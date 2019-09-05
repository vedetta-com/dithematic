#!/bin/sh
# Add a zone: env DDNS=false zoneadd name

set -o errexit
set -o nounset

# Bail out if non-privileged UID
[ 0 -eq "$(id -u)" ] || exit 1

GH_PROJECT="dithematic"
PREFIX="/usr/local"
DOCDIR="${PREFIX}/share/doc/${GH_PROJECT}"
EXAMPLESDIR="${PREFIX}/share/examples/${GH_PROJECT}"
BASESYSCONFDIR="/etc"
VARBASE="/var"

ZONE_NAME="$1"

NSD_DIR="${VARBASE}/nsd"
ZONE_DIR="${NSD_DIR}/zones/master"
KEY_DIR="${KEY_DIR:-/etc/ssl/dns}"
KEY_HMAC="${2:-hmac-sha512}"
DDNS="${DDNS:-false}"
DOMAIN=$(hostname | sed "s/$(hostname -s)\.//")

# New keys if missing
KEY_NAME="${KEY_NAME:-tsig.${ZONE_NAME}}"
CSK="${CSK:-${ZONE_NAME}.CSK}"
DNSKEY="${DNSKEY:-${ZONE_NAME}.DNSKEY}"

# Role: master or slave
grep "^master=yes" ${BASESYSCONFDIR}/pdns/pdns.conf &&
 MASTER="${MASTER:-true}" ||
  MASTER="${MASTER:-false}"

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

umask 137

# NSD
#

# Old zone
ls -l ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME} && exit 1

# New zone
printf "%s\n" "zone:" > ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}
printf "\t%s\n" \
 "name: \"${ZONE_NAME}.\"" \
 "zonefile: \"slave/${ZONE_NAME}.zone\"" \
 "notify-retry: 2" \
 >> ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}

if "${MASTER}"
 then
  cp ${DOCDIR}/nsd.conf.master.PowerDNS ${VARBASE}/nsd/etc/
  printf "\t%s\n" \
   "# Super-Master" \
   "include: ${VARBASE}/nsd/etc/nsd.conf.master.PowerDNS" \
   >> ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}
  [ -n "${SLAVE_IP}" ] &&
   printf "\t%s\n" \
    "# Super Slave(s)" \
    "include: ${VARBASE}/nsd/etc/nsd.conf.slave.${ZONE_NAME}" \
    >> ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}
  [ -n "${FREE_SLAVE}" ] &&
   printf "\t%s\n" \
    "# Free Slave(s)" \
    >> ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}
  for _FREE_SLAVE in ${FREE_SLAVE}
   do
    cp ${DOCDIR}/nsd.conf.slave.${_FREE_SLAVE} ${VARBASE}/nsd/etc/
    printf "\t%s\n" \
     "include: ${VARBASE}/nsd/etc/nsd.conf.slave.${_FREE_SLAVE}" \
     >> ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}
   done
 else
  cp ${DOCDIR}/nsd.conf.slave.PowerDNS ${VARBASE}/nsd/etc/
  printf "\t%s\n" \
   "# Super Slave" \
   "include: ${VARBASE}/nsd/etc/nsd.conf.slave.PowerDNS" \
   "# Super Master(s)" \
   "#multi-master-check: yes" \
   "include: ${VARBASE}/nsd/etc/nsd.conf.master.${ZONE_NAME}" \
   >> ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}
fi

if "${MASTER}"
 then
  printf "\t%s\n" \
   "# ${ZONE_NAME} slave" \
   > ${VARBASE}/nsd/etc/nsd.conf.slave.${ZONE_NAME}
  for _SLAVE_IP in ${SLAVE_IP}
   do
    printf "\t%s\n" \
     "provide-xfr: ${_SLAVE_IP} tsig.${DOMAIN}." \
     "notify: ${_SLAVE_IP} tsig.${DOMAIN}." \
     >> ${VARBASE}/nsd/etc/nsd.conf.slave.${ZONE_NAME}
    grep ${_SLAVE_IP} ${BASESYSCONFDIR}/pf.conf.table.dns ||
     printf "%s\n" "${_SLAVE_IP}" >> ${BASESYSCONFDIR}/pf.conf.table.dns
   done
 else
  printf "\t%s\n" \
   "# ${ZONE_NAME} master" \
   > ${VARBASE}/nsd/etc/nsd.conf.master.${ZONE_NAME}
  for _MASTER_IP in ${MASTER_IP}
   do
    printf "\t%s\n" \
     "request-xfr: AXFR ${_MASTER_IP} tsig.${DOMAIN}." \
     "allow-notify: ${_MASTER_IP} tsig.${DOMAIN}." \
     >> ${VARBASE}/nsd/etc/nsd.conf.master.${ZONE_NAME}
    grep ${_MASTER_IP} ${BASESYSCONFDIR}/pf.conf.table.dns ||
     printf "%s\n" "${_MASTER_IP}" >> ${BASESYSCONFDIR}/pf.conf.table.dns
   done
