; InputTip

normalizeConfig(key, value) {
    if InStr(key, "color") {
        if value != "" && !RegExMatch(value, "i)^0x[0-9a-f]{6}$")
            value := "0xFFFFFF"
    } else if InStr(key, "size") {
        value := Abs(returnNumber(value))
        if value < 8 || value > 200
            value := 16
    } else if InStr(key, "weight") {
        value := Abs(returnNumber(value))
        value := Round(value / 100) * 100
        if value < 100 || value > 900
            value := 400
    } else if InStr(key, "offset") && !InStr(key, "SymbolScreenOffset") {
        value := returnNumber(value)
    } else if InStr(key, "transparent") {
        value := Abs(returnNumber(value))
        if value > 255
            value := 255
    } else if InStr(key, "Width") || InStr(key, "Height") {
        value := Abs(returnNumber(value))
        if value < 1
            value := 1
    } else if InStr(key, "HideDelay") || InStr(key, "DetectionTimeout") {
        value := Abs(returnNumber(value))
        if value < 0
            value := 0
    } else if key == "pollInterval" {
        value := Abs(returnNumber(value))
        value += value <= 0
        if value > 100
            value := 100
    }
    return value
}

changeConfig(key, value, debounce := 0, callback := (key, value, *) => restartJAB()) {
    if value == "" {
        ; 允许空值的配置
        allowNullVal := InStr(key, "inputMethodDetectionRule") || InStr(key, "cursorPath") || InStr(key, "SymbolPicturePath") || InStr(key, "overlayText") || InStr(key, "color") || InStr(key, "SymbolText")
        if !allowNullVal
            return
    }
    oldVal := ""
    try oldVal := var.%key%
    if value == oldVal
        return

    if key == "language"
        writeIni(key, value), restartApp()

    if key == "menuFontSize" {
        writeIni(key, value)
        var.menuFontSize := Number(value)
        fontOpt[1] := "s" value
        updateUIC()
        return
    }

    value := normalizeConfig(key, value)

    var.%key% := value
    if (debounce) {
        writeIniDebounced(key, value, callback.Bind(key, value))
    } else {
        writeIni(key, value)
        try callback(key, value)
    }

    if key == "cursorActive" || InStr(key, "cursorPath") {
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
        global lastCaretSymbol := "", lastCursorSymbol := ""

        if InStr(key, "symbolPicture") {
            symType := "Picture"
        } else if InStr(key, "symbolText") {
            symType := "Text"
        } else {
            symType := "Shape"
        }

        isCaret := InStr(key, "caret")
        if var.caretSymbolType || var.cursorSymbolType {
            isCaret ? updateSymbol("caret") : updateSymbol("cursor")

            if InStr(key, "cornerPreference") || InStr(key, "edgeStyle") {
                isCaret ? reloadCaretSymbol() : reloadCursorSymbol()
            }

            if InStr(key, "path") || InStr(key, "color") || InStr(key, "font") {
                if (value) {
                    isCaret ? reloadCaretSymbol() : reloadCursorSymbol()
                } else {
                    isCaret ? hideCaretSymbol() : hideCursorSymbol()
                }
            }
        } else {
            isCaret ? hideCaretSymbol() : hideCursorSymbol()
        }

        if InStr(key, "HideDelay") {
            updateSymbolDelay()
            updateCursorDelay()
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
        case "iconRunning", "iconPaused":
            setTrayIcon(value)
        case "enableCustomTrayTip", "trayTipTemplate", "enableKeyStats", "keyStatsTemplate":
            SetTimer(updateTrayTip, -1000)
    }
}
