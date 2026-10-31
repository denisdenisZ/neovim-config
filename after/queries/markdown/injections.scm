; Overrides nvim-treesitter's queries/markdown/injections.scm.
;
; nvim-treesitter (master branch) resolves a fenced code block's language
; via its own custom `#set-lang-from-info-string!` directive, implemented
; in lua/nvim-treesitter/query_predicates.lua. That directive assumes
; `match[capture_id]` is a single TSNode, but current Neovim (0.12) always
; passes directive handlers an array of nodes per capture -- the old
; `all = false` compatibility option that used to request a single node
; was removed from vim.treesitter.query.add_directive's Opts. Calling
; `node:range()` on the resulting array then throws "attempt to call
; method 'range' (a nil value)", crashing anything that parses markdown
; injections (render-markdown.nvim, plain markdown syntax highlighting).
;
; This file replaces the query with Neovim core's own version of the
; same file (queries/markdown/injections.scm in $VIMRUNTIME), which
; captures `@injection.language` directly with no custom directive --
; core's injection logic reads that capture's node text as the language
; name natively. Loses nvim-treesitter's info-string aliasing (e.g. `py`
; -> `python`) and case-insensitivity, but every fence tag actually used
; in this config's own docs (`c`, `sh`) is already an exact lowercase
; parser name, so nothing regresses for this setup.
(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
