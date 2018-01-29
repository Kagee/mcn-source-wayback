#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# This way we can work with realtive paths in the rest of the script
cd "${SOURCE_DIR}"

source config.sh
#STORAGE_PATH="$PWD/data"
#THREADS=3
#MCN_TOOLS="/root/mcn-tools"
#DOMAINS="mcn-source-wayback.list"

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
    jq -r '.[][2]' "${TMP}" | uniq 
    #while [ $(df . | awk '/vda1/{print substr($5, 1, length($5)-1)}') -gt 52 ]; do echo "less that 52";sleep 10s; done
  done
}

ext "$(cat errors.txt| sort -R | head -1 | grep -o '/root.*.gz')"
ext "/root/mcn-source-wayback/data/domain-no-40000.gz"

find ${STORAGE_PATH}/ -type f -name '*.gz' -exec gunzip -c {} \; | \
        parallel --jobs ${THREADS} --pipe iconv -c -f utf-8 -t utf-8 | \
        sed -e 's/\.no\.html/.html/g' | \
        ${MCN_TOOLS}/urldecode 3 | ${MCN_TOOLS}/default_extract > "${DOMAINS}"

rm "${TMP}"
