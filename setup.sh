#!/usr/bin/env bash
# Links these Vencord settings the same way on macOS (run from hypr-mac) and Linux (run from dotfiles).
# Safe to re-run. Vencord itself has to be installed into Discord first (VencordInstaller).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname)" = Darwin ]; then
	DIR="$HOME/Library/Application Support/Vencord/settings"
	running() { pgrep -xq Discord; }
else
	DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Vencord/settings"
	running() { pgrep -x Discord >/dev/null; }
fi

echo "==> vencord: settings"
mkdir -p "$DIR"
# linked, not copied: Vencord rewrites settings.json in place (writeFileSync follows the link), so changes made in
# its settings land here
for f in settings.json quickCss.css; do
	[ -e "$DIR/$f" ] && [ ! -L "$DIR/$f" ] && mv "$DIR/$f" "$DIR/$f.bak"
	ln -sfn "$REPO/$f" "$DIR/$f"
done
running && echo "  Discord is running: quit it fully and reopen to apply (it would write its old settings back)"
echo "==> vencord: done"
