-- ============================================================
-- NEOTEST (TEST RUNNER)
-- Run/debug individual tests or whole files without leaving
-- the editor. Adapters: Go, Python.
-- (No mature standalone adapter for raw C/C++ GTest/Catch2 yet;
-- for C/C++ use the DAP launch config in dap.lua against a
-- compiled test binary instead.)
-- ============================================================
return {
    {
        "nvim-neotest/neotest",
        ft = { "go", "python" },
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-go",
            "nvim-neotest/neotest-python",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-go"),
                    require("neotest-python")({
                        dap = { justMyCode = false },
                    }),
                },
            })
        end,
    },
}
