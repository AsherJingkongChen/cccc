#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
NAME="broccoli"

case "${1:-}" in
  build)
    docker build -t "$NAME" "$DIR"
    ;;
  init)
    docker rm "$NAME" 2>/dev/null || true
    docker run -it \
      --privileged \
      --gpus all \
      --memory=16g --cpus=8 \
      --name "$NAME" \
      "$NAME"
    ;;
  start)
    docker start -ai "$NAME"
    ;;
  stop)
    docker stop "$NAME"
    ;;
  export)
    docker cp "$NAME:/home/agent/.claude/." "$DIR/.claude"
    docker cp "$NAME:/home/agent/.claude.json" "$DIR/.claude.json"
    chown -R "$(id -u):$(id -g)" "$DIR/.claude"
    ;;
  clear)
    docker rm "$NAME" >/dev/null 2>&1
    docker rmi "$NAME" >/dev/null 2>&1
    ;;
  *)
    echo "usage: $0 {build|init|start|stop|clear}"
    ;;
esac

