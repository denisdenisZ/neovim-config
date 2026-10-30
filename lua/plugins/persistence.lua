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
    },
}
