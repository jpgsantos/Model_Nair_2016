#!/bin/bash
if (($#>0)); then
    if [[ `which ssconvert` ]]; then
    j=0;
    Document=`head -n 1 "${1}" | sed -E "s/^.*Document='([^']+)'.*\\$/\\1/"`
    for i in $*; do
	TableName=`head -n 1 "${i}" | sed -E "s/^.*TableName='([^']+)'.*\\$/\\1/"`
	echo "$TableName"
	f[j]="/dev/shm/${TableName}"
	cp "${i}" "${f[j]}"
	((j++));
    done
    HASH=`md5sum "$@" | md5sum`
    echo "file hash (md5): ${HASH}; this will be used to make a hopefully unique file name."
    FILE="./${Document}_`date +%Y-W%W_${HASH:0:6}`.ods"
    ssconvert --merge-to="$FILE" "${f[@]}"
    else
	echo "gnumeric's «ssconvert» not found"
    fi
else
    echo "Usage: $0 file1.tsv file2.tsv [...]"
fi
