#!/usr/bin/env python3
import json, os, sys
from datetime import datetime, timezone

input_data = json.load(sys.stdin)
ts = datetime.now(timezone.utc).astimezone().replace(microsecond=0).isoformat()
tp = input_data.get("transcript_path", "")

parts = [ts]

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
        total = (
            last_usage.get("input_tokens", 0)
            + last_usage.get("cache_creation_input_tokens", 0)
            + last_usage.get("cache_read_input_tokens", 0)
        )
        window = int(os.environ.get("CLAUDE_AUTO_COMPACT_WINDOW", 1_000_000))
        pct = total / window * 100
        parts.append(f"tok:{total}({pct:.0f}%)")

print(" | ".join(parts))
