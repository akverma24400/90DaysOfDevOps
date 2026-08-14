#!/bin/bash

#!/bin/bash

log_file="$1"

if [ $# -eq 0 ]; then
    echo "Error: No log file path provided."
    exit 1
fi

if [ ! -f "$log_file" ]; then
    echo "Error: File does not exist: $log_file"
    exit 1
fi

echo "--- Top 5 Error Messages ---"

grep -i "error" "$log_file" | sort | uniq -c | sort -nr | head -5
