# vencord

One Vencord setup shared by macOS ([hypr-mac](https://github.com/RyanAHayden/hypr-mac)) and Linux ([dotfiles](https://github.com/RyanAHayden/dotfiles)), both of which clone this to `~/vencord` and run `setup.sh`. Taken from the Vencord settings on omarchy-desktop.

`setup.sh` builds Vencord from source in `~/repos/Vencord` (`$VENCORD_SRC` to move it), the checkout vimcord is worked on in, with the [vimcord](https://github.com/RyanAHayden/vimcord) plugin cloned into its `src/userplugins`, pulling both first, so re-running updates them. It installs node and pnpm if they're missing. It patches that build into Discord with the official VencordInstallerCli, the way `pnpm inject` does: a Discord patched any other way (the stock download) is unpatched and patched again, and Discord updates undo the patch, so re-run after one. Then it stows `settings/` (`settings.json`, `quickCss.css`) into Vencord's settings folder (`~/Library/Application Support/Vencord/settings` / `~/.config/Vencord/settings`), moving Vencord's own files there to `.bak`. Vencord writes changes made in its settings straight through the link, so they show up here to commit.

What's in it:
- [vimcord](https://github.com/RyanAHayden/vimcord): vim-style keys, panes, modes and an nvim look in nvim's own colors (Omarchy's current theme on Linux)
- plugins: AlwaysExpandRoles, Dearrow, FakeNitro, FixSpotifyEmbeds, FixYoutubeEmbeds, GameActivityToggle, NoF1, NoOnboardingDelay, NoTrack (and the APIs they need)
- `disableMinSize`: Discord's ~940px minimum width is off, so it tiles in a narrow column (yabai/Hyprland)

Quit Discord before running `setup.sh`: it can't be patched while running, and would write its old settings back.
