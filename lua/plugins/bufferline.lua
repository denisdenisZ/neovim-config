-- ============================================================
-- BUFFERLINE (TAB-LIKE BUFFER UI)
-- Provides a buffer tabline with reordering, pick-close, etc.
-- ============================================================

return {
    "https://github.com/akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",

    opts = {},
    keys = {
        { "<C-n>", "<Cmd>BufferLineCycleNext<CR>", desc = "BufferLine: Next buffer" },
        { "<C-p>", "<Cmd>BufferLineCyclePrev<CR>", desc = "BufferLine: Previous buffer" },
        { "<C-S-n>", "<Cmd>BufferLineMoveNext<CR>", desc = "BufferLine: Move buffer forward" },
        { "<C-S-p>", "<Cmd>BufferLineMovePrev<CR>", desc = "BufferLine: Move buffer back" },
        -- Grouped here (not MISC) because it's buffer-management,
        -- even though :bdelete itself is a vanilla Vim command.
        { "<leader>q", "<Cmd>bdelete<CR>", desc = "Close current buffer" },
        { "<leader>bc", "<cmd>BufferLinePickClose<CR>", desc = "BufferLine: Pick buffer to close" },
    },
}
