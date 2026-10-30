-- ============================================================
-- LAZYDEV (BETTER lua_ls FOR EDITING THIS VERY CONFIG)
-- Gives lua_ls proper `vim.*` types and completions pulled from
-- installed plugins' own annotations, instead of generic Lua
-- stdlib-only completions / "undefined global vim" warnings.
-- ============================================================
return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    {
        "https://github.com/Saghen/blink.cmp",
        optional = true,
        opts = {
            sources = {
                default = { "lazydev" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },
        },
    },
}
