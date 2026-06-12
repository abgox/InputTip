; InputTip

/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk
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
    static OpenStateMap := Map(
        1, "CN",
        0, "EN",
    )

    /**
     * 获取当前输入法输入模式
     * @returns {"CN"|"EN"|"Caps"|"US"|"JP"|"KR"}
     * - "CN": 中文输入法的中文模式
     * - "EN": 中文输入法的英文模式
     * - "Caps": 大写锁定激活状态
     * - "US": 英文键盘布局（如美式键盘）
     * - "JP": 日文键盘
     * - "KR": 韩文键盘
     */
    static GetInputModeText(hwnd := this.GetFocusedWindow()) {
        static lastState := "EN"
        if GetKeyState("CapsLock", "T") {
            lastState := "Caps"
            return "Caps"
        }
        try {
            langID := this.GetKeyboardLayout(hwnd) & 0xFF
            for state, info in this.LangMap {
                if langID == info.langId {
                    ; CN 需要走后续状态判断
                    if state != "CN" {
                        lastState := state
                        return state
                    }
                    break
                }
            }

            opened := this.GetOpenStatus(hwnd)
            convMode := this.GetConversionMode(hwnd)


            if var.inputMethodDetectionMode == "general" {
                static lastOpened := -1
                static lastConvMode := -1
                static strategy := 0 ; 0 = 标准复合兜底, 1 = 纯状态码, 2 = 纯转换码

                static isNonBinaryIME := 0 ; 非二元状态输入法标识
                static cnValue := 0
                static enValue := 0

                if lastOpened == -1 || lastConvMode == -1 {
                    lastOpened := opened
                    lastConvMode := convMode
                }
                else if opened != lastOpened || convMode != lastConvMode {
                    openedChanged := opened != lastOpened
                    convModeChanged := convMode != lastConvMode

                    if !openedChanged && convModeChanged {
                        strategy := 2
                        isNonBinaryIME := 0
                    }
                    else if openedChanged && !convModeChanged {
                        strategy := 1
                        if isNonBinaryIME && (strategy == 2 || opened < 1)
                            isNonBinaryIME := 0
                        if opened != lastOpened && (opened > 1 || lastOpened > 1)
                            isNonBinaryIME := 1, cnValue := Max(opened, lastOpened), enValue := Min(opened, lastOpened)
                    }
                    else if openedChanged && convModeChanged {
                        strategy := 0
                        isNonBinaryIME := 0
                    }

                    lastOpened := opened
                    lastConvMode := convMode
                }

                switch strategy {
                    case 1:
                        if isNonBinaryIME
                            state := opened == cnValue ? "CN" : "EN"
                        else
                            state := opened ? "CN" : "EN"

                    case 2:
                        state := convMode & 1 ? "CN" : "EN"

                    default:
                        if isNonBinaryIME {
                            state := opened == cnValue ? "CN" : "EN"
                        }
                        else if convMode & 1 {
                            state := "CN"
                        }
                        else {
                            if (opened == 0) || (opened == 1 && (convMode == 0 || convMode == 1))
                                state := "EN"
                            else
                                state := opened ? "CN" : "EN"
                        }
                }
                lastState := state
                return state
            }

            state := var.inputMethodBaseState

            for v in var.inputMethodDetectionRules {
                r := StrSplit(v, ",")
                if matchRule(opened, r[1]) && matchRule(convMode, r[2]) {
                    state := r[3]
                    break
                }
            }

            return lastState := state
        } catch {
            return lastState
        }

        matchRule(value, ruleValue) {
            if ruleValue == ""
                return 1
            switch ruleValue {
                case "evenNum": isMatch := !(value & 1)
                case "oddNum": isMatch := value & 1
                default: isMatch := InStr("/" ruleValue "/", "/" value "/")
            }
            return isMatch
        }
    }

    static CheckInputMode(hwnd := this.GetFocusedWindow()) {
        return {
            stateMode: this.GetOpenStatus(hwnd),
            conversionMode: this.GetConversionMode(hwnd)
        }
    }

    /**
     * 切换到指定的输入法状态/布局
     * @param {"CN"|"EN"|"US"|"JP"|"KR"} targetState
     */
    static SetInputMode(targetState, hwnd := this.GetFocusedWindow()) {
        if targetState == "US" || targetState == "JP" || targetState == "KR" {
            this.SwitchKeyboard(targetState)
            if targetState != "US"
                Sleep(50), this.SetOpenStatus(true, hwnd)
            return
        }
        this.SwitchKeyboard("CN")
        switch targetState {
            case "CN": this.SetOpenStatus(true, hwnd), this.SetConversionMode(this.LangMap["CN"].convMode, hwnd)
            case "EN": this.SetOpenStatus(false, hwnd)
        }
    }

    static ToggleInputMode(hwnd := this.GetFocusedWindow()) {
        current := this.GetInputModeText(hwnd)
        this.SetInputMode((current == "US" || current == "EN") ? "CN" : "EN", hwnd)
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
 * @param ignoreKeepCaps
 */
switchKeyboard(state, ignoreKeepCaps := 0) {
    if matchWindowRules(exeName, exeTitle, exeClass, var.WindowRule["ignoreKeyboardSwitch"]).Length
        return 0
    if !ignoreKeepCaps && IME.GetInputModeText() == "Caps" && !var.keepCapsLockWhenKeyboardSwitch
        SendInput("{CapsLock}")
    return IME.SwitchKeyboard(state)
}

/**
 * 切换输入法状态
 * @param {"CN"|"EN"|"Caps"} state 输入法状态
 * @param {"{LShift}"|"{RShift}"|"{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}"|"IME"} method  切换方式(模拟按键/IME)
 */
switchState(state, method) {
    if !state
        return

    if matchWindowRules(exeName, exeTitle, exeClass, var.WindowRule["ignoreStateSwitch"]).Length
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
