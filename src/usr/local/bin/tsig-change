#!/bin/sh
# Change TSIG secret for NSD and PowerDNS: tsig-change name [algorithm]
# (!) Secret keys should be changed periodically: tsig-change tsig.example.com

set -o errexit
set -o nounset

# Bail out if non-privileged UID
[ 0 -eq "$(id -u)" ] || exit 1

KEY_NAME="$1"
KEY_HMAC="${2:-hmac-sha512}"
KEY_DIR="${KEY_DIR:-/etc/ssl/dns}"
NSD_DIR="${NSD_DIR:-/var/nsd}"

umask 137

[ -r ${KEY_DIR}/private/${KEY_NAME} ]

# PowerDNS
/usr/local/bin/pdnsutil import-tsig-key \
  ${KEY_NAME} ${KEY_HMAC} $(cat ${KEY_DIR}/private/${KEY_NAME})

# NSD
cp ${KEY_DIR}/private/${KEY_NAME} ${NSD_DIR}/etc/
nsd-checkconf ${NSD_DIR}/etc/nsd.conf && nsd-control reconfig

