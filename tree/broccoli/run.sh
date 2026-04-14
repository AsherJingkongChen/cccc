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
    rm -rf "$DIR/.claude" "$DIR/.claude.json" "$DIR/work"
    docker cp "$NAME:/home/agent/.claude/." "$DIR/.claude"
    docker cp "$NAME:/home/agent/.claude.json" "$DIR/.claude.json"
    docker cp "$NAME:/home/agent/work/." "$DIR/work"
    chown -R "$(id -u):$(id -g)" "$DIR/.claude" "$DIR/.claude.json" "$DIR/work"
    ;;
  clear)
    docker rm "$NAME" >/dev/null 2>&1
    docker rmi "$NAME" >/dev/null 2>&1
    ;;
  *)
    echo "usage: $0 {build|init|start|stop|export|clear}"
    ;;
esac

