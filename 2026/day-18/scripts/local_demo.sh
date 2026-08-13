#!/bin/bash


# set -euo pipefail


name="global"

fun_a(){
	local loc_name="local_a"
	echo "Inside function a: $loc_name"
}

fun_b(){
	regular_name="regular"
	echo "Inside function b: $regular_name"
}

fun_a
fun_b

echo ""
echo "printing outside function a: $loc_name"
echo "Printing outside function b: $regular_name"
echo "Printing global variable: $name"
