; InputTip

updateSymbolDelay()

loop {
    Sleep(var.pollInterval)
    ; 正在使用鼠标或有键盘操作
    if (A_TimeIdle < leaveDelay) {
        needShow := var.symbolType
        try {
            exeName := ProcessGetName(WinGetPID("A"))
            exeTitle := WinGetTitle("A")

            if (needSkip(exeName)) {
                hideSymbol()
                lastSymbol := ""
                lastCursor := ""
                lastWindow := ""
                continue
            }

            ; 进程有变化(包含标题变化)
            hasWindowChange := lastWindow != exeName ":" exeTitle

            if (hasWindowChange) {
                if (validateMatch(exeName, exeTitle, var.WindowAutoExit)) {
                    fn_exit()
                }
                if (var.symbolType) {
                    if (!var.symbolNearCursorActive && !WinActive("ahk_class AutoHotkeyGUI") && (validateMatch(exeName, exeTitle, var.WindowSymbolHide) || !validateMatch(exeName, exeTitle, var.WindowSymbolShow))) {
                        hideSymbol()
                        needShow := 0
                    }
                }

                ; 等待窗口完成聚焦，防止切换状态冲突，导致状态切换失败
                WinWaitActive(exeTitle " ahk_exe " exeName, , 5)

                lastSymbol := ""
                lastCursor := ""

                switchState(returnState(exeName, exeTitle))
            }
        } catch {
            hideSymbol()
            needShow := 0
        }

        try {
            currentState := IME.GetInputModeText()
        } catch {
            hideSymbol()
            continue
        }

        if (!currentState) {
            continue
        }

        if (!isJAB) {
            loadCursor(currentState)
            if (var.overlayActive) {
                if (currentState != lastInputState || (var.overlayShowOnWindowChange && hasWindowChange)) {
                    showOverlay(currentState)
                    lastInputState := currentState
                }
            }
        }

        ShowSymbolEx(currentState)

        if (var.exportState) {
            if (currentState != lastExportState) {
                f := FileOpen(var.exportStateFile, "w-wd", "UTF-8-RAW")
                f.Write(currentState)
                f.Close()
                lastExportState := currentState
            }
        }
    }
}

/**
 * 匹配指定的状态，并返回是否需要切换
 * @param {String} exeName 程序名
 * @param {String} exeTitle 程序标题
 * @returns {"CN"|"EN"|"Caps"|0} 需要切换到的状态或 0
 */
returnState(exeName, exeTitle) {
    all := false
    for val in var.stateList {
        for v in var.%"WindowAutoSwitch" val% {
            kv := StrSplit(v, "=", , 2)
            part := StrSplit(kv[2], ":", , 4)
            if (part.Length >= 2) {
                ; 进程名称
                name := part[1]
                ; 是否全局的，全局的只有当切换到此窗口时才会触发
                isGlobal := part[2]

                if (isGlobal) {
                    if (exeName == name && !InStr(lastWindow, name ":")) {
                        all := val
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
            if (name == exeName) {
                isMatch := isRegex ? RegExMatch(exeTitle, title) : exeTitle == title
                if (isMatch) {
                    return val
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
 * @param {String} exeName 程序名
 * @param {String} exeTitle 程序标题
 * @returns {1|0}
 */
showBesideCursor(exeName, exeTitle) {
    if (!var.symbolNearCursorActive) {
        return 0
    }
    if (var.symbolNearCursorWindow == "all") {
        return 1
    }
    return validateMatch(exeName, exeTitle, var.WindowSymbolNearCursor)
}

/**
 * 验证匹配是否成功(通用)
 * @param {String} exeName 程序名
 * @param {String} exeTitle 程序标题
 * @returns {1|0}
 */
validateMatch(exeName, exeTitle, configValue) {
    for v in configValue {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 4)
        if (part.Length >= 2) {
            ; 进程名称
            name := part[1]
            if (exeName == name) {
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

        if (name == exeName) {
            ; 是否正则匹配
            isRegex := part[3]
            ; 标题
            title := part[4]

            isMatch := isRegex ? RegExMatch(exeTitle, title) : exeTitle == title
            if (isMatch) {
                return 1
            }
        }
    }
    return 0
}
