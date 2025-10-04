# From LiveCD

```
livecd /home/gentoo/install # fdisk /dev/nvme0n1

Welcome to fdisk (util-linux 2.41.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

This disk is currently in use - repartitioning is probably a bad idea.
It's recommended to umount all file systems, and swapoff all swap
partitions on this disk.


Command (m for help): p

Disk /dev/nvme0n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: SAMSUNG MZVLB512HBJQ-000H1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 00351B84-7E73-412C-ACA7-0F8F13907C20

Device             Start       End   Sectors   Size Type
/dev/nvme0n1p1      2048   1023999   1021952   499M EFI System
/dev/nvme0n1p2   1024000   1286143    262144   128M Microsoft reserved
/dev/nvme0n1p3   1286144 211978239 210692096 100.5G Microsoft basic data
/dev/nvme0n1p4 211980288 221976575   9996288   4.8G Windows recovery environment

Command (m for help):


```

I already have a GPT disklabel, so I just have to create the necessary partitions.

Creating the swap partition:

```
Command (m for help): n
Partition number (5-128, default 5): 5
First sector (221976576-1000215182, default 221976576):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (221976576-1000215182, default 1000214527): +16G

Created a new partition 5 of type 'Linux filesystem' and of size 16 GiB.
```

Label it as swap:

```
Command (m for help): t
Partition number (1-5, default 5): 5
Partition type or alias (type L to list all): L
Partition type or alias (type L to list all): 19

Changed type of partition 'Linux filesystem' to 'Linux swap'.

```

Print the current partitions:

```
Command (m for help): p
Disk /dev/nvme0n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: SAMSUNG MZVLB512HBJQ-000H1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 00351B84-7E73-412C-ACA7-0F8F13907C20

Device             Start       End   Sectors   Size Type
/dev/nvme0n1p1      2048   1023999   1021952   499M EFI System
/dev/nvme0n1p2   1024000   1286143    262144   128M Microsoft reserved
/dev/nvme0n1p3   1286144 211978239 210692096 100.5G Microsoft basic data
/dev/nvme0n1p4 211980288 221976575   9996288   4.8G Windows recovery environment
/dev/nvme0n1p5 221976576 255531007  33554432    16G Linux swap

```

Now we create the root partition:

```
Command (m for help): n
Partition number (6-128, default 6):
First sector (255531008-1000215182, default 255531008):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (255531008-1000215182, default 1000214527):

Created a new partition 6 of type 'Linux filesystem' and of size 355.1 GiB.

Command (m for help): t
Partition number (1-6, default 6):
Partition type or alias (type L to list all): L
Partition type or alias (type L to list all): 23

Changed type of partition 'Linux filesystem' to 'Linux root (x86-64)'.

Command (m for help): p
Disk /dev/nvme0n1: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: SAMSUNG MZVLB512HBJQ-000H1
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 00351B84-7E73-412C-ACA7-0F8F13907C20

Device             Start        End   Sectors   Size Type
/dev/nvme0n1p1      2048    1023999   1021952   499M EFI System
/dev/nvme0n1p2   1024000    1286143    262144   128M Microsoft reserved
/dev/nvme0n1p3   1286144  211978239 210692096 100.5G Microsoft basic data
/dev/nvme0n1p4 211980288  221976575   9996288   4.8G Windows recovery environmen
/dev/nvme0n1p5 221976576  255531007  33554432    16G Linux swap
/dev/nvme0n1p6 255531008 1000214527 744683520 355.1G Linux root (x86-64)
```

Now write the changes to disk:

```
Command (m for help): w

The partition table has been altered.
Syncing disks.

livecd /home/gentoo/install #
```

Make sure to change the Type-UUIDs to conform to DPS (Discoverable Partition Specification)!

## Luks

```
livecd /home/gentoo # cryptsetup -v luksFormat /dev/nvme0n1p6
```

Now test opening it:

```
livecd /home/gentoo # cryptsetup luksOpen /dev/nvme0n1p6 root
Enter passphrase for /dev/nvme0n1p6: 
```

```
livecd /home/gentoo # mkfs.btrfs -L rootfs /dev/mapper/root
```

