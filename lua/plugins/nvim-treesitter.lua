local M = {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "c",
                "cpp",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "javascript",
                "html",
                "css",
                "go",
                "python",
                "bash",
                "markdown",
                "markdown_inline",
                "make",
                "cmake",
                -- "latex" deliberately excluded: tree-sitter-latex's build
                -- script passes a --no-bindings flag that the tree-sitter
                -- CLI installed on this machine (0.26.9) no longer
                -- accepts, so the grammar fails to compile every time
                -- (confirmed via real install attempt). vimtex doesn't
                -- depend on this parser for its own syntax/compile/
                -- SyncTex features, so nothing is lost by skipping it.
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "json",
                "yaml",
                "toml",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = {
                enable = true,
                disable = { "c", "cpp" },
            },
        })

        -- ----- nvim-treesitter-textobjects -----
        -- This plugin was rewritten with its own standalone setup() and
        -- requires explicit vim.keymap.set() calls -- the old declarative
        -- `textobjects = { keymaps = {...} }` block nested inside
        -- nvim-treesitter.configs.setup() (still used by some older
        -- guides) is silently ignored by this version. Confirmed via a
        -- real PTY test: "vaf" did nothing until rewritten this way.
        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,
            },
            move = {
                set_jumps = true,
            },
        })

        local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")

        -- Function/class/parameter text objects, e.g. "daf" (delete
        -- around function), "yif" (yank inside function) -- big win for
        -- navigating/editing deep C++ class hierarchies.
        local textobj_select = {
            af = "@function.outer",
            ["if"] = "@function.inner",
            ac = "@class.outer",
            ic = "@class.inner",
            aa = "@parameter.outer",
            ia = "@parameter.inner",
        }
        for key, query in pairs(textobj_select) do
            vim.keymap.set({ "x", "o" }, key, function()
                select_obj(query, "textobjects")
            end, { desc = "Textobject: " .. query })
        end

        -- Jump to the next/previous function or class start/end.
        vim.keymap.set({ "n", "x", "o" }, "]m", function()
            move.goto_next_start("@function.outer", "textobjects")
        end, { desc = "Textobjects: Next function start" })
        vim.keymap.set({ "n", "x", "o" }, "]]", function()
            move.goto_next_start("@class.outer", "textobjects")
        end, { desc = "Textobjects: Next class start" })
        vim.keymap.set({ "n", "x", "o" }, "]M", function()
            move.goto_next_end("@function.outer", "textobjects")
        end, { desc = "Textobjects: Next function end" })
        vim.keymap.set({ "n", "x", "o" }, "][", function()
            move.goto_next_end("@class.outer", "textobjects")
        end, { desc = "Textobjects: Next class end" })
        vim.keymap.set({ "n", "x", "o" }, "[m", function()
            move.goto_previous_start("@function.outer", "textobjects")
        end, { desc = "Textobjects: Previous function start" })
        vim.keymap.set({ "n", "x", "o" }, "[[", function()
            move.goto_previous_start("@class.outer", "textobjects")
        end, { desc = "Textobjects: Previous class start" })
        vim.keymap.set({ "n", "x", "o" }, "[M", function()
            move.goto_previous_end("@function.outer", "textobjects")
        end, { desc = "Textobjects: Previous function end" })
        vim.keymap.set({ "n", "x", "o" }, "[]", function()
            move.goto_previous_end("@class.outer", "textobjects")
        end, { desc = "Textobjects: Previous class end" })

        -- Swap the current parameter with the next/previous one.
        vim.keymap.set("n", "<leader>na", function()
            swap.swap_next("@parameter.inner")
        end, { desc = "Textobjects: Swap parameter with next" })
        vim.keymap.set("n", "<leader>nb", function()
            swap.swap_previous("@parameter.inner")
        end, { desc = "Textobjects: Swap parameter with previous" })

        -- ----- fix: nvim-treesitter's #set-lang-from-info-string!/
        -- #set-lang-from-mimetype! directives crash on this Neovim
        -- version -----
        -- nvim-treesitter.query_predicates (loaded as a side effect of
        -- requiring the plugin above) registers these two directives
        -- assuming `match[capture_id]` is a single TSNode and calls
        -- `node:range()` on it directly. Current Neovim always passes
        -- directive handlers an *array* of nodes per capture now -- the
        -- `all = false` compat option the plugin's shim relied on to
        -- request a single node was removed from
        -- vim.treesitter.query.add_directive's Opts (confirmed against
        -- $VIMRUNTIME/lua/vim/treesitter/query.lua, which now only
        -- documents `force`). That crashes any markdown fenced-code-block
        -- parse -- confirmed via real PTY test opening a .md file through
        -- nvim-tree (not a cmd-line arg -- see below for why that
        -- distinction matters).
        --
        -- An `after/queries/markdown/injections.scm` override was tried
        -- first and looked like it worked in isolated testing, but it's
        -- actually a dead end: Neovim's query-file combination algorithm
        -- (vim.treesitter.query.get_files) uses the *first* non-";
        -- extends" file found in 'runtimepath' order as the base and
        -- silently discards every later non-extends file, including
        -- ours -- it does NOT take the last one. nvim-treesitter's own
        -- file is earlier in rtp than anything under
        -- ~/.config/nvim/after, so our override file was never actually
        -- used. The reason it *looked* like it worked when opened as a
        -- `nvim file.md` cmd-line arg: that parses the buffer before
        -- nvim-treesitter (lazy-loaded on "VeryLazy") has added itself to
        -- 'runtimepath', so at that moment only the safe files are
        -- visible and Neovim caches that safe query for the rest of the
        -- session. Opening the same file later through nvim-tree happens
        -- well after VeryLazy has fired, so the query resolves with
        -- nvim-treesitter's file included and crashes. Fixing this
        -- requires actually overriding the buggy Lua functions, not the
        -- query files that reference them -- which is what this does.
        require "nvim-treesitter.query_predicates"
        local tsquery = require "vim.treesitter.query"

        local function first_node(node)
            if type(node) == "table" then
                return node[1]
            end
            return node
        end

        local html_script_type_languages = {
            ["importmap"] = "json",
            ["module"] = "javascript",
            ["application/ecmascript"] = "javascript",
            ["text/ecmascript"] = "javascript",
        }
        local non_filetype_match_injection_language_aliases = {
            ex = "elixir",
            pl = "perl",
            sh = "bash",
            uxn = "uxntal",
            ts = "typescript",
        }
        local function get_parser_from_markdown_info_string(injection_alias)
            local filetype_match = vim.filetype.match({ filename = "a." .. injection_alias })
            return filetype_match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
        end

        tsquery.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
            local node = first_node(match[pred[2]])
            if not node then
                return
            end
            local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
            local configured = html_script_type_languages[type_attr_value]
            if configured then
                metadata["injection.language"] = configured
            else
                local parts = vim.split(type_attr_value, "/", {})
                metadata["injection.language"] = parts[#parts]
            end
        end, { force = true })

        tsquery.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
            local node = first_node(match[pred[2]])
            if not node then
                return
            end
            local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
            metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
        end, { force = true })
    end,
}

return { M }
