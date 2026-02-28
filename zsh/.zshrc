# Enable zsh-autosuggestions

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7aa2f7,underline"

HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=1000
HISTDUP=erase
setopt appendHistory
setopt shareHistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Enable zsh-completions
fpath+=~/.zsh/zsh-completions/src
autoload -U compinit && compinit
source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh
# Enable zsh-syntax-highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(starship init zsh)"

# Enable Ctrl + Left Arrow to move one word left
bindkey '^[[1;5D' backward-word

# Enable Ctrl + Right Arrow to move one word right
bindkey '^[[1;5C' forward-word

# Enable Ctrl + Backspace to delete the previous word
bindkey '^H' backward-kill-word

# Enable Ctrl + Delete to delete the next word to the right
bindkey '^[[3;5~' kill-word

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
tailbat() {
  tail "$@" | batcat --paging=never -l log
}

tailbat_fzf () {
    local filepath
    filepath=$(fzf)
 tailbat -f "$filepath"  "$@"
}

alias batf='batcat $(fzf)'
alias tailf='tailbat $(fzf)'
alias cdf='cd $(find . -type d -print | fzf)'
alias codef='code $(find . -type d -print | fzf)'
alias vimf='vim $(fzf --preview="batcat --color=always --line-range=:500 {}")'
alias vimfm='vim $(fzf -m --preview="batcat --color=always --line-range=:500 {}")'j
alias vim=nvim
alias vi=nvim

# Tmux
alias tma="tmux a"
alias tmns="tmux -s"

open_knr() {
    tmux new-session -d -s knr -c "$HOME/dev/knr-study"
    tmux split-window -h -c "$HOME/dev/knr-study"
    tmux attach-session -t knr
}
# Git aliases
# Basic git commands
alias g="git"                       # General shortcut for Git
alias ga="git add"                  # Stage files for commit
alias gaa="git add --all"           # Stage all changes for commit
alias gc="git commit -m"            # Commit with a message
alias gcm="git commit -m"           # Same as gc, for readability
alias gca="git commit --amend"      # Amend the last commit
alias gcam="git commit -am"         # Add and commit in one step
alias gco="git checkout"            # Switch branches or restore files
alias gb="git branch"               # List all branches
alias gba="git branch -a"           # List all branches, including remote
alias gd="git diff"                 # Show file differences not yet staged
alias gds="git diff --staged"       # Show differences between staged changes
alias gl="git log"                  # Show commit logs
alias gl1="git log --oneline"       # Show compact commit log

alias gspro='git status --porcelain'

alias gaf='git add $(gspro | fzf -m | awk '\''{print $2}'\'' )'


#Branch Management
alias gcb="git checkout -b"         # Create and switch to a new branch
alias gprune="git remote prune origin" # Remove deleted remote branches locally
alias gpo="git push origin"         # Push to the remote origin
alias gpu="git push -u origin"      # Push and set upstream
alias grb="git rebase"              # Rebase branches
alias grbi="git rebase -i"          # Interactive rebase

#Status and cleanup
alias gs="git status -s"            # Short status view
alias gss="git status"              # Full status view
alias gr="git reset"                # Reset changes
alias grh="git reset --hard"        # Hard reset to a specific commit
alias grm="git rm"                  # Remove file(s) from staging area
alias gclean="git clean -fd"        # Remove untracked files and directories
alias grs='git restore --staged'
alias grsa='git restore --staged .'

alias grsaf='git restore --staged $(gspro | fzf -m | awk '\''{print $2}'\'')'

# Fetch, pull and merge
alias gf="git fetch"                # Fetch changes from origin
alias gfo="git fetch origin"        # Fetch from origin only
alias gp="git pull"                 # Pull latest changes
alias gpl="git pull"                # Same as gp for clarity
alias gm="git merge"                # Merge branches
alias gmt="git mergetool"           # Open the merge tool

#Stash
alias gst="git stash"               # Stash changes
alias gstp="git stash pop"          # Apply and remove the latest stash
alias gstl="git stash list"         # Show all stashed changes
alias gsta="git stash apply"        # Apply the latest stash without removing it
alias gstc="git stash clear"        # Clear all stashed changes


# Log
alias glog="git log --oneline --decorate --graph"   # Colorful one-line log with graph
alias gshow="git show"                              # Show various types of objects
alias gblame="git blame"                            # Show blame for each line of file
alias gt="git tag"                                  # Show tags
alias gti="git tag -l"                              # List all tags

# QoL
alias gundo="git reset HEAD~"                       # Undo the last commit, keep changes
alias glg="git log --graph --all --decorate --oneline" # Graph log view for all branches

#### misc
alias cdhome='cd ~'
alias l="ls -lah"                       # Detailed list with hidden files
alias ll="ls -lh"                       # List with file sizes
alias la="ls -A"                        # List all files excluding . and ..
alias ls="ls --color=auto"              # Enable color output for ls
alias lt="ls -lt"                       # Sort by modification time, descending
alias ltr="ls -ltr"                     # Sort by modification time, ascending
alias mkdirp='mkdie -p'
alias reload='source ~/.zshrc'




# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
export PATH=$PATH:/usr/local/go/bin:$HOME/.cargo/bin
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

# pnpm
export PNPM_HOME="/home/enesfurkanoz/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export EDITOR="nvim"
export VISUAL="nvim"
# pnpm end
