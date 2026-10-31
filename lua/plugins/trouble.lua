return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
    -- A non-linear view: see many symbols/refs/diagnostics at once
    -- instead of jumping one-at-a-time through the jumplist.
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Trouble: Diagnostics (workspace)" },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
            desc = "Trouble: Diagnostics (buffer)",
        },
        { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Trouble: Symbols outline" },
        {
            "<leader>cl",
            "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
            desc = "Trouble: LSP refs/defs/implementations",
        },
        { "<leader>xL", "<cmd>Trouble loclist toggle<CR>", desc = "Trouble: Location list" },
        { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", desc = "Trouble: Quickfix list" },
    },
}
