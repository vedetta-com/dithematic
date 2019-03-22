# dithematic (alpha)

OpenBSD DNS name server

![Dithematic Logo](src/usr/local/share/doc/dithematic/dithematic-256x256.png)

## About
> autoritative nameserver for domain names

Dithematic configuration and guide for self-hosting [DNS](https://powerdns.org/dns-camel/)

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

Install DNS zone(s), e.g. on master: `example.com` and `ddns.example.com`
```console
env ROLE=master DDNS=false zoneadd example.com
env ROLE=master DDNS=true zoneadd ddns.example.com
```

n.b.: place [zone templates](https://github.com/vedetta-com/dithematic/tree/master/src/usr/local/share/examples/dithematic) in `/var/nsd/zones/master` (or start with a blank slate.)

n.b.: place existing TSIG key as `tsig.example.com`, CSK (or ZSK) as `example.com.CSK` in `/etc/ssl/dns/private` (or let `zoneadd` generate new keys.)

Add a [DDNS](https://tools.ietf.org/html/rfc2136) user, e.g.: `puffy`
```console
user add -L authpf -G authdns -c "DDNS user" -s /sbin/nologin -m puffy
```

Setup the [TSIG](https://tools.ietf.org/html/rfc2845) user on all nameservers, i.e.: `tsig`
```console
su - tsig
ssh-keygen -t ed25519 -C tsig@example.com
exit
ssh -i /home/tsig/.ssh/id_ed25519 -l tsig $IP \
	"cat - >> /home/tsig/.ssh/authorized_keys" \
	< /home/tsig/.ssh/id_ed25519.pub
rcctl restart sshd
```

Share master TSIG secret with nameservers, e.g.: `dig.example.com`
```console
env NS="dig.example.com" tsig-share tsig.example.com
```

Enjoy:
```console
rcctl enable nsd pdns_server
rcctl restart nsd pdns_server
```

## Support
[Issues](https://github.com/vedetta-com/dithematic/issues)

## Contribute
Contributions welcome, [fork](https://github.com/vedetta-com/dithematic/fork)

