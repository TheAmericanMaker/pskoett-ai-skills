#!/usr/bin/env python3
"""Sync skills/ -> plugin/skills/ with the public source as the single source of truth.

For each skill present in BOTH skills/ and plugin/skills/:
  - copy references/, scripts/, assets/ from the source skill
  - rebuild the plugin SKILL.md from the SOURCE body + SOURCE description, while
    PRESERVING the plugin-only frontmatter keys (hooks, user-invocable,
    argument-hint) that make the skill register correctly as a plugin.

This is what keeps plugin/skills/ from drifting away from skills/: body and
description always come from source; only the plugin-registration frontmatter is
allowed to differ.

Usage:
    python3 scripts/sync_plugin.py [skill-name ...]
      no args -> sync every skill present in both trees
"""
import sys
import shutil
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "skills"
DST_DIR = ROOT / "plugin" / "skills"

# Frontmatter keys that are plugin-specific (absent from the public source) and
# must be carried over from the existing plugin copy.
PLUGIN_KEYS = ["hooks", "user-invocable", "argument-hint"]
SUBDIRS = ["references", "scripts", "assets"]


def split_frontmatter(text):
    """Return (frontmatter_dict, body_str). frontmatter_dict is None if absent."""
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].strip() != "---":
        return None, text
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            fm = yaml.safe_load("".join(lines[1:i])) or {}
            body = "".join(lines[i + 1:])
            return fm, body
    return None, text


def build_skill_md(src_md: Path, dst_md: Path) -> str:
    src_fm, src_body = split_frontmatter(src_md.read_text())
    if src_fm is None:
        raise SystemExit(f"no frontmatter in {src_md}")

    dst_fm = {}
    if dst_md.exists():
        dst_fm, _ = split_frontmatter(dst_md.read_text())
        dst_fm = dst_fm or {}

    new_fm = dict(src_fm)
    if isinstance(new_fm.get("description"), str):
        new_fm["description"] = new_fm["description"].strip()
    # Carry over plugin-only registration keys that source does not define.
    for key in PLUGIN_KEYS:
        if key in dst_fm and key not in new_fm:
            new_fm[key] = dst_fm[key]

    # Stable, readable order: name, description, plugin keys, then anything else.
    ordered = {}
    for key in ["name", "description"]:
        if key in new_fm:
            ordered[key] = new_fm.pop(key)
    for key in PLUGIN_KEYS:
        if key in new_fm:
            ordered[key] = new_fm.pop(key)
    ordered.update(new_fm)

    fm_yaml = yaml.dump(
        ordered, sort_keys=False, allow_unicode=True, width=10 ** 9,
        default_flow_style=False,
    )
    return f"---\n{fm_yaml}---\n{src_body}"


def sync_skill(name: str) -> None:
    src, dst = SRC_DIR / name, DST_DIR / name
    if not src.is_dir() or not dst.is_dir():
        print(f"  SKIP {name} (not present in both trees)")
        return
    # Rebuild references/, scripts/, assets/ from source as a delete-aware mirror:
    # a file removed from the source skill must not keep shipping in the plugin.
    for sub in SUBDIRS:
        s, d = src / sub, dst / sub
        if d.exists():
            shutil.rmtree(d)
        if s.is_dir():
            shutil.copytree(s, d)
    (dst / "SKILL.md").write_text(build_skill_md(src / "SKILL.md", dst / "SKILL.md"))
    print(f"  SYNCED {name}")


def shared_skills():
    return sorted(
        p.name for p in SRC_DIR.iterdir()
        if p.is_dir() and (DST_DIR / p.name).is_dir()
    )


def main():
    targets = sys.argv[1:] or shared_skills()
    print("Syncing skills/ -> plugin/skills/")
    for name in targets:
        sync_skill(name)
    print("Done.")


if __name__ == "__main__":
    main()
