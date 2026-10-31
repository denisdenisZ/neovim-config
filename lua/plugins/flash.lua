-- ============================================================
-- FLASH (JUMP TO ANY VISIBLE LOCATION, 2-CHAR LABELS)
-- The "fly around" motion-level answer: label-jump to any word
-- on screen, or to treesitter nodes directly. Complements
-- telescope/harpoon (cross-buffer) at the within-buffer level.
--
-- NOTE: this takes over bare `s`/`S` in normal/visual/operator-
-- pending mode, overriding vim's native "substitute one
-- character" (`s`). This is flash's own documented default and
-- a deliberate trade: `s` for a single-char substitute is rare
-- and easily replaced by `cl`; label-jumping anywhere on screen
-- is high value. mini.surround (see mini-surround.lua) was
-- deliberately moved to a `gz` prefix instead of `s*` so the
-- two plugins don't fight over the same key.
-- ============================================================
return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function()
                    require("flash").jump()
                end,
                desc = "Flash: Jump",
            },
            {
                "S",
                mode = { "n", "x", "o" },
                function()
                    require("flash").treesitter()
                end,
                desc = "Flash: Treesitter jump",
            },
            {
                "r",
                mode = "o",
                function()
                    require("flash").remote()
                end,
                desc = "Flash: Remote (operator)",
            },
            {
                "R",
                mode = { "o", "x" },
                function()
                    require("flash").treesitter_search()
                end,
                desc = "Flash: Treesitter search",
            },
        },
    },
}
