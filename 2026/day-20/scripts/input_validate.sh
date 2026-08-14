#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo "ERROR: No log file path provided.."
	exit 1
fi

log_file=$1

if [ ! -f "$log_file" ]; then
	echo "ERROR: $log_file doesn't exist..."
	exit 1
fi

echo "Log file found $log_file"
