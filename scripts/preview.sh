#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
OUT_DIR="${REPO_ROOT}/preview"
COMPILER_PATH="${OCTO_CKC_COMPILER:-${REPO_ROOT}/../octo-construction-kit-engine/src/ConstructionKit.Compiler}"
COMPILED_MODEL="${REPO_ROOT}/src/SandboxCkModel/bin/DebugL/net10.0/octo-ck-libraries/SandboxCkModel/out/ck-sandbox.yaml"

if [[ ! -f "${COMPILED_MODEL}" ]]; then
    echo "Compiled model not found: ${COMPILED_MODEL}"
    echo "Run: dotnet build -c DebugL"
    exit 1
fi

mkdir -p "${OUT_DIR}"

dotnet run --project "${COMPILER_PATH}" -- \
    -c generateDocs \
    -f "${COMPILED_MODEL}" \
    -o "${OUT_DIR}" \
    -l "/" \
    > "${OUT_DIR}/build.log" 2>&1

echo "Preview ready under ${OUT_DIR}/Sandbox/"
echo "Open ${OUT_DIR}/Sandbox/index.md in VS Code → 'Open Preview to the Side' renders the Mermaid classDiagram"
echo "(Types.md / Attributes.md / VersionHistory.md are the detail tables)"
