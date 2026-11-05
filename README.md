# Dotfile

My Neovim config for Mac, Windows, and the OSU server (ssh). Needs Neovim 0.12 or newer.

Languages: C, C++, Python, JavaScript, TypeScript, SystemVerilog, LaTeX (plus Lua for editing the config).

## Layout

```
Dotfile/
  install.sh      Mac / Linux setup menu (install / update)
  install.ps1     Windows setup menu (install / update)
  nvim/           the actual Neovim config
    init.lua
    lazy-lock.json   exact plugin versions, so both machines match
    lua/config/      options, keymaps, autocmds, update command, plugin manager
    lua/plugins/     ui, completion, language servers, treesitter, LaTeX
```

Neovim only looks in one folder for its config: `~/.config/nvim` on Mac and Linux, `%LOCALAPPDATA%\nvim` on Windows. Cloning this repo into `~/.config` would give `~/.config/Dotfile/nvim`, which Neovim ignores. The install scripts solve that with a link, so the repo can live anywhere.

## Install

Each machine only needs git and a clone of this repo. The install script does the rest and shows a menu:

```
  Dotfile setup
  [1] Install / Update nvim
  [0] Quit
```

Option 1 pulls the newest Dotfile from GitHub, installs or upgrades Neovim and the tools the config uses, links the config into the folder Neovim reads, and installs the plugins at the versions in `lazy-lock.json`. Run it again any time to update everything. If a real (not linked) config folder is already there, it gets renamed to `nvim.backup.<date>` and the script asks whether to clear the old plugin data.

### Mac

```sh
xcode-select --install          # git and a C compiler, skip if already installed
git clone https://github.com/<your-username>/Dotfile ~/Dotfile
sh ~/Dotfile/install.sh         # or: sh ~/Dotfile/install.sh 1
```

Installs with Homebrew (it offers to install Homebrew if missing): neovim, git, ripgrep, fd, tree-sitter-cli, and node if you do not already have one.

For LaTeX: `brew install --cask mactex-no-gui` and optionally `brew install --cask skim` (forward search to the line you are editing).

On Linux without Homebrew (the OSU server), the script skips installing programs and only links the config and installs plugins.

### Windows (PowerShell)

```powershell
winget install Git.Git          # then open a new terminal
git clone https://github.com/<your-username>/Dotfile $HOME\Dotfile
powershell -ExecutionPolicy Bypass -File $HOME\Dotfile\install.ps1
```

Installs with winget: Neovim, Git, Node.js LTS, ripgrep, fd.

Optional on Windows:

* Treesitter colors: install Visual Studio Build Tools with the "Desktop development with C++" workload, and the tree-sitter CLI (`tree-sitter-windows-x64.gz` from the tree-sitter GitHub releases page, unzip it, rename to `tree-sitter.exe`, put it on PATH). Without these, Neovim still uses normal syntax colors.
* LaTeX: TeX Live (includes latexmk), or MiKTeX plus Strawberry Perl. SumatraPDF as the viewer gets used automatically when it is on PATH.
* PowerShell 7 (`winget install Microsoft.PowerShell`): the built-in terminal opens in it when installed.

### First start

Open any code file and Mason installs the language servers in the background (watch progress with `<space>m`). Servers start on their own when the install finishes, no restart needed.

### Updating

Run the install script again and pick 1. Inside Neovim, `:Update` (or `<space>U`) gets newer plugin, server, and parser versions than the lock file; commit the new `nvim/lazy-lock.json` afterward so the other machine gets the same versions next time it runs the script.

### C and C++ headers

clangd works best with a `compile_flags.txt` in the project folder, one flag per line:

```
-std=c17
-Wall
-Iinclude
```

For bigger projects (CMake, Make), generate `compile_commands.json` instead (`cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`, or `bear -- make`). If clangd says `stdio.h` is not found, this file is the fix.

## Keymaps

Leader is `Space`. Local leader (LaTeX) is `\`. Press `<space>sk` to search every keymap, or press `Space` and wait to see the menu.

### Editing and windows

| Keys | Action |
| --- | --- |
| `Ctrl-s` | Save (normal and insert mode) |
| `Esc` | Clear search highlight |
| `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` | Move to the window left, down, up, right |
| `Shift-h` / `Shift-l` | Previous / next buffer (open file) |
| `<` / `>` in visual mode | Indent and keep the selection |
| `<space>bd` | Close buffer |
| `<space>ur` | Toggle relative line numbers |
| `<space>qq` | Quit all |

### Finding things

| Keys | Action |
| --- | --- |
| `<space><space>` or `<space>ff` | Find file |
| `<space>fr` | Recent files |
| `<space>fc` | Config files |
| `<space>/` | Search text in project |
| `<space>,` | Open buffers |
| `<space>e` | File explorer |
| `<space>sk` | Search keymaps |
| `<space>sh` | Search help |
| `<space>sd` | Diagnostics in all files |
| `<space>ss` | Symbols (functions, variables) in this file |
| `<space>n` | Message history |

### Completion (insert mode)

| Keys | Action |
| --- | --- |
| `Enter` or `Tab` | Accept the highlighted item (functions insert `name()` with the cursor inside) |
| `Ctrl-n` / `Ctrl-p` or `Up` / `Down` | Next / previous item |
| `Ctrl-e` | Close the menu |
| `Ctrl-Space` | Open the menu |
| `Ctrl-k` | Toggle the parameter hint popup |

### Code (when a language server is attached)

| Keys | Action |
| --- | --- |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gy` | Go to type definition |
| `grr` | References |
| `gri` | Implementations |
| `K` | Hover documentation |
| `<space>cr` | Rename symbol |
| `<space>ca` | Code action (quick fixes) |
| `<space>cf` | Format file |
| `<space>cd` | Show the error on this line |
| `<space>ch` | Toggle inlay hints |
| `<space>co` | Switch between .c/.cpp and .h (C and C++) |
| `]d` / `[d` | Next / previous error or warning |
| `Ctrl-o` / `Ctrl-i` | Jump back / forward after going to a definition |

### Git (inside a git repo)

| Keys | Action |
| --- | --- |
| `]h` / `[h` | Next / previous changed block |
| `<space>gp` | Preview the change |
| `<space>gr` | Undo the change |
| `<space>gb` | Blame this line |

### Terminal

| Keys | Action |
| --- | --- |
| `<space>tt` | Toggle a terminal |
| `Esc Esc` | Leave terminal typing mode |

### LaTeX (vimtex, in a .tex file)

| Keys | Action |
| --- | --- |
| `\ll` | Start / stop continuous compile |
| `\lv` | Open the PDF at this line |
| `\le` | Show compile errors |
| `\lc` | Clean aux files |
| `\lt` | Table of contents |

### Plugins and tools

| Keys | Action |
| --- | --- |
| `<space>l` | Plugin manager (Lazy) |
| `<space>m` | Language servers (Mason) |
| `<space>U` | Update plugins, servers, parsers |
