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
	playlist_length=$(echo "{\"command\": [\"get_property\", \"playlist-count\"]}" | socat - /tmp/mpv.sock | jq '.data')
	playlist_position=$(echo "{\"command\": [\"get_property\", \"playlist-pos\"]}" | socat - /tmp/mpv.sock | jq '.data')
	playing_eof=$(echo "{\"command\": [\"get_property\", \"eof-reached\"]}" | socat - /tmp/mpv.sock | jq '.data')

	for i in $(seq 0 "$((playlist_length - 1))"); do
		if [ "$i" -eq "$playlist_position" ] && [ "$playing_eof" != "true" ]; then
			break
		fi
		echo "{\"command\": [\"playlist-remove\", \"$i\"]}" | socat - /tmp/mpv.sock
	done
	unset playlist_length playlist_position playing_eof i

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
