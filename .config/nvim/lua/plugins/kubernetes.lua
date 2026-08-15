-- Kubernetes-specific plugins and configuration
return {
  -- Launch k9s in a full-screen tab with <leader>K
  {
    "LazyVim/LazyVim",
    keys = {
      {
        "<leader>K",
        function()
          vim.cmd("tabnew | terminal k9s")
        end,
        desc = "K9s",
      },
    },
  },

  -- Extend yamlls with additional Kubernetes schemas
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                -- Common Kubernetes resource schemas (auto-detected via SchemaStore)
                -- Add custom CRD schemas here if needed:
                -- ["https://raw.githubusercontent.com/..."] = "/*.yaml",
              },
            },
          },
        },
      },
    },
  },

  -- Additional treesitter parsers useful for K8s workflows
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "yaml",
        "json",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "dockerfile",
        "terraform",
        "hcl",
        "helm",
        "bash",
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
        "regex",
        "toml",
      },
    },
  },
}
