# Neovim config: what's new (overnight session)

Branch: `nav-and-completion-upgrade`. Nothing in this doc has been pushed
to the remote yet. Everything below has been tested in a real nvim
session (PTY, not just `--headless`) unless flagged otherwise.

## 1. One-time setup you still need to do

I cannot run `sudo` in this environment (no interactive password), so a
few things are configured but not installed. Run these yourself:

```sh
# LaTeX (vimtex is configured and will error without this)
sudo pacman -S texlive-bin texlive-basic texlive-latex \
  texlive-latexrecommended texlive-latexextra \
  texlive-binextra texlive-bibtexextra texlive-fontsrecommended
```

That's the only outstanding system-level dependency. Everything else
(debuggers, formatters, linters, test adapters) was installed through
Mason, which doesn't need sudo.

## 2. Debugging (DAP) -- new

Backed by `nvim-dap` + `nvim-dap-ui` + `nvim-dap-virtual-text`. Adapters:

| Language | Adapter | Notes |
|---|---|---|
| C / C++ | `lldb-dap` (`/usr/sbin/lldb-dap`) | already installed, no codelldb needed |
| Python | `debugpy` via `nvim-dap-python` | already installed |
| Go | `delve` via `nvim-dap-go` | already installed (`~/go/bin/dlv`) |

Keymaps (global, in `keybinds.lua`):

- `<F5>` continue/start, `<F9>` toggle breakpoint, `<F10>` step over,
  `<F11>` step into, `<S-F11>` step out -- VSCode/Visual Studio
  convention, so there's nothing new to memorize if you've used those.
- `<leader>db` conditional breakpoint, `<leader>dr` toggle REPL,
  `<leader>dt` terminate session, `<leader>du` toggle the dapui panels
  (scopes/stacks/breakpoints/watches/console).

**Verified for real**: set a breakpoint in a plain C++ file, launched via
`lldb-dap`, hit the breakpoint, inspected a real backtrace and real local
variables (`Circle c`, `double a`) in the Locals panel. Same for Python
via debugpy (breakpoint hit, session stayed active while stopped). Go
isn't separately DAP-tested but `nvim-dap-go` is the standard, widely
used wrapper around the same delve binary neotest-go already proved
works.

For C/C++: there's no `dap.configurations.cpp` picker magic -- pressing
`<F5>` on a C/C++ buffer prompts for the path to the executable to debug.
If you're in a CMake project, use `<leader>kd` instead (see below) --
it launches the currently selected CMake target directly, no prompt.

## 3. CMake build/run/debug loop (`cmake-tools.nvim`) -- new

Addresses the "build/test loop is annoying" complaint directly. Ties
into the same `lldb-dap` adapter used by DAP above.

- `<leader>kc` configure (`CMakeGenerate`) -- builds into `out/<buildType>/`
- `<leader>kb` build, `<leader>kr` run, `<leader>kd` debug (DAP)
- `<leader>kt` select build target, `<leader>kl` select launch target
- `<leader>ko` open the CMake console

**Verified for real**: ran `CMakeGenerate` against a real `CMakeLists.txt`,
got a real `CMakeCache.txt`/`Makefile`/`compile_commands.json` in
`out/Debug/`.

The CMake language server itself was also swapped from the (old,
somewhat dead) `cmake-language-server` to `neocmakelsp`, which is
actively maintained and gives real completions in `CMakeLists.txt` files.

## 4. Generic task runner (`overseer.nvim`) -- new

For anything that isn't CMake: Go builds/tests, Python scripts, Bash
scripts, Makefiles.

- `<leader>or` run a task (prompts for a template/command)
- `<leader>ot` toggle the task list
- `<leader>oq` quick actions on the task under cursor (rerun, open output...)

## 5. Test runner (`neotest`) -- new

Run/debug individual tests without leaving the editor, with a visual
pass/fail gutter. Adapters: `neotest-go`, `neotest-python`.

