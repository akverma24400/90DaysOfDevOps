#!/bin/bash

set -euo pipefail

sys_info(){
	echo "==== hostname & system info ===="
	echo "Host_Name	: $(hostname)"
	echo "Kernal	: $(uname -r)"
	echo "OS	: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2)"
}

sys_uptime(){
	echo "==== System Uptime ===="
	uptime -p
}

disk_usage(){
	echo -e "====Disk Usage ===="
	df -h | awk 'NR==1'
	df -h | sort -hr -k2 | head -5
}

cpu_consuming_processes() {
    echo -e "\n===== CPU-CONSUMING PROCESSES ======"
    ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 6
}

main(){
	sys_info
	sys_uptime
	disk_usage
	cpu_consuming_processes
}

main
