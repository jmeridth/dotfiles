#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" branch --show-current 2>/dev/null)
printf "%s" "$cwd"
[ -n "$branch" ] && printf " \033[36m(%s)\033[0m" "$branch"
[ -n "$model" ] && printf " \033[33m[%s]\033[0m" "$model"
