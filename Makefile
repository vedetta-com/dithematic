#	$OpenBSD$

# Put overrides in "Makefile.local"

GH_PROJECT ?=	dithematic
PREFIX ?=	/usr/local
MANDIR ?=	${PREFIX}/man/man
BINDIR ?=	${PREFIX}/bin
BASESYSCONFDIR ?=	/etc
VARBASE ?=	/var
DOCDIR ?=	${PREFIX}/share/doc/${GH_PROJECT}
EXAMPLESDIR ?=	${PREFIX}/share/examples/${GH_PROJECT}

# Server

EGRESS =	vio0

DOMAIN_NAME =	example.com

MASTER =	yes
MASTER_HOST =	dot

IPv4 =		203.0.113.3
IPv6 =		2001:0db8::3

UPGRADE =	yes

DITHEMATIC =	${SCRIPT} ${SYSCONF} ${PFCONF} ${AUTHPFCONF} ${MAILCONF} \
		${PDNSCONF} ${SSHCONF} ${MTREECONF} ${NSDCONF} ${UNBOUNDCONF} \
		${CRONALLOW} ${CRONTAB} ${DOC} ${EXAMPLES}

# Dithematic

SCRIPT =	${BINDIR:S|^/||}/pdns-backup \
		${BINDIR:S|^/||}/rmchangelist \
		${BINDIR:S|^/||}/nsec3salt \
		${BINDIR:S|^/||}/tsig-change \
		${BINDIR:S|^/||}/tsig-fetch \
		${BINDIR:S|^/||}/tsig-secret \
		${BINDIR:S|^/||}/tsig-share \
		${BINDIR:S|^/||}/zoneadd \
		${BINDIR:S|^/||}/zonedel

SYSCONF =	${BASESYSCONFDIR:S|^/||}/changelist.local \
		${BASESYSCONFDIR:S|^/||}/daily.local \
		${BASESYSCONFDIR:S|^/||}/dhclient.conf \
		${BASESYSCONFDIR:S|^/||}/doas.conf \
		${BASESYSCONFDIR:S|^/||}/motd.authpf \
		${BASESYSCONFDIR:S|^/||}/resolv.conf \
		${BASESYSCONFDIR:S|^/||}/sysctl.conf

PFCONF =	${BASESYSCONFDIR:S|^/||}/pf.conf \
		${BASESYSCONFDIR:S|^/||}/pf.conf.anchor.block \
		${BASESYSCONFDIR:S|^/||}/pf.conf.anchor.icmp \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.ban \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.dns \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.martians \
		${BASESYSCONFDIR:S|^/||}/pf.conf.table.msa

AUTHPFCONF =	${BASESYSCONFDIR:S|^/||}/authpf/authpf.allow \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.conf \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.message \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.problem \
		${BASESYSCONFDIR:S|^/||}/authpf/authpf.rules

MAILCONF =	${BASESYSCONFDIR:S|^/||}/mail/smtpd.conf

PDNSCONF =	${BASESYSCONFDIR:S|^/||}/pdns/pdns.conf

SSHCONF =	${BASESYSCONFDIR:S|^/||}/ssh/sshd_banner \
		${BASESYSCONFDIR:S|^/||}/ssh/sshd_config

MTREECONF =	${BASESYSCONFDIR:S|^/||}/mtree/special.local

NSDCONF =	${VARBASE:S|^/||}/nsd/etc/nsd.conf

UNBOUNDCONF =	${VARBASE:S|^/||}/unbound/etc/unbound.conf

CRONALLOW =	${VARBASE:S|^/||}/cron/cron.allow
CRONTAB =	${VARBASE:S|^/||}/cron/tabs/root

