PKG   = ldap-for-dhcp
VER   = 4.1.0
REL   = 3

FILES = LICENSE dhcp-$(VER)-ldap.patch dhcpd-conf-to-ldap \
        README.ldap dhcp.schema draft-ietf-dhc-ldap-schema-01.txt

all: $(FILES)
	-rm -rf $(PKG)-$(VER)-$(REL)
	mkdir -p $(PKG)-$(VER)-$(REL)
	cp -p $(FILES) $(PKG)-$(VER)-$(REL)
	tar -cvf - $(PKG)-$(VER)-$(REL) | gzip -9c > $(PKG)-$(VER)-$(REL).tar.gz

LICENSE: LICENSE.in
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

push:
	git push fedorapeople master
	git fetch
	git rebase origin

clean:
	-rm -rf $(PKG)-$(VER)-$(REL).tar.gz
	-rm -rf $(PKG)-$(VER)-$(REL)
	-rm -rf LICENSE
