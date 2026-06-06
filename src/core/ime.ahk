; InputTip

/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk
 * @example
 * var.inputMethodDetectionTimeout := 200 ; 超时时间(单位：毫秒)
 * var.inputMethodDetectionRules := [] ; 状态规则
 * var.inputMethodBaseState := 0 ; 默认状态为英文
 */
class IME {
    static LangMap := Map(
        "EN", { langId: 0x09, klid: 0x0409, convMode: 0 },
        "CN", { langId: 0x04, klid: 0x0804, convMode: 1025 },
        "JP", { langId: 0x11, klid: 0x0411, convMode: 9 },
        "KR", { langId: 0x12, klid: 0x0412, convMode: 0 },
    )
    static OpenStateMap := Map(
        1, "CN",
        0, "EN",
    )

    static GetInputMode(hwnd := this.GetFocusedWindow()) {
        if !this.GetOpenStatus(hwnd)
            return false
        convMode := this.GetConversionMode(hwnd)

        ; IME_CMODE_NOCONVERSION，强制英文
        if convMode & 0x100
            return false

        ; IME_CMODE_LANGUAGE，兼容日文
        return convMode & 3
    }

    /**
     * 获取当前输入法输入模式
     * @returns {"CN"|"EN"|"Caps"|"JP"|"KR"}
     */
    static GetInputModeText(hwnd := this.GetFocusedWindow()) {
        if GetKeyState("CapsLock", "T")
            return "Caps"

        langID := this.GetKeyboardLayout(hwnd) & 0xFF
        for state, info in this.LangMap {
            if langID == info.langId {
                ; CN 需要走后续状态判断
                if state != "CN"
                    return state
                break
            }
        }

        opened := this.GetOpenStatus(hwnd)
        convMode := this.GetConversionMode(hwnd)

        ; IME_CMODE_NOCONVERSION：即使 opened 为 1 也视为英文
        if convMode & 0x100
            opened := false

        if var.inputMethodDetectionMode == "general"
            return this.OpenStateMap.Get(opened && (convMode & 3) ? 1 : 0, "EN")

        ; 存储默认状态，如果都不匹配，就返回预先指定的默认状态
        baseState := var.inputMethodBaseState

        for v in var.inputMethodDetectionRules {
            r := StrSplit(v, "*")

            ; 状态码规则
            sm := r[1]
            ; 转换码规则
            cm := r[2]
            ; 匹配状态
            s := r[3]

            if matchRule(opened, sm) && matchRule(convMode, cm) {
                ; 匹配成功
                baseState := s
                break
            }
        }

        /**
         * 匹配规则
         * @param value 系统返回的状态值
         * @param ruleValue 规则定义的状态值
         * @returns {1|0} 是否匹配成功
         */
        matchRule(value, ruleValue) {
            ; 规则为空，默认匹配成功
            if ruleValue == ""
                return 1
            switch ruleValue {
                case "evenNum": isMatch := !(value & 1)
                case "oddNum": isMatch := value & 1
                default: isMatch := InStr("/" ruleValue "/", "/" value "/")
            }
            return isMatch
        }

        try {
            return this.OpenStateMap.Get(Integer(baseState), "EN")
        } catch {
            return "EN"
        }
    }

    /**
     * 系统返回的状态码和转换码
     * @returns {Object} 系统返回的状态码和转换码
     */
    static CheckInputMode(hwnd := this.GetFocusedWindow()) {
        return {
            stateMode: this.GetOpenStatus(hwnd),
            conversionMode: this.GetConversionMode(hwnd)
        }
    }

    /**
     * 切换到指定的输入法状态
     * @param mode 要切换的指定输入法状态(1:中文/日文，0:英文)
     */
    static SetInputMode(mode, hwnd := this.GetFocusedWindow()) {
        if mode {
            this.SetOpenStatus(true, hwnd)
            langID := this.GetKeyboardLayout(hwnd) & 0xFF
            for state, info in this.LangMap {
                if (langID == info.langId) && info.convMode {
                    this.SetConversionMode(info.convMode, hwnd)
                    break
                }
            }
        }
        else {
            this.SetOpenStatus(false, hwnd)
        }
    }

    static ToggleInputMode(hwnd := this.GetFocusedWindow()) {
        this.SetInputMode(!this.GetInputMode(hwnd), hwnd)
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
     * @param {"CN"|"EN"|"JP"|"KR"} state
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
 * @param {"CN"|"EN"|"JP"|"KR"} state 要切换的键盘布局
 */
switchKeyboard(state) {
    if matchWindowRule(exeName, exeTitle, exeClass, var.windowRule["ignoreStateSwitch"])
        return 0
    return IME.SwitchKeyboard(state)
}

/**
 * 切换输入法状态
 * @param {"CN"|"EN"|"Caps"} state 要切换的输入法状态
 */
switchState(state) {
    if (!state) {
        return
    }
    if matchWindowRule(exeName, exeTitle, exeClass, var.windowRule["ignoreStateSwitch"])
        return

    SetTimer(onRun, 50)
    onRun() {
        static modifiers := ["Ctrl", "Alt", "Shift", "LWin", "RWin", "Shift"]
        for mod in modifiers {
            if GetKeyState(mod, "P")
                return
        }
        SetTimer(onRun, 0)
        stateText := IME.GetInputModeText()
        if (!stateText) {
            return
        }
        if (state == stateText) {
            return
        }
        if (stateText == "Caps") {
            if (var.keepCapsLockWhenStateSwitch) {
                return
            }
            SendInput("{CapsLock}")
            Sleep(50)
            stateText := IME.GetInputModeText()
            if (!stateText) {
                return
            }
            if (state == stateText) {
                return
            }
        } else if (state == "Caps") {
            SendInput("{CapsLock}")
            return
        }
        if (var.inputMethodSwitchState == "ime") {
            IME.SetInputMode(var.stateVal.%state%.id)
        } else {
            SendInput(var.inputMethodSwitchState)
        }
    }
}
