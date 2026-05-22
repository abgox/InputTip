; InputTip

normalizeConfig(key, value) {
    static isChanging := 0
    if isChanging
        return value

    if InStr(key, "color") {
        if !RegExMatch(value, "i)^0x[0-9a-f]{6}$")
            value := "0xffffff"
        switch value {
            case 'red':
                value := "0xFF0000"
            case 'blue':
                value := "0x0000FF"
            case 'green':
                value := "0x00FF00"
        }
    } else if InStr(key, "size") {
        value := Abs(returnNumber(value))
        if value < 8 || value > 200
            value := 16
    } else if InStr(key, "weight") {
        value := Abs(returnNumber(value))
        value := Round(value / 100) * 100
        if value < 100 || value > 900
            value := 400
    } else if InStr(key, "offset") && !InStr(key, "symbolOffsetBaseY") {
        value := returnNumber(value)
    } else if InStr(key, "transparent") {
        value := Abs(returnNumber(value))
        if value > 255
            value := 255
    } else if InStr(key, "Width") || InStr(key, "Height") {
        value := Abs(returnNumber(value))
        if value < 1
            value := 1
    } else if InStr(key, "HideDelay") || InStr(key, "DetectionTimeout") || key == "updateCheckInterval" {
        value := Abs(returnNumber(value))
        if value < 0
            value := 0
    } else if key == "pollInterval" {
        value := Abs(returnNumber(value))
        if value < 1
            value := 1
        if value > 99
            value := 99
    }
    isChanging := 0
    return value
}

changeConfig(key, value, callback := (key, value) => restartJAB()) {
    if value == "" {
        ; 允许空值的配置
        allowNullVal := InStr(key, "hotkey") || InStr(key, "inputMethodDetectionRule") || InStr(key, "cursorPath") || InStr(key, "symbolPicturePath")
        if !allowNullVal
            return
    }
    oldVal := ""
    try oldVal := var.%key%
    if value == oldVal
        return

    value := normalizeConfig(key, value)

    var.%key% := value
    writeIni(key, value)

    if InStr(key, "cursor") {
        if var.cursorActive {
            updateCursor()
            loadCursor(currentState, 1)
        } else {
            revertCursor()
        }
    } else if InStr(key, "overlay") {
        if var.overlayActive {
            updateOverlay()
            showOverlay(currentState)
        } else {
            hideOverlay()
        }
    } else if InStr(key, "symbol") {
        global lastWindow := ""
        global lastSymbol := ""

        if InStr(key, "symbolPicture") {
            symType := "Picture"
        } else if InStr(key, "symbolText") {
            symType := "Text"
        } else {
            symType := "Shape"
        }

        if var.symbolType {
            updateSymbol()
            if key == "symbolOffsetBaseY" || key == "symbolType" {
                gc.previewSymbol.Focus()
            }

            if InStr(key, "cornerPreference") || InStr(key, "edgeStyle") {
                reloadSymbol()
                try gc.%"previewSymbol" symType%.Focus()
            }

            if InStr(key, "path") || InStr(key, "color") || InStr(key, "font") {
                if (value) {
                    reloadSymbol()
                    try gc.%"previewSymbol" symType%.Focus()
                } else {
                    hideSymbol()
                }
            }
        } else {
            hideSymbol()
        }

        if InStr(key, "HideDelay") {
            updateSymbolDelay()
        }
        if InStr(key, "JAB") {
            if var.symbolJABActive {
                runJAB()
            } else {
                SetTimer(killAppTimer, -1)
                killAppTimer() {
                    try killJAB(1, A_IsCompiled || A_IsAdmin)
                }
            }
        }
    }

    switch key {
        case "pollInterval":
            value += value <= 0
            if (value > 100) {
                value := 100
            }
        case "iconRunning", "iconPaused":
            setTrayIcon(value)
        case "enableCustomTrayTip", "trayTipTemplate", "enableKeyStats", "keyStatsTemplate":
            updateTrayTip()
        default:
    }

    callback(key, value)
}

changeSectionConfig(key, value, section, delete := 0) {
    if delete {
        try IniDelete(configFile, section, key)
    } else {
        writeIni(key, value, section)
    }
    k := StrReplace(section, ".", "")
    var.%k% := StrSplit(readIniSection(section), "`n")
    restartJAB()
}
