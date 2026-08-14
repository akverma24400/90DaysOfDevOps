#!/bin/bash

set -euo pipefail

usage(){
	echo "usage: backup.sh source/path destination/path"
	echo "example: backup.sh home/ubuntu/day19 home/ubuntu/backups"
	echo "please prove source and destination..."
}

check_source(){
	[ -d "$src" ] ||{
		echo "Scouce directory dosn't exists..."
	exit 1
	}

	[ -d "$dest" ] ||{
		echo "destination directory dosn't exists..."
	exit 1
	}
}

timestamp=$(date +%Y-%m-%d-%H-%M-%S)
archive="backup-${timestamp}.tar.gz"

backup(){
	echo "====tacking backup===="
	tar -czf "$dest/$archive" "$src" &>/dev/null

	echo "Backup Complete!"
	echo ""
}

print_file(){
    echo "======Backup Taken======"

    size=$(du -sh "$dest/$archive" | awk '{print $1}')

    echo "Archive Name : $archive        Size : $size"
    echo ""

}

delete_old_archives() {

    archives=$(find "$dest" -name "*.tar.gz" -mtime +14)

    if [ -n "$archives" ]; then

        echo "======Removing archives older than 14 days======"

        for file in $archives
        do
            rm "$file"
            echo "Removed Archive : $file"
        done
    fi
}

if [ $# -lt 2 ]; then
    usage
fi

src=$1
dest=$2

check_source
backup
print_file
delete_old_archives


