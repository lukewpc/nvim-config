-- Keymaps are automatically loaded on the VeryLazy event
-- Default LazyVim keymaps: https://lazyvim.github.io/keymaps
-- Add any additional keymaps here

local map = vim.keymap.set

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
map("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Explorer (Oil)" })

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
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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

-- Alt-Enter: open (or focus) this tab's main terminal (bottom right).
-- The shell inherits the tab cwd (repo root).
local function open_or_focus_main_term()
  local win = find_win_for_buf(vim.t.main_term_bufnr)
  if win then
    focus_win(win)
    return
  end
  vim.cmd("split | terminal")
  vim.t.main_term_bufnr = vim.api.nvim_get_current_buf()
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

-- Alt+Enter: open/focus main terminal (bottom right)
map({ "n", "t" }, "<A-CR>", open_or_focus_main_term, { desc = "Open/focus main terminal" })

-- Alt+Backslash: open/focus kiro terminal (bottom left, runs kiro-cli)
map({ "n", "t" }, "<A-Bslash>", open_or_focus_kiro_term, { desc = "Open/focus kiro terminal" })

-- Close pane (close split, keep buffer alive)
map({ "n", "t" }, "<A-q>", "<cmd>close<CR>", { desc = "Close pane" })

local workspaces = require("config.workspaces")

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

