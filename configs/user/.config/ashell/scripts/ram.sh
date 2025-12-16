#!/bin/bash

while true; do
    # Get memory stats in MiB from 'free' command
    # $2 = Total, $3 = Used, $7 = Available
    read total used available < <(free -m | grep Mem | awk '{print $2, $3, $7}')
    
    # Calculate percentage
    percent=$(( 100 * used / total ))
    
    # Determine CSS state
    if [ "$percent" -ge 85 ]; then
        alt="critical"
    elif [ "$percent" -ge 70 ]; then
        alt="warning"
    else
        alt="default"
    fi

    # Format text: Use GiB if > 1024 MiB used, otherwise MiB
    used_gb=$(awk -v u="$used" 'BEGIN {printf "%.1f", u/1024}')
    total_gb=$(awk -v u="$total" 'BEGIN {printf "%.1f", u/1024}')
    text="${used_gb}/${total_gb} GiB"


    jq -n --unbuffered --compact-output \
        --arg t "$text " \
        --arg a "$alt" \
        '{text: $t, alt: $a}'

    sleep 2
done