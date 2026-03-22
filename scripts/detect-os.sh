#!/bin/bash
# Detect operating system and hostname.
# Source this file to set OS_TYPE, IS_DEBIAN, HOSTNAME_TYPE variables.

OS_TYPE="$(uname)"
IS_DEBIAN=false
HOSTNAME_TYPE="unknown"

WORK_HOSTNAME="Jasons-MacBook-Pro-CG"
PERSONAL_HOSTNAME="Jasons-MacBook-Pro"

if [[ "$OS_TYPE" == "Linux" ]] && [ -f /etc/debian_version ]; then
  IS_DEBIAN=true
fi

CURRENT_HOSTNAME="$(hostname)"
if [[ "$CURRENT_HOSTNAME" == "$WORK_HOSTNAME" ]]; then
  HOSTNAME_TYPE="work"
elif [[ "$CURRENT_HOSTNAME" == "$PERSONAL_HOSTNAME" ]]; then
  HOSTNAME_TYPE="personal"
fi
