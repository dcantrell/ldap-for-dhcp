VER   = 4.1.0

FILES = LICENSE dhcp-$(VERSION)-ldap.patch dhcpd-conf-to-ldap \
        README.ldap dhcp.schema draft-ietf-dhc-ldap-schema-01.txt

all: $(FILES)
	-rm -rf ldap-for-dhcp-$(VER)
	mkdir -p ldap-for-dhcp-$(VER)
	cp -p $(FILES) ldap-for-dhcp-$(VER)
	tar -cvf - ldap-for-dhcp-$(VER) | gzip -9c > ldap-for-dhcp-$(VER).tar.gz

LICENSE: LICENSE.in
	sed -e "s|%VERSION%|$(VER)|g" < $< > $@

clean:
	-rm -rf ldap-for-dhcp-$(VER).tar.gz
	-rm -rf LICENSE
