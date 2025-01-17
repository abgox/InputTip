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
        if (!symbolType || needHide || isMouseOver("ahk_class Shell_TrayWnd") || !isMouseOver("ahk_exe " lastWindow)) {
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
                    ShowSymbolEx("CN")
                }
            } else if (InStr(app_EN, exe_str)) {
                switch_EN()
                if (!isCN()) {
                    loadCursor("EN", 1)
                    ShowSymbolEx("EN")
                }
            } else if (InStr(app_Caps, exe_str)) {
                switch_Caps()
                if (GetKeyState("CapsLock", "T")) {
                    loadCursor("Caps", 1)
                    ShowSymbolEx("Caps")
                }
            }
        }
        if (GetKeyState("CapsLock", "T")) {
            loadCursor("Caps")
            ShowSymbolEx("Caps")
            continue
        }
        try {
            v := isCN() ? "CN" : "EN"
        } catch {
            hideSymbol()
            continue
        }
        loadCursor(v)
        ShowSymbolEx(v)
    }
}

ShowSymbolEx(state) {
    global canShowSymbol
    if (needShow) {
        if (showCursorPos || InStr(showCursorPosList, exe_str)) {
            try {
                MouseGetPos(&left, &top)
                canShowSymbol := 1
                loadSymbol(state, left, top, 1)
            } catch {
                hideSymbol()
            }
            return
        }
        try {
            canShowSymbol := returnCanShowSymbol(&left, &top)
            loadSymbol(state, left, top)
        } catch {
            hideSymbol()
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
