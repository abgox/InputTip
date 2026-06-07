; InputTip

currentState := "EN"
lastInputState := "", lastExportState := ""
hasTitleChange := 1, hasClassChange := 1, hasProcessChange := 1
exeName := "", exeTitle := "", exeClass := "", leaveDelay := var.pollInterval + 500
lastProcess := "", lastTitle := "", lastClass := ""
lastCaretSymbol := "", lastCursorSymbol := "", lastCursor := "", lastBorderState := ""

updateSymbolDelay()


if isJAB {
    loop {
        Sleep(var.pollInterval)

        if !var.caretSymbolType {
            hideCaretSymbol()
            lastCaretSymbol := ""
            lastCursorSymbol := ""
            lastCursor := ""
            continue
        }

        if A_TimeIdle < leaveDelay {
            needShow := var.caretSymbolType
            try {
                exePid := WinGetPID("A")
                exeName := ProcessGetName(exePid)
                exeTitle := WinGetTitle("A")
                exeClass := WinGetClass("A")

                if !InStr(getCursorCapture(), "JAB") {
                    hideCaretSymbol()
                    lastCaretSymbol := ""
                    lastCursorSymbol := ""
                    lastCursor := ""
                    continue
                }

                hasProcessChange := lastProcess != exeName
                hasTitleChange := lastTitle != exeTitle
                hasClassChange := lastClass != exeClass

                if hasTitleChange || hasClassChange || hasProcessChange {
                    if matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCaretSymbolRule["hide"]) || !matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCaretSymbolRule["show"])
                        hideCaretSymbol(), needShow := 0

                    lastCaretSymbol := ""
                    lastCursorSymbol := ""
                    lastCursor := ""
                    lastTitle := exeTitle
                    lastClass := exeClass
                    lastProcess := exeName
                }
            } catch {
                hideCaretSymbol()
                needShow := 0
            }

            try {
                currentState := IME.GetInputModeText()
            } catch {
                hideCaretSymbol()
                continue
            }

            if !currentState
                continue

            ShowCaretSymbolEx(currentState)
        }
    }
} else {
    loop {
        Sleep(var.pollInterval)
        if (A_TimeIdle < leaveDelay) {
            needShow := var.caretSymbolType
            try {
                exePid := WinGetPID("A")
                exeName := ProcessGetName(exePid)
                exeTitle := WinGetTitle("A")
                exeClass := WinGetClass("A")

                hasProcessChange := lastProcess != exeName
                hasTitleChange := lastTitle != exeTitle
                hasClassChange := lastClass != exeClass

                if hasProcessChange
                    initMonitor()

                if hasTitleChange || hasClassChange || hasProcessChange {
                    if var.caretSymbolType {
                        if exePid != appPid && (matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCaretSymbolRule["hide"]) || !matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCaretSymbolRule["show"]))
                        {
                            hideCaretSymbol()
                            needShow := 0
                        }
                    }

                    ; 等待窗口完成聚焦，防止切换状态冲突，导致状态切换失败
                    WinWaitActive(exeTitle " ahk_exe " exeName, , 5)

                    lastCaretSymbol := ""
                    lastCursorSymbol := ""
                    lastCursor := ""
                    lastTitle := exeTitle
                    lastClass := exeClass
                    lastProcess := exeName

                    updateWindowHotkey()
                    runTriggers(returnTriggers(exeName, exeTitle, exeClass))
                }
            } catch {
                hideCaretSymbol()
                needShow := 0
            }

            try {
                currentState := IME.GetInputModeText()
            } catch {
                hideCaretSymbol()
                continue
            }

            if !currentState
                continue

            if var.borderActive {
                try {
                    hwnd := WinExist("A")
                    isPined := WinGetExStyle("A") & 0x8
                    isMaximized := WinGetMinMax("A") == 1

                    if isPined {
                        targetColor := var.borderColorPinned
                        targetWidth := var.borderWidthPinned
                    } else {
                        targetColor := var.%"borderColor" currentState%
                        targetWidth := var.%"borderWidth" currentState%
                    }

                    allowShow := (targetColor != "")

                    if (allowShow && !isPined) {
                        switch var.borderShowMode {
                            case "blacklist":
                                if matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowBorderRule["hide"])
                                    allowShow := false
                            case "whitelist":
                                if !matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowBorderRule["show"])
                                    allowShow := false
                        }
                    }

                    currentBorderFingerprint := targetColor "_" targetWidth "_" isMaximized "_" allowShow "_" hwnd

                    if currentBorderFingerprint != lastBorderState || (var.borderReshowOnTitleChange && hasTitleChange) || (var.borderReshowOnClassChange && hasClassChange) || (var.borderReshowOnProcessChange && hasProcessChange) {
                        if allowShow {
                            if IsSet(activeBorderTimer) {
                                SetTimer(activeBorderTimer, 0)
                            }
                            ShowMaximizedBorders(targetColor, targetWidth, hwnd)
                            if var.borderHideDelay {
                                activeBorderTimer := DestroyMaximizedBorders.Bind(hwnd)
                                SetTimer(activeBorderTimer, -var.borderHideDelay)
                            }
                        } else {
                            if IsSet(activeBorderTimer)
                                SetTimer(activeBorderTimer, 0)
                            DestroyMaximizedBorders(hwnd)
                        }
                        lastBorderState := currentBorderFingerprint
                    }
                } catch {
                    DestroyMaximizedBorders()
                    lastBorderState := ""
                }
            } else {
                if lastBorderState != "" {
                    try DestroyMaximizedBorders(WinExist("A"))
                    lastBorderState := ""
                }
            }

            switch var.cursorSymbolShowMode {
                case "blacklist":
                    matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCursorSymbolRule["hide"]) ? hideCursorSymbol() : ShowCursorSymbolEx(currentState)
                case "whitelist":
                    matchWindowRules(exeName, exeTitle, exeClass, var.WindowCursorSymbolRule["show"]) ? ShowCursorSymbolEx(currentState) : hideCursorSymbol()
                default:
                    hideCursorSymbol()
            }

            if !InStr(getCursorCapture(), "JAB") {
                ShowCaretSymbolEx(currentState)
            } else {
                hideCaretSymbol()
            }

            loadCursor(currentState)
            if var.overlayActive {
                if currentState != lastInputState || (var.overlayReshowOnTitleChange && hasTitleChange) || (var.overlayReshowOnClassChange && hasClassChange) || (var.overlayReshowOnProcessChange && hasProcessChange) {
                    switch var.overlayShowMode {
                        case "blacklist":
                            matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowOverlayRule["hide"]) ? hideOverlay() : showOverlay(currentState)
                        case "whitelist":
                            matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowOverlayRule["show"]) ? showOverlay(currentState) : hideOverlay()
                        default:
                            showOverlay(currentState)
                    }
                    lastInputState := currentState
                }
            }

            if var.exportState {
                if currentState != lastExportState {
                    f := FileOpen(var.exportStateFile, "w-wd", "UTF-8-RAW")
                    f.Write(currentState)
                    f.Close()
                    lastExportState := currentState
                }
            }
        }
    }
}
