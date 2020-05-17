# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# This is a *very ugly* patch to make a mesa library that will provide opengl to
# application running under x2go, under the /opt/mesa_x2go path

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit llvm meson multilib-minimal python-any-r1

OPENGL_DIR="xorg-x11"

P="mesa-20.1.0_rc3"

MY_P="${P/_/-}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/mesa/mesa.git"
	inherit git-r3
else
	SRC_URI="https://mesa.freedesktop.org/archive/${MY_P}.tar.xz"
	KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
fi

LICENSE="MIT"
SLOT="0"
RESTRICT="
	!test? ( test )
"

RADEON_CARDS=""
VIDEO_CARDS=""
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	+classic debug +gallium +libglvnd +llvm
	lm-sensors opencl osmesa selinux test unwind valgrind 
	+X xa xvmc +zstd"

REQUIRED_USE="
	xa? ( X )
	xvmc? ( X )
"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.100"
RDEPEND="
	!app-eselect/eselect-mesa
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8[${MULTILIB_USEDEP}]
	libglvnd? (
		>=media-libs/libglvnd-1.2.0-r1[X?,${MULTILIB_USEDEP}]
		!app-eselect/eselect-opengl
	)
	!libglvnd? (
		>=app-eselect/eselect-opengl-1.3.0
	)
	gallium? (
		unwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
		lm-sensors? ( sys-apps/lm-sensors:=[${MULTILIB_USEDEP}] )
		opencl? (
					>=virtual/opencl-3[${MULTILIB_USEDEP}]
					dev-libs/libclc
					virtual/libelf:0=[${MULTILIB_USEDEP}]
				)
		xvmc? ( >=x11-libs/libXvMC-1.0.8:=[${MULTILIB_USEDEP}] )
	)
	selinux? ( sys-libs/libselinux[${MULTILIB_USEDEP}] )
	X? (
		>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXdamage-1.1.4-r1:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
		>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
		>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
		x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
	)
	zstd? ( app-arch/zstd:=[${MULTILIB_USEDEP}] )
"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.
#
# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 10.
# 3. Specify LLVM_MAX_SLOT, e.g. 9.
LLVM_MAX_SLOT="10"
LLVM_DEPSTR="
	|| (
		sys-devel/llvm:10[${MULTILIB_USEDEP}]
		sys-devel/llvm:9[${MULTILIB_USEDEP}]
		sys-devel/llvm:8[${MULTILIB_USEDEP}]
	)
	<sys-devel/llvm-$((LLVM_MAX_SLOT + 1)):=[${MULTILIB_USEDEP}]
