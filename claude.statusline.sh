#!/bin/bash
input=$(cat)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

COST_FMT=$(printf '$%.3f' "$COST")

echo "💰 ${COST_FMT} | 📊 ctx ${USED_PCT}%"
