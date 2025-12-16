#!/bin/bash

# Function to read CPU stats from /proc/stat
# Columns: cpu user nice system idle iowait irq softirq steal ...
# We calculate:
#   Idle  = idle($5) + iowait($6)
#   Total = user($2)+nice($3)+system($4)+idle($5)+iowait($6)+irq($7)+softirq($8)
#   Active = Total - Idle
get_cpu_stat() {
    grep '^cpu ' /proc/stat | awk '{
        idle = $5 + $6
        total = $2 + $3 + $4 + $5 + $6 + $7 + $8
        print (total - idle) " " total
    }'
}

# 1. Initial read to establish a baseline
read cpu_active_prev cpu_total_prev < <(get_cpu_stat)

while true; do
    # 2. Wait for a moment to gather new stats
    sleep 2

    # 3. Read current stats
    read cpu_active_cur cpu_total_cur < <(get_cpu_stat)

    # 4. Calculate the change (delta)
    cpu_active_delta=$((cpu_active_cur - cpu_active_prev))
    cpu_total_delta=$((cpu_total_cur - cpu_total_prev))

    # 5. Calculate percentage
    # Avoid division by zero
    if [ "$cpu_total_delta" -eq 0 ]; then
        cpu_usage=0
    else
        cpu_usage=$((100 * cpu_active_delta / cpu_total_delta))
    fi

    # 6. Determine "alt" class for colors
    if [ "$cpu_usage" -ge 80 ]; then
        alt="critical"
    elif [ "$cpu_usage" -ge 50 ]; then
        alt="warning"
    else
        alt="default"
    fi

    # 7. Output JSON
    jq -n --unbuffered --compact-output \
        --arg t "$cpu_usage% " \
        --arg a "$alt" \
        '{text: $t, alt: $a}'

    # 8. Save current values as previous for the next loop
    cpu_active_prev=$cpu_active_cur
    cpu_total_prev=$cpu_total_cur
done