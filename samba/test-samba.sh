#!/bin/bash
set -e

# Check DNS resolution is properly configured.
# Samba is used as DNS resolver
dig @localhost +short SRV _ldap._tcp.thecompany.example.com
dig @localhost +short SRV _kerberos._udp.thecompany.example.com
dig @localhost +short A adsamba.thecompany.example.com
# default resolver should work too
dig +short A adsamba.thecompany.example.com

# Check LDAP works
ldapsearch -H ldap://localhost -D "CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com" -w Test1234 -x -LLL -b "DC=thecompany,DC=example,DC=com" "(cn=administrator)" sAMAccountName whenCreated
ldapsearch -H ldap://localhost -D "CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com" -w Test1234 -x -LLL -b "DC=thecompany,DC=example,DC=com" "(cn=Ansible_Linux_Server_UAT)" member

# Check kerberos works
echo Test1234 | kinit Administrator
klist
