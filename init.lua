-- Must run before anything else calls vim.keymap.set (including
-- config.lazy, which processes every plugin's `keys` table): it wraps
-- the function so every later call -- here or inside any plugin file --
-- goes through the wrapped version. See lua/modules/keymap-tracker.lua.
require("modules.keymap-tracker").setup()

local features = require("config.features")
features.enable_visual_whitespaces = false

require("config.lazy")
require("settings.keybinds")
require("settings.vim_settings")

require("modules.float-diagnostics").setup()
