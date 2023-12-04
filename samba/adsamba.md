# Samba Active Directory Domain Controller Notes

Notes how to setup samba as AD controller in VM.
Ignore it, except if you need to update Dockerfile for samba container.

## Preinstallation steps

Check `samba` is not already running
```
ps ax | egrep "samba|smbd|nmbd|winbindd"
```
otherwise `pkill samba`.
Set hostname to `samba`.
Insert
```
<your-ip>   samba.<domain>  samba
```
and remove the line with `127.0.1.1`.

### Update

This is now handled automatically by the `docker run` command.
Just change the ip in the script to your `docker0` interface ip,
in my case `172.17.0.2`.

## Installing Samba

Install `samba` by
```
apt-get install acl attr samba samba-dsdb-modules samba-vfs-modules winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils ntp
```
Remove all existing `.conf`, `.tdb` and `.ldb` files in folders returned by
```
smbd -b | egrep "CONFIGFILE|LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR"
```
and old `kerberos` config file
```
rm /etc/krb5.conf
```
Also for testing install the client, ip tools and a text editor
```
apt-get install smbclient iproute2 vim
```

## Provisioning a Samba AD

### Interactive

For interactive provisioning run
```
samba-tool domain provision --use-rfc2307 --interactive
```
and jump through the default options, except set the fallback resolver to
something static like `8.8.8.8`.

### Non-interactive (for scripts)

Run
```
samba-tool domain provision \
    --server-role=dc \
    --use-rfc2307 \
    --dns-backend=SAMBA_INTERNAL \
    --realm=THECOMPANY.EXAMPLE.COM \
    --domain=THECOMPANY \
    --adminpass=Test1234
```
and then in `/etc/samba/smb.conf` change the fallback resolver
to something static, like `8.8.8.8`, so in `[global]` change
```
dns forwarder = 172.17.0.2
```
to
```
dns forwarder = 8.8.8.8
```

### Update

On my work machine the container needs to be run with `--privileged` for this
to work.

## Post-installation configuration

## Configuring Kerberos

Copy the `kerberos` configuration `samba` generated
```
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
```

## Starting samba

Simply run
```
samba -D & disown
```


## Testing and verifying

### Verify the file server

Verify the file server with
```
smbclient -L localhost -N
```
This should return
```
Anonymous login successful

    Sharename       Type      Comment
    ---------       ----      -------
    sysvol          Disk
    netlogon        Disk
    IPC$            IPC       IPC Service (Samba 4.12.6-Debian)
SMB1 disabled -- no workgroup available
```

Verify authentication, connect to `netlogon` with
```
smbclient //localhost/netlogon -UAdministrator -c 'ls'
```
This should return
```
Enter Administrator's password:
Domain=[thecompany] OS=[Unix] Server=[Samba x.y.z]
 .                                   D        0  Tue Nov  1 08:40:00 2016
 ..                                  D        0  Tue Nov  1 08:40:00 2016

               49386 blocks of size 524288. 42093 blocks available
```
Both of these work for me. The next commands however don't.

### Verify DNS

Run the following commands, below is the expected result
```
$ host -t SRV _ldap._tcp.thecompany.example.com.
_ldap._tcp.thecompany.example.com has SRV record 0 100 389 adsamba.thecompany.example.com.
```
Next
```
$ host -t SRV _kerberos._udp.thecompany.example.com.
_kerberos._udp.thecompany.example.com has SRV record 0 100 88 adsamba.thecompany.example.com.
```
and
```
$ host -t A adsamba.thecompany.example.com.
adsamba.thecompany.example.com has address 172.17.0.2
```

I think the problems arise because I am not publishing docker container ports +
my custom dns configuration.

### Verifying Kerberos

The command to verify `kerberos`
```
$ kinit administrator
```
throws
```
kinit: Cannot find KDC for realm while getting initial credentials
```
Probably another dns + ports problem.
Also try just
```
kinit
```

### Update

This works now with the new script.

## Adding users and groups

To list users and groups on a domain, respectively run
```
wbinfo -u THECOMPANY
wbinfo -g THECOMPANY
```
Users and groups are added, deleted and modified respectively by
```
samba-tool user
samba-tool group
```
subcommands, use `--help` on both.


## Sources

* https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller
* https://wiki.samba.org/index.php/Distribution-specific_Package_Installation#Debian
* https://www.youtube.com/watch?v=EsKgCGUlBog (part 1)
* https://www.youtube.com/watch?v=dS5PxJk2gyg (part 2)
* https://github.com/Fmstrat/samba-domain
* https://wiki.samba.org/index.php/Samba_AD_DC_Port_Usage
* https://wiki.samba.org/index.php/Linux_and_Unix_DNS_Configuration
* https://wiki.samba.org/index.php/User_and_Group_management
