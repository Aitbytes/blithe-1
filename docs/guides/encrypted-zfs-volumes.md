# Managing the Encrypted ZFS Volume "Napokue-20g"

This guide provides instructions for managing the 20GB LUKS-encrypted ZFS volume named `Napokue-20g`. This volume is intended for storing sensitive data that requires an additional layer of security.

The ZFS volume is located at `Alpha-Aegialeus/Napokue-20g`, and its encryption key is stored in HashiCorp Vault.

**WARNING:** Losing access to the Vault instance or the specific secret will result in the permanent loss of all data on the encrypted volume.

---

## How to Mount the Volume (e.g., after a system reboot)

After a reboot, the LUKS container will be closed and unmounted. Follow these steps to make it accessible again.

1.  **Retrieve and Decode the Key from Vault:**
    The key is stored Base64-encoded in Vault. You must retrieve it and decode it before use.

    ```bash
    # Retrieve, decode, and save the key to a temporary file
    vault kv get -field=key kv/luks/Napokue-20g | base64 --decode > /tmp/Napokue-20g.key

    # Set secure permissions for the key file
    chmod 400 /tmp/Napokue-20g.key
    ```

2.  **Copy the Key to the Proxmox Host:**
    Use `scp` to securely transfer the key file to the Proxmox server.

    ```bash
    scp /tmp/Napokue-20g.key root@192.168.1.10:/root/Napokue-20g.key
    ```

3.  **Open the LUKS Container:**
    Use `cryptsetup` on the Proxmox host to open the encrypted ZFS volume with the key file.

    ```bash
    ssh root@192.168.1.10 'cryptsetup luksOpen --key-file /root/Napokue-20g.key /dev/zvol/Alpha-Aegialeus/Napokue-20g Napokue-20g-volume'
    ```

4.  **Mount the Filesystem:**
    Mount the decrypted volume to your desired location. The standard mount point is `/mnt/Napokue-20g`.

    ```bash
    # Ensure the mount point exists
    ssh root@192.168.1.10 'mkdir -p /mnt/Napokue-20g'

    # Mount the volume
    ssh root@192.168.1.10 'mount /dev/mapper/Napokue-20g-volume /mnt/Napokue-20g'
    ```

5.  **Clean Up:**
    For security, remove the key file from both the local machine and the Proxmox host after the volume is mounted.

    ```bash
    rm /tmp/Napokue-20g.key
    ssh root@192.168.1.10 'rm /root/Napokue-20g.key'
    ```

The volume is now accessible at `/mnt/Napokue-20g` on the Proxmox host.

---

## How to Unmount and Close the Volume

When you are finished accessing the data, you should unmount and close the container to secure the data at rest.

1.  **Unmount the Filesystem:**

    ```bash
    ssh root@192.168.1.10 'umount /mnt/Napokue-20g'
    ```

2.  **Close the LUKS Container:**
    This removes the decrypted device mapper entry, making the data inaccessible until it is opened again.

    ```bash
    ssh root@192.168.1.10 'cryptsetup luksClose Napokue-20g-volume'
    ```

The volume is now securely closed.
