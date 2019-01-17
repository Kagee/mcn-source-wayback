#! /bin/bash
#zsh
#cd "${0:a:h}"
source config.sh

# Dosen't actually work ...
echo -n "Errors: ";
A=$(for X in ${STORAGE_PATH}/*; do
	zcat $X | tail -1; done | grep -E '\]\]|\[\]' | wc -l) 2>&1 | grep 'unexpected end';
B=$(ls data | wc -l);
sleep 1
echo -e "\n\nOK:$A\nTotal:$B"
