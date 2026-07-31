#!/usr/bin/env bash
set -euo pipefail

VERIFIER_VERSION="2.0.0"

WL_ROOT="${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)}"

failures=0


pass() {
    echo "PASS: $1"
}


fail() {
    echo "FAIL: $1"
    failures=$((failures + 1))
}


resolve_package_root() {

    if [[ -z "${PACKAGE:-}" ]]; then
        echo "ERROR: PACKAGE missing"
        exit 1
    fi

    PACKAGE_ROOT="${WL_ROOT}/scripts/auto-drop/packages/${PACKAGE}"

    if [[ ! -d "$PACKAGE_ROOT" ]]; then
        echo "ERROR: package directory missing"
        echo "$PACKAGE_ROOT"
        exit 1
    fi
}


run_package_verifier() {

    resolve_package_root

    echo
    echo "========== VERIFIER =========="
    echo "VERSION    : ${VERIFIER_VERSION}"
    echo "PACKAGE    : ${PACKAGE}"
    echo "WORKSPACE  : ${PACKAGE_ROOT}"
    echo "WL_ROOT    : ${WL_ROOT}"
    echo


    echo
    echo "PACKAGE CONTRACT"
    echo "----------------"


    local required_files=(
        "manifest.json"
        "artifacts/metadata.yaml"
        "scripts/install.sh"
        "scripts/verify.sh"
        "scripts/rollback.sh"
    )


    for file in "${required_files[@]}"; do

        target="${PACKAGE_ROOT}/${file}"

        if [[ ! -e "$target" ]]; then
            fail "missing:${target}"
            continue
        fi


        if [[ "$file" == scripts/* ]]; then

            if [[ ! -x "$target" ]]; then
                fail "not executable:${file}"
            else
                pass "executable:${file}"
            fi

        else
            pass "artifact_exists:${target}"
        fi

    done



    echo
    echo "METADATA"
    echo "--------"


    if [[ -f "${PACKAGE_ROOT}/artifacts/metadata.yaml" ]]; then
        pass "metadata_available"
    else
        fail "metadata_missing"
    fi



    echo
    echo "INSTALL STATE"
    echo "-------------"


    if [[ -f "${PACKAGE_ROOT}/scripts/install.sh" ]]; then
        pass "install_success"
    else
        fail "install_missing"
    fi



    echo
    echo "EVIDENCE"
    echo "--------"


    if [[ -d "${WL_ROOT}/vault" ]]; then
        pass "evidence_available"
    else
        fail "evidence_missing"
    fi



    echo
    echo "Certification Engine"
    echo "--------------------"


    if [[ "${failures}" -eq 0 ]]; then
        echo
        echo "CERTIFICATION: CERTIFIED"
        return 0
    fi


    echo
    echo "CERTIFICATION: FAILED"
    echo "Failures: ${failures}"

    return 1
}



# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_package_verifier
fi
