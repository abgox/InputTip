param(
    # 未处理的鼠标样式目录
    $dir,
    # 处理后的鼠标样式目录
    $out = "out"
)

$cursorNameMap = @{
    AppStarting = @("Work")
    Arrow       = @("Pointer")
    Cross       = @("")
    Hand        = @("Link")
    Help        = @("")
    IBeam       = @("Text")
    No          = @("Unavailable")
    Pen         = @("Handwriting")
    Person      = @("")
    Pin         = @("")
    SizeAll     = @("Move")
    SizeNESW    = @("Dgn2")
    SizeNS      = @("Vert")
    SizeNWSE    = @("Dgn1")
    SizeWE      = @("Horz")
    UpArrow     = @("Alternate")
    Wait        = @("Busy")
}

# 输出目录
$out_dir = Join-Path $dir $out
New-Item -ItemType Directory $out_dir -Force

Get-ChildItem $dir -Recurse -File | ForEach-Object {
    foreach ($style in $cursorNameMap.Keys) {
        if ($_.BaseName -eq $style -or $_.BaseName -in $cursorNameMap.$style) {
            Move-Item $_ (Join-Path $out_dir "$($style)$($_.Extension)") -Force
            Continue
        }
    }
}








