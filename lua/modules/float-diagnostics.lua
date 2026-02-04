local M = {}

function M.setup()
    vim.o.updatetime = 200

    vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
            vim.diagnostic.open_float(nil, {
                scope = "cursor", -- <-- only show when cursor is ON the problem
                focusable = false,
                border = "rounded",
                max_width = 80,
            })
        end,
    })
end

return M
