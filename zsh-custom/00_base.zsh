# mise
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh --shims)"
else
    echo "mise not found" >&2
fi

# env
export LANG=C.UTF-8
export EDITOR=$(command -v nvim || command -v vi)
export VISUAL=$EDITOR
export SUDO_EDITOR=$EDITOR

typeset -U path PATH
path=(~/utils $path)
path=(~/bin $path)
path=(~/.local/bin $path)
path=(~/.bun/bin $path)

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

# nvim
if command -v nvim &>/dev/null; then
    export MANPAGER="nvim +Man!"
fi
