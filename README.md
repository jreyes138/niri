# dotfiles

GNU Stow-managed dotfiles for niri + wezterm + waybar + fuzzel + mako +
swaylock + wlogout + yazi + bash + git on Fedora 44.

## Structure

Each directory is a stow "package" that mirrors paths relative to `$HOME`:

```
niri/       .config/niri/config.kdl
waybar/     .config/waybar/{config,style.css}
wezterm/    .wezterm.lua
fuzzel/     .config/fuzzel/fuzzel.ini
mako/       .config/mako/config
swaylock/   .config/swaylock/config
wlogout/    .config/wlogout/{layout,style.css}
yazi/       .config/yazi/yazi.toml
bash/       .bashrc, .bash_profile
git/        .gitconfig
bin/        .local/bin/{niri-theme,y}
```

## Install

```bash
git clone https://github.com/JOSER/dotfiles ~/dotfiles
cd ~/dotfiles
stow niri waybar wezterm fuzzel mako swaylock wlogout yazi bash git bin
```

## Uninstall

```bash
cd ~/dotfiles
stow -D niri waybar wezterm fuzzel mako swaylock wlogout yazi bash git bin
```

## Themes

`niri-theme` script switches between gruvbox, catppuccin, nord, and tokyo-night.
Mod+Ctrl+1-4 in niri.

## Requirements

- Fedora 44 (or similar)
- niri 26.04+
- wezterm (nightly)
- waybar, fuzzel, mako, swaylock, swayidle, wlogout
- yazi
- GNU Stow