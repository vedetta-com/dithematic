#!/bin/sh
# Share TSIG secrets with name servers: tsig-share name
# (!) Secrets should never be shared by more than two entities
# e.g. tsig-share tsig.example.com

set -o errexit
set -o nounset

# Bail out if non-privileged UID
[ 0 -eq "$(id -u)" ] || exit 1

KEY_NAME="$1"
KEY_DIR="${KEY_DIR:-/etc/ssl/dns}"
KEY_USER="${KEY_USER:-tsig}"
SSH_ID="/home/${KEY_USER}/.ssh/id_ed25519"
SSH_LOGIN="${KEY_USER}"
NS="${NS:-dig.example.com}" # (space-separated) domain name(s), or IP(s)

[ -r ${KEY_DIR}/private/${KEY_NAME} ]

for _ns in ${NS}
  do
    ssh -i ${SSH_ID} -l ${SSH_LOGIN} -o VerifyHostKeyDNS=yes ${_ns} exit \
    < ${KEY_DIR}/private/${KEY_NAME}
  done

