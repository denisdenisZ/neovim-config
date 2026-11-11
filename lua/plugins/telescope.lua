-- Grep the current visual selection across the project. Lives here
-- (not inline in `keys`) because it needs to run a buffer-local
-- register swap before telescope ever gets involved.
local function get_visual_selection()
    local save_reg = vim.fn.getreg("v")
    local save_regtype = vim.fn.getregtype("v")
    vim.cmd('noautocmd normal! "vy')
    local sel = vim.fn.getreg("v")
    vim.fn.setreg("v", save_reg, save_regtype)
    -- collapse multi-line selections into a single search string
    return sel:gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

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

    -- `keys` (not keybinds.lua) so pressing e.g. <leader>ff is what
    -- actually triggers telescope's lazy load -- each entry's
    -- function only calls require("telescope.builtin") once pressed,
    -- same deferred-require trick the old keybinds.lua comment
    -- explained, just declared where lazy.nvim expects it.
    keys = {
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Telescope: Find files",
        },
        {
            "<leader>fg",
            function()
                require("telescope.builtin").live_grep()
            end,
            desc = "Telescope: Live grep (project)",
        },
        {
            "<leader>fG",
            function()
                require("telescope.builtin").live_grep({ additional_args = { "--fixed-strings" } })
            end,
            desc = "Telescope: Live grep literal (no regex)",
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Telescope: Buffers",
        },
        {
            "<leader>fh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "Telescope: Help tags",
        },
        -- NOTE: <C-/> can be terminal-dependent; if it doesn't work,
        -- try mapping <C-_> instead.
        {
            "<C-/>",
            function()
                require("telescope.builtin").current_buffer_fuzzy_find()
            end,
            desc = "Telescope: Fuzzy find in current buffer",
        },
        -- Grep word under cursor across the project (starts in normal mode).
        -- <C-f>, not <S-f>: flash.nvim's char plugin unconditionally
        -- takes over f/F/t/T/;/, in n/x/o mode when it loads (no check for
        -- a pre-existing mapping, unlike its own handling of ;/,), so plain
        -- <S-f> here was always going to lose that fight regardless of
        -- plugin load order. <C-f> is the "global" one; <leader>fw is the
        -- current-buffer-only counterpart right below.
        {
            "<C-f>",
            function()
                local word = vim.fn.expand("<cword>")
                require("telescope.builtin").live_grep({
                    default_text = word,
                    initial_mode = "normal",
                })
            end,
            desc = "Telescope: Live grep word under cursor (project)",
        },
        -- Fuzzy find word under cursor in the current buffer (starts in normal mode)
        {
            "<leader>fw",
            function()
                local word = vim.fn.expand("<cword>")
                require("telescope.builtin").current_buffer_fuzzy_find({
                    default_text = word,
                    initial_mode = "normal",
                })
            end,
            desc = "Telescope: Search word under cursor in current buffer",
        },
        -- Same collision as above: flash maps F in Visual mode too ("x"
        -- mode, which Visual-mode lookups also consult), so this moved
        -- off <S-f> to match. Kept on <C-f> (the "global" key) to match
        -- the normal-mode entry above.
        {
            "<C-f>",
            function()
                local text = get_visual_selection()
                require("telescope.builtin").live_grep({
                    default_text = text,
                    initial_mode = "normal",
                })
            end,
            mode = "v",
            desc = "Telescope: Live grep visual selection",
        },
        -- Extensions: frecency (files ranked by frequency+recency
        -- across sessions) and live_grep_args (grep with interactive
        -- ripgrep flags, e.g. type `-g *.cpp` to restrict to C++ files).
        {
            "<leader>fr",
            function()
                require("telescope").extensions.frecency.frecency()
            end,
            desc = "Telescope: Frecent files",
        },
        {
            "<leader>fa",
            function()
                require("telescope").extensions.live_grep_args.live_grep_args()
            end,
            desc = "Telescope: Live grep with args",
        },
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
