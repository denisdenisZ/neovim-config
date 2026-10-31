-- ============================================================
-- KEYMAPS
-- ============================================================
-- Notes:
-- - Prefer `vim.keymap.set()` over legacy `vim.api.nvim_set_keymap()`.
-- - Use `desc` consistently so plugins like which-key / keymap viewers can show help.
-- - Plugin-specific keymaps live in that plugin's own
--   `lua/plugins/<name>.lua`, under its `keys` table -- not here.
--   Only keymaps that aren't owned by a single plugin (vanilla Vim
--   splits/terminal, and genuinely cross-cutting quality-of-life
--   mappings) belong in this file.
-- ============================================================

-- ============================================================
-- WINDOW NAVIGATION (VANILLA VIM SPLITS)
-- Use Ctrl + h/j/k/l to move focus between split windows.
-- See `:help wincmd` for more.
-- ============================================================
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })

-- Stay centered (plugin: stay-centered.nvim) — currently disabled
-- vim.keymap.set({ 'n', 'v' }, '<leader>st', require('stay-centered').toggle, { desc = 'Toggle stay-centered.nvim' })

-- ============================================================
-- TERMINAL MODE NAVIGATION
-- Adds sensible terminal mappings when a terminal buffer opens:
-- - <Esc> to exit terminal insert-mode
-- - Ctrl+h/j/k/l to move between windows
-- ============================================================
function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }

    -- Exit terminal-mode to normal-mode
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
    -- Alternative exit chord (disabled)
    -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)

    -- Window navigation from terminal buffers
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)

    -- Allow <C-w> commands after leaving terminal-mode
    vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- Apply terminal keymaps to all terminal buffers
-- If you only want these mappings for toggleterm, use: term://*toggleterm#*
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- ============================================================
-- MISC / QUALITY OF LIFE
-- ============================================================

-- Clear search highlights
vim.keymap.set("n", "<Leader>/", ":noh<CR>", { desc = "Clear search highlight" })

-- Copy "filename" (tail only) to system clipboard
vim.keymap.set("n", "<leader>cf", function()
    local p = vim.fn.expand("%:t")
    vim.fn.setreg("+", p)
    vim.notify("Copied: " .. p)
end, { desc = "Copy filename only", silent = true })

-- Copy "filename:line" to system clipboard
vim.keymap.set("n", "<leader>cfl", function()
    local fname = vim.fn.expand("%:t")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local text = string.format("%s:%d", fname, line)
    vim.fn.setreg("+", text)
    vim.notify("Copied: " .. text)
end, { desc = "Copy filename:line", silent = true })

-- Copy full path to system clipboard
vim.keymap.set("n", "<leader>cp", function()
    local p = vim.fn.expand("%:p")
    vim.fn.setreg("+", p)
    vim.notify("Copied: " .. p)
end, { desc = "Copy full path", silent = true })

-- Copy "full/path:line" to system clipboard
vim.keymap.set("n", "<leader>cpl", function()
    local fname = vim.fn.expand("%:p")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local text = string.format("%s:%d", fname, line)
    vim.fn.setreg("+", text)
    vim.notify("Copied: " .. text)
end, { desc = "Copy full path:line", silent = true })

-- Copy and paste to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v" }, "<leader>P", '"+P')
