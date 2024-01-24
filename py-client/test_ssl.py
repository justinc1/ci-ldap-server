#!/usr/bin/env python

import sys
import ldap


def main():
    ldap_url = "ldaps://localhost:10636"
    bind_dn = "cn=admin,dc=example,dc=com"
    bind_pw = "secret"
    search_base = "dc=example,dc=com"
    filter = "uid=demo"

    ldapmodule_trace_level = 2  # 0 1 2 9
    ldapmodule_trace_file = sys.stdout
    CACERTFILE = "../data/openldap/tls/ca.pem"

    # Create LDAPObject instance
    l = ldap.initialize(ldap_url,trace_level=ldapmodule_trace_level,trace_file=ldapmodule_trace_file)

    # Set LDAP protocol version used
    l.protocol_version=ldap.VERSION3

    # Force cert validation
    #l.set_option(ldap.OPT_X_TLS_REQUIRE_CERT, ldap.OPT_X_TLS_DEMAND)  #
    # Set path name of file containing all trusted CA certificates
    l.set_option(ldap.OPT_X_TLS_CACERTFILE, CACERTFILE)
    # Force libldap to create a new SSL context (must be last TLS option!)
    l.set_option(ldap.OPT_X_TLS_NEWCTX, 0)

    # Try an explicit anon bind to provoke failure
    l.simple_bind_s(bind_dn, bind_pw)

    print('***ldap.OPT_X_TLS_VERSION', l.get_option(ldap.OPT_X_TLS_VERSION))
    print('***ldap.OPT_X_TLS_CIPHER', l.get_option(ldap.OPT_X_TLS_CIPHER))

    # Close connection
    l.unbind_s()


if __name__ == "__main__":
    main()
