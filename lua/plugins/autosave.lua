return {
    -- "brianhuster/autosave.nvim",
    "https://github.com/pocco81/auto-save.nvim",
    event = "VeryLazy",
    opts = {
        debounce_delay = 2000, -- wait 2s of idle before writing to disk, instead of 135ms
    },
}
