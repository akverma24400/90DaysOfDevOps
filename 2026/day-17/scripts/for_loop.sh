#!/bin/bash

fruits=("Apple" "Banana" "Mango" "kiwi" "Blackberry")

echo "List of fruits"

for fruit in "${fruits[@]}"
do
	echo "$fruit"
done
