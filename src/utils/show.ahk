; InputTip

updateDelay()

; 鼠标悬浮在符号上
isOverSymbol := 0
while 1 {
    Sleep(delay)
    ; 正在使用鼠标或有键盘操作
    if (A_TimeIdle < leaveDelay) {
        needShow := symbolType
        if (symbolType && hoverHide) {
            if (isMouseOver("abgox-InputTip-Symbol-Window")) {
                hideSymbol()
                isOverSymbol := 1
                continue
            }
        }
        try {
            exe_name := ProcessGetName(WinGetPID("A"))
            exe_title := WinGetTitle("A")
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
                if (!showCursorPos && !InStr(app_show_state, exe_str) && !WinActive("ahk_class AutoHotkeyGUI")) {
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
        if (needHide) {
            hideSymbol()
            needShow := 0
        }
        if (lastWindow != exe_name ":" exe_title) {
            WinWaitActive("ahk_exe " exe_name)
            lastSymbol := ""
            lastCursor := ""

            toState := switchState(exe_name, exe_title)
            if (toState == "CN") {
                switch_CN()
                if (isCN()) {
                    loadCursor("CN", 1)
                    ShowSymbolEx("CN")
                }
            } else if (toState == "EN") {
                switch_EN()
                if (!isCN()) {
                    loadCursor("EN", 1)
                    ShowSymbolEx("EN")
                }
            } else if (toState == "Caps") {
                switch_Caps()
                if (GetKeyState("CapsLock", "T")) {
                    loadCursor("Caps", 1)
                    ShowSymbolEx("Caps")
                }
            }
            lastWindow := exe_name ":" exe_title
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

/**
 * 匹配指定的状态，并返回是否需要切换
 * @param {String} exe_name 程序名
 * @param {String} exe_title 程序标题
 * @returns {"CN" | "EN" | "Caps" | 0} 需要切换到的状态或0
 */
switchState(exe_name, exe_title) {
    all := false
    for value in ["CN", "EN", "Caps"] {
        app_state := %"app_" value%
        for v in app_state {
            kv := StrSplit(v, "=", , 2)
            part := StrSplit(kv[2], ":", , 4)
            if (part.Length >= 2) {
                ; 进程名称
                name := part[1]
                ; 是否全局的，全局的只有当切换到此窗口时才会触发
                isGlobal := part[2]

                if (isGlobal) {
                    if (exe_name == name && !InStr(lastWindow, name ":")) {
                        all := value
                    }
                    continue
                }
            }

            if (part.Length < 4) {
                continue
            }

            ; 是否正则匹配
            isRegex := part[3]
            ; 标题
            title := part[4]
            if (name == exe_name) {
                isMatch := isRegex ? RegExMatch(exe_title, title) : exe_title == title
                if (isMatch) {
                    return value
                }
            }
        }
    }
    if (all) {
        return all
    }
    return 0
}

ShowSymbolEx(state) {
    global canShowSymbol
    if (needShow) {
        if (showCursorPos || InStr(showCursorPosList, exe_str)) {
            try {
                MouseGetPos(&left, &top)
                canShowSymbol := 1
                loadSymbol(state, left, top, left, top, 1)
            } catch {
                hideSymbol()
            }
            return
        }
        try {
            canShowSymbol := returnCanShowSymbol(&left, &top, &right, &bottom)

            WinGetPos(&x, &y, &w, &h, "A")
            if (top < y || top > y + h) {
                hideSymbol()
                return
            }
            loadSymbol(state, left, top, right, bottom)
        } catch {
            hideSymbol()
        }
    }
}

updateDelay() {
    if (hideSymbolDelay) {
        SetTimer(updateDelayTimer, 25)
        updateDelayTimer() {
            global needHide, isWait
            if (GetKeyState("LButton", "P")) {
                needHide := 0
                isWait := 1
                SetTimer(_timer, -hideSymbolDelay)
                _timer() {
                    isWait := 0
                }
            }
            if (!isWait) {
                if (A_TimeIdleKeyboard >= hideSymbolDelay - delay) {
                    needHide := 1
                    hideSymbol()
                } else {
                    needHide := 0
                }
            }
            if (hideSymbolDelay = 0) {
                SetTimer(updateDelayTimer, 0)
                needHide := 0
                isWait := 0
            }
        }
    }
}
