updateDelay() {
    if (HideSymbolDelay) {
        SetTimer(timer, 25)
        timer() {
            global
            if (HideSymbolDelay = 0) {
                SetTimer(, 0)
            }
            if (GetKeyState("LButton", "P")) {
                needHide := 0
                isWait := 1
                SetTimer(_timer, -HideSymbolDelay)
                _timer() {
                    isWait := 0
                }
            }
            if (!isWait) {
                if (A_TimeIdleKeyboard >= HideSymbolDelay - delay) {
                    needHide := 1
                    hideSymbol()
                } else {
                    needHide := 0
                }
            }
        }
    }
}

loadCursor(type, change := 0) {
    static lastType := ""
    if (changeCursor) {
        if (type != lastType || change) {
            for v in cursorInfo {
                if (v.%type%) {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%type%, "Ptr"), "Int", v.value)
                }
            }
            lastType := type
        }
    }
}
loadSymbol(type, left, top) {
    global lastType
    static old_top := 0
    static old_left := 0

    if (type = lastType && left = old_left && top = old_top) {
        return
    }

    hideSymbol()
    if (!symbolType || !canShowSymbol) {
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
    if (symbolGui.%type%) {
        symbolGui.%type%.Show(showConfig)
    }

    lastType := type
    old_top := top
    old_left := left
}
hideSymbol(init := 1) {
    for v in ["CN", "EN", "Caps"] {
        try {
            symbolGui.%v%.Hide()
        }
    }
    if (init) {
        global lastType := ""
    }
}
