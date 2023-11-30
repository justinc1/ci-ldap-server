Commands:

```
docker compose up -d
docker compose exec auth sh

ldapwhoami -H ldap://auth:389 -vvv -D cn=admin,dc=example,dc=com -w secret -x
ldapsearch -H ldap://auth:389/ -D cn=admin,dc=example,dc=com -w secret -b dc=example,dc=com "uid=demo"
# include operational attributes
ldapsearch -H ldap://auth:389/ -D cn=admin,dc=example,dc=com -w secret -b dc=example,dc=com "uid=demo" +
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