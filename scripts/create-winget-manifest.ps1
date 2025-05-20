param(
  $outPath = "winget-manifest"
)

$template_yaml = '# yaml-language-server: $schema=https://aka.ms/winget-manifest.version.1.9.0.schema.json

PackageIdentifier: abgox.InputTip
PackageVersion: {{ version }}
DefaultLocale: zh-CN
ManifestType: version
ManifestVersion: 1.9.0
'

$template_installer_yaml = '# yaml-language-server: $schema=https://aka.ms/winget-manifest.installer.1.9.0.schema.json

PackageIdentifier: abgox.InputTip
PackageVersion: {{ version }}
UpgradeBehavior: uninstallPrevious
ReleaseDate: {{ release_date }}
Installers:
  # From GitHub repository
  - Architecture: x64
    InstallerType: portable
    InstallerUrl: https://github.com/abgox/InputTip/releases/download/v{{ version }}/InputTip.exe
    InstallerSha256: {{ sha256 }}
  # From Gitee repository
  - Architecture: x64
    InstallerLocale: zh-CN
    InstallerType: portable
    InstallerUrl: https://gitee.com/abgox/InputTip/releases/download/v{{ version }}/InputTip.exe
    InstallerSha256: {{ sha256 }}
ManifestType: installer
ManifestVersion: 1.9.0
'

$template_locale_en_yaml = '# yaml-language-server: $schema=https://aka.ms/winget-manifest.locale.1.9.0.schema.json

PackageIdentifier: abgox.InputTip
PackageVersion: {{ version }}
PackageLocale: en-US
Publisher: abgox
PublisherUrl: https://github.com/abgox
PublisherSupportUrl: https://github.com/abgox/InputTip/issues
Author: abgox
PackageName: InputTip
PackageUrl: https://inputtip.abgox.com/
License: MIT License
LicenseUrl: https://github.com/abgox/InputTip/blob/main/LICENSE
Copyright: Copyright (c) 2023-present abgox
CopyrightUrl: https://github.com/abgox/InputTip/blob/main/LICENSE
ShortDescription: An input method status tip tool.
Tags:
  - autohotkey
  - cursor
  - ime
  - input
  - inputmethod
  - tip
ReleaseNotesUrl: https://github.com/abgox/InputTip/releases/tag/v{{ version }}
Documentations:
  - DocumentLabel: README (GitHub)
    DocumentUrl: https://github.com/abgox/InputTip/blob/main/README.md
  - DocumentLabel: README (Gitee)
    DocumentUrl: https://gitee.com/abgox/InputTip/blob/main/README.md
  - DocumentLabel: Some Frequently Asked Questions & Tips (FAQ)
    DocumentUrl: https://inputtip.abgox.com/FAQ/
  - DocumentLabel: README
    DocumentUrl: https://inputtip.abgox.com/v2/
ManifestType: locale
ManifestVersion: 1.9.0
'


$template_locale_zh_yaml = '# yaml-language-server: $schema=https://aka.ms/winget-manifest.defaultLocale.1.9.0.schema.json

PackageIdentifier: abgox.InputTip
PackageVersion: {{ version }}
PackageLocale: zh-CN
Publisher: abgox
PublisherUrl: https://gitee.com/abgox
PublisherSupportUrl: https://pd.qq.com/s/gyers18g6?businessType=5
Author: abgox
PackageName: InputTip
PackageUrl: https://inputtip.abgox.com/
License: MIT License
LicenseUrl: https://gitee.com/abgox/InputTip/blob/main/LICENSE
Copyright: Copyright (c) 2023-present abgox
CopyrightUrl: https://gitee.com/abgox/InputTip/blob/main/LICENSE
ShortDescription: 一个输入法状态实时提示工具。
Tags:
  - autohotkey
  - 光标
  - 鼠标
  - 鼠标指针
  - 输入
  - 输入法
  - 状态
  - 提示
  - 实时
  - 工具
ReleaseNotesUrl: https://gitee.com/abgox/InputTip/releases/tag/v{{ version }}
Documentations:
  - DocumentLabel: README (GitHub)
    DocumentUrl: https://github.com/abgox/InputTip/blob/main/README.md
  - DocumentLabel: README (Gitee)
    DocumentUrl: https://gitee.com/abgox/InputTip/blob/main/README.md
  - DocumentLabel: 一些常见问题及使用技巧 (FAQ)
    DocumentUrl: https://inputtip.abgox.com/FAQ/
  - DocumentLabel: README
    DocumentUrl: https://inputtip.abgox.com/v2/
ManifestType: defaultLocale
ManifestVersion: 1.9.0
'

$version = (Invoke-RestMethod -uri "https://raw.githubusercontent.com/abgox/InputTip/refs/heads/main/src/version.txt").Trim()

function replaceContent($content, [System.Collections.Generic.List[array]]$replaceList) {
  foreach ($replace in $replaceList) {
    $content = $content -replace $replace[0], $replace[1]
  }
  return $content
}

Invoke-WebRequest -uri "https://github.com/abgox/InputTip/releases/download/v$version/InputTip.exe" -OutFile "abgox.InputTip.exe"

$sha256 = Get-FileHash "abgox.InputTip.exe"

Remove-Item "abgox.InputTip.exe" -ErrorAction SilentlyContinue

$replaceMap = @(
  @("{{ version }}", $version),
  @("{{ release_date }}", (Get-Date -Format "yyyy-MM-dd")),
  @("{{ sha256 }}", $sha256.Hash)
)

$tempate = @(
  @{
    fileName = "abgox.InputTip.yaml"
    content  = replaceContent $template_yaml $replaceMap
  },
  @{
    fileName = "abgox.InputTip.installer.yaml"
    content  = replaceContent $template_installer_yaml $replaceMap
  },
  @{
    fileName = "abgox.InputTip.locale.en-US.yaml"
    content  = replaceContent $template_locale_en_yaml $replaceMap
  },
  @{
    fileName = "abgox.InputTip.locale.zh-CN.yaml"
    content  = replaceContent $template_locale_zh_yaml $replaceMap
  }
)

$out = Join-Path $outPath $version
New-Item -ItemType Directory -Force -Path $out | Out-Null
foreach ($item in $tempate) {
  $filePath = Join-Path $out $item.fileName
  $item.content | Out-File $filePath -Force -Encoding utf8
}

# $envList = @{
#   new_branch = "abgox.InputTip-$version"
#   commit_msg = "New version: abgox.InputTip version $version"
#   pr_title   = "New version: abgox.InputTip version $version"
#   pr_body    = "Pull Request created by the publish action of [InputTip](https://github.com/abgox/InputTip)."
# }

# $envList | ConvertTo-Json | Out-File "$PSScriptRoot\..\out-winget-env.json"
