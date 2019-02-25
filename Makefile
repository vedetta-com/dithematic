#	$OpenBSD$

# Put overrides in "Makefile.local"

PREFIX ?=	/usr/local
GH_PROJECT ?=	dithematic
#MAN =		man/${SCRIPT}.8
MANDIR ?=	${PREFIX}/man/man
BINDIR ?=	${PREFIX}/bin
BASESYSCONFDIR ?=	/etc
VARBASE ?=	/var
DOCDIR ?=	${PREFIX}/share/doc/${GH_PROJECT}
EXAMPLES_DIR ?=	${PREFIX}/share/examples/${GH_PROJECT}

# Server

EGRESS =	vio0

MASTER =	yes
DOMAIN_NAME =	example.com
DDNS =		ddns

MASTER_HOST =	dot
MASTER_IPv4 =	203.0.113.3
MASTER_IPv6 =	2001:0db8::3

SLAVE_HOST =	dig
SLAVE_IPv4 =	203.0.113.4
SLAVE_IPv6 =	2001:0db8::4

UPGRADE =	yes

DITHEMATIC =	${SCRIPT} ${SYSCONF} ${PFCONF} ${AUTHPF} ${MAILCONF} \
		${PDNSCONF} ${SSHCONF} ${MTREECONF} ${NSDCONF} ${UNBOUNDCONF} \
		${CRONALLOW} ${CRONTAB}

# Dithematic

SCRIPT =	${BINDIR:S|^/||}/pdns-backup \
		${BINDIR:S|^/||}/rmchangelist \
		${BINDIR:S|^/||}/tsig-change \
		${BINDIR:S|^/||}/tsig-fetch \
		${BINDIR:S|^/||}/tsig-secret \
		${BINDIR:S|^/||}/tsig-share

SYSCONF =	${BASESYSCONFDIR:S|^/||}/changelist.local \
		${BASESYSCONFDIR:S|^/||}/daily.local \
		${BASESYSCONFDIR:S|^/||}/dhclient.conf \
		${BASESYSCONFDIR:S|^/||}/doas.conf \
		${BASESYSCONFDIR:S|^/||}/motd.authpf \
		${BASESYSCONFDIR:S|^/||}/resolv.conf \
		${BASESYSCONFDIR:S|^/||}/sysctl.conf \
		${BASESYSCONFDIR:S|^/||}/weekly.local

PFCONF =	${BASESYSCONFDIR:S|^/||}/pf.conf \
		${BASESYSCONFDIR:S|^/||}/pf.conf.anchor.block \
		${BASESYSCONFDIR:S|^/||}/pf.conf.anchor.icmp \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.ban \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.dns \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.martians \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.msa

AUTHPF =	${BASESYSCONFDIR:S|^/||}/authpf/authpf.allow \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.conf \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.message \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.problem \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.rules

MAILCONF =	${BASESYSCONFDIR:S|^/||}/mail/smtpd.conf

PDNSCONF =	${BASESYSCONFDIR:S|^/||}/pdns/pdns.conf
KEYDIR =	${BASESYSCONFDIR:S|^/||}/ssl/dns

SSHCONF =	${BASESYSCONFDIR:S|^/||}/ssh/sshd_banner \
		${BASESYSCONFDIR:S|^/||}/ssh/sshd_config

MTREECONF =	${BASESYSCONFDIR:S|^/||}/mtree/special.local

NSDCONF =	${VARBASE:S|^/||}/nsd/etc/nsd.conf \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.master.PowerDNS \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.master.${DOMAIN_NAME} \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.1984.is \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.FreeDNS.afraid.org \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.GratisDNS.com \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.HE.net \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.PowerDNS \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.Puck.nether.net \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.slave.${DOMAIN_NAME} \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.zone.${DDNS}.${DOMAIN_NAME} \
		${VARBASE:S|^/||}/nsd/etc/nsd.conf.zone.${DOMAIN_NAME} \
		${VARBASE:S|^/||}/nsd/zones/master/${DDNS}.${DOMAIN_NAME}.zone \
		${VARBASE:S|^/||}/nsd/zones/master/${DOMAIN_NAME}.zone

UNBOUNDCONF =	${VARBASE:S|^/||}/unbound/etc/unbound.conf

CRONALLOW =	${VARBASE:S|^/||}/cron/cron.allow
CRONTAB =	${VARBASE:S|^/||}/cron/tabs/root

HOSTNAME !!=	hostname
WRKSRC ?=	${HOSTNAME:S|^|${.CURDIR}/|}

#-8<-----------	[ cut here ] --------------------------------------------------^

.if exists(Makefile.local)
. include "Makefile.local"
.endif

# Specifications (target rules)

.if defined(UPGRADE) && ${UPGRADE} == "yes"
upgrade: config .WAIT ${DITHEMATIC}
	@echo Upgrade
.else
upgrade: config
	@echo Fresh install
.endif

