-- Repo-scoped workspaces: each tab is one repository via :tcd.
-- Used by the project picker, workspace keymaps, and bufferline.

local M = {}

---@param path string|nil
---@return string|nil
function M.normalize(path)
  if not path or path == "" then
    return nil
  end
  path = vim.fs.normalize(path)
  local real = vim.uv.fs_realpath(path)
  if real then
    path = real
  else
    path = vim.fn.fnamemodify(path, ":p")
  end
  path = path:gsub("/+$", "")
  if path == "" then
    return "/"
  end
  return path
end

---@param tab integer|nil tabpage handle; nil = current
---@return integer
local function tabnr_of(tab)
  if tab then
    return vim.api.nvim_tabpage_get_number(tab)
  end
  return 0
end

---@param tab integer|nil tabpage handle; nil = current
---@return string|nil
function M.tab_cwd(tab)
  return M.normalize(vim.fn.getcwd(-1, tabnr_of(tab)))
end

---@param tab integer|nil tabpage handle; nil = current
---@return boolean
function M.has_local_cwd(tab)
  return vim.fn.haslocaldir(-1, tabnr_of(tab)) == 1
end

---@param path string
---@return integer|nil tabpage handle
function M.find_tab(path)
  local target = M.normalize(path)
  if not target then
    return nil
  end
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if M.tab_cwd(tab) == target then
      return tab
    end
  end
  return nil
end

---@param path string|nil
---@return string|nil
function M.repo_root(path)
  if not path or path == "" or path:match("^%w+://") then
    return nil
  end
  local root = vim.fs.root(path, ".git")
  if root then
    return M.normalize(root)
  end
  if vim.fn.isdirectory(path) == 1 then
    return M.normalize(path)
  end
  return M.normalize(vim.fs.dirname(path))
end

local SKIP_DIR = {
  node_modules = true,
  target = true,
  vendor = true,
  dist = true,
  build = true,
}

local MAX_REPO_DEPTH = 8

---@param dir string
---@return boolean
local function is_git_repo(dir)
  local st = vim.uv.fs_lstat(dir .. "/.git")
  return st ~= nil and (st.type == "directory" or st.type == "file")
end

---@param dir string
---@return boolean
local function is_dir(dir)
  local st = vim.uv.fs_stat(dir)
  return st ~= nil and st.type == "directory"
end

