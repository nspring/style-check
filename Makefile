RULESFILES=bad-words barrass common-typos foolish-phrases latex-checking misspellings my-rules  \
	networking-research passive-voice verbose-phrases day-gastel
PACKAGE=style-check
VERSION=0.14
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
	mkdir -p $(DESTDIR)$(bindir)
	$(INSTALL) -m0755 style-check.rb $(DESTDIR)$(bindir);

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
	cp Makefile COPYING style-check.rb README README.html $(distdir)
	mkdir $(distdir)/test
	cp test/*.tex $(distdir)/test

$(distdir).tar.gz: distdir 
	tar cvfz $(distdir).tar.gz $(distdir)
	$(am__remove_distdir)

dist: $(distdir).tar.gz

README: README.html
	cat $< | w3m -dump -T text/html > $@

check:
	@echo Should succeed
	./style-check.rb -r rules test/clean.tex 
	@echo Should report nothing
	!(./style-check.rb -r rules test/clean.tex | grep clean)
	@echo Should report something
	./style-check.rb -r rules test/dirty.tex | grep dirty > /dev/null
	@echo Checks for space after line before column.
	./style-check.rb -g -r rules test/dirty.tex  | grep "1: 32" > /dev/null
	@echo Checks for html output
	./style-check.rb -w -r rules test/dirty.tex  | grep html > /dev/null
	./style-check.rb -r rules test/math.tex  
	./style-check.rb test/math.tex  
	./style-check.rb --help > /dev/null

upload: $(distdir).tar.gz
	scp README.html ringding.cs.umd.edu:public_html/software/style-check-readme.html
	scp $(distdir).tar.gz ringding.cs.umd.edu:public_html/software/
	ssh ringding.cs.umd.edu "cd public_html/software && rm -f style-check-current.tar.gz && ln -s  $(distdir).tar.gz style-check-current.tar.gz"
