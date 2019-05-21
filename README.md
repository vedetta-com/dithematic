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

Grab a copy of this repository, and put overrides in "[Makefile](Makefile).local":
```console
make install
```

*n.b.* rename and place [zone templates](https://github.com/vedetta-com/dithematic/tree/master/src/usr/local/share/examples/dithematic) in `/var/nsd/zones/master` (or start with a blank slate.)

Install DNS zone(s), e.g. on master: `example.com` and `ddns.example.com`
```console
env ROLE=master DDNS=false zoneadd example.com
env ROLE=master DDNS=true zoneadd ddns.example.com
```

*n.b.* place existing TSIG key as `tsig.example.com`, CSK (or ZSK) as `example.com.CSK` in `/etc/ssl/dns/private` (or let [`zoneadd`](src/usr/local/bin/zoneadd) generate new keys.)

Setup the [TSIG](https://tools.ietf.org/html/rfc2845) user on all dithematic nameservers, i.e. `tsig`
```console
su - tsig
ssh-keygen -t ed25519 -C tsig@example.com
exit
```

Share TSIG user's public key with all dithematic slave nameservers, and update "known_hosts"
```console
ssh -4 -i /home/tsig/.ssh/id_ed25519 -l tsig dig.example.com "exit"
ssh -4 -i /home/tsig/.ssh/id_ed25519 -l tsig dig.example.com "exit"
```

Share master TSIG secret with nameservers, e.g.: `dig.example.com`
```console
env NS="dig.example.com" tsig-share tsig.example.com
```

[DNS UPDATE](https://tools.ietf.org/html/rfc2136) allowed IPs are managed with authpf(8) i.e. user "puffy" first needs to SSH login on the master name server host to authenticate the IP from which they will next update ddns.example.com zone using e.g. nsupdate (pkg_add ics-bind) or dnspython (pkg_add py-dnspython) on their device (skip if not using dynamic DNS)
```console
user add -L authpf -G authdns -c "DDNS user" -s /sbin/nologin -m puffy
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

