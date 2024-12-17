dirList := ["InputTipSymbol", "InputTipSymbol\default"]

for d in dirList {
    if (!DirExist(d)) {
        DirCreate(d)
    }
}

if (!FileExist("InputTipSymbol\default\CN.png")) {
    FileInstall("InputTipSymbol\default\CN.png", "InputTipSymbol\default\CN.png", 1)
}
if (!FileExist("InputTipSymbol\default\EN.png")) {
    FileInstall("InputTipSymbol\default\EN.png", "InputTipSymbol\default\EN.png", 1)
}
if (!FileExist("InputTipSymbol\default\Caps.png")) {
    FileInstall("InputTipSymbol\default\Caps.png", "InputTipSymbol\default\Caps.png", 1)
}
if (!FileExist("InputTipSymbol\default\offer.png")) {
    FileInstall("InputTipSymbol\default\offer.png", "InputTipSymbol\default\offer.png", 1)
}
