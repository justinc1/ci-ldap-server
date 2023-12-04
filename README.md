Commands:

```
docker compose up -d

docker compose exec auth sh
# in auth continer
ldapwhoami -H ldap://auth:389 -vvv -D cn=admin,dc=example,dc=com -w secret -x
ldapsearch -H ldap://auth:389/ -D cn=admin,dc=example,dc=com -w secret -b dc=example,dc=com "uid=demo"
# include operational attributes
ldapsearch -H ldap://auth:389/ -D cn=admin,dc=example,dc=com -w secret -b dc=example,dc=com "uid=demo" +

# on docker host
ldapsearch -H ldap://localhost:10389 -D cn=admin,dc=example,dc=com -w secret -b dc=example,dc=com "uid=demo"
ldapsearch -H ldap://localhost:11389 -D 'CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com' -w Test1234 -b 'dc=thecompany,dc=example,dc=com'
ldapsearch -H ldap://localhost:12389 -D 'CN=Administrator,CN=Users,DC=thecompany,DC=example,DC=com' -w Test1234 -b 'dc=thecompany,dc=example,dc=com' '(&(objectClass=group)(name=spotter-*))' member
```

Web UI at http://127.0.0.1:8001 :
- user cn=admin,dc=example,dc=com
- pass secret

Initial db-a-data.ldif was created by following https://github.com/mlan/docker-openldap/blob/master/README.md.
Summary:
```shell

git clone ...
cd docker-openldap/demo
docker compose up -d
make init
# make test

# DB 0 is config, DB 1 is data
docker compose exec auth slapcat -n 1 > db-a-data.ldif
```