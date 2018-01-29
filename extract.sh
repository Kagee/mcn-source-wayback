#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# This way we can work with realtive paths in the rest of the script
cd "${SOURCE_DIR}"

source config.sh
TMP="./extraxt.tmp"

function ext {
  for X in 1; do #data/*; do 
    X="$1"
    #echo $X;
    gunzip -c "$X" 2> /dev/null > "${TMP}"
    if [ $? -ne 0 ]; then
        echo "${X} failed to extract" 1>&2;
        continue;
    fi
    echo "${X} extracted ok";
    #while [ $(df . | awk '/vda1/{print substr($5, 1, length($5)-1)}') -gt 52 ]; do echo "less that 52";sleep 10s; done
  done
}

ext "$(cat errors.txt| sort -R | head -1 | grep -o '/root.*.gz')"
ext "/root/mcn-source-wayback/data/domain-no-40000.gz"

rm "${TMP}"
