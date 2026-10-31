return {
    "https://github.com/sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    -- :DiffviewOpen auto-detects an in-progress merge and switches to the
    -- 3-way merge-tool layout (OURS | result | THEIRS, conflict regions
    -- highlighted) -- no separate command needed for that.
    keys = {
        { "<leader>vo", "<Cmd>DiffviewOpen<CR>", desc = "Diffview: Open (merge-tool during a conflict)" },
        { "<leader>vc", "<Cmd>DiffviewClose<CR>", desc = "Diffview: Close" },
        { "<leader>vh", "<Cmd>DiffviewFileHistory %<CR>", desc = "Diffview: File history (current file)" },
        { "<leader>vH", "<Cmd>DiffviewFileHistory<CR>", desc = "Diffview: File history (repo)" },
    },
}
