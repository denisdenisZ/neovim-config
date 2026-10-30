# Exercises: put the new setup through its paces

Practice repo: `~/apps/repos/practice/assimp` (Open Asset Import Library,
cloned shallow -- real, large, CMake-based, and built around a
virtual-dispatch `BaseImporter` plugin architecture, which is exactly
the "C++ inheritance pipelines" problem you described). I could not run
`cmake` inside it myself -- Claude Code's sandbox blocks executing a
freshly-downloaded repo's own build scripts, correctly, since that's
effectively running untrusted code. You'll need to configure it
yourself first:

```sh
cd ~/apps/repos/practice/assimp
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DASSIMP_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Debug
ln -sf build/compile_commands.json compile_commands.json   # so clangd finds it from the project root
```

That gives clangd a real `compile_commands.json` for the whole project.

## C++ / CMake exercises (assimp)

1. **Non-linear navigation on a real inheritance chain.** Open
   `include/assimp/BaseImporter.h`. Put the cursor on `CanRead` (the
   pure-virtual at line ~116) and press `<leader>cl` (Trouble: LSP
   list). You should get a flat list of every importer's override
   (`ObjFileImporter::CanRead`, `FBXImporter::CanRead`, ...) instead of
   having to `gi` through them one at a time. Compare against pressing
   `<leader>gi` (go to implementation) directly on `CanRead` -- note
   that with a real `compile_commands.json` in place, this should
   actually land on a concrete override now, not "go nowhere" like you
   described before.
2. **Harpoon a working set.** You're tracing how OBJ files get loaded:
   pin `code/AssetLib/Obj/ObjFileImporter.h`,
   `code/AssetLib/Obj/ObjFileImporter.cpp`, and
   `code/Common/Importer.cpp` with `<leader>a` on each, then bounce
   between them with `<leader>1`/`<leader>2`/`<leader>3` instead of
   `:e`-ing each one by path.
3. **Visual-selection grep.** Visually select the string `InternReadFile`
   anywhere it appears, press `<S-f>` -- confirm it searches the whole
   project, not just the current buffer.
4. **Snippet.** In a throwaway `.cpp` scratch file (don't commit
   anything inside assimp), type `typedef struct` and accept the
   completion -- confirm the cursor lands where you can immediately type
   the type name.
5. **Build + debug loop.** `<leader>kc` to configure (should be instant
   since you already ran it once by hand), `<leader>kt` to pick a small
   target (e.g. `assimp_cmd` or one of the importer test tools if
   enabled), `<leader>kb` to build it, then set a breakpoint
   (`<F9>`) inside `ObjFileImporter::InternReadFile` and `<leader>kd` to
   debug it. Confirm you actually stop at the breakpoint with real
   locals visible (`<leader>du` if the DAP UI didn't auto-open).
6. **Clangd header/source switch.** Open any `.cpp` in `code/AssetLib/`,
   press `<leader>gh`, confirm it jumps to the matching header.
7. **Trouble + diagnostics.** Deliberately break something trivial (add
   a typo to a local scratch copy, not the real file) and confirm
   `<leader>xx` surfaces it.
8. **Flash across a file.** In `code/Common/Importer.cpp`, press `s`
   and type the 2-character label for any visible occurrence of
   `ReadFile` -- confirm you land on it instantly instead of scrolling
   or searching.
9. **Textobjects on a real class.** In `include/assimp/BaseImporter.h`,
   put the cursor anywhere inside the `BaseImporter` class body and
   try `vac` (select the whole class) and `]m`/`[m` to hop between
   method declarations.
10. **Grug-far a rename.** Pick a locally-scoped symbol (not something
    exported across the whole library) and try `<leader>sr` to preview
    a project-wide rename before committing to it. Don't actually save
    the changes unless you mean to -- this is a real codebase.
11. **Gitsigns.** Make a trivial one-line edit to a throwaway copy of a
    tracked file, confirm `]h` jumps to the hunk and `<leader>hp`
    previews it inline.
12. **Frecency.** After you've opened a handful of files above, press
    `<leader>fr` and confirm the ones you just touched rank near the
    top.

## Go exercise (throwaway, anywhere e.g. `/tmp`)

`gopls` had never actually been enabled before this session (see
`NVIM_FEATURES.md` #13) -- worth specifically confirming you now get
real completions/diagnostics on `.go` files, not just test running.

Write a tiny package with one function and one table-driven test.
- Confirm gopls completion/hover works at all (type `fmt.` and check
  you get real completions).
- `<leader>tt` on the test function, confirm pass/fail shows inline.
- `<leader>td` to debug it via delve -- set a breakpoint inside the
  function under test first.
- Try `<leader>na`/`<leader>nb` on a multi-parameter function call to
  swap argument order.

## Python exercise

Same shape: a function + a `pytest` test.
- `<leader>tt` / `<leader>ts` (summary panel) for the test.
- `<F9>` + `<F5>` to debug the script directly (not through pytest) and
  confirm you can inspect a variable mid-function in the DAP UI.
- Write a file with an unused import and bad spacing, press `<leader>f`
  -- confirm `ruff` (swapped in for black+isort, see
  `NVIM_FEATURES.md` #17) both reformats it and flags the unused import
  as a diagnostic, without a duplicate message from pylsp.

## Bash exercise

Write a deliberately sloppy script (unquoted variable, useless `cat`
piped into `grep`, etc.) and confirm:
- `<leader>f` (format via efm -> shfmt) reindents it.
- Diagnostics (shellcheck) actually flag the issues -- check `<leader>xx`.

## Markdown / LaTeX exercise

- Open any `.md` file with headers/bullets/a code block, `<leader>mr` to
  toggle in-editor rendering, `<leader>mp` to toggle the full browser
  preview side by side -- compare the two.
- Once you've installed texlive (see `NVIM_FEATURES.md` section 1):
  write a minimal `.tex` doc, compile with vimtex's default mapping
  (`\ll`), and confirm forward search (`\lv`) jumps zathura to the right
  page.

## If something breaks

Tell me what you pressed and what you expected vs. what happened --
specifics (file, cursor position, exact keys) let me reproduce it in a
real PTY test rather than guessing.

See also `PRACTICES.md` for the beyond-the-editor side: build-loop
speedups (ccache/mold/sanitizers), git hooks, and a few architecture
habits aimed specifically at the inheritance-heavy C++ pain point.
