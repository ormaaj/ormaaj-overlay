# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/radare2/radare2-9999.ebuild,v 2.0 2012/04/04 06:20:21 akochkov Exp $

EAPI=5
inherit base eutils git-2

DESCRIPTION='Advanced command line hexadecimal editor and more'
HOMEPAGE='http://www.radare.org'
EGIT_REPO_URI='http://github.com/radare/radare2'

LICENSE=GPL-2
SLOT=0
KEYWORDS=
IUSE='ssl ewf gmp debug'

RDEPEND='ssl? ( dev-libs/openssl )
	gmp? ( dev-libs/gmp )'

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	local -a cnf
	local x

	for x in ssl gmp ewf debug; do
		use "$x" || cnf+=("--without-${x}")
	done

	econf "${cnf[@]}"
}

src_install() {
	emake DESTDIR="${D}" INSTALL_PROGRAM=install install || die 'install failed'
}
