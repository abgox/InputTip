updateDelay() {
    if (HideSymbolDelay) {
        SetTimer(timer, 25)
        timer() {
            global
            if (HideSymbolDelay = 0) {
                SetTimer(, 0)
            }
            _delay := HideSymbolDelay < 150 ? 150 : HideSymbolDelay
            if (GetKeyState("LButton", "P")) {
                needHide := 0
                needShow := 1
                isWait := 1
                SetTimer(_timer, -_delay)
                _timer() {
                    global isWait := 0
                }
            }
            if (!isWait) {
                if (A_TimeIdleKeyboard >= _delay - delay) {
                    needHide := 1
                    hideSymbol()
                } else {
                    needHide := 0
                    needShow := 1
                }
            }
        }
    }
}

loadCursor(type) {
    if (changeCursor) {
        for v in cursorInfo {
            if (v.%type%) {
                DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%type%, "Ptr"), "Int", v.value)
            }
        }
    }
}
loadSymbol(type, change) {
    global lastType
    global lastGui

    if (!canShowSymbol) {
        hideSymbol()
        return
    }

    showConfig := "NA "
    if (symbolType = 1) {
        showConfig .= "x" left + pic_offset_x "y" top + pic_offset_y
    } else if (symbolType = 2) {
        showConfig .= "w" symbol_width "h" symbol_height "x" left + offset_x "y" top + offset_y
    } else if (symbolType = 3) {
        showConfig .= "x" left + offset_x "y" top + offset_y
    }

    if (change) {
        for v in ["CN", "EN", "Caps"] {
            if (type != v) {
                if (symbolGui.%v%) {
                    symbolGui.%v%.Hide()
                }
            }
        }
        if (symbolGui.%type%) {
            symbolGui.%type%.Show(showConfig)
        }
        lastGui := symbolGui.%type%
        lastType := type
    } else {
        if (lastGui) {
            lastGui.Show(showConfig)
        }
    }
}
hideSymbol() {
    if (symbolType) {
        for v in ["CN", "EN", "Caps"] {
            if (symbolGui.%v%) {
                symbolGui.%v%.Hide()
            }
        }
    }
}
