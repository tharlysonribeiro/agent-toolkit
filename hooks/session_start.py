#!/usr/bin/env python3
"""Provide the Karpathy skill as additional context at session start."""

import json
import os
import re
import sys
from pathlib import Path


def main() -> int:
    try:
        hook_input = sys.stdin.read()
        if hook_input.strip():
            json.loads(hook_input)

        script_path = Path(__file__).resolve()
        plugin_root = os.environ.get("CLAUDE_PLUGIN_ROOT") or os.environ.get("PLUGIN_ROOT")
        candidates = []
        if plugin_root:
            candidates.append(
                Path(plugin_root) / "skills" / "karpathy-guidelines" / "SKILL.md"
            )
        candidates.extend(
            [
                script_path.parents[1] / "skills" / "karpathy-guidelines" / "SKILL.md",
                *[
                    parent / ".agents" / "skills" / "karpathy-guidelines" / "SKILL.md"
                    for parent in script_path.parents
                ],
            ]
        )
        skill_path = next((path for path in candidates if path.is_file()), candidates[0])
        skill = skill_path.read_text(encoding="utf-8")
        instructions = re.sub(
            r"\A---\s*\n.*?\n---\s*\n", "", skill, count=1, flags=re.DOTALL
        ).strip()
        if not instructions:
            raise ValueError(f"No guideline text found in {skill_path}")

        context = (
            "Apply these Karpathy-inspired coding guidelines throughout this session. "
            "They complement the repository's own instructions:\n\n"
            f"{instructions}"
        )
        json.dump(
            {
                "hookSpecificOutput": {
                    "hookEventName": "SessionStart",
                    "additionalContext": context,
                }
            },
            sys.stdout,
            ensure_ascii=False,
        )
        sys.stdout.write("\n")
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Karpathy guidelines hook failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
