-- ============================================================
-- GRUG-FAR (PROJECT-WIDE SEARCH & REPLACE UI)
-- The structured "replace in files" workflow that was missing --
-- previously only live_grep (search) existed, with no project-
-- wide replace. Directly useful on inheritance-heavy codebases
-- where a rename touches many override sites at once.
-- ============================================================
return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        opts = {},
        keys = {
            { "<leader>sr", "<cmd>GrugFar<CR>", desc = "Grug-far: Search & replace" },
            {
                "<leader>sr",
                mode = "v",
                function()
                    require("grug-far").with_visual_selection()
                end,
                desc = "Grug-far: Search & replace (visual selection)",
            },
        },
    },
}
