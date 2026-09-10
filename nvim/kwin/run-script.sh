#!/usr/bin/env bash
# Loads, runs, and unloads a one-shot KWin script via D-Bus. Used by the
# typst preview keymap (config/autocmds.lua) to tile windows; silently a
# no-op anywhere gdbus/KWin's scripting interface isn't available.
set -euo pipefail

script="$1"
name="claude-cp-$$-$RANDOM"

out=$(gdbus call --session --dest org.kde.KWin --object-path /Scripting \
  --method org.kde.kwin.Scripting.loadScript "$script" "$name" 2>/dev/null) || exit 0

id=$(grep -oE '[0-9]+' <<<"$out" | head -1)
[ -n "$id" ] || exit 0

gdbus call --session --dest org.kde.KWin --object-path "/Scripting/Script$id" \
  --method org.kde.kwin.Script.run >/dev/null 2>&1 || true

gdbus call --session --dest org.kde.KWin --object-path /Scripting \
  --method org.kde.kwin.Scripting.unloadScript "$name" >/dev/null 2>&1 || true
