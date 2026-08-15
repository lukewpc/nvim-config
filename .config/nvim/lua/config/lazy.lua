local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ╭─────────────────────────────────────────────────────────╮
    -- │ Language Extras                                          │
    -- ╰─────────────────────────────────────────────────────────╯
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.helm" },
    { import = "lazyvim.plugins.extras.lang.java" },

    -- ╭─────────────────────────────────────────────────────────╮
    -- │ Editor Extras                                            │
    -- ╰─────────────────────────────────────────────────────────╯
    { import = "lazyvim.plugins.extras.editor.aerial" },
    { import = "lazyvim.plugins.extras.editor.illuminate" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },

    -- ╭─────────────────────────────────────────────────────────╮
    -- │ DAP (Debug Adapter Protocol)                             │
    -- ╰─────────────────────────────────────────────────────────╯
    { import = "lazyvim.plugins.extras.dap.core" },

    -- ╭─────────────────────────────────────────────────────────╮
    -- │ User Plugins                                             │
    -- ╰─────────────────────────────────────────────────────────╯
    { import = "plugins" },
  },
  defaults = {
    -- LazyVim plugins are lazy-loaded by default. Custom plugins load at startup.
    lazy = false,
    -- Use latest git commit instead of potentially outdated tagged releases.
    version = false,
  },
  install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- periodically check for plugin updates
    notify = false, -- don't spam notifications on every update
  },
  performance = {
    rtp = {
      -- Disable unused built-in plugins for faster startup
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
