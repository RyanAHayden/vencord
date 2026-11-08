#!/usr/bin/env bash
# Builds Vencord from source with the vimcord plugin (github.com/RyanAHayden/vimcord) in it, patches it into Discord,
# and stows these settings, the same way on macOS (run from hypr-mac) and Linux (run from dotfiles). Safe to re-run:
# it pulls both and rebuilds. Quit Discord first: it can't be patched while running, and would write its old settings back.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Vencord's source, built here; Discord loads it from dist/ (userplugins like vimcord need a source build)
SRC="${VENCORD_SRC:-${XDG_DATA_HOME:-$HOME/.local/share}/vencord-src}"

if [ "$(uname)" = Darwin ]; then
	T="$HOME/Library/Application Support/Vencord/settings"
	CLI=VencordInstallerCli-darwin
	RES=(/Applications/Discord.app/Contents/Resources)
	running() { pgrep -xq Discord; }
	command -v stow >/dev/null || brew install stow
	command -v node >/dev/null || brew install node
	command -v pnpm >/dev/null || brew install pnpm
else
	T="${XDG_CONFIG_HOME:-$HOME/.config}/Vencord/settings"
	CLI=VencordInstallerCli-linux
	# Discord's updater installs into ~/.config/discord/app-<version>; older packages used /opt or /usr/share
	RES=("$HOME"/.config/discord/app-*/resources /opt/discord/resources /usr/share/discord/resources)
	running() { pgrep -x Discord >/dev/null; }
	command -v stow >/dev/null || sudo pacman -S --needed stow
	command -v node >/dev/null || sudo pacman -S --needed nodejs
	command -v pnpm >/dev/null || sudo pacman -S --needed pnpm
fi

echo "==> vencord: build from source with vimcord ($SRC)"
pull() { git -C "$1" pull -q --ff-only || echo "  couldn't update $1, building what's there"; }
if [ -d "$SRC/.git" ]; then pull "$SRC"; else git clone -q --depth 1 https://github.com/Vendicated/Vencord "$SRC"; fi
P="$SRC/src/userplugins/vimcord"
if [ -d "$P/.git" ]; then pull "$P"; else git clone -q https://github.com/RyanAHayden/vimcord "$P"; fi
# quiet when it works, the build's own output when it doesn't
(cd "$SRC" && pnpm install --frozen-lockfile --silent && { out=$(pnpm build 2>&1) || { echo "$out"; exit 1; }; })

# Discord updates replace the patched app.asar (the original is kept as _app.asar while Vencord is in). Patched by
# anything but this build (the stock installer's download, an old location), it's unpatched and patched again.
echo "==> vencord: patch Discord"
res=
for r in "${RES[@]}"; do [ -d "$r" ] && res=$r; done
if [ -z "$res" ]; then
	echo "  Discord isn't installed, skipping (open it once after installing, then re-run)"
elif [ -e "$res/_app.asar" ] && grep -aqF "$SRC/dist" "$res/app.asar"; then
	echo "  already patched"
elif running; then
	echo "  Discord is running: quit it fully and re-run to patch it"
else
	tmp=$(mktemp -d)
	curl -fsSL -o "$tmp/$CLI" "https://github.com/Vencord/Installer/releases/latest/download/$CLI"
	chmod +x "$tmp/$CLI"
	sudo=; [ -w "$res" ] || sudo=sudo
	# the install the installer wants: Discord.app on macOS, the folder holding resources/ on Linux
	loc=${res%/Contents/Resources}; [ "$loc" != "$res" ] || loc=$(dirname "$res")
	# what `pnpm inject` does: a dev install, which points Discord at $SRC/dist instead of downloading Vencord
	inst() { $sudo env VENCORD_USER_DATA_DIR="$SRC" VENCORD_DEV_INSTALL=1 "$tmp/$CLI" "$@" -location "$loc"; }
	[ -e "$res/_app.asar" ] && inst -uninstall
	inst -install
	rm -rf "$tmp"
fi

echo "==> vencord: stow settings into $T"
mkdir -p "$T"
linked=
for f in settings.json quickCss.css; do
	[ -L "$T/$f" ] && [ "$(realpath "$T/$f" 2>/dev/null)" = "$(realpath "$REPO/settings/$f")" ] && continue
	linked=1
	# real files (Vencord's defaults) and links from before this used stow go to .bak / away
	if [ -L "$T/$f" ]; then rm "$T/$f"; elif [ -e "$T/$f" ]; then mv "$T/$f" "$T/$f.bak"; fi
done
# linked, not copied: Vencord rewrites settings.json in place (writeFileSync follows the link), so changes made in
# its settings land here
stow -d "$REPO" -t "$T" --no-folding -R settings
[ -n "$linked" ] && running && echo "  Discord is running: quit it fully and reopen to apply (it would write its old settings back)"
echo "==> vencord: done"
