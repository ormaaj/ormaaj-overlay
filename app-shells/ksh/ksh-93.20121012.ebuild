# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# Specify an alternate AST distribution if needed.
myPkgName=ast-ksh

if [[ $PV == 9999 ]]; then
	myPkgName=ast-open
	EGIT_REPO_URI=http://I.accept.www.opensource.org.licenses.eclipse:.@www2.research.att.com/sw/git/ast-open
	SRC_URI=
else
	printf -v SRC_URI "%s.$(LC_TIME=C date -d "${PV##*.}" +%F).tgz\n" \
		{mirror://gentoo,'http://dev.gentoo.org/~flopppym/distfiles'}/{INIT,"${myPkgName:=ast-base}"}
fi

inherit toolchain-funcs prefix eutils ${EGIT_REPO_URI+git-2}

DESCRIPTION='The Original Korn Shell, 1993 revision (ksh93)'
HOMEPAGE=http://www.kornshell.com/
LICENSE='CPL-1.0 EPL-1.0'
SLOT=0
KEYWORDS='~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86'
IUSE=plugins
RDEPEND=!app-shells/pdksh
S=$WORKDIR

src_prepare() {
	# Bug 238906
	typeset f
	for f in bin/package src/cmd/INIT/package.sh; do
		ed -s "$f" </dev/fd/0 || die 
	done <<\EOF
g|cd /tmp|s,,cd "${TMPDIR:-/tmp}",g
w
EOF

	epatch "${FILESDIR}/${PN}-prefix.patch"
	eprefixify src/cmd/ksh93/data/msg.c

	# http://article.gmane.org/gmane.comp.programming.tools.ast.devel/651
	if (( $(LC_TIME=C date -d "${PV##*.}" +%Y%m%d) < 20121024 )); then
		epatch "${FILESDIR}/${PN}-fix-command-builtin.patch"
	fi
}

src_compile() {
	tc-export AR CC LD NM
	export CCFLAGS=$CFLAGS

	typeset -a packageOpts=("SHELL=${EPREFIX}/bin/sh" SHOPT_SYSRC=1)
	use plugins && packageCmd+=(SHOPT_CMDLIB_DIR=1)
	sh bin/package flat setup || die
	sh bin/package only make ast-ksh "SHELL=${EPREFIX}/bin/sh" SHOPT_CMDLIB_DIR=1 || die
	sh bin/package results
}

src_test() {
	bin/package test
	bin/package results test
}

src_install() {
	dodoc "lib/package/${myPkgName}.README"
	dohtml "lib/package/${myPkgName}.html"

	cd "arch/$(sh bin/package host)" || die
	into /
	dobin bin/ksh
	dosym ksh /bin/rksh
	newman man/man1/sh.1 ksh.1
}