config:
	mkdir -m750 ${WRKSRC}
	(umask 077; cp -R ${.CURDIR}/src/* ${WRKSRC})
	find ${WRKSRC} -type f -exec sed -i \
		-e 's|vio0|${EGRESS}|g' \
		-e 's|example.com|${DOMAIN_NAME}|g' \
		-e 's|ddns|${DDNS}|g' \
		-e 's|dot|${MASTER_HOST}|g' \
		-e 's|203.0.113.3|${MASTER_IPv4}|g' \
		-e 's|2001:0db8::3|${MASTER_IPv6}|g' \
		-e 's|dig|${SLAVE_HOST}|g' \
		-e 's|203.0.113.4|${SLAVE_IPv4}|g' \
		-e 's|2001:0db8::4|${SLAVE_IPv6}|g' \
		{} +
.if ${MASTER} == "no"
	sed -i \
		-e 's|^master=yes|\#master=yes|' \
		-e 's|^\#slave=yes|slave=yes|' \
		${WRKSRC}/${PDNSCONF}
	sed -i \
		-e 's|${SLAVE_HOST}|${MASTER_HOST}|g' \
		${WRKSRC}/${SCRIPT:M*tsig-share}
	sed -i \
		-e 's|${MASTER_IPv4}|${SLAVE_IPv4}|g' \
		-e 's|${MASTER_IPv6}|${SLAVE_IPv6}|g' \
		${WRKSRC}/${NSDCONF:M*nsd.conf}
	sed -i \
		-e '/slave\.PowerDNS/s|^\#||' \
		-e '/master\.${DOMAIN_NAME}/s|^\#||' \
		-e '/master\.PowerDNS/s|^|\#|' \
		-e '/slave\.${DOMAIN_NAME}/s|^|\#|' \
		${WRKSRC}${VARBASE}/nsd/etc/nsd.conf.zone.example.com \
		${WRKSRC}${VARBASE}/nsd/etc/nsd.conf.zone.ddns.example.com
	@echo Super-Slave
.else
	@echo Super-Master
.endif
.for _NSDCONF in ${NSDCONF}
. if "${_NSDCONF:S|${DDNS}|ddns|:S|${DOMAIN_NAME}|example.com|}" \
  != "${_NSDCONF}"
	cp -p ${_NSDCONF:S|${DOMAIN_NAME}|example.com|:S|${DDNS}|ddns|:S|^|${WRKSRC}/|} \
	      ${_NSDCONF:S|^|${WRKSRC}/|}
. endif
.endfor
	@echo Configured

${DITHEMATIC}:
	(umask 077; [[ -r ${DESTDIR}/$@ ]] \
	&& (diff -u ${DESTDIR}/$@ ${WRKSRC}/$@ >/dev/null \
	   || sdiff -as -w $$(tput -T $${TERM:-vt100} cols) \
		-o ${WRKSRC}/$@.merged \
		${DESTDIR}/$@ \
		${WRKSRC}/$@) \
	|| [[ "$$?" -eq 1 ]])

clean:
	@rm -r ${WRKSRC}

beforeinstall: upgrade
.if ${UPGRADE} == "yes"
. for _DITHEMATIC in ${DITHEMATIC}
	(umask 077; [[ -r ${_DITHEMATIC:S|^|${WRKSRC}/|:S|$|.merged|} ]] \
		&& cp -p ${WRKSRC}/${_DITHEMATIC}.merged ${WRKSRC}/${_DITHEMATIC} \
		|| [[ "$$?" -eq 1 ]])
. endfor
.endif

realinstall:
.for _DITHEMATIC in ${DITHEMATIC:N*cron/tabs*}
	${INSTALL} -S -b -o ${DOCOWN} -g ${DOCGRP} -m ${DOCMODE} \
		${_DITHEMATIC:S|^|${WRKSRC}/|} \
		${_DITHEMATIC:S|^|${DESTDIR}/|}
.endfor
	mkdir -pm700 ${DESTDIR}${KEYDIR}

afterinstall:
	mtree -qef ${WRKSRC}${BASESYSCONFDIR}/mtree/special.local -p / -U
.if !empty(CRONTAB)
	crontab -u root ${WRKSRC}/${CRONTAB}
.endif
.if !empty(AUTHPF)
	group info -e ddns || group add -g 20053 ddns
.endif
	user info -e tsig \
	|| { user add -u 25353 -g =uid -c "TSIG Wizard" -s /bin/ksh -md /home/tsig tsig; \
		mkdir -m700 /home/tsig/.key; chown tsig:tsig /home/tsig/.key; }
	${INSTALL} -d -m ${DIRMODE} ${DOCDIR}
	${INSTALL} -S -b -o ${DOCOWN} -g ${DOCGRP} -m ${DOCMODE} \
		${WRKSRC}${DOCDIR}/validate.tsig ${DOCDIR}

.PHONY: upgrade
.USE: upgrade

.include <bsd.prog.mk>

