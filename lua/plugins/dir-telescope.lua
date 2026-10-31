return {
    "https://github.com/princejoogie/dir-telescope.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    opts = {},
    keys = {
        { "<leader>fd", "<cmd>Telescope dir live_grep<CR>", desc = "Telescope dir: Live grep (pick dir)" },
        { "<leader>pd", "<cmd>Telescope dir find_files<CR>", desc = "Telescope dir: Find files (pick dir)" },
    },
}
