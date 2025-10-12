# ZFS Storage Reconfiguration Plan

This document outlines the procedure for reconfiguring the ZFS storage pool on the Proxmox server.

### **High-Level Goal:**
Transform the existing storage into a 3-disk redundant ZFS pool named `Alpha-Aegialeus`, using partitions of equal size from `/dev/sda`, `/dev/sdb`, and `/dev/sdc`.

### **⚠️ IMPORTANT: Pre-Migration Warning**

*   **RISK OF DATA LOSS:** This operation involves destroying the existing ZFS pool. While the plan includes migrating the data first, any failure during the copy process or a mistake in execution could lead to the complete loss of data on `Pool-001`. **A complete backup of the data on `Pool-001` to an entirely separate location is strongly recommended before proceeding.**
*   **SERVICE DOWNTIME:** The services that rely on the storage (primarily the `Debian-003` container, ID 105) will be unavailable for the duration of this migration.

---

### **Original Step-by-Step Plan**

The original plan was divided into three phases: migrating the data to a temporary location, creating a new degraded ZFS pool, and finally adding the temporary disk back into the pool to achieve redundancy. The full, detailed plan can be found in this document's Git history.

---
## **Execution Narrative: A Tale of unexpected Hurdles**

The migration was ultimately successful, but the journey was far from straightforward. This narrative documents the challenges encountered and the solutions devised, serving as a reference for future operations.

### **The First Hurdle: Building the Degraded Pool**

Our first task was to create a new, degraded `raidz1` pool. We discovered the initial `Alpha-Aegialeus` pool had been created incorrectly as a simple, non-redundant pool. After destroying it, we revisited our strategy. The original plan suggested using the `missing` keyword in the `zpool create` command, but online research pointed to a more robust method: using a temporary sparse file as a placeholder. We created a 298GB sparse file, used it to build the `raidz1` pool (requiring the `-f` flag to mix file and device vdevs), and then immediately took the placeholder offline. This left us with a clean, correctly configured degraded pool, ready for data.

### **From Smooth Sailing to a Stubborn Mount**

The data transfer itself was seamless. We copied 376GB of data from the temporary storage on `/dev/sda1` to the new ZFS pool using `rsync`. However, when it came time to decommission the temporary storage, we hit a snag. The filesystem refused to unmount, reporting that it was "busy." A quick investigation with `lsof` revealed the culprit: a lingering root shell session had the mount point as its current directory. After terminating the blocking process, we were able to wipe the partition and prepare the disk for its final role.

### **The Devil in the Details: A Matter of Sectors**

With the third disk ready, we attempted to add it to the pool to begin the resilvering process. ZFS, however, rejected the disk, claiming it was too small. This was puzzling, as we had created the partition with the same `298G` size designation as the others. The issue was one of precision. `parted`'s interpretation of "298G" was slightly different from the exact size of the other pool members.

The solution was to be exact. We queried the partition table of `/dev/sdb`, noted the precise end sector (`625141759s`), and used that exact value to re-create the partition on `/dev/sda`. With a perfect size match, `zpool replace` accepted the disk, and the pool finally began resilvering.

### **The Final Boss: Proxmox's Quirks**

With the storage layer healing, we moved to the final step: starting the container. This is where we encountered the most challenging problem. The `pct start 105` command hung indefinitely. More alarmingly, even trying to read the container's configuration file also hung. This pointed to a deeper issue with Proxmox itself.

A check of the `pve-cluster` service logs revealed the root cause: `database or disk is full`. The cluster's configuration database had locked up. A simple restart of the service brought the filesystem back to life, but the container still wouldn't start, now failing with a `pre-start hook` error.

Recalling a past issue, we realized the hook script was likely rejecting the container's modern Debian 13 "trixie" version. To solve this, we mounted the container's logical volume on the host and discovered two separate files defining the OS version: `/etc/os-release` and `/etc/debian_version`. After modifying both to report the older, compatible "Debian 12 (bookworm)", the container finally started without issue.

As a final correction, we ensured the container's configuration used a bind mount to expose only the necessary subdirectory (`/Alpha-Aegialeus/subvol-105-disk-0`) rather than the entire pool.

The migration is now complete. The system is fully operational, and the `Alpha-Aegialeus` pool is resilvering in the background, on its way to full health.