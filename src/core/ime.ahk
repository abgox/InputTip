; InputTip

/**
 * - 源自于 [AutoHotkeyScripts/IME](https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk)
 * - 为了适配 InputTip，进行了大量的改进与优化
 * @example
 * var.inputMethodDetectionTimeout := 200 ; 超时时间(单位：毫秒)
 * var.inputMethodDetectionRules := [] ; 状态规则
 * var.inputMethodBaseState := "EN" ; 默认状态为英文
  */
class IME {
    static LangMap := Map(
        "US", { langId: 0x09, klid: 0x0409, convMode: 0 },
        "CN", { langId: 0x04, klid: 0x0804, convMode: 1025 },
        "JP", { langId: 0x11, klid: 0x0411, convMode: 9 },
        "KR", { langId: 0x12, klid: 0x0412, convMode: 0 },
    )

    static GeneralStrategy := {
        strategy: 0, ; 0(复合兜底) 1(纯状态码) 2(纯转换码)
        lastChangedTime: 0,
        pendingState: "",
        lastHwnd: 0,
        lastOpened: -1,
        lastConvMode: -1,
        isNonBinaryIME: 0,
        cnValue: 0,
        enValue: 0,
        pendingNonBinary: 0,
        nonBinaryTime: 0,
        hwndChangedTime: 0,
        isHwndInitPending: 0,
    }

    /**
     * 获取当前输入法状态(CN/EN/Caps)或键盘布局(US/JP/KR)
     * @returns {"CN"|"EN"|"Caps"|"US"|"JP"|"KR"}
      */
    static GetInputModeText(hwnd := this.GetFocusedWindow()) {
        static lastState := "EN"
        if GetKeyState("CapsLock", "T")
            return lastState := "Caps"

        try {
            langID := this.GetKeyboardLayout(hwnd) & 0xFF
            for state, info in this.LangMap {
                if langID == info.langId {
                    ; CN 需要走后续状态判断
                    if state != "CN"
                        return lastState := state
                    break
                }
            }

            opened := this.GetOpenStatus(hwnd)
            convMode := this.GetConversionMode(hwnd)

            if var.inputMethodDetectionMode == "general" || !var.inputMethodDetectionRules.Length {
                gs := this.GeneralStrategy
                state := lastState
                if gs.lastHwnd != hwnd || hasTitleChange || hasClassChange || hasProcessChange {
                    gs.lastHwnd := hwnd
                    gs.hwndChangedTime := A_TickCount
                    gs.isHwndInitPending := 1

                    gs.pendingState := ""
                    gs.lastChangedTime := 0
                    gs.pendingNonBinary := 0
                    gs.nonBinaryTime := 0

                    goto SKIP_STRATEGY_LEARNING
                }
                if gs.isHwndInitPending {
                    if A_TickCount - gs.hwndChangedTime < 200
                        goto SKIP_STRATEGY_LEARNING

                    gs.lastOpened := opened
                    gs.lastConvMode := convMode
                    gs.isHwndInitPending := 0
                }

                openedChanged := opened != gs.lastOpened
                convModeChanged := convMode != gs.lastConvMode

                if openedChanged || convModeChanged {
                    currentFeature := opened "," convMode
                    if gs.pendingState != currentFeature {
                        gs.pendingState := currentFeature
                        gs.lastChangedTime := A_TickCount
                        goto SKIP_STRATEGY_LEARNING
                    } else if A_TickCount - gs.lastChangedTime < 200 {
                        goto SKIP_STRATEGY_LEARNING
                    }

                    if convModeChanged {
                        if gs.strategy == 1 && gs.isNonBinaryIME {
                            gs.isNonBinaryIME := 0
                            gs.cnValue := 0
                            gs.enValue := 0
                            gs.pendingNonBinary := 0
                            gs.nonBinaryTime := 0
                        }
                        gs.strategy := 2
                    }
                    else if openedChanged {
                        if gs.strategy == 2 && gs.isNonBinaryIME
                            gs.isNonBinaryIME := 0
                        gs.strategy := 1
                        if opened > 1 {
                            if gs.pendingNonBinary != opened {
                                gs.pendingNonBinary := opened
                                gs.nonBinaryTime := A_TickCount
                                goto SKIP_STRATEGY_LEARNING
                            } else {
                                if A_TickCount - gs.nonBinaryTime < 200 {
                                    goto SKIP_STRATEGY_LEARNING
                                } else {
                                    gs.isNonBinaryIME := 1
                                    gs.cnValue := opened
                                    gs.enValue := (gs.lastOpened == -1 || gs.lastOpened > 1) ? 0 : gs.lastOpened
                                    gs.pendingNonBinary := 0
                                    gs.nonBinaryTime := 0
                                }
                            }
                        } else {
                            if gs.lastOpened >= 0 && gs.lastOpened <= 1 {
                                if gs.isNonBinaryIME {
                                    gs.isNonBinaryIME := 0
                                    gs.cnValue := 0
                                    gs.enValue := 0
                                    gs.pendingNonBinary := 0
                                    gs.nonBinaryTime := 0
                                }
                            } else {
                                gs.pendingNonBinary := 0
                                gs.nonBinaryTime := 0
                            }
                        }
                    }
                    gs.lastOpened := opened
                    gs.lastConvMode := convMode
                    gs.pendingState := ""
                    gs.lastChangedTime := 0
                } else {
                    gs.pendingState := ""
                    gs.lastChangedTime := 0
                }

                SKIP_STRATEGY_LEARNING:
                switch gs.strategy {
                    case 1:
                        state := gs.isNonBinaryIME ? (opened == gs.cnValue ? "CN" : "EN") : (opened ? "CN" : "EN")
                    case 2:
                        state := convMode & 1 ? "CN" : "EN"
                    default:
                        if gs.isNonBinaryIME
                            state := opened == gs.cnValue ? "CN" : "EN"
                        else if convMode == 0
                            state := opened ? "CN" : "EN"
                        else if opened == 0
                            state := "EN"
                        else if convMode & 1
                            state := "CN"
                        else
                            state := "EN"
                }
                lastState := state
                return state
            }

            state := var.inputMethodBaseState

            for v in var.inputMethodDetectionRules {
                r := StrSplit(v, ",")
                if this.MatchRule(opened, r[1]) && this.MatchRule(convMode, r[2]) {
                    state := r[3]
                    break
                }
            }

            return lastState := state
        } catch {
            return lastState
        }
    }

