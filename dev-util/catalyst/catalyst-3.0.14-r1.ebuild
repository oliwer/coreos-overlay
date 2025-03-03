# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Flatcar: Based on catalyst-3.0.14.ebuild from commit
# 78fc35f2e766117caa26928db5a0a09b8af18c3c in Gentoo repo (see
# https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-util/catalyst/catalyst-3.0.14.ebuild?id=78fc35f2e766117caa26928db5a0a09b8af18c3c).

EAPI=6

if [[ ${PV} == *9999* ]]; then
	SRC_ECLASS="git-r3"
	EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/catalyst.git"
	EGIT_BRANCH="master"
else
	SRC_URI="https://gitweb.gentoo.org/proj/catalyst.git/snapshot/${P}.tar.bz2"
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv s390 sparc x86"
fi

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_USE_SETUPTOOLS=no

inherit distutils-r1 ${SRC_ECLASS}

DESCRIPTION="Release metatool used for creating releases based on Gentoo Linux"
HOMEPAGE="https://wiki.gentoo.org/wiki/Catalyst"

LICENSE="GPL-2+"
SLOT="0"
IUSE="ccache doc +iso kernel_linux system-bootloader"

DEPEND="
	app-text/asciidoc
	>=dev-python/snakeoil-0.6.5[${PYTHON_USEDEP}]
"
RDEPEND="
	>=dev-python/snakeoil-0.6.5[${PYTHON_USEDEP}]
	>=dev-python/pydecomp-0.3[${PYTHON_USEDEP}]
	app-arch/lbzip2
	app-crypt/shash
	sys-fs/dosfstools
	!kernel_FreeBSD? ( || ( app-arch/tar[xattr] app-arch/libarchive[xattr] ) )
	kernel_FreeBSD? ( app-arch/libarchive[xattr] )
	amd64? ( >=sys-boot/syslinux-3.72 )
	x86? ( >=sys-boot/syslinux-3.72 )
	ccache? ( dev-util/ccache )
	iso? ( virtual/cdrtools )
	kernel_linux? ( app-misc/zisofs-tools >=sys-fs/squashfs-tools-2.1 )
"
PDEPEND="system-bootloader? ( >=sys-apps/memtest86+-5.01-r4
				sys-boot/grub:2
				amd64? ( sys-boot/grub[grub_platforms_efi-32,grub_platforms_efi-64] )
				x86? ( sys-boot/grub[grub_platforms_efi-32] )
				sys-boot/syslinux
				sys-boot/shim )"

PATCHES=(
	"${FILESDIR}/0001-catalyst-Remove-left-over-Id.patch"
	"${FILESDIR}/0002-catalyst-Remove-Maintained-by-sections.patch"
	"${FILESDIR}/0003-catalyst-Remove-unnecessary-future-imports.patch"
	"${FILESDIR}/0004-catalyst-Use-python3-shebangs.patch"
	"${FILESDIR}/0005-chroot-funcs-use-python3-for-debug-output.patch"
)

python_prepare_all() {
	python_setup
	echo VERSION="${PV}" "${PYTHON}" setup.py set_version
	VERSION="${PV}" "${PYTHON}" setup.py set_version || die
	distutils-r1_python_prepare_all
}

python_compile_all() {
	# build the man pages and docs
	emake
}

python_install_all() {
	distutils-r1_python_install_all
	if use doc; then
		dodoc files/HOWTO.html files/docbook-xsl.css
	fi
}
