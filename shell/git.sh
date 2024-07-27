#!/bin/sh

#########################
#                       #
#  ██████╗ ██╗████████╗ #
# ██╔════╝ ██║╚══██╔══╝ #
# ██║  ███╗██║   ██║    #
# ██║   ██║██║   ██║    #
# ╚██████╔╝██║   ██║    #
#  ╚═════╝ ╚═╝   ╚═╝    #
#                       #
#########################

# If in $HOME then set dotfiles dirs
if [ "$(pwd)" = "$HOME" ]; then
	/bin/git --git-dir="$XDG_DATA_HOME"/dotfiles/ --work-tree="$HOME" "$@"
else
	/bin/git "$@"
fi
