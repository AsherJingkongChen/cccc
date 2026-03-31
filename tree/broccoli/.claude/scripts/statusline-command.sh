#!/bin/bash

# Debug: set to 1 to enable debug logging
DEBUG=0
DEBUG_LOG="$HOME/.claude/statusline-debug.log"

# Read Claude Code context
input=$(cat)

# Debug: Log input JSON and processing steps
if [[ $DEBUG -eq 1 ]]; then
    jq . <<< "$input" > "$DEBUG_LOG"
fi

# Extract JSON values
current_dir=$(jq -r '.workspace.current_dir // .cwd' <<< "$input")
total_lines_added=$(jq -r '.cost.total_lines_added // 0' <<< "$input")
total_lines_removed=$(jq -r '.cost.total_lines_removed // 0' <<< "$input")
total_cost_usd=$(jq -r '.cost.total_cost_usd // 0' <<< "$input")
rate_5h=$(jq -r '.rate_limits.five_hour.used_percentage // 0 | round' <<< "$input")
rate_7d=$(jq -r '.rate_limits.seven_day.used_percentage // 0 | round' <<< "$input")

# Calculate derived variables
total_cost_usd=$(printf "%.2f" "$total_cost_usd")
current_dir_name="@${current_dir##*/}/"
current_date_time=$(date '+%m-%d %H:%M')

# Output the status line using printf with colors
printf "\033[0m"
printf "\033[1;38;5;223m✻\033[0m "
printf "\033[1;38;5;173m%s\033[0m " "$current_date_time"
printf "\033[1;38;5;223m❱\033[0m "
printf "\033[1;38;5;178m%s\033[0m " "$current_dir_name"
printf "\033[1;38;5;223m❱\033[0m "
printf "\033[1;38;5;111m$%s\033[0m " "$total_cost_usd"
printf "\033[1;38;5;223m❱\033[0m "
printf "\033[1;38;5;118m+%s\033[0m " "$total_lines_added"
printf "\033[1;38;5;202m-%s\033[0m " "$total_lines_removed"
printf "\033[1;38;5;223m❱\033[0m "
printf "\033[1;38;5;175m%s%% 5h\033[0m " "$rate_5h"
printf "\033[1;38;5;223m❱\033[0m "
printf "\033[1;38;5;114m%s%% 7d\033[0m " "$rate_7d"
printf "\033[0m"
