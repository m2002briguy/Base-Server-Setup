#!/bin/bash

# Check if the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

# The lines to be added to /etc/fstab
FSTAB_ENTRIES="
###########DISK SETUP############

#parity disk
/dev/disk/by-id/ata-ST6000DM003-2CY186_ZR10LZR1-part1 /mnt/Life/1-Parity ext4 defaults 0 2
/dev/disk/by-id/ata-HGST_HUS726T6TALE6L4_V9G7S8PL-part1 /mnt/Life/2-Parity ext4 defaults 0 2

#data disks
/dev/disk/by-id/ata-ST4000LM024-2AN17V_WCK73B51-part1 /mnt/data/NAS_1 ext4 defaults 0 2
/dev/disk/by-id/ata-ST4000LM024-2AN17V_WCK79DJ2-part1 /mnt/data/NAS_2 ext4 defaults 0 2
/dev/disk/by-id/ata-ST4000LM024-2AN17V_WCK79DF7-part1 /mnt/data/NAS_3 ext4 defaults 0 2
/dev/disk/by-id/ata-HITACHI_HUS724040ALE640_PBGURTVS-part1  /mnt/data/NAS_4 ext4 defaults 0 2
/dev/disk/by-id/ata-WL3000GSA6454_WOL240385091-part1 /mnt/data/NAS_6 ext4 defaults 0 2
/dev/disk/by-id/ata-HGST_HUS724040ALA640_PN1334PBJNYZ0S-part1 /mnt/data/NAS_7 ext4 defaults 0 2

#mergerfs mount
/mnt/data/* /mnt/mashed fuse.mergerfs allow_other,direct_io,use_ino,category.create=lfs,moveonenospc=true,minfreespace=20G,fsname=mergerfsPool 0 0

#Camera Disk
/dev/disk/by-id/ata-WDC_WD5000AAKX-75U6AA0_WD-WCC2E3XES1LH-part1 /mnt/cams ext4 defaults 0 2

#Photo Backup
/dev/disk/by-id/ata-HGST_HUS724040ALA640_PN2334PEJUWENT-part1 /mnt/photobu ext4 defaults 0 2
"

# Check if the entries are already in /etc/fstab
if grep -q "###########DISK SETUP############" /etc/fstab; then
    echo "Disk setup entries already exist in /etc/fstab. Exiting."
    exit 0
fi

# Append the entries to /etc/fstab
echo "$FSTAB_ENTRIES" >> /etc/fstab

# Verify the changes
echo "Disk setup entries added to /etc/fstab successfully!"

# Run the create-dirs.sh script
if [[ -f "./create-dirs.sh" ]]; then
    echo "Running create-dirs.sh..."
    bash ../create-dirs.sh
else
    echo "create-dirs.sh not found! Please make sure it's in the same directory."
    exit 1
fi
