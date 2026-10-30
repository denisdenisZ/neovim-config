# Beyond the editor: tightening the loop and leveling up practices

You asked for the tactical/technical angle on the develop-test loop, and
for habits/architecture advice beyond just editor mechanics. This is
that list, scoped to your actual stack (C/C++/CMake/Go/Python/Bash),
ordered roughly by effort-to-value ratio. Items marked **(needs sudo)**
I couldn't install myself this session (no interactive password) -- the
exact command is given so you can run it in one go when you're back.

## C/C++/CMake: the build loop itself

1. **ccache (needs sudo)** -- caches compiled object files keyed by
   content hash. The first full build of something like assimp is slow
   no matter what; ccache makes every subsequent build (branch
   switches, `git stash` round-trips, CI-vs-local re-builds of the same
   commit) dramatically faster, because object files you've already
   produced for identical source+flags get reused instead of
   recompiled.
   ```sh
   sudo pacman -S ccache
   ```
   Then tell CMake to use it (per-project, or add to `cmake-tools.lua`'s
   `cmake_generate_options` to make it the default everywhere):
   ```
   -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
   ```
2. **Ninja generator** -- already wired in for you (see
   `NVIM_FEATURES.md` #18). No action needed, just noting it's part of
   the same "faster loop" theme.
3. **mold linker (needs sudo)** -- the default GNU `ld` linker is
   often the single slowest step in a C++ link, especially for a
   binary with many translation units (like most of assimp's
   importers linked together). mold is a drop-in-faster linker.
   ```sh
   sudo pacman -S mold
   ```
   Then add `-fuse-ld=mold` to `CMAKE_EXE_LINKER_FLAGS`/
   `CMAKE_SHARED_LINKER_FLAGS`, or set
   `CMAKE_LINKER_TYPE=MOLD` (CMake >= 3.29, which you have).
4. **Sanitizers as a standing build mode** -- this is the highest
   bug-catching-per-effort-minute practice available for C/C++. Add a
   `Debug-ASan` configure preset (or just a second `out/` build dir)
   with:
   ```
   -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer -g"
   ```
   Run your normal test suite against that build. Memory errors and UB
   that would otherwise show up as a confusing segfault three functions
   away (exactly the kind of thing that sends you into a DAP session to
   hunt down) instead abort immediately at the real fault site with a
   readable report. Catching it there is strictly cheaper than catching
   it in the debugger later.
5. **CMakePresets.json** -- if you don't already use these, they're
   worth adopting: a committed, reproducible way to express "the ASan
   build", "the Ninja release build", etc. as named presets instead of
   remembering flag combinations. `cmake-tools.nvim` has native preset
   support (`<leader>kc` will offer a preset picker if a
   `CMakePresets.json` exists in the project root) -- no nvim config
   change needed, just add the file to projects as you touch them.
6. **bear / compiledb** -- only matters for Makefile-based (non-CMake)
   C/C++ projects that need a `compile_commands.json` for clangd. Not
   installed; ask if you want one (`bear` wraps a real build and
   records the exact commands actually run, which is more reliable than
   compiledb's parsing approach for complex Makefiles).

## Python

- `ruff` (now wired into the editor, see `NVIM_FEATURES.md` #17) is
  also worth using as your CLI linter/formatter directly, same tool,
  zero extra setup: `ruff check .` / `ruff format .` across a whole
  project in well under a second even on large codebases.
- Type hints + a type checker pay off fast once a codebase gets past
  "small script" size -- pylsp's built-in type checking is weak. If
  you start feeling that gap, `pyright`/`basedpyright` (swap-in
  replacement for pylsp as the completion/hover source, keep pylsp or
  drop it) catches a different class of bug than ruff does (ruff is
  style+correctness-smell; a type checker is actual type errors).

## Go

- `gopls` now actually runs (see `NVIM_FEATURES.md` #13) with
  `staticcheck` enabled -- that's already a meaningfully stronger
  check set than `go vet` alone.
- Habit, not tooling: reach for `go test -race` by default on anything
  touching goroutines/channels. The race detector only flags races it
  actually observes during that run, so it's only as good as your test
  coverage of the concurrent paths -- but it's free and catches a class
  of bug that's otherwise brutal to reproduce.
- Table-driven tests (`[]struct{ name string; in ...; want ... }`) are
  the Go-idiomatic way to get a lot of `neotest` mileage: each case
  shows up as its own named result in the summary panel (`<leader>ts`).

## Bash

- `shellcheck`/`shfmt` are now wired in (see `NVIM_FEATURES.md` #8).
  Habit to pair with it: `set -euo pipefail` at the top of any script
  meant to be more than a one-off -- fails loud on an unset variable or
  a failed command in a pipeline instead of silently continuing.

## Closing the loop automatically: git hooks

Right now, formatting/linting only happens when you remember to press
`<leader>f` or `<leader>xx`. A pre-commit framework
(https://pre-commit.com, or even a plain `.git/hooks/pre-commit` shell
script) running the exact same tools already wired into efm
(`clang-format`/`clang-tidy`, `shfmt`/`shellcheck`, `ruff`, `gofumpt`,
`stylua`) at commit time closes that loop without relying on memory --
and it's the same check CI would run, so you get the feedback locally,
before a push, rather than after. This is a "set up once per repo,
benefit forever" change and is probably the single highest-leverage
habit change on this list that isn't pure editor config.

## Architecture-level habits (not tooling)

- **Inheritance-heavy C++ (your stated pain point): prefer composition
  at the boundary, reserve deep virtual hierarchies for genuinely
  open-ended extension points** (assimp's `BaseImporter` is a good
  example of where it's actually earned -- an unbounded, plugin-style
  set of file formats). When a hierarchy exists mainly to share code
  between a *known, closed* set of siblings, a free function or a
  composed helper is usually easier to navigate later than another
  virtual layer -- and it's also easier for `<leader>cl` (Trouble's LSP
  list) and `<leader>gi` (go to implementation) to reason about, since
  there's less indirection to walk through.
- **Keep the thing you're actively changing buildable in under ~10
  seconds.** If a change forces a full project rebuild to test, that's
  usually a sign a header is too widely included (pImpl / forward
  declarations are the classic C++ fix) or a module boundary is too
  coarse (Go/Python equivalent: a package doing too much, so touching
  one function forces re-running an unrelated test file). This is the
  single biggest lever on "tightest loop" that no tool can do for
  you -- it's a structural property of the code, not the editor.
- **Write the test before the fix when debugging, not after.** You now
  have `<leader>td` (debug nearest test under DAP) -- the fast cycle is:
  reproduce the bug as a failing test, debug *that* test with a
  breakpoint instead of the whole program, fix, watch it go green.
  This is faster in practice than attaching a debugger to the full
  program each time, and you keep the regression test afterward for
  free.
