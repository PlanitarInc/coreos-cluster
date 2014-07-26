#!/bin/sh

CANONICAL_PATH=`readlink -f "$0"`
PROG_NAME=`basename "$CANONICAL_PATH"`
SCRIPT_DIR=`dirname "$CANONICAL_PATH"`

get_status() {
  # Remove color escape codes, then do the manipulation
  fleetctl status "$1" | \
    sed 's,\x1B\[[0-9;]*[a-zA-Z],,g' | \
    sed -n 's/^ *Active: \([a-zA-Z0-9]*\) (\([^)]*\)).*$/\1\n\2/p'
}

is_done() {
  get_status "$1" | head -n 1 | grep -qwEe 'inactive|failed'
}

debug() {
  echo "[D] $@" >&2
}

unit="$1"

if [ $# -lt 1 -o "$unit" == "-h" -o "$unit" == "--help" ]; then
  echo "Usage: $PROG_NAME <test unit>" >&2
  exit 1
fi

if ! get_status "$unit" | grep -q . ; then
  echo "Error: unknown unit '$unit'" >&2
  exit 1
fi

until is_done "$unit"; do
  debug `get_status "$unit"` "... waiting 5 seconds..."
  sleep 5;
done

debug `get_status "$unit"`

get_status "$unit" | tail -n +2 | \
  awk '/\<dead\>/      { print "success"; exit 0; }
       /\<timeout\>/   { print "timeout"; exit 0; }
       /\<exit-code\>/ { print "failure"; exit 0; }
                       { exit 1; }
       '
