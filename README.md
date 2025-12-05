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
recommended partition:
| Mount point on the installed system | Partition | Partition Type | Suggested Size |
|-------------------------------------|-----------|----------------|----------------|
| `/boot` | `/dev/efi_system_partition` | EFI System Partition | 1GiB |
| `[SWAP]` | `/dev/swap_partition` | Linux swap | at least 4GiB |
| / | /dev/root_partition | Linux x86-64 root(/) | Remainder of the device. At least 23–32 GiB. |
 
For more info, check: [Arch Wiki - Installation Guide](https://wiki.archlinux.org/title/Installation_guide)

## 2. Install Hyprland

## 3. Install Hyprpanel

(Probably i`ll change to waybar or quickshell)
## 4. Export dot files config

## 5. Change config folders

## 6. Install wallpaper
Install **wallpaper.gif** and **wallpaper_static.png** from [This Drive](https://drive.google.com/drive/folders/1jc7Q7E3MQFgboO9pTSi3rd9tDr2yDWdE?usp=sharing)
