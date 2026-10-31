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
        keys = {
            {
                "<leader>tt",
                function()
                    require("neotest").run.run()
                end,
                desc = "Neotest: Run nearest test",
            },
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Neotest: Run file",
            },
            {
                "<leader>td",
                function()
                    require("neotest").run.run({ strategy = "dap" })
                end,
                desc = "Neotest: Debug nearest test",
            },
            {
                "<leader>to",
                function()
                    require("neotest").output.open({ enter = true })
                end,
                desc = "Neotest: Output (nearest)",
            },
            {
                "<leader>ts",
                function()
                    require("neotest").summary.toggle()
                end,
                desc = "Neotest: Toggle summary panel",
            },
            {
                "<leader>tS",
                function()
                    require("neotest").run.stop()
                end,
                desc = "Neotest: Stop nearest",
            },
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
