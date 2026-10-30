-- ============================================================
-- KEYMAPS
-- ============================================================
-- Notes:
-- - Prefer `vim.keymap.set()` over legacy `vim.api.nvim_set_keymap()`.
-- - Use `desc` consistently so plugins like which-key / keymap viewers can show help.
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
-- TELESCOPE (FUZZY FINDING)
-- Built-in Telescope pickers: files, grep, buffers, help, etc.
-- ============================================================
local builtin = require("telescope.builtin")

-- Common pickers
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Live grep (project)" })
vim.keymap.set("n", "<leader>fG", function()
  builtin.live_grep({ additional_args = { "--fixed-strings" } })
end, { desc = "Telescope: Live grep literal (no regex)" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })

-- Search within current buffer
-- NOTE: <C-/> can be terminal-dependent; if it doesn't work, try mapping <C-_> instead.
vim.keymap.set(
    "n",
    "<C-/>",
    builtin.current_buffer_fuzzy_find,
    { desc = "Telescope: Fuzzy find in current buffer" }
)
-- Alternative:
-- vim.keymap.set('n', '<C-_>', builtin.current_buffer_fuzzy_find, { desc = 'Telescope: Fuzzy find in current buffer' })

-- Grep word under cursor across the project (starts in normal mode)
vim.keymap.set("n", "<S-f>", function()
    local word = vim.fn.expand("<cword>")
    builtin.live_grep({
        default_text = word,
        initial_mode = "normal",
    })
end, { desc = "Telescope: Live grep word under cursor" })

-- Fuzzy find word under cursor in the current buffer (starts in normal mode)
vim.keymap.set("n", "<C-f>", function()
    local word = vim.fn.expand("<cword>")
    builtin.current_buffer_fuzzy_find({
        default_text = word,
        initial_mode = "normal",
    })
end, { desc = "Telescope: Search word under cursor in current buffer" })

-- Grep the current visual selection across the project
local function get_visual_selection()
    local save_reg = vim.fn.getreg("v")
    local save_regtype = vim.fn.getregtype("v")
    vim.cmd('noautocmd normal! "vy')
    local sel = vim.fn.getreg("v")
    vim.fn.setreg("v", save_reg, save_regtype)
    -- collapse multi-line selections into a single search string
    return sel:gsub("\n", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

vim.keymap.set("v", "<S-f>", function()
    local text = get_visual_selection()
    builtin.live_grep({
        default_text = text,
        initial_mode = "normal",
    })
end, { desc = "Telescope: Live grep visual selection" })

-- ============================================================
-- TELESCOPE DIR (PLUGIN EXTENSION)
-- Requires: Telescope "dir" extension (or equivalent command provider).
-- ============================================================
vim.keymap.set(
    "n",
    "<leader>fd",
    "<cmd>Telescope dir live_grep<CR>",
    { noremap = true, silent = true, desc = "Telescope dir: Live grep (pick dir)" }
)
vim.keymap.set(
    "n",
    "<leader>pd",
    "<cmd>Telescope dir find_files<CR>",
    { noremap = true, silent = true, desc = "Telescope dir: Find files (pick dir)" }
)

-- ============================================================
-- LSP (LANGUAGE SERVER PROTOCOL) VIA TELESCOPE
-- Jump to definitions/references/etc with Telescope UI.
-- ============================================================
vim.keymap.set("n", "<leader>gr", function()
    builtin.lsp_references({ initial_mode = "normal" })
end, { desc = "[G]o to [R]eferences" })

vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, { desc = "[G]o to [D]efinitions" })
vim.keymap.set(
    "n",
    "<leader>gt",
    builtin.lsp_type_definitions,
    { desc = "[G]o to [T]ype definitions" }
)
vim.keymap.set(
    "n",
    "<leader>gi",
    builtin.lsp_implementations,
    { desc = "[G]o to [I]mplementations" }
)
vim.keymap.set(
    "n",
    "<leader>ic",
    builtin.lsp_incoming_calls,
    { desc = "LSP: Show [I]ncoming [C]alls" }
)
vim.keymap.set(
    "n",
    "<leader>oc",
    builtin.lsp_outgoing_calls,
    { desc = "LSP: Show [O]utgoing [C]alls" }
)

-- Symbols
vim.keymap.set(
    "n",
    "<leader>ls",
    builtin.lsp_document_symbols,
    { desc = "[L]ist [S]ymbols in buffer" }
)
vim.keymap.set(
    "n",
    "<leader>lsw",
    builtin.lsp_workspace_symbols,
    { desc = "[L]ist [S]ymbols in [W]orkspace" }
)
vim.keymap.set(
    "n",
    "<leader>lsww",
    builtin.lsp_dynamic_workspace_symbols,
    { desc = "[L]ist [S]ymbols in [W]orkspace (dynamic)" }
)