--- Git repos under `roots`. Recurses into grouping folders, but does not
--- descend into a directory once `.git` is found (no nested/submodule hits).
---@param roots string[]|string|nil
---@return string[]
function M.list_repos(roots)
  if type(roots) == "string" then
    roots = { roots }
  end
  local found = {}
  local seen = {}

  local function walk(dir, depth)
    if depth > MAX_REPO_DEPTH then
      return
    end
    dir = M.normalize(dir)
    if not dir or seen[dir] then
      return
    end
    seen[dir] = true

    if is_git_repo(dir) then
      found[#found + 1] = dir
      return
    end

    local handle = vim.uv.fs_scandir(dir)
    if not handle then
      return
    end
    while true do
      local name = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end
      if not SKIP_DIR[name] and not name:match("^%.") then
        local child = dir .. "/" .. name
        if is_dir(child) then
          walk(child, depth + 1)
        end
      end
    end
  end

  for _, root in ipairs(roots or {}) do
    local dir = vim.fn.fnamemodify(vim.fs.normalize(root), ":p")
    if vim.fn.isdirectory(dir) == 1 then
      walk(dir, 0)
    end
  end

  return found
end

--- Label every tab as "N reponame" so Alt+1-9 still matches the bar.
--- Bufferline reads t:name for the tab-page indicators.
function M.sync_tab_names()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local nr = vim.api.nvim_tabpage_get_number(tab)
    local repo = vim.t[tab].repo_name
    if not repo or repo == "" then
      local cwd = M.tab_cwd(tab)
      if cwd then
        repo = vim.fn.fnamemodify(cwd, ":t")
        vim.t[tab].repo_name = repo
      end
    end
    local label = (repo and repo ~= "") and (nr .. " " .. repo) or tostring(nr)
    pcall(vim.api.nvim_tabpage_set_var, tab, "name", label)
  end
  pcall(function()
    require("bufferline.ui").refresh()
  end)
end

---@param path string
function M.tcd(path)
  local dir = M.normalize(path)
  if not dir then
    return
  end
  vim.cmd.tcd(vim.fn.fnameescape(dir))
  vim.t.repo_name = vim.fn.fnamemodify(dir, ":t")
  M.sync_tab_names()
end

--- Return the window ID in the current tab that is displaying `bufnr`, or nil.
---@param bufnr integer|nil
---@return integer|nil
local function find_win_for_buf(bufnr)
  if bufnr == nil or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end

--- True if the current buffer is an unmodified unnamed scratch (e.g. from :tabnew).
---@return boolean
local function current_buf_is_empty_scratch()
  local buf = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(buf) == ""
    and vim.bo[buf].buftype == ""
    and not vim.bo[buf].modified
end

--- Open or focus this tab's main terminal (same as Alt-Enter).
--- The shell inherits the tab cwd (repo root). An empty scratch window is
--- replaced so a new project tab does not keep a leftover [No Name] buffer.
function M.open_main_term()
  local win = find_win_for_buf(vim.t.main_term_bufnr)
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd("startinsert")
    return
  end

  local scratch = vim.api.nvim_get_current_buf()
  local replace = current_buf_is_empty_scratch()
  if replace then
    vim.cmd("terminal")
  else
    vim.cmd("split | terminal")
  end
  vim.t.main_term_bufnr = vim.api.nvim_get_current_buf()
  if replace and scratch ~= vim.t.main_term_bufnr and vim.api.nvim_buf_is_valid(scratch) then
    vim.api.nvim_buf_delete(scratch, { force = true })
  end
  vim.cmd("startinsert")
end

--- Jump to the tab for `path`, or open a new tab and :tcd there.
---@param path string
function M.open_repo(path)
  local dir = M.normalize(path)
  if not dir then
    return
  end
  if vim.fn.isdirectory(dir) == 0 then
    dir = M.repo_root(dir) or M.normalize(vim.fs.dirname(dir))
  end
  if not dir then
    return
  end

  local tab = M.find_tab(dir)
  if tab then
    vim.api.nvim_set_current_tabpage(tab)
    if not M.has_local_cwd(tab) then
      M.tcd(dir)
    end
  else
    vim.cmd("tabnew")
    M.tcd(dir)
    M.open_main_term()
  end

  vim.t.repo_name = vim.t.repo_name or vim.fn.fnamemodify(dir, ":t")
  vim.notify("Workspace: " .. vim.t.repo_name, vim.log.levels.INFO)
end

--- True if `path` is `cwd` or a file inside it (path-boundary safe).
---@param path string
---@param cwd string|nil
---@return boolean
function M.path_under_cwd(path, cwd)
  cwd = M.normalize(cwd or vim.fn.getcwd())
  path = M.normalize(path)
  if not cwd or not path then
    return false
  end
  return path == cwd or vim.startswith(path, cwd .. "/")
end

--- Visible in this tab, or a normal file under this tab's cwd.
---@param buf integer
---@return boolean
function M.buf_in_workspace(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return true
    end
  end
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return false
  end
  return M.path_under_cwd(name)
end

--- Existing files of listed workspace buffers (for grep).
---@return string[]
function M.workspace_file_paths()
  local paths = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and M.buf_in_workspace(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" and vim.uv.fs_stat(name) then
        paths[#paths + 1] = name
      end
    end
  end
  return paths
end

--- Alternate buffer if it belongs here, else most recently used workspace buffer.
---@return integer|nil
function M.alternate_buf()
  local alt = vim.fn.bufnr("#")
  if alt > 0 and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted and M.buf_in_workspace(alt) then
    return alt
  end
  local cur = vim.api.nvim_get_current_buf()
  local best, best_used = nil, 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and M.buf_in_workspace(buf) then
      local info = vim.fn.getbufinfo(buf)[1]
      if info and info.lastused > best_used then
        best, best_used = buf, info.lastused
      end
    end
  end
  return best
end

--- Snacks picker filter: keep items in this workspace.
---@return table
function M.picker_filter()
  return {
    filter = function(item)
      if item.buf then
        return M.buf_in_workspace(item.buf)
      end
      if item.file then
        return M.path_under_cwd(item.file)
      end
      return false
    end,
  }
end

return M
