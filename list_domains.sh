#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SOURCE_DIR}"

source config.sh
#STORAGE_PATH="$PWD/data"
#THREADS=3
#DOMAINS="mcn-source-wayback.list"
YMD="$(date +%F)"
function test_storage_space {
  if [ $(df "$STORAGE_PATH" | awk '/\/dev/{print substr($5, 1, length($5)-1)}') -gt $1 ]; then
    pushover "Storage space less than $1%, halting wayback extraction"
    while [ $(df "$STORAGE_PATH" | awk '/\/dev/{print substr($5, 1, length($5)-1)}') -gt $1 ]; do
        echo "more than $1% storage on drive of \$STORAGE_PATH used";
        sleep 5m;
    done
  fi
}

TMP="./extract.tmp"
TMP2="./extract2.tmp"
mkdir data_urlz
find ${STORAGE_PATH}/ -type f -name '*.gz' | sort | while read X; do
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
    test_storage_space 94
  else
    echo "Found ${OUT}, skipping";
  fi
done
mv output/* old/
find ${STORAGE_PATH}_urlz/ -type f -name '*.urlz' -exec gunzip -c {} \; | \
        parallel --jobs ${THREADS} --pipe iconv -c -f utf-8 -t utf-8 | \
        sed -e 's/\.no\.html/.html/g' | \
        ${MCN_TOOLS}/urldecode 3 | ${MCN_TOOLS}/default_extract > "${DOMAINS}"
mv "${DOMAINS}" "output/${YMD}-${DOMAINS}"
rm "${TMP}"
