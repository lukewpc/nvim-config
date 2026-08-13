# Neovim Cheat Sheet

Leader key is `Space`. Window modifier is `Alt` (i3-style).

## i3-Like Workflow (Alt modifier)

This config uses nvim tabs as **workspaces** and nvim splits as **tiled panes**, navigated with `Alt` — the same mental model as i3wm.

**Pane focus (directional):**

| Key | Action |
|-----|--------|
| `Alt+←` | Focus pane left |
| `Alt+↓` | Focus pane down |
| `Alt+↑` | Focus pane up |
| `Alt+→` | Focus pane right |

**Pane movement:**

| Key | Action |
|-----|--------|
| `Alt+Shift+←` | Move pane left |
| `Alt+Shift+↓` | Move pane down |
| `Alt+Shift+↑` | Move pane up |
| `Alt+Shift+→` | Move pane right |

**Splits:**

| Key | Action |
|-----|--------|
| `Alt+-` | Split horizontal (pane below) |
| `Alt+=` | Split vertical (pane right) |
| `Alt+Enter` | Split horizontal + open terminal |
| `Alt+q` | Close pane (buffer stays open) |

**Workspaces (tabs):**

| Key | Action |
|-----|--------|
| `Alt+1` – `Alt+9` | Switch to workspace N (creates if needed) |
| `Alt+Shift+1` – `Alt+Shift+9` | Move current buffer to workspace N |

## General

| Key | Action |
|-----|--------|
| `jk` | Exit insert mode |
| `Ctrl-s` | Save file (works in insert, normal, visual) |
| `Esc` | Clear search highlights |
| `p` (visual mode) | Paste without overwriting your yank register |
| `<` / `>` (visual) | Indent and stay in visual mode |

## Navigation

| Key | Action |
|-----|--------|
| `Ctrl-d` / `Ctrl-u` | Scroll half-page down/up (cursor stays centered) |
| `n` / `N` | Next/prev search result (centered) |
| `H` / `L` | Prev/next buffer |
| `[b` / `]b` | Prev/next buffer (alternative) |

## Telescope (Fuzzy Finder)

Start nvim from `/workspace` to search across all projects.

**Finding files:**

| Key | Action |
|-----|--------|
| `Space Space` | Find files (from cwd) |
| `Space f f` | Find files |
| `Space f r` | Recent files |
| `Space f g` | Find files (git files only) |
| `Space f b` | Browse files from current buffer's directory |

**Searching content:**

| Key | Action |
|-----|--------|
| `Space /` | Live grep (type and filter results in real-time) |
| `Space s g` | Grep (same as `Space /`) |
| `Space s w` | Search word under cursor |
| `Space s W` | Search WORD under cursor (includes punctuation) |
| `Space s r` | Search and replace (Spectre) |

**Navigating buffers & history:**

| Key | Action |
|-----|--------|
| `Space ,` | Switch open buffers (with preview) |
| `Space f r` | Recent files |
| `Space s R` | Resume last Telescope picker |

**Other pickers:**

| Key | Action |
|-----|--------|
| `Space ?` | Search keymaps |
| `Space s h` | Search help tags |
| `Space s m` | Search marks |
| `Space s "` | Search registers |
| `Space s c` | Search commands |
| `Space s d` | Search diagnostics |

**Inside a Telescope picker:**

| Key | Action |
|-----|--------|
| `Ctrl-j` / `Ctrl-k` | Move down/up in results |
| `Ctrl-n` / `Ctrl-p` | Move down/up (alternative) |
| `Enter` | Open selected file |
| `Ctrl-x` | Open in horizontal split |
| `Ctrl-v` | Open in vertical split |
| `Ctrl-t` | Open in new tab |
| `Ctrl-u` / `Ctrl-d` | Scroll preview up/down |
| `Ctrl-/` | Show picker keybindings (help) |
| `Esc` | Close picker (normal mode) |
| `Ctrl-c` | Close picker (insert mode) |
| `Tab` | Toggle selection + move to next |
| `Shift-Tab` | Toggle selection + move to prev |
| `Ctrl-q` | Send all results to quickfix list |
| `Alt-q` | Send selected results to quickfix list |

## LSP