    static CheckInputMode(hwnd := this.GetFocusedWindow()) {
        return {
            openStatus: this.GetOpenStatus(hwnd),
            conversionMode: this.GetConversionMode(hwnd)
        }
    }

    /**
     * 切换到指定的输入法状态(CN/EN)或键盘布局(US/JP/KR)
     * @param {"CN"|"EN"|"US"|"JP"|"KR"} targetState
     * @param {0|1} active
     */
    static SetInputMode(targetState, opened := "", conversionMode := "", hwnd := this.GetFocusedWindow()) {
        switch targetState {
            case "US":
                this.SwitchKeyboard(targetState)
                return
            case "JP", "KR":
                this.SwitchKeyboard(targetState)
                if opened !== "" || conversionMode !== "" {
                    Sleep(50)
                    if opened !== ""
                        this.SetOpenStatus(opened, hwnd)
                    if conversionMode !== ""
                        this.SetConversionMode(conversionMode, hwnd)
                }
                return
        }
        this.SwitchKeyboard("CN")

        if var.inputMethodDetectionMode != "general" {
            switch targetState {
                case "CN": this.SetOpenStatus(true, hwnd), this.SetConversionMode(this.LangMap["CN"].convMode, hwnd)
                case "EN": this.SetOpenStatus(false, hwnd)
            }
            return
        }

        ; CN/EN
        gs := this.GeneralStrategy
        switch gs.strategy {
            case 1:
                if targetState == "CN"
                    s := gs.isNonBinaryIME ? gs.cnValue : 1
                else
                    s := gs.isNonBinaryIME ? gs.enValue : 0
                this.SetOpenStatus(s, hwnd)
            case 2:
                this.SetConversionMode(targetState == "CN" ? this.LangMap["CN"].convMode : 0, hwnd)
            default:
                if gs.isNonBinaryIME {
                    this.SetOpenStatus(targetState == "CN" ? gs.cnValue : gs.enValue, hwnd)
                } else {
                    if targetState == "CN"
                        this.SetOpenStatus(true, hwnd), this.SetConversionMode(this.LangMap["CN"].convMode, hwnd)
                    else
                        this.SetOpenStatus(false, hwnd), this.SetConversionMode(0, hwnd)
                }
        }

        Sleep(20)
        gs.lastOpened := this.GetOpenStatus(hwnd)
        gs.lastConvMode := this.GetConversionMode(hwnd)
    }

    static MatchRule(value, rule) {
        if rule == ""
            return 1
        switch rule {
            case "evenNum": isMatch := !(value & 1)
            case "oddNum": isMatch := value & 1
            default: isMatch := InStr("/" rule "/", "/" value "/")
        }
        return isMatch
    }

