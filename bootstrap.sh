#!/usr/bin/env bash

# Bootstrap script for fresh Mac setup
# Usage: curl -fsSL https://raw.githubusercontent.com/localshred/dotfiles/main/bootstrap.sh | bash

set -e

color_green='\033[0;32m'
color_yellow='\033[0;33m'
color_red='\033[0;31m'
color_reset='\033[0;39m'

print_info() { echo -e "${color_green}==> $*${color_reset}"; }
print_warn() { echo -e "${color_yellow}~~> $*${color_reset}"; }
print_error() { echo -e "${color_red}!!> $*${color_reset}"; }

# Directory structure
code_dir="$HOME/code"
src_dir="$code_dir/src"
utilities_dir="$src_dir/utilities"
localshred_dir="$src_dir/localshred"

dotfiles_dir="$utilities_dir/dotfiles"
dotfiles_repo="git@github.com:localshred/dotfiles.git"

# Work dotfiles (set via prompts or detected)
work_dir=""
dotfiles_work_dir=""
dotfiles_work_repo=""

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------

check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    print_error "This script is for macOS only"
    exit 1
  fi
}

# -----------------------------------------------------------------------------
# Installation functions
# -----------------------------------------------------------------------------

install_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    print_info "Xcode CLI tools already installed"
  else
    print_info "Installing Xcode CLI tools..."
    xcode-select --install
    print_warn "Press any key after Xcode CLI tools installation completes..."
    read -n 1 -s
  fi
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    print_info "Homebrew already installed"
  else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Set up brew in current shell
  if [[ -d /opt/homebrew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(brew shellenv)"
  fi
}

install_essentials() {
  print_info "Installing essential packages..."
  brew install git gh stow
}

prompt_directories() {
  echo ""
  print_info "Directory structure setup"
  echo ""
  echo "Default directories to create under $src_dir:"
  echo "  - utilities (for dotfiles)"
  echo "  - localshred (personal projects)"
  echo "  - go (Go workspace)"
  echo "  - lib (libraries)"
  echo ""

  read -p "Additional directories to create (space-separated, or Enter to skip): " extra_dirs

  mkdir -p "$utilities_dir"
  mkdir -p "$localshred_dir"
  mkdir -p "$src_dir/go"
  mkdir -p "$src_dir/lib"

  for dir in $extra_dirs; do
    print_info "Creating $src_dir/$dir"
    mkdir -p "$src_dir/$dir"
  done
}

# -----------------------------------------------------------------------------
# 1Password SSH Agent setup
# -----------------------------------------------------------------------------

setup_1password_ssh() {
  print_info "Setting up 1Password SSH agent..."

  local ssh_config="$HOME/.ssh/config"
  local op_agent_sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

  mkdir -p "$HOME/.ssh"

  if [[ -f "$ssh_config" ]] && grep -q "1Password" "$ssh_config"; then
    print_info "1Password SSH agent already configured in ~/.ssh/config"
  else
    print_info "Adding 1Password SSH agent to ~/.ssh/config..."
    cat >> "$ssh_config" << 'EOF'

# 1Password SSH Agent
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
  fi

  if [[ ! -S "$op_agent_sock" ]]; then
    print_warn "1Password SSH agent socket not found."
    print_warn "Please ensure:"
    print_warn "  1. 1Password is installed"
    print_warn "  2. Settings > Developer > 'Use SSH Agent' is enabled"
    print_warn "  3. You have SSH keys configured in 1Password"
    echo ""
    read -p "Press Enter after configuring 1Password, or Ctrl+C to abort..."
  fi

  print_info "Testing SSH connection to GitHub..."
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_info "GitHub SSH authentication successful!"
  else
    print_warn "GitHub SSH test inconclusive. You may need to configure 1Password SSH keys."
  fi
}

# -----------------------------------------------------------------------------
# GitHub CLI authentication
# -----------------------------------------------------------------------------

setup_gh_auth() {
  print_info "Setting up GitHub CLI authentication..."

  if gh auth status &>/dev/null; then
    print_info "Already authenticated with GitHub CLI"
  else
    print_info "Please authenticate with GitHub..."
    gh auth login
  fi
}

# -----------------------------------------------------------------------------
# Clone and install dotfiles
# -----------------------------------------------------------------------------

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"
  local repo_name="$3"

  if [[ -d "$target_dir/.git" ]]; then
    print_info "$repo_name already cloned, pulling latest..."
    git -C "$target_dir" pull --ff-only || {
      print_warn "Could not fast-forward $repo_name. You may need to manually resolve."
    }
  else
    print_info "Cloning $repo_name..."
    git clone "$repo_url" "$target_dir"
  fi
}

clone_dotfiles() {
  clone_or_update_repo "$dotfiles_repo" "$dotfiles_dir" "dotfiles"
}

