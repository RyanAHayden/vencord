#!/usr/bin/env bash
# Links these Vencord settings the same way on macOS (run from hypr-mac) and Linux (run from dotfiles).
# Safe to re-run. Quit Discord first: it can't be patched while running, and would write its old settings back.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(uname)" = Darwin ]; then
	DIR="$HOME/Library/Application Support/Vencord/settings"
	RES=/Applications/Discord.app/Contents/Resources
	CLI=VencordInstallerCli-darwin SUDO=
	running() { pgrep -xq Discord; }
else
	DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Vencord/settings"
	RES=/opt/discord/resources
	CLI=VencordInstallerCli-linux SUDO=sudo
	running() { pgrep -x Discord >/dev/null; }
fi

# Discord updates replace the patched app.asar (the original is kept as _app.asar while Vencord is in)
echo "==> vencord: patch Discord"
if [ ! -d "$RES" ]; then
	echo "  Discord isn't installed ($RES), skipping"
elif [ -e "$RES/_app.asar" ]; then
	echo "  already patched"
elif running; then
	echo "  Discord is running: quit it fully and re-run to patch it"
else
	tmp=$(mktemp -d)
	curl -fsSL -o "$tmp/$CLI" "https://github.com/Vencord/Installer/releases/latest/download/$CLI"
	chmod +x "$tmp/$CLI"
	$SUDO "$tmp/$CLI" -install -branch stable
	rm -rf "$tmp"
fi

echo "==> vencord: settings"
mkdir -p "$DIR"
# linked, not copied: Vencord rewrites settings.json in place (writeFileSync follows the link), so changes made in
# its settings land here
linked=
for f in settings.json quickCss.css; do
	[ "$(readlink "$DIR/$f" 2>/dev/null)" = "$REPO/$f" ] && continue
	[ -e "$DIR/$f" ] && [ ! -L "$DIR/$f" ] && mv "$DIR/$f" "$DIR/$f.bak"
	ln -sfn "$REPO/$f" "$DIR/$f"
	linked=1
done
[ -n "$linked" ] && running && echo "  Discord is running: quit it fully and reopen to apply (it would write its old settings back)"
echo "==> vencord: done"
