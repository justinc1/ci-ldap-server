FROM debian:latest

# RUN /bin/bash -c 'echo "search thecompany.example.com" > /etc/resolv.conf'
# RUN /bin/bash -c 'echo "nameserver 172.17.0.2" >> /etc/resolv.conf'
# RUN /bin/bash -c 'echo "nameserver 8.8.8.8" >> /etc/resolv.conf'
# RUN /bin/bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'
# RUN /bin/bash -c 'echo "option edns0" >> /etc/resolv.conf'

# RUN /bin/bash -c 'echo -e "172.17.0.2\tadsamba.thecompany.example.com" >> /etc/hosts'
# RUN /bin/bash -c 'echo -e "172.17.0.2\tadsamba" >> /etc/hosts'

RUN /bin/bash -c 'apt-get update'
RUN /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends iputils-ping iproute2 dnsutils ldap-utils net-tools nano patch'
RUN /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends acl attr samba samba-dsdb-modules samba-vfs-modules winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils ntp samba-ad-provision'

RUN /bin/bash -c 'rm -f /etc/krb5.conf /etc/samba/smb.conf'
# RUN /bin/bash -c 'samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=THECOMPANY.EXAMPLE.COM --domain=THECOMPANY --adminpass=Test1234'
# RUN /bin/bash -c 'cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf'
# RUN /bin/bash -c 'sed -i "s/dns forw.*/dns forwarder = 8\.8\.8\.8/g" /etc/samba/smb.conf'

EXPOSE 88:88
EXPOSE 88:88/udp
EXPOSE 135:135
EXPOSE 137:137/udp
EXPOSE 138:138/udp
EXPOSE 139:139
EXPOSE 389:389
EXPOSE 389:389/udp
EXPOSE 445:445
EXPOSE 464:464
EXPOSE 464:464/udp
EXPOSE 636:636
EXPOSE 1024-1044:1024-1044
EXPOSE 3268-3269:3268-3269

COPY ./ /scripts/samba
ENTRYPOINT ["/scripts/samba/setup-samba.sh"]

# config files are replaced when container is running
#COPY --chown=root:root res/hosts /etc/hosts
#COPY --chown=root:root res/resolv.conf /etc/resolv.conf
#COPY --chown=root:root res/krb5.conf /etc/resolv.conf
#COPY --chown=root:root res/smb.conf /etc/samba/smb.conf
