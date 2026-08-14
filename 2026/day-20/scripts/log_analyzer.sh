#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
	echo "No log file path Provided..."
	exit 1
fi

log_file=$1

if [ ! -f "$log_file" ]; then
	echo "File does not exist: $log_file"
	exit 1
fi

#creating archive folder if it dosn't exixt...

mkdir  -p archive

#date
analysis_date=$(date)

#total lines count
total_lines_processed=$(wc -l < "$log_file")

#total errors
total_error_count=$(grep -Ei "ERROR|FAILED" "$log_file" | wc -l)

#top 5 error Messages...
top_errors=$(grep -i "error" "$log_file" | sort | uniq -c | sort -nr | head -5)

#CRITICAL events with line number
critical_events=$(grep -n "CRITICAL" "$log_file" | while IFS=: read -r line_num log_entry
do
	echo "Line $line_num: $log_entry"
done)

# Report file (inside archive folder)
report_file="archive/log_report_$(date +%F).txt"

{
    echo "========== LOG ANALYSIS REPORT =========="
    echo
    echo "Date of analysis: $analysis_date"
    echo "Log file name: $log_file"
    echo "Total lines processed: $total_lines_processed"
    echo "Total error count: $total_error_count"
    echo

    echo "---------- Top 5 Error Messages ----------"
    echo "$top_errors"
    echo

    echo "---------- Critical Events ----------"
    echo "$critical_events"
    echo

} > "$report_file"

echo "Summery Report Generated: $report_file"


# Move processed log file to archive
mv "$log_file" archive/

echo "Moved $log_file to archive/"
echo "Log analysis completed."


