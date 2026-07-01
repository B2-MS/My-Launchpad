#!/usr/bin/env python3
"""Migrate Copilot chat history between VS Code workspace-storage SQLite stores.

Background
----------
VS Code stores chat history per workspace under:

    ~/Library/Application Support/<App>/User/workspaceStorage/<hash>/

Each store has:
  - state.vscdb            (SQLite; key 'chat.ChatSessionStore.index' lists sessions)
  - chatSessions/*.jsonl   (the actual conversation content, keyed by sessionId)
  - chatEditingSessions/*  (edit session state, keyed by sessionId)
  - GitHub.copilot-chat/*  (chat session resources)

The history panel reads the SQLite *index*. Copying jsonl files alone is not
enough — the index rows must also be merged. This script does both.

Safety
------
- The TARGET app MUST be fully quit, otherwise VS Code overwrites state.vscdb on
  exit. The script refuses to write to a target whose app is running.
- The target state.vscdb is backed up before any change.
- Merges are additive: existing target sessions are preserved; source sessions
  are added (source wins on duplicate sessionId).

Usage
-----
    python3 migrate_chat_history.py            # apply
    python3 migrate_chat_history.py --dry-run  # show plan only
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import sqlite3
import subprocess
import sys
import time

HOME = os.path.expanduser("~")
APP_STORAGE = {
    "code": os.path.join(
        HOME, "Library/Application Support/Code/User/workspaceStorage"
    ),
    "insiders": os.path.join(
        HOME, "Library/Application Support/Code - Insiders/User/workspaceStorage"
    ),
}
APP_MAIN_BINARY = {
    "code": "/Applications/Visual Studio Code.app/Contents/MacOS/Code",
    "insiders": "/Applications/Visual Studio Code - Insiders.app/Contents/MacOS/Code - Insiders",
}

INDEX_KEY = "chat.ChatSessionStore.index"
CONTENT_DIRS = ["chatSessions", "chatEditingSessions", "GitHub.copilot-chat"]

# --- Discovered configuration (My Launchpad) --------------------------------
# Sources hold the real history (VS Code Stable, OneDrive-path workspaces).
SOURCES = [
    ("code", "6d201ac8e78e625c64c45854f6bc5a1f"),  # 17 sessions
    ("code", "d06a1c555e17763694ff224a4eabf858"),  # 3 sessions
]
# Targets are the local-path workspace (same hash in both apps).
TARGETS = [
    ("code", "fd32d3ebdc14a68391e3a0e75203a9cc"),
    ("insiders", "fd32d3ebdc14a68391e3a0e75203a9cc"),
]


def app_running(app: str) -> bool:
    """True if the app's MAIN process is running (ignores Helper/Crashpad procs)."""
    binary = APP_MAIN_BINARY[app]
    try:
        out = subprocess.run(
            ["ps", "-axo", "command"], capture_output=True, text=True, timeout=10
        ).stdout
    except Exception:  # noqa: BLE001
        return False
    for line in out.splitlines():
        stripped = line.strip()
        # Main process arg0 is exactly the binary, optionally followed by a space + args.
        if stripped == binary or stripped.startswith(binary + " "):
            if "Helper" not in line and "Crashpad" not in line:
                return True
    return False


def store_path(app: str, wshash: str) -> str:
    return os.path.join(APP_STORAGE[app], wshash)


def read_index(db_path: str) -> dict:
    if not os.path.exists(db_path):
        return {"version": 1, "entries": {}}
    con = sqlite3.connect(db_path)
    try:
        row = con.execute(
            "SELECT value FROM ItemTable WHERE key=?", (INDEX_KEY,)
        ).fetchone()
    finally:
        con.close()
    if not row or not row[0]:
        return {"version": 1, "entries": {}}
    try:
        data = json.loads(row[0])
    except Exception:  # noqa: BLE001
        return {"version": 1, "entries": {}}
    data.setdefault("version", 1)
    data.setdefault("entries", {})
    return data


def write_index(db_path: str, index: dict) -> None:
    con = sqlite3.connect(db_path)
    try:
        con.execute(
            "INSERT INTO ItemTable(key,value) VALUES(?,?) "
            "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
            (INDEX_KEY, json.dumps(index, separators=(",", ":"))),
        )
        con.commit()
    finally:
        con.close()


def copy_content(src_store: str, dst_store: str, dry: bool) -> int:
    copied = 0
    for sub in CONTENT_DIRS:
        s = os.path.join(src_store, sub)
        if not os.path.isdir(s):
            continue
        d = os.path.join(dst_store, sub)
        for name in os.listdir(s):
            sp = os.path.join(s, name)
            dp = os.path.join(d, name)
            if dry:
                copied += 1
                continue
            os.makedirs(d, exist_ok=True)
            if os.path.isdir(sp):
                shutil.copytree(sp, dp, dirs_exist_ok=True)
            else:
                shutil.copy2(sp, dp)
            copied += 1
    return copied


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true", help="show plan, change nothing")
    args = ap.parse_args()

    ts = time.strftime("%Y%m%d-%H%M%S")
    overall_ok = True

    # Gather source indexes up front.
    src_indexes = []
    for app, h in SOURCES:
        sp = store_path(app, h)
        idx = read_index(os.path.join(sp, "state.vscdb"))
        src_indexes.append((app, h, sp, idx))
        print(f"SOURCE [{app}] {h}: {len(idx['entries'])} sessions")

    for app, h in TARGETS:
        tp = store_path(app, h)
        db = os.path.join(tp, "state.vscdb")
        print(f"\n=== TARGET [{app}] {h} ===")
        if not os.path.isdir(tp):
            print(f"  target store missing: {tp} — skipping")
            continue

        if app_running(app):
            print(f"  ⚠️  {app} is RUNNING — quit it fully, then re-run. Skipping.")
            overall_ok = False
            continue

        before = read_index(db)
        merged = {"version": before.get("version", 1), "entries": dict(before["entries"])}

        total_new = 0
        for s_app, s_h, s_path, s_idx in src_indexes:
            new_here = 0
            for sid, meta in s_idx["entries"].items():
                if sid not in merged["entries"]:
                    new_here += 1
                merged["entries"][sid] = meta
            total_new += new_here
            n = copy_content(s_path, tp, args.dry_run)
            print(f"  from [{s_app}] {s_h}: +{new_here} index, {n} content items copied")

        if args.dry_run:
            print(
                f"  DRY-RUN: would grow index {len(before['entries'])} -> "
                f"{len(merged['entries'])} (+{total_new})"
            )
            continue

        # Backup then write.
        if os.path.exists(db):
            bak = f"{db}.premigrate-{ts}"
            shutil.copy2(db, bak)
            print(f"  backup: {bak}")
        write_index(db, merged)
        after = read_index(db)
        print(
            f"  index updated: {len(before['entries'])} -> {len(after['entries'])} sessions"
        )

    print("\nDONE" + ("" if overall_ok else " (some targets skipped — see warnings)"))
    return 0 if overall_ok else 2


if __name__ == "__main__":
    sys.exit(main())
