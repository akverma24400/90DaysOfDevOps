#!/bin/bash

set -euo pipefail

check_disk(){
	usage=$(df / |awk 'NR==2 {print $5}' | tr -d '%')

	echo "Disk Usages is: ${usage}%"

	if [ "$usage" -gt 80 ]; then
		return 1
	else
		return 0
	fi
}

check_memory(){
	free_mem=$(free -m |awk 'NR==2 {print $7}')
	echo "Free memory is ${free_mem}MB"
	if [ "$free_mem" -lt 500 ]; then
		return 1
	else
		return 0
	fi
}

main(){
	echo "======system report======="
	if check_disk; then
		echo "Disk Status: Healthy"
	else
		echo "Disk Status: Critical"
	fi

	echo " "

	if check_memory; then
		echo "Memory status: Healthy"
	else
		echo "Memory Status: Low memory"
	fi
}

main
