#!/bin/bash
set -eu

echo LDAP_DATA_LDIF=$LDAP_DATA_LDIF

#apt-get update
#export DEBIAN_FRONTEND=noninteractive
#apt-get install -y iputils-ping iproute2 dnsutils ldap-utils net-tools nano  # bind9-utils
#apt-get install -y -q acl attr samba samba-dsdb-modules samba-vfs-modules winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils ntp

# samba-tool in container fails at setntacl(). But we do not need those for LDAP.
if [ ! -f /usr/lib/python3/dist-packages/samba/ntacls.py.original ]
then
    cp /usr/lib/python3/dist-packages/samba/ntacls.py /usr/lib/python3/dist-packages/samba/ntacls.py.original
    patch -u /usr/lib/python3/dist-packages/samba/ntacls.py < /scripts/samba/files/samba-ntacls.patch
fi
rm -f /etc/krb5.conf /etc/samba/smb.conf
samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=THECOMPANY.EXAMPLE.COM --domain=THECOMPANY --adminpass=Test1234
cp /scripts/samba/files/smb.conf /etc/samba/smb.conf
cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf

# import data after short delay
(
    for ii in $(seq 1 30)
    do
        sleep 1
        echo "Trying to test with ldapsearch ii=$ii"
        set +e
        ldapsearch -H ldap://localhost -D 'CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com' -w Test1234 -b 'dc=thecompany,dc=example,dc=com' '(&(objectClass=group)(name=spotter-*))' member
        rc=$?
        set -e
        echo "Trying to test with ldapsearch ii=$ii rc=$rc"
        if [[ $rc == 0 ]]
        then
            break
        fi
    done
    sleep 5
    echo "================================"
    ldapadd -H ldap://localhost -D "CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com" -w Test1234 -x -f "$LDAP_DATA_LDIF"
    echo "================================"
    ldapsearch -H ldap://localhost -D 'CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com' -w Test1234 -b 'dc=thecompany,dc=example,dc=com' '(&(objectClass=group)(name=spotter-*))' member
    echo "================================"
)&
exec samba -i
