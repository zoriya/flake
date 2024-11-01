# used by kubectl plugin & maybe some other oh-my-zsh plugins
export ZSH_CACHE_DIR="$HOME/.cache/zsh";
mkdir -p "$ZSH_CACHE_DIR/completions"
fpath+="$ZSH_CACHE_DIR/completions"

# default completion system
zstyle ':completion:*' completer _complete
# case insensitive completion & enable completion from the middle of the word 
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# use LS_COLORS for autocompletion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# allow manual selection in the completion menu
zstyle ':completion:*:*:*:*:*' menu select
