# vencord

One Vencord setup shared by macOS ([hypr-mac](https://github.com/RyanAHayden/hypr-mac)) and Linux ([dotfiles](https://github.com/RyanAHayden/dotfiles)), both of which clone this to `~/vencord` and run `setup.sh`. Taken from the Vencord settings on omarchy-desktop.

`setup.sh` links `settings.json` and `quickCss.css` into Vencord's settings folder (`~/Library/Application Support/Vencord/settings` / `~/.config/Vencord/settings`), moving any existing ones to `.bak`. Vencord writes changes made in its settings straight through the link, so they show up here to commit.

What's in it:
- plugins: AlwaysExpandRoles, Dearrow, FakeNitro, FixSpotifyEmbeds, FixYoutubeEmbeds, GameActivityToggle, NoF1, NoOnboardingDelay, NoTrack (and the APIs they need)
- theme: [system24](https://github.com/refact0r/system24) (auto flavor), by link
- `disableMinSize`: Discord's ~940px minimum width is off, so it tiles in a narrow column (yabai/Hyprland)

Vencord has to be installed into Discord first (VencordInstaller), and Discord updates sometimes undo that; run the installer again then. Quit Discord before running `setup.sh`, or restart it after.
