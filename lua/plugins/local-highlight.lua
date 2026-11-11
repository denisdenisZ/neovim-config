return {
    "tzachar/local-highlight.nvim",
    -- NOT "VeryLazy": that fires once, after startup, with no buffer
    -- of its own. The plugin attaches to buffers via its own BufRead
    -- autocmd, which only gets (re-)fired for buffers lazy.nvim's
    -- event loader already knows about -- so under VeryLazy, the
    -- very first file you open (already read before VeryLazy fires)
    -- never got attached, and the highlight silently never appeared
    -- for it. BufReadPost/BufNewFile are buffer-scoped events that
    -- lazy.nvim re-fires for the triggering buffer after loading.
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local local_highlight = require("local-highlight")
        local_highlight.setup()
        -- The plugin's own attach autocmd (registered inside setup())
        -- matches BufRead against the pattern "*.*" -- requires a literal
        -- dot somewhere in the full path -- so a dotless file (Makefile,
        -- extensionless scripts, etc.) never attaches no matter what. Call
        -- attach() ourselves on every buffer to bypass that pattern.
        local group = vim.api.nvim_create_augroup("LocalHighlightAttachAll", { clear = true })
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
            group = group,
            callback = function(args)
                local_highlight.attach(args.buf)
            end,
        })
        -- The buffer that caused THIS lazy-load already fired its own
        -- BufReadPost/BufNewFile before config() ran -- lazy.nvim only
        -- replays that event for autocmds in a *named* augroup, and only
        -- under conditions that didn't hold reliably here, so attach the
        -- current buffer directly rather than depend on a replay.
        local_highlight.attach(vim.api.nvim_get_current_buf())
    end,
}
