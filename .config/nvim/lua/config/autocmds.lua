
-- Autocmds are automatically loaded on the VeryLazy event
-- Default LazyVim autocmds: https://lazyvim.github.io/configuration/general
-- Add any additional autocmds here

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ╭─────────────────────────────────────────────────────────╮
-- │ General                                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("trim_whitespace", { clear = true }),
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ Filetype Detection                                       │
-- ╰─────────────────────────────────────────────────────────╯

-- Detect Kubernetes YAML files and set filetype for schema support
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("kubernetes_yaml", { clear = true }),
  pattern = {
    "*/templates/*.yaml",
    "*/templates/*.yml",
    "*/.kube/config",
    "*/kubernetes/*.yaml",
    "*/kubernetes/*.yml",
    "*/k8s/*.yaml",
    "*/k8s/*.yml",
    "*/manifests/*.yaml",
    "*/manifests/*.yml",
    "*/deploy/*.yaml",
    "*/deploy/*.yml",
  },
  callback = function(ev)
    -- Read the first few lines to detect Kubernetes resources
    local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, 10, false)
    local content = table.concat(lines, "\n")
    if content:match("apiVersion:") and content:match("kind:") then
      vim.b[ev.buf].yaml_schema = "kubernetes"
    end
  end,
})

-- Detect Go template files (helm chart templates, etc.)
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("gotmpl_detection", { clear = true }),
  pattern = { "*.tpl", "*.gotmpl" },
  callback = function()
    vim.bo.filetype = "gotmpl"
  end,
})

-- Detect Terraform/OpenTofu files
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("terraform_detection", { clear = true }),
  pattern = { "*.tf", "*.tfvars", "*.tofu" },
  callback = function()
    vim.bo.filetype = "terraform"
  end,
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ Format Options                                           │
-- ╰─────────────────────────────────────────────────────────╯

-- Don't auto-continue comments on new lines
autocmd("FileType", {
  group = augroup("format_options", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ╭─────────────────────────────────────────────────────────╮
-- │ Terminal                                                  │
-- ╰─────────────────────────────────────────────────────────╯

-- Enter insert mode when opening a terminal
autocmd("TermOpen", {
  group = augroup("terminal_insert", { clear = true }),
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
  end,
})

-- Enter insert mode when switching to a terminal pane via keyboard
autocmd("WinEnter", {
  group = augroup("terminal_focus_insert", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "terminal" then
      vim.schedule(function()
        if vim.bo.buftype == "terminal" then
          vim.cmd("startinsert")
        end
      end)
    end
  end,
})
