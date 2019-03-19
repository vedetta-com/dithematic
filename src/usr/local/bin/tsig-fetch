#!/bin/sh
# TSIG fetch: tsig-fetch name
# e.g. tsig-fetch tsig.example.com

set -o errexit
set -o nounset

# Bail out if non-privileged UID
[ 25353 -eq "$(id -u)" ] || exit 1

KEY_NAME="$1"
KEY_DIR="${KEY_DIR:-/etc/ssl/dns}"
VALIDATE="/usr/local/share/doc/dithematic/validate.tsig"

umask 077

# Download
cat - > ${HOME}/.key/${KEY_NAME}

# Validate
nsd-checkconf "${VALIDATE}"

# Install
doas cp ${HOME}/.key/${KEY_NAME} ${KEY_DIR}/private/

# Change
doas tsig-change ${KEY_NAME}

# Clean
rm ${HOME}/.key/${KEY_NAME}

