RULESFILES=bad-words  common-typos  misspellings  my-rules  \
	networking-research  verbose-phrases
PACKAGE=style-check
VERSION=0.3
SYSCONFDIR=/etc/$(PACKAGE).d
PREFIX=/usr/local
bindir=$(PREFIX)/bin
INSTALL=install

all:

user-install:
	mkdir -p $(HOME)/.style-check.d
	for p in $(RULESFILES); do \
		$(INSTALL) -m0644 rules/$$p $(HOME)/.style-check.d; \
	done

install:
	mkdir -p $(DESTDIR)$(SYSCONFDIR)
	for p in $(RULESFILES); do \
		$(INSTALL) -m0644 rules/$$p $(DESTDIR)$(SYSCONFDIR); \
	done
	mkdir -p $(DESTDIR)$(PREFIX)
	$(INSTALL) -m0755 $$p $(DESTDIR)$(bindir);

distdir = $(PACKAGE)-$(VERSION)
am__remove_distdir = \
  { test ! -d $(distdir) \
    || { find $(distdir) -type d ! -perm -200 -exec chmod u+w {} ';' \
         && rm -fr $(distdir); }; }                                                            
distdir: README Makefile
	$(am__remove_distdir)
	mkdir $(distdir)
	mkdir $(distdir)/rules
	for f in $(RULESFILES); do \
		cp rules/$$f $(distdir)/rules; \
	done
	cp Makefile COPYING style-check.rb README README.html test-*.tex $(distdir)

dist: distdir
	tar cvfz $(distdir).tar.gz $(distdir)
	$(am__remove_distdir)

README: README.html
	cat $< | w3m -dump -T text/html > $@

check:
	./style-check.rb -r rules test-clean.tex
