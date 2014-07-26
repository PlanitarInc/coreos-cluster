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

echo $res "::" $expected_result

[ "$res" != "$expected_result" ] && fleetctl journal "$unit_name"

fleetctl destroy "$unit_name"

test "$res" == "$expected_result"
