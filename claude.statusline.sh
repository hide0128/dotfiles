#!/bin/bash
input=$(cat)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
SESSION_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
SESSION_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEKLY_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEKLY_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# 為替レート（1時間キャッシュ）
RATE_FILE="$HOME/.claude/usd_jpy_rate"
RATE=150
if [ -f "$RATE_FILE" ]; then
  age=$(( $(date +%s) - $(date -r "$RATE_FILE" +%s) ))
  if [ "$age" -lt 86400 ]; then
    RATE=$(cat "$RATE_FILE")
  else
    (curl -sf "https://open.er-api.com/v6/latest/USD" | jq -r '.rates.JPY' > "$RATE_FILE" 2>/dev/null) &
  fi
else
  (curl -sf "https://open.er-api.com/v6/latest/USD" | jq -r '.rates.JPY' > "$RATE_FILE" 2>/dev/null) &
fi
COST_JPY=$(awk "BEGIN {printf \"%.0f\", $COST * $RATE}")
COST_FMT="¥${COST_JPY}"
IN_K=$(awk "BEGIN {printf \"%.1f\", $IN_TOKENS/1000}")
OUT_K=$(awk "BEGIN {printf \"%.1f\", $OUT_TOKENS/1000}")

fmt_session_reset() {
  local ts="$1"
  [ -z "$ts" ] && echo "?" && return
  local now diff h m
  now=$(date +%s)
  diff=$((ts - now))
  [ "$diff" -le 0 ] && echo "soon" && return
  h=$((diff / 3600))
  m=$(((diff % 3600) / 60))
  [ "$h" -gt 0 ] && echo "${h}h${m}m" || echo "${m}m"
}

fmt_weekly_reset() {
  local ts="$1"
  [ -z "$ts" ] && echo "月 7:00" && return
  date -r "$ts" "+%a %H:%M" 2>/dev/null || echo "月 7:00"
}

if [ -n "$SESSION_PCT" ] && [ -n "$WEEKLY_PCT" ]; then
  SESSION_INT=$(printf '%.0f' "$SESSION_PCT")
  WEEKLY_INT=$(printf '%.0f' "$WEEKLY_PCT")
  S_RESET=$(fmt_session_reset "$SESSION_RESET")
  W_RESET=$(fmt_weekly_reset "$WEEKLY_RESET")
  echo "💰 ${COST_FMT} | 📊 ${CTX_PCT}% | 🕐 ${SESSION_INT}%(${S_RESET}) | 📅 ${WEEKLY_INT}%(${W_RESET}リセット) | ↑${IN_K}k ↓${OUT_K}k"
else
  echo "💰 ${COST_FMT} | 📊 ${CTX_PCT}% | ↑${IN_K}k ↓${OUT_K}k"
fi