DOC =		${DOCDIR:S|^/||}/validate.tsig \
		${DOCDIR:S|^/||}/nsd.conf.master.PowerDNS \
		${DOCDIR:S|^/||}/nsd.conf.slave.PowerDNS \
		${DOCDIR:S|^/||}/nsd.conf.slave.1984.is \
		${DOCDIR:S|^/||}/nsd.conf.slave.FreeDNS.afraid.org \
		${DOCDIR:S|^/||}/nsd.conf.slave.GratisDNS.com \
		${DOCDIR:S|^/||}/nsd.conf.slave.HE.net \
		${DOCDIR:S|^/||}/nsd.conf.slave.Puck.nether.net

EXAMPLES =	${EXAMPLESDIR:S|^/||}/ddns.example.com.zone \
		${EXAMPLESDIR:S|^/||}/example.com.zone \
		${EXAMPLESDIR:S|^/||}/nsd.conf.master.example.com \
		${EXAMPLESDIR:S|^/||}/nsd.conf.slave.example.com \
		${EXAMPLESDIR:S|^/||}/nsd.conf.zone.example.com

PKG =		powerdns \
		ldns-utils \
		drill

HOSTNAME !!=	hostname -s
WRKSRC ?=	${HOSTNAME:S|^|${.CURDIR}/|}
RELEASE !!=	uname -r

#-8<-----------	[ cut here ] --------------------------------------------------^

.if exists(Makefile.local)
. include "Makefile.local"
.endif

.if ${MASTER} == "yes"
SYSCONF +=	${BASESYSCONFDIR:S|^/||}/weekly.local
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
	sed -i \
		's|vio0|${EGRESS}|' \
		${WRKSRC}/${PFCONF:M*pf.conf}
	sed -i \
		's|example.com|${DOMAIN_NAME}|' \
		${SYSCONF:M*doas.conf:S|^|${WRKSRC}/|} \
		${PFCONF:M*pf.conf.table.dns:S|^|${WRKSRC}/|} \
		${AUTHPFCONF:M*authpf.problem:S|^|${WRKSRC}/|} \
		${MAILCONF:M*smtpd.conf:S|^|${WRKSRC}/|} \
		${PDNSCONF:M*pdns.conf:S|^|${WRKSRC}/|} \
		${SSHCONF:M*sshd_config:S|^|${WRKSRC}/|} \
		${MTREECONF:M*special.local:S|^|${WRKSRC}/|} \
		${NSDCONF:M*nsd.conf:S|^|${WRKSRC}/|} \
		${DOC:M*nsd.conf.*.PowerDNS:S|^|${WRKSRC}/|}
	sed -i \
		's|dot|${MASTER_HOST}|' \
		${PDNSCONF:M*pdns.conf:S|^|${WRKSRC}/|}
	sed -i \
		-e 's|203.0.113.3|${IPv4}|' \
		-e 's|2001:0db8::3|${IPv6}|' \
		${NSDCONF:M*nsd.conf:S|^|${WRKSRC}/|}
	sed -i \
		's|dot|${HOSTNAME}|' \
		${MAILCONF:M*smtpd.conf:S|^|${WRKSRC}/|} \
		${MTREECONF:M*special.local:S|^|${WRKSRC}/|}
.if ${MASTER} == "yes"
	sed -i \
		's|example.com|${DOMAIN_NAME}|' \
		${SYSCONF:M*weekly.local:S|^|${WRKSRC}/|}
	@echo Super-Master
.else
	sed -i \
		-e 's|^master=yes|#master=yes|' \
		-e 's|^#slave=yes|slave=yes|' \
		${PDNSCONF:M*pdns.conf:S|^|${WRKSRC}/|}
	@echo Super-Slave
.endif
	@echo Configured

${DITHEMATIC}:
	[[ -r ${DESTDIR}/$@ ]] \
	&& (umask 077; diff -u ${DESTDIR}/$@ ${WRKSRC}/$@ >/dev/null \
		|| sdiff -as -w $$(tput -T $${TERM:-vt100} cols) \
			-o ${WRKSRC}/$@.merged \
			${DESTDIR}/$@ \
			${WRKSRC}/$@) \
	|| [[ "$$?" -eq 1 ]]

