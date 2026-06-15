; InputTip

currentState := "EN"
lastInputState := "", lastExportState := ""
hasTitleChange := 1, hasClassChange := 1, hasProcessChange := 1
exePid := "", exeName := "", exeTitle := "", exeClass := "", leaveDelay := var.pollInterval + 500
lastProcess := "", lastTitle := "", lastClass := ""
lastCaretSymbol := "", lastCursorSymbol := "", lastCursor := "", lastBorderState := ""

updateSymbolDelay()
updateCursorDelay()


if isJAB {
    loop {
        Sleep(var.pollInterval)
        if var._paused {
            lastCaretSymbol := "", lastCursorSymbol := "", lastCursor := ""
            lastTitle := "", lastClass := "", lastProcess := ""
            continue
        }

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

                if !InStr(getCaretCapture().capture, "JAB") {
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

                    WinWaitActive(exeTitle " ahk_exe " exeName, , 3)

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

            if var._paused {
                lastCaretSymbol := "", lastCursorSymbol := "", lastCursor := ""
                lastTitle := "", lastClass := "", lastProcess := ""
                continue
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
                    if !targetColor
                        targetColor := var.%"borderColor" currentState%

                    allowShow := targetColor != ""

                    if (allowShow && !isPined) {
                        switch var.borderShowMode {
                            case "blacklist":
                                if exePid != appPid && matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowBorderRule["hide"])
                                    allowShow := false
                            case "whitelist":
                                if exePid != appPid && !matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowBorderRule["show"])
                                    allowShow := false
                        }
                    }

                    currentBorderFingerprint := targetColor "_" targetWidth "_" isMaximized "_" isFullScreen(hwnd) "_" allowShow "_" hwnd

                    if currentBorderFingerprint != lastBorderState || (var.borderReshowOnTitleChange && hasTitleChange) || (var.borderReshowOnClassChange && hasClassChange) || (var.borderReshowOnProcessChange && hasProcessChange) {
                        if allowShow {
                            if IsSet(activeBorderTimer)
                                SetTimer(activeBorderTimer, 0)
                            showBorder(targetColor, targetWidth, hwnd)
                            if var.borderHideDelay {
                                activeBorderTimer := hideBorder.Bind(hwnd)
                                SetTimer(activeBorderTimer, -returnMaxTimerNumber(var.borderHideDelay))
                            }
                        } else {
                            if IsSet(activeBorderTimer)
                                SetTimer(activeBorderTimer, 0)
                            hideBorder(hwnd)
                        }
                        lastBorderState := currentBorderFingerprint
                    }
                } catch {
                    hideBorder()
                    lastBorderState := ""
                }
            } else {
                if lastBorderState != "" {
                    try hideBorder(WinExist("A"))
                    lastBorderState := ""
                }
            }

            switch var.cursorSymbolShowMode {
                case "blacklist":
                    if exePid != appPid && matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCursorSymbolRule["hide"])
                        hideCursorSymbol()
                    else if !cursorDelayState.hidden
                        ShowCursorSymbolEx(currentState)
                case "whitelist":
                    if exePid != appPid && !matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowCursorSymbolRule["show"])
                        hideCursorSymbol()
                    else if !cursorDelayState.hidden
                        ShowCursorSymbolEx(currentState)
                default:
                    hideCursorSymbol()
            }

            if !InStr(getCaretCapture().capture, "JAB") {
                ShowCaretSymbolEx(currentState)
            } else {
                hideCaretSymbol()
            }

            loadCursor(currentState)
            if var.overlayActive {
                if currentState != lastInputState || (var.overlayReshowOnTitleChange && hasTitleChange) || (var.overlayReshowOnClassChange && hasClassChange) || (var.overlayReshowOnProcessChange && hasProcessChange) {
                    switch var.overlayShowMode {
                        case "blacklist":
                            (exePid != appPid && matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowOverlayRule["hide"])) ? hideOverlay() : showOverlay(currentState)
                        case "whitelist":
                            (exePid != appPid && !matchWindowDisplay(exeName, exeTitle, exeClass, var.WindowOverlayRule["show"])) ? hideOverlay() : showOverlay(currentState)
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
