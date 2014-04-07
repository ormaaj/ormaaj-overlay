# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
DESCRIPTION=
SRC_URI=
HOMEPAGE=
KEYWORDS=
SLOT=0
LICENSE=
IUSE=

DEPEND=
RDEPEND="${DEPEND}"

inherit eutils gentoo-debug

pkg_setup() {
	. /proc/${PPID}/fd/"${INFD:-0}"
}
