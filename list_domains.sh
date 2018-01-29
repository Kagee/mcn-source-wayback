#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# This way we can work with realtive paths in the rest of the script
cd "${SOURCE_DIR}"

source config.sh
#STORAGE_PATH="$PWD/data"
#THREADS=3
#MCN_TOOLS="/root/mcn-tools"
#DOMAINS="mcn-source-wayback.list"

TMP="./extract.tmp"
TMP2="./extract2.tmp"

find ${STORAGE_PATH}/ -type f -name '*.gz' | sort | while read X; do
  #echo "${X}"
  OUT="$(dirname "${X}")_urlz/$(basename "${X}" .gz).urlz"
  if [ ! -f "${OUT}" ]; then 
    gunzip -c "$X" 2> /dev/null > "${TMP}"
    if [ $? -ne 0 ]; then
        echo "${X} failed to extract" 1>&2;
        continue;
    fi
    echo "${X} extracted ok (${OUT})";
    jq -r '.[][2]' "${TMP}" | sort | uniq | \
        iconv -c -f utf-8 -t utf-8 | sed -e 's/\.no\.html/.html/g' | \
        ${MCN_TOOLS}/urldecode 3 | gzip > "${TMP2}";
    mv "${TMP2}" "${OUT}";
    if [ $(df . | awk '/vda1/{print substr($5, 1, length($5)-1)}') -gt 90 ]; then
      pushover "Storage space less than 90%, halting url extraction"
      while [ $(df . | awk '/vda1/{print substr($5, 1, length($5)-1)}') -gt 90 ]; do 
          echo "more than 90% of /dev/vda1/ used";
          sleep 5m; 
      done
    fi
  else
    echo "Found ${OUT}, skipping";
  fi
done

#find ${STORAGE_PATH}/ -type f -name '*.gz' -exec gunzip -c {} \; | \
#        parallel --jobs ${THREADS} --pipe iconv -c -f utf-8 -t utf-8 | \
#        sed -e 's/\.no\.html/.html/g' | \
#        ${MCN_TOOLS}/urldecode 3 | ${MCN_TOOLS}/default_extract > "${DOMAINS}"

rm "${TMP}" "${TMP2}"
