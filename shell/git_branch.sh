#!/bin/sh

###############################################################################
#                                                                             #
#  ██████╗ ██╗████████╗    ██████╗ ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗ #
# ██╔════╝ ██║╚══██╔══╝    ██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔════╝██║  ██║ #
# ██║  ███╗██║   ██║       ██████╔╝██████╔╝███████║██╔██╗ ██║██║     ███████║ #
# ██║   ██║██║   ██║       ██╔══██╗██╔══██╗██╔══██║██║╚██╗██║██║     ██╔══██║ #
# ╚██████╔╝██║   ██║       ██████╔╝██║  ██║██║  ██║██║ ╚████║╚██████╗██║  ██║ #
#  ╚═════╝ ╚═╝   ╚═╝       ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝ #
#                                                                             #
###############################################################################

# Get current/master/develop branch
git rev-parse --git-dir >/dev/null || return
case $1 in
current)
	ref=$(git symbolic-ref --quiet HEAD 2>/dev/null)
	case $? in
	0) echo "$ref" | sed 's|.*/||' ;;
	128) ;;
	*) git rev-parse --short HEAD 2>/dev/null ;;
	esac
	unset ref
	return
	;;
master)
	for type in heads remotes; do
		for remote in origin upstream; do
			for branch in default main mainline master trunk; do
				case $type in
				heads) ref="$branch" ;;
				remotes) ref="$remote/$branch" ;;
				esac
				if git show-ref -q --verify refs/"$type"/"$ref"; then
					echo $branch
					unset type remote branch ref
					return
				fi
			done
		done
	done
	unset type remote branch ref
	echo master
	;;
develop)
	for branch in dev devel develop development; do
		if git show-ref -q --verify refs/heads/$branch; then
			echo $branch
			unset branch
			return
		fi
	done
	unset branch
	echo develop
	;;
esac
return 1
