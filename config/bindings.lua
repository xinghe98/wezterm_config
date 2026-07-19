local wezterm = require("wezterm")
local platform = require("utils.platform")()
local act = wezterm.action

local mod = {}

if platform.is_mac then
  mod.SUPER = "SUPER"
  mod.SUPER_REV = "SUPER|CTRL"
elseif platform.is_win then
  mod.SUPER = "CTRL|ALT" -- reserve Alt shortcuts for Zellij
  mod.SUPER_REV = "CTRL|ALT|SHIFT"
elseif platform.is_linux then
  mod.SUPER = "ALT" -- to not conflict with Windows key shortcuts
  mod.SUPER_REV = "ALT|CTRL"
end

local keys = {
  -- misc/useful --
  { key = "F1",  mods = "NONE",    action = "ActivateCopyMode" },
  { key = "F2",  mods = "NONE",    action = act.ActivateCommandPalette },
  { key = "F3",  mods = "NONE",    action = act.ShowLauncher },
  { key = "F4",  mods = "NONE",    action = act.ShowTabNavigator },
  { key = "F11", mods = "NONE",    action = act.ToggleFullScreen },
  { key = "F12", mods = "NONE",    action = act.ShowDebugOverlay },
  { key = "f",   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = "" }) },

  -- Legacy terminal input cannot encode Ctrl+Tab without Kitty Keyboard Protocol.
  -- Forward the equivalent Zellij tab-mode sequences instead.
  { key = "Tab", mods = "CTRL",       action = act.SendString("\x14e\x14") },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.SendString("\x14n\x14") },

  -- copy/paste --

  {
    key = 'C', -- 'C' (大写) 通常表示 Shift + c
    mods = 'CTRL',
    action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
  },

  -- ctrl+shift+v 粘贴
  {
    key = 'V', -- 'V' (大写) 通常表示 Shift + v
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
  },

  -- ctrl+1 切换到下一个标签页
  {
    key = '1',
    mods = 'CTRL',
    action = wezterm.action.ActivateTabRelative(1),
  },

  -- ctrl+alt+shift+tab 切换到上一个标签页
  {
    key = 'Tab',
    mods = 'CTRL|ALT|SHIFT',
    action = wezterm.action.ActivateTabRelative(-1),
  },

  -- ctrl+shift+t 新建标签页
  {
    key = 'T', -- 'T' (大写) 表示 Shift + t
    mods = 'CTRL',
    action = wezterm.action.SpawnTab 'DefaultDomain',
  },

  -- ctrl+alt+shift+w 关闭当前标签页
  {
    key = 'W', -- 'W' (大写) 表示 Shift + w
    mods = 'CTRL|ALT',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },



  -- panes --
  -- panes: split panes
  {
    key = [[/]],
    mods = mod.SUPER_REV,
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = [[\]],
    mods = mod.SUPER_REV,
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = [[-]],
    mods = mod.SUPER_REV,
    action = act.CloseCurrentPane({ confirm = true }),
  },

  -- panes: zoom+close pane
  { key = "z",         mods = mod.SUPER_REV, action = act.TogglePaneZoomState },
  { key = "w",         mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

  -- panes: navigation
  { key = "u",         mods = mod.SUPER,     action = act.ActivatePaneDirection("Up") },
  { key = "e",         mods = mod.SUPER,     action = act.ActivatePaneDirection("Down") },
  { key = "n",         mods = mod.SUPER,     action = act.ActivatePaneDirection("Left") },
  { key = "i",         mods = mod.SUPER,     action = act.ActivatePaneDirection("Right") },

  -- panes: resize
  { key = "u",         mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Up", 1 }) },
  { key = "e",         mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Down", 1 }) },
  { key = "n",         mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Left", 1 }) },
  { key = "i",         mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Right", 1 }) },

  -- fonts --
  -- fonts: resize
  { key = "UpArrow",   mods = mod.SUPER,     action = act.IncreaseFontSize },
  { key = "DownArrow", mods = mod.SUPER,     action = act.DecreaseFontSize },
  { key = "r",         mods = mod.SUPER,     action = act.ResetFontSize },

  -- key-tables --
  -- resizes fonts
  {
    key = "f",
    mods = "LEADER",
    action = act.ActivateKeyTable({
      name = "resize_font",
      one_shot = false,
      timemout_miliseconds = 1000,
    }),
  },
  -- resize panes
  {
    key = "p",
    mods = "LEADER",
    action = act.ActivateKeyTable({
      name = "resize_pane",
      one_shot = false,
      timemout_miliseconds = 1000,
    }),
  },
  -- rename tab bar
  {
    key = "R",
    mods = "CTRL|SHIFT",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

local key_tables = {
  resize_font = {
    { key = "k",      action = act.IncreaseFontSize },
    { key = "j",      action = act.DecreaseFontSize },
    { key = "r",      action = act.ResetFontSize },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
  },
  resize_pane = {
    { key = "k",      action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "j",      action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "h",      action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "l",      action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
  },
}

local mouse_bindings = {
  -- Ctrl-click will open the link under the mouse cursor
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  -- Move mouse will only select text and not copy text to clipboard
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Cell"),
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.ExtendSelectionToMouseCursor("Cell"),
  },
  {
    event = { Drag = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.ExtendSelectionToMouseCursor("Cell"),
  },
  -- Triple Left click will select a line
  {
    event = { Down = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Line"),
  },
  {
    event = { Up = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Line"),
  },
  -- Double Left click will select a word
  {
    event = { Down = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Word"),
  },
  {
    event = { Up = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = act.SelectTextAtMouseCursor("Word"),
  },
  -- Turn on the mouse wheel to scroll the screen
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "NONE",
    action = act.ScrollByCurrentEventWheelDelta,
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = "NONE",
    action = act.ScrollByCurrentEventWheelDelta,
  },
}

return {
  disable_default_key_bindings = true,
  disable_default_mouse_bindings = true,
  leader = { key = "Space", mods = "CTRL|SHIFT" },
  keys = keys,
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
