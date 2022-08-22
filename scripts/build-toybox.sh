#!/bin/bash

# This file can be in bash as toybox build script is also in bash,
# and bash is included in Debian base images anyway.

# Toybox cannot be built easily on Alpine or it triggers errors, such as:
# toys/pending/route.c:47:10: fatal error: 'linux/rtnetlink.h' file not found

set -exu

toys="ls mktemp mv route sed test"

cd /toybox-*/

apt-get update
apt-get install -y --no-install-recommends --no-install-suggests make clang file

# gcc doesn't work for some reason: `configure: error: C compiler cannot create executables`
export CC=clang

make allnoconfig

for toy in $toys
do
  echo "CONFIG_${toy^^}=y" >> .config
done

LDFLAGS="--static" make

# print out some info about this, size, and to ensure it's actually fully static
ls -lah toybox
file toybox
# exit with error code 1 if the executable is dynamic, not static
ldd toybox && exit 1 || true

./toybox
./toybox ls

mkdir -p /tmp/release/
mv toybox /tmp/release/toybox

chmod a+rx /tmp/release/toybox

for cmd in [ $toys
do
  ln -s /bin/toybox "/tmp/release/$cmd"
done
