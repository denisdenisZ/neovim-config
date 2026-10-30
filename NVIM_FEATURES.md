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