```
livecd /home/gentoo # lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0         7:0    0   3.6G  1 loop  /run/rootfsbase
sda           8:0    1  57.7G  0 disk  
└─sda1        8:1    1  57.7G  0 part  /run/initramfs/live
nvme0n1     259:0    0 476.9G  0 disk  
├─nvme0n1p1 259:1    0   499M  0 part  
├─nvme0n1p2 259:2    0   128M  0 part  
├─nvme0n1p3 259:3    0 100.5G  0 part  
├─nvme0n1p4 259:4    0   4.8G  0 part  
├─nvme0n1p5 259:5    0    16G  0 part  
└─nvme0n1p6 259:6    0 355.1G  0 part  
  └─root    253:0    0 355.1G  0 crypt 
```

And mounting it:

```
livecd /home/gentoo # mount --label rootfs /mnt/gentoo/
```

```
livecd /home/gentoo # lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0         7:0    0   3.6G  1 loop  /run/rootfsbase
sda           8:0    1  57.7G  0 disk  
└─sda1        8:1    1  57.7G  0 part  /run/initramfs/live
nvme0n1     259:0    0 476.9G  0 disk  
├─nvme0n1p1 259:1    0   499M  0 part  
├─nvme0n1p2 259:2    0   128M  0 part  
├─nvme0n1p3 259:3    0 100.5G  0 part  
├─nvme0n1p4 259:4    0   4.8G  0 part  
├─nvme0n1p5 259:5    0    16G  0 part  
└─nvme0n1p6 259:6    0 355.1G  0 part  
  └─root    253:0    0 355.1G  0 crypt /mnt/gentoo
```


From here, we can follow the normal AMD64 Install guide, noting from https://wiki.gentoo.org/wiki/Rootfs_encryption#Gentoo_installation

> **Important**
> 
>* sys-fs/cryptsetup and sys-fs/btrfs-progs must be installed within the chroot, before the initramfs is created.
>
>   An initial RAM filesystem must be built with support for decrypting and mounting the root partition.
>   If a bootloader is being used, it must be configured and installed on unencrypted volumes.

We will get back to this later when we install dracut and rEFInd.
 
## Applying a filesystem

For the swap partition:

```
livecd /home/gentoo # mkswap /dev/nvme0n1p5
Setting up swapspace version 1, size = 16 GiB (17179865088 bytes)
no label, UUID=31e55f72-4af4-4afa-a565-3eb599d3e6da
livecd /home/gentoo # swapon /dev/nvme0n1p5
```

## Mounting the root partition

```
livecd /home/gentoo # mkdir --parents /mnt/gentoo/
livecd /home/gentoo # mount --label rootfs /mnt/gentoo/
```

Mount the EFI partition too

```
livecd /home/gentoo # mkdir --parents /mnt/gentoo/efi
livecd /home/gentoo # mount /dev/nvme0n1p1 /mnt/gentoo/efi/
```

# Installing a stage file

```
livecd /home/gentoo # cd /mnt/gentoo/
livecd /mnt/gentoo # date
Wed Sep  3 20:27:28 UTC 2025
livecd /mnt/gentoo # chronyd -q
2025-09-03T20:27:35Z chronyd version 4.7 starting (+CMDMON +REFCLOCK +RTC +PRIVDROP +SCFILTER -SIGND +NTS +SECHASH +IPV6 -DEBUG)
2025-09-03T20:27:35Z Wrong owner of /run/chrony (UID != 0)
2025-09-03T20:27:35Z Disabled command socket /run/chrony/chronyd.sock
2025-09-03T20:27:35Z Running with root privileges
2025-09-03T20:27:40Z System clock wrong by 25196.524922 seconds (step)
2025-09-04T03:27:37Z chronyd exiting
```

I downloaded the following stage3 file:

https://distfiles.gentoo.org/releases/amd64/autobuilds/20250831T170358Z/stage3-amd64-desktop-openrc-20250831T170358Z.tar.xz

```
livecd /mnt/gentoo # tar xpvf stage3-amd64-desktop-openrc-20250831T170358Z.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo/
```

## Configuring compile flags

```
livecd /mnt/gentoo # vim /mnt/gentoo/etc/portage/make.conf 
```

Add `-march=native` to `COMMON_FLAGS` and add a `RUST_FLAGS` option. Also add `MAKEOPTS`
```
livecd /mnt/gentoo # cat /mnt/gentoo/etc/portage/make.conf 
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"

MAKEOPTS="-j8 -l9"

# NOTE: This stage was built with the bindist USE flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8
```

## Installing the base system

