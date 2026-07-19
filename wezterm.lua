local Config = require("config")
local wezterm = require("wezterm")

wezterm.on("gui-startup", function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

require("events.right-status").setup()
require("events.tab-title").setup()
require("events.new-tab-button").setup()

return Config:init()
  :append(require("config.appearance"))
  :append(require("config.bindings"))
  :append(require("config.domains"))
  :append(require("config.fonts"))
  :append(require("config.general"))
  :append(require("config.launch")).options
