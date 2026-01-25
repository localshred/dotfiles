# @localshred Dotfiles

Various dotfiles for everyday use. Alias and functions dotfiles are zsh specific,
but may work for bash too.

## Fresh Mac Setup

Run the bootstrap script on a fresh Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/localshred/dotfiles/main/bootstrap.sh | bash
```

The script will:

1. Install Xcode CLI tools and Homebrew
2. Set up 1Password SSH agent
3. Authenticate with GitHub CLI
4. Clone and install dotfiles using GNU Stow
5. Optionally configure work-specific dotfiles

The script is idempotent and can be re-run safely if something fails.

## Manual Installation

If dotfiles are already cloned:

```bash
./install.sh
```

To uninstall (remove symlinks):

```bash
./install.sh uninstall
```
