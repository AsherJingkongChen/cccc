#!/usr/bin/env python3
import json
import os
import sys
from datetime import datetime, timezone

input_data = json.load(sys.stdin)
tp = input_data.get("transcript_path", "")

parts = []
parts += [datetime.now(timezone.utc).astimezone().replace(microsecond=0).isoformat()]
parts += [os.getcwd()]

if tp and os.path.exists(tp):
    last_usage = None
    with open(tp) as f:
        for line in f:
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue
            if row.get("type") == "assistant":
                u = row.get("message", {}).get("usage")
                if u:
                    last_usage = u

    if last_usage:
        usage = (
            last_usage.get("input_tokens", 0)
            + last_usage.get("cache_creation_input_tokens", 0)
            + last_usage.get("cache_read_input_tokens", 0)
        )
        window = int(os.environ.get("CLAUDE_CODE_AUTO_COMPACT_WINDOW", 1_000_000))
        usage_label = "Memorizing" if usage / window > 0.95 else "Low"
        parts.append(f"{usage} tokens used ({usage_label})")

print(" | ".join(parts))
