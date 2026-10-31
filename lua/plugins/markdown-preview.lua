-- ============================================================
-- MARKDOWN-PREVIEW (BROWSER-RENDERED LIVE PREVIEW)
-- Full-fidelity live-reloading preview in the system browser --
-- complements render-markdown.nvim's in-editor rendering for
-- anything that needs pixel-perfect output (tables, embedded
-- images, complex layouts).
-- ============================================================
return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown: Toggle browser preview" },
        },
    },
}
