#!/bin/bash
input=$(cat)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
SESSION_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEKLY_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

COST_FMT=$(printf '$%.3f' "$COST")
IN_K=$(awk "BEGIN {printf \"%.1f\", $IN_TOKENS/1000}")
OUT_K=$(awk "BEGIN {printf \"%.1f\", $OUT_TOKENS/1000}")

if [ -n "$SESSION_PCT" ] && [ -n "$WEEKLY_PCT" ]; then
  SESSION_INT=$(printf '%.0f' "$SESSION_PCT")
  WEEKLY_INT=$(printf '%.0f' "$WEEKLY_PCT")
  echo "💰 ${COST_FMT} | 📊 ${CTX_PCT}% | 🕐 ${SESSION_INT}% | 📅 ${WEEKLY_INT}% | ↑${IN_K}k ↓${OUT_K}k"
else
  echo "💰 ${COST_FMT} | 📊 ${CTX_PCT}% | ↑${IN_K}k ↓${OUT_K}k"
fi
