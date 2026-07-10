# dotfiles

GNU Stow-managed dotfiles for a niri Wayland desktop on Fedora 44.

Replicate the full setup on a fresh Fedora 44 (or similar) install with one command:

```bash
git clone git@github.com:jreyes138/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --all
```

## What This Repo Contains

### Stow packages (user-level configs)

| Package | Path | Purpose |
|---------|------|---------|
| niri | .config/niri/config.kdl | Niri compositor config (layout, keybindings, window rules, env vars) |
| waybar | .config/waybar/{config,style.css} | Status bar (Gruvbox Dark) |
| wezterm | .wezterm.lua | WezTerm terminal config |
| fuzzel | .config/fuzzel/fuzzel.ini | App launcher |
| mako | .config/mako/config | Notification daemon |
| swaylock | .config/swaylock/config | Screen locker (Gruvbox colors) |
| wlogout | .config/wlogout/{layout,style.css} | Logout menu |
| wlogout-icons | .local/share/wlogout/icons/ | Custom Gruvbox SVG icons for wlogout |
| xdg-desktop-portal | .config/xdg-desktop-portal/niri-portals.conf | Portal config (gnome+gtk backends) |
| yazi | .config/yazi/yazi.toml, .local/share/applications/yazi.desktop | File manager config + xdg-open .desktop file |
| mimeapps | .config/mimeapps.list | Default app associations (yazi for dirs, okular for PDF, brave for http, nvim for txt) |
| bash | .bashrc, .bash_profile | Shell config (Gruvbox PS1, fzf+fd integration) |
| git | .gitconfig | Git config |
| bin | .local/bin/{niri-theme,y} | Scripts: theme switcher, yazi wrapper |
| fonts | .local/share/fonts/ | FiraCode Nerd Font (bundled) |
| wallpapers | Pictures/wallpapers/ | Per-theme wallpaper directories (gruvbox-dark, catppuccin-mocha, nord, tokyo-night) with multiple curated wallpapers each |
| dconf | .config/gsettings-*.txt | GSettings dump for replication |

### System-level configs (opt-in via --system)

| File | Path | Purpose |
|------|------|---------|
| greetd config | /etc/greetd/config.toml | Tuigreet display manager config |
| vtrgb | /etc/vtrgb | Nord VGA palette for virtual console |
| vtrgb-nord.service | /etc/systemd/system/ | Systemd service to apply vtrgb on boot |

## Bootstrap Script

`bootstrap.sh` automates the full setup on a fresh Fedora install.

### Quick start (everything)

```bash
git clone git@github.com:jreyes138/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh --all
sudo reboot
```

After reboot, select "niri" at the tuigreet session picker.

### Flags

| Flag | What it does |
|------|-------------|
| (none) | DNF packages, wezterm nightly, yazi, stow dotfiles, gsettings, wallpapers, fonts from repo |
| --system | Also install greetd config, vtrgb Nord palette, systemd service (needs sudo) |
| --fonts | Download FiraCode Nerd Font from github (~100MB) instead of using bundled copy |
| --icons | Clone and install Gruvbox-Plus-Dark icon theme from github |
| --all | All of the above |

### What bootstrap.sh installs via DNF

niri, waybar, fuzzel, mako, swaybg, swaylock, swayidle, slurp, brightnessctl,
lxpolkit, wlogout, cliphist, grim, wl-clipboard, playerctl, tuigreet, greetd,
xdg-desktop-portal + gnome + gtk, pipewire, wireplumber, adw-gtk3-theme,
jetbrains-mono-fonts, stow, git, fd-find, fzf, blueman,
network-manager-applet, tesseract, tuned, tuned-ppd

### What bootstrap.sh installs from GitHub

- WezTerm nightly RPM (wez/wezterm releases)
- Yazi binary (sxyazi/yazi releases)
- Gruvbox-Plus-Dark icon theme (PapirusDevelopmentTeam/gruvbox-plus-icon-pack) — with --icons
- FiraCode Nerd Font (ryanoasis/nerd-fonts) — with --fonts, or bundled copy without

## Themes

`niri-theme` script switches between gruvbox-dark, catppuccin-mocha, nord, and tokyo-night.
It updates niri config, wezterm, waybar CSS, fuzzel, mako, swaylock, wlogout, wallpaper,
cursor, accent-color, TTY/vtrgb, nvim, and SwayOSD. Wallpapers rotate randomly from
per-theme directories on each switch.

In niri: Mod+Ctrl+1-4 (1=gruvbox, 2=catppuccin, 3=nord, 4=tokyo-night)

## Stow Usage

Install (symlink dotfiles into $HOME):
```bash
cd ~/dotfiles
stow niri waybar wezterm fuzzel mako swaylock wlogout yazi mimeapps bash git bin \
  xdg-desktop-portal wallpapers fonts wlogout-icons dconf
```

Uninstall:
```bash
cd ~/dotfiles
stow -D niri waybar wezterm fuzzel mako swaylock wlogout yazi mimeapps bash git bin \
  xdg-desktop-portal wallpapers fonts wlogout-icons dconf
```

Restow (after pulling changes):
```bash
cd ~/dotfiles
stow -R niri waybar wezterm fuzzel mako swaylock wlogout yazi mimeapps bash git bin \
  xdg-desktop-portal wallpapers fonts wlogout-icons dconf
```

## Keybindings (niri)

| Key | Action |
|-----|--------|
| Mod+T | Open wezterm |
| Mod+D | Open fuzzel (app launcher) |
| Mod+Q | Close window |
| Mod+W | Toggle tabbed column |
| Mod+F | Maximize column |
| Mod+Shift+F | Fullscreen window |
| Mod+V | Toggle floating |
| Mod+1-9 | Switch workspace |
| Mod+Shift+1-9 | Move window to workspace |
| Mod+H/J/K/L | Focus left/down/up/right |
| Mod+Ctrl+H/J/K/L | Move window left/down/up/right |
| Mod+R | Cycle column width presets |
| Mod+Shift+E | Quit niri |
| Mod+Shift+Slash | Show keybinding overlay |
| Mod+Ctrl+1-4 | Switch theme (gruvbox/catppuccin/nord/tokyo-night) |
| Mod+B | Open Brave browser |
| Mod+M | Open Tuta mail |
| Print | Screenshot |

Mod = Super (Mod4)

## Requirements

- Fedora 44 (or similar Fedora version)
- niri 26.04+
- WezTerm nightly
- Waybar, fuzzel, mako, swaylock, swayidle, wlogout
- Yazi (file manager)
- GNU Stow
- greetd + tuigreet (display manager)

## Existing Setup Notes

This setup was built on a Dell laptop originally shipped with Fedora 44 COSMIC.
COSMIC was fully removed (packages, configs, release identity). GNOME shell/session
was also removed. The system runs niri exclusively with greetd/tuigreet as the
display manager. Hostname is fedora-niri.

Secure Boot is enabled with self-signed keys via sbctl. Thermald is configured
with a custom thermal-conf.xml for Dell SMM fan management. These are
hardware-specific and not included in this repo.