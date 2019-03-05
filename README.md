# dithematic (alpha)

OpenBSD DNS name server

![Dithematic Logo](src/usr/local/share/doc/dithematic/dithematic-256x256.png)

## About
> autoritative nameserver for domain names

Dithematic configuration and guide for self-hosting DNS

## Features

[PowerDNS](https://doc.powerdns.com/authoritative/) features on [OpenBSD](https://github.com/openbsd/src/tree/master/usr.sbin/nsd)'s [NSD](https://man.openbsd.org/nsd.conf) shoulders

## Getting started

*Minimum requirements*: 512MB RAM, [10GB SSD](src/usr/local/share/doc/dithematic/disklabel)

Install packages:
```console
pkg_add powerdns ldns-utils drill
```

Grab a copy of this repository, and put overrides in "[Makefile](Makefile).local":
```console
make install
```

Add a [DDNS](https://tools.ietf.org/html/rfc2136) user, e.g.:
```console
user add -L authpf -G authdns -c "DDNS user" -s /sbin/nologin -m puffy
```

Setup the [TSIG](https://tools.ietf.org/html/rfc2845) user on all nameservers:
```console
su - tsig
ssh-keygen -t ed25519 -C tsig@example.com
exit
ssh -i /home/tsig/.ssh/id_ed25519 -l tsig $IP \
	"umask 077; cat - >> /home/tsig/.ssh/authorized_keys" \
	< /home/tsig/.ssh/id_ed25519.pub
```

Run the TSIG Wizard, e.g.:
```console
tsig-secret tsig.example.com && tsig-change tsig.example.com && tsig-share tsig.example.com
tsig-secret tsig.ddns.example.com && tsig-change tsig.ddns.example.com
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

