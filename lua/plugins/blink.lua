-- Completion: LSP + path auto-popup only where a real language server
-- knows the grammar. Config-like filetypes are path-only; <C-space> shows
-- the menu. Buffer words and snippets are off everywhere.
return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local lsp_ft = {
        go = true,
        gomod = true,
        gowork = true,
        gosum = true,
        java = true,
        lua = true,
        terraform = true,
        tf = true,
        ["terraform-vars"] = true,
        hcl = true,
        dockerfile = true,
        sh = true,
        bash = true,
        zsh = true,
      }

      local function use_lsp()
        return lsp_ft[vim.bo.filetype] == true
      end

      opts.sources = opts.sources or {}
      opts.sources.default = function()
        if use_lsp() then
          return { "lsp", "path" }
        end
        return { "path" }
      end

      -- Path/LSP must not fall back to buffer words when they return nothing.
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.lsp = vim.tbl_deep_extend("force", opts.sources.providers.lsp or {}, {
        fallbacks = {},
      })
      opts.sources.providers.path = vim.tbl_deep_extend("force", opts.sources.providers.path or {}, {
        fallbacks = {},
      })
      opts.sources.providers.snippets = vim.tbl_deep_extend("force", opts.sources.providers.snippets or {}, {
        enabled = false,
      })
      opts.sources.providers.buffer = vim.tbl_deep_extend("force", opts.sources.providers.buffer or {}, {
        enabled = false,
      })

      opts.completion = opts.completion or {}
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.menu.auto_show = function(ctx)
        if ctx.mode ~= "default" then
          return true
        end
        return lsp_ft[vim.bo[ctx.bufnr].filetype] == true
      end

      return opts
    end,
  },
}
