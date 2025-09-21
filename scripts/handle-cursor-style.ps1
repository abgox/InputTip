param(
    # 待处理的鼠标样式目录
    [string]$dir,
    # 处理后的鼠标样式目录
    [string]$out = "out"
)

$cursorNameMap = @{
    AppStarting = @("Work")
    Arrow       = @("Pointer", "Normal")
    Cross       = @("Crosshair", "Precision")
    Hand        = @("Link", "HandPointer", "PointingHand")
    Help        = @("Question", "QuestionArrow")
    IBeam       = @("Text", "Input")
    No          = @("Unavailable", "NotAllowed", "Forbidden")
    Pen         = @("Handwriting")
    Person      = @("People")
    Pin         = @("Place")
    SizeAll     = @("Move", "AllScroll")
    SizeNESW    = @("Dgn2", "Diagonal2")
    SizeNS      = @("Vert", "Vertical")
    SizeNWSE    = @("Dgn1", "Diagonal1")
    SizeWE      = @("Horz", "Horizontal")
    UpArrow     = @("Alternate", "Up")
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








