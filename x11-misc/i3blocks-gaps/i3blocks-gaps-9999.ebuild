# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} = 9999 ]]; then
	inherit git-r3
fi

DESCRIPTION="highly flexible status line for the i3 window manager"
HOMEPAGE="https://github.com/vivien/i3blocks"
EGIT_REPO_URI="https://github.com/Airblader/i3blocks-gaps.git"
KEYWORDS="amd64 ~arm64 x86"

SLOT="0"
LICENSE="GPL-3"

RDEPEND="app-admin/sysstat
	media-sound/playerctl
	sys-apps/lm_sensors
	sys-power/acpi
	|| ( x11-wm/i3 x11-wm/i3-gaps )"

DEPEND="app-text/ronn"

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install
}
