#!/bin/sh

set -e

CANONICAL_PATH=`readlink -f "$0"`
TEST_DIR=`dirname "$CANONICAL_PATH"`
ROOT_DIR=`dirname "$TEST_DIR"`

cd "$ROOT_DIR"

cluster_reset() {
  make clean
  make run NINSTANCES=1
}

cluster_reset
sleep 3

vagrant ssh core-01 <<EOF

set -ex

# Wait for skydns server
until ps aux | grep -v grep | grep -q '/usr/bin/docker run --name skydns '; do
  sleep 10s
done

ping -c3 "ya.ru"
ping -c3 "127.0.0.1"

etcdctl set /skydns/plntr/dev/a/01 \
  '{ "host": "ya.ru", "port": 80, "priority": 10 }'
etcdctl set /skydns/plntr/dev/a/02 \
  '{ "host": "01.b.dev.plntr", "port": 80, "priority": 10 }'
etcdctl set /skydns/plntr/dev/b/01 \
  '{ "host": "127.0.0.1", "port":53, "priority": 10 }'

# All 'a' hosts are CNAMES; according to documentation they should be resolved
# in a recursive query, but in practice it does not happen.
ping -c3 a && echo 'Could ping "a"!!' && exit 1 || true
ping -c3 01.a
ping -c3 01.a.dev.plntr
ping -c3 02.a
ping -c3 02.a.dev.plntr
ping -c3 b
ping -c3 b.dev.plntr
ping -c3 01.b
ping -c3 01.b.dev.plntr

etcdctl set /skydns/plntr/dev/a/03 \
  '{ "host": "127.0.0.1", "port": 81, "priority": 13 }'
# Now there is A entry among 'a' hosts, so 'a' is resolved
ping -c3 a
ping -c3 a.dev.plntr
ping -c3 03.a
ping -c3 03.a.dev.plntr

EOF
