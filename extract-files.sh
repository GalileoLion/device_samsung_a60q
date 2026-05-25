#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=a60q
VENDOR=samsung

DEVICE_COMMON=sm6150-common

set -o pipefail

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

LINEAGE_ROOT="${MY_DIR}/../../.."

HELPER="${LINEAGE_ROOT}/tools/extract-utils/extract_utils.sh"
if [[ ! -f "${HELPER}" ]]; then
    echo "Unable to find ${HELPER}"
    exit 1
fi
source "${HELPER}"

function blob_fixup() {
    case "${1}" in
        *)
            return 1
            ;;
    esac
}

if [[ -f "${LINEAGE_ROOT}/device/${VENDOR}/${DEVICE_COMMON}/extract-files.sh" ]]; then
    "${LINEAGE_ROOT}/device/${VENDOR}/${DEVICE_COMMON}/extract-files.sh" --only-common "$@"
fi

setup_vendor "${DEVICE}" "${VENDOR}" "${LINEAGE_ROOT}" false
extract "${MY_DIR}/proprietary-files.txt" "$@"

"${MY_DIR}/setup-makefiles.sh"
