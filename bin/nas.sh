#!/usr/bin/env bash

echo "Toggling NFS mountpoints on local network..."

declare -a mountpoints=("/mnt/assets"
                        "/mnt/documents"
                        "/mnt/images"
                        "/mnt/plex"
                        "/mnt/projects")

# Configuration for NFS shares in /etc/fstab.
# Note this will only work if this computer is on the same local network!

for point in "${mountpoints[@]}"; do
    if mountpoint -q "$point"; then
        echo "$point is mounted. unmounting."
        umount "$point"
    else
        echo "$point is unmounted. mounting."
        mount "$point"
    fi
done
