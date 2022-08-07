# TCG OPAL Root Filesystem

Support for using [self-encrypting drives (SED)](https://en.wikipedia.org/wiki/Hardware-based_full_disk_encryption) which follow [TCG OPAL specification ](https://trustedcomputinggroup.org/resource/storage-work-group-storage-security-subsystem-class-opal/) to encrypt the root filesystem of Linux systems.

## Dependencies

- sedutil: for setting up drives. [Upstream](https://github.com/Drive-Trust-Alliance/sedutil) is still pending merging [S3 sleep support](https://github.com/Drive-Trust-Alliance/sedutil/pull/190), so we require [badicsalex's s3-sleep-support branch](https://github.com/badicsalex/sedutil/tree/s3-sleep-support).
- [initramfs-tools](https://salsa.debian.org/kernel-team/initramfs-tools): to ask user for the password to unlock the drive.
	- cryptsetup: we reuse its [askpass](https://salsa.debian.org/cryptsetup-team/cryptsetup/-/blob/debian/latest/debian/askpass.c) binary.

## References

-	[A Practical Guide to Use of Opal Drives](https://develop.trustedcomputinggroup.org/2019/05/28/a-practical-guide-to-use-of-opal-drives/).