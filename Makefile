RULESFILES=bad-words barrass common-typos foolish-phrases latex-checking misspellings my-rules  \
	networking-research passive-voice verbose-phrases 
PACKAGE=style-check
VERSION=0.6
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

$(distdir).tar.gz: distdir 
	tar cvfz $(distdir).tar.gz $(distdir)
	$(am__remove_distdir)

dist: $(distdir).tar.gz

README: README.html
	cat $< | w3m -dump -T text/html > $@

check:
	./style-check.rb -r rules test-clean.tex

upload: $(distdir).tar.gz
	scp README.html ringding.cs.umd.edu:public_html/software/style-check-readme.html
	scp $(distdir).tar.gz ringding.cs.umd.edu:public_html/software/
	ssh ringding.cs.umd.edu "cd public_html/software && rm -f style-check-current.tar.gz && ln -s  $(distdir).tar.gz style-check-current.tar.gz"
