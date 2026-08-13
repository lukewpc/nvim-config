# Neovim Configuration

A modern, LazyVim-based Neovim configuration optimized for DevOps/Cloud-Native development.

## Features

- **LazyVim** as the base distribution (lazy-loaded, fast startup)
- **Language support**: Go, Terraform/OpenTofu, Docker, YAML, JSON, Helm
- **Kubernetes**: Schema validation, kubectl integration, resource detection
- **File explorer**: oil.nvim (edit filesystem like a buffer)
- **Code navigation**: aerial.nvim (symbol outline), flash.nvim (motions)
- **Completion**: blink.cmp with LSP, snippets, and path completion
- **Debugging**: DAP support for Go (delve)
- **Formatting**: conform.nvim (goimports, gofumpt, terraform_fmt, etc.)
- **Linting**: nvim-lint (golangci-lint, hadolint, tflint, etc.)
- **Git**: gitsigns, lazygit integration
- **Colorscheme**: catppuccin (mocha)

## Requirements

- Neovim >= 0.11.2 (built with LuaJIT)
- Git >= 2.19.0
- A [Nerd Font](https://www.nerdfonts.com/) (v3.0+)
- A C compiler (for treesitter parsers)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (live grep)
- [fd](https://github.com/sharkdp/fd) (find files)
- [fzf](https://github.com/junegunn/fzf) (v0.25.1+)
- [lazygit](https://github.com/jesseduffield/lazygit) (optional, git TUI)

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak

# Clone this config
git clone <this-repo> ~/.config/nvim

# Start Neovim — plugins will install automatically
nvim
```

## Structure

```
.
├── init.lua                      # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua              # lazy.nvim bootstrap + extras
│   │   ├── options.lua           # Neovim options
│   │   ├── keymaps.lua           # Custom key bindings
│   │   └── autocmds.lua         # Auto-commands
│   └── plugins/
│       ├── colorscheme.lua       # Catppuccin config
│       ├── editor.lua            # QoL editor plugins
│       ├── kubernetes.lua        # K8s-specific plugins
│       └── oil.lua               # File explorer
├── .gitignore
├── stylua.toml                   # Lua formatter config
└── PLAN.md                       # Implementation plan
```

## Key Bindings

### General
| Key | Action |
|---|---|
| `<leader>` | Space (default) |
| `jk` | Exit insert mode |
| `<C-s>` | Save file |
| `-` / `<leader>e` | Open file explorer (Oil) |
| `<leader>K` | Toggle kubectl.nvim |

### Navigation
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Window navigation (tmux-aware) |
| `<C-d>` / `<C-u>` | Scroll half-page (centered) |

### Code (LSP)
| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename (incremental) |
| `<leader>cs` | Symbol outline (Aerial) |
| `<leader>cf` | Format |

### Search (fzf-lua)
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |

### Diagnostics
| Key | Action |
|---|---|
| `<leader>xx` | Trouble toggle |
| `<leader>xd` | Document diagnostics |
| `<leader>xw` | Workspace diagnostics |
| `]d` / `[d` | Next/prev diagnostic |

### Git
| Key | Action |
|---|---|
| `<leader>gg` | Lazygit |
| `<leader>gf` | Git file history |
| `]h` / `[h` | Next/prev hunk |

## LazyVim Extras Enabled

### Languages
- `lang.go` — gopls, goimports, gofumpt, golangci-lint, delve, neotest
- `lang.terraform` — terraform-ls, tflint, terraform_fmt
- `lang.docker` — dockerls, docker-compose-ls, hadolint
- `lang.yaml` — yamlls + SchemaStore (K8s schemas)
- `lang.json` — jsonls + SchemaStore
- `lang.helm` — helm_ls, helm-ls.nvim

### Editor
- `editor.aerial` — Code outline sidebar
- `editor.mini-move` — Move lines/blocks with Alt+hjkl
- `editor.illuminate` — Highlight word under cursor
- `editor.inc-rename` — Incremental rename UI

### DAP
- `dap.core` — Debug adapter protocol (used by Go/delve)

## Customization

- Add new plugins: create a file in `lua/plugins/` returning a plugin spec
- Override options: edit `lua/config/options.lua`
- Add keymaps: edit `lua/config/keymaps.lua`
- Enable more extras: add `{ import = "lazyvim.plugins.extras.<name>" }` in `lua/config/lazy.lua`
- Browse extras: run `:LazyExtras` inside Neovim

## Mason (LSP/DAP/Linter/Formatter Manager)

Mason is included by default. Use `:Mason` to browse and install tools. The language extras auto-install required tools:

- **Go**: gopls, goimports, gofumpt, golangci-lint, gomodifytags, impl, delve
- **Terraform**: terraform-ls, tflint
- **Docker**: dockerfile-language-server, docker-compose-language-service, hadolint
- **YAML**: yaml-language-server
- **JSON**: json-lsp
- **Helm**: helm-ls
