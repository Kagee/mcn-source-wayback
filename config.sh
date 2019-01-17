#! /bin/bash
# MCN_TOOLS have moved to system config file
source "$HOME/.mcn.conf"

STORAGE_PATH="$PWD/data"
CPUS="$(grep -c ^processor /proc/cpuinfo)"
CPUS80="$( echo "$CPUS * 0.8" | bc)"
THREADS="${CPUS80%.*}"

DOMAINS="mcn-source-wayback.list"