install_dotfiles() {
  print_info "Running dotfiles installer..."
  cd "$dotfiles_dir"
  ./install.sh
}

# -----------------------------------------------------------------------------
# Work dotfiles (optional)
# -----------------------------------------------------------------------------

detect_work_dotfiles() {
  # Check if dotfiles_work is already set in .zshrc
  local zshrc="$HOME/.zshrc"
  if [[ -f "$zshrc" ]]; then
    local existing_path
    existing_path=$(grep "^export dotfiles_work=" "$zshrc" 2>/dev/null | cut -d'"' -f2 || true)
    if [[ -n "$existing_path" && -d "$existing_path" ]]; then
      dotfiles_work_dir="$existing_path"
      work_dir="$(dirname "$dotfiles_work_dir")"
      return 0
    fi
  fi
  return 1
}

prompt_work_dotfiles() {
  echo ""

  # Check if work dotfiles already configured
  if detect_work_dotfiles; then
    print_info "Work dotfiles detected at: $dotfiles_work_dir"
    read -p "Update existing work dotfiles? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      update_work_dotfiles
    else
      print_info "Skipping work dotfiles"
    fi
    return
  fi

  read -p "Set up work dotfiles? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    prompt_work_config
    setup_work_dotfiles
  else
    print_info "Skipping work dotfiles"
  fi
}

prompt_work_config() {
  echo ""
  print_info "Work dotfiles configuration"
  echo ""

  read -p "Work directory name (under $src_dir): " work_dir_name
  work_dir="$src_dir/$work_dir_name"
  dotfiles_work_dir="$work_dir/dotfiles"

  read -p "Work dotfiles git repo URL: " dotfiles_work_repo

  echo ""
  print_info "Work dotfiles will be cloned to: $dotfiles_work_dir"
  print_info "From repo: $dotfiles_work_repo"
  echo ""
  read -p "Continue? (y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warn "Skipping work dotfiles"
    work_dir=""
    dotfiles_work_dir=""
    dotfiles_work_repo=""
  fi
}

update_work_dotfiles() {
  [[ -z "$dotfiles_work_dir" ]] && return

  print_info "Updating work dotfiles..."

  if [[ -d "$dotfiles_work_dir/.git" ]]; then
    git -C "$dotfiles_work_dir" pull --ff-only || {
      print_warn "Could not fast-forward work dotfiles. You may need to manually resolve."
    }
  fi

  print_info "Running work dotfiles installer..."
  cd "$dotfiles_work_dir"
  ./install.sh
}

setup_work_dotfiles() {
  [[ -z "$dotfiles_work_dir" ]] && return

  print_info "Setting up work dotfiles..."

  # Create work directory
  mkdir -p "$work_dir"

  if [[ -d "$dotfiles_work_dir/.git" ]]; then
    print_info "Work dotfiles already cloned, pulling latest..."
    git -C "$dotfiles_work_dir" pull --ff-only || {
      print_warn "Could not fast-forward work dotfiles. You may need to manually resolve."
    }
  else
    print_info "Cloning work dotfiles..."
    print_warn "You may need to authenticate with your work Git server"
    git clone "$dotfiles_work_repo" "$dotfiles_work_dir"
  fi

  print_info "Running work dotfiles installer..."
  cd "$dotfiles_work_dir"
  ./install.sh
}

# -----------------------------------------------------------------------------
# Post-install
# -----------------------------------------------------------------------------

post_install() {
  print_info "Running post-install tasks..."

  local zshrc="$HOME/.zshrc"

  # Set up dotfiles_work env var for zsh if work dotfiles were configured
  if [[ -n "$dotfiles_work_dir" ]]; then
    if [[ -f "$zshrc" ]] && ! grep -q "^export dotfiles_work=" "$zshrc"; then
      print_info "Adding dotfiles_work to .zshrc..."
      {
        echo ""
        echo "# Work dotfiles path"
        echo "export dotfiles_work=\"$dotfiles_work_dir\""
      } >> "$zshrc"
    fi
  fi

  # Sync claude config
  if [[ -f "$zshrc" ]]; then
    print_info "Syncing Claude configuration..."
    zsh -c "source $zshrc && type claudesync &>/dev/null && claudesync" 2>/dev/null || true
  fi

  echo ""
  print_info "Bootstrap complete!"
  echo ""
  print_warn "Next steps:"
  print_warn "  1. Restart your terminal or run: source ~/.zshrc"
  print_warn "  2. Run 'claudesync' to combine Claude configurations"
  print_warn "  3. Open 1Password and verify SSH keys are configured"
  echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
  echo ""
  print_info "Starting Mac bootstrap..."
  echo ""

  check_macos
  install_xcode_cli
  install_homebrew
  install_essentials
  prompt_directories
  setup_1password_ssh
  setup_gh_auth
  clone_dotfiles
  install_dotfiles
  prompt_work_dotfiles
  post_install
}

main "$@"
