#!/bin/bash

read -p "Enter any  number: " num

if [ "$num" -eq "$num" ] &>/dev/null; then
	:
else  
	echo "Enter a valid number"
	exit 1
fi

if [ "$num" -gt 0 ]; then
	while [ "$num" -gt 0 ]; do
		echo "$num"
		((num--))
	done

elif [ "$num" -lt 0 ]; then
	while [ "$num" -lt 0 ]; do
		echo "$num"
		((num++))
	done
else
	echo "0"
fi
echo "Done!"
	
