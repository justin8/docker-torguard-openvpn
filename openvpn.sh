#!/bin/sh
set -e -u -o pipefail


if [ -n "$REGION" ]; then
  sed -i "s|up /etc/openvpn/update-resolv-conf|up /etc/openvpn/up.sh|g" TorGuard.${REGION}.ovpn
  sed -i "s|down /etc/openvpn/update-resolv-conf|up /etc/openvpn/down.sh|g" TorGuard.${REGION}.ovpn
  set -- "$@" '--config' "TorGuard.${REGION}.ovpn"
fi

if [ -n "$USERNAME" -a -n "$PASSWORD" ]; then
  echo "$USERNAME" > auth.conf
  echo "$PASSWORD" >> auth.conf
  set -- "$@" '--auth-user-pass' 'auth.conf'
fi

openvpn "$@"
