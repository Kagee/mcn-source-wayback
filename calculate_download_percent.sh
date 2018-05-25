#! /bin/zsh
# Calculate download persentage
MAX_PAGE=68182
echo "; ($(ls data_urlz | sort -n | tail -1 | grep -o -P '\d*')/$MAX_PAGE)*100" | bc -l | grep -o '^.....';

