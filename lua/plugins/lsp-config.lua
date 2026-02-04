return {
    "neovim/nvim-lspconfig",
    config = function()
        -- Register/override server configs (Neovim 0.11+)
        vim.lsp.config("clangd", {})

        vim.lsp.config("pyright", {})

        -- EFM = LSP wrapper for formatters/linters
        -- Requires: efm-langserver
        vim.lsp.config("efm", {
            filetypes = { "lua" }, -- add more
            init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
            },
            settings = {
                rootMarkers = { ".git/" },
                languages = {
                    lua = {
                        {
                            formatCommand = "stylua -",
                            formatStdin = true,
                        },
                    },
                },
            },
        })

        -- Enable (auto-start) servers
        vim.lsp.enable({ "clangd", "pyright", "efm" })
    end,
}
