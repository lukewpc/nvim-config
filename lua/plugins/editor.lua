-- Additional editor plugins for quality of life
return {
  -- Better text objects (expand/shrink selection)
  {
    "nvim-mini/mini.surround",
    opts = {
      -- Use 'gs' prefix instead of 's' to avoid conflict with flash.nvim
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  -- Better diagnostics display (virtual text at end of line)
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "help",
          "dashboard",
          "lazy",
          "mason",
          "notify",
          "oil",
        },
      },
    },
  },

  -- Highlight TODO/FIXME/HACK/NOTE comments (override for broader keywords)
  {
    "folke/todo-comments.nvim",
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      },
    },
  },

  -- Side-by-side diff viewer: compare any git ref against the working tree.
  --
  -- Commands:
  --   :DiffviewOpen              → HEAD vs working tree (with LSP on right side)
  --   :DiffviewOpen main         → main vs working tree
  --   :DiffviewOpen abc123       → any commit hash vs working tree
  --   :DiffviewOpen main..HEAD   → range between two refs
  --   :DiffviewOpen origin/HEAD...HEAD --imply-local  → PR review (symmetric diff)
  --   :DiffviewFileHistory %     → commit history for current file
  --   :DiffviewFileHistory       → commit history for whole repo
  --
  -- From LazyGit (<leader>gg): press E on a commit, branch, tag, or stash
  -- to close LazyGit and open Diffview for that ref vs the working tree.
  --
  -- In the file panel (left):
  --   j/k          navigate files
  --   Enter/l      open diff for selected file
  --   Tab/S-Tab    cycle files without leaving diff view
  --   s / -        stage / unstage entry
  --   X            restore file to ref state
  --   R            refresh file list
  --   i            toggle tree/list view
  --   g?           open help
  --
  -- In the diff view:
  --   do           pull hunk from left (ref) into right (working tree) — standard vim diffget
  --   ]x / [x      next / prev conflict or hunk
  --   e            focus the file panel
  --   b            toggle file panel visibility
  --
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>",            desc = "Diff View (HEAD vs working tree)" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>",           desc = "Diff View Close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",   desc = "File History (current file)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",     desc = "File History (repo)" },
    },
    opts = {
      -- Highlight individual changed characters within a line, not just whole lines
      enhanced_diff_hl = true,

      -- Always use --imply-local so the right side is the real working tree file
      -- with full LSP support (diagnostics, go-to-def, completions, etc.)
      default_args = {
        DiffviewOpen = { "--imply-local" },
      },

      view = {
        default = {
          layout = "diff2_horizontal",  -- side-by-side (left=ref, right=working tree)
          disable_diagnostics = false,  -- keep LSP squiggles; right side is live
          winbar_info = true,           -- show ref names in winbar for orientation
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
      },

      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,          -- collapse single-child dirs (e.g. src/main/java/...)
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 40,
        },
      },
    },
  },

  -- Better folding with treesitter
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    keys = {
      { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open folds except kinds" },
      { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close folds with" },
      { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek folded lines" },
    },
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    init = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
  },
}
