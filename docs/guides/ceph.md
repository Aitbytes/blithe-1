# Guide: Manually Mounting a Ceph RBD Volume into an LXC Container

This guide details the process of creating a Ceph RBD (RADOS Block Device) image on a Proxmox host and manually mounting it into an LXC container. This is a useful technique for providing persistent, network-replicated storage to a container for testing or specific applications.

## Prerequisites

- A functional Proxmox VE environment with a healthy Ceph cluster.
- A Ceph pool created for RBD storage (e.g., `rbd-proxmox`).
- An existing LXC container (e.g., container ID `105`, name `debian003`).
- SSH root access to the Proxmox host.

---

## Part 1: Creating and Mounting the Volume on the Host

This part covers the creation of the virtual block device and preparing it on the Proxmox host.

### 1. Create an RBD Image

First, create a new RBD image within your Ceph pool. This command creates a 1GB image named `test-volume-1`.

```bash
rbd create rbd-proxmox/test-volume-1 --size 1G
```

### 2. Map the Image to a Host Device

Map the newly created image to a kernel block device on the Proxmox host. This makes the RBD image appear as if it were a physical disk.

```bash
rbd map rbd-proxmox/test-volume-1
# Expected output: /dev/rbd0
```

The command will output the name of the new device, typically `/dev/rbd0`.

### 3. Format the Device

Format the new block device with a filesystem. `ext4` is a common choice.

```bash
mkfs.ext4 /dev/rbd0
```

### 4. Create a Host Mount Point

Create a directory on the Proxmox host where you will temporarily mount the volume.

```bash
mkdir -p /mnt/ceph-test
```

### 5. Mount the Device on the Host

Mount the formatted device to the directory you just created.

```bash
mount /dev/rbd0 /mnt/ceph-test
```

At this point, the Ceph volume is accessible on the Proxmox host at `/mnt/ceph-test`.

---

## Part 2: Bind-Mounting the Volume into the LXC Container

This part covers making the host-mounted volume accessible inside the target container.

### 1. Create a Mount Point in the Container

Before you can mount the volume, a mount point directory must exist *inside* the container.

```bash
pct exec 105 -- mkdir -p /mnt/ceph-volume
```
*(Replace `105` with your container's ID and `/mnt/ceph-volume` with your desired mount path).*

### 2. Configure the Bind-Mount

Use the `pct set` command to create a persistent bind-mount. This tells Proxmox to take the directory mounted on the host (`/mnt/ceph-test`) and make it available at a specified path inside the container.

```bash
pct set 105 -mp0 /mnt/ceph-test,mp=/mnt/ceph-volume
```
- `105`: The container ID.
- `-mp0`: The mount point index (0 for the first one).
- `/mnt/ceph-test`: The source directory on the Proxmox host.
- `mp=/mnt/ceph-volume`: The destination path inside the container.

### 3. Restart the Container

For the new mount point to become active, the container must be restarted.

```bash
pct stop 105 && pct start 105
```

### 4. Verify the Mount

Check if the volume is now accessible inside the container.

```bash
pct exec 105 -- ls -l /mnt/ceph-volume
# Expected output:
# total 16
# drwx------ 2 nobody nogroup 16384 Oct 15 13:35 lost+found
```
The presence of `lost+found` confirms the mount is successful.

---

## Part 3: Cleanup and Reverting Changes

Follow these steps to cleanly unmount and delete the experimental volume.

### 1. Remove the Bind-Mount from the Container

First, remove the mount point configuration from the container.

```bash
pct set 105 --delete mp0
```

### 2. Restart the Container

Restart the container to ensure the directory is fully unmounted.

```bash
pct stop 105 && pct start 105
```

### 3. Unmount from the Host

Unmount the volume from the host's filesystem.

```bash
umount /mnt/ceph-test
```

### 4. Remove the Host Mount Point

Delete the temporary directory.

```bash
rmdir /mnt/ceph-test
```

### 5. Unmap the RBD Device

Remove the block device mapping from the host's kernel.

```bash
rbd unmap /dev/rbd0
```

### 6. Delete the RBD Image

Finally, delete the image from the Ceph pool to free the storage space.

```bash
rbd rm rbd-proxmox/test-volume-1
```

---

# Guide: Creating a Proxmox VM with a Ceph RBD Disk

This guide covers creating a Proxmox VM with its main disk hosted on a Ceph RBD storage pool. It also details a critical troubleshooting step related to authentication that can occur when the Ceph cluster is configured manually via the command line.

## Prerequisites

- A functional Proxmox VE environment with a healthy Ceph cluster.
- A Ceph pool configured as an RBD storage target in Proxmox (e.g., `ceph-storage`).
- An existing VM template to clone from (e.g., VMID `106`, name `StdDebian`).
- SSH root access to the Proxmox host.

---

## Part 1: Creating the VM

The primary method for creating a VM on Ceph storage is to clone an existing template and specify the target storage during the process.

### 1. Clone the Template

Use the `qm clone` command to create a new VM.

```bash
# Usage: qm clone <template_id> <new_vmid> --name <vm_name> --full --storage <ceph_storage_name>
qm clone 106 108 --name test-ceph-vm --full --storage ceph-storage
```

This command creates a full clone of the template's disk, placing the new disk image directly into the `ceph-storage` pool.

### 2. Start and Verify the VM

Once the clone is complete, start the new VM to ensure it boots correctly.

```bash
qm start 108
qm status 108
```

---

## Part 2: Troubleshooting Connection Errors

During a manual CLI-based Ceph setup, Proxmox's `qm` and `pvesm` tools may fail to connect to the cluster even when `ceph` and `rbd` commands work correctly. This is typically an authentication issue.

### Symptom

Commands like `qm clone` or `qm set` fail with errors such as:

- `rbd error: rbd: listing images failed: (95) Operation not supported`
- `rbd error: rbd: couldn't connect to the cluster!`

These errors indicate that the Proxmox daemon (`pvedaemon`) does not have the correct authentication key to manage the Ceph cluster.

### Solution: Explicitly Configure the Keyring

The solution is to ensure the Ceph admin key is copied to the location Proxmox expects and that the storage configuration explicitly references it.

**1. Copy the Admin Keyring**

The `pveceph` tool creates the admin key at `/etc/ceph/ceph.client.admin.keyring`. Copy it to the path Proxmox requires for your specific storage pool.

```bash
# The destination filename should match your storage pool name: <storage_name>.keyring
mkdir -p /etc/pve/priv/ceph
cp /etc/ceph/ceph.client.admin.keyring /etc/pve/priv/ceph/ceph-storage.keyring
```

**2. Update the Storage Configuration**

Edit the `/etc/pve/storage.cfg` file and add the `keyring` parameter to your RBD storage definition.

**Incorrect (before):**
```
rbd: ceph-storage
	pool rbd-proxmox
	content images
	monhost 10.10.10.10
```

**Correct (after):**
```
rbd: ceph-storage
	pool rbd-proxmox
	content images
	monhost 10.10.10.10
	keyring /etc/pve/priv/ceph/ceph-storage.keyring
```

After making these changes, the `qm clone` command should succeed.

---

## Part 3: Cleanup

To remove the test VM and its associated disk from Ceph, follow these steps.

### 1. Stop the VM

```bash
qm stop 108
```

### 2. Destroy the VM

The `qm destroy` command will automatically locate and delete the VM's disk from the Ceph pool.

```bash
qm destroy 108
```