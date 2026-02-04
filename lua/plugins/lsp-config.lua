return {
    "neovim/nvim-lspconfig",
    config = function()
        -- Register/override server configs (Neovim 0.11+)
        vim.lsp.config("clangd", {})

        vim.lsp.config("pyright", {})

        -- EFM = LSP wrapper for formatters/linters
        -- Requires: efm-langserver
        vim.lsp.config("efm", {
            filetypes = { "lua", "c", "cpp" }, -- add more

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

                    -- C formatting/linting via clang tools
                    c = {
                        {
                            formatCommand = "clang-format",
                            formatStdin = true,
                        },
                        {
                            lintCommand = "clang-tidy --quiet --stdin-filename ${INPUT} -",
                            lintStdin = true,
                            lintFormats = {
                                "%f:%l:%c: %t%*[^:]: %m",
                            },
                        },
                    },

                    -- C++ formatting/linting via clang tools
                    cpp = {
                        {
                            formatCommand = "clang-format",
                            formatStdin = true,
                        },
                        {
                            lintCommand = "clang-tidy --quiet --stdin-filename ${INPUT} -",
                            lintStdin = true,
                            lintFormats = {
                                "%f:%l:%c: %t%*[^:]: %m",
                            },
                        },
                    },
                },
            },
        })

        -- Enable (auto-start) servers
        vim.lsp.enable({ "clangd", "pyright", "efm" })
    end,
}

