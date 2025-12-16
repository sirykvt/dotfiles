#!/bin/bash

while true; do
    # 1. Query NVIDIA GPU
    # Output example: "45, 2048, 8192"
    output=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits)

    # 2. Parse the CSV output into variables
    # We strip commas and read into variables
    IFS=',' read -r load mem_used mem_total <<< "$output"

    # Trim leading whitespace caused by the csv format
    load=${load// /}
    mem_used=${mem_used// /}
    mem_total=${mem_total// /}

    # 3. Determine the "alt" state (e.g., critical if load > 80%)
    if [ "$load" -gt 80 ]; then
        alt="critical"
    else
        alt="default"
    fi

    # 4. Construct the text string (e.g., "45% 2.4GiB")
    # You can customize this line to change what displays on the bar
    text_val="$load% ${mem_used}/${mem_total} MiB"

    # 6. Output JSON using jq
    jq -n --unbuffered --compact-output \
        --arg t "$text_val" \
        --arg a "$alt" \
        '{text: $t, alt: $a}'

    # Update every 2 seconds
    sleep 2
done