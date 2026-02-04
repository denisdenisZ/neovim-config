
return {
  "neovim/nvim-lspconfig",

  config = function()
    -- Enable built-in LSP servers via Neovim's API
    vim.lsp.enable("clangd")
    vim.lsp.enable("pyright")
  end,
}

