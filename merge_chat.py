import json
import sqlite3
import os

old_db = os.path.expanduser("~/Library/Application Support/Code/User/workspaceStorage/6f74879cd4cd5dafeff9e03e74c3d4a1/state.vscdb")
new_db = os.path.expanduser("~/Library/Application Support/Code/User/workspaceStorage/6d201ac8e78e625c64c45854f6bc5a1f/state.vscdb")

# Get old index
conn_old = sqlite3.connect(old_db)
old_index = json.loads(conn_old.execute("SELECT value FROM ItemTable WHERE key='chat.ChatSessionStore.index'").fetchone()[0])
conn_old.close()

# Get new index
conn_new = sqlite3.connect(new_db)
new_index = json.loads(conn_new.execute("SELECT value FROM ItemTable WHERE key='chat.ChatSessionStore.index'").fetchone()[0])

# Merge entries (new takes precedence)
merged_entries = {**old_index['entries'], **new_index['entries']}
merged_index = {"version": 1, "entries": merged_entries}

# Update new database
merged_json = json.dumps(merged_index)
conn_new.execute("UPDATE ItemTable SET value=? WHERE key='chat.ChatSessionStore.index'", (merged_json,))
conn_new.commit()
conn_new.close()

print(f"Merged {len(old_index['entries'])} old + {len(new_index['entries'])} new = {len(merged_entries)} total sessions")