    static GetOpenStatus(hwnd := this.GetFocusedWindow()) {
        try {
            DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x5, "ptr", 0, "uint", 0, "uint", var.inputMethodDetectionTimeout, "ptr*", &status := 0)
            return status
        } catch {
            return 0
        }
    }

    static SetOpenStatus(status, hwnd := this.GetFocusedWindow()) {
        try DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x6, "ptr", status, "uint", 0, "uint", var.inputMethodDetectionTimeout, "ptr*", 0)
    }

    static GetConversionMode(hwnd := this.GetFocusedWindow()) {
        try {
            DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x1, "ptr", 0, "uint", 0, "uint", var.inputMethodDetectionTimeout, "ptr*", &mode := 0)
            return mode
        } catch {
            return 0
        }
    }

    static SetConversionMode(mode, hwnd := this.GetFocusedWindow()) {
        try DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x2, "ptr", mode, "uint", 0, "uint", var.inputMethodDetectionTimeout, "ptr*", 0)
    }

    static GetKeyboardLayout(hwnd := this.GetFocusedWindow()) {
        return DllCall("GetKeyboardLayout", "uint", DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", 0, "uint"), "ptr")
    }

    static SetKeyboardLayout(hkl, hwnd := this.GetFocusedWindow()) {
        try SendMessage(0x50, 1, hkl, hwnd)
    }

    static GetKeyboardLayoutList() {
        list := []
        if cnt := DllCall("GetKeyboardLayoutList", "int", 0, "ptr", 0) {
            buf := Buffer(cnt * A_PtrSize)
            loop DllCall("GetKeyboardLayoutList", "int", cnt, "ptr", buf)
                list.Push(NumGet(buf, (A_Index - 1) * A_PtrSize, "ptr"))
        }
        return list
    }

    static LoadKeyboardLayout(hkl) {
        return DllCall("LoadKeyboardLayoutW", "str", Format("{:08x}", hkl), "uint", 0x101)
    }

    static UnloadKeyboardLayout(hkl) {
        return DllCall("UnloadKeyboardLayout", "ptr", hkl)
    }

    /**
     * 切换到指定的语言输入法布局
     * @param {"CN"|"US"|"JP"|"KR"} state
      */
    static SwitchKeyboard(state) {
        if !this.LangMap.Has(state)
            return false
        info := this.LangMap[state]
        hwnd := this.GetFocusedWindow()
        if !hwnd
            return false

        for hkl in this.GetKeyboardLayoutList() {
            if (hkl & 0xFF) == info.langId {
                this.SetKeyboardLayout(hkl, hwnd)
                return true
            }
        }
        hkl := this.LoadKeyboardLayout(info.klid)
        if hkl {
            this.SetKeyboardLayout(hkl, hwnd)
            return true
        }
        return false
    }

    static GetFocusedWindow() {
        if foreHwnd := WinExist("A") {
            guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48)
            NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
            DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", foreHwnd, "ptr", 0, "uint"), "ptr", guiThreadInfo)
            if focusedHwnd := NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr")
                return focusedHwnd
            return foreHwnd
        }
        return 0
    }
}

/**
 * 切换键盘布局
 * @param {"CN"|"US"|"JP"|"KR"} state 要切换的键盘布局
 * @param {""|0|1} active
 * @param {0|1} ignoreKeepCaps
 */
switchKeyboard(state, opened := "", conversionMode := "", ignoreKeepCaps := 0) {
    if matchWindowRules(var.WindowRule["ignoreKeyboardSwitch"]).Length
        return 0
    if !ignoreKeepCaps && IME.GetInputModeText() == "Caps" && !var.keepCapsLockWhenKeyboardSwitch
        SendInput("{CapsLock}")
    return opened != "" || conversionMode != "" ? IME.SetInputMode(state, opened, conversionMode) : IME.SwitchKeyboard(state)
}

/**
 * 切换输入法状态
 * @param {"CN"|"EN"|"Caps"} state 输入法状态
 * @param {"{LShift}"|"{RShift}"|"{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}"|"IME"} method  切换方式(模拟按键/IME)
 */
switchState(state, method) {
    if !state || matchWindowRules(var.WindowRule["ignoreStateSwitch"]).Length
        return

    SetTimer(onRun, 50)
    onRun() {
        static modifiers := ["Ctrl", "Alt", "Shift", "LWin", "RWin", "Shift"]
        for mod in modifiers {
            if GetKeyState(mod, "P")
                return
        }
        if GetKeyState("LButton", "P") || GetKeyState("RButton", "P")
            return

        SetTimer(onRun, 0)
        stateText := IME.GetInputModeText()
        if !stateText
            return

        if state == stateText
            return

        if stateText == "Caps" {
            if var.keepCapsLockWhenStateSwitch
                return

            SendInput("{CapsLock}")
            Sleep(50)
            stateText := IME.GetInputModeText()
            if !stateText
                return

            if state == stateText
                return

        } else if state == "Caps" {
            SendInput("{CapsLock}")
            return
        }

        if method == "IME"
            IME.SetInputMode(state)
        else
            SendInput(method)
    }
}