| Key | Action |
|-----|--------|
| `g d` | Go to definition |
| `g D` | Go to declaration |
| `g r` | Go to references |
| `g I` | Go to implementation |
| `g y` | Go to type definition |
| `K` | Hover documentation |
| `g K` | Signature help |
| `Space c a` | Code actions |
| `Space c r` | Rename symbol (inc-rename) |
| `Space c f` | Format file |
| `Space c l` | Lint info |
| `Space c L` | LSP info |
| `] d` / `[ d` | Next/prev diagnostic |

## Completion (blink.cmp)

Completion menu appears automatically as you type.

| Key | Action |
|-----|--------|
| `Ctrl-n` | Next completion item |
| `Ctrl-p` | Previous completion item |
| `Ctrl-y` | Accept completion |
| `Ctrl-e` | Cancel/close completion menu |
| `Ctrl-b` / `Ctrl-f` | Scroll documentation up/down |
| `Tab` | Accept or jump to next snippet placeholder |
| `Shift-Tab` | Jump to previous snippet placeholder |

## File Explorer (Oil.nvim)

Oil replaces netrw — you edit the filesystem like a buffer (rename by editing text, delete by removing lines, save to apply).

| Key | Action |
|-----|--------|
| `-` | Open parent directory |
| `Space e` | Open explorer |
| **Inside Oil:** | |
| `Enter` | Open file/directory |
| `-` | Go up a directory |
| `Ctrl-v` | Open in vertical split |
| `Ctrl-s` | Open in horizontal split |
| `Ctrl-t` | Open in new tab |
| `Ctrl-p` | Preview |
| `Ctrl-c` | Close oil |
| `Ctrl-r` | Refresh |
| `g.` | Toggle hidden files |
| `gs` | Change sort |
| `g?` | Show help |

To rename/delete/create: just edit the buffer text and `:w` to apply.

## Git

| Key | Action |
|-----|--------|
| `Space g g` | LazyGit (full TUI) |
| `Space g l` | LazyGit log (current file) |
| `Space g L` | LazyGit log (all files) |
| `]h` / `[h` | Next/prev hunk |
| `Space g h s` | Stage hunk |
| `Space g h r` | Reset hunk |
| `Space g h S` | Stage buffer |
| `Space g h R` | Reset buffer |
| `Space g h p` | Preview hunk |
| `Space g h b` | Blame line |
| `Space g h d` | Diff this |
| `Space g b` | Git blame line (inline) |

## Diffview (Side-by-Side Diff)

Compare any git ref against your working tree. File tree on the left, editable split diff on the right.

**Opening:**

| Key / Command | Action |
|-----|--------|
| `Space g v` | Open diff view (HEAD vs working tree) |
| `Space g V` | Close diff view |
| `Space g h` | File history (current file) |
| `Space g H` | File history (whole repo) |
| `:DiffviewOpen main` | Compare `main` vs working tree |
| `:DiffviewOpen abc123` | Compare any commit hash vs working tree |
| `:DiffviewOpen main..HEAD` | Compare range between two refs |
| `:DiffviewOpen origin/HEAD...HEAD` | PR review (symmetric diff from merge base) |

**In the file panel (left):**

| Key | Action |
|-----|--------|
| `j` / `k` | Navigate files |
| `Enter` / `l` | Open diff for selected file |
| `Tab` / `Shift-Tab` | Cycle through files without leaving diff |
| `s` / `-` | Stage / unstage entry |
| `X` | Restore file to ref state |
| `R` | Refresh file list |
| `i` | Toggle tree / list view |
| `g?` | Open help |

**In the diff view (right side = working tree):**

| Key | Action |
|-----|--------|
| `do` | Pull hunk from left (ref) into right (working tree) |
| `]x` / `[x` | Next / prev hunk or conflict |
| `e` | Focus the file panel |
| `b` | Toggle file panel visibility |

## Bufferline (Buffer Tabs)

The tab bar at the top shows open buffers. Workspace (tab) indicators appear on the right.

| Key | Action |
|-----|--------|
| `Space b b` | Switch buffers (Telescope) |
| `Space b d` | Close buffer |
| `Space b D` | Close other buffers |
| `Space b p` | Toggle pin buffer |
| `Space b P` | Close non-pinned buffers |
| `[b` / `]b` | Prev/next buffer |
| `H` / `L` | Prev/next buffer (alternative) |

## Flash.nvim (Jump Motions)

Flash lets you jump to any visible character instantly. It shows labels on matches as you type.

