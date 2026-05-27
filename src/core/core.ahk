; InputTip

currentState := "EN"
lastInputState := "", lastExportState := ""
hasWindowChange := 1, canShowSymbol := 0
lastWindow := "", lastSymbol := "", lastCursor := ""
exeName := "", exeTitle := "", leaveDelay := var.pollInterval + 500

updateSymbolDelay()

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
                if validateMatch(exeName, exeTitle, var.WindowAutoPause) {
                    pauseApp()
                    continue
                }
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
