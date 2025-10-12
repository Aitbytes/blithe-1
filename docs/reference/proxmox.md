# Proxmox Server Documentation

This document provides a snapshot of the Proxmox server configuration.

## 1. System Information

### 1.1. Hardware

#### CPU
- **Model:** Intel(R) Xeon(R) CPU E5-2689 0 @ 2.60GHz
- **Cores:** 8
- **Threads:** 16
- **Architecture:** x86_64
- **Virtualization:** VT-x
- **L1d cache:** 256 KiB (8 instances)
- **L1i cache:** 256 KiB (8 instances)
- **L2 cache:** 2 MiB (8 instances)
- **L3 cache:** 20 MiB (1 instance)

#### Memory
- **Total RAM:** 31Gi
- **Used RAM:** 10Gi
- **Total Swap:** 8.0Gi
- **Used Swap:** 0B

#### Storage
- **NVMe Drive:** `/dev/nvme0n1` (238.5G) - Boot drive, LVM managed.
  - `pve-root`: 69.4G (ext4) - Proxmox OS
  - `pve-data`: 141.2G (LVM Thin Pool) - VM Disks
- **SATA Drive 1:** `/dev/sda` (1.8T) - A `298.1G` partition is part of ZFS Pool `Alpha-Aegialeus`. The rest is unallocated.
- **SATA Drive 2:** `/dev/sdb` (298.1G) - The entire disk is used by ZFS Pool `Alpha-Aegialeus`.
- **SATA Drive 3:** `/dev/sdc` (465.8G) - A `298.1G` partition is part of ZFS Pool `Alpha-Aegialeus`. The rest is unallocated.
- **ZFS Pool `Alpha-Aegialeus`:**
  - **Disks:** `/dev/sda1`, `/dev/sdb1`, `/dev/sdc1`
  - **RAID Level:** RAID-Z1 (Single-disk redundancy)

#### PCI Devices
- **Host bridge:** Intel Corporation Xeon E5/Core i7 DMI2
- **Ethernet controller:** Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller
- **SATA controller:** Intel Corporation 6 Series/C200 Series Chipset Family 6 port Desktop SATA AHCI Controller
- **USB controller:** Intel Corporation 6 Series/C200 Series Chipset Family USB Enhanced Host Controller
- **Non-Volatile memory controller:** Silicon Motion, Inc. SM2261XT x2 NVMe SSD Controller (DRAM-less)

#### USB Devices
- **Bus 001:** Linux Foundation 2.0 root hub, Intel Corp. Integrated Rate Matching Hub
- **Bus 002:** Linux Foundation 2.0 root hub, Intel Corp. Integrated Rate Matching Hub

### 1.2. Software

- **Operating System:** Debian GNU/Linux 12 (bookworm)
- **Kernel Version:** 6.8.4-2-pve
- **Proxmox Version:** pve-manager/8.2.2/9355359cd7afbae4

### 1.3. Networking

- **Primary Interface (vmbr0):** 192.168.1.10/24
- **Tailscale:** 100.125.19.56/32

## 2. Virtualization

### 2.1. Virtual Machines

| VMID | Name                      | Status  | Memory (MB) | Boot Disk (GB) |
|------|---------------------------|---------|-------------|----------------|
| 100  | bootstrap-base-template   | stopped | 4096        | 20.00          |
| 101  | win10ltsc                 | stopped | 10240       | 60.00          |
| 102  | Win10ltscQ35              | stopped | 8196        | 48.00          |
| 103  | Windox-XP                 | stopped | 4096        | 12.00          |
| 104  | Android-001               | stopped | 4096        | 32.00          |
| 106  | StdDebian                 | stopped | 2048        | 8.00           |
| 9003 | VM 9003                   | stopped | 2048        | 3.50           |
| 9004 | VM 9004                   | stopped | 2048        | 3.50           |

### 2.2. Containers

| VMID | Status  | Name       |
|------|---------|------------|
| 105  | running | Debian-003 |

## 3. Key Running Services

- `ceph-crash.service`: Ceph crash dump collector
- `chrony.service`: NTP client/server
- `corosync.service`: Corosync Cluster Engine
- `nmbd.service`: Samba NMB Daemon
- `postfix@-.service`: Postfix Mail Transport Agent
- `pve-cluster.service`: The Proxmox VE cluster filesystem
- `pvedaemon.service`: PVE API Daemon
- `smbd.service`: Samba SMB Daemon
- `ssh.service`: OpenBSD Secure Shell server
- `tailscaled.service`: Tailscale node agent
- `zfs-zed.service`: ZFS Event Daemon (zed)

