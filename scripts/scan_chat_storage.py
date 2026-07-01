#!/usr/bin/env python3
"""Scan all VS Code / Insiders workspace storage for chat history content.

Read-only diagnostic: lists every workspace storage entry, the folder it maps
to, how many chatSessions files exist, their sizes, and how many sessions the
state.vscdb index registers. Used to locate any DB holding real chat history.
"""
import os
import glob
import json
import subprocess

BASES = [
    ('/Users/barticus/Library/Application Support/Code/User/workspaceStorage', 'code'),
    ('/Users/barticus/Library/Application Support/Code - Insiders/User/workspaceStorage', 'insiders'),
]


def sqlite_val(db, key):
    try:
        return subprocess.run(
            ['/usr/bin/sqlite3', db, f"SELECT value FROM ItemTable WHERE key='{key}';"],
            capture_output=True, text=True, timeout=20,
        ).stdout.strip()
    except Exception as exc:  # noqa: BLE001
        return f"ERR:{exc}"


def main():
    rows = []
    for base, app in BASES:
        for wsdir in sorted(glob.glob(os.path.join(base, '*'))):
            if not os.path.isdir(wsdir):
                continue
            ws = os.path.basename(wsdir)

            folder = '?'
            wj = os.path.join(wsdir, 'workspace.json')
            if os.path.exists(wj):
                try:
                    folder = json.load(open(wj)).get('folder', '?')
                except Exception:  # noqa: BLE001
                    folder = '(bad json)'

            csdir = os.path.join(wsdir, 'chatSessions')
            nfiles, total, biggest = 0, 0, 0
            if os.path.isdir(csdir):
                for f in glob.glob(os.path.join(csdir, '*')):
                    if os.path.isfile(f):
                        nfiles += 1
                        sz = os.path.getsize(f)
                        total += sz
                        biggest = max(biggest, sz)

            db = os.path.join(wsdir, 'state.vscdb')
            nidx = 0
            if os.path.exists(db):
                v = sqlite_val(db, 'chat.ChatSessionStore.index')
                if v and not v.startswith('ERR'):
                    try:
                        nidx = len(json.loads(v).get('entries', {}))
                    except Exception:  # noqa: BLE001
                        pass

            interesting = (
                'launchpad' in folder.lower()
                or nfiles > 0
                or nidx > 0
                or total > 10000
            )
            if interesting:
                rows.append((app, ws, folder, nfiles, total, biggest, nidx))

    header = f"{'app':9} {'files':>5} {'totalKB':>9} {'bigKB':>8} {'idx':>4}  folder"
    print(header)
    for app, ws, folder, nfiles, total, biggest, nidx in rows:
        short = folder.replace('file://', '').replace('%20', ' ')
        if short != '?':
            short = '/'.join(short.split('/')[-2:])
        print(f"{app:9} {nfiles:>5} {total/1024:>9.0f} {biggest/1024:>8.0f} {nidx:>4}  {short}")
    print(f"\nTotal interesting workspaces: {len(rows)}")


if __name__ == '__main__':
    main()
