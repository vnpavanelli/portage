EAPI=5


inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/ospray/tsimd.git"
DESCRIPTION="Fundamental C++ SIMD types for Intel CPUs (sse, avx, avx2, avx512)"
HOMEPAGE="https://github.com/ospray/tsimd"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-util/cmake
"
DEPEND="${RDEPEND}"

src_configure() {
    # general configuration
	local mycmakeargs=(
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}

# kate: replace-tabs off;
