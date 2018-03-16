# Copyright 2014 CoreOS, Inc.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
ETYPE="sources"

# -rc releases should be versioned L.M_rcN
# Final releases should be versioned L.M.N, even for N == 0

# Only needed for RCs
K_BASE_VER="4.14"

inherit kernel-2
EXTRAVERSION="-flatcar"
detect_version

DESCRIPTION="Full sources for the CoreOS Linux kernel"
HOMEPAGE="http://www.kernel.org"
if [[ "${PV%%_rc*}" != "${PV}" ]]; then
	SRC_URI="https://git.kernel.org/torvalds/p/v${KV%-coreos}/v${OKV} -> patch-${KV%-coreos}.patch ${KERNEL_BASE_URI}/linux-${OKV}.tar.xz"
	PATCH_DIR="${FILESDIR}/${KV_MAJOR}.${KV_PATCH}"
else
	SRC_URI="${KERNEL_URI}"
	PATCH_DIR="${FILESDIR}/${KV_MAJOR}.${KV_MINOR}"
fi

KEYWORDS="amd64 arm64"
IUSE=""

# XXX: Note we must prefix the patch filenames with "z" to ensure they are
# applied _after_ a potential patch-${KV}.patch file, present when building a
# patchlevel revision.  We mustn't apply our patches first, it fails when the
# local patches overlap with the upstream patch.
UNIPATCH_LIST="
	${PATCH_DIR}/z0001-kbuild-derive-relative-path-for-KBUILD_SRC-from-CURD.patch \
	${PATCH_DIR}/z0002-Add-arm64-coreos-verity-hash.patch \
	${PATCH_DIR}/z0003-tools-objtool-Makefile-Don-t-fail-on-fallthrough-wit.patch \
	${PATCH_DIR}/z0004-xen-netfront-Fix-mismatched-rtnl_unlock.patch \
	${PATCH_DIR}/z0005-xen-netfront-Update-features-after-registering-netde.patch \
	${PATCH_DIR}/z0006-Revert-random-use-a-different-mixing-algorithm-for-a.patch \
	${PATCH_DIR}/z0007-Revert-random-fix-crng_ready-test.patch \
	${PATCH_DIR}/z0008-ext4-fix-false-negatives-and-false-positives-in-ext4.patch \
	${PATCH_DIR}/z0009-ext4-fix-inline-data-updates-with-checksums-enabled.patch \
	${PATCH_DIR}/z0010-ext4-check-for-allocation-block-validity-with-block-.patch \
	${PATCH_DIR}/z0011-ext4-fix-check-to-prevent-initializing-reserved-inod.patch \
	${PATCH_DIR}/z0012-x86-entry-64-Remove-ebx-handling-from-error_entry-ex.patch \
"
