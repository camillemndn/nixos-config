# My NixOS configurations <img src="https://upload.wikimedia.org/wikipedia/commons/2/28/Nix_snowflake.svg" alt= "❄" width="20px" height="20px">

[![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)

This repository contains the configurations of my machines using NixOS. 

## *What is NixOS ?*

NixOS is a linux distribution based on the Nix package manager. It allows fully reproducible builds and a declarative configuration style, using a functional langage called Nix.

## *What is a flake ?*

This whole repository is a flake. It is an experimental feature of Nix, allowing for pure evaluation of code. Dependencies are fully specified and locked.

## Inspirations

This project is freely inspired by [JulienMalka/nix-config](https://github.com/JulienMalka/nix-config).

## My machines:

- **genesis**, an Asus ROG X13 convertible laptop with secure boot, Gnome (*soon Hyprland*) and fully functional hardware except for fingerprint sensor
- **offspring**, an Oracle VM with monitoring services
- **pinkfloyd**, a PinePhone with Mobile NixOS (*decommissioned*) 
- **radiogaga**, a Raspberry Pi 3B used as a smart alarm clock
- **rush**, a Raspberry Pi 4B with UEFI
- **wutang**, a Windows Subsystem for Linux machine (*decommissioned*)
- **zeppelin**, a NUC with a multimedia server and many other things

## Toolbox

### [Install Secure Boot with ```sbctl```](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md)

### Speed up LUKS encryption on USB ([source](https://www.reddit.com/r/Fedora/comments/zlrmmt/disable_dmcrypt_workqeues_to_improve_ssd/))

```
sudo su -
cryptsetup convert --type luks2 /dev/<disk>
cryptsetup luksOpen /dev/<disk> <name>
cryptsetup --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh <name>
```

### Install NixOS with ZFS

```
DISK=/dev/disk/by-id/<id>

sgdisk --zap-all $DISK
sgdisk -n3:1M:+512M -t3:EF00 $DISK
sgdisk -n1:0:+1854G -t1:BF01 $DISK
sgdisk -n2:0:0 -t2:8200 $DISK

zpool create -O mountpoint=none -O relatime=on -O compression=lz4 -O xattr=sa -O acltype=posixacl -O encryption=aes-256-gcm -O keylocation=prompt -O keyformat=passphrase -o ashift=12 -R /mnt rpool $DISK-part1
zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home

mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/home
mount -t zfs rpool/home /mnt/home
mkfs.vfat $DISK-part3
mkdir /mnt/boot
mount $DISK-part3 /mnt/boot

# If RPI4 EFI
# nix-shell -p wget unzip
# wget https://github.com/pftf/RPi4/releases/download/v1.33/RPi4_UEFI_Firmware_v1.33.zip
# unzip RPi4_UEFI_Firmware_v1.33.zip -d /mnt/boot

umount /mnt/boot
zpool export rpool
```

### Build NixOS Image with GUI for aarch64

```
docker run -it --platform linux/arm64 nixos/nix
git clone https://github.com/NixOS/nixpkgs.git --depth 1

# fetch and check out the latest release tag
# apply changes to `https://github.com/NixOS/nixpkgs/compare/master...Thra11:nixpkgs:aarch64-graphical-iso` from https://github.com/NixOS/nixpkgs/compare/master...Thra11:nixpkgs:aarch64-graphical-iso

nix-build -A config.system.build.isoImage -I nixos-config=modules/installer/cd-dvd/installation-cd-graphical-gnome.nix default.nix
```