"
LLVM_DEPSTR_AMDGPU=${LLVM_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
CLANG_DEPSTR=${LLVM_DEPSTR//llvm/clang}
CLANG_DEPSTR_AMDGPU=${CLANG_DEPSTR//]/,llvm_targets_AMDGPU(-)]}
unset {LLVM,CLANG}_DEPSTR{,_AMDGPU}

DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )
	X? (
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
		x11-base/xorg-proto
	)
"
BDEPEND="
	${PYTHON_DEPS}
	opencl? (
		>=sys-devel/gcc-4.6
	)
	sys-devel/bison
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig
	$(python_gen_any_dep ">=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]")
"

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR=${S}

QA_WX_LOAD="
x86? (
	usr/lib*/libglapi.so.0.0.0
	usr/lib*/libGLESv1_CM.so.1.1.0
	usr/lib*/libGLESv2.so.2.0.0
	usr/lib*/libGL.so.1.2.0
	usr/lib*/libOSMesa.so.8.0.0
	libglvnd? ( usr/lib/libGLX_mesa.so.0.0.0 )
)"

llvm_check_deps() {
	local flags=${MULTILIB_USEDEP}
	if use opencl; then
		has_version "sys-devel/clang:${LLVM_SLOT}[${flags}]" || return 1
	fi
	has_version "sys-devel/llvm:${LLVM_SLOT}[${flags}]"
}

pkg_pretend() {
	if use xa; then
		if ! use video_cards_freedreno &&
		   ! use video_cards_nouveau &&
		   ! use video_cards_vmware; then
			ewarn "Ignoring USE=xa         since VIDEO_CARDS does not contain freedreno, nouveau, or vmware"
		fi
	fi

	if use xvmc; then
		if ! use video_cards_r600 &&
		   ! use video_cards_nouveau; then
			ewarn "Ignoring USE=xvmc       since VIDEO_CARDS does not contain r600 or nouveau"
		fi
	fi

	if ! use gallium; then
		use lm-sensors && ewarn "Ignoring USE=lm-sensors since USE does not contain gallium"
		use llvm       && ewarn "Ignoring USE=llvm       since USE does not contain gallium"
		use opencl     && ewarn "Ignoring USE=opencl     since USE does not contain gallium"
		use vaapi      && ewarn "Ignoring USE=vaapi      since USE does not contain gallium"
		use unwind     && ewarn "Ignoring USE=unwind     since USE does not contain gallium"
		use xa         && ewarn "Ignoring USE=xa         since USE does not contain gallium"
		use xvmc       && ewarn "Ignoring USE=xvmc       since USE does not contain gallium"
	fi

	if ! use llvm; then
		use opencl     && ewarn "Ignoring USE=opencl     since USE does not contain llvm"
	fi
}

python_check_deps() {
	has_version -b ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]"
}

pkg_setup() {
	# warning message for bug 459306
	if use llvm && has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use gallium && use llvm; then
		llvm_pkg_setup
	fi
	python-any-r1_pkg_setup
}

multilib_src_configure() {
	local emesonargs=()

	emesonargs+=( -Dplatforms=$(use X && echo "x11,")surfaceless )

	if use gallium; then
		emesonargs+=(
			$(meson_use llvm)
			$(meson_use lm-sensors lmsensors)
			$(meson_use unwind libunwind)
		)
		emesonargs+=(-Dgallium-nine=false)
		emesonargs+=(-Dgallium-va=false)
		emesonargs+=(-Dgallium-vdpau=false)
		emesonargs+=(-Dgallium-xa=false)
		emesonargs+=(-Dgallium-xvmc=false)
		emesonargs+=(-Dosmesa=gallium)
		emesonargs+=(-Dglx=gallium-xlib)
		emesonargs+=(-Ddri3=false)
		emesonargs+=(-Degl=false)
		emesonargs+=(-Dgbm=false)
		emesonargs+=(-Dgles1=false)
		emesonargs+=(-Dgles2=false)
		emesonargs+=(-Ddri-drivers=)
		emesonargs+=(-Dvulkan-drivers=)
		emesonargs+=(-Dgallium-drivers=swrast)

	fi

	driver_list() {
		local drivers="$(sort -u <<< "${1// /$'\n'}")"
		echo "${drivers//$'\n'/,}"
	}

	emesonargs+=(
		$(meson_use test build-tests)
		-Dshared-glapi=true
		$(meson_use selinux)
		$(meson_use zstd)
		-Dvalgrind=$(usex valgrind auto false)
		--buildtype $(usex debug debug plain)
		-Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
	mkdir "${D}/opt"
	mv "${D}/usr" "${D}/opt/mesa_x2go"

}

multilib_src_install_all() {
	einstalldocs
}

multilib_src_test() {
	meson test -v -C "${BUILD_DIR}" -t 100
}

pkg_postinst() {
	if ! use libglvnd; then
		# Switch to the xorg implementation.
		echo
		eselect opengl set --use-old ${OPENGL_DIR}
	fi
}

pkg_preinst() {
	echo "****************************"
	echo " PRE INST RUNNING "
	echo "****************************"
	mkdir "${D}/opt"
	mv "${D}/usr" "${D}/opt/mesa_x2go"
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of DRI drivers to enable
dri_driver_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		DRI_DRIVERS+=("$@")
	fi
}

gallium_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		GALLIUM_DRIVERS+=("$@")
	fi
}

vulkan_enable() {
	if [[ $1 == -- ]] || use $1; then
		shift
		VULKAN_DRIVERS+=("$@")
	fi
}
