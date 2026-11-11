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

-- Open the current selection in the window telescope was launched from,
-- WITHOUT closing the picker -- so you can keep browsing results and
-- open several candidates to look at while the list stays up. Normal
-- <CR> always closes the picker (that's `action_set.edit`'s job); this
-- deliberately skips that.
--
-- Telescope auto-closes the picker if the prompt buffer loses focus
-- (a `BufLeave`-once autocmd in the "PickerInsert" group, meant to
-- catch you accidentally tabbing away) -- we have to clear that one
-- autocmd for this single programmatic hop, since we're leaving on
-- purpose and coming straight back. It gets reinstalled the moment you
-- type in the prompt again, so nothing is left permanently disabled.
local function open_in_background(prompt_bufnr)
    local action_state = require("telescope.actions.state")
    local entry = action_state.get_selected_entry()
    if not entry then
        return
    end

    local filename = entry.path or entry.filename
    if not filename then
        return
    end
    local row = entry.row or entry.lnum
    local col = entry.col

    local picker = action_state.get_current_picker(prompt_bufnr)
    local prompt_win = vim.api.nvim_get_current_win()

    pcall(vim.api.nvim_clear_autocmds, {
        buffer = prompt_bufnr,
        group = "PickerInsert",
        event = "BufLeave",
    })

    vim.api.nvim_set_current_win(picker.original_win_id)
    vim.cmd("edit " .. vim.fn.fnameescape(filename))
    if row then
        pcall(vim.api.nvim_win_set_cursor, 0, { row, math.max((col or 1) - 1, 0) })
    end

    if vim.api.nvim_win_is_valid(prompt_win) then
        vim.api.nvim_set_current_win(prompt_win)
    end
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
        -- Reopens the last picker exactly as you left it -- same
        -- query text, same result list, same cursor position in the
        -- list. Built into telescope itself, no caching logic needed
        -- here.
        {
            "<leader>fR",
            function()
                require("telescope.builtin").resume()
            end,
            desc = "Telescope: Resume last picker",
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
            defaults = {
                -- <C-CR> already means "accept, don't close" in blink-cmp
                -- (blink-cmp.lua) -- same chord, same meaning, here:
                -- open the selection but keep the picker open.
                mappings = {
                    i = { ["<C-CR>"] = open_in_background },
                    n = { ["<C-CR>"] = open_in_background },
                },
            },
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
