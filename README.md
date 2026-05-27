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
- `$ pacman -S kitty gtk3 rofi dolphin swww`
Follow the instructions on [Hyprland Wiki](https://wiki.hyprland.org/).
## 4. Install Quickshell / DankMaterialShell
If you use DankMaterialShell:
- Make sure to install `quickshell` and the required package `dms-shell-bin` (or build from your repository).

## 5. Export/Deploy dotfiles (Import to System)
To copy the configurations from this repository into your active `~/.config` directory:

```bash
# Clone this repository (if not already done)
git clone https://github.com/RukasuDesuu/dot-files.git ~/.config/style

# Deploy Hyprland config
mkdir -p ~/.config/hypr
cp ~/.config/style/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
cp ~/.config/style/hypr/spotify-playpause.sh ~/.config/hypr/spotify-playpause.sh
chmod +x ~/.config/hypr/spotify-playpause.sh

# Deploy Kitty config
mkdir -p ~/.config/kitty
cp -r ~/.config/style/kitty/* ~/.config/kitty/

# Deploy DankMaterialShell settings
mkdir -p ~/.config/DankMaterialShell
cp ~/.config/style/DankMaterialShell/settings.json ~/.config/DankMaterialShell/settings.json

# Deploy Fish config
mkdir -p ~/.config/fish
cp ~/.config/style/fish/config.fish ~/.config/fish/config.fish

# Deploy Fuzzel config
mkdir -p ~/.config/fuzzel
cp ~/.config/style/fuzzel/fuzzel.ini ~/.config/fuzzel/fuzzel.ini

# Deploy Cava config
mkdir -p ~/.config/cava
cp ~/.config/style/cava/config ~/.config/cava/config

# Deploy Btop config
mkdir -p ~/.config/btop
cp -r ~/.config/style/btop/* ~/.config/btop/

# Deploy GTK 3.0 & GTK 4.0 colors/styles
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cp -r ~/.config/style/gtk-3.0/* ~/.config/gtk-3.0/
cp -r ~/.config/style/gtk-4.0/* ~/.config/gtk-4.0/

# Deploy Qt 5 & Qt 6 configs
mkdir -p ~/.config/qt5ct ~/.config/qt6ct
cp -r ~/.config/style/qt5ct/* ~/.config/qt5ct/
cp -r ~/.config/style/qt6ct/* ~/.config/qt6ct/

# Deploy Waybar config (optional)
mkdir -p ~/.config/waybar
cp -r ~/.config/style/waybar/* ~/.config/waybar/
```

## 6. How to Back Up Active Configurations (Export to Repo)
Whenever you modify your local configurations and want to commit them back to this repository, run the following commands from the `~/.config/style` folder:

```bash
cd ~/.config/style

# Pull active configs into the repository
cp ~/.config/hypr/hyprland.conf ./hypr/
cp ~/.config/hypr/spotify-playpause.sh ./hypr/
cp -r ~/.config/kitty/* ./kitty/
cp ~/.config/DankMaterialShell/settings.json ./DankMaterialShell/
cp ~/.config/fish/config.fish ./fish/
cp ~/.config/fuzzel/fuzzel.ini ./fuzzel/
cp ~/.config/cava/config ./cava/
cp -r ~/.config/btop/* ./btop/
cp -r ~/.config/gtk-3.0/* ./gtk-3.0/
cp -r ~/.config/gtk-4.0/* ./gtk-4.0/
cp -r ~/.config/qt5ct/* ./qt5ct/
cp -r ~/.config/qt6ct/* ./qt6ct/
cp -r ~/.config/waybar/* ./waybar/

# Stage and commit your changes
git add .
git commit -m "Update configurations"
git push origin main
```

## 7. Install wallpaper
Install **wallpaper.gif** and **wallpaper_static.png** from [This Drive](https://drive.google.com/drive/folders/1jc7Q7E3MQFgboO9pTSi3rd9tDr2yDWdE?usp=sharing) and place them in `~/.config/style/`.