```
livecd /mnt/gentoo # cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

Chroot into the new location:

```
livecd /mnt/gentoo # arch-chroot /mnt/gentoo/
livecd / # lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0   3.6G  1 loop 
sda           8:0    1  57.7G  0 disk 
└─sda1        8:1    1  57.7G  0 part 
nvme0n1     259:0    0 476.9G  0 disk 
├─nvme0n1p1 259:1    0   499M  0 part /efi
├─nvme0n1p2 259:2    0   128M  0 part 
├─nvme0n1p3 259:3    0 100.5G  0 part 
├─nvme0n1p4 259:4    0   4.8G  0 part 
├─nvme0n1p5 259:5    0    16G  0 part [SWAP]
└─nvme0n1p6 259:6    0 355.1G  0 part /

```

Thus, we see that we are now in your new root partition.

```
livecd / # source /etc/profile
livecd / # export PS1="(chroot) ${PS1}"
(chroot) livecd / # 
```

## Configuring portage

```
(chroot) livecd / # emerge-webrsync 
```

```
(chroot) livecd / # emerge --ask --verbose --oneshot app-portage/mirrorselect
```

```
(chroot) livecd / # mirrorselect -i -o >> /etc/portage/make.conf 
```

I am already using the profile I want, so I won't switch.

Configure a binary package host:

`/etc/portage/binrepos.conf/gentoobinhost.conf`
```
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consider using a local mirror.

[gentoobinhost]
priority = 1
sync-uri = http://gentoo-mirror.flux.utah.edu/releases/amd64/binpackages/23.0/x86-64-v3/
```

I won't be configuring Gentoo to use binary packages by default. But I might install some large packages this way like Firefox.

Run `getuto` to set up the keyrings for verification.

```
getuto
```

```
(chroot) livecd / # emerge --ask --oneshot app-portage/cpuid2cpuflags
```

```
(chroot) livecd / # cpuid2cpuflags
```

```
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags
```

```
(chroot) livecd / # cat /etc/portage/package.use/00cpu-flags 
*/* CPU_FLAGS_X86: aes avx avx2 bmi1 bmi2 f16c fma3 mmx mmxext pclmul popcnt rdrand sha sse sse2 sse3 sse4_1 sse4_2 sse4a ssse3 vpclmulqdq
```

Configure `VIDEO_CARDS`

```
(chroot) livecd / # vim /etc/portage/package.use/00video-cards
```

```
(chroot) livecd / # cat /etc/portage/package.use/00video_cards 
*/* VIDEO_CARDS: amdgpu radeonrsi
```

I will change `ACCEPT_LICENSE` to accept basically any license:

In `/etc/portage/make.conf` add 

```
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE @EULA"
```

We can check that the change worked:

```
(chroot) livecd / # portageq envvar ACCEPT_LICENSE
@FREE @BINARY-REDISTRIBUTABLE @EULA
```

Now I will update the world set:

```
(chroot) livecd / # emerge --ask --verbose --update --deep --changed-use @world
```

Set the timezone

```
(chroot) livecd / # ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime 
```

Generate the locale

```
(chroot) livecd / # vim /etc/locale.gen 
# /etc/locale.gen: list all of the locales you want to have on your system.
# See the locale.gen(5) man page for more details.
#
# The format of each line:
# <locale name> <charset>
#
# Where <locale name> starts with a name as found in /usr/share/i18n/locales/.
# It must be unique in the file as it is used as the key to locale variables.
# For non-default encodings, the <charset> is typically appended.
#
# Where <charset> is a charset located in /usr/share/i18n/charmaps/ (sans any
# suffix like ".gz").
#
# All blank lines and lines starting with # are ignored.
#
# For the default list of supported combinations, see the file:
# /usr/share/i18n/SUPPORTED
#
# Whenever glibc is emerged, the locales listed here will be automatically
# rebuilt for you.  After updating this file, you can simply run `locale-gen`
# yourself instead of re-emerging glibc.

en_US ISO-8859-1
en_US.UTF-8 UTF-8
#ja_JP.EUC-JP EUC-JP
#ja_JP.UTF-8 UTF-8
#ja_JP EUC-JP
#en_HK ISO-8859-1
#en_PH ISO-8859-1
#de_DE ISO-8859-1
#de_DE@euro ISO-8859-15
#es_MX ISO-8859-1
#fa_IR UTF-8
#fr_FR ISO-8859-1
#fr_FR@euro ISO-8859-15
#it_IT ISO-8859-1
```

```
(chroot) livecd / # locale-gen 
 * Generating 3 locales (this might take a while) with 16 jobs
 *  (1/3) Generating en_US.ISO-8859-1 ...                                         [ ok ]
 *  (3/3) Generating C.UTF-8 ...                                                  [ ok ]
 *  (2/3) Generating en_US.UTF-8 ...                                              [ ok ]
 * Generation complete
 * Adding locales to archive ...                                                  [ ok ]
