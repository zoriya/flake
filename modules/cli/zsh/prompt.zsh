setopt promptsubst

# (){
# 	local left right invisible leftcontent
#
# 	# User name.
# 	left+='%B%F{black}%K{green} %n '
# 	# Current working directory.
# 	left+='%K{yellow} %~ '
#
# 	# Version control branch.
# 	right='${vcs_info_msg_0_:+${vcs_info_msg_0_//[%]/%%} }'
# 	# Virtualenv.
# 	export VIRTUAL_ENV_DISABLE_PROMP=1
# 	right+='${VIRTUAL_ENV:+venv }'
#
# 	# Editing mode. $ZLE_MODE shouldn't contain %, no need to escape
# 	ZLE_MODE=insert
# 	right+='%K{green} $ZLE_MODE'
#
# 	# closing
# 	right+=$' %k%f%b'
#
# 	# Combine left and right prompt with spacing in between.
# 	invisible='%([BSUbfksu]|([FBK]|){*})'
#
# 	leftcontent=${(S)left//$~invisible}
# 	rightcontent=${(S)right//$~invisible}
#
# 	PS1="$left\${(l,COLUMNS-\${#\${(%):-$leftcontent$rightcontent}},)}$right%{"$'\n%}$ '
# 	}

WORKDIR='%B%F{blue}%~%b%f'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '(%b)'
precmd() {
	vcs_info
}
GIT='%F{green}$vcs_info_msg_0_%f'

PROMPT_SHLVL='%(?.%F{green}.%F{red})$(printf "❯%.0s" {1..$SHLVL})%f'

# %(?.%F{green}>.$F{red}>.)

export PROMPT="-----\n$WORKDIR $GIT $PROMPT_SHLVL "
export RPROMPT='%j'
