-- Bufferline override: make vim tabs visually prominent
-- The tab bar shows both buffers AND tab pages. Tabs appear on the right
-- side of the bufferline as distinct, always-visible indicators.
return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- Always show the tab pages section on the right side of the tabline
        mode = "buffers", -- show buffers (files) as the main items
        always_show_bufferline = true,
        show_tab_indicators = true,

        -- This tab's repo files (under :tcd) plus anything actually shown here.
        -- Other workspaces' files stay off the bar.
        custom_filter = function(buf)
          local workspaces = require("config.workspaces")
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
          return workspaces.path_under_cwd(name)
        end,

        -- Separator style between buffer entries
        separator_style = "thin",

        -- Show tab pages as a separate section on the right
        -- This gives you a clear "Tab 1 | Tab 2 | Tab 3" indicator
        tab_size = 18,

        -- Show close icons on tabs
        show_close_icon = true,
        show_buffer_close_icons = true,
      },
    },
    keys = {
      { "<leader><tab>n", "<cmd>tabnew<CR>", desc = "New Tab" },
      { "<leader><tab>d", "<cmd>tabclose<CR>", desc = "Close Tab" },
      { "<leader><tab>l", "<cmd>tablast<CR>", desc = "Last Tab" },
      { "<leader><tab>f", "<cmd>tabfirst<CR>", desc = "First Tab" },
      { "<leader><tab>]", "<cmd>tabnext<CR>", desc = "Next Tab" },
      { "<leader><tab>[", "<cmd>tabprevious<CR>", desc = "Previous Tab" },
      { "<leader><tab>o", "<cmd>tabonly<CR>", desc = "Close Other Tabs" },
    },
  },
}
