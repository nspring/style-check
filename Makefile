PACKAGE=style-check
VERSION=0.1
SYSCONFDIR=/etc/$(PACKAGE).d
PREFIX=/usr/local
bindir=$(PREFIX)/bin
INSTALL=install

all:

user-install:
	mkdir -p $(HOME)/.style-check.d
	for p in rules/*; do \
		$(INSTALL) -m0644 $$p $(HOME)/.style-check.d; \
	done

install:
	mkdir -p $(DESTDIR)$(SYSCONFDIR)
	for p in rules/*; do \
		$(INSTALL) -m0644 $$p $(DESTDIR)$(SYSCONFDIR); \
	done
	mkdir -p $(DESTDIR)$(PREFIX)
	$(INSTALL) -m0755 $$p $(DESTDIR)$(bindir);

distdir = $(PACKAGE)-$(VERSION)
am__remove_distdir = \
  { test ! -d $(distdir) \
    || { find $(distdir) -type d ! -perm -200 -exec chmod u+w {} ';' \
         && rm -fr $(distdir); }; }                                                            
distdir: 
	$(am__remove_distdir)
	mkdir $(distdir)
	mkdir $(distdir)/rules
	cp rules/* $(distdir)/rules
	cp style-check.rb README test-*.tex $(distdir)

dist: distdir
	tar cvfz $(distdir).tar.gz $(distdir)
	$(am__remove_distdir)

README: README.html
	cat $< | w3m -dump -T text/html > $@
