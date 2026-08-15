-- Oil.nvim — file explorer that lets you edit the filesystem like a buffer
-- https://github.com/stevearc/oil.nvim
return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
      { "<leader>e", "<cmd>Oil<CR>", desc = "Explorer (Oil)" },
    },
    opts = {
      -- Show hidden files (dotfiles)
      view_options = {
        show_hidden = true,
        -- Hide some common unneeded entries
        is_hidden_file = function(name)
          return vim.startswith(name, "..") or name == ".git"
        end,
      },
      -- Columns to display
      columns = {
        "icon",
        -- "permissions",
        -- "size",
        -- "mtime",
      },
      -- Skip confirmation for simple file operations
      skip_confirm_for_simple_edits = true,
      -- Keymaps inside oil buffer
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.tcd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      -- Use floating window
      float = {
        padding = 2,
        max_width = 120,
        max_height = 40,
      },
    },
  },
}
