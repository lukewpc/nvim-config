-- Colorscheme configuration
-- Using catppuccin as primary, with tokyonight as fallback
return {
  -- Catppuccin (primary colorscheme)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "latte", -- light theme
      transparent_background = false,
      term_colors = true,
      integrations = {
        aerial = true,
        blink_cmp = true,
        flash = true,
        gitsigns = true,
        illuminate = { enabled = true },
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        mini = { enabled = true },
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        notify = true,
        snacks = true,
        treesitter = true,
        which_key = true,
      },
      -- Custom highlight overrides for better visibility
      custom_highlights = function(colors)
        return {
          -- Bufferline / tab bar - make tabs more visible
          TabLine = { fg = colors.subtext0, bg = colors.mantle },
          TabLineSel = { fg = colors.text, bg = colors.surface1, style = { "bold" } },
          TabLineFill = { bg = colors.crust },

          -- Separators / dividers - use a visible colour
          WinSeparator = { fg = colors.surface2, bg = colors.base },
          VertSplit = { fg = colors.surface2, bg = colors.base },

          -- Statusline contrast
          StatusLine = { fg = colors.text, bg = colors.mantle },
          StatusLineNC = { fg = colors.subtext0, bg = colors.crust },

          -- Floating windows - clearer borders
          FloatBorder = { fg = colors.blue, bg = colors.base },
          NormalFloat = { bg = colors.mantle },
        }
      end,
    },
  },

  -- Bufferline overrides for visible tabs
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        separator_style = "thick", -- more visible separators (slant, thick, thin, padded_slant)
        indicator = {
          style = "underline", -- underline the active tab
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
      },
    },
  },

  -- Tell LazyVim to use catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
