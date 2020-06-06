EAPI=5

EGIT_REPO_URI="http://itk.org/ITK.git" 
SRC_URI="https://github.com/InsightSoftwareConsortium/ITK/releases/download/v5.0.1/InsightToolkit-5.0.1.tar.gz"

inherit cmake-utils

DESCRIPTION="ITK GIT" 
HOMEPAGE="https://itk.org" 

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="itkvtkglue gcc-8"

RDEPEND="
	dev-util/cmake
	media-libs/openjpeg
	>=dev-cpp/eigen-3.3.0
	dev-libs/expat
	media-libs/libpng
	media-libs/tiff
	sys-libs/zlib
	sci-libs/hdf5
	itkvtkglue? ( sci-libs/vtk )
"
DEPEND="${RDEPEND}"

src_configure() {
    # general configuration
	local mycmakeargs=(
		-DBUILD_TESTING=OFF
		-DITK_USE_SYSTEM_JPEG=ON
		-DITK_USE_SYSTEM_EIGEN=ON
		-DITK_USE_SYSTEM_EXPAT=ON
		-DITK_USE_SYSTEM_PNG=ON
		-DITK_USE_SYSTEM_TIFF=ON
		-DITK_USE_SYSTEM_ZLIB=ON
		-DITK_USE_SYSTEM_HDF5=ON
	)
	if use itkvtkglue; then
		mycmakeargs+=( -DModule_ITKVtkGlue=ON )
	fi
	if use gcc-8; then
		mycmakeargs+=( -DCMAKE_CXX_COMPILER=g++-8 )
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	echo " ************ Searching for libopenjp2.pc files: *******"
	find ${D} -name libopenjp2.pc -print
	echo " ************ Deleting libopenjp2.pc files" 
	find ${D} -name libopenjp2.pc -delete
	echo " ************ Seaching again: ************" 
	find ${D} -name libopenjp2.pc -print
	echo " ************ Done **********"
}

# kate: replace-tabs off;
