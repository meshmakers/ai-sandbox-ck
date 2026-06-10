#!/usr/bin/env bash
set -euo pipefail

# Generates .mcp.json from cluster-config.yaml for the chosen cluster.
# Usage:  ./scripts/init.sh [-c <cluster-slug>]
# Default cluster comes from cluster-config.yaml's defaultCluster field.

REPO_ROOT="$(git rev-parse --show-toplevel)"
CFG="${REPO_ROOT}/cluster-config.yaml"
OUT="${REPO_ROOT}/.mcp.json"

if [[ ! -f "${CFG}" ]]; then
    echo "Missing ${CFG}"
    exit 1
fi

CLUSTER=""
while getopts "c:" opt; do
    case "${opt}" in
        c) CLUSTER="${OPTARG}";;
        *) echo "Usage: $0 [-c <cluster-slug>]"; exit 1;;
    esac
done
if [[ -z "${CLUSTER}" ]]; then
    CLUSTER="$(yq '.defaultCluster' "${CFG}")"
fi

MCP_URL="$(yq ".clusters[] | select(.slug == \"${CLUSTER}\") | .mcpUrl" "${CFG}")"
IDP_ISSUER="$(yq ".clusters[] | select(.slug == \"${CLUSTER}\") | .idpIssuer" "${CFG}")"
IDP_CLIENT="$(yq ".clusters[] | select(.slug == \"${CLUSTER}\") | .idpClientId" "${CFG}")"

if [[ -z "${MCP_URL}" ]]; then
    echo "Cluster slug '${CLUSTER}' not found in ${CFG}"
    echo "Available clusters:"
    yq '.clusters[].slug' "${CFG}" | sed 's/^/  /'
    exit 1
fi

cat > "${OUT}" <<EOF
{
  "mcpServers": {
    "octo-mcp-sandbox": {
      "transport": "http",
      "url": "${MCP_URL}",
      "auth": {
        "type": "oauth-device-flow",
        "issuer": "${IDP_ISSUER}",
        "client_id": "${IDP_CLIENT}"
      }
    }
  }
}
EOF

echo "Wrote ${OUT} for cluster '${CLUSTER}'"
echo "  MCP URL:   ${MCP_URL}"
echo "  IdP:       ${IDP_ISSUER}"
echo "  Client ID: ${IDP_CLIENT}"
echo
echo "Next: run 'claude' and inside the session try 'get_available_types'."
