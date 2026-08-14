#!/bin/bash

set -euo pipefail

usage(){
	echo "usage: ./log_rotate.sh /var/log/myapp"
	echo "example: ./log_rotate.sh /var/log/nginx"
	exit 1
}

if [ "$#" -eq 0 ]; then
	usage
fi

dir=$1

check_dir(){
    if [ ! -d "$dir" ]; then
        echo "Directory $dir doesn't exist..."
        exit 1
    fi
}

gzip_count=0
delete_count=0

compress(){
	file_list=$(find "$dir" -type f -name "*.log" -mtime +7)
	for file in $file_list; do
		gzip "$file"
		gzip_count=$((gzip_count + 1))
	done
}

del_log(){
	zip_files=$(find "$dir" -type f -name "*.gz" -mtime +30)
	for file in $zip_files; do
		rm "$file"
		delete_count=$((delete_count + 1))
	done
}

check_dir
compress
del_log

echo "Total log files zipped : $gzip_count"
echo "total zip files deleted : $delete_count"
