# TCG OPAL Root Filesystem

Support for using [self-encrypting drives (SED)](https://en.wikipedia.org/wiki/Hardware-based_full_disk_encryption) which follow [TCG OPAL specification ](https://trustedcomputinggroup.org/resource/storage-work-group-storage-security-subsystem-class-opal/) to encrypt the root filesystem of Debian / Ubuntu Linux systems.

Why SED instead of `cryptsetup`?

- No performance penalty, as encryption is handled by the drive.
- No CPU usage on I/O, translating to battery savings.
- No CPU performance bottleneck (if your drive is faster than your CPU encryption speed).

Why `cryptsetup` instead of SED?

- Simpler setup.
- Not vulnerable to any potential drive firmware security issues.

Why this instead of [OPAL MBR Shadow with linuxpba](https://github.com/Drive-Trust-Alliance/sedutil/wiki/Encrypting-your-drive)?

- No need for "double boot" the machine (one to enter the password, another for the real OS boot).
- Faster boots.
- Arguably easier setup.
- linuxpba image does not receive any (security) updates.

Why use linuxpba instead of this?

- Works for any operating system, including dual boot.

## Cookbook

This example setup was successfully tested with Linux Mint 20.3 (Ubuntu Focal 20.04 LTS) though it should work at other Debian / Ubuntu variants.

**Make sure to have backups of your data before attempting any of this.**

## Boot the installation media

From the live OS, we'll prepare the drive for encryption and partition it, so installation can go on top.

## Compile `sedutil`

You will require `sedutil-cli` for the setup.

```shell
sudo apt install git automake make build-essential g++
git clone https://github.com/fornellas/tcg_opal_rootfs
cd tcg_opal_rootfs/
git submodule init
git submodule update
make
```

The binary will be available at `tcg_opal_rootfs/sedutil/sedutil-cli`.

## Prepare the drive

Prepare the drive. This **WILL ERASE EVERYTHING IN IT**:

```shell
sedutil-cli --yesIreallywanttoERASEALLmydatausingthePSID $PSID $DEVICE
sedutil-cli --initialsetup $PASS $DEVICE
sedutil-cli --setMBREnable off $PASS $DEVICE
```

## Partition

Partition using GPT (eg: with GParted):

- 1: 100M, FAT32, EFI
- 2: 512M, ext4, /boot
- 3: Rest of the disk, ext4, /

Use `fdisk -l $DEVICE` to get for partition 3:

- RANGE_START=Start
- RANGE_LENGTH=Sectors

## Setup locking range for root filesystem

Setup a locking range **only** for the `/` filesystem:

```shell
sedutil-cli --setupLockingRange 1 $RANGE_START $RANGE_LENGTH $PASS $DEVICE
sedutil-cli --enablelockingrange 1 $PASS $DEVICE
```

## Install OS

Proceed with OS installation as usual. Make sure to tell it to use the created partitions.

**IMPORTANT:** Do **NOT** poweroff the system after installation is finished. If you do so, the drive will be locked and you won't be able to boot! Simply reboot the system for first boot without powering it off.

## First boot: Setup `initramfs-tools`

This step install `sedutil` & setup `initramfs-tools` to ask for the password for the drive if it is locked on boot (eg: after a cold boot). The drive will be unlocked to enable the boot to proceed, and the kernel will be instructed to keep the password in memory to enable the system to wake up from S3 sleep (as the drive will be locked).

```shell
sudo apt install git automake make build-essential g++
git clone https://github.com/fornellas/tcg_opal_rootfs
cd tcg_opal_rootfs/
git submodule init
git submodule update
make
sudo make install
```

Note: sedutil will be installed to `/sbin/sedutil-cli.badicsalex` deliberately, so it is clear this is a fork from the original!

## Voilà

At this point, your system should be fully functional:

- Every time the drive looses power, the root filesystem will be locked.
- As EFI and `/boot` are NOT locked, the system can still boot.
- On boot, initrd will ask for password to unlock the drive if it is locked.

## Operational Commands

Change password:

```shell
sedutil-cli --setSIDPassword $OLD_PASS $PASS $DEVICE
sedutil-cli --setAdmin1Pwd $OLD_PASS $PASS $DEVICE $DEVICE
```

Restore drive to factory state (**ERASE ALL**)

This will **DELETE ALL DATA**. It requires the PSID which should be found printed at the drive:

```shell
sedutil-cli --yesIreallywanttoERASEALLmydatausingthePSID $PSID $DEVICE
````

Unlock drive manually (eg: from a recovery system):

```shell
sedutil-cli --setlockingrange 1 rw $PASS $DEVICE
```

## Improvements

- Set EFI & `/boot` partitions to read only as well and have initrd set it to RW (for some extra security).
- Integrate with Plymouth to ask for password.
  - This was attempted with `/lib/cryptsetup/askpass`, but it seems plymouth is not fully functional during `init-premount/` (no frame buffer yet?), so not sure if possible.

## Dependencies

- sedutil: for setting up drives. [Upstream](https://github.com/Drive-Trust-Alliance/sedutil) is still pending merging [S3 sleep support](https://github.com/Drive-Trust-Alliance/sedutil/pull/190), so we require [badicsalex's s3-sleep-support branch](https://github.com/badicsalex/sedutil/tree/s3-sleep-support).
- [initramfs-tools](https://salsa.debian.org/kernel-team/initramfs-tools): to ask user for the password to unlock the drive.

## Caveats

- There's technically a race condition with initramfs-tools. `init-premount/` is run immediately after all modules (including block device) are loaded. This means, that OPAL drive unlock should be the first thing to run, to prevent other scripts that depend on block devices to fail, eg, lvm2. With current initramfs-tools, which only accepts prereqs, the only possible fix to this would be to patch **all** scripts (eg: lvm2) so they depend on the drive unlock script (impractical). An alternative would for another step prior to `init-premount/` to run drive unlocks.
  - As a side-effect of this race condition, some I/O errors may happen. In the worst case, for example, these errors come from lvm as it `vgscan`, which may break other steps, breaking the boot.

## References

-	[A Practical Guide to Use of Opal Drives](https://develop.trustedcomputinggroup.org/2019/05/28/a-practical-guide-to-use-of-opal-drives/).