PREFIX ?=

.PHONY: all
all:

.PHONY: install
install:

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
install-sedutil: sedutil/sedutil-cli
	install -m 755 sedutil/sedutil-cli $(PREFIX)/sbin/sedutil-cli.badicsalex
install: install-sedutil

.PHONY: clean-sedutil
clean-sedutil:
	cd sedutil/ && \
		git clean -xdf
clean: clean-sedutil

.PHONY: clean
clean: