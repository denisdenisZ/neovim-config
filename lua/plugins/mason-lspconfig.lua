return {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
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
            -- `automatic_installation` was removed upstream (checked
            -- the current source: it's not referenced anywhere, not
            -- even as a deprecated alias) -- replaced by
            -- `automatic_enable`, which defaults to true and already
            -- covers this. Had been silently doing nothing.
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

                -- python (ruff replaces black+isort -- rust-speed,
                -- one tool for format+lint instead of two)
                "ruff",

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