```

Set the locale

```
(chroot) livecd / # eselect locale list
Available targets for the LANG variable:
  [1]   C
  [2]   C.utf8
  [3]   POSIX
  [4]   en_US
  [5]   en_US.iso88591
  [6]   en_US.utf8
  [7]   C.UTF8 *
  [ ]   (free form)
```

```
(chroot) livecd / # eselect locale set 2
Setting LANG to C.utf8 ...
Run ". /etc/profile" to update the variable in your shell.
```

```
(chroot) livecd / # env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
>>> Regenerating /etc/ld.so.cache...
```

## Configuring the Kernel

```
(chroot) livecd / # emerge --ask sys-kernel/linux-firmware
```

I will be using EFI stub booting instead of GRUB

In `/etc/portage/package.accept_keywords/installkernel`
```
sys-kernel/installkernel
sys-boot/uefi-mkconfig
app-emulation/virt-firmware
```

In `/etc/portage/package.use/installkernel`
```
sys-kernel/installkernel efistub
```

```
(chroot) livecd / # emerge --ask sys-kernel/installkernel
```

Add the `dracut` USE flag to `installkernel`.

In `/etc/portage/package.use/installkernel`
```
sys-kernel/installkernel efistub dracut
```

I will not be using a UKI (Unified Kernel Image).

Now before doing this, we go back to the warning from before and install
`sys-fs/cryptsetup` and `sys-fs/btrfs-progs`

```
(chroot) livecd / # emerge -avt sys-fs/cryptsetup sys-fs/btrfs-progs
```

Configure dracut

```
(chroot) livecd / # mkdir /etc/dracut.conf.d
```

```
(chroot) livecd / # vim /etc/dracut.conf.d/luks.conf
```

In `/etc/dracut.conf.d/luks.conf`:

```
add_dracutmodules+=" crypt "
```

Now get the UUID of the luks volume and the root partition
and add them to `/etc/dracut.conf.d/luks.conf`:

```
(chroot) livecd / # lsblk -o name,uuid
NAME        UUID
loop0       
sda         
└─sda1      1D19-2B06
nvme0n1     
├─nvme0n1p1 1661-3176
├─nvme0n1p2 
├─nvme0n1p3 943A61B43A619450
├─nvme0n1p4 F41C62161C61D3E0
├─nvme0n1p5 31e55f72-4af4-4afa-a565-3eb599d3e6da
└─nvme0n1p6 727d6157-6da4-49f1-b501-94c9763747e9
  └─root    7442ba3f-d6f4-4aaf-b2a3-35b9d5167aaa
