#! /bin/bash
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# This way we can work with realtive paths in the rest of the script
cd "${SOURCE_DIR}"

source config.sh

# Last run took approx 6d 15h
python2 ./cdx-index-client/cdx-index-client.py -p${THREADS} -j -z --max-retries 5 \
	-d "${STORAGE_PATH}" \
	--header 'User-Agent: python-requests/2.9.1/hildenae-at-gmail-com' \
	--cdx-server-url 'http://web.archive.org/cdx/search/cdx' \
	'*.no'
