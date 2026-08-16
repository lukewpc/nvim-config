-- Snacks.nvim overrides
-- https://github.com/folke/snacks.nvim
-- File/buffer pickers default to this tab's repo. Capital-letter variants stay global.
return {
  "folke/snacks.nvim",
  init = function()
    -- Inject LazyGit `E` → Diffview custom commands before the first <leader>gg.
    require("config.lazygit").setup()
  end,
  opts = {
    picker = {
      sources = {
        -- Apply to all file-finding sources (files, grep, explorer, etc.)
        files = {
          hidden = true,   -- descend into hidden directories (e.g. .harness)
          -- .git is excluded by fd/rg by default; .gitignore is still respected.
        },
        grep = {
          hidden = true,   -- also search inside hidden dirs when grepping
        },
        -- Walk `dev` for git repos; stop at the first `.git` so nested
        -- modules and package.json trees are not listed. Confirm opens a
        -- repo tab (:tcd). Do not use load_session (global chdir).
        projects = {
          dev = { "/workspace", "~/dev", "~/projects" },
          recent = false,
          finder = function(opts, ctx)
            return function(cb)
              local seen = {}
              local function add(dir)
                if not dir or seen[dir] then
                  return
                end
                seen[dir] = true
                if ctx.filter:match({ file = dir, text = dir }) then
                  cb({ file = dir, text = dir, dir = true })
                end
              end
              for _, dir in ipairs(opts.projects or {}) do
                add(require("config.workspaces").normalize(dir))
              end
              for _, dir in ipairs(require("config.workspaces").list_repos(opts.dev)) do
                add(dir)
              end
            end
          end,
          confirm = function(picker, item)
            picker:close()
            if item and item.file then
              require("config.workspaces").open_repo(item.file)
            end
          end,
        },
        -- Default recent list is this repo. <leader>fR passes cwd = false.
        recent = {
          filter = { cwd = true },
        },
        jumps = {
          filter = { cwd = true },
        },
      },
    },
  },
  keys = {
    {
      "<leader>,",
      function()
        Snacks.picker.buffers({ filter = require("config.workspaces").picker_filter() })
      end,
      desc = "Buffers (workspace)",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers({ filter = require("config.workspaces").picker_filter() })
      end,
      desc = "Buffers (workspace)",
    },
    {
      "<leader>fB",
      function()
        Snacks.picker.buffers({ hidden = true, nofile = true, filter = {} })
      end,
      desc = "Buffers (all)",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent (workspace)",
    },
    {
      "<leader>fR",
      function()
        Snacks.picker.recent({ filter = { cwd = false } })
      end,
      desc = "Recent (all)",
    },
    {
      "<leader>sB",
      function()
        local dirs = require("config.workspaces").workspace_file_paths()
        Snacks.picker.grep({
          dirs = dirs,
          live = true,
          need_search = false,
        })
      end,
      desc = "Grep workspace buffers",
    },
  },
}
