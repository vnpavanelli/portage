# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#PYTHON_COMPAT=( python{2_7,3_5,3_6} )
PYTHON_COMPAT=( python{3_6,3_7,3_8} )
WEBAPP_OPTIONAL=yes
WEBAPP_MANUAL_SLOT=yes

# PV="9.0.0.rc1"

inherit flag-o-matic java-pkg-opt-2 python-single-r1 qmake-utils toolchain-funcs cmake-utils virtualx webapp

# Short package version
SPV="$(ver_cut [1-2])"

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="https://www.vtk.org/"
SRC_URI="
	https://www.vtk.org/files/release/${SPV}/VTK-${PV}.tar.gz
	examples? (
		https://www.vtk.org/files/release/${SPV}/VTKData-${PV}.tar.gz
		https://www.vtk.org/files/release/${SPV}/VTKLargeData-${PV}.tar.gz
	)"

#PATCHES=(
#	"${FILESDIR}/QVTKWidget2.patch"
#)
#
LICENSE="BSD LGPL-2"
KEYWORDS="amd64 ~x86 amd64-linux ~x86-linux"
SLOT="0"
IUSE="
	all-modules aqua boost doc examples imaging ffmpeg gdal java json mpi
	mysql odbc offscreen postgres python qt5 rendering tbb theora tk tcl
	video_cards_nvidia views web R +X xdmf2 vtkm opengl x2go"

REQUIRED_USE="
	all-modules? ( python xdmf2 boost )
	java? ( qt5 )
	tcl? ( rendering )
	examples? ( python )
	tk? ( tcl )
	web? ( python )
	^^ ( X aqua offscreen )"

