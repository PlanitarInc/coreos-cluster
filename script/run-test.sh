#!/bin/bash

CANONICAL_PATH=`readlink -f "$0"`
PROG_NAME=`basename "$CANONICAL_PATH"`
SCRIPT_DIR=`dirname "$CANONICAL_PATH"`

export PATH="$SCRIPT_DIR:$PATH"

unit_path="$1"
unit_name=`basename "$unit_path"`
expected_result="${2:-success}"

if [ $# -lt 1 -o "$unit_path" == "-h" -o "$unit_path" == "--help" ]; then
  cat >&2 <<EOF
Usage: $PROG_NAME <test unit> [<expected result>]

  where expected result values are: success, failure, timeout (default: success)
EOF

  exit 1
fi

fleetctl start "$unit_path"

res=`fleet-wait.sh "$unit_name"`

if [ "$res" != "$expected_result" ]; then
    echo "  : got = $res, expected = $expected_result"
    fleetctl journal --lines 50 "$unit_name" | sed 's/^/  : /'
fi

fleetctl destroy "$unit_name"
echo ' '

test "$res" == "$expected_result"
