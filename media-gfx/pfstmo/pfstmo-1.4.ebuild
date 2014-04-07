# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="Implementation of tone mapping operators"
HOMEPAGE="http://pfstools.sourceforge.net/pfstmo.html"
SRC_URI="mirror://sourceforge/pfstools/pfstmo/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	>=media-gfx/pfstools-1.8.1
	sci-libs/fftw:3.0
	>=sci-libs/gsl-1.12
	"

RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${P}-mantiuk08-auto_ptr.patch"
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS README TODO
}
