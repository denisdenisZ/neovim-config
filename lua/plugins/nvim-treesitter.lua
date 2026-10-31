-- ============================================================
-- NVIM-TREESITTER (main branch, not master)
-- ============================================================
-- This config used to pin the old "master" branch (configs.setup(),
-- ensure_installed, highlight/indent tables). Switched to "main" --
-- the actively maintained rewrite -- because master's own docs say
-- it's locked for Nvim 0.11 compatibility only, and we're on 0.12.4.
-- Staying on master meant patching around its query_predicates.lua
-- directly (a real, documented incompatibility with current Neovim's
-- query API: directive handlers always receive an array of nodes per
-- capture now, which master's shim doesn't expect, crashing any
-- markdown fenced-code-block parse). "main" doesn't ship that custom
-- directive at all -- it defers entirely to Neovim core's own
-- injection handling -- so migrating removes the patch rather than
-- maintaining it. Confirmed via PTY: parsers install, highlighting/
-- indentation/injections all work, and the markdown crash is gone
-- without any override needed.
--
-- "main" has a different shape than master:
-- - no configs.setup() -- parsers are installed via
--   require("nvim-treesitter").install(...), highlighting/indent are
--   enabled per-filetype via autocmds (Neovim core features now, not
--   plugin config: see :h treesitter-highlight).
-- - doesn't support lazy-loading (its own README says so explicitly),
--   so this loads at startup instead of on "VeryLazy" like before.
local M = {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
        require("nvim-treesitter").install({
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
        })

        -- Treesitter indentation is still experimental upstream; it
        -- was disabled for c/cpp under the old master-branch config
        -- too (its indent output there was worse than the default),
        -- so that exclusion carries over here.
        local indent_disabled = { c = true, cpp = true }

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                pcall(vim.treesitter.start)
                if not indent_disabled[vim.bo[args.buf].filetype] then
                    pcall(function()
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end)
                end
            end,
        })

        -- ----- nvim-treesitter-textobjects -----
        -- This plugin was rewritten with its own standalone setup() and
        -- requires explicit vim.keymap.set() calls -- the old declarative
        -- `textobjects = { keymaps = {...} }` block nested inside
        -- nvim-treesitter.configs.setup() (still used by some older
        -- guides, and only existed on master anyway) is silently
        -- ignored by this version. Confirmed via a real PTY test: "vaf"
        -- did nothing until rewritten this way.
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
    end,
}

return { M }
