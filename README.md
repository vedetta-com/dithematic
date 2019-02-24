# dithematic (alpha)

OpenBSD DNS name server

![Dithematic Logo](src/usr/local/share/doc/dithematic/dithematic-256x256.png)

## About
> autoritative nameserver for domain names

Dithematic configuration and guide for self-hosting DNS

## Features

[PowerDNS](https://www.powerdns.com/) features on [OpenBSD](https://github.com/openbsd/src/tree/master/usr.sbin/nsd)'s [NSD](https://man.openbsd.org/nsd.conf) shoulders

## Getting started

Minimum requirements: 512MB RAM, [10GB SSD](src/usr/local/share/doc/dithematic/disklabel)

Install packages:
```console
pkg_add powerdns ldns-utils drill
```

Grab a copy of this repository, and put overrides in "[Makefile](Makefile).local":
```console
make install
```

Install DNS SQL:
```console
sqlite3
.read /usr/local/share/doc/pdns/schema.sqlite3.sql
.save /var/pdns/pdns.sqlite
.exit
```

Install DNSSEC SQL:
```console
sqlite3
.read /usr/local/share/doc/pdns/dnssec-3.x_to_3.4.0_schema.sqlite3.sql
.save /var/pdns/pdnssec.sqlite
.exit
```

Setup NSD:
```console
nsd-control-setup
```

Add a [DDNS](https://tools.ietf.org/html/rfc2136) user:
```console
user add -L authpf -G ddns -c "DDNS user" -s /sbin/nologin -md /home/john john
```

Setup the [TSIG](https://tools.ietf.org/html/rfc2845) user on all nameservers:
```console
su - tsig
ssh-keygen -t ed25519 -C tsig@example.com
exit
cat /home/tsig/.ssh/id_ed25519.pub \
| ssh -i /home/tsig/.ssh/id_ed25519 -l tsig $IP "cat >> /home/tsig/.ssh/authorized_keys"
```

Install TSIG
```console
tsig-secret && tsig-change && tsig-share
```

Install DNS zone(s):
```console
# WiP
```

Enjoy:
```console
rcctl enable nsd unbound pdns_server
rcctl restart nsd unbound pdns_server
```

## Support
[Issues](https://github.com/vedetta-com/dithematic/issues)

## Contribute
Contributions welcome, [fork](https://github.com/vedetta-com/dithematic/fork)

