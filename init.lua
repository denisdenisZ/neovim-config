local features = require("config.features")
features.enable_visual_whitespaces = false

require("config.lazy")
require("settings.keybinds")
require("settings.vim_settings")

require("modules.float-diagnostics").setup()
