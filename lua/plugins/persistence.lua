-- ============================================================
-- PERSISTENCE (PER-DIRECTORY SESSION RESTORE)
-- Remembers the window/buffer layout per project directory, so
-- hopping between e.g. assimp / go_proj / python practice dirs
-- doesn't mean losing your open files each time. Auto-saves on
-- exit, restore is manual (<leader>qs) so it never surprises you
-- with a stale layout.
-- ============================================================
return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
        keys = {
            {
                "<leader>Ss",
                function()
                    require("persistence").load()
                end,
                desc = "Persistence: Restore session (cwd)",
            },
            {
                "<leader>Sl",
                function()
                    require("persistence").load({ last = true })
                end,
                desc = "Persistence: Restore last session",
            },
            {
                "<leader>Sd",
                function()
                    require("persistence").stop()
                end,
                desc = "Persistence: Stop (don't save on exit)",
            },
        },
    },
}
