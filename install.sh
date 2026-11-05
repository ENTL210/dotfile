#!/bin/sh
# Dotfile installer for Mac (and Linux, like the OSU server).
#
#   sh ~/Dotfile/install.sh        shows the menu
#   sh ~/Dotfile/install.sh 1      runs option 1 without the menu
#
# To add a new option later: write a function, add a line to show_menu,
# and add a case to run_choice.

set -u

REPO="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

info() { printf '\n==> %s\n' "$1"; }
warn() { printf '    ! %s\n' "$1"; }

ask_yes() {
  # ask_yes "question" -> returns 0 for yes
  printf '%s [y/N] ' "$1"
  read -r reply
  case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# ---------------------------------------------------------------- helpers

pull_dotfile() {
  info "Getting the newest Dotfile from GitHub"
  if [ ! -d "$REPO/.git" ]; then
    warn "This folder is not a git clone, skipping the pull"
    return
  fi
  if ! git -C "$REPO" pull --ff-only; then
    warn "Pull failed (local changes or no internet). Using the files already here."
  fi
}

load_brew() {
  # makes brew usable in this shell, even right after installing it
  if command -v brew >/dev/null 2>&1; then return 0; fi
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [ -x "$b" ]; then
      eval "$("$b" shellenv)"
      return 0
    fi
  done
  return 1
}

brew_get() {
  # install the formula, or upgrade it when it is already installed
  for pkg in "$@"; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      printf '    upgrading %s\n' "$pkg"
      brew upgrade "$pkg" >/dev/null 2>&1 || true
    else
      printf '    installing %s\n' "$pkg"
      brew install "$pkg" || warn "Could not install $pkg"
    fi
  done
}

install_programs() {
  info "Installing / updating Neovim and the tools the config uses"

  if [ "$OS" = "Darwin" ]; then
    if ! xcode-select -p >/dev/null 2>&1; then
      warn "Xcode command line tools are missing (needed for git and the C compiler)"
      xcode-select --install
      echo "    Finish the popup install, then run this script again."
      exit 1
    fi
    if ! load_brew; then
      if ask_yes "Homebrew is not installed. Install it now?"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        load_brew || { warn "Homebrew still not found, stopping"; exit 1; }
      else
        warn "Skipping programs. Install Neovim 0.12+ yourself."
        return
      fi
    fi
  elif ! load_brew; then
    # Linux without Homebrew (for example the OSU server): leave programs alone
    warn "No Homebrew here, so Neovim is not installed or updated by this script."
    if command -v nvim >/dev/null 2>&1; then
      warn "Found $(nvim --version | head -n 1). The config needs 0.12 or newer."
    fi
    return
  fi

  brew update >/dev/null 2>&1 || true
  brew_get neovim git ripgrep fd tree-sitter-cli
  # leave node alone if you already have one (for example from nvm)
  command -v node >/dev/null 2>&1 || brew_get node
  printf '    %s\n' "$(nvim --version | head -n 1)"
}

link_config() {
  info "Putting the Dotfile config in place"
  target="$HOME/.config/nvim"
  mkdir -p "$HOME/.config"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    printf '    Old config moved to %s\n' "$backup"
    if ask_yes "Also clear the old config's plugin data (recommended the first time)?"; then
      rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
      printf '    Cleared old plugin data\n'
    fi
  fi

  ln -s "$REPO/nvim" "$target"
  printf '    %s -> %s\n' "$target" "$REPO/nvim"
}

sync_plugins() {
  info "Installing plugins at the versions in lazy-lock.json"
  if ! command -v nvim >/dev/null 2>&1; then
    warn "nvim not found, skipping"
    return
  fi
  nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || warn "Plugin sync reported a problem, open nvim and run :Lazy"
  printf '    Done. Language servers install the first time you open a code file.\n'
}

# ---------------------------------------------------------------- options

option_install() {
  pull_dotfile
  install_programs
  link_config
  sync_plugins
  info "Neovim is ready"
}

show_menu() {
  echo
  echo "  Dotfile setup"
  echo "  [1] Install / Update nvim"
  echo "  [0] Quit"
  printf '  Choose: '
}

run_choice() {
  case "$1" in
    1) option_install ;;
    0|q|Q) exit 0 ;;
    *) echo "  Not an option: $1" ;;
  esac
}

if [ $# -gt 0 ]; then
  run_choice "$1"
  exit 0
fi

show_menu
read -r choice
run_choice "$choice"
