#!/bin/sh

PROG_PATH=`readlink -f "$0"`
ROOT_PATH=`dirname "${PROG_PATH}/.."`

if [ $# -le 1 ]; then
  prog=`filename "$PROG_PATH"`
  echo "Usage: $prog <units to deploy>" >&2
  exit 1
fi

shift

. "${ROOT_PATH}/.config"
FLEETCTL_TUNNEL=${FLEETCTL_TUNNEL:-172.17.8.101}
FLEETCTL_HOST_FILE="${FLEETCTL_HOST_FILE:-~/.fleetctl/known_hosts}"

fleetctl --tunnel=${FLEETCTL_TUNNEL} --strict-host-key-checking=false \
  --known-hosts-file=${FLEETCTL_HOST_FILE} start "$@"
fleetctl --tunnel=${FLEETCTL_TUNNEL} --strict-host-key-checking=false \
  --known-hosts-file=${FLEETCTL_HOST_FILE} list-units
