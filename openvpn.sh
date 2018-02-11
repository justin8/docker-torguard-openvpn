#!/bin/sh
set -e -u -o pipefail


if [ -n "$REGION" ]; then
  set -- "$@" '--config' "TorGuard.${REGION}.ovpn"
fi

if [ -n "$USERNAME" -a -n "$PASSWORD" ]; then
  echo "$USERNAME" > auth.conf
  echo "$PASSWORD" >> auth.conf
  set -- "$@" '--auth-user-pass' 'auth.conf'
fi

openvpn "$@"
