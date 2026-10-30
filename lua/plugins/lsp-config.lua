return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
        -- Register/override server configs (Neovim 0.11+)
        vim.lsp.config("clangd", {})

        -- Disable pylsp's own diagnostic plugins -- ruff (via efm,
        -- below) covers the same ground and was producing duplicate
        -- diagnostics for the same issue (e.g. "'os' imported but
        -- unused" from pyflakes AND from ruff simultaneously, confirmed
        -- via a real test). Deliberately NOT touching pylsp's
        -- formatting plugins (rope/yapf/autopep8): disabling those too
        -- made `vim.lsp.buf.format({filter = efm})` silently do
        -- nothing for python specifically (confirmed by bisecting) --
        -- root cause not fully nailed down, so leaving those alone
        -- rather than carrying a latent, poorly-understood breakage.
        vim.lsp.config("pylsp", {
            settings = {
                pylsp = {
                    plugins = {
                        pyflakes = { enabled = false },
                        pycodestyle = { enabled = false },
                        mccabe = { enabled = false },
                        pylint = { enabled = false },
                    },
                },
            },
        })

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

                    -- Python formatting/linting via ruff (replaces
                    -- black+isort: same formatting philosophy, rust-
                    -- speed, one tool instead of two+flake8).
                    python = {
                        {
                            formatCommand = "ruff format --stdin-filename ${INPUT} -",
                            formatStdin = true,
                        },
                        {
                            lintCommand = "ruff check --stdin-filename ${INPUT} --output-format concise -",
                            lintStdin = true,
                            lintFormats = {
                                "%f:%l:%c: %m",
                            },
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

