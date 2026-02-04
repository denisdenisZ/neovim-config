
return {
  "nvim-telescope/telescope.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim",
    "BurntSushi/ripgrep",
    "nvim-telescope/telescope-fzf-native.nvim",
  },

-- ============================================================
-- TELESCOPE EXTENSIONS
-- Loads extra Telescope functionality (directory picker + bookmarks integration).
-- ============================================================
  config = function()
    local telescope = require("telescope")

    telescope.load_extension("dir")
    telescope.load_extension("bookmarks")
  end,
}

