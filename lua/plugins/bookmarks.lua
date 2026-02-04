-- ============================================================
-- BOOKMARKS (PLUGIN)
-- Persistent line bookmarks with optional annotations + quick navigation.
-- ============================================================

return {
  "tomasky/bookmarks.nvim",
  config = function()
    require("bookmarks").setup({
      save_file = vim.fn.expand("$HOME/.bookmarks"),
      keywords = {
        ["@t"] = "V",
        ["@w"] = "!!",
        ["@f"] = "F",
        ["@n"] = "N:",
      },
      on_attach = function(bufnr)
        local bm = require("bookmarks")
        local map = vim.keymap.set
        local opts = { buffer = bufnr }

        map("n", "mm", bm.bookmark_toggle, opts)
        map("n", "mi", bm.bookmark_ann, opts)
        map("n", "mc", bm.bookmark_clean, opts)
        map("n", "mn", bm.bookmark_next, opts)
        map("n", "mp", bm.bookmark_prev, opts)
        map("n", "ml", bm.bookmark_list, opts)
        map("n", "mx", bm.bookmark_clear_all, opts)
      end,
    })
  end,
}


