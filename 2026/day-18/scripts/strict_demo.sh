#!/bin/bash

echo "================Demo for set -euo pipefail============="
(
	set -euo pipefail
 
	cat hello.txt | grep -i "akash"
)


echo "========= Demo for set -u ================="
(

	set -u
	echo "$username"

)

echo "============== Demo for set -e =================="

(
	set -e
	mkdir test1
	mkdir test1
)

