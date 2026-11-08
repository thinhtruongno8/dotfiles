# dotfiles

## Getting started

Install chezmoi

```bash
VER=2.74.0
curl -L https://github.com/twpayne/chezmoi/releases/download/v${VER}/chezmoi_${VER}_linux_amd64.deb -o cm.deb
sudo apt install ./cm.deb
```

Create and update this file `~/.config/chezmoi/chezmoi.toml` with your info.

```toml
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

Init (pull repo and populate template)

```bash
chezmoi init thinhtruongno8
```

Apply All

```bash
chezmoi apply
```

Apply Partially

```bash
chezmoi apply ~/.config/nvim
```

## Routine tasks

```bash
chezmoi diff
chezmoi apply

chezmoi diff --reverse
chezmoi re-add
```

## Template

1) Git commit template: `~/.gitcommitmsg`
```
title

Issue:

Fix:
```