-- Diagnostics (NOTE: your mapping calls workspace symbols; keeping as-is but labeled clearly)
vim.keymap.set(
    "n",
    "<leader>ld",
    builtin.lsp_dynamic_workspace_symbols,
    { desc = "[L]ist [D]iagnostics (check mapping)" }
)

-- Hover (wording tweak: hover shows documentation, not "type")
vim.keymap.set("n", "<leader>st", vim.lsp.buf.hover, { desc = "[S]how [T]ooltip (LSP hover)" })

vim.keymap.set("n", "<leader>R", vim.lsp.buf.rename, { desc = "[LSP] Rename symbol" })
vim.keymap.set("n", "<CR>", vim.lsp.buf.code_action, { desc = "[LSP] Code actions" })

-- Format code, force efm langserver instead of lsp
vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == "efm"
        end,
    })
end, { desc = "Format buffer (efm)" })

-- Format using any LSP EXCEPT EFM (e.g. clangd / pyright)
vim.keymap.set("n", "<leader>fl", function()
    vim.lsp.buf.format({
        filter = function(client)
            return client.name ~= "efm"
        end,
    })
end, { desc = "Format without EFM" })

-- ============================================================
-- FILE EXPLORER (NVIM-TREE)
-- Toggle the file tree.
-- ============================================================
vim.keymap.set(
    "n",
    "<leader>r",
    ":NvimTreeToggle<CR>",
    { noremap = true, desc = "NvimTree: Toggle" }
)

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
-- BUFFERS (BUFFERLINE)
-- Cycle and reorder buffers using BufferLine.
-- ============================================================
vim.keymap.set("n", "<C-n>", "<Cmd>BufferLineCycleNext<CR>", { desc = "BufferLine: Next buffer" })
vim.keymap.set(
    "n",
    "<C-p>",
    "<Cmd>BufferLineCyclePrev<CR>",
    { desc = "BufferLine: Previous buffer" }
)
vim.keymap.set(
    "n",
    "<C-S-n>",
    "<Cmd>BufferLineMoveNext<CR>",
    { desc = "BufferLine: Move buffer forward" }
)
vim.keymap.set(
    "n",
    "<C-S-p>",
    "<Cmd>BufferLineMovePrev<CR>",
    { desc = "BufferLine: Move buffer back" }
)

-- Close buffers
vim.keymap.set("n", "<leader>q", "<Cmd>bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set(
    "n",
    "<leader>bc",
    "<cmd>BufferLinePickClose<CR>",
    { desc = "BufferLine: Pick buffer to close" }
)

-- ============================================================
-- LSP LINES (PLUGIN: lsp_lines.nvim)
-- Toggle virtual-lines diagnostics.
-- ============================================================
vim.keymap.set("n", "<Leader>l", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })

-- ============================================================
-- LSP: SWITCH BETWEEN SOURCE/HEADER (clangd extension)
-- ============================================================
vim.keymap.set(
    "n",
    "<leader>gh",
    "<cmd>LspClangdSwitchSourceHeader<CR>",
    { desc = "[G]o to [H]eader/source (clangd)" }
)

-- ============================================================
-- TROUBLE (AGGREGATED DIAGNOSTICS/SYMBOLS/LSP LIST)
-- A non-linear view: see many symbols/refs/diagnostics at once
-- instead of jumping one-at-a-time through the jumplist.
-- ============================================================
vim.keymap.set(
    "n",
    "<leader>xx",
    "<cmd>Trouble diagnostics toggle<CR>",
    { desc = "Trouble: Diagnostics (workspace)" }
)
vim.keymap.set(
    "n",
    "<leader>xX",
    "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
    { desc = "Trouble: Diagnostics (buffer)" }
)
vim.keymap.set(
    "n",
    "<leader>cs",
    "<cmd>Trouble symbols toggle focus=false<CR>",
    { desc = "Trouble: Symbols outline" }
)
vim.keymap.set(
    "n",
    "<leader>cl",
    "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
    { desc = "Trouble: LSP refs/defs/implementations" }
)
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Trouble: Location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", { desc = "Trouble: Quickfix list" })

-- ============================================================
-- HARPOON (QUICK-PINNED FILE JUMPS)
-- Manually mark a handful of files/locations and jump straight
-- to them, instead of walking the jumplist one hop at a time.
-- ============================================================
vim.keymap.set("n", "<leader>a", function()
    require("harpoon"):list():add()
end, { desc = "Harpoon: Add file" })

