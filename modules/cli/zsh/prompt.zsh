setopt promptsubst
zmodload zsh/datetime
zmodload zsh/mathfunc
zmodload zsh/stat

timer_preexec() {
	timer=$EPOCHREALTIME
}
add-zsh-hook preexec timer_precmd
timer_precmd() {
	if [ -z $timer ]; then
		EXEC_TIME=""
		return
	fi
	local d_s=$((EPOCHREALTIME - timer))
	local s=$((int(rint(d_s % 60))))
	local m=$((int(rint( (d_s / 60) % 60 ))))
	local h=$((int(rint(d_s / 3600))))

	if   ((h > 0)); then EXEC_TIME=${h}h${m}m
	elif ((m > 0)); then EXEC_TIME=${m}m${s}s
	elif ((s > 0)); then EXEC_TIME=${s}s
	else unset EXEC_TIME
	fi
	unset timer
}
add-zsh-hook precmd timer_precmd


kube_check_time=0
kube_precmd() {
	local mtime=$(zstat +mtime ${KUBECONFIG-~/.kube/config})
	if [[ $mtime -gt $kube_check_time ]]; then
		KCTX=$(kubectl config current-context)
		KNS=$(kubectl config view --minify --output 'jsonpath={..namespace}')
		kube_check_time=$EPOCHREALTIME
	fi
}
add-zsh-hook precmd kube_precmd


FILL="%F{#808080}${(l.$COLUMNS..·.)}%f"
NEWLINE=$'\n'

WORKDIR='%B%F{blue}%~%b%f'
RO='%F{red}$([ -w . ] || echo ':ro")%f"
# from gitstatusd, sourced before this prompt script
GIT='($GITSTATUS_PROMPT)'
KUBE='%F{cyan}$KCTX/$KNS%f'
PROMPT_SHLVL='%(?.%F{green}.%F{red})$(printf "❯%.0s" {1..$SHLVL})%f'

EXEC_TIME=""
EXIT_CODE=' %(?..%F{red}x${(j[|])pipestatus}%f)'
JOBS=' %F{cyan}%(1j.&%j.)%f'

export PROMPT="${FILL}${NEWLINE}$WORKDIR$RO $GIT $KUBE $PROMPT_SHLVL "
export RPROMPT="\${EXEC_TIME}${EXIT_CODE}${JOBS}"