- `<leader>tt` run nearest test, `<leader>tf` run whole file
- `<leader>td` debug nearest test (routes through DAP)
- `<leader>to` open output of the nearest test, `<leader>ts` toggle the
  summary tree (pass/fail counts across the whole suite)
- `<leader>tS` stop the nearest running test

**Verified for real**: ran an actual `pytest` test and an actual
`go test`, both came back `passed=1` via neotest's own internal state
tracker (not screen-scraped).

No mature C/C++ adapter exists for GTest/Catch2 in the neotest
ecosystem yet -- for C/C++ test binaries, debug them directly via DAP's
"Launch (lldb-dap)" config or `cmake-tools`'s `<leader>kd`/`<leader>kr`
instead.

## 6. Non-linear navigation -- new (`trouble.nvim`, `harpoon2`)

Directly answers "I want to see several symbols/refs at once, not just
jump one at a time":

- `<leader>xx` / `<leader>xX` -- all diagnostics, workspace / current buffer
- `<leader>cs` -- symbol outline for the current buffer
- `<leader>cl` -- LSP references/definitions/implementations as a list
  (this is the one worth using instead of jumping through `gd`/`gr` one
  at a time on a virtual-heavy class hierarchy)
- `<leader>xL` / `<leader>xQ` -- location list / quickfix list

Harpoon -- pin a handful of files and jump straight to them instead of
walking the jumplist:

- `<leader>a` add current file, `<leader>e` toggle the quick menu
- `<leader>1` .. `<leader>4` jump to pinned slot 1-4

## 7. Which-key -- new

Shows available keybinds in a popup after you press `<leader>` and
pause. Directly answers "I forget keybinds." I could not 100% confirm
the popup renders in my automated PTY test harness (no floating window
detected in several attempts, with no errors either -- possibly a
terminal-size artifact of the headless-PTY environment). It's installed
and configured correctly (`:WhichKey` runs with no errors). **Please
just press `<leader>` yourself and check** -- if nothing shows up after
~1 second, tell me and I'll dig further.

## 8. CMake/C/C++/Bash LSP & tooling fixes

- CMake LSP swapped `cmake-language-server` -> `neocmakelsp` (actively
  maintained, actually completes).
- `clangd` go-to-definition and go-to-implementation were tested against
  a real pure-virtual-method + override hierarchy and **both work
  correctly** when a correct `compile_commands.json` is present. If your
  real projects still feel broken here, the nvim config isn't the
  problem -- it's almost certainly a missing/stale `compile_commands.json`.
  For CMake projects: `cmake-tools.nvim`'s `<leader>kc` generates one
  automatically now. For Makefile-based projects, you'd need `bear` or
  `compiledb` (neither is installed; ask if you want one).
- `<leader>gh` -- clangd's header/source switch.
- Bash got real linting/formatting for the first time: `shellcheck` +
  `shfmt` wired into the `efm` formatter/linter chain, `bashls` enabled.
  `<leader>f` (format via efm) and inline diagnostics now work on `.sh`
  files the same way they already did for C/C++/Lua.

## 9. Snippets

`friendly-snippets` enabled (broad community snippet packs for every
filetype, auto-discovered). Plus one custom one you asked for:

Type `typedef struct` in a C or C++ file, and once you're mid-typing
"struct" the completion menu offers the full boilerplate:

```c
typedef struct {
	<cursor here>
} <TypeName>
```

with your cursor starting on the body, then tab-stop to the type name.

## 10. Markdown & LaTeX visualization -- new

- `render-markdown.nvim` (`<leader>mr` to toggle) -- in-editor rendering:
  styled headers, bullets, checkboxes, code block borders, table
  borders. Chosen over image.nvim because your terminal is **Alacritty**,
  which doesn't support the kitty graphics protocol image.nvim needs --
  this is the terminal-agnostic alternative. **Verified for real**: 10
  real extmarks placed on a test buffer (headers/bold/bullets/code
  fence all rendered).