clean:
	@rm -r ${WRKSRC}

beforeinstall: upgrade
	rcctl stop nsd pdns_server || [[ "$$?" -eq 1 ]]
.for _PKG in ${PKG}
	env PKG_PATH= pkg_info ${_PKG} > /dev/null || pkg_add ${_PKG}
.endfor
.if ${UPGRADE} == "yes"
. for _DITHEMATIC in ${DITHEMATIC}
	[[ -r ${_DITHEMATIC:S|^|${WRKSRC}/|:S|$|.merged|} ]] \
	&& cp -p ${WRKSRC}/${_DITHEMATIC}.merged ${WRKSRC}/${_DITHEMATIC} \
	|| [[ "$$?" -eq 1 ]]
. endfor
.endif

realinstall:
	${INSTALL} -d -m ${DIRMODE} ${DOCDIR}
	${INSTALL} -d -m ${DIRMODE} ${EXAMPLESDIR}
.for _DITHEMATIC in ${DITHEMATIC:N*cron/tabs*}
	${INSTALL} -S -o ${LOCALEOWN} -g ${LOCALEGRP} -m 440 \
		${_DITHEMATIC:S|^|${WRKSRC}/|} \
		${_DITHEMATIC:S|^|${DESTDIR}/|}
.endfor
	${INSTALL} -d -m 750 -o _powerdns ${VARBASE}/pdns

afterinstall:
.if !empty(CRONTAB)
	crontab -u root ${WRKSRC}/${CRONTAB}
.endif
.if !empty(AUTHPFCONF)
	group info -e authdns || group add -g 20053 authdns
.endif
	[[ -r ${VARBASE}/nsd/etc/nsd_control.pem ]] || nsd-control-setup
	[[ -r ${VARBASE}/pdns/pdns.sqlite ]] \
		|| sqlite3 ${VARBASE}/pdns/pdns.sqlite \
			-init ${PREFIX}/share/doc/pdns/schema.sqlite3.sql ".exit"
	[[ -r ${VARBASE}/pdns/pdnssec.sqlite ]] \
		|| sqlite3 ${VARBASE}/pdns/pdnssec.sqlite \
			-init ${PREFIX}/share/doc/pdns/dnssec-3.x_to_3.4.0_schema.sqlite3.sql ".exit"
	group info -e tsig || user info -e tsig \
		|| { user add -u 25353 -g =uid -c "TSIG Wizard" -s /bin/ksh -m tsig; \
			mkdir -m700 /home/tsig/.key; chown tsig:tsig /home/tsig/.key; }
	[[ -r ${BASESYSCONFDIR}/changelist-${RELEASE} ]] \
		|| cp ${BASESYSCONFDIR}/changelist ${BASESYSCONFDIR}/changelist-${RELEASE}
	sed -i '/changelist.local/,$$d' ${BASESYSCONFDIR}/changelist
	cat ${BASESYSCONFDIR}/changelist.local >> ${BASESYSCONFDIR}/changelist
	sed -i '/^console/s/ secure//' ${BASESYSCONFDIR}/ttys
	mtree -qef ${BASESYSCONFDIR}/mtree/special -p / -U
	mtree -qef ${BASESYSCONFDIR}/mtree/special.local -p / -U
	[[ -r ${BASESYSCONFDIR}/ssl/dns/private/tsig.${DOMAIN_NAME} ]] \
		|| ${PREFIX}/bin/tsig-secret tsig.${DOMAIN_NAME}
	[[ -r ${VARBASE}/nsd/etc/tsig.${DOMAIN_NAME} ]] \
		|| ${PREFIX}/bin/tsig-change tsig.${DOMAIN_NAME}
	pfctl -f /etc/pf.conf
	rcctl disable check_quotas sndiod
	rcctl enable unbound nsd pdns_server
	rcctl restart unbound nsd pdns_server
	rcctl reload sshd

.PHONY: upgrade
.USE: upgrade

.include <bsd.prog.mk>