fi

# pf table "dns"
pfctl -t dns -T replace -f ${BASESYSCONFDIR}/pf.conf.table.dns

# Include zone configuration
grep "^include: ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}" \
 ${VARBASE}/nsd/etc/nsd.conf ||
  printf "%s\n" \
   "include: ${VARBASE}/nsd/etc/nsd.conf.zone.${ZONE_NAME}" \
   >> ${VARBASE}/nsd/etc/nsd.conf

# Reload
rcctl reload nsd

# PowerDNS
#

# Old zone
pdnsutil list-zone ${ZONE_NAME} && exit 1

# Load zone template from ${VARBASE}/nsd/zones/master/${ZONE_NAME}.zone
[ -r ${ZONE_DIR}/${ZONE_NAME}.zone ] &&
 pdnsutil load-zone ${ZONE_NAME} ${ZONE_DIR}/${ZONE_NAME}.zone ||
  pdnsutil create-zone ${ZONE_NAME}

# DNSSEC
#
if "${MASTER}"
 then
  [ -r ${KEY_DIR}/private/${CSK} ] ||
   (umask 077; pdnsutil generate-zone-key KSK ecdsa256 | sed '/Flags/d' \
    > ${KEY_DIR}/private/${CSK})
  pdnsutil set-nsec3 ${ZONE_NAME} "1 0 333 $(nsec3salt)" inclusive
  pdnsutil import-zone-key ${ZONE_NAME} ${KEY_DIR}/private/${CSK}
  local \
   _id=$(pdnsutil list-keys ${ZONE_NAME} | awk -v name=${ZONE_NAME} '$0 ~ name { print $5 }')
  pdnsutil activate-zone-key ${ZONE_NAME} "${_id}"
fi

# TSIG
#
if [ "${ZONE_NAME}" = "${DOMAIN}" -a "${MASTER}" ]
 then
  [ -r ${KEY_DIR}/private/${KEY_NAME} ] || tsig-secret ${KEY_NAME}
  tsig-change ${KEY_NAME}
fi

if [ "${DDNS}" -a "${MASTER}" ]
 then
  [ -r ${KEY_DIR}/private/${KEY_NAME} ] || tsig-secret ${KEY_NAME}
  pdnsutil import-tsig-key \
   ${KEY_NAME} ${KEY_HMAC} $(<${KEY_DIR}/private/${KEY_NAME})
fi

pdnsutil activate-tsig-key ${ZONE_NAME} tsig.${DOMAIN} master
pdnsutil activate-tsig-key ${ZONE_NAME} tsig.${DOMAIN} slave

# Master or Slave
if "${MASTER}"
 then
  pdnsutil set-kind ${ZONE_NAME} master
  if ${DDNS}
   then
    pdnsutil set-meta ${ZONE_NAME} ALLOW-DNSUPDATE-FROM 0.0.0.0/0,::/0
    pdnsutil set-meta ${ZONE_NAME} TSIG-ALLOW-DNSUPDATE ${KEY_NAME}
    pdnsutil set-meta ${ZONE_NAME} NOTIFY-DNSUPDATE 1
  fi
 else
  pdnsutil set-kind ${ZONE_NAME} slave
  pdnsutil change-slave-zone-master ${ZONE_NAME} 127.0.0.1:10053 [::1]:10053
  pdnsutil unset-presigned ${ZONE_NAME}
fi
pdnsutil set-meta ${ZONE_NAME} SOA-EDIT-DNSUPDATE SOA-EDIT-INCREASE

# Finish
#
if "${MASTER}"
 then
  pdnsutil export-zone-dnskey ${ZONE_NAME} "${_id}" > ${KEY_DIR}/${DNSKEY}
  echo Send the DNSKEY to registrar:
  cat ${KEY_DIR}/${DNSKEY}
fi
pdnsutil rectify-zone ${ZONE_NAME}
env EDITOR="${EDITOR:-vi}" pdnsutil edit-zone ${ZONE_NAME}

echo Add ${ZONE_NAME} to all nameservers and share the master key: tsig-share tsig.${DOMAIN}

