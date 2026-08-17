-- LazyGit → Diffview bridge.
--
-- Writes a LazyGit config fragment so `E` on a commit, branch, tag, or stash
-- closes the LazyGit float and opens Diffview against the working tree
-- (`:DiffviewOpen <ref>`, which already passes --imply-local).
--
-- Snacks cannot serialize customCommands (list of maps), so this lives in its
-- own YAML file and is appended to LG_CONFIG_FILE before LazyGit starts.

local M = {}

local cache = vim.fn.stdpath("cache")
local extra_yml = cache .. "/lazygit-diffview.yml"
local script_path = cache .. "/lazygit-diffview.sh"
local ref_path = cache .. "/lazygit-diffview-ref"

local function close_lazygit()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:find("lazygit", 1, true) then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end
end

--- Open Diffview for `ref` vs the working tree. Called from the LazyGit helper script.
---@param ref string
---@return string
function M.diffview(ref)
  if not ref or ref == "" then
    vim.notify("LazyGit Diffview: no git ref", vim.log.levels.WARN)
    return ""
  end
  vim.schedule(function()
    close_lazygit()
    -- Defer DiffviewOpen until after the lazygit window close has fully
    -- settled. Opening immediately causes diffview's sync_scroll to call
    -- nvim_win_call on a stale window handle, producing a layout error.
    vim.defer_fn(function()
      local ok, err = pcall(vim.cmd, "DiffviewOpen " .. vim.fn.fnameescape(ref))
      if not ok then
        vim.notify("DiffviewOpen failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end, 50)
  end)
  return ""
end

--- Read the ref written by the helper script, then open Diffview.
---@return string
function M.diffview_from_file()
  local ok, lines = pcall(vim.fn.readfile, ref_path)
  pcall(vim.fn.delete, ref_path)
  if not ok or not lines or #lines == 0 then
    vim.notify("LazyGit Diffview: no ref received", vim.log.levels.WARN)
    return ""
  end
  return M.diffview(table.concat(lines, "\n"))
end

local function write_script()
  local lines = {
    "#!/usr/bin/env bash",
    "set -euo pipefail",
    'ref="${1-}"',
    'if [[ -z "$ref" ]]; then',
    '  echo "lazygit-diffview: missing git ref" >&2',
    "  exit 1",
    "fi",
    'if [[ -z "${NVIM-}" ]]; then',
    '  echo "lazygit-diffview: open lazygit from Neovim (<leader>gg)" >&2',
    "  exit 1",
    "fi",
    string.format("printf '%%s' \"$ref\" > %s", vim.fn.shellescape(ref_path)),
    [[nvim --server "$NVIM" --remote-expr "v:lua.require('config.lazygit').diffview_from_file()"]],
  }
  vim.fn.writefile(lines, script_path)
  vim.fn.setfperm(script_path, "rwxr-xr-x")
end

local function write_yml()
  -- Single-quoted YAML so `| quote` and `{{...}}` stay literal for LazyGit.
  local lines = {
    -- Override edit commands so `e` opens in the current window/tab, not a new
    -- tab. Lazygit's built-in nvim-remote preset uses --remote-tab; we swap it
    -- for --remote so the file lands in the current tab's active window.
    "os:",
    '  edit: "nvim --server \\"$NVIM\\" --remote {{filename}}"',
    '  editAtLine: "nvim --server \\"$NVIM\\" --remote {{filename}} && nvim --server \\"$NVIM\\" --remote-send \\":{{line}}<CR>\\""',
    '  editAtLineAndWait: "nvim --server \\"$NVIM\\" --remote-wait {{filename}} && nvim --server \\"$NVIM\\" --remote-send \\":{{line}}<CR>\\""',
    "customCommands:",
    '  - key: "E"',
    '    context: "commits, subCommits, reflogCommits"',
    '    description: "Diffview vs working tree"',
    '    loadingText: "Opening Diffview"',
    string.format("    command: '%s {{.SelectedCommit.Hash | quote}}'", script_path),
    "    output: none",
    '  - key: "E"',
    '    context: "localBranches"',
    '    description: "Diffview vs working tree"',
    '    loadingText: "Opening Diffview"',
    string.format("    command: '%s {{.SelectedLocalBranch.Name | quote}}'", script_path),
    "    output: none",
    '  - key: "E"',
    '    context: "remoteBranches"',
    '    description: "Diffview vs working tree"',
    '    loadingText: "Opening Diffview"',
    string.format(
      "    command: '%s {{printf \"%%s/%%s\" .SelectedRemoteBranch.RemoteName .SelectedRemoteBranch.Name | quote}}'",
      script_path
    ),
    "    output: none",
    '  - key: "E"',
    '    context: "tags"',
    '    description: "Diffview vs working tree"',
    '    loadingText: "Opening Diffview"',
    string.format("    command: '%s {{.SelectedTag.Name | quote}}'", script_path),
    "    output: none",
    '  - key: "E"',
    '    context: "stash"',
    '    description: "Diffview vs working tree"',
    '    loadingText: "Opening Diffview"',
    string.format("    command: '%s {{printf \"stash@{%%d}\" .SelectedStashEntry.Index | quote}}'", script_path),
    "    output: none",
  }
  vim.fn.writefile(lines, extra_yml)
end

local function ensure_config_file()
  local files = {}
  if vim.env.LG_CONFIG_FILE and vim.env.LG_CONFIG_FILE ~= "" then
    files = vim.split(vim.env.LG_CONFIG_FILE, ",", { plain = true })
  else
    local default = vim.fn.expand("~/.config/lazygit/config.yml")
    if vim.uv.fs_stat(default) then
      files[1] = default
    end
  end
  if not vim.tbl_contains(files, extra_yml) then
    table.insert(files, extra_yml)
  end
  vim.env.LG_CONFIG_FILE = table.concat(files, ",")
end

function M.setup()
  vim.fn.mkdir(cache, "p")
  write_script()
  write_yml()
  ensure_config_file()
end

return M
