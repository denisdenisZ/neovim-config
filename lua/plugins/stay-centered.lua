return {
    "https://github.com/arnamak/stay-centered.nvim",
    event = "VeryLazy",
    opts = {
        -- The filetype is determined by the vim filetype, not the file extension. In order to get the filetype, open a file and run the command:
        -- :lua print(vim.bo.filetype)
        skip_filetypes = {},
        -- Set to false to disable by default
        enabled = true,
        -- allows scrolling to move the cursor without centering, default recommended
        allow_scroll_move = true,
        -- temporarily disables plugin on left-mouse down, allows natural mouse selection
        -- try disabling if plugin causes lag, function uses vim.on_key
        disable_on_mouse = true,
    },
    -- BUG WORKAROUND: the plugin's own disable_on_mouse only matches a
    -- literal single <LeftMouse> press, never the double/triple/quad-click
    -- variants (<2-LeftMouse> etc.) that terminals send when you
    -- double-click to select a word and then drag. Centering never gets
    -- disabled for that drag, so every CursorMoved re-centers (`zz`),
    -- and since zz re-centers around wherever the cursor currently is,
    -- each recenter makes the *next* tiny drag step "past middle" again
    -- -- chaining into a runaway scroll once the drag crosses the
    -- window's vertical middle. Confirmed by capturing the raw key
    -- codes a double-click actually sends (`<2-LeftMouse>`, distinct
    -- from `<LeftMouse>`) and confirming the plugin's checker never
    -- matches it.
    --
    -- Patch the gap instead of forking the plugin: piggyback on its own
    -- public activate()/deactivate(), just matching the click codes it
    -- missed.
    config = function(_, opts)
        local stay_centered = require("stay-centered")
        stay_centered.setup(opts)

        local press_codes = {}
        for _, name in ipairs({ "LeftMouse", "2-LeftMouse", "3-LeftMouse", "4-LeftMouse" }) do
            press_codes[vim.api.nvim_replace_termcodes("<" .. name .. ">", true, true, true)] = true
        end
        local release_code = vim.api.nvim_replace_termcodes("<LeftRelease>", true, true, true)

        vim.on_key(function(key)
            if press_codes[key] then
                stay_centered.deactivate()
            elseif key == release_code then
                stay_centered.activate()
            end
        end)
    end,
}
