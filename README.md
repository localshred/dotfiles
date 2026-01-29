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

## mx CLI Tool

The `mx` command provides local development utilities.

### Available Commands

#### goto

Navigate to SCM provider URLs for users, repos, issues, and pull requests.

```bash
# Open a user/org page
mx goto -u foo

# Open a repository
mx goto -u foo -r bar

# Open repository issues
mx goto -u foo -r bar -i

# Open specific issue
mx goto -u foo -r bar -i -n 123

# Open repository pull requests
mx goto -u foo -r bar -p

# Open specific pull request
mx goto -u foo -r bar -p -n 456

# Use shorthand (arguments parsed as user/repo/number)
mx goto foo bar
mx goto foo bar 123
```

Configuration file (`mx.goto.json`) supports user and repo aliases:

```json
{
  "l": {
    "user": "localshred",
    "scm": "github",
    "host": "https://github.com",
    "repos": {
      "d": "dotfiles"
    }
  }
}
```

Place config file at:
- `$dotfiles/mx.goto.json` (personal)
- `$dotfiles_work/mx.goto.json` (work)

#### prs

Show open pull requests across all repositories with their CI status.

```bash
# Show your authored PRs (compact format with status indicator)
mx prs

# Show PRs requesting your review (compact format)
mx prs --reviews
mx prs -r

# Show detailed check status for authored PRs
mx prs --verbose
mx prs -v
```
