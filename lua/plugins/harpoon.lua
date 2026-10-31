-- Manually mark a handful of files/locations and jump straight to
-- them, instead of walking the jumplist one hop at a time.
local harpoon_keys = {
    {
        "<leader>a",
        function()
            require("harpoon"):list():add()
        end,
        desc = "Harpoon: Add file",
    },
    {
        "<leader>e",
        function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon: Toggle quick menu",
    },
}
for i = 1, 4 do
    table.insert(harpoon_keys, {
        "<leader>" .. i,
        function()
            require("harpoon"):list():select(i)
        end,
        desc = "Harpoon: Jump to " .. i,
    })
end

return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
    keys = harpoon_keys,
}
