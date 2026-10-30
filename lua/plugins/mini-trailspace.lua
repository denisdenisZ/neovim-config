-- ============================================================
-- MINI.TRAILSPACE
-- Trims trailing whitespace / manages trailspace behavior.
-- ============================================================

return {
    "nvim-mini/mini.nvim",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("mini.trailspace").setup()
    end,
}
