return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "BurntSushi/ripgrep",
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-telescope/telescope-live-grep-args.nvim",
        { "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
    },

    -- ============================================================
    -- TELESCOPE EXTENSIONS
    -- dir/bookmarks: pre-existing.
    -- live_grep_args: refine a grep interactively with ripgrep
    --   flags (e.g. restrict to -g '*.cpp', add -i, etc.) instead
    --   of only ever matching a plain string/regex.
    -- frecency: "most frecently used" file picker (biased toward
    --   files you open often AND recently) -- the actual answer to
    --   "fly around files" across sessions, beyond plain MRU.
    -- ============================================================
    config = function()
        local telescope = require("telescope")

        telescope.setup({
            extensions = {
                frecency = {
                    show_scores = false,
                    show_unindexed = true,
                    ignore_patterns = { "*.git/*", "*/tmp/*" },
                },
            },
        })

        telescope.load_extension("dir")
        telescope.load_extension("bookmarks")
        telescope.load_extension("live_grep_args")
        telescope.load_extension("frecency")
    end,
}
