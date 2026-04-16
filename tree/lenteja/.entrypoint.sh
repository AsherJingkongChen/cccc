#!/bin/bash
set -euo pipefail

(
  set -a
  source .claude/.litellm/.env
  set +a
  litellm --config .claude/.litellm/config.yaml --host 127.0.0.1 > /dev/null 2>&1
) &

sleep 5

claude --channels plugin:discord@claude-plugins-official
