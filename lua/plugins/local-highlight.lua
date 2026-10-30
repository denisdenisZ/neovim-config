return {
    "tzachar/local-highlight.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("local-highlight").setup()
    end,
}
