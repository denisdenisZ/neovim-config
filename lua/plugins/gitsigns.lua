-- ============================================================
-- GITSIGNS (INLINE GIT: hunk signs, blame, stage/reset hunks)
-- Previously the only git integration was diffview (full diffs);
-- this adds the inline, line-by-line workflow diffview doesn't
-- cover -- see what changed without leaving the buffer, blame a
-- line, stage/reset/preview a hunk, jump hunk-to-hunk.
-- ============================================================
return {
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            on_attach = function(bufnr)
                local gs = require("gitsigns")
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                map("n", "]h", gs.next_hunk, "Gitsigns: Next hunk")
                map("n", "[h", gs.prev_hunk, "Gitsigns: Previous hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Gitsigns: Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Gitsigns: Reset hunk")
                map("v", "<leader>hs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Gitsigns: Stage hunk (visual)")
                map("v", "<leader>hr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Gitsigns: Reset hunk (visual)")
                map("n", "<leader>hp", gs.preview_hunk, "Gitsigns: Preview hunk")
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "Gitsigns: Blame line")
                map("n", "<leader>hd", gs.diffthis, "Gitsigns: Diff this")
            end,
        },
    },
}
