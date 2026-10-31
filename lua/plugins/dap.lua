-- ============================================================
-- DAP (DEBUG ADAPTER PROTOCOL)
-- Core debugging: breakpoints, step in/over/out, variable
-- inspection, watches. Backed by:
--   - C/C++   -> lldb-dap        (already installed system-wide)
--   - Python  -> debugpy         (already installed system-wide)
--   - Go      -> delve (dlv)     (already installed, ~/go/bin)
-- ============================================================
return {
    {
        "mfussenegger/nvim-dap",
        ft = { "c", "cpp", "python", "go", "rust" },
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
        },
        -- F-keys match the common VSCode/Visual Studio convention.
        -- These stay global (not scoped to the `ft` list above) on
        -- purpose, same as before the split: pressing e.g. F9 in any
        -- buffer is what triggers DAP's first load.
        keys = {
            {
                "<F5>",
                function()
                    require("dap").continue()
                end,
                desc = "DAP: Continue/Start",
            },
            {
                "<F9>",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "DAP: Toggle breakpoint",
            },
            {
                "<F10>",
                function()
                    require("dap").step_over()
                end,
                desc = "DAP: Step over",
            },
            {
                "<F11>",
                function()
                    require("dap").step_into()
                end,
                desc = "DAP: Step into",
            },
            {
                "<S-F11>",
                function()
                    require("dap").step_out()
                end,
                desc = "DAP: Step out",
            },
            {
                "<leader>db",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "DAP: Conditional breakpoint",
            },
            {
                "<leader>dr",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "DAP: Toggle REPL",
            },
            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "DAP: Terminate session",
            },
            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "DAP: Toggle UI",
            },
        },
        config = function()
            local dap = require("dap")

            -- ----- C / C++ (lldb-dap) -----
            dap.adapters["lldb-dap"] = {
                type = "executable",
                command = "/usr/sbin/lldb-dap",
                name = "lldb-dap",
            }
            dap.configurations.cpp = {
                {
                    name = "Launch (lldb-dap)",
                    type = "lldb-dap",
                    request = "launch",
                    program = function()
                        return vim.fn.input(
                            "Path to executable: ",
                            vim.fn.getcwd() .. "/",
                            "file"
                        )
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }
            dap.configurations.c = dap.configurations.cpp

            -- ----- Go (delve, via nvim-dap-go) -----
            require("dap-go").setup()

            -- ----- Python (debugpy, via nvim-dap-python) -----
            require("dap-python").setup("python3")

            -- ----- UI + virtual text -----
            require("dapui").setup()
            require("nvim-dap-virtual-text").setup()

            local dapui = require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Breakpoint signs
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
            vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk" })
        end,
    },
}
