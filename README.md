# How to Install

## 1. Install Arch
- Prepare an Arch Linuyx Installation Media (USB/DVD) with Arch ISO
- Boot from the Installation Media
- Set the keyboard layout if needed (standard is US)
  
`# localectl list-keymaps`
`# loadkeys <keymap>` (for example: `# loadkeys us-acentos`)

- Set the text font

`# setfont ter-132n` (change to other number for different sizes)

- Verify the boot mode

`# cat /sys/firmware/efi/fw_platform_size`
> if the command returns an error, you are in BIOS mode. If it returns 32 or 64, you are in UEFI mode. (expected: 64, or on an VM it may return an error)

- Connect to the internet

run `# ip link` to check if you device is being listened
`# iwctl` (for wireless connections)
`[iwd]# device list` (to list network devices)
`[iwd]# station <device_name> scan` (to scan for networks)
`[iwd]# station <device_name> get-networks` (to list available networks)
`[iwd]# station <device_name> connect <network_name>` (to connect to a network, will prompt for password if needed)
`[iwd]# exit` (to exit iwctl)
check connection status with `# ping ping.archlinux.org`

- Update system clock

`# timedatectl`
- Partition the disk

`# cfdisk`
select 'gpt' if you are in UEFI mode, or 'MBR' if you are in BIOS mode.
recommended partition for UEFI mode:
| Mount point on the installed system | Partition | Partition Type | Suggested Size |
|-------------------------------------|-----------|----------------|----------------|
| `/boot` | `/dev/efi_system_partition` | EFI System Partition | 1GiB |
| `[SWAP]` | `/dev/swap_partition` | Linux swap | at least 4GiB |
| / | /dev/root_partition | Linux x86-64 root(/) | Remainder of the device. At least 23–32 GiB. |

recommended partition for BIOS mode:
| Mount point on the installed system | Partition | Partition Type | Suggested Size |
|-------------------------------------|-----------|----------------|----------------|
| `[SWAP]` | `/dev/swap_partition` | Linux swap | at least 4GiB |
| / | /dev/root_partition | Linux x86-64 root(/) | Remainder of the device. At least 23–32 GiB. |

write and exit cfdisk
you can check the created partitions with `# lsblk`
- Format the partitions

`# mkfs.fat -F32 /dev/efi_system_partition` (only for UEFI mode)
`# mkswap /dev/swap_partition`
`# swapon /dev/swap_partition`
`# mkfs.ext4 /dev/root_partition`

- Mount the file systems

`# mount /dev/root_partition /mnt`
`# mkdir /mnt/boot` (only for UEFI mode)
`# mount /dev/efi_system_partition /mnt/boot` (only for UEFI mode)
list findmnt to verify mounts with `# findmnt`

- Install essential packages

Installing linux kernel, firmware and basic tools
`# pacstrap /mnt base linux linux-firmware`

- Configure the system

Generate fstab file
`# genfstab -U /mnt >> /mnt/etc/fstab`

Chroot into the new system with `# arch-chroot /mnt`
And proceed with the essential packages installation
`# pacman -Syu grub efibootmgr networkmanager nano sudo git`


Set the time zone
`# ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`  (change Region/City accordingly, America/Sao_Paulo for example) 
`# hwclock --systohc`


- Localization

Edit the locale.gen file to uncomment your needed locales
`# nano /etc/locale.gen`
and generate them
`# locale-gen`

- Create the locale.conf file

`# nano /etc/locale.conf`
```
LANG=en_US.UTF-8
```
(change if you use another locale)

- persist keyboard layout across reboots

`# nano /etc/vconsole.conf`
```
KEYMAP=us-acentos
```
(change if you use another layout)
- Set the hostname

`# nano /etc/hostname`

- Set the root password

`# passwd`

- Configure the bootloader

`# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB` (for UEFI mode)
`# grub-install --target=i386-pc /dev/sdX` (for BIOS mode, change sdX to your disk, like sda)
`# grub-mkconfig -o /boot/grub/grub.cfg`

- Enable NetworkManager service

`# systemctl enable NetworkManager`

- Create a new user

`# useradd -mG wheel username` (change username accordingly)
`# passwd username`
`# nano /etc/sudoers` and uncomment the line
```
%wheel ALL=(ALL) ALL
```

- Exit chroot environment

`# exit`

- Reboot the system

`# reboot`

For more info, check: [Arch Wiki - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)

## 2. Install Hyprland
First install an AUR helper, like yay:
- `$ pacman -S --needed base-devel git`
- `$ git clone https://aur.archlinux.org/yay.git`
- `$ cd yay`
- `$ makepkg -si`
Then install Hyprland:

- `$ yay -S hyprland-git`

## 3. Install Fundamental Packages
- `$ pacman -S kitty gtk3 rofi dolphin`
Follow the instructions on [Hyprland Wiki](https://wiki.hyprland.org/).
## 3. Install Hyprpanel

`$ yay -S ags-hyprpanel-git` 

(Probably i`ll change to [waybar](https://github.com/Alexays/Waybar) or [quickshell](https://github.com/username/quickshell) in the future) 
## 4. Export dot files config
`$ git clone https://github.com/RukasuDesuu/dot-files.git ~/.config/style` 
## 5. Change config folders
`hyprland -c ~/.config/style/hypr/hyprland.conf
## 6. Install wallpaper
Install **wallpaper.gif** and **wallpaper_static.png** from [This Drive](https://drive.google.com/drive/folders/1jc7Q7E3MQFgboO9pTSi3rd9tDr2yDWdE?usp=sharing)
