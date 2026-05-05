return {
    "mason-org/mason-lspconfig.nvim",
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
                "cmake",
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

                -- python
                "black",
                "isort",

                -- js
                "prettier",

                -- bash
                "shfmt",

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