RDEPEND="
	dev-python/mpi4py
	media-libs/glew
	sci-libs/proj
	dev-libs/pugixml
	app-arch/lz4
	dev-libs/expat
	dev-libs/jsoncpp:=
	dev-libs/libxml2:2
	>=media-libs/freetype-2.5.4
	>=media-libs/libharu-2.3.0-r2
	media-libs/libpng:0=
	media-libs/libtheora
	media-libs/mesa
	media-libs/tiff:0
	sci-libs/exodusii
	sci-libs/hdf5:=
	sci-libs/netcdf:0=
	sci-libs/netcdf-cxx:3
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXt
	>=x11-libs/gl2ps-1.4.1
	boost? ( dev-libs/boost:=[mpi?] )
	examples? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
	)
	ffmpeg? ( media-video/ffmpeg )
	gdal? ( sci-libs/gdal )
	java? ( >=virtual/jdk-1.7:* )
	mpi? (
		virtual/mpi[cxx,romio]
		python? ( dev-python/mpi4py )
	)
	mysql? ( virtual/mysql )
	odbc? ( dev-db/unixODBC )
	offscreen? ( media-libs/mesa[osmesa] )
	postgres? ( dev-db/postgresql:= )
	python? (
		${PYTHON_DEPS}
		dev-python/sip
	)
	qt5? (
		dev-qt/designer:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtsql:5
		dev-qt/qtwebkit:5
		dev-qt/qtx11extras:5
		python? ( dev-python/PyQt5 )
	)
	R? ( dev-lang/R )
	tbb? ( dev-cpp/tbb )
	tcl? ( dev-lang/tcl:0= )
	tk? ( dev-lang/tk:0= )
	web? (
		${WEBAPP_DEPEND}
		dev-python/autobahn
		dev-python/constantly
		dev-python/hyperlink
		dev-python/incremental
		dev-python/six
		dev-python/twisted
		dev-python/txaio
		dev-python/zope-interface
	)
	xdmf2? ( sci-libs/xdmf2 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S="${WORKDIR}"/VTK-${PV}

RESTRICT="test"

pkg_setup() {
	use java && java-pkg-opt-2_pkg_setup
	use python && python-single-r1_pkg_setup
	use web && webapp_pkg_setup
}

src_prepare() {

	sed -i 's/vtkJson/Json/g' ${S}/IO/Export/vtkGLTFExporter.cxx
	if use x2go; then
		cp "${FILESDIR}/FindOpenGL.cmake" "${S}/CMake/patches/99"
	fi
	cmake-utils_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"
	# general configuration
	local mycmakeargs=(
		-Wno-dev
		-DVTK_DIR="${S}"
		-DVTK_INSTALL_LIBRARY_DIR=$(get_libdir)
		-DVTK_INSTALL_DOC_DIR="${EPREFIX}/usr/share/doc/${PF}"
		-DVTK_DATA_ROOT="${EPREFIX}/usr/share/${PN}/data"
		-DVTK_CUSTOM_LIBRARY_SUFFIX=""
		-DBUILD_SHARED_LIBS=ON
		-DVTK_BUILD_TESTING=OFF
		-DVTK_MODULE_USE_EXTERNAL_VTK_eigen=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_expat=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_freetype=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_gl2ps=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_glew=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_hdf5=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_jpeg=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_jsoncpp=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_libxml2=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_lz4=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_lzma=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_netcdf=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_ogg=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_png=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_sqlite=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_tiff=ON
		-DVTK_MODULE_USE_EXTERNAL_VTK_utf8=OFF
		-DVTK_MODULE_USE_EXTERNAL_VTK_zlib=ON
# 		-DVTK_USE_SYSTEM_MPI4PY=ON
# 		-DVTK_USE_SYSTEM_AUTOBAHN=ON
# 		# Use bundled gl2ps (bundled version is a patched version of 1.3.9. Post 1.3.9 versions should be compatible)
# 		-DVTK_USE_SYSTEM_GL2PS=OFF
# 		-DVTK_USE_SYSTEM_HDF5=ON
# 		-DVTK_USE_SYSTEM_JPEG=ON
# 		-DVTK_USE_SYSTEM_LIBXML2=ON
# 		-DVTK_USE_SYSTEM_LibXml2=ON
# 		-DVTK_USE_SYSTEM_NETCDF=ON
# 		-DVTK_USE_SYSTEM_OGGTHEORA=ON
# 		-DVTK_USE_SYSTEM_PNG=ON
# 		-DVTK_USE_SYSTEM_TIFF=ON
# 		-DVTK_USE_SYSTEM_TWISTED=ON
# 		-DVTK_USE_SYSTEM_XDMF2=OFF
# 		-DVTK_USE_SYSTEM_XDMF3=OFF
# 		-DVTK_USE_SYSTEM_ZLIB=ON
# 		-DVTK_USE_SYSTEM_ZOPE=ON
# 		-DVTK_USE_SYSTEM_JSONCPP=ON
# 		-DVTK_USE_SYSTEM_LIBRARIES=ON
# 		-DVTK_USE_SYSTEM_LIBPROJ4=ON
		# Use bundled diy2 (no gentoo package / upstream does not provide a Finddiy2.cmake or diy2Config.cmake / diy2-config.cmake)
		-DVTK_USE_SYSTEM_DIY2=OFF
		-DVTK_USE_GL2PS=ON
		-DVTK_USE_LARGE_DATA=ON
		-DVTK_USE_PARALLEL=ON
		-DVTK_EXTRA_COMPILER_WARNINGS=ON
		-DVTK_Group_StandAlone=ON
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_VTK_BUILD_ALL_MODULES_FOR_TESTS=off
		-DVTK_BUILD_ALL_MODULES=$(usex all-modules)
		-DUSE_DOCUMENTATION_HTML_HELP=$(usex doc)
		-DVTK_Group_Imaging=$(usex imaging)
		-DVTK_Group_MPI=$(usex mpi)
		-DVTK_Group_Rendering=$(usex rendering)
		-DVTK_Group_Tk=$(usex tk)
		-DVTK_Group_Views=$(usex views)
		-DVTK_Group_Web=$(usex web)
		-DVTK_WWW_DIR="${ED%/}/${MY_HTDOCSDIR}"
		-DVTK_WRAP_JAVA=$(usex java)
		-DVTK_WRAP_PYTHON=$(usex python)
		-DVTK_WRAP_PYTHON_SIP=$(usex python)
		-DVTK_WRAP_TCL=$(usex tcl)
		-DVTK_USE_BOOST=$(usex boost)
		-DUSE_VTK_USE_BOOST=$(usex boost)
		-DModule_vtkInfovisBoost=$(usex boost)
		-DModule_vtkInfovisBoostGraphAlgorithms=$(usex boost)
		-DVTK_USE_ODBC=$(usex odbc)
		-DModule_vtkIOODBC=$(usex odbc)
		-DVTK_USE_OFFSCREEN=$(usex offscreen)
		-DVTK_OPENGL_HAS_OSMESA=$(usex offscreen)
		-DVTK_USE_OGGTHEORA_ENCODER=$(usex theora)
		-DVTK_USE_NVCONTROL=$(usex video_cards_nvidia)
		-DModule_vtkFiltersStatisticsGnuR=$(usex R)
		-DVTK_USE_X=$(usex X)
	# IO
		-DVTK_USE_FFMPEG_ENCODER=$(usex ffmpeg)
		-DModule_vtkIOGDAL=$(usex gdal)
		-DModule_vtkIOGeoJSON=$(usex json)
		-DModule_vtkIOXdmf2=$(usex xdmf2)
		-DBUILD_TESTING=$(usex examples)
	# Apple stuff, does it really work?
		-DVTK_USE_COCOA=$(usex aqua)
	)

	if use opengl; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2=YES 
		)
	fi

	if use x2go; then
		mycmakeargs+=( 
			-DOpenGL_GL_PREFERENCE=LEGACY
			-DOpenGL_X2GO=true
			-DOpenGL_INCLUDE_DIR=/opt/mesa_x2go/include
			-DOpenGL_LIBRARIES=/opt/mesa_x2go/lib64
			-DCMAKE_MODULE_PATH=${S}/CMake
		)
	fi

	if use rendering; then
		mycmakeargs+=( -DVTK_MODULE_ENABLE_VTK_RenderingRayTracing=YES
		)
	fi

	if use vtkm; then
		mycmakeargs+=( -DModule_vtkAcceleratorsVTKm:BOOL=ON -DModule_vtkVTKm:BOOL=ON )
	fi



	if use java; then
		local javacargs=$(java-pkg_javac-args)
		mycmakeargs+=( -DJAVAC_OPTIONS=${javacargs// /;} )
	fi

	if use tbb; then
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="TBB" )
	else
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="Sequential" )
	fi

	if use python; then
		mycmakeargs+=(
			-DVTK_INSTALL_PYTHON_MODULE_DIR="$(python_get_sitedir)"
			-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
			-DPYTHON_LIBRARY="$(python_get_library_path)"
			-DSIP_PYQT_DIR="${EPREFIX}/usr/share/sip"
			-DSIP_INCLUDE_DIR="$(python_get_includedir)"
			-DVTK_PYTHON_INCLUDE_DIR="$(python_get_includedir)"
			-DVTK_PYTHON_LIBRARY="$(python_get_library_path)"
			-DVTK_PYTHON_SETUP_ARGS:STRING="--prefix=${EPREFIX} --root=${D}"
			-DVTK_USE_SYSTEM_SIX=ON
		)
		if python_is_python3; then
			mycmakeargs+=(
				-DVTK_PYTHON_VERSION="3"
			)
		fi
	fi

	if use qt5; then
		mycmakeargs+=(
			-DVTK_GROUP_ENABLE_Qt=YES
			-DVTK_MODULE_ENABLE_VTK_GUISupportQtOpenGL=YES
			-DVTK_MODULE_ENABLE_VTK_GUISupportQt=YES
			-DVTK_USE_QVTK=ON
			-DVTK_USE_QVTK_OPENGL=ON
			-DVTK_USE_QVTK_QTOPENGL=ON
			-DQT_WRAP_CPP=ON
			-DQT_WRAP_UI=ON
			-DVTK_INSTALL_QT_DIR="$(qt5_get_libdir)/qt5/plugins/designer"
			-DDESIRED_QT_VERSION=5
			-DVTK_QT_VERSION=5
			-DQT_MOC_EXECUTABLE="$(qt5_get_bindir)/moc"
			-DQT_UIC_EXECUTABLE="$(qt5_get_bindir)/uic"
			-DQT_INCLUDE_DIR="${EPREFIX}/usr/include/qt5"
			-DQT_QMAKE_EXECUTABLE="$(qt5_get_bindir)/qmake"
			-DVTK_Group_Qt:BOOL=ON
		)
	fi

	if use R; then
		mycmakeargs+=(
			-DR_LIBRARY_BLAS=/usr/$(get_libdir)/R/lib/libR.so
			-DR_LIBRARY_LAPACK=/usr/$(get_libdir)/R/lib/libR.so
		)
	fi

	append-cppflags -D__STDC_CONSTANT_MACROS -D_UNICODE

	use java && export JAVA_HOME="${EPREFIX}/etc/java-config-2/current-system-vm"

	if use mpi; then
		export CC=mpicc
		export CXX=mpicxx
		export FC=mpif90
		export F90=mpif90
		export F77=mpif77
	fi

	cmake-utils_src_configure
}

src_install() {
	use web && webapp_src_preinst

	cmake-utils_src_install

	use java && java-pkg_regjar "${ED%/}"/usr/$(get_libdir)/${PN}.jar

	# Stop web page images from being compressed
	use doc && docompress -x /usr/share/doc/${PF}/doxygen

	if use tcl; then
		# install Tcl docs
		docinto vtk_tcl
		dodoc Wrapping/Tcl/README
		docinto .
	fi

	# install examples
	if use examples; then
		einfo "Installing examples"
		mv -v {E,e}xamples || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi

	# environment
	cat >> "${T}"/40${PN} <<- EOF || die
		VTK_DATA_ROOT=${EPREFIX}/usr/share/${PN}/data
		VTK_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}-${SPV}
		VTKHOME=${EPREFIX}/usr
		EOF
	doenvd "${T}"/40${PN}

	use web && webapp_src_install
}

# webapp.eclass exports these but we want it optional #534036
pkg_postinst() {
	use web && webapp_pkg_postinst
}

pkg_prerm() {
	use web && webapp_pkg_prerm
}
