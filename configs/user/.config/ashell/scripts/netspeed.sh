#!/bin/bash

# Auto-detect default interface (e.g., wlan0 or eth0)
INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

# Helper: Convert bytes to human readable
human_readable() {
    local bytes=$1
    if [ "$bytes" -gt 1048576 ]; then
        awk -v b="$bytes" 'BEGIN { printf "%.1f MB/s", b/1048576 }'
    elif [ "$bytes" -gt 1024 ]; then
        awk -v b="$bytes" 'BEGIN { printf "%.0f KB/s", b/1024 }'
    else
        echo "${bytes} B/s"
    fi
}

get_bytes() {
    # Returns: rx_bytes tx_bytes
    # Reading directly from /sys is faster than running commands like ifconfig
    local rx=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
    local tx=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
    echo "$rx $tx"
}

# Initial read
read rx_prev tx_prev < <(get_bytes)

while true; do
    sleep 1

    # Current read
    read rx_curr tx_curr < <(get_bytes)

    # Calculate bytes per second
    rx_speed=$((rx_curr - rx_prev))
    tx_speed=$((tx_curr - tx_prev))

    # Convert to strings
    rx_str=$(human_readable "$rx_speed")
    tx_str=$(human_readable "$tx_speed")

    # Icons:  (Down)  (Up)
    text=" $rx_str   $tx_str"

    # Set alt class based on activity
    if [ "$rx_speed" -gt 1024 ] || [ "$tx_speed" -gt 1024 ]; then
        alt="active"
    else
        alt="idle"
    fi

    jq -n --unbuffered --compact-output \
        --arg t "$text" \
        --arg a "$alt" \
        '{text: $t, alt: $a}'

    # Update previous
    rx_prev=$rx_curr
    tx_prev=$tx_curr
done