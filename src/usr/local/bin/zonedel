#!/bin/sh
# Remove a zone: zonedel name

set -o errexit
set -o nounset

# Bail out if non-privileged UID
[ 0 -eq "$(id -u)" ] || exit 1

ZONE_NAME="$1"

NSD_DIR="${NSD_DIR:-/var/nsd}"
KEY_DIR="${KEY_DIR:-/etc/ssl/dns}"
DOMAIN=$(hostname | sed "s/$(hostname -s)\.//")

# NSD
#
rm -f ${NSD_DIR}/etc/nsd.conf.*.${ZONE_NAME}
sed -i "/nsd.conf.zone.${ZONE_NAME}/d" ${NSD_DIR}/etc/nsd.conf

# PowerDNS
#
pdnsutil list-zone ${ZONE_NAME} && pdnsutil delete-zone ${ZONE_NAME}

# Finish
#
ls -l ${KEY_DIR}/private/*${ZONE_NAME}* ${KEY_DIR}/*${ZONE_NAME}*