```

In `/etc/dracut.conf.d/luks.conf`, add

```
kernel_cmdline+=" root=UUID=7442ba3f-d6f4-4aaf-b2a3-35b9d5167aaa rd.luks.uuid=727d6157-6da4-49f1-b501-94c9763747e9 "
```

In total we have

`/etc/dracut.conf.d/luks.conf`

```
add_dracutmodules+=" crypt "
kernel_cmdline+=" root=UUID=7442ba3f-d6f4-4aaf-b2a3-35b9d5167aaa rd.luks.uuid=727d6157-6da4-49f1-b501-94c9763747e9 "
```

Install the distribution kernel

```
emerge --ask sys-kernel/gentoo-kernel
```

Add the global `USE` flag to `/etc/portage/make.conf`:

```
USE="dist-kernel"
```

# Configuring the system 

I forgot to make btrfs subvolumes when I created the filesytem, so I will do it now.


```
(chroot) livecd / # btrfs subvolume create @
Create subvolume './@'
(chroot) livecd / # btrfs subvolume create @home
Create subvolume './@home'
```

```
(chroot) livecd / # btrfs subvolume list /
ID 256 gen 516 top level 5 path @
ID 257 gen 516 top level 5 path @home
```

```
(chroot) livecd / # blkid
/dev/sda1: LABEL="GENTOO-AMD6" UUID="1D19-2B06" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="Main Data Partition" PARTUUID="9efb1ded-5604-48b3-9d4d-6cdd6891fbb3"
/dev/nvme0n1p5: UUID="31e55f72-4af4-4afa-a565-3eb599d3e6da" TYPE="swap" PARTUUID="0657fd6d-a4ab-43c4-84e5-0933c84b4f4f"
/dev/nvme0n1p3: LABEL="Windows" BLOCK_SIZE="512" UUID="943A61B43A619450" TYPE="ntfs" PARTLABEL="Basi" PARTUUID="f6ebb88d-cc6b-4153-941b-efa339816721"
/dev/nvme0n1p1: LABEL="BOOT" UUID="1661-3176" BLOCK_SIZE="512" TYPE="vfat" PARTLABEL="EFI" PARTUUID="56f1a617-2412-4ffc-990e-61419f169127"
/dev/nvme0n1p6: UUID="727d6157-6da4-49f1-b501-94c9763747e9" TYPE="crypto_LUKS" PARTUUID="34015f40-00e6-4450-9b57-490dc5fc8d84"
/dev/nvme0n1p4: LABEL="Recovery" BLOCK_SIZE="512" UUID="F41C62161C61D3E0" TYPE="ntfs" PARTUUID="0a17139e-9f46-4665-a2a1-f47219e5b2a6"
/dev/loop0: BLOCK_SIZE="131072" TYPE="squashfs"
/dev/mapper/root: LABEL="rootfs" UUID="7442ba3f-d6f4-4aaf-b2a3-35b9d5167aaa" UUID_SUB="742f9fd3-15b4-42c8-bce4-1eef7c78e5c4" BLOCK_SIZE="4096" TYPE="btrfs"
/dev/nvme0n1p2: PARTLABEL="Micr" PARTUUID="e1778793-8291-4804-81a1-d83411145c65"
```

```
# /etc/fstab: static file system information.
#
# See the manpage fstab(5) for more information.
#
# NOTE: The root filesystem should have a pass number of either 0 or 1.
#       All other filesystems should have a pass number of 0 or greater than 1.
#
# NOTE: Even though we list ext4 as the type here, it will work with ext2/ext3
#       filesystems.  This just tells the kernel to use the ext4 driver.
#
# NOTE: You can use full paths to devices like /dev/sda3, but it is often
#       more reliable to use filesystem labels or UUIDs. See your filesystem
#       documentation for details on setting a label. To obtain the UUID, use
#       the blkid(8) command.

# <fs> = filesystem identifier (UUID, PARTUUID, path to device file, label)
# <mountpoint> = where to mount
# <type> = type of file system
# <opts> = options to pass to mount
# <dump> = used by dump to check if partition needs to be dumped or not 
#          (typically 0)
# <pass> = used by fsck to determine the order in which filesystems should be 
#          checked if the system wasn't shut down properly. The root 
#          filesystem should have this set to 1 while the rest should have 2 
#          (or 0 if a filesystem check is not necessary).

# <fs>                  <mountpoint>    <type>          <opts>                 <dump> <pass>
UUID=1661-3176          /efi            vfat            umask=0077             0       2
UUID=TODO  /     btrfs  defaults,subvol=/@     0       1
UUID=TODO  /home btrfs  defaults,subvol=/@home 0       2
```

```
(chroot) livecd / # echo hp845 > /etc/hostname
```

```
(chroot) livecd / # rc-update add dhcpcd default
(chroot) livecd / # rc-service dhcpcd start
```

Add an alias in `/etc/hosts`

```
# /etc/hosts: Local Host Database
#
# This file describes a number of aliases-to-address mappings for the for 
# local hosts that share this file.
#
# The format of lines in this file is:
#
# IP_ADDRESS    canonical_hostname      [aliases...]
#
#The fields can be separated by any number of spaces or tabs.
#
# In the presence of the domain name service or NIS, this file may not be 
# consulted at all; see /etc/host.conf for the resolution order.
#

# IPv4 and IPv6 localhost aliases
127.0.0.1       localhost hp845
::1             localhost

