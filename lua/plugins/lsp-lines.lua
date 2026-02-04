return {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    -- Similar plugin 'https://github.com/dgagn/diagflow.nvim'
    -- Even more advance one 'https://github.com/folke/trouble.nvim'
    config = function()
        require("lsp_lines").setup()
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = false,
        })
        -- vim.diagnostic.config({ virtual_lines = true })
    end,
}
