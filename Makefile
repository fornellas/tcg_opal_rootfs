PREFIX ?=
PREFIX_INITRAMFS_TOOLS ?= /usr/share

.PHONY: all
all:

.PHONY: install
install:

.PHONY: uninstall
uninstall:

##
## sedutil
##

.PHONY: sedutil/sedutil-cli
sedutil/sedutil-cli:
	cd sedutil/ && \
		autoreconf || true && \
		automake --add-missing && \
		autoreconf && \
		./configure && \
		$(MAKE) $(MAKEFLAGS)
all: sedutil/sedutil-cli

.PHONY: install-sedutil
install-sedutil:
	install -m 755 sedutil/sedutil-cli $(PREFIX)/sbin/sedutil-cli.badicsalex
install: install-sedutil

.PHONY: uninstall-sedutil
uninstall-sedutil:
	rm -f $(PREFIX)/sbin/sedutil-cli.badicsalex
uninstall: uninstall-sedutil

.PHONY: clean-sedutil
clean-sedutil:
	cd sedutil/ && \
		git clean -xdf
clean: clean-sedutil

.PHONY: clean
clean:

##
## initramfs-tools
##

.PHONY: install-initramfs-tools
install-initramfs-tools:
	install -m 755 initramfs-tools/hooks/tcg_opal $(PREFIX_INITRAMFS_TOOLS)/initramfs-tools/hooks/tcg_opal
	install -m 755 initramfs-tools/scripts/init-premount/tcg_opal $(PREFIX_INITRAMFS_TOOLS)/initramfs-tools/scripts/init-premount/tcg_opal
install: install-initramfs-tools

.PHONY: uninstall-initramfs-tools
uninstall-initramfs-tools:
	rm -f \
		$(PREFIX_INITRAMFS_TOOLS)/initramfs-tools/hooks/tcg_opal \
		$(PREFIX_INITRAMFS_TOOLS)/initramfs-tools/scripts/init-premount/tcg_opal
uninstall: uninstall-initramfs-tools