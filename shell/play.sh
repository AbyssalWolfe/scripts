#!/bin/sh

#####################################
#                                   #
# ██████╗ ██╗      █████╗ ██╗   ██╗ #
# ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝ #
# ██████╔╝██║     ███████║ ╚████╔╝  #
# ██╔═══╝ ██║     ██╔══██║  ╚██╔╝   #
# ██║     ███████╗██║  ██║   ██║    #
# ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝    #
#                                   #
#####################################

# Check for existing MPV instance using mpv.sock
if [ -e "/tmp/mpv.sock" ] && echo "{\"command\": [\"get_version\"]}" | socat - /tmp/mpv.sock | grep -q "success"; then
	# Clear played files from playlist
	while [ "$(echo "{\"command\": [\"get_property\", \"playlist-pos\"]}" | socat - /tmp/mpv.sock | jq '.data')" -ne 0 ]; do
		echo "{\"command\": [\"playlist-remove\", \"0\"]}" | socat - /tmp/mpv.sock
	done

	# Clear current file if EOF reached
	if [ "$(echo "{\"command\": [\"get_property\", \"eof-reached\"]}" | socat - /tmp/mpv.sock | jq '.data')" = "true" ]; then
		echo "{\"command\": [\"playlist-remove\", \"0\"]}" | socat - /tmp/mpv.sock
	fi

	# Append to playlist
	for url in "$@"; do
		if [ -z "$url" ]; then
			continue
		fi
		echo "{\"command\": [\"loadfile\", \"$url\", \"append-play\"]}" | socat - /tmp/mpv.sock
	done
	unset url

	return
fi

# Kill any rogue MPV processes
pkill mpv

# Create MPV instance
nohup mpv --no-terminal --input-ipc-server=/tmp/mpv.sock "$@" >/dev/null &
