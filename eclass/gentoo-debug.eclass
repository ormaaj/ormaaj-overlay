# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: gentoo-debug.eclass
# @MAINTAINER:
# Dan Douglas <ormaaj@gmail.com>
# @BLURB: Various ebuild debugging functions

# @FUNCTION: args
# @DESCRIPTION:
# Convenient colorized display of the given "words".
# @VARIABLE: ofd
# @DESCRIPTION:
# File descriptor to use for output.
# Defaults to 2.
args() {
	if [[ $- == *x* ]]; then
		set +x
		trap 'set -x' RETURN
	fi

	if [[ -t ${ofd:-2} ]]; then
		local -A 'clr=( [green]="$(tput setaf 2)" [sgr0]="$(tput sgr0)" )'
	else
		local clr
	fi

	printf -- "${clr[green]}<${clr[sgr0]}%s${clr[green]}>${clr[sgr0]} " "$@"
	echo

} >&"${ofd:-2}"

# @FUNCTION: callDepth
# @DESCRIPTION:
# Returns the number of adjacent direct (non-mutual) recursive calls of the
# current function.
callDepth() {
	# Strip "main" off the end of FUNCNAME[@] if current function is named "main" and
	# Bash added an extra "main" for non-interactive scripts.
	if [[ main == !(!("${FUNCNAME[1]}")|!("${FUNCNAME[-1]}")) && $- != *i* ]]; then
		local -a 'fnames=("${FUNCNAME[@]:1:${#FUNCNAME[@]}-2}")'
	else
		local -a 'fnames=("${FUNCNAME[@]:1}")'
	fi

	if (( ! ${#fnames[@]} )); then 
		printf 0 
		return
	fi

	local n
	while [[ $fnames == ${fnames[++n]} ]]; do
		:
	done

	printf -- $n
}

# @FUNCTION: lsfd
# @USAGE: [-u ofd] [-t target] [fd1 fd2 fd3 ...]
# @DESCRIPTION:
# lsof wrapper printing fds
# @VARIABLE: ofd
# @DESCRIPTION:
# File descriptor to use for output. Same as -u <fd>
# Defaults to 2.
# @VARIABLE: target
# @DESCRIPTION:
# The target PID. Defaults to BASHPID. Same as -t <PID>
lsfd() {
	local ofd=${ofd:-2} target=${target:-$BASHPID}

	while [[ $1 == -* ]]; do
		if [[ -z $2 || $2 == *[![:digit:]]* ]]; then
			eerror "${FUNCNAME}: $2 - invalid argument to $1"
			return 1
		fi
		case ${1##+(-)} in
			u)
				shift
				ofd=$1
				shift
				;;
			t)
				shift
				target=$1
				shift
		esac
	done

	IFS=, local -a 'fds=('"${*:-{0..20\}}"')' 'fds=("${fds[*]}")'
	lsof -a -p "$target" -d "$fds" +f g -- >&"$ofd"
}

setupFDs() {
	exec {inFD}</proc/${PPID}/fd/0 {outFD}>/proc/${PPID}/fd/1
}

setupFDs
