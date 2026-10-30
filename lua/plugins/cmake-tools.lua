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
        },
    },
}
