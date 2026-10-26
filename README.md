# dotfiles

Personal Hyprland desktop configuration managed with [chezmoi](https://www.chezmoi.io/).

## What's inside

- **Quickshell** — custom bar, dock, launcher, clipboard, OSD
- **Hyprland** — window manager config (Lua + fallback conf)
- **kitty** — terminal + quick-access dropdown
- **swaync** — notification center
- **btop** — system monitor theme
- **lazygit** — git TUI config
- **zsh** — terminal tools (fzf, eza, bat, zoxide, yazi)
- **Scripts** — `mugzx-*` utilities and `snap` for btrfs snapshots

## Install

```bash
chezmoi init --apply git@github.com:Neomelt/dotfiles.git
```

> The age key (`~/.config/chezmoi/age-key.txt`) is not included — keep it backed up separately.

## Sync changes

After editing a config file, sync it to the repo and push:

```bash
chezmoi re-add ~/.config/hypr/hyprland.lua   # sync one file
chezmoi cd                                   # enter repo directory
lg                                           # commit with lazygit (or git add -A && git commit && git push)
exit
```
