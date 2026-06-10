[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Cluster
)

$ErrorActionPreference = 'Stop'
$repoRoot = (git rev-parse --show-toplevel).Trim()
$cfgPath  = Join-Path $repoRoot 'cluster-config.yaml'
$outPath  = Join-Path $repoRoot '.mcp.json'

if (-not (Test-Path $cfgPath)) { throw "Missing $cfgPath" }

# Requires the powershell-yaml module: Install-Module powershell-yaml -Scope CurrentUser
$cfg = ConvertFrom-Yaml (Get-Content $cfgPath -Raw)

if ([string]::IsNullOrEmpty($Cluster)) {
    $Cluster = $cfg.defaultCluster
}

$entry = $cfg.clusters | Where-Object { $_.slug -eq $Cluster }
if (-not $entry) {
    Write-Error "Cluster slug '$Cluster' not found."
    $cfg.clusters | ForEach-Object { Write-Host "  $($_.slug)" }
    exit 1
}

$mcp = @{
    mcpServers = @{
        'octo-mcp-sandbox' = @{
            transport = 'http'
            url       = $entry.mcpUrl
            auth = @{
                type      = 'oauth-device-flow'
                issuer    = $entry.idpIssuer
                client_id = $entry.idpClientId
            }
        }
    }
}

$mcp | ConvertTo-Json -Depth 10 | Set-Content -Path $outPath -Encoding utf8
Write-Host "Wrote $outPath for cluster '$Cluster'"
Write-Host "  MCP URL:   $($entry.mcpUrl)"
Write-Host "  IdP:       $($entry.idpIssuer)"
Write-Host "  Client ID: $($entry.idpClientId)"
