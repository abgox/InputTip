$content = Invoke-RestMethod -Uri 'https://api.github.com/repos/abgox/InputTip/releases/latest'
$version = $content.tag_name -replace 'v', ''
$digest = $content.assets | Where-Object { $_.name -eq 'InputTip.exe' } | Select-Object -ExpandProperty digest
$sha256 = $digest -replace 'sha256:', ''

if (-not $version -or -not $sha256) {
  Write-Error 'version or sha256 is empty'
  return
}

$outDir = Join-Path 'manifests\a\abgox\InputTip' $version
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$replaceMap = @(
  @('$version', $version),
  @('$release_date', (Get-Date).ToUniversalTime().AddHours(8).ToString('yyyy-MM-dd')),
  @('$sha256', $sha256)
)

Get-ChildItem -Path "$PSScriptRoot\template\winget-manifest" -File | ForEach-Object {
  $content = Get-Content -Path $_.FullName -Raw
  foreach ($replace in $replaceMap) {
    $content = $content.Replace($replace[0], $replace[1])
  }
  $filePath = Join-Path $outDir $_.Name
  $content | Out-File $filePath -Force -Encoding utf8
}

@{
  new_branch = "abgox.InputTip-$version"
  commit_msg = "New version: abgox.InputTip version $version"
  pr_title   = "New version: abgox.InputTip version $version"
  pr_body    = 'Pull Request created by the publish action of [InputTip](https://github.com/abgox/InputTip).'
}
