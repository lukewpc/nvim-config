-- Snacks.nvim overrides
-- https://github.com/folke/snacks.nvim
return {
  "folke/snacks.nvim",
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
        -- Confirm opens/focuses a repo tab (:tcd). Do not use load_session
        -- (that does a global chdir and can clobber every tab).
        projects = {
          dev = { "/workspace", "~/dev", "~/projects" },
          confirm = function(picker, item)
            picker:close()
            if item and item.file then
              require("config.workspaces").open_repo(item.file)
            end
          end,
        },
      },
    },
  },
}
