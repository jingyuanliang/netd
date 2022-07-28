#!/bin/bash

set -exu

cd /jq-*/

apt-get update

apt-get install -y gcc make file

# Disable regular expression support
./configure --without-oniguruma

make -j8 LDFLAGS=-all-static

strip jq

# print out some info about this, size, and to ensure it's actually fully static
ls -lah jq
file jq
# exit with error code 1 if the executable is dynamic, not static
ldd jq && exit 1 || true

./jq -V
echo '{}' | ./jq .

mkdir -p /tmp/release/
mv jq /tmp/release/jq