## 4. Detailed Network Configuration

### 4.1. Host Network Configuration (`/etc/network/interfaces`)

The Proxmox host's networking is centered around a few key virtual and physical interfaces:

*   **`vmbr0` (Primary Bridge):**
    *   **IP Address:** `192.168.1.10/24` (Static)
    *   **Gateway:** `192.168.1.1`
    *   **Physical Port:** `enp6s0`
    *   **Description:** This is the main network bridge. It connects the Proxmox host and its virtual guests (VMs and Containers) to the local LAN.

*   **`wlp7s0` (Wireless Interface):**
    *   **Configuration:** DHCP
    *   **Description:** The server has a wireless card configured to connect to a Wi-Fi network and get an IP address automatically.

*   **`private0` & `private1` (Isolated Bridges):**
    *   **Description:** These are two virtual bridges not connected to any physical network interface. Their purpose is to allow for completely private and isolated networking between VMs.

### 4.2. Firewall Status

*   The Proxmox firewall configuration directory (`/etc/pve/firewall/`) is empty, which means the server is running with default firewall settings. No custom, cluster-wide rules have been created.

### 4.3. Container: `Debian-003` (ID 105)

The network configuration inside this container reveals a complex setup:

*   **Direct LAN Access:** The container has a virtual network interface `eth0` with the IP address `192.168.1.50`, which is on the main LAN. This connection is bridged through the host's `vmbr0`.

*   **Docker Installation Detected:** The container has a large number of additional network bridges (e.g., `docker0`, `br-a2a05991798c`, `br-cfbf5deb12ef`, etc.). This is a clear indication that **Docker is running inside the `Debian-003` container**. These bridges are created by Docker to manage the networks for its own containers.

This indicates a nested virtualization setup where the LXC container itself acts as a host for Docker containers.

## 5. Detailed Storage Configuration

The server utilizes a combination of LVM (Logical Volume Management) and ZFS for storage.

### 5.1. Proxmox Storage View (`/etc/pve/storage.cfg`)

Proxmox is configured to use two main storage pools:

*   **`local-lvm` (LVM-Thin):**
    *   **Type:** LVM Thin Pool
    *   **Volume Group:** `pve`
    *   **Thin Pool:** `data`
    *   **Content:** VM and Container Disks
    *   **Description:** This is the default storage for virtual disks, located on the fast NVMe drive.

*   **`Alpha-Aegialeus` (ZFS):**
    *   **Type:** ZFS Pool
    *   **ZFS Pool:** `Alpha-Aegialeus`
    *   **Content:** VM and Container Disks
    *   **Description:** A redundant ZFS pool for bulk data storage.

### 5.2. LVM Configuration (Boot Drive)

The primary NVMe drive (`nvme0n1p3`) is managed by LVM.

*   **Volume Group (VG):** `pve`
    *   **Size:** 237.47 GiB
    *   **Physical Volume (PV):** `/dev/nvme0n1p3`

*   **Logical Volumes (LVs) within `pve` VG:**
    *   **`root`:** 69.37 GiB - The operating system's root filesystem.
    *   **`swap`:** 8.00 GiB - The system's swap space.
    *   **`data`:** 141.23 GiB - A thin pool that holds the actual virtual disks for VMs and containers stored in `local-lvm`.

### 5.3. ZFS Configuration

A new, redundant ZFS pool has been created for bulk storage.

*   **Pool Name:** `Alpha-Aegialeus`
    *   **Status:** `DEGRADED` (Resilvering) - The pool is currently rebuilding its redundancy after a disk replacement. It is online and functional during this process.
    *   **RAID Level:** `raidz1` (Single-disk fault tolerance)
    *   **Physical Disks:** The pool is composed of partitions from three physical disks. The pool was created using the device names, but the persistent identifiers are included here for accurate hardware tracking:
        *   **`sda1`**: `ata-ST2000NM000A-2J2100_WJC01CY5`
        *   **`sdb1`**: `ata-Hitachi_HDT725032VLA360_VFD200R21U7MSC`
        *   **`sdc1`**: `ata-WDC_WD5000LPVX-80V0TT0_WD-WX71AA3U9624`
    *   **Note:** This configuration ensures that the failure of any single disk will not result in data loss.
