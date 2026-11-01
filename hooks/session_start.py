#!/usr/bin/env python3
"""Provide coding guidelines as additional context at session start."""

import json
import os
import re
import sys
from pathlib import Path

SKILL_NAMES = ("karpathy-guidelines", "coding-principles")


def find_skill_path(skill_name: str, script_path: Path, plugin_root) -> Path:
    candidates = []
    if plugin_root:
        candidates.append(Path(plugin_root) / "skills" / skill_name / "SKILL.md")
    candidates.append(script_path.parents[1] / "skills" / skill_name / "SKILL.md")
    candidates.extend(
        parent / ".agents" / "skills" / skill_name / "SKILL.md"
        for parent in script_path.parents
    )
    return next((path for path in candidates if path.is_file()), candidates[0])


def read_skill(skill_name: str, script_path: Path, plugin_root) -> str:
    skill_path = find_skill_path(skill_name, script_path, plugin_root)
    skill = skill_path.read_text(encoding="utf-8")
    instructions = re.sub(
        r"\A---\s*\n.*?\n---\s*\n", "", skill, count=1, flags=re.DOTALL
    ).strip()
    if not instructions:
        raise ValueError(f"No guideline text found in {skill_path}")
    return instructions


def main() -> int:
    try:
        hook_input = sys.stdin.read()
        if hook_input.strip():
            json.loads(hook_input)

        script_path = Path(__file__).resolve()
        plugin_root = os.environ.get("CLAUDE_PLUGIN_ROOT") or os.environ.get("PLUGIN_ROOT")
        sections = [
            f"## {skill_name.replace('-', ' ').title()}\n\n"
            f"{read_skill(skill_name, script_path, plugin_root)}"
            for skill_name in SKILL_NAMES
        ]
        context = (
            "Apply these coding guidelines throughout this session. "
            "They complement the repository's own instructions:\n\n"
            + "\n\n".join(sections)
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
