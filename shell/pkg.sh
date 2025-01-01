#!/bin/sh

# Check OS
if test -e /etc/os-release; then
	case $(grep -oP "(?<=^ID=).+" /etc/os-release | tr -d '"') in
	arch | manjaro | steamos)
		if [ "$(command -v paru)" != "" ]; then
			cmd="paru"
		else
			cmd="sudo pacman"
		fi
		osI="$cmd -S"
		osU="$cmd -Syu"
		osR="$cmd -Rnsc"
		osS="$cmd -Ss"
		unset cmd
		;;
	debian | ubuntu)
		osI="sudo apt install"
		osU="sudo apt update && apt upgrade"
		osR="sudo apt remove"
		osS="sudo apt search"
		;;
	fedora)
		osI="sudo dnf install"
		osU="sudo dnf check-update && dnf upgrade"
		osR="sudo dnf remove"
		osS="sudo dnf search"
		;;
	*)
		printf "OS not recognized or supported"
		;;
	esac
else
	printf "OS not recognized or supported"
fi

# Check Node.js package manager
if [ "$(command -v pnpm)" != "" ]; then
	npm="pnpm"
else
	npm="npm"
fi

case $1 in
global | g)
	# Global package management
	shift
	case $1 in
	install | i)
		shift
		case $1 in
		os | o)
			shift
			$osI "$@"
			;;
		python | py)
			shift
			sudo pip install "$@"
			;;
		ruby | r)
			shift
			gem install "$@"
			;;
		node | n)
			shift
			$npm add -g "$@"
			;;
		*)
			printf "Third parameter should be one of:\nos (o), python (py), ruby (r), node (n)"
			;;
		esac
		;;
	update | u)
		shift
		printf "Updating system packages...\n"
		$osU
		if [ "$(command -v pip)" != "" ]; then
			printf "Updating pip packages...\n"
			pip --disable-pip-version-check list --outdated --format=json | python -c "import json, sys; print('\n'.join([x['name'] for x in json.load(sys.stdin)]))" | xargs -n1 sudo pip install --upgrade
		fi
		if [ "$(command -v gem)" != "" ]; then
			printf "Updating gem packages...\n"
			gem update
		fi
		if [ "$(command -v $npm)" != "" ]; then
			printf "Updating npm packages...\n"
			$npm update -g
		fi
		;;
	remove | r)
		shift
		case $1 in
		os | o)
			shift
			$osR "$@"
			;;
		python | py)
			shift
			sudo pip uninstall "$@"
			;;
		ruby | r)
			shift
			gem uninstall "$@"
			;;
		node | n)
			shift
			$npm uninstall -g "$@"
			;;
		*)
			printf "Third parameter should be one of:\nos (o), python (py), ruby (r), node (n)"
			;;
		esac
		;;
	search | s)
		shift
		case $1 in
		os | o)
			shift
			$osS "$@"
			;;
		python | py)
			shift
			pip search "$@"
			;;
		ruby | r)
			shift
			gem search "$@"
			;;
		node | n)
			shift
			$npm search "$@"
			;;
		*)
			printf "Third parameter should be one of:\nos (o), python (py), ruby (r), node (n)"
			;;
		esac
		;;
	*)
		printf "Second parameter should be one of:\ninstall (i), update (u), remove (r), search (s)"
		;;
	esac
	unset osI osU osR osS
	;;
local | l)
	# Project package management
	shift
	#TODO: Determine package manager(s) for project and execute appropriate commands
	;;
*)
	printf "First parameter should be either:\nglobal (g) OR local (l)"
	;;
esac
unset npm
