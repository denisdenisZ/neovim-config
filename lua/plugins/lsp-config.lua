return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
        -- Register/override server configs (Neovim 0.11+)
        vim.lsp.config("clangd", {})

        vim.lsp.config("pylsp", {})

        vim.lsp.config("gopls", {
            settings = {
                gopls = {
                    gofumpt = true,
                    staticcheck = true,
                },
            },
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    workspace = { checkThirdParty = false },
                },
            },
        })

        -- neocmakelsp only offers completions when the client advertises
        -- snippet support; without this it silently completes nothing.
        local cmake_capabilities = vim.lsp.protocol.make_client_capabilities()
        cmake_capabilities.textDocument.completion.completionItem.snippetSupport = true
        vim.lsp.config("neocmake", { capabilities = cmake_capabilities })

        -- EFM = LSP wrapper for formatters/linters
        -- Requires: efm-langserver
        vim.lsp.config("efm", {
            filetypes = { "lua", "c", "cpp", "sh", "bash", "python", "go" },

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

                    -- Bash formatting/linting via shfmt/shellcheck
                    sh = {
                        {
                            formatCommand = "shfmt -i 4 -ci",
                            formatStdin = true,
                        },
                        {
                            lintCommand = "shellcheck -f gcc -x -",
                            lintStdin = true,
                            lintFormats = {
                                "%f:%l:%c: %trror: %m",
                                "%f:%l:%c: %tarning: %m",
                                "%f:%l:%c: %tote: %m",
                            },
                        },
                    },
                    bash = {
                        {
                            formatCommand = "shfmt -i 4 -ci",
                            formatStdin = true,
                        },
                        {
                            lintCommand = "shellcheck -f gcc -x -",
                            lintStdin = true,
                            lintFormats = {
                                "%f:%l:%c: %trror: %m",
                                "%f:%l:%c: %tarning: %m",
                                "%f:%l:%c: %tote: %m",
                            },
                        },
                    },

                    -- Python formatting via isort (import order) then black
                    python = {
                        {
                            formatCommand = "isort -",
                            formatStdin = true,
                        },
                        {
                            formatCommand = "black -q -",
                            formatStdin = true,
                        },
                    },

                    -- Go formatting via gofumpt (stricter superset of gofmt).
                    -- gopls already formats on its own; this is for <leader>f,
                    -- which always forces efm specifically.
                    go = {
                        {
                            formatCommand = "gofumpt",
                            formatStdin = true,
                        },
                    },
                },
            },
        })

        -- Enable (auto-start) servers.
        -- gopls/lua_ls/ts_ls/html/cssls were installed via mason-lspconfig's
        -- ensure_installed but never actually enabled here -- fixed.
        vim.lsp.enable({
            "clangd",
            "pylsp",
            "efm",
            "neocmake",
            "bashls",
            "gopls",
            "lua_ls",
            "ts_ls",
            "html",
            "cssls",
        })
    end,
}

