#!/usr/bin/env python3
"""Path guard: deny file tools from accessing .claude directories."""

from pathlib import Path
import json
import sys

DENY = (
    Path("/home/agent/.claude.json"),
    Path("/home/agent/.claude/.credentials.json"),
    Path("/home/agent/.claude/.litellm"),
    Path("/home/agent/.claude/CLAUDE.md"),
    Path("/home/agent/.claude/channels/discord/.env"),
    Path("/home/agent/.claude/history.jsonl"),
    Path("/home/agent/.claude/hooks"),
    Path("/home/agent/.claude/scripts"),
    Path("/home/agent/.claude/settings.json"),
    Path("/home/agent/.claude/settings.local.json"),
    Path("/home/agent/.entrypoint.sh"),
)

data = json.load(sys.stdin)
inp = data.get("tool_input", {})
tool = data.get("tool_name", "")

TOOL_KEYS = {
    "Edit": ("file_path",),
    "Glob": ("path", "pattern"),
    "Grep": ("glob", "path", "pattern"),
    "Read": ("file_path",),
    "Write": ("file_path",),
}

if tool not in TOOL_KEYS:
    sys.exit(0)

def denied(p):
    """Check if a resolved path overlaps any DENY path."""
    return any(p.is_relative_to(d) or d.is_relative_to(p) for d in DENY)

def hits_deny(val=None, base=None):
    """Check if val (path, glob, or None) could reach any DENY path."""
    root = Path(base).resolve() if base else Path.cwd()
    if not val:
        return denied(root)
    p = Path(val)
    if p.is_absolute():
        root, val = Path(p.anchor), str(p.relative_to(p.anchor))
    return denied((root / val).resolve()) or any(denied(m.resolve()) for m in root.glob(val))

base = inp.get("path")
for key in TOOL_KEYS[tool]:
    val = inp.get(key)
    try:
        d = hits_deny(val, base)
    except Exception as _:
        d = True
    if d:
        print(f"DENIED. {key}={val}", file=sys.stderr)
        sys.exit(2)
