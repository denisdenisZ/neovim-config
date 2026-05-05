local M = {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "c",
                "cpp",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "javascript",
                "html",
                "css",
                "go",
                "python",
                "bash",
                "markdown",
                "markdown_inline",
                "make",
                "git_config",
                "git_rebase",
                "gitcommit",
                "gitignore",
                "json",
                "yaml",
                "toml",
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}

return { M }
