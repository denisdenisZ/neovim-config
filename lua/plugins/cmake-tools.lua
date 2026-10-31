-- ============================================================
-- CMAKE-TOOLS (CMAKE CONFIGURE/BUILD/RUN/DEBUG)
-- Tightens the C/C++/CMake build-test loop: configure once,
-- then build/run/debug a target without leaving nvim or
-- retyping cmake invocations by hand. Debug launches reuse the
-- lldb-dap adapter defined in dap.lua.
-- ============================================================
return {
    {
        "Civitasv/cmake-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
        cmd = {
            "CMakeGenerate",
            "CMakeBuild",
            "CMakeRun",
            "CMakeDebug",
            "CMakeSelectBuildType",
            "CMakeSelectBuildTarget",
            "CMakeSelectLaunchTarget",
            "CMakeOpen",
            "CMakeClose",
            "CMakeClean",
        },
        opts = {
            cmake_dap_configuration = {
                name = "cpp-dbg",
                type = "lldb-dap",
                request = "launch",
            },
            -- Ninja is already installed on this machine and builds
            -- noticeably faster than the default "Unix Makefiles"
            -- generator, especially on incremental rebuilds of a large
            -- project -- directly tightens the build/test loop.
            cmake_generate_options = { "-G", "Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
        },
        keys = {
            { "<leader>kc", "<cmd>CMakeGenerate<CR>", desc = "CMake: Configure" },
            { "<leader>kb", "<cmd>CMakeBuild<CR>", desc = "CMake: Build" },
            { "<leader>kr", "<cmd>CMakeRun<CR>", desc = "CMake: Run" },
            { "<leader>kd", "<cmd>CMakeDebug<CR>", desc = "CMake: Debug (DAP)" },
            { "<leader>kt", "<cmd>CMakeSelectBuildTarget<CR>", desc = "CMake: Select build target" },
            { "<leader>kl", "<cmd>CMakeSelectLaunchTarget<CR>", desc = "CMake: Select launch target" },
            { "<leader>ko", "<cmd>CMakeOpen<CR>", desc = "CMake: Open console" },
        },
    },
}