vim.keymap.set("n", "<leader>e", function()
    local harpoon = require("harpoon")
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: Toggle quick menu" })

for i = 1, 4 do
    vim.keymap.set("n", "<leader>" .. i, function()
        require("harpoon"):list():select(i)
    end, { desc = "Harpoon: Jump to " .. i })
end

-- ============================================================
-- DAP (DEBUGGING: C/C++ via lldb-dap, Python via debugpy, Go via delve)
-- F-keys match the common VSCode/Visual Studio convention.
-- ============================================================
vim.keymap.set("n", "<F5>", function()
    require("dap").continue()
end, { desc = "DAP: Continue/Start" })

vim.keymap.set("n", "<F9>", function()
    require("dap").toggle_breakpoint()
end, { desc = "DAP: Toggle breakpoint" })

vim.keymap.set("n", "<F10>", function()
    require("dap").step_over()
end, { desc = "DAP: Step over" })

vim.keymap.set("n", "<F11>", function()
    require("dap").step_into()
end, { desc = "DAP: Step into" })

vim.keymap.set("n", "<S-F11>", function()
    require("dap").step_out()
end, { desc = "DAP: Step out" })

vim.keymap.set("n", "<leader>db", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Conditional breakpoint" })

vim.keymap.set("n", "<leader>dr", function()
    require("dap").repl.toggle()
end, { desc = "DAP: Toggle REPL" })

vim.keymap.set("n", "<leader>dt", function()
    require("dap").terminate()
end, { desc = "DAP: Terminate session" })

vim.keymap.set("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "DAP: Toggle UI" })

-- ============================================================
-- NEOTEST (RUN/DEBUG INDIVIDUAL TESTS: Go, Python)
-- ============================================================
vim.keymap.set("n", "<leader>tt", function()
    require("neotest").run.run()
end, { desc = "Neotest: Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
    require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Neotest: Run file" })

vim.keymap.set("n", "<leader>td", function()
    require("neotest").run.run({ strategy = "dap" })
end, { desc = "Neotest: Debug nearest test" })

vim.keymap.set("n", "<leader>to", function()
    require("neotest").output.open({ enter = true })
end, { desc = "Neotest: Output (nearest)" })

vim.keymap.set("n", "<leader>ts", function()
    require("neotest").summary.toggle()
end, { desc = "Neotest: Toggle summary panel" })

vim.keymap.set("n", "<leader>tS", function()
    require("neotest").run.stop()
end, { desc = "Neotest: Stop nearest" })

-- ============================================================
-- OVERSEER (GENERIC TASK RUNNER: non-CMake build/test/run tasks)
-- ============================================================
vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<CR>", { desc = "Overseer: Run task" })
vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<CR>", { desc = "Overseer: Toggle task list" })
vim.keymap.set(
    "n",
    "<leader>oq",
    "<cmd>OverseerQuickAction<CR>",
    { desc = "Overseer: Quick action" }
)

-- ============================================================
-- CMAKE-TOOLS (CMAKE CONFIGURE/BUILD/RUN/DEBUG)
-- Debug launches reuse the lldb-dap adapter defined in dap.lua.
-- ============================================================
vim.keymap.set("n", "<leader>kc", "<cmd>CMakeGenerate<CR>", { desc = "CMake: Configure" })
vim.keymap.set("n", "<leader>kb", "<cmd>CMakeBuild<CR>", { desc = "CMake: Build" })
vim.keymap.set("n", "<leader>kr", "<cmd>CMakeRun<CR>", { desc = "CMake: Run" })
vim.keymap.set("n", "<leader>kd", "<cmd>CMakeDebug<CR>", { desc = "CMake: Debug (DAP)" })
vim.keymap.set(
    "n",
    "<leader>kt",
    "<cmd>CMakeSelectBuildTarget<CR>",
    { desc = "CMake: Select build target" }
)
vim.keymap.set(
    "n",
    "<leader>kl",
    "<cmd>CMakeSelectLaunchTarget<CR>",
    { desc = "CMake: Select launch target" }
)
vim.keymap.set("n", "<leader>ko", "<cmd>CMakeOpen<CR>", { desc = "CMake: Open console" })

-- ============================================================
-- MARKDOWN RENDERING
-- <leader>mr: in-editor text-based rendering (render-markdown.nvim)
-- <leader>mp: full browser live preview (markdown-preview.nvim)
-- ============================================================
vim.keymap.set(
    "n",
    "<leader>mr",
    "<cmd>RenderMarkdown toggle<CR>",
    { desc = "Markdown: Toggle in-editor rendering" }
)
vim.keymap.set(
    "n",
    "<leader>mp",
    "<cmd>MarkdownPreviewToggle<CR>",
    { desc = "Markdown: Toggle browser preview" }
)

-- ============================================================
-- BOOKMARKS (TELESCOPE EXTENSION)
-- Shows bookmark list.
-- ============================================================
vim.keymap.set(
    "n",
    "<leader>mm",
    "<cmd>Telescope bookmarks list<CR>",
    { noremap = true, silent = true, desc = "Bookmarks: List (Telescope)" }
)
-- Other bookmark mappings are set wherever the bookmarks module is required

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