- `markdown-preview.nvim` (`<leader>mp` to toggle) -- full
  browser-rendered live preview, for anything render-markdown can't do
  justice to in-terminal (tables, embedded images, complex layouts).
- `vimtex` for LaTeX -- compilation via `latexmk`, TOC, concealment, and
  forward/backward SyncTex search with `zathura` (already installed).
  **Needs texlive installed first** -- see section 1.

## 11. Two-liner QoL additions (committed earlier, already pushed-ready)

- Visual-mode `<S-f>`: grep the visual selection across the project
  (previously only worked on the word under the cursor in normal mode).
- `<leader>cp` / `<leader>cpl`: copy full path / full path:line (previous
  `<leader>cf` / `<leader>cfl` only copied the filename, not the path).

## 12. Performance

Startup is still ~50-65ms clean (headless, no UI), vs. the original
~120-150ms before this session's lazy-loading fixes. All of today's new
plugins are `ft`/`cmd`-gated (DAP/neotest only load when you open a
C/C++/Python/Go file; overseer/cmake-tools only load on their commands;
vimtex/render-markdown only load on `.tex`/`.md` files), so none of them
cost anything at startup for an unrelated file.

## Known open items

- Which-key popup rendering not independently confirmed (see section 7)
  -- please check and report back.
- No C/C++ unit test runner integration (neotest has no mature
  GTest/Catch2 adapter) -- debug test binaries directly via DAP instead.
- `bear`/`compiledb` not installed -- only matters if you have a
  Makefile-based (non-CMake) C/C++ project that needs a
  `compile_commands.json`.

---

# Session 2: a real bug hunt + "fly around files"

Everything below was added in a second pass specifically aimed at your
ask to stress-test for bugs, overlapping plugin behavior, and go further
on navigation/architecture. Two real, pre-existing bugs were found and
fixed (not things I introduced) -- see 13 and 18.

## 13. Fixed: gopls/lua_ls/ts_ls/html/cssls were installed but dead

`mason-lspconfig`'s `ensure_installed` had `gopls`, `lua_ls`, `ts_ls`,
`html`, `cssls` in it, but `vim.lsp.enable()` never included them --
**Go had zero LSP support this entire time**, and so did Lua (meaning
every time you've edited this very nvim config, you've had no
completions/diagnostics/go-to-def for it either). Fixed by adding all
five to the enable list. **Verified for real**: opened a `.go` file,
`gopls` attached; opened a `.lua` file, `lua_ls` attached.

