-- ============================================================
-- MINI.NVIM MODULES (single mono-repo, multiple independent
-- modules set up together so there's only one lazy.nvim spec
-- for this plugin -- avoids ambiguous multi-file config merging).
--
-- - mini.trailspace: trims trailing whitespace.
-- - mini.surround: add/delete/replace surrounding pairs, under
--   a `gz*` prefix (not the usual `sa`/`sd`/`sr`) because
--   flash.nvim (see flash.lua) claims bare `s`/`S` for jump
--   motions -- `gz*` avoids fighting it for every keystroke.
-- ============================================================

return {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
        require("mini.trailspace").setup()

        require("mini.surround").setup({
            mappings = {
                add = "gza",
                delete = "gzd",
                find = "gzf",
                find_left = "gzF",
                highlight = "gzh",
                replace = "gzr",
                update_n_lines = "gzn",
            },
        })
    end,
}
