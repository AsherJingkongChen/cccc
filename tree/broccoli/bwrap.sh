#!/bin/bash
# bwrap wrapper: inject GPU devices, strip network isolation.

GPU=()
for p in /dev/nvidia* /proc/driver/nvidia; do
  [ -e "$p" ] && GPU+=(--dev-bind "$p" "$p")
done

ALL=("$@")
ARGS=()
i=0
while [ $i -lt ${#ALL[@]} ]; do
  a="${ALL[$i]}"
  case "$a" in
    --unshare-net) ;;
    --setenv)
      key="${ALL[$((i+1))]}"
      val="${ALL[$((i+2))]}"
      case "$key" in *[Pp][Rr][Oo][Xx][Yy]*) i=$((i+2)) ;; *) ARGS+=("$a" "$key" "$val"); i=$((i+2)) ;; esac
      ;;
    --) ARGS+=("${GPU[@]}" "$a") ;;
    *) ARGS+=("$a") ;;
  esac
  i=$((i+1))
done

exec /usr/bin/bwrap.real "${ARGS[@]}"