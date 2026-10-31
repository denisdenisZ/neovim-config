-- ============================================================
-- HARDTIME (REAL-TIME BAD-HABIT NUDGES)
-- Blocks/warns on repeated hjkl, arrow keys, repeated dd/x instead
-- of a count, etc., and suggests the better alternative inline.
-- `:Hardtime report` shows which hints fired most.
-- ============================================================
return {
    "m4xshen/hardtime.nvim",
    -- README's own spec uses lazy = false -- it needs to observe every
    -- keypress from startup, not just after some trigger event.
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
        -- Mouse is deliberately enabled elsewhere in this config
        -- (vim_settings.lua) for real uses (picker clicks, diffview's
        -- file panel, terminal). Don't let hardtime disable it --
        -- the goal here is using the keyboard features you already
        -- have, not banning the mouse outright.
        disable_mouse = false,
    },
}
