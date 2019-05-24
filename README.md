# dithematic (alpha)

OpenBSD DNS name server

![Dithematic Logo](src/usr/local/share/doc/dithematic/dithematic-256x256.png)

## About
> autoritative nameserver for domain names

Dithematic configuration and guide for self-hosting [DNS](https://powerdns.org/dns-camel/)

## Features

[PowerDNS](https://doc.powerdns.com/authoritative/) features on [OpenBSD](https://github.com/openbsd/src/tree/master/usr.sbin/nsd)'s [NSD](https://man.openbsd.org/nsd.conf) shoulders

## Getting started

*Minimum requirements*
- 512MB RAM, [10GB SSD](src/usr/local/share/doc/dithematic/disklabel)
- reverse DNS (record type PTR) for each nameserver IP configured on hosting provider, with the primary DOMAIN_NAME

Grab a copy of this repository, and put overrides in "[Makefile](Makefile).local" e.g.
```console
# Makefile.local

EGRESS =	vio0

DOMAIN_NAME =	example.com

MASTER =	yes
MASTER_HOST =	dot

IPv4 =		203.0.113.3
IPv6 =		2001:0db8::3

UPGRADE =	yes
```

*n.b.* UPGRADE uses [`sdiff`](https://man.openbsd.org/sdiff) side-by-side diff (with *new* on the right side)

Test
```sh
make beforeinstall
```

Install
```sh
make install
```

Edit [`zoneadd`](src/usr/local/bin/zoneadd) to match (or use `env`)
```console
# Dithematic IP
MASTER_IP="${MASTER_IP:-\
 203.0.113.3 \
 2001:0db8::3 \
 }"
SLAVE_IP="${SLAVE_IP:-\
 203.0.113.4 \
 2001:0db8::4 \
 }" # empty to disable

# Vendor
FREE_SLAVE="${FREE_SLAVE:-\
 1984.is \
 FreeDNS.afraid.org \
 GratisDNS.com \
 HE.net \
 Puck.nether.net \
 }" # empty to disable
```

*n.b.* rename and place [zone templates](https://github.com/vedetta-com/dithematic/tree/master/src/usr/local/share/examples/dithematic) in `/var/nsd/zones/master` (or start with a blank slate.)

Install DNS zone(s), e.g. on master: `example.com` and `ddns.example.com`
```sh
zoneadd example.com
env DDNS=true zoneadd ddns.example.com
```

Edit a zone
```sh
env EDITOR="${EDITOR:-vi}" pdnsutil edit-zone example.com
```

*n.b.* place existing TSIG key as `tsig.example.com`, CSK (or ZSK) as `example.com.CSK` in `/etc/ssl/dns/private` (or let [`zoneadd`](src/usr/local/bin/zoneadd) generate new keys.)

Setup the [TSIG](https://tools.ietf.org/html/rfc2845) user on all dithematic nameservers, i.e. `tsig`
```sh
su - tsig
ssh-keygen -t ed25519 -C tsig@example.com
exit
```

Share TSIG user's public key with all dithematic slave nameservers, and update "known_hosts"
```sh
ssh -4 -i /home/tsig/.ssh/id_ed25519 -l tsig dig.example.com "exit"
ssh -6 -i /home/tsig/.ssh/id_ed25519 -l tsig dig.example.com "exit"
```

Edit [`tsig-share`](src/usr/local/bin/tsig-share) on master to add slave nameserver names
```console
NS="${NS:-dig.example.com}" # (space-separated) domain name(s), or IP(s)
```

Share master TSIG secret with slave nameservers, e.g.: `dig.example.com`
```sh
env NS="dig.example.com" tsig-share tsig.example.com
```

[DNS UPDATE](https://tools.ietf.org/html/rfc2136) allowed IPs are managed with authpf(8) i.e. user "puffy" first needs to SSH login on the master name server host to authenticate the IP from which they will next update ddns.example.com zone using e.g. nsupdate (`pkg_add isc-bind`) or dnspython (`pkg_add py-dnspython`) on their device (skip if not using dynamic DNS)
```sh
user add -L authpf -G authdns -c "DDNS user" -s /sbin/nologin -m puffy
```

Edit ["smtpd.conf"](src/etc/mail/smtpd.conf) and "secrets"

Edit pf table ["msa"](src/etc/pf.conf.table.msa) to add Message Submission Agent IP(s)

Enjoy
```sh
dig example.com any
```

## Support
[Issues](https://github.com/vedetta-com/dithematic/issues)

## Contribute
Contributions welcome, [fork](https://github.com/vedetta-com/dithematic/fork)

