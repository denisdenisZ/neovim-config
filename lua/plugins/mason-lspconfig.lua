return {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "neovim/nvim-lspconfig",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "bashls",
                "clangd",
                "gopls",
                "pylsp",
                "ts_ls",
                "html",
                "cssls",
                "lua_ls",
                "efm",
            },
            automatic_installation = true,
        })

        require("mason-tool-installer").setup({
            ensure_installed = {
                -- go
                "gofumpt",
                "goimports-reviser",
                "golines",

                -- c/cpp
                "clang-format",

                -- cmake (raw mason package name; lspconfig server name is "neocmake")
                "neocmakelsp",

                -- python
                "black",
                "isort",

                -- js
                "prettier",

                -- bash
                "shfmt",
                "shellcheck",

                -- lua
                "stylua",

                -- git
                "gitlint",

                -- markdown
                "markdownlint",
            },
            auto_update = false,
            run_on_start = true,
        })
    end,
}
