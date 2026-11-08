# vencord

One Vencord setup shared by macOS ([hypr-mac](https://github.com/RyanAHayden/hypr-mac)) and Linux ([dotfiles](https://github.com/RyanAHayden/dotfiles)), both of which clone this to `~/vencord` and run `setup.sh`. Taken from the Vencord settings on omarchy-desktop.

`setup.sh` patches Vencord into Discord with the official VencordInstallerCli when it isn't (Discord updates undo it, so re-run after one), then links `settings.json` and `quickCss.css` into Vencord's settings folder (`~/Library/Application Support/Vencord/settings` / `~/.config/Vencord/settings`), moving any existing ones to `.bak`. Vencord writes changes made in its settings straight through the link, so they show up here to commit.

What's in it:
- plugins: AlwaysExpandRoles, Dearrow, FakeNitro, FixSpotifyEmbeds, FixYoutubeEmbeds, GameActivityToggle, NoF1, NoOnboardingDelay, NoTrack (and the APIs they need)
- theme: [system24](https://github.com/refact0r/system24) (auto flavor), by link
- `disableMinSize`: Discord's ~940px minimum width is off, so it tiles in a narrow column (yabai/Hyprland)

Quit Discord before running `setup.sh`: it can't be patched while running, and would write its old settings back.
