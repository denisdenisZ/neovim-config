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
        cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
        opts = {},
    },
}
