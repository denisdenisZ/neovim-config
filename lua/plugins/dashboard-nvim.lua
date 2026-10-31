return {
    "https://github.com/nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
        require("dashboard").setup({
            -- config
        })

        -- The dashboard buffer's buftype is "" (not "nofile"), so
        -- plugins that normally skip non-file buffers don't exclude
        -- it. Two culprits found by checking the actual rendered
        -- SGR colors against every highlight group definition (none
        -- of dashboard-nvim's own highlight groups had a background
        -- set -- the real source turned out to be elsewhere):
        -- - snacks.indent drew indent guides across the padding
        --   whitespace used to center the dashboard's text.
        -- - mini.trailspace painted a solid background block over
        --   that same trailing whitespace, since every dashboard
        --   line is entirely trailing (space-padded) content.
        -- Both have their own documented per-buffer opt-out var.
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dashboard",
            group = vim.api.nvim_create_augroup("dashboard-no-text-decorations", { clear = true }),
            callback = function()
                vim.b.snacks_indent = false
                vim.b.minitrailspace_disable = true
            end,
        })

        -- Closing the last real buffer doesn't leave you with nothing --
        -- Vim always auto-creates a fresh unnamed empty buffer to show
        -- in its place. Detect that exact state (the *only* listed
        -- buffer left is unnamed, unmodified, and a normal buftype) and
        -- swap it for the dashboard instead of sitting on a blank "new
        -- file". Guarded against the dashboard's own (unlisted) buffer
        -- so this doesn't retrigger itself.
        vim.api.nvim_create_autocmd("BufDelete", {
            group = vim.api.nvim_create_augroup("dashboard-on-empty", { clear = true }),
            callback = function()
                vim.schedule(function()
                    if vim.bo.filetype == "dashboard" then
                        return
                    end

                    local listed = vim.tbl_filter(function(buf)
                        return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
                    end, vim.api.nvim_list_bufs())

                    if #listed == 0 then
                        vim.cmd("Dashboard")
                        return
                    end

                    if #listed == 1 then
                        local buf = listed[1]
                        if
                            vim.api.nvim_buf_get_name(buf) == ""
                            and not vim.bo[buf].modified
                            and vim.bo[buf].buftype == ""
                        then
                            vim.cmd("Dashboard")
                            -- dashboard-nvim reuses the current buffer
                            -- in-place when it's already empty (see its
                            -- instance(): `buf_is_empty` check), instead
                            -- of creating a separate one. Only delete
                            -- `buf` if it's still a distinct, valid
                            -- buffer -- otherwise this deletes the
                            -- dashboard's own buffer, which forces Vim
                            -- to spawn yet another empty buffer and
                            -- retrigger this same autocmd forever.
                            local current = vim.api.nvim_get_current_buf()
                            if current ~= buf and vim.api.nvim_buf_is_valid(buf) then
                                vim.api.nvim_buf_delete(buf, { force = true })
                            end
                        end
                    end
                end)
            end,
        })
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
