# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit latex-package

DESCRIPTION="TikZ extension to manage common UML diagrams"
HOMEPAGE="http://perso.ensta-paristech.fr/~kielbasi/tikzuml/"
MY_P="tikzuml-v1.0-2016-03-29"
# SRC_URI="http://perso.ensta-paristech.fr/~kielbasi/${PN}/src/${MY_P}-${PV: -8:4}-${PV: -4:2}-${PV: -2:2}.tbz"
SRC_URI="https://perso.ensta-paristech.fr/~kielbasi/tikzuml/var/files/src/tikzuml-v1.0-2016-03-29.tbz"

LICENSE="tba"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc examples"

S=${WORKDIR}/${MY_P}

src_install() {
	latex-package_src_install
	if use doc; then
		cd "${S}/doc"  || die
		latex-package_src_install
	fi
	if use examples; then
		cd "${S}/examples"  || die
		latex-package_src_install
	fi
}
