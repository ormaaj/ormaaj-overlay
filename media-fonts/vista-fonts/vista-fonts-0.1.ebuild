# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Original Vista Fonts"
HOMEPAGE="http://www.arcong.ath.cx/"
SRC_URI="http://ormaaj.org/pages/gentoo/${P}.tar.bz2"

EAPI=2

LICENSE="MSttfEULA"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""
RESTRICT="nostrip"

DEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack ${A}
}

src_install() {
	cp -a "${WORKDIR}"/* "${D}"/ || die
}
