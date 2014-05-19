# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

versionMap() {
	# Specify an alternate AST distribution if needed.
	myPkgName=

	case $1 in
		*[^[:digit:]]*|'')
			return 1
			;;
		9999)
			myPkgName=ast-open
			EGIT_REPO_URI=http://I.accept.www.opensource.org.licenses.eclipse:.@www2.research.att.com/sw/git/ast-open
			SRC_URI=
			;;
		*)
			# Setup mappings to upstream's randomly released testing packages
			# and calculate the corresponding SRC_URI
			local -A v
			local x=(
				\[2012{0229,0504,0518}\]=ast-base
				\[{2012{0628,0801,1024,1121},2013{0422,0628,07{19,27},0829,09{13,26},1010},2014{0114,0415,0509}}\]=ast-open
				\[{2012{1004,1012},2013{0214,0222,0318,0402,0409,05{03,24}}}\]=ast-ksh
				) "v=(${x[*]})"

			printf -v SRC_URI "%s.$(LC_TIME=C date -d "$1" +%F).tgz\n" \
				{mirror://gentoo,'http://dev.gentoo.org/~flopppym/distfiles'}/{INIT,"${myPkgName:=${v[$1]:-ast-base}}"}
	esac
}

versionMap "${PV##*.}" || die
inherit toolchain-funcs prefix eutils ${EGIT_REPO_URI+git-2}

DESCRIPTION='The AT&T Korn Shell'
HOMEPAGE='http://www.kornshell.com/ http://www2.research.att.com/~gsf/download/ksh/ksh.html'
LICENSE='CPL-1.0 EPL-1.0'
SLOT=0
KEYWORDS=
IUSE=+plugins
RDEPEND=
S=$WORKDIR

src_prepare() {
	# Bug 238906
	local f
	for f in bin/package src/cmd/INIT/package.sh; do
		ed -s "$f" </dev/fd/0 || die 
	done <<\EOF
g|cd /tmp|s,,cd "${TMPDIR:-/tmp}",g
w
EOF

	# Bug 230241
	epatch "${FILESDIR}/${PN}-prefix.patch"
	eprefixify src/cmd/ksh93/data/msg.c

	# Backport http://article.gmane.org/gmane.comp.programming.tools.ast.devel/651
	if (( ${PV##*.} < 20121024 )); then
		epatch "${FILESDIR}/${PN}-fix-command-builtin.patch"
	fi

	epatch_user
}

src_compile() {
	if [[ $FUNCNAME != "${FUNCNAME[1]}" ]]; then
		tc-export AR CC LD NM
		export CCFLAGS=$CFLAGS
		local -a packageOpts=("SHELL=${EPREFIX}/bin/sh" SHOPT_SYSRC=1)
		#local -a packageOpts=("SHELL=${EPREFIX}/bin/sh")
		use plugins && packageOpts+=(SHOPT_CMDLIB_DIR=1)
		local -f +t "$FUNCNAME"
		"$FUNCNAME" "$@" || die
	else
		sh bin/package flat only make ast-ksh "${packageOpts[@]}"
		trap "trap RETURN; einfo 'make results:'; sh bin/package results; return $?" RETURN
	fi
}

src_test() {
	sh bin/package test
	einfo "test status: $?"
	einfo 'test results:'
	sh bin/package results test
	einfo "results status: $?"
}

src_install() {
	dodoc "lib/package/${myPkgName}.README"
	dohtml "lib/package/${myPkgName}.html"
	into /
	dobin bin/ksh
	dosym ksh /bin/rksh
	newman man/man1/sh.1 ksh.1
}
