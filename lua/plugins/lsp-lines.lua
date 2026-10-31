return {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    -- Similar plugin 'https://github.com/dgagn/diagflow.nvim'
    -- Even more advance one 'https://github.com/folke/trouble.nvim'
    event = "VeryLazy",
    keys = {
        -- Wrapped in a closure (not `require("lsp_lines").toggle`
        -- directly) so the require() only happens on keypress --
        -- a bare reference would eagerly require() the plugin the
        -- instant this spec table is built, at startup, regardless of
        -- the "VeryLazy" trigger above.
        {
            "<Leader>l",
            function()
                require("lsp_lines").toggle()
            end,
            desc = "Toggle lsp_lines",
        },
    },
    config = function()
        require("lsp_lines").setup()
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = false,
        })
        -- vim.diagnostic.config({ virtual_lines = true })
    end,
}
