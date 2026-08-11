#!/bin/bash

read -p "Please Enter file name you want to check: " filename
if [ -f $filename ]; then
	echo "The file $filename exist."
else
	echo "The file $filename not exist."
fi
