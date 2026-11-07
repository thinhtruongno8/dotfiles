# dotfiles

## Routine tasks

```bash
chezmoi diff
chezmoi apply

chezmoi diff --reverse
chezmoi re-add
```

## Inputs

Create and update this file `~/.config/chezmoi/chezmoi.toml` with your info.

```toml
#

[data]

[data.git]
email = "YourEmail@emailprovider.com"
name = "Your Name"

[[data.git.credentials]]
hostname = "https://github.com"
helper = "!gh auth git-credential"

[[data.git.credentials]]
hostname = "https://gist.github.com"
helper = "!gh auth git-credential"
```

## Template

1) Git commit template: `~/.gitcommitmsg`
```
title

Issue:

Fix:
```
