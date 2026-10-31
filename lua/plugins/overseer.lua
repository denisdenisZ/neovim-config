-- ============================================================
-- OVERSEER (GENERIC TASK RUNNER)
-- Run build/test/run commands as background tasks with
-- captured output, for anything that isn't a CMake project
-- (Go build/test, Python scripts, Bash scripts, Makefiles).
-- CMake projects should prefer cmake-tools.lua instead.
-- ============================================================
return {
    {
        "stevearc/overseer.nvim",
        -- "OverseerShell" added here -- it's the ad-hoc-command
        -- keymap's target (<leader>oa, below) and without it listed,
        -- lazy.nvim never creates a stub for that exact command name,
        -- so pressing <leader>oa before overseer had already loaded
        -- via one of the other three would do nothing.
        cmd = { "OverseerRun", "OverseerShell", "OverseerToggle", "OverseerQuickAction" },
        opts = {},
        keys = {
            -- Plain `:OverseerRun` only auto-detects project templates
            -- (Makefile, Cargo.toml, package.json, etc.) -- when none
            -- match, it calls its own internal `log.error` (writes to
            -- overseer's log file only, never `vim.notify`) and shows
            -- nothing at all: no picker, no message, nothing.
            -- Confirmed via PTY. `<leader>oa` covers the ad-hoc case
            -- via overseer's own public `OverseerShell` command (NOT
            -- "OverseerRunCmd" -- that name doesn't exist; checked the
            -- actual command list in overseer/init.lua after the first
            -- version of this fix silently failed with
            -- "E492: Not an editor command").
            { "<leader>or", "<cmd>OverseerRun<CR>", desc = "Overseer: Run task (detected templates only)" },
            { "<leader>oa", "<cmd>OverseerShell<CR>", desc = "Overseer: Run ad-hoc command" },
            { "<leader>ot", "<cmd>OverseerToggle<CR>", desc = "Overseer: Toggle task list" },
            { "<leader>oq", "<cmd>OverseerQuickAction<CR>", desc = "Overseer: Quick action" },
        },
    },
}
