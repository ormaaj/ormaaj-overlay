# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Photometric calibration of HDR and LDR cameras"
HOMEPAGE="http://pfstools.sourceforge.net/pfscalibration.html"
SRC_URI="http://downloads.sourceforge.net/project/pfstools/pfscalibration/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=media-gfx/pfstools-1.8.1"

RDEPEND="${DEPEND}"

src_compile() {
	econf || die "configure failed"
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS README TODO
}
