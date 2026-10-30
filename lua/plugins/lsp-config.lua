return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
        -- Register/override server configs (Neovim 0.11+)
        vim.lsp.config("clangd", {})

        vim.lsp.config("pylsp", {})

        -- neocmakelsp only offers completions when the client advertises
        -- snippet support; without this it silently completes nothing.
        local cmake_capabilities = vim.lsp.protocol.make_client_capabilities()
        cmake_capabilities.textDocument.completion.completionItem.snippetSupport = true
        vim.lsp.config("neocmake", { capabilities = cmake_capabilities })

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
        vim.lsp.enable({ "clangd", "pylsp", "efm", "neocmake" })
    end,
}

