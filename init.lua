require("config.lazy")
require("settings.keybinds")
require("settings.vim_settings")


-- ============================================================
-- DIAGNOSTICS UX
-- Custom module: show diagnostics in a floating window on hover, etc.
-- ============================================================
require("modules.float-diagnostics").setup()
-- require("modules.keymap-viewer").setup() -- disabled

