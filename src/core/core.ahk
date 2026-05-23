; InputTip

currentState := "", lastInputState := "", lastExportState := ""
hasWindowChange := 1, lastWindow := "", lastSymbol := "", lastCursor := ""
exeName := "", exeTitle := "", leaveDelay := var.pollInterval + 500
canShowSymbol := 0

delayState := {
    timer: 0,
    isWait: 0,
    needHide: 0
}

updateSymbolDelay()

updateSymbolDelay() {
    if !var.symbolHideDelay
        return
    SetTimer(onDelayTick, 0)
    SetTimer(onDelayTick, 25)
}

onDelayTick() {
    if (var.symbolHideDelay == 0) {
        SetTimer(onDelayTick, 0)
        delayState.needHide := 0
        delayState.isWait := 0
        return
    }

    if (GetKeyState("LButton", "P")) {
        delayState.needHide := 0
        delayState.isWait := 1
        SetTimer(() => delayState.isWait := 0, -var.symbolHideDelay)
    }

    if A_TimeIdleKeyboard <= leaveDelay
        delayState.timer := 0

    if (!delayState.isWait) {
        if (A_TimeIdleKeyboard >= var.symbolHideDelay - var.pollInterval
            || delayState.timer >= var.symbolHideDelay) {
            delayState.needHide := 1
            hideSymbol()
            delayState.timer := 0
        } else {
            delayState.needHide := 0
        }
    }
    delayState.timer += 25
}

loop {
    Sleep(var.pollInterval)
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

            hasWindowChange := lastWindow != exeName ":" exeTitle

            if (hasWindowChange) {
                if exeName != "explorer.exe" && validateMatch(exeName, exeTitle, var.WindowAutoExit)
                    fn_exit()
                if (var.symbolType) {
                    if (needSkipSymbol(exeName)) {
                        hideSymbol()
                        needShow := 0
                    } else if (!var.symbolNearCursorActive && !WinActive("ahk_class AutoHotkeyGUI") && (validateMatch(exeName, exeTitle, var.WindowSymbolHide) || !validateMatch(exeName, exeTitle, var.WindowSymbolShow))) {
                        hideSymbol()
                        needShow := 0
                    }
                }

                ; 等待窗口完成聚焦，防止切换状态冲突，导致状态切换失败
                WinWaitActive(exeTitle " ahk_exe " exeName, , 5)

                lastSymbol := ""
                lastCursor := ""
                lastWindow := exeName ":" exeTitle

                ; JAB 进程不执行状态切换
                if !isJAB
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

        if !currentState
            continue

        ShowSymbolEx(currentState)

        if (!isJAB) {
            loadCursor(currentState)
            if (var.overlayActive) {
                if (currentState != lastInputState || (var.overlayShowOnWindowChange && hasWindowChange)) {
                    showOverlay(currentState)
                    lastInputState := currentState
                }
            }
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
}

/**
 * 预处理匹配规则
 * @param {Array} configValue 原始配置数组
 * @returns {Map} 以进程名为键的规则 Map
 */
parseMatchRules(configValue) {
    rules := Map()
    for v in configValue {
        if (v == "")
            continue
        kv := StrSplit(v, "=", , 2)
        if kv.Length < 2
            continue
        part := StrSplit(kv[2], ":", , 4)
        if part.Length < 2
            continue
        name := part[1]
        if (name == "")
            continue
        rule := {
            isByProcess: part[2] == "1" ? 1 : 0,
            isRegex: part.Length >= 4 ? part[3] : "",
            title: part.Length >= 4 ? RTrim(part[4], ":") : ""
        }
        if !rules.Has(name)
            rules.Set(name, [])
        rules.Get(name).Push(rule)
    }
    return rules
}

/**
 * 验证匹配是否成功(通用)
 * @param {String} exeName 程序名
 * @param {String} exeTitle 程序标题
 * @param {Map} rules 预处理后的规则 Map
 * @returns {1|0}
 */
validateMatch(exeName, exeTitle, rules) {
    if !rules.Has(exeName)
        return 0
    byProcess := 0
    for rule in rules.Get(exeName) {
        if (rule.isByProcess) {
            byProcess := 1
            continue
        }
        isMatch := rule.isRegex ? RegExMatch(exeTitle, rule.title) : exeTitle == rule.title
        if (isMatch)
            return 1
    }
    return byProcess
}

/**
 * 匹配指定的状态，并返回是否需要切换
 * @param {String} exeName 程序名
 * @param {String} exeTitle 程序标题
 * @returns {"CN"|"EN"|"Caps"|0} 需要切换到的状态或 0
 */
returnState(exeName, exeTitle) {
    byProcess := 0
    ; XXX 不支持 JP 和 KR
    for state in ["CN", "EN", "Caps"] {
        rules := var.%"WindowAutoSwitch" state%
        if !rules.Has(exeName)
            continue
        for rule in rules.Get(exeName) {
            if (rule.isByProcess) {
                if !byProcess
                    byProcess := state
                continue
            }
            isMatch := rule.isRegex ? RegExMatch(exeTitle, rule.title) : exeTitle == rule.title
            if (isMatch)
                return state
        }
    }
    return byProcess
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
