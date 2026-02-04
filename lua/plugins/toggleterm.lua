-- ============================================================
-- TOGGLETERM (INTEGRATED TERMINAL)
-- Provides togglable terminal windows inside Neovim.
-- ============================================================

return {
    "akinsho/toggleterm.nvim",
    version = "*",

    opts = {
        -- Keymap used by ToggleTerm to open/close terminal
        open_mapping = [[<c-\>]],

        -- Enable mappings inside terminal buffers
        terminal_mappings = true,
    },
}
