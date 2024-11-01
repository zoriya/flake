# used by kubectl plugin & maybe some other oh-my-zsh plugins
export ZSH_CACHE_DIR="$HOME/.cache/zsh";
mkdir -p "$ZSH_CACHE_DIR/completions"
fpath+="$ZSH_CACHE_DIR/completions"

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# enable completion from the middle of the word (MUST be specified just ofter the case-insensitive completion)
zstyle ':completion:*' matcher-list '+l:|=* r:|=*'
# use LS_COLORS for autocompletion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# allow manual selection in the completion menu
zstyle ':completion:*:*:*:*:*' menu select
