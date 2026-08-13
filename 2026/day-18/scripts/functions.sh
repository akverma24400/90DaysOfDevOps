#!/bin/bash

set -euo pipefail


greet(){
	echo "Hello, $1!"
}

add(){
	local sum=$(($1 + $2))
	echo "sum is $sum"
}

read -p "Please Enter your Name: " name
greet "$name"

read -p "Enter any Two Numbers: " a b
if [ "$a" -eq "$a" ] 2>/dev/null && [ "$b" -eq "$b" ] 2>/dev/null; then
	add "$a" "$b"
else
	echo"Please Enter valid number..."
	exit 1
fi