Also added `lazydev.nvim` so `lua_ls` gives you proper `vim.*`
completions (pulled from installed plugins' own type annotations)
instead of generic-Lua-only completions while editing this config.

`<leader>f`/`<leader>fl` (format) previously did nothing on `.py`/`.go`
files too, despite the formatters being installed -- wired
black+isort (later swapped to `ruff`, see 17) and `gofumpt` into efm.

## 14. Fly-around-files tooling -- new

- **flash.nvim** (bare `s`/`S`): press `s`, type 2 characters near
  where you want to go, land there instantly -- works for any visible
  text, in any window, including across splits. `S` does the same but
  jumps to treesitter nodes (functions, classes, etc.) instead of raw
  text matches. This takes over vim's native single-char-substitute
  `s` -- a deliberate, well-established trade (use `cl` instead, which
  does the same thing).
- **gitsigns.nvim**: `]h`/`[h` next/previous hunk, `<leader>hs`/`hr`
  stage/reset a hunk, `<leader>hp` preview a hunk inline, `<leader>hb`
  blame the current line, `<leader>hd` diff the whole file. This is the
  inline, line-level git workflow diffview never covered (diffview is
  still there for full side-by-side diffs). **Verified for real**:
  attached to an actual git repo, detected actual uncommitted hunks.
- **grug-far.nvim** (`<leader>sr`, or visual-select then `<leader>sr`):
  project-wide search *and replace* with a live preview before you
  commit to it -- `live_grep` could only ever search, never replace.
  Directly useful for renaming something across many override sites in
  an inheritance-heavy codebase.
- **telescope-frecency** (`<leader>fr`): a file picker ranked by
  frequency + recency together, not just one or the other -- the
  actual answer to "fly around files" across sessions, beyond plain
  MRU. Needs `sqlite3` (already on this machine, no install needed).
- **telescope-live-grep-args** (`<leader>fa`): grep with ripgrep flags
  typed inline, e.g. restrict to `-g *.cpp`, add `-i` for
  case-insensitive -- addresses "ripgrep is weak" by letting you
  actually scope a search precisely instead of only ever doing a plain
  string/regex match.
- **persistence.nvim** (`<leader>Ss` restore session for this
  directory, `<leader>Sl` restore the last session anywhere,
  `<leader>Sd` don't save this session on exit): remembers your
  window/buffer layout per project directory, so hopping between e.g.
  the assimp practice repo and a quick Go/Python scratch dir doesn't
  mean losing your open files each time. **Verified for real**: a
  2-window layout round-tripped through an actual save+restore across
  two separate nvim processes.
- **nvim-autopairs**: auto-closes `(`/`{`/`[`/`"`/`'` as you type --
  was entirely missing before. **Verified for real**: typing `foo(`
  produces `foo()` with the cursor between the parens.
- **mini.surround** (`gza`/`gzd`/`gzr` add/delete/replace a surrounding
  pair, e.g. `gzd"` deletes surrounding quotes): moved to a `gz*`
  prefix instead of the usual `sa`/`sd`/`sr` specifically because
  flash.nvim already claims bare `s` -- this is the standard way the
  community resolves that exact conflict (LazyVim does the same).
- **nvim-treesitter-textobjects**: `af`/`if` (a/inner function),
  `ac`/`ic` (a/inner class), `aa`/`ia` (a/inner parameter) as operators
  -- e.g. `daf` deletes a whole function, `vac` selects a whole class.
  `]m`/`[m` jump to next/previous function start, `]]`/`[[` for class
  start (these override vim's native `]]`/`[[` section-jump, another
  deliberate trade -- section-jump is rarely used and class-jump is far
  more valuable in C++). `<leader>na`/`<leader>nb` swap the parameter
  under the cursor with the next/previous one. **Verified for real**
  via feedkeys-based tests: `vaf` selected exactly a function's line
  span, `]m` landed exactly on a function start, swapping two
  parameters actually reordered them in the buffer.

## 15. Fixed: telescope was loading on every single startup

`keybinds.lua` had `local builtin = require("telescope.builtin")` at
the top of the file (loaded unconditionally at startup), which forced
telescope to load eagerly every time regardless of its
`cmd = "Telescope"` lazy trigger -- a caveat flagged back in the first
pass and left alone at the time, fixed now that it was back under the
microscope. Every Telescope-calling keymap now wraps the `require` in
a closure so it only loads the first time you actually use a picker.
**Verified**: `package.loaded['telescope.builtin']` is `nil` at a plain
startup now, whereas before it was always loaded.

## 16. Fixed: nvim-treesitter-textobjects config was a silent no-op

The first pass configured `nvim-treesitter-textobjects` the
old/deprecated way -- a `textobjects = { select = {...}, move = {...} }`
block nested inside `nvim-treesitter.configs.setup()`. This plugin was
rewritten with its own standalone `setup()` and requires explicit
`vim.keymap.set()` calls; the old nested style is silently ignored on
the installed version. Pressing `vaf` did nothing. Rewritten correctly
(see 14) and re-verified.

## 17. Swapped python formatting/linting to ruff; deduped diagnostics

`black`+`isort` replaced with `ruff format`/`ruff check` -- one
rust-speed tool instead of two, same formatting philosophy (`ruff
format` is black-compatible so this won't reformat your existing code
differently). Along the way, found that `pylsp`'s own built-in
`pyflakes`/`pycodestyle`/`mccabe`/`pylint` plugins were producing
near-duplicate diagnostics for the same issues ruff already reports
(e.g. two separate "`os` imported but unused" messages for one unused
import) -- disabled those specific pylsp plugins so ruff is the sole
linter. Deliberately left pylsp's own *formatting* plugins untouched:
disabling those too made `<leader>f` silently do nothing for python
(root cause not fully nailed down -- not worth carrying a
poorly-understood breakage just to tidy up dead config).

## 18. CMake now uses Ninja + auto-exports compile_commands.json

`ninja` was already installed on this machine and builds noticeably
faster than the default "Unix Makefiles" generator, especially on
incremental rebuilds of something the size of assimp. `<leader>kc`
(`CMakeGenerate`) now passes `-G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=1`
automatically, so you get a fresh `compile_commands.json` for clangd
without remembering to pass that flag by hand. **Verified for real**:
`build.ninja`/`rules.ninja` and `compile_commands.json` all present
after a real `CMakeGenerate` run.

## 19. Dropped the "latex" treesitter parser

It was in `ensure_installed` but fails to compile every time --
tree-sitter-latex's build script passes a `--no-bindings` flag the
installed `tree-sitter` CLI (0.26.9) no longer accepts. vimtex doesn't
need this parser for its own syntax highlighting, compilation, or
SyncTex search, so nothing is lost by skipping it; just stops the
repeated failed-install noise on `:Lazy sync`.

## 20. New session testing discipline

Every item above marked "verified for real" was checked with an actual
spawned nvim process (not `--headless`, which never fires a real
`UIEnter` and is an unreliable proxy for anything UI/FileType-gated),
driving real keystrokes and reading the plugin's own internal state
(`require("dap").session()`, `nvim_buf_get_extmarks`, etc.) rather than
trusting that a config "should" work from reading its docs. This caught
three real, otherwise-invisible bugs (13, 16, 17) that a
docs-reading-only pass would have missed entirely.

See `PRACTICES.md` for suggestions beyond the editor itself -- the
build/test loop, sanitizers, git hooks, and so on.

## 21. Fixed: markdown rendering crash on fenced code blocks

You hit this live: opening a markdown file with a fenced code block (the
`sh` block in section 1 of this very file) crashed with `attempt to call
method 'range' (a nil value)` inside `vim.treesitter.get_node_text`,
triggered from render-markdown.nvim's parse step.

Root cause, confirmed by reading the actual source on disk (not
guessed): nvim-treesitter's `master` branch (which this config uses --
it's the old `configs.setup()`-style API, not the newer `main` rewrite)
ships its own `queries/markdown/injections.scm`, which resolves a fenced
block's language via a custom `#set-lang-from-info-string!` directive
in `lua/nvim-treesitter/query_predicates.lua`. That directive assumes
`match[capture_id]` is a single `TSNode` and calls `node:range()`
directly on it. Current Neovim (0.12.4) always passes directive
handlers an *array* of nodes per capture now -- the `all = false`
compatibility option nvim-treesitter's shim relied on to request a
single node was removed from `vim.treesitter.query.add_directive`'s
`Opts` (confirmed against `$VIMRUNTIME/lua/vim/treesitter/query.lua`,
which now only documents `force`). This is a genuine, currently-open
upstream incompatibility on nvim-treesitter's `master` tip (verified
we're already at tip, not stale -- `master`'s last update predates this
Neovim release).

Fix: `after/queries/markdown/injections.scm` overrides the plugin's
query with Neovim core's own (bug-free) version of the same file --
core captures `@injection.language` directly with no custom directive,
and core's injection logic resolves that capture's text as the
language name natively. Verified via PTY: the crash is gone, and the
```sh block in this file's section 1 still gets a real injected `bash`
parser (checked `vim.treesitter.get_parser(0):children()`), same for a
```c block elsewhere in this doc. The only loss versus the plugin's
version is info-string aliasing (e.g. a fence tagged `py` instead of
`python`) and case-insensitivity -- not a regression for this config,
since every fence tag actually used in these docs (`c`, `sh`) is
already an exact, lowercase parser name.
