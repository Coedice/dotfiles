# Dotfiles Repository

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

This repository is organized into multiple packages, each containing dotfiles for specific applications:

- **shell/** - Shell configurations (.zshrc, .zprofile, .bashrc, .tmux.conf)
- **fish/** - Fish shell configuration
- **nvim/** - Neovim configuration
- **config/** - Other application configs (starship, htop, ranger)

## Required Installations

- GNU Stow
- Fish shell
- Starship
- LazyGit
- Ripgrep

Clone this dotfiles repo, then use Stow to create symlinks:

```bash
git clone <this repo>
cd path/to/repo
stow -t ~ */ --adopt
```

## Unstow

To remove symlinks:

```bash
stow -D */
```
