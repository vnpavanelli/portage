EAPI=5


inherit cmake-utils git-r3

EGIT_REPO_URI="https://github.com/google/benchmark.git"
DESCRIPTION="Google Benchmark Library"
HOMEPAGE="https://github.com/google/benchmark"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-util/cmake
	dev-cpp/gtest
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
