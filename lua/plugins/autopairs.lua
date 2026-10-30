-- ============================================================
-- NVIM-AUTOPAIRS (AUTO-CLOSE BRACKETS/QUOTES)
-- Was entirely missing -- every ( { [ " ' had to be closed by
-- hand. High-frequency win for C/C++ especially.
-- ============================================================
return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },
}
