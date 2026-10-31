-- ============================================================
-- GIT-CONFLICT (INLINE MERGE-CONFLICT HIGHLIGHTING)
-- Plain conflict markers (<<<<<<<, =======, >>>>>>>) render as
-- unstyled text otherwise -- nothing marks the current/incoming
-- regions the way VS Code does. This highlights them inline in
-- any buffer the moment it detects markers (independent of
-- diffview's merge-tool, which is a separate split-pane workflow).
-- ============================================================
return {
    "https://github.com/akinsho/git-conflict.nvim",
    -- Not VeryLazy: that fires *after* VimEnter, but the plugin's own
    -- detection hooks VimEnter/BufRead to scan the just-opened buffer for
    -- conflict markers. Loading on BufReadPre/BufNewFile instead means
    -- lazy.nvim loads it in time to catch (and replay) that same event for
    -- whatever file was opened first -- VeryLazy would silently miss it.
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        default_mappings = true, -- buffer-local co/ct/cb/c0, only active in conflicted files
        default_commands = true,
    },
    keys = {
        { "<leader>vq", "<Cmd>GitConflictListQf<CR>", desc = "GitConflict: List all conflicts (quickfix)" },
    },
}
