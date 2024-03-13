#!/bin/bash
# Add NN users to openldap
set -u
set -v

NN=$1

for ii in $(seq 0 $NN)
do
  echo "
dn: cn=uu$ii,ou=users,dc=example,dc=com
sn: uu$ii
objectClass: inetOrgPerson
" | ldapadd -H ldap://$SRVIP:10389 -D cn=admin,dc=example,dc=com -w secret
done
