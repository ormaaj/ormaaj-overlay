# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit eutils

DESCRIPTION="A set of programs for reading, writing, manipulating and viewing high-dynamic range (HDR) images and video frames"
HOMEPAGE="http://pfstools.sourceforge.net/"
SRC_URI="mirror://sourceforge/pfstools/pfstools/${PV}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug doc gdal imagemagick matlab netpbm octave +openexr raw glut +tiff"

DEPEND="
	gdal? ( >=sci-libs/gdal-1.6.1 )
	imagemagick? ( >=media-gfx/imagemagick-6.5.2.9 )
	netpbm? ( >=media-libs/netpbm-10.46.00 )
	octave? ( >=sci-mathematics/octave-3.0.3 )
	openexr? ( >=media-libs/openexr-1.6.1 )
	raw? ( >=media-gfx/dcraw-8.73 )
	glut? ( virtual/glut )
	tiff? ( >=media-libs/tiff-3.9.1 )
	"

RDEPEND="${DEPEND}"
PDEPEND=">=media-gfx/pfstmo-1.4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-gcc4.4.patch"
}

src_compile() {
	econf \
		--disable-jpeghdr \
		--disable-qt \
		$(use_enable debug) \
		$(use_enable gdal) \
		$(use_enable imagemagick) \
		$(use_enable matlab) \
		$(use_enable netpbm) \
		$(use_enable octave) \
		$(use_enable openexr) \
		$(use_enable glut opengl) \
		$(use_enable tiff) \
		|| die "configure failed"
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS README TODO doc/faq.txt

	if use doc; then
		dodoc doc/pfs_format_spec.pdf
	fi
}