| Key | Action |
|-----|--------|
| `s` | Flash jump — type chars, then pick a label to jump |
| `S` | Flash treesitter — select a treesitter node |
| `r` (operator pending) | Remote flash — jump to location, apply operator, return |
| `f` / `F` / `t` / `T` | Enhanced f/t motions with multi-line labels |
| `Ctrl-s` (in Telescope) | Toggle flash filtering inside Telescope |

How to use `s`: press `s`, start typing the text you want to jump to, labels appear next to matches, press the label character to jump there.

## Terminal

| Key | Action |
|-----|--------|
| `Alt+Enter` | Open / focus main terminal (bottom right) |
| `Alt+\` | Open / focus Kiro terminal (bottom left, runs kiro-cli) |
| `Ctrl-/` | Toggle floating terminal |
| `Ctrl-\` | Exit terminal mode |
| `Esc Esc` | Exit terminal mode (alternative) |
| `Alt+arrows` | Navigate out of terminal (no need to exit terminal mode first) |

## Trouble (Diagnostics Panel)

| Key | Action |
|-----|--------|
| `Space x x` | Toggle trouble (diagnostics) |
| `Space x X` | Buffer diagnostics |
| `Space x L` | Location list |
| `Space x Q` | Quickfix list |
| `Space x t` | Todo list (all TODOs in project) |

## Surround (mini.surround)

| Key | Action |
|-----|--------|
| `gsa` | Add surrounding (e.g., `gsaiw"` wraps word in quotes) |
| `gsd` | Delete surrounding (e.g., `gsd"` removes quotes) |
| `gsr` | Replace surrounding (e.g., `gsr"'` changes `"` to `'`) |
| `gsf` | Find next surrounding |

## Illuminate (Word Highlighting)

Automatically highlights other occurrences of the word under your cursor.

| Key | Action |
|-----|--------|
| `] ]` | Jump to next occurrence of word |
| `[ [` | Jump to previous occurrence of word |

## Todo Comments

Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `WARN`, `PERF` in comments.

| Key | Action |
|-----|--------|
| `] t` | Jump to next TODO comment |
| `[ t` | Jump to previous TODO comment |
| `Space s t` | Search all TODOs (Telescope) |
| `Space s T` | Search TODO/FIXME/FIX only |

## Projects

Quickly switch between repos/projects under `/workspace`. Powered by `project.nvim`.

| Key | Action |
|-----|--------|
| `Space f p` | Browse recent projects |

Inside the project picker, selecting a project will `cd` into it and open `find_files` there. Projects are auto-detected from git repos you visit.

## Aerial (Code Outline)

| Key | Action |
|-----|--------|
| `Space c s` | Toggle symbol outline sidebar |

## Folding (nvim-ufo)

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open folds (one level) |
| `zm` | Close folds (one level) |
| `zK` | Peek inside fold under cursor |

## Kubernetes

| Key | Action |
|-----|--------|
| `Space K` | Open k9s in a new tab |

## Debugging (DAP)

| Key | Action |
|-----|--------|
| `Space d b` | Toggle breakpoint |
| `Space d c` | Continue |
| `Space d s` | Step over |
| `Space d i` | Step into |
| `Space d o` | Step out |
| `Space d t` | Terminate |

## Useful Commands

| Command | Action |
|-----|--------|
| `:Mason` | Open Mason (manage LSP servers, linters, formatters) |
| `:Lazy` | Open Lazy.nvim plugin manager |
| `:LazyExtras` | Browse and enable/disable LazyVim extras |
| `:LazyHealth` | Check plugin health |
| `:ConformInfo` | Show active formatters for current buffer |
| `:LspInfo` | Show active LSP clients |
| `:Noice` | Show notification/message history |

## Tips

- **Which-key**: press `Space` and wait — a popup shows all available keybindings from that prefix.
- **Format on save** is enabled via conform.nvim (shfmt for bash, language servers for Go/Terraform/etc).
- **Trailing whitespace** is auto-stripped on save.
- **System clipboard** is synced — yank in nvim, paste anywhere and vice versa.
- Comments won't auto-continue on new lines.
- **Yank highlight**: yanked text flashes briefly so you can see what was copied.
- **Persistent undo**: undo history survives across sessions (stored in nvim data dir).
- **Noice.nvim**: command line, messages, and notifications are shown in a modern popup UI.
- **No tmux**: this config uses nvim as the sole layout manager. Tabs = workspaces, splits = tiled panes.
