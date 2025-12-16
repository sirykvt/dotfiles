#!/usr/bin/env bash
set -euo pipefail

# Query GPU utilization (%) and memory used/total (MiB)
# Output (1 GPU):  "GPU: 37%  3.2/8.0 GiB"
# Output (multi):  "GPU0: 12%  0.5/8.0 GiB  GPU1: 55%  6.8/12.0 GiB"

mapfile -t rows < <(
  nvidia-smi \
    --query-gpu=utilization.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null || true
)

if [[ ${#rows[@]} -eq 0 || -z "${rows[0]:-}" ]]; then
  echo '{"text":"GPU N/A","tooltip":"nvidia-smi not available","class":"na"}'
  exit 0
fi

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# MiB -> GiB (1 decimal)
to_gib() {
  awk -v mib="$1" 'BEGIN { printf "%.1f", mib / 1024 }'
}

if [[ ${#rows[@]} -eq 1 ]]; then
  IFS=',' read -r util mem_used mem_total <<< "${rows[0]}"
  util="$(trim "$util")"
  mem_used="$(trim "$mem_used")"
  mem_total="$(trim "$mem_total")"

  used_gib="$(to_gib "$mem_used")"
  total_gib="$(to_gib "$mem_total")"

  echo "{\"text\":\"GPU: ${util}%  ${used_gib}/${total_gib} GiB\",\"tooltip\":\"\"}"
else
  text_parts=()
  tip_parts=()

  for i in "${!rows[@]}"; do
    IFS=',' read -r util mem_used mem_total <<< "${rows[$i]}"
    util="$(trim "$util")"
    mem_used="$(trim "$mem_used")"
    mem_total="$(trim "$mem_total")"

    used_gib="$(to_gib "$mem_used")"
    total_gib="$(to_gib "$mem_total")"

    text_parts+=("GPU${i}: ${util}%  ${used_gib}/${total_gib} GiB")
    tip_parts+=("GPU${i}: ${util}%  ${used_gib}/${total_gib} GiB")
  done

  text="$(printf '%s  ' "${text_parts[@]}")"; text="${text%  }"
  tip="$(printf '%s\n' "${tip_parts[@]}")"
  tip_escaped="${tip//$'\n'/\\n}"

  echo "{\"text\":\"${text}\",\"tooltip\":\"${tip_escaped}\",\"class\":\"gpu\"}"
fi
