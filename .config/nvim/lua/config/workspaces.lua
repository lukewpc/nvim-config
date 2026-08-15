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

---@param path string
function M.tcd(path)
  local dir = M.normalize(path)
  if not dir then
    return
  end
  vim.cmd.tcd(vim.fn.fnameescape(dir))
  vim.t.repo_name = vim.fn.fnamemodify(dir, ":t")
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

return M
