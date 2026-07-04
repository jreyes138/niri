local wezterm = require("wezterm")
local act = wezterm.action

local copy_or_interrupt = wezterm.action_callback(function(window, pane)
  local has_selection = window:get_selection_text_for_pane(pane) ~= ""
  if has_selection then
    window:perform_action(act.CopyTo("Clipboard"), pane)
    window:perform_action(act.ClearSelection, pane)
  else
    window:perform_action(act.SendKey({ key = "c", mods = "CTRL" }), pane)
  end
end)

return {
  default_prog = { "/usr/bin/bash", "-l" },

  -- ── Font ──────────────────────────────────────────────────────────────────
  font = wezterm.font("JetBrains Mono"),
  font_size = 12.0,
  line_height = 1.08,

  -- ── Colors ────────────────────────────────────────────────────────────────
  color_schemes = {
    ["Gruvbox Dark"] = {
      foreground    = "#ebdbb2",
      background    = "#282828",
      cursor_bg     = "#ebdbb2",
      cursor_border = "#ebdbb2",
      cursor_fg     = "#282828",
      selection_fg  = "#ebdbb2",
      selection_bg  = "#504945",
      ansi = {
        "#282828", "#cc241d", "#98971a", "#d79921",
        "#458588", "#b16286", "#689d6a", "#a89984",
      },
      brights = {
        "#928374", "#fb4934", "#b8bb26", "#fabd2f",
        "#83a598", "#d3869b", "#8ec07c", "#ebdbb2",
      },
    },
  },
  color_scheme = "Catppuccin Mocha",   -- ← actually activate the scheme

  -- ── Window ────────────────────────────────────────────────────────────────
  window_background_opacity = 0.90,
  text_background_opacity   = 1.0,
  window_decorations        = "NONE",
  enable_scroll_bar         = false,
  enable_tab_bar            = true,
  scrollback_lines          = 50000,

  window_padding = {
    left   = 10,
    right  = 10,
    top    = 0,
    bottom = 8,
  },

  -- ── Tab Bar ───────────────────────────────────────────────────────────────
  enable_wayland             = true,
  use_fancy_tab_bar          = true,
  hide_tab_bar_if_only_one_tab = true,
  tab_bar_at_bottom          = false,
  show_tab_index_in_tab_bar  = true,

  -- ── Misc ──────────────────────────────────────────────────────────────────
  audible_bell = "Disabled",
  window_close_confirmation = "NeverPrompt",
  skip_close_confirmation_for_processes_named = {
    "bash", "sh", "zsh", "fish", "tmux", "nu",
    "python3", "python", "hermes", "node", "vim", "nvim", "micro",
  },

  -- ── Keys ──────────────────────────────────────────────────────────────────
  keys = {
    { key = "c", mods = "CTRL",       action = copy_or_interrupt },
    { key = "v", mods = "CTRL",       action = act.PasteFrom("Clipboard") },

    { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
    { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },
    { key = "q", mods = "CTRL|SHIFT", action = act.QuitApplication },

    { key = "Tab", mods = "CTRL",       action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

    { key = "f", mods = "CTRL|SHIFT",  action = act.Search({ CaseInSensitiveString = "" }) },

    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },

    { key = "d", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "e", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "x", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },

    { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
    { key = "t", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "LeftArrow",  mods = "ALT", action = act.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },

    { key = "1", mods = "ALT", action = act.ActivateTab(0) },
    { key = "2", mods = "ALT", action = act.ActivateTab(1) },
    { key = "3", mods = "ALT", action = act.ActivateTab(2) },
    { key = "4", mods = "ALT", action = act.ActivateTab(3) },
    { key = "5", mods = "ALT", action = act.ActivateTab(4) },
    { key = "6", mods = "ALT", action = act.ActivateTab(5) },
    { key = "7", mods = "ALT", action = act.ActivateTab(6) },
    { key = "8", mods = "ALT", action = act.ActivateTab(7) },
    { key = "9", mods = "ALT", action = act.ActivateTab(8) },

    { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
  },
}
