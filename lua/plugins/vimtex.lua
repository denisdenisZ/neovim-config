-- ============================================================
-- VIMTEX (LATEX)
-- Compilation (via latexmk), TOC, concealment, and forward/
-- backward SyncTex search with zathura (already installed).
--
-- REQUIRES A LATEX DISTRIBUTION -- NOT YET INSTALLED ON THIS
-- MACHINE. Nothing here will be able to compile until you run,
-- as yourself (not Claude -- sudo needs an interactive
-- password this session never had):
--
--   sudo pacman -S texlive-bin texlive-basic texlive-latex \
--     texlive-latexrecommended texlive-latexextra \
--     texlive-binextra texlive-bibtexextra \
--     texlive-fontsrecommended
--
-- (texlive-binextra brings latexmk, which vimtex uses by
-- default; texlive-bibtexextra brings biblatex/biber for
-- citations.) Until then: syntax highlighting, concealment,
-- and the TOC work fine; `\ll` (compile) will just error that
-- latexmk/pdflatex is missing.
-- ============================================================
return {
    {
        "lervag/vimtex",
        ft = { "tex", "plaintex", "bib" },
        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_quickfix_mode = 0
            vim.g.vimtex_mappings_enabled = true
            vim.g.vimtex_syntax_conceal_disable = false
        end,
    },
}
