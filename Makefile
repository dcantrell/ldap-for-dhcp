PKG   = ldap-for-dhcp
VER   = 4.1.1
REL   = 2

URL   = ftp://ftp.isc.org/isc/dhcp/dhcp-4.1.1.tar.gz
SHA1  = b23a28d481a84248f8170b4c6c1166a86c04b2a6

FILES = LICENSE.ldap dhcp-$(VER)-ldap.patch dhcpd-conf-to-ldap \
        README.ldap dhcp.schema draft-ietf-dhc-ldap-schema-01.txt

CWD     = $(shell pwd)
ARCHIVE = $(shell basename $(URL))
SUBDIR  = $(shell basename $(ARCHIVE) .tar.gz)
WGET    = wget -t 5 --progress=bar

all: $(FILES)
	-rm -rf $(PKG)-$(VER)-$(REL)
	mkdir -p $(PKG)-$(VER)-$(REL)
	cp -p $(FILES) $(PKG)-$(VER)-$(REL)
	tar -cvf - $(PKG)-$(VER)-$(REL) | gzip -9c > $(PKG)-$(VER)-$(REL).tar.gz

fetch:
	@if [ -f $(ARCHIVE) ]; then \
		sum="$$(sha1sum $(ARCHIVE) | cut -d ' ' -f 1)" ; \
		if [ ! "$(SHA1)" = "$${sum}" ]; then \
			rm -f $(ARCHIVE) ; \
			$(WGET) $(URL) ; \
		fi ; \
	else \
		$(WGET) $(URL) ; \
	fi ; \
	sum="$$(sha1sum $(ARCHIVE) | cut -d ' ' -f 1)" ; \
	if [ ! "$(SHA1)" = "$${sum}" ]; then \
		echo "*** SHA-1 digest mismatch for $(ARCHIVE)" >&2 ; \
		exit 1 ; \
	fi

prep: fetch
	@gzip -dc $(ARCHIVE) | tar -xvf - ; \
	cd $(SUBDIR) ; \
	patch -p 1 -b -z .ldap < $(CWD)/dhcp-$(VER)-ldap.patch

LICENSE.ldap: LICENSE.in
	sed -e "s|%VERSION%|$(VER)|g" < $< > $@

tag: all
	@if [ -z "$(GPGKEY)" ]; then \
		echo "GPGKEY environment variable missing, please set this to the key ID" ; \
		echo "you want to use to tag the repository." ; \
		exit 1 ; \
	fi
	@git tag -u $(GPGKEY) -m "Tag as $(PKG)-$(VER)-$(REL)" -f $(PKG)-$(VER)-$(REL)
	@echo "Tagged as $(PKG)-$(VER)-$(REL) (GPG signed)"

release: tag
	@echo
	@echo "$(PKG)-$(VER)-$(REL).tar.gz is now ready to upload."
	@echo "Do not forget to push changes to the repository with:"
	@echo "    git push"
	@echo "    git push --tags"
	@echo

clean:
	-rm -rf $(PKG)-$(VER)-$(REL).tar.gz
	-rm -rf $(PKG)-$(VER)-$(REL)
	-rm -rf $(ARCHIVE) $(SUBDIR)
	-rm -rf LICENSE.ldap
