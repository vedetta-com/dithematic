#!/bin/sh
# nsec3salt: NSEC3PARAM random SALT generator
# for DNS Security (DNSSEC) Hashed Authenticated Denial of Existence (rfc5155)

set -o errexit
set -o nounset

# SHA-1 calculate the message digest for 512 bytes of random
readonly SALT="$(dd if=/dev/random of=/dev/stdout count=1 bs=512 | sha1)"
# The salt SHOULD be at least 64 bits long and unpredictable (rfc5155#section-12.1.1)
# i.e. 2*64 bits = 16 bytes (hexadecimal characters)
printf "%.16s" ${SALT}

