-- ============================================================
-- KEYMAP USAGE TRACKER
--
-- Answers "what am I actually using and how often" -- the other half
-- of the hardtime.nvim loop (hardtime nags about bad habits as they
-- happen; this records which of this config's *good* keybinds you
-- do/don't reach for, across sessions). See CHEATSHEET.md Part 4.
--
-- How it works: wraps vim.keymap.set (must be required before
-- anything else calls it -- see init.lua) so every mapping that goes
-- through the normal API gets catalogued (mode+lhs -> desc), and every
-- mapping whose rhs is a Lua function additionally gets its actual
-- invocation counted. String-rhs mappings (e.g. "<cmd>Foo<CR>") are
-- catalogued but NOT invocation-wrapped -- rewriting an arbitrary rhs
-- string into an equivalent function is not reliably safe across every
-- mode/opts combination (expr mappings, operator-pending, recursive
-- vs noremap), so those just always show as "not tracked" rather than
-- risking a behavior change on a real keybind. Multi-mode specs
-- (mode = {"n","x","o"}) are attributed to whichever mode was actually
-- active at invocation time, not the static list.
--
-- Persisted to stdpath("state")/keymap_usage.json, loaded on setup and
-- saved on VimLeavePre + a periodic timer (session can get killed -9
-- during testing/crashes, don't lose data silently).
-- ============================================================

local M = {}

local catalog = {} -- "mode:lhs" -> desc
local counts = {} -- "mode:lhs" -> count
local save_path = vim.fn.stdpath("state") .. "/keymap_usage.json"

-- which-key.nvim registers internal bookkeeping keymaps (digit prefixes,
-- raw motions it needs to observe for its own popup) through the same
-- vim.keymap.set API, tagged with these desc values -- noise, not real
-- user-facing keybinds worth reporting on.
local function is_noise(desc)
    return desc == "which_key_ignore" or desc:match("^which%-key%-trigger")
end

local function load()
    local f = io.open(save_path, "r")
    if not f then
        return
    end
    local content = f:read("*a")
    f:close()
    if content == "" then
        return
    end
    local ok, decoded = pcall(vim.json.decode, content)
    if ok and type(decoded) == "table" then
        counts = decoded
    end
end

local function save()
    local ok, encoded = pcall(vim.json.encode, counts)
    if not ok then
        return
    end
    local f = io.open(save_path, "w")
    if not f then
        return
    end
    f:write(encoded)
    f:close()
end

function M.setup()
    load()

    local orig_set = vim.keymap.set
    vim.keymap.set = function(mode, lhs, rhs, opts)
        opts = opts or {}

        -- Catalog every desc'd mapping, regardless of rhs type.
        if opts.desc and not is_noise(opts.desc) then
            local modes = type(mode) == "table" and mode or { mode }
            for _, m in ipairs(modes) do
                catalog[m .. ":" .. lhs] = opts.desc
            end
        end

        -- Only function rhs gets invocation-wrapped (safe: pure
        -- pre-call side effect, same args/return passed through).
        if type(rhs) == "function" and opts.desc and not is_noise(opts.desc) then
            local original_rhs = rhs
            rhs = function(...)
                local actual_mode = vim.api.nvim_get_mode().mode:sub(1, 1)
                local key = actual_mode .. ":" .. lhs
                counts[key] = (counts[key] or 0) + 1
                return original_rhs(...)
            end
        end

        return orig_set(mode, lhs, rhs, opts)
    end

    local augroup = vim.api.nvim_create_augroup("keymap-tracker", { clear = true })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = augroup,
        callback = save,
    })

    local timer = vim.uv.new_timer()
    timer:start(60000, 60000, vim.schedule_wrap(save))

    vim.api.nvim_create_user_command("KeymapStats", function(cmd_opts)
        M.report(cmd_opts.args)
    end, {
        nargs = "?",
        desc = "Show keymap usage stats (args: 'unused' to only list never-used mappings)",
    })

    vim.api.nvim_create_user_command("KeymapStatsReset", function()
        counts = {}
        save()
        vim.notify("Keymap usage stats reset", vim.log.levels.INFO)
    end, { desc = "Reset keymap usage stats" })
end

function M.report(filter)
    -- Pull in current buffer-local mappings too (gitsigns/git-conflict/
    -- bookmarks on_attach etc.) so they show up in the catalog even if
    -- this is the first time this buffer type was opened this session.
    for _, mode in ipairs({ "n", "x", "o", "i", "v" }) do
        for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
            if m.desc and m.desc ~= "" and not is_noise(m.desc) then
                catalog[mode .. ":" .. m.lhs] = m.desc
            end
        end
    end

    local entries = {}
    for key, desc in pairs(catalog) do
        local count = counts[key] or 0
        table.insert(entries, { key = key, desc = desc, count = count })
    end
    table.sort(entries, function(a, b)
        if a.count ~= b.count then
            return a.count > b.count
        end
        return a.key < b.key
    end)

    local lines = {}
    local used, unused = {}, {}
    for _, e in ipairs(entries) do
        local mode, lhs = e.key:match("^(.-):(.*)$")
        local line = string.format("%-14s %-5s %s", lhs, mode, e.desc)
        if e.count > 0 then
            table.insert(used, string.format("%4d  %s", e.count, line))
        else
            table.insert(unused, line)
        end
    end

    if filter ~= "unused" then
        table.insert(lines, "=== Most used ===")
        vim.list_extend(lines, used)
        table.insert(lines, "")
    end
    table.insert(lines, "=== Never used this session/history (" .. #unused .. ") ===")
    vim.list_extend(lines, unused)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = "keymapstats"
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.cmd("vsplit")
    vim.api.nvim_win_set_buf(0, buf)
end

return M
