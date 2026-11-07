# dotfiles

```bash
chezmoi apply
```

```toml
# ~/.config/chezmoi/chezmoi.toml

[data]

[data.git]
email = "YourEmail@emailprovider.com"
name = "Your Name"

[[data.git.credentials]]
hostname = "https://github.com"
helper = ""

[[data.git.credentials]]
hostname = "https://gist.github.com"
helper = ""
```
