#!/usr/bin/env bash

IMLIST_FILE="/tmp/fcitx5-imlist"

# Print out identifier of current input method
current() {
	dbus-send --session --print-reply \
		--dest=org.fcitx.Fcitx5 \
		/controller \
		org.fcitx.Fcitx.Controller1.CurrentInputMethod \
		| grep -Po '(?<=")[^"]+' \
		|| echo "en"
}

# List all input methods added to Fcitx
imlist() {
	if [ ! -f "${IMLIST_FILE}" ]; then
		dbus-send --session --print-reply --dest=org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.AvailableInputMethods \
			| awk 'BEGIN{i=0}{
					if($0~/struct {/) i=0;
					else if(i<6){gsub(/"/,"",$2); printf("%s,",$2); i++}
					else if(i==6){printf("%s\n",$2); i++}
					}' > ${IMLIST_FILE}
		# Output like this:
		# pinyin, 拼音, 拼音, fcitx-pinyin, 拼, zh_CN, true
		# rime, 中州韻, , fcitx-rime, ㄓ, zh, true
		# ......
	fi
	cat ${IMLIST_FILE}
}

# This script wait for events from `watch` and
# update the text by printing a new line.
#
# Strip `Keyboard - ` part from IM name then print
print_pretty_name() {
	name=$(imlist | grep "^$(current)," | cut -d',' -f5)
	if [[ -z "$name" ]]; then
		return
	fi
	echo "${name}"
}

react() {
	print_pretty_name

	# Track input method changes. Each new line read is an event fired from IM switch
	while true; do
		# When read someting from dbus-monitor
		read -r unused
		print_pretty_name
	done
}

# Watch for events from Fcitx.
# Need --line-buffered to avoid messages being hold in buffer
# dbus-monitor --session destination=org.freedesktop.IBus | grep --line-buffered '65505\|65509' | react

# Dbus watching does not seems to work so /shrug
print_pretty_name
