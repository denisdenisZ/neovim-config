local features = require("config.features")
-- ============================================================
-- COLORS / UI BOOTSTRAP
-- ============================================================

-- Load colorscheme
vim.cmd("colorscheme cyberdream")

-- Disable netrw (usually when using another file explorer like nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable legacy Vim syntax highlighting (Tree-sitter likely handles it)
vim.cmd("syntax off")

-- ============================================================
-- FOLDING (TREE-SITTER BASED)
-- ============================================================

-- Disable folding by default (folds still exist, just not closed)
vim.opt.foldenable = false

-- Use expression-based folding
vim.wo.foldmethod = "expr"

-- Delegate fold calculation to Tree-sitter
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- ============================================================
-- TAB / INDENTATION BEHAVIOR
-- ============================================================

-- NOTE: You had conflicting tab settings earlier.
-- These below enforce *spaces* for indentation.

-- Convert tabs to spaces
vim.opt.expandtab = true

-- Visual width of a <Tab>
vim.opt.tabstop = 4

-- Indent width for >> << and auto-indent
vim.opt.shiftwidth = 4

-- Insert-mode <Tab> spacing
vim.opt.softtabstop = 4

-- Enable smart indentation heuristics
vim.opt.smartindent = true

-- ============================================================
-- PLUGIN GLOBAL FLAGS
-- ============================================================

-- Disable animation in snacks.nvim (performance / preference)
vim.g.snacks_animate = false

-- ============================================================
-- WINDOW / TITLE BAR
-- ============================================================

-- Enable terminal window title updates
vim.o.title = true

-- Set title to the current directory name
vim.o.titlestring = "%{fnamemodify(getcwd(), ':t')}"

-- ============================================================
-- GENERAL UI OPTIONS
-- ============================================================

-- Always show the sign column (diagnostics, git, etc.)
vim.opt.signcolumn = "yes"

-- Enable mouse support in all modes
vim.o.mouse = "a"

-- Highlight the current cursor line
vim.o.cursorline = true

-- When wrapping lines, preserve indentation visually
vim.o.breakindent = true

-- ============================================================
-- UNDO / HISTORY
-- ============================================================

-- Persist undo history across sessions
vim.o.undofile = true

-- ============================================================
-- SEARCH BEHAVIOR
-- ============================================================

-- Ignore case unless uppercase letters appear in the pattern
vim.o.ignorecase = true
vim.o.smartcase = true

-- ============================================================
-- TIMING / RESPONSIVENESS
-- ============================================================

-- Faster CursorHold / diagnostic popups
vim.o.updatetime = 250

-- Time to wait for mapped key sequences
vim.o.timeoutlen = 1000

-- ============================================================
-- COMMAND-LINE UX
-- ============================================================

-- Preview substitutions live in a split window
vim.o.inccommand = "split"

-- Ask before quitting modified buffers
vim.o.confirm = true

-- ============================================================
-- TERMINAL COLOR SUPPORT
-- ============================================================

-- Enable 24-bit RGB color in terminal
vim.opt.termguicolors = true

-- ============================================================
-- LINE NUMBERS
-- ============================================================

-- Show absolute line number on cursor line
vim.o.number = true

-- Show relative numbers elsewhere
vim.o.relativenumber = true

if features.enable_visual_whitespaces then
    -- ============================================================
    -- WHITESPACE / INVISIBLE CHARACTERS (DEBUG / TEST SECTION)
    -- ============================================================

    -- Render whitespace characters visually
    vim.opt.list = true

    -- Define how invisible characters are displayed
    vim.opt.listchars = {
        space = "·",
        tab = "»·",
        trail = "·",
        extends = "…",
        precedes = "…",
        nbsp = "␣",
    }
    -- Visible spaces (·)
    vim.api.nvim_set_hl(0, "Whitespace", {
        fg = "#555555",
    })

    -- Tabs / special chars
    vim.api.nvim_set_hl(0, "SpecialKey", {
        fg = "#888888",
    })

    -- End-of-buffer / extends / precedes
    vim.api.nvim_set_hl(0, "NonText", {
        fg = "#444444",
    })
end

-- ============================================================
-- CUSTOM HIGHLIGHTS
-- ============================================================

-- Highlight group for visible tab characters (if used elsewhere)
vim.api.nvim_set_hl(0, "TabChar", {
    bg = "#FF5555",
    nocombine = true,
})
