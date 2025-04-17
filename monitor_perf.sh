#!/bin/bash
# Script: monitor_log.sh
# This script collects every second the following information:
#   - The top 1 process by CPU usage (using top in batch mode)
#   - The top 1 process by memory usage (using top in batch mode sorted by %MEM)
#   - The network usage information using iftop (extracting total send and receive rate)
#   - The "Disk space used" line from the output of fdbcli status
#
# All results are appended to the specified log file.

# Set the log file path (adjust as needed)
if [ -n "$1" ]; then
    LOG_FILE="/users/Ziqif/${1}_monitor.log"
else
    LOG_FILE="/users/Ziqif/monitor.log"
fi

while true; do
    # Get the current timestamp
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Get the top 1 process by CPU usage.
    # 'top' outputs header lines; this command finds the header "PID" and prints the next line.
    TOP_CPU=$(top -b -n 1 | awk '/^ *PID/ {getline; print $0}')

    # Get the top 1 process by memory usage.
    # Use the -o %MEM option to sort by memory usage.
    TOP_MEM=$(top -b -n 1 -o %MEM | awk '/^ *PID/ {getline; print $0}')

    # Get network usage using iftop in text mode for 1 second.
    # We extract the line containing "Total send and receive rate:".
    NET_LINE=$(sudo iftop -t -s 1 -n | grep "Total send and receive rate:" | head -n 1)

    {
      echo "==== $TIMESTAMP ===="
      echo "------ Top 1 process by CPU usage ------"
      echo "$TOP_CPU"
      echo ""
      echo "------ Top 1 process by memory usage ------"
      echo "$TOP_MEM"
      echo ""
      echo "------ Network Usage (iftop) ------"
      echo "$NET_LINE"
      echo ""
      echo "----------------------------------------"
      echo ""
    } >> "$LOG_FILE"

    sleep 1
done