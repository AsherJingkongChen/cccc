#!/bin/bash
# Wrapper: replace bwrap with sandbox-lite (mount namespace only, no seccomp).

# Extract command after -- (skip apply-seccomp if present)
CMD=()
found=false
for a in "$@"; do
  if $found; then
    CMD+=("$a")
  elif [ "$a" = "--" ]; then
    found=true
  fi
done
# Strip apply-seccomp from embedded shell script
for i in "${!CMD[@]}"; do
  CMD[$i]="$(echo "${CMD[$i]}" | sed 's|ARGV0=apply-seccomp /proc/self/fd/[0-9]* ||g')"
done
exec /usr/bin/sandbox-lite "${CMD[@]}"
