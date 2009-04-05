PKG   = ldap-for-dhcp
VER   = 4.1.0
REL   = 1

FILES = LICENSE dhcp-$(VER)-ldap.patch dhcpd-conf-to-ldap \
        README.ldap dhcp.schema draft-ietf-dhc-ldap-schema-01.txt

all: $(FILES)
	-rm -rf ldap-for-dhcp-$(VER)
	mkdir -p ldap-for-dhcp-$(VER)
	cp -p $(FILES) ldap-for-dhcp-$(VER)
	tar -cvf - ldap-for-dhcp-$(VER) | gzip -9c > ldap-for-dhcp-$(VER).tar.gz

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
	rm -rf $(PKG)-$(VER)
	gzip -dc $(PKG)-$(VER).tar.gz | tar -xvf -
	( cd $(PKG)-$(VER) && ./configure && make ) || exit 1
	@echo
	@echo "$(PKG)-$(VER).tar.gz is now ready to upload."
	@echo "Do not forget to push changes to the repository with:"
	@echo "    git push"
	@echo "    git push --tags"
	@echo

push:
	git push --mirror fedorapeople

clean:
	-rm -rf ldap-for-dhcp-$(VER).tar.gz
	-rm -rf ldap-for-dhcp-$(VER)
	-rm -rf LICENSE