#
# Imaginary network.
#10.0.0.2               myname
#10.0.0.3               myfriend
#
# According to RFC 1918, you can use the following IP networks for private 
# nets which will never be connected to the Internet:
#
#       10.0.0.0        -   10.255.255.255
#       172.16.0.0      -   172.31.255.255
#       192.168.0.0     -   192.168.255.255
#
# In case you want to be able to connect directly to the Internet (i.e. not 
# behind a NAT, ADSL router, etc...), you need real official assigned 
# numbers.  Do not try to invent your own network numbers but instead get one 
# from your network provider (if any) or from your regional registry (ARIN, 
# APNIC, LACNIC, RIPE NCC, or AfriNIC.)
#
```


```
(chroot) livecd / # passwd 
```

```
(chroot) livecd / # emerge -avt app-admin/sysklogd
```

```
(chroot) livecd / # rc-update add sysklogd default
 * service sysklogd added to runlevel default
```

```
(chroot) livecd / # emerge --ask sys-process/cronie
```

```
(chroot) livecd / # rc-update add cronie default
 * service cronie added to runlevel default
```

```
emerge --ask sys-apps/mlocate
```

```
rc-update add sshd default
```

```
emerge --ask app-shells/bash-completion
```

```
emerge --ask net-misc/chrony
```

```
rc-update add chronyd default
```

```
emerge --ask sys-block/io-scheduler-udev-rules
```

```
emerge --ask net-wireless/iw net-wireless/wpa_supplicant
```

In `/etc/portage/package.use/refind`:

```
sys-boot/refind btrfs doc
```

then

```
(chroot) livecd / # emerge -avt sys-boot/refind
```

```
emerge --ask --config sys-kernel/gentoo-kernel
```

```
efibootmgr --create --disk /dev/nvme0n1 --label "Gentoo" --loader "vmlinuz-6.12.41-gentoo-dist" --unicode "initrd=initramfs-6.12.41-gentoo-dist"
```

```
(chroot) livecd / # efibootmgr --create --disk /dev/nvme0n1 --label "Gentoo" --loader "vmlinuz-6.12.41-gentoo-dist" --unicode "initrd=initramfs-6.12.41-gentoo-dist"
BootCurrent: 0003
Timeout: 5 seconds
BootOrder: 0000,01FF,0200,0003,0002,0001,0004
Boot0001  USB NETWORK BOOT:     PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x4)/USB(0,0)/USB(0,6)/MAC(0c3796385d61,0)/IPv4(0.0.0.0,0,DHCP,0.0.0.0,0.0.0.0,0.0.0.0)걎脈鼑䵙຅᫢ⱒ뉙⠛
Boot0002* Windows Boot Manager  HD(1,GPT,56f1a617-2412-4ffc-990e-61419f169127,0x800,0xf9800)/\EFI\Microsoft\Boot\bootmgfw.efi䥗䑎坏S
Boot0003* 07002732C2D5E232      PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x3)/USB(5,0)걎脈鼑䵙຅᫢ⱒ뉙᠉
Boot0004  USB NETWORK BOOT:     PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x4)/USB(0,0)/USB(0,6)/MAC(0c3796385d61,0)/IPv6([::],0,Static,[::],[::],64)걎脈鼑䵙຅᫢ⱒ뉙〛
Boot01FF* UMC 1 Gentoo Linux 6.12.41    HD(1,GPT,56f1a617-2412-4ffc-990e-61419f169127,0x800,0xf9800)/\EFI\Gentoo\vmlinuz-6.12.41-gentoo-dist.efi  initrd=\EFI\Gentoo\amd-uc.img initrd=\EFI\Gentoo\initramfs-6.12.41-gentoo-dist.img
Boot0200* UMC 2 Gentoo Linux 6.12.41    HD(1,GPT,56f1a617-2412-4ffc-990e-61419f169127,0x800,0xf9800)/\EFI\Gentoo\vmlinuz-6.12.41-gentoo-dist-old.efi  initrd=\EFI\Gentoo\amd-uc.img initrd=\EFI\Gentoo\initramfs-6.12.41-gentoo-dist.img.old
Boot0000* Gentoo        HD(1,GPT,56f1a617-2412-4ffc-990e-61419f169127,0x800,0xf9800)/vmlinuz-6.12.41-gentoo-distinitrd=initramfs-6.12.41-gentoo-dist
(chroot) livecd / # refind-install
ShimSource is none
Installing rEFInd on Linux....
ESP was found at /efi using vfat
Installing driver for btrfs (btrfs_x64.efi)
Copied rEFInd binary files

Copying sample configuration file as refind.conf; edit this file to configure
rEFInd.

Creating new NVRAM entry
rEFInd is set as the default boot manager.
Creating //boot/refind_linux.conf; edit it to adjust kernel options.

