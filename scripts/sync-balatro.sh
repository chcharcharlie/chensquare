#!/bin/bash
# sync-balatro.sh — Sync balatro-web/index.html → chensquare/balatro/index.html
# Runs as a cron job; only pushes if the file actually changed.

set -e

SRC="$HOME/clawspace/balatro-web/index.html"
DST="$HOME/clawspace/chensquare/balatro/index.html"
REPO="$HOME/clawspace/chensquare"

BACK_BUTTON='
<!-- Back to chensquare -->
<style>
#back-home {
  position: fixed;
  top: 10px; left: 10px; z-index: 9999;
  background: rgba(13,13,26,0.85);
  color: #7c6af7; text-decoration: none;
  font-family: system-ui, sans-serif; font-size: 0.75rem;
  padding: 5px 8px; border-radius: 6px;
  border: 1px solid rgba(124,106,247,0.3);
  backdrop-filter: blur(8px);
  overflow: hidden; max-width: 22px; white-space: nowrap;
  transition: max-width 0.25s ease, opacity 0.25s ease;
  opacity: 0.4;
}
#back-home:hover { max-width: 120px; opacity: 1; }
</style>
<a href="/" id="back-home">← chensquare</a>
'

# Copy + inject back button using Python
python3 - <<PYEOF
src = open("$SRC", "r").read()
inject = '''$BACK_BUTTON'''
if "back-home" not in src:
    src = src.replace("</body>", inject + "\n</body>")
open("$DST", "w").write(src)
PYEOF

cd "$REPO"

# Check if anything changed
if git diff --quiet balatro/index.html; then
  echo "[sync-balatro] No changes, skipping push."
  exit 0
fi

git add balatro/index.html
git commit -m "Auto-sync: update balatro from balatro-web"
git push origin main

echo "[sync-balatro] Pushed updated balatro."
