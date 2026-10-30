-- ============================================================
-- RENDER-MARKDOWN (IN-BUFFER MARKDOWN RENDERING)
-- Terminal is Alacritty (no kitty graphics protocol), so this
-- uses text-based conceal/extmark rendering instead of inline
-- images: styled headings, bullets, tables, checkboxes, code
-- block borders -- all while still editing plain text.
-- For a full browser-rendered preview (tables/images/etc. at
-- full fidelity) see markdown-preview.lua instead.
-- ============================================================
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
}
