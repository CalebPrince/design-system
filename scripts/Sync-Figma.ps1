<#!
.SYNOPSIS
Downloads a Figma node's JSON document and optional PNG export.

.DESCRIPTION
Reads sources from figma/sources.json and uses FIGMA_ACCESS_TOKEN from the
current environment. When -LoadEnv is supplied, it also loads a local .env
file. The token is never written to disk by this script.
#>
[CmdletBinding()]
param(
    [string]$Source = 'landing-pages-51-55',
    [switch]$LoadEnv,
    [switch]$SkipExport
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

if ($LoadEnv) {
    $envPath = Join-Path $repoRoot '.env'
    if (-not (Test-Path -LiteralPath $envPath)) {
        throw "No .env file found. Copy .env.example to .env, add FIGMA_ACCESS_TOKEN, then retry."
    }

    Get-Content -LiteralPath $envPath | ForEach-Object {
        if ($_ -match '^\s*FIGMA_ACCESS_TOKEN\s*=\s*(.+?)\s*$') {
            $env:FIGMA_ACCESS_TOKEN = $Matches[1].Trim('"').Trim("'")
        }
    }
}

if ([string]::IsNullOrWhiteSpace($env:FIGMA_ACCESS_TOKEN) -or $env:FIGMA_ACCESS_TOKEN -eq 'replace-with-your-figma-token') {
    throw 'FIGMA_ACCESS_TOKEN is not configured. Set it in your shell or a local .env file.'
}

$sourcesPath = Join-Path $repoRoot 'figma/sources.json'
$sourceConfig = Get-Content -Raw -LiteralPath $sourcesPath | ConvertFrom-Json
$target = @($sourceConfig.sources | Where-Object { $_.name -eq $Source })
if ($target.Count -ne 1) {
    $names = ($sourceConfig.sources.name -join ', ')
    throw "Unknown source '$Source'. Available sources: $names"
}

$headers = @{ 'X-Figma-Token' = $env:FIGMA_ACCESS_TOKEN }
$nodeId = [uri]::EscapeDataString($target.nodeId)
$fileKey = $target.fileKey
$nodeEndpoint = "https://api.figma.com/v1/files/$fileKey/nodes?ids=$nodeId"

Write-Host "Fetching node $($target.nodeId) from Figma..."
$nodeResponse = Invoke-RestMethod -Uri $nodeEndpoint -Headers $headers -Method Get

$snapshotPath = Join-Path $repoRoot $target.snapshotPath
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $snapshotPath) | Out-Null
$nodeResponse | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $snapshotPath -Encoding utf8
Write-Host "Saved node snapshot: $($target.snapshotPath)"

if (-not $SkipExport -and $target.export -ne $false) {
    # Wrap fileKey because PowerShell otherwise treats the following `?` as
    # part of the variable name and drops the file key from the request.
    $imageEndpoint = "https://api.figma.com/v1/images/$($fileKey)?ids=$nodeId&format=png&scale=1"
    $imageResponse = Invoke-RestMethod -Uri $imageEndpoint -Headers $headers -Method Get
    $exportUrl = $imageResponse.images.PSObject.Properties[$target.nodeId].Value
    if ([string]::IsNullOrWhiteSpace($exportUrl)) {
        Write-Warning "Figma did not return an export URL for node $($target.nodeId). The snapshot was saved; select an exportable FRAME or COMPONENT node to create a PNG."
        return
    }

    $exportPath = Join-Path $repoRoot $target.exportPath
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $exportPath) | Out-Null
    Invoke-WebRequest -Uri $exportUrl -OutFile $exportPath
    Write-Host "Saved PNG export: $($target.exportPath)"
}
elseif ($target.export -eq $false) {
    Write-Host "PNG export skipped: node $($target.nodeId) is configured as a library/container source."
}