Installation has completed successfully.

```

And now 

```
exit
```

```
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
```

Right after rebooting, I was met with a white screen with the refind logo, so I went into the UEFI and tried 
booting the kernel directly. After entering the password, the kenrel hung, and after waiting, dracut tried
scanning for btrfs devices but couldn't find one. I tried again, this time entering a wrong password, and got
an error for "no luks device with that passphrase" (to paraphrase), which implies that luksOpen works, but maybe
the mapped device name is wrong or my initramfs doesn't have `btrfs` support.

I tried:

```
livecd / # dracut initramfs-6.12.41-gentoo-dist.img 6.12.41-gentoo-dist
```

and then manually move it `/efi/EFI/Gentoo`

then

```
efibootmgr --create --disk /dev/nvme0n1 --label "Gentoo" --loader "vmlinuz-6.12.41-gentoo-dist" --unicode "initrd=initramfs-6.12.41-gentoo-dist"
```

Okay, this got me no where, and after rebooting a few times, I realized that my laptop's UEFI was deleting the EFI
entry. After some reading, I was pretty sure that this is because the UEFI implementation cannot find the
lodaer (the .efi file), so it just deletes the entry. Sure enough, I was putting the path in wrong. Entries are *relatiive*
to the ESP, so I need to prefix both the loeader and initramfs with `\EFI\Gentoo` (note the backslashes). 
[Thanks Arch Wiki](https://wiki.archlinux.org/title/EFI_boot_stub#Booting_an_EFI_boot_stub).

```
efibootmgr --create --disk /dev/nvme0n1 --label "Gentoo Linux" --loader "\EFI\Gentoo\vmlinuz-6.12.41-gentoo-dist" --unicode " initrd=\EFI\Gentoo\initramfs-6.12.41-gentoo-dist"
```

After this, I could see a Gentoo entry in the UEFI, and after disabling all other boot options, I got a boot device not
found error. Oops! I had typed `|` instead of `\` for one of the paths. 

Now, when I booted, I could confirm that the device was found and it was using the initramfs, but it hung for a few minutes before
dracut showed "Scanning for all btrfs devices". I had gotten this error on a failed install before, so I knew that it would
eventually drop me to dracut shell where I could debug this further.

Success! Now we are booted.

Now I need to connect to a network again.

Edit `/etc/wpa_supplicant/wpa_supplicant.conf`

```
ctrl_interface=/run/wpa_supplicant
update_config=1
```

This will allow use to use `wpa_cli` to connect to a network.

```
wpa_supplicant -B -i wlp1s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
> scan
> scan_results
> add_network
> set_network 0 ssid "SSID"
> set_network 0
> enable_network 0
> save_config
> quit
```

Now make sure `wpa_supplicant` is added to startup:

```
rc-update add wpa_supplicant default
```

I want to download brightnessctl, so I will enable GURU:

```
emerge -avt app-eselect/eselect-repository
```

then

```
eselect repository enable guru
```

```
emerge --sync guru
```

```
useradd -m -G users,wheel,audio -s /bin/bash chris
```

```
passwd chris
```

# Getting a GUI

`/etc/portage/package.use/sway`:

```
gui-wm/sway man swaybar swaynag X tray wallpapers
```

```
emerge --avt sway foot swaylock swayidle wmenu
```

```
emerge -avt elogind
```

```
rc-service elogind start
rc-update add elogind boot
```

Logout from root with Ctrl+D and login as your normal user.

```
emerge -avt sudo
```

Add yourself to the sudoers:

```
su
```

```
visudo
```

add `chris  ALL=(ALL:ALL) ALL` to the file and save it.


Now start sway

```
sway
```

The default mod key is Win or Super. You can start a terminal with Win+Enter

Copy the default sway config to `~/.config/sway/config`

In that file, I changed the mod key to Alt.

Mod+Shift+C to reload the config.

Update the whole system:

```
```

## Sound:


## References:

## TODO:

- Update rootfs encryption article to specifcy that entries are relative to ESP.

- Ask about why /usr/share/portage/config/make.conf.example shows options like
  --ask --verbose but not --jobs (maybe expand the article?
   https://wiki.gentoo.org/wiki/EMERGE_DEFAULT_OPTS

- Add nodejs as a bin package. It takes way too long to compile. See https://forums.gentoo.org/viewtopic-p-8848797.html?sid=248e70926183584c7449df514011bf58
 

