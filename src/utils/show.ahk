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

        ; 进程有变化(包含标题变化)
        hasWindowChange := lastWindow != exe_name ":" exe_title
        if (hasWindowChange) {
            if (symbolType) {
                if (needSkip(exe_str)) {
                    hideSymbol()
                    lastSymbol := ""
                    lastCursor := ""
                    lastWindow := ""
                    continue
                }

                if (
                    !showCursorPos
                    && !WinActive("ahk_class AutoHotkeyGUI")
                    && (validateMatch(exe_name, exe_title, app_HideSymbol) || !validateMatch(exe_name, exe_title, app_ShowSymbol))
                ) {
                    hideSymbol()
                    needShow := 0
                }
            }

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

        if (needHide) {
            hideSymbol()
            needShow := 0
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

/**
 * 是否需要显示在鼠标附近
 * @param {String} exe_name 程序名
 * @param {String} exe_title 程序标题
 * @returns {1 | 0}
 */
showBesideCursor(exe_name, exe_title) {
    if (showCursorPos) {
        return 1
    }
    return validateMatch(exe_name, exe_title, ShowNearCursor)
}

/**
 * 验证匹配是否成功(通用)
 * @param {String} exe_name 程序名
 * @param {String} exe_title 程序标题
 * @returns {1 | 0}
 */
validateMatch(exe_name, exe_title, configValue) {
    for v in configValue {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 4)
        if (part.Length >= 2) {
            ; 进程名称
            name := part[1]
            if (exe_name == name) {
                ; 如果是进程级
                if (part[2]) {
                    return 1
                }
            } else {
                continue
            }
        }

        if (part.Length < 4) {
            continue
        }

        if (name == exe_name) {
            ; 是否正则匹配
            isRegex := part[3]
            ; 标题
            title := part[4]

            isMatch := isRegex ? RegExMatch(exe_title, title) : exe_title == title
            if (isMatch) {
                return 1
            }
        }
    }
    return 0
}

ShowSymbolEx(state) {
    static last := 0
    static lastNeedShow := 0
    global canShowSymbol

    if (hasWindowChange) {
        select := showBesideCursor(exe_name, exe_title)
        lastNeedShow := needShow
    } else {
        select := last
    }

    if (lastNeedShow) {
        if (select) {
            try {
                MouseGetPos(&left, &top)
                canShowSymbol := 1
                loadSymbol(state, left, top, left, top, 1)
            } catch {
                hideSymbol()
            }
            last := 1
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
        last := 0
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
