updateDelay()

; 鼠标悬浮在符号上
isOverSymbol := 0
while 1 {
    Sleep(delay)
    ; 正在使用鼠标或有键盘操作
    if (A_TimeIdle < leaveDelay) {
        needShow := 1
        if (symbolType) {
            if (isMouseOver("abgox-InputTip-Symbol-Window")) {
                hideSymbol()
                isOverSymbol := 1
                continue
            }
        }
        try {
            exe_name := ProcessGetName(WinGetPID("A"))
            exe_str := ":" exe_name ":"
        } catch {
            hideSymbol()
            needShow := 0
        }
        if (symbolType) {
            if (needSkip(exe_str)) {
                hideSymbol()
                lastSymbol := ""
                lastCursor := ""
                lastWindow := ""
                continue
            }
            if (useWhiteList) {
                if (!InStr(app_show_state, exe_str) && !WinActive("ahk_class AutoHotkeyGUI")) {
                    hideSymbol()
                    needShow := 0
                }
            } else {
                if (InStr(app_hide_state, exe_str)) {
                    hideSymbol()
                    needShow := 0
                }
            }
        }
        if (!symbolType || needHide || isMouseOver("ahk_class Shell_TrayWnd")) {
            hideSymbol()
            needShow := 0
        }
        if (exe_name != lastWindow) {
            WinWaitActive("ahk_exe " exe_name)
            lastSymbol := ""
            lastCursor := ""
            lastWindow := exe_name
            if (InStr(app_CN, exe_str)) {
                switch_CN()
                if (isCN()) {
                    loadCursor("CN", 1)
                    if (needShow) {
                        canShowSymbol := returnCanShowSymbol(&left, &top)
                        loadSymbol("CN", left, top)
                    }
                }
            } else if (InStr(app_EN, exe_str)) {
                switch_EN()
                if (!isCN()) {
                    loadCursor("EN", 1)
                    if (needShow) {
                        canShowSymbol := returnCanShowSymbol(&left, &top)
                        loadSymbol("EN", left, top)
                    }
                }
            } else if (InStr(app_Caps, exe_str)) {
                switch_Caps()
                if (GetKeyState("CapsLock", "T")) {
                    loadCursor("Caps", 1)
                    if (needShow) {
                        canShowSymbol := returnCanShowSymbol(&left, &top)
                        loadSymbol("Caps", left, top)
                    }
                }
            }
        }
        if (GetKeyState("CapsLock", "T")) {
            loadCursor("Caps")
            if (needShow) {
                canShowSymbol := returnCanShowSymbol(&left, &top)
                loadSymbol("Caps", left, top)
            }
            continue
        }
        try {
            v := isCN() ? "CN" : "EN"
        } catch {
            hideSymbol()
            continue
        }
        loadCursor(v)
        if (needShow) {
            canShowSymbol := returnCanShowSymbol(&left, &top)
            loadSymbol(v, left, top)
        }
    }
}

updateDelay() {
    if (HideSymbolDelay) {
        SetTimer(updateDelayTimer, 25)
        updateDelayTimer() {
            global needHide, isWait
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
            if (HideSymbolDelay = 0) {
                SetTimer(updateDelayTimer, 0)
                needHide := 0
                isWait := 0
            }
        }
    }
}
loadCursor(state, change := 0) {
    global lastCursor
    if (changeCursor) {
        if (state != lastCursor || change) {
            for v in cursorInfo {
                if (v.%state%) {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%state%, "Ptr"), "Int", v.value)
                }
            }
            lastCursor := state
        }
    }
}
loadSymbol(state, left, top) {
    global lastSymbol, isOverSymbol
    static old_left := 0, old_top := 0
    if (left = old_left && top = old_top) {
        if (state = lastSymbol || (isOverSymbol && A_TimeIdleKeyboard > leaveDelay)) {
            return
        }
    } else {
        isOverSymbol := 0
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
        showConfig .= "x" left + charSymbol_offset_x "y" top + charSymbol_offset_y
    }
    if (symbolInfo.%"gui_" state%) {
        symbolInfo.%"gui_" state%.Show(showConfig)
    }

    lastSymbol := state
    old_top := top
    old_left := left
}
hideSymbol() {
    for state in ["CN", "EN", "Caps"] {
        try {
            symbolInfo.%"gui_" state%.Hide()
        }
    }
    global lastSymbol := ""
}
