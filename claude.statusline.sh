#!/bin/bash
input=$(cat)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

COST_FMT=$(printf '$%.3f' "$COST")
IN_K=$(awk "BEGIN {printf \"%.1f\", $IN_TOKENS/1000}")
OUT_K=$(awk "BEGIN {printf \"%.1f\", $OUT_TOKENS/1000}")

echo "💰 ${COST_FMT} | 📊 ${USED_PCT}% | ↑${IN_K}k ↓${OUT_K}k"
