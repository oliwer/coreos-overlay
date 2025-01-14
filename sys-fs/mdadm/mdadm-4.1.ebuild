# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Flatcar: Based on mdadm-4.1.ebuild from commit
# 32ddfce1d8ce63479d23d2983fa653ce5eac3ad2 in Gentoo repo (see
# https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-fs/mdadm/mdadm-4.1.ebuild?id=32ddfce1d8ce63479d23d2983fa653ce5eac3ad2).

EAPI=6
inherit flag-o-matic multilib systemd toolchain-funcs udev

DESCRIPTION="Tool for running RAID systems - replacement for the raidtools"
HOMEPAGE="https://git.kernel.org/pub/scm/utils/mdadm/mdadm.git/"
DEB_PF="4.1-3"
SRC_URI="https://www.kernel.org/pub/linux/utils/raid/mdadm/${P/_/-}.tar.xz
		mirror://debian/pool/main/m/mdadm/${PN}_${DEB_PF}.debian.tar.xz"

LICENSE="GPL-2"
SLOT="0"
# Flatcar: Build for arm64 too.
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 sparc x86"
IUSE="static"

DEPEND="virtual/pkgconfig
	app-arch/xz-utils"
RDEPEND=">=sys-apps/util-linux-2.16"

# The tests edit values in /proc and run tests on software raid devices.
# Thus, they shouldn't be run on systems with active software RAID devices.
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/${PN}-3.4-sysmacros.patch #580188
# Flatcar: These patches are already upstreamed, but not released yet.
	"${FILESDIR}"/${PN}-4.1-create-add-support-for-raid0-layouts.patch
	"${FILESDIR}"/${PN}-4.1-assemble-add-support-for-raid0-layouts.patch
)

mdadm_emake() {
	# We should probably make corosync & libdlm into USE flags. #573782
	emake \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		CC="$(tc-getCC)" \
		CWFLAGS="-Wall" \
		CXFLAGS="${CFLAGS}" \
		UDEVDIR="$(get_udevdir)" \
		SYSTEMD_DIR="$(systemd_get_systemunitdir)" \
		COROSYNC="-DNO_COROSYNC" \
		DLM="-DNO_DLM" \
		"$@"
}

src_compile() {
	use static && append-ldflags -static
	mdadm_emake all
}

src_test() {
	mdadm_emake test

	sh ./test || die
}

src_install() {
	mdadm_emake DESTDIR="${D}" install install-systemd
	dodoc ChangeLog INSTALL TODO README* ANNOUNCE-*

	insinto /etc
	newins mdadm.conf-example mdadm.conf
	newinitd "${FILESDIR}"/mdadm.rc mdadm
	newconfd "${FILESDIR}"/mdadm.confd mdadm
	newinitd "${FILESDIR}"/mdraid.rc mdraid
	newconfd "${FILESDIR}"/mdraid.confd mdraid

	# From the Debian patchset
	into /usr
	dodoc "${WORKDIR}"/debian/README.checkarray
	dosbin "${WORKDIR}"/debian/checkarray
	insinto /etc/default
	newins "${FILESDIR}"/etc-default-mdadm mdadm

	systemd_dounit "${FILESDIR}"/mdadm.service
	systemd_dounit "${FILESDIR}"/mdadm.timer

	systemd_enable_service timers.target mdadm.timer
}

pkg_postinst() {
	if ! systemd_is_booted; then
		if [[ -z ${REPLACING_VERSIONS} ]] ; then
			# Only inform people the first time they install.
			elog "If you're not relying on kernel auto-detect of your RAID"
			elog "devices, you need to add 'mdraid' to your 'boot' runlevel:"
			elog "	rc-update add mdraid boot"
		fi
	fi
}
