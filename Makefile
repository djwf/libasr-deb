ifeq ($(DESTDIR),)
	destdir=$(HOME)
else
	destdir=$(DESTDIR)
endif

ifeq ($(LIBASR),)
	libasr=$(HOME)/usr/src/libasr
else
	libasr=$(LIBASR)
endif

ifeq ($(PACKAGES),)
	packages=$(HOME)/usr/debian-packages
else
	packages=$(PACKAGES)
endif

prefix=$(destdir)/usr/local
exec_prefix=$(prefix)
bindir=$(exec_prefix)/bin
sysconfdir=$(prefix)/etc
sysconfsubdir=$(sysconfdir)/libasr-deb

CHMOD=chmod
INSTALL=install
RM=rm
RMDIR=rmdir

all:

install: install-bin

install-bin: create-libasr-deb.sh
	$(INSTALL) -d $(bindir)
	$(INSTALL) $< $(bindir)
	sed -e 's!%%packages%%!$(packages)!' $(bindir)/$< >$(bindir)/$<.new
	sed -e 's!%%libasr%%!$(libasr)!' $(bindir)/$<.new >$(bindir)/$<
	sed -e 's!%%sysconfdir%%!$(sysconfdir)!' $(bindir)/$< >$(bindir)/$<.new
	sed -e 's!%%OFFICIAL%%!$(official)!' $(bindir)/$<.new >$(bindir)/$<
	$(INSTALL) -d $(sysconfsubdir)/usr/share/doc/libasr
	$(INSTALL) -m 644 usr/share/doc/libasr/* \
		$(sysconfsubdir)/usr/share/doc/libasr
	$(RM) $(bindir)/$<.new
	$(CHMOD) 755 $(bindir)/$<

uninstall: uninstall-bin

uninstall-bin: create-libasr-deb.sh
	$(RM) -f $(bindir)/$<
	-$(RMDIR) -p --ignore-fail-on-non-empty $(bindir)
	$(RM) -fr $(sysconfdir)/libasr-deb

.PHONY: all install uninstall
