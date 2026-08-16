-- Keymaps are automatically loaded on the VeryLazy event
-- Default LazyVim keymaps: https://lazyvim.github.io/keymaps
-- Add any additional keymaps here

local map = vim.keymap.set
local workspaces = require("config.workspaces")

-- ╭─────────────────────────────────────────────────────────╮
-- │ General                                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- NOTE: LazyVim already provides: <C-s> save, <Esc> nohl,
-- <C-h/j/k/l> window nav, <C-arrows> resize, </>gv indent

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Lines                                                    │
-- ╰─────────────────────────────────────────────────────────╯

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor centered when searching (LazyVim handles direction but not centering)
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Don't yank on paste in visual mode
map("x", "p", [["_dP]], { desc = "Paste without yanking" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Oil.nvim                                                 │
-- ╰─────────────────────────────────────────────────────────╯

map("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory (Oil)" })
map("n", "<leader>e", function()
  require("oil").open(vim.fn.getcwd())
end, { desc = "Explorer (workspace root)" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Config                                                   │
-- ╰─────────────────────────────────────────────────────────╯

map("n", "<leader>rn", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "Reload Neovim config" })

-- ╭─────────────────────────────────────────────────────────╮
-- │ Terminal                                                  │
-- ╰─────────────────────────────────────────────────────────╯

map("t", "<C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Shift+Enter: insert a newline in the terminal process (e.g. Kiro CLI multi-line input)
map("t", "<S-CR>", function()
  local chan = vim.bo[vim.api.nvim_get_current_buf()].channel
  if chan and chan > 0 then
    vim.fn.chansend(chan, "\n")
  end
end, { desc = "Newline in terminal (Shift+Enter)" })

--- Return the window ID that is currently displaying `bufnr`, or nil.
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

--- Focus `win` and enter insert mode (so the terminal is immediately usable).
local function focus_win(win)
  vim.api.nvim_set_current_win(win)
  vim.cmd("startinsert")
end

-- Alt-Backslash: open (or focus) this tab's kiro terminal (bottom left).
local function open_or_focus_kiro_term()
  local win = find_win_for_buf(vim.t.kiro_term_bufnr)
  if win then
    focus_win(win)
    return
  end
  -- Register the TermOpen handler BEFORE opening the terminal, because
  -- TermOpen fires synchronously inside vim.cmd("split | terminal") and
  -- would be missed if registered afterwards.
  vim.api.nvim_create_autocmd("TermOpen", {
    once = true,
    callback = function(ev)
      vim.t.kiro_term_bufnr = ev.buf
      local chan = vim.bo[ev.buf].channel
      if chan and chan > 0 then
        vim.fn.chansend(chan, "kiro-cli\n")
      end
    end,
  })
  vim.cmd("split | terminal")
  -- Move this pane to the far left so it sits left of the main terminal.
  vim.cmd("wincmd H")
end

-- ╭─────────────────────────────────────────────────────────╮
-- │ i3-like workflow (Alt as modifier)                        │
-- ╰─────────────────────────────────────────────────────────╯
-- Mental model:
--   Alt+h/j/k/l       = focus pane (directional)
--   Alt+Shift+h/j/k/l = move/swap pane
--   Alt+-             = split horizontal (pane below)
--   Alt+=             = split vertical (pane right)
--   Alt+r             = resize mode (arrows move divider, Esc or Alt+r to finish)
--   Alt+Enter         = open/focus this workspace's main terminal
--   Alt+Backslash     = open/focus this workspace's kiro terminal
--   Alt+q             = close pane (keep buffer alive)
--   Alt+1-9           = switch to workspace (tab) N
--   Alt+Shift+1-9     = move current buffer to workspace N
--   Each tab is one repo (:tcd). Terminals are per-tab and start at the repo root.

-- Focus pane (works from normal and terminal mode)
map({ "n", "t" }, "<A-Left>", "<cmd>wincmd h<CR>", { desc = "Focus pane left" })
map({ "n", "t" }, "<A-Down>", "<cmd>wincmd j<CR>", { desc = "Focus pane down" })
map({ "n", "t" }, "<A-Up>", "<cmd>wincmd k<CR>", { desc = "Focus pane up" })
map({ "n", "t" }, "<A-Right>", "<cmd>wincmd l<CR>", { desc = "Focus pane right" })

-- Move/swap pane in direction
map("n", "<A-S-Left>", "<cmd>wincmd H<CR>", { desc = "Move pane left" })
map("n", "<A-S-Down>", "<cmd>wincmd J<CR>", { desc = "Move pane down" })
map("n", "<A-S-Up>", "<cmd>wincmd K<CR>", { desc = "Move pane up" })
map("n", "<A-S-Right>", "<cmd>wincmd L<CR>", { desc = "Move pane right" })

-- Split creation (opens empty buffer in new pane, like i3 empty container)
map("n", "<A-->", "<cmd>split | enew<CR>", { desc = "Split horizontal (empty pane below)" })
map("n", "<A-=>", "<cmd>vsplit | enew<CR>", { desc = "Split vertical (empty pane right)" })

-- Alt+r: i3-style resize mode. Arrows move a divider, not grow/shrink the
-- current pane: prefer the edge below / to the right; if this pane is on
-- the bottom or right of the tab, move the edge above / to the left instead.
-- Esc, Enter, or Alt+r leaves. hjkl are aliases for the arrows.
local RESIZE_W, RESIZE_H = 5, 3

local function win_in_dir(dir)
  local cur = vim.fn.winnr()
  local other = vim.fn.winnr(dir)
  if cur == other then
    return nil
  end
  return vim.fn.win_getid(other)
end

local function move_divider(dir)
  local cur = vim.api.nvim_get_current_win()
  if dir == "down" or dir == "up" then
    local offset = dir == "down" and RESIZE_H or -RESIZE_H
    local below = win_in_dir("j")
    if below then
      vim.fn.win_move_statusline(cur, offset)
    else
      local above = win_in_dir("k")
      if above then
        vim.fn.win_move_statusline(above, offset)
      end
    end
  else
    local offset = dir == "right" and RESIZE_W or -RESIZE_W
    local right = win_in_dir("l")
    if right then
      vim.fn.win_move_separator(cur, offset)
    else
      local left = win_in_dir("h")
      if left then
        vim.fn.win_move_separator(left, offset)
      end
    end
  end
end

local resize_keys = {
  [vim.keycode("<Left>")] = "left",
  [vim.keycode("<Right>")] = "right",
  [vim.keycode("<Up>")] = "up",
  [vim.keycode("<Down>")] = "down",
  h = "left",
  l = "right",
  k = "up",
  j = "down",
}
local resize_exit = {
  [vim.keycode("<Esc>")] = true,
  [vim.keycode("<CR>")] = true,
  [vim.keycode("<A-r>")] = true,
}

local function resize_mode()
  local hint = " RESIZE   arrows move divider   Esc to finish "
  vim.api.nvim_echo({ { hint, "WarningMsg" } }, false, {})
  vim.cmd.redraw()
  while true do
    local ok, key = pcall(vim.fn.getcharstr)
    if not ok or not key or resize_exit[key] then
      break
    end
    local dir = resize_keys[key]
    if dir then
      move_divider(dir)
    end
    vim.api.nvim_echo({ { hint, "WarningMsg" } }, false, {})
    vim.cmd.redraw()
  end
  vim.api.nvim_echo({}, false, {})
end

map({ "n", "t" }, "<A-r>", function()
  local from_term = vim.api.nvim_get_mode().mode == "t"
  if from_term then
    vim.cmd("stopinsert")
  end
  resize_mode()
  if from_term and vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "Resize pane (i3 mode)" })

-- Alt+Enter: open/focus main terminal (bottom right)
map({ "n", "t" }, "<A-CR>", workspaces.open_main_term, { desc = "Open/focus main terminal" })

-- Alt+Backslash: open/focus kiro terminal (bottom left, runs kiro-cli)
map({ "n", "t" }, "<A-Bslash>", open_or_focus_kiro_term, { desc = "Open/focus kiro terminal" })

-- Close pane (close split, keep buffer alive)
map({ "n", "t" }, "<A-q>", "<cmd>close<CR>", { desc = "Close pane" })

-- Workspace (tab) switching: Alt+1 through Alt+9
-- Only switches existing tabs. New repo workspaces come from <leader>fp.
for i = 1, 9 do
  map({ "n", "t" }, "<A-" .. i .. ">", function()
    if i > vim.fn.tabpagenr("$") then
      vim.notify("No workspace " .. i, vim.log.levels.WARN)
      return
    end
    vim.cmd("tabn " .. i)
  end, { desc = "Go to workspace " .. i })
end

-- Move buffer to workspace N: Alt+Shift+1 through Alt+9
local shift_keys = { "!", "@", "#", "$", "%", "^", "&", "*", "(" }
for i = 1, 9 do
  map("n", "<A-" .. shift_keys[i] .. ">", function()
    local buf = vim.api.nvim_get_current_buf()
    local root = workspaces.repo_root(vim.api.nvim_buf_get_name(buf))
    local tab_count = vim.fn.tabpagenr("$")

    -- Close pane in current tab (but don't wipe the buffer or the last window)
    if #vim.api.nvim_tabpage_list_wins(0) > 1 then
      vim.cmd("close")
    end

    if i > tab_count then
      -- One new tab, not a gap-filling run of empty workspaces
      vim.cmd("tablast | tabnew")
      if root then
        workspaces.tcd(root)
      end
    else
      vim.cmd("tabn " .. i)
      if root and not workspaces.has_local_cwd() then
        workspaces.tcd(root)
      end
    end
    vim.cmd("buffer " .. buf)
  end, { desc = "Move buffer to workspace " .. i })
end

-- ╭─────────────────────────────────────────────────────────╮
-- │ Buffers (this workspace unless marked "all")              │
-- ╰─────────────────────────────────────────────────────────╯

map("n", "<leader>,", function()
  Snacks.picker.buffers({ filter = workspaces.picker_filter() })
end, { desc = "Buffers (workspace)" })

map("n", "<leader>fb", function()
  Snacks.picker.buffers({ filter = workspaces.picker_filter() })
end, { desc = "Buffers (workspace)" })

map("n", "<leader>fB", function()
  Snacks.picker.buffers({ hidden = true, nofile = true, filter = {} })
end, { desc = "Buffers (all)" })

map("n", "<leader>fr", function()
  Snacks.picker.recent({ filter = { cwd = true } })
end, { desc = "Recent (workspace)" })

map("n", "<leader>fR", function()
  Snacks.picker.recent({ filter = { cwd = false } })
end, { desc = "Recent (all)" })

map("n", "<leader>sB", function()
  Snacks.picker.grep({
    dirs = workspaces.workspace_file_paths(),
    live = true,
    need_search = false,
  })
end, { desc = "Grep workspace buffers" })

map("n", "<leader>bb", function()
  local alt = workspaces.alternate_buf()
  if alt then
    vim.cmd("buffer " .. alt)
  else
    vim.notify("No other workspace buffer", vim.log.levels.INFO)
  end
end, { desc = "Switch to Other Buffer (workspace)" })

map("n", "<leader>`", function()
  local alt = workspaces.alternate_buf()
  if alt then
    vim.cmd("buffer " .. alt)
  else
    vim.notify("No other workspace buffer", vim.log.levels.INFO)
  end
end, { desc = "Switch to Other Buffer (workspace)" })

map("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  Snacks.bufdelete({
    filter = function(b)
      return b ~= cur and workspaces.buf_in_workspace(b)
    end,
  })
end, { desc = "Delete Other Buffers (workspace)" })

map("n", "<leader>bO", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers (all)" })

map("n", "<leader>bi", function()
  Snacks.bufdelete({
    filter = function(b)
      return workspaces.buf_in_workspace(b) and vim.fn.bufwinnr(b) == -1
    end,
  })
end, { desc = "Delete Invisible Buffers (workspace)" })

