# -------------------------------------------
# | ALIASES AND FUNCTIONS                   |
# -------------------------------------------
alias ls='ls --color=auto'
alias diff='diff --color=auto -u'
alias grep='grep --color=auto'

alias v=$EDITOR

# git
alias g='git'
alias glo='git log --oneline'
alias gloga='git log --oneline --graph --all'

# Multiplexer
alias t='tmux'
alias z='zellij'

# Nvim
alias m='nvim +Man!'

# DevOps - Terraform
alias tf='terraform'
alias tg='terragrunt'

# Containers
alias dk='docker'

# Kubernetes
alias k='kubectl'

# AWS
alias asl='aws sso login'

function atx() {
    local ctx=("none" $(aws configure list-profiles))
    ctx=$(print -l $ctx | fzf)
    if [[ "$ctx" != "none" || -z "$ctx" ]]; then
        unset AWS_PROFILE
    else
        export AWS_PROFILE="$ctx"
    fi
}

# Esoteric
alias rma='tee >(xargs rm -fr)'
alias pgg='curl https://api.ipify.org'

alias cm='chezmoi'
alias reload='source ~/.zshrc'
