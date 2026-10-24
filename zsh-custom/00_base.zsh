# mise
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh --shims)"
else
    echo "mise not found" >&2
fi

# prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# fzf - keybinding and fuzzy completion
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# aws
# autocomplete
if command -v aws_completer &>/dev/null; then
    complete -C $(which aws_completer) aws
fi
