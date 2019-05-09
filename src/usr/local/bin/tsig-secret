#!/bin/sh
# random base64 encoded TSIG secret generator: tsig-secret name [bytes]
# The secret should be at least as long as the keyed message digest
# i.e. 16 bytes for HMAC-MD5
#      20 bytes for HMAC-SHA1
# e.g. 64 bytes for HMAC-SHA512 authentication algorithm:
#      tsig-secret tsig.example.com
# (*) https://tools.ietf.org/html/rfc2845.html

set -o errexit
set -o nounset

# Bail out if non-privileged UID
[ 0 -eq "$(id -u)" ] || exit 1

KEY_NAME="$1"
KEY_BYTES="${2:-64}"
KEY_DIR="${KEY_DIR:-/etc/ssl/dns}"

mkdir -p ${KEY_DIR}/private
chmod 755 ${KEY_DIR}
chmod 700 ${KEY_DIR}/private

umask 077

# Generate a new secret with the first KEY_BYTES from random(4)
dd if=/dev/random of=/dev/stdout count=1 bs=${KEY_BYTES} |
  openssl enc -base64 -A -out ${KEY_DIR}/private/${KEY_NAME}

