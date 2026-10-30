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
    },
}
