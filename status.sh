#! /bin/zsh
echo -n "Errors: "; A=$(for X in data/*; do zcat $X | tail -1; done | grep -E '\]\]|\[\]' | wc -l) 2>&1 | grep -c 'unexpected end'; B=$(ls data | wc -l); echo -e "OK:$A\nTotal:$B"
