-- Options are automatically loaded before lazy.nvim startup
-- Default LazyVim options: https://lazyvim.github.io/configuration/general
-- Add any additional options here

local opt = vim.opt

-- ╭─────────────────────────────────────────────────────────╮
-- │ UI                                                       │
-- ╰─────────────────────────────────────────────────────────╯
opt.relativenumber = true -- Relative line numbers
opt.number = true -- Show absolute line number on current line
opt.cursorline = true -- Highlight current line
opt.signcolumn = "yes" -- Always show sign column
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
opt.termguicolors = true -- True color support

-- ╭─────────────────────────────────────────────────────────╮
-- │ Indentation                                              │
-- ╰─────────────────────────────────────────────────────────╯
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Indent by 2 spaces
opt.tabstop = 2 -- Tab = 2 spaces
opt.softtabstop = 2 -- Soft tab = 2 spaces
opt.smartindent = true -- Smart auto-indentation

-- ╭─────────────────────────────────────────────────────────╮
-- │ Search                                                   │
-- ╰─────────────────────────────────────────────────────────╯
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if uppercase used
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search

-- ╭─────────────────────────────────────────────────────────╮
-- │ Splits                                                   │
-- ╰─────────────────────────────────────────────────────────╯
opt.splitbelow = true -- Horizontal splits open below
opt.splitright = true -- Vertical splits open to the right

-- ╭─────────────────────────────────────────────────────────╮
-- │ Files & Undo                                             │
-- ╰─────────────────────────────────────────────────────────╯
opt.undofile = true -- Persistent undo history
opt.undolevels = 10000 -- Maximum undo levels
opt.swapfile = false -- Disable swap files
opt.backup = false -- Disable backup files
opt.writebackup = false -- Disable write backup

-- ╭─────────────────────────────────────────────────────────╮
-- │ Clipboard                                                │
-- ╰─────────────────────────────────────────────────────────╯
opt.clipboard = "unnamedplus" -- Use system clipboard

-- ╭─────────────────────────────────────────────────────────╮
-- │ Completion                                               │
-- ╰─────────────────────────────────────────────────────────╯
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10 -- Maximum popup menu height

-- ╭─────────────────────────────────────────────────────────╮
-- │ Misc                                                     │
-- ╰─────────────────────────────────────────────────────────╯
opt.wrap = false -- Disable line wrapping
opt.updatetime = 200 -- Faster CursorHold events
opt.timeoutlen = 300 -- Time to wait for mapped sequence (ms)
opt.mouse = "a" -- Enable mouse in all modes
opt.conceallevel = 2 -- Hide markup in markdown

-- Disable netrw (we use oil.nvim)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- LazyVim file/grep "Root Dir" follows the tab's cwd (:tcd), not the
-- current file's LSP or .git root. Each tab is one repository.
vim.g.root_spec = { "cwd" }
