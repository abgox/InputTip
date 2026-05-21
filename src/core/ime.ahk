; InputTip

/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk
 * @example
 * var.inputMethodDetectionTimeout := 200 ; 超时时间(单位：毫秒)
 * var.inputMethodDetectionRules := [] ; 状态规则
 * var.inputMethodBaseState := 0 ; 默认状态为英文
 */
class IME {
    static GetInputMode(hwnd := this.GetFocusedWindow()) {
        if !this.GetOpenStatus(hwnd) {
            return false
        }
        convMode := this.GetConversionMode(hwnd)
        if (convMode & 0x100) {  ; IME_CMODE_NOCONVERSION，强制英文
            return false
        }
        return convMode & 3  ; IME_CMODE_LANGUAGE，兼容日文
    }

    /**
     * 获取当前输入法输入模式
     * @returns {"CN"|"EN"|"Caps"|"JP"|"KR"}
     */
    static GetInputModeText(hwnd := this.GetFocusedWindow()) {
        if (GetKeyState("CapsLock", "T")) {
            return "Caps"
        }
        langID := this.GetKeyboardLayout(hwnd) & 0xFFFF
        switch langID {
            ; case 0x0404, 0x0804:  ; 繁体中文、简体中文
            case 0x0409:  ; 英文
                return "EN"
            case 0x0411:  ; 日文
                return "JP"
            case 0x0412:  ; 韩文
                return "KR"
        }

        langMap := Map(
            1, "CN",
            0, "EN",
        )
        opened := this.GetOpenStatus(hwnd)
        convMode := this.GetConversionMode(hwnd)

        ; 英文键盘布局时 opened 强制视为关闭
        if (opened && langID == 0x0409) {
            opened := false
        }

        ; IME_CMODE_NOCONVERSION：即使 opened 为 1 也视为英文
        if (convMode & 0x100) {
            opened := false
        }

        if (var.inputMethodDetectionMode == "general") {
            return langMap.Get(opened && (convMode & 3) ? 1 : 0)
        }

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

            if (matchRule(opened, sm) && matchRule(convMode, cm)) {
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
            if (ruleValue == "") {
                return 1
            }

            if (ruleValue == "evenNum") { ; 如果值是偶数
                isMatch := !(value & 1)
            } else if (ruleValue == "oddNum") { ; 如果值是奇数
                isMatch := value & 1
            } else {
                isMatch := InStr("/" ruleValue "/", "/" value "/")
            }
            return isMatch
        }

        return langMap.Get(baseState)
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
     * @param mode 要切换的指定输入法状态(1:中文，0:英文)
     */
    static SetInputMode(mode, hwnd := this.GetFocusedWindow()) {
        if mode {
            this.SetOpenStatus(true, hwnd)
            switch this.GetKeyboardLayout(hwnd) {
                case 0x08040804:
                    this.SetConversionMode(1025, hwnd)
                case 0x04110411:
                    this.SetConversionMode(9, hwnd)
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
        SendMessage(0x50, 1, hkl, hwnd)
    }

    static GetKeyboardLayoutList() {
        if cnt := DllCall("GetKeyboardLayoutList", "int", 0, "ptr", 0) {
            list := []
            buf := Buffer(cnt * A_PtrSize)
            loop DllCall("GetKeyboardLayoutList", "int", cnt, "ptr", buf) {
                list.Push(NumGet(buf, (A_Index - 1) * A_PtrSize, "ptr"))
            }
            return list
        }
    }

    static LoadKeyboardLayout(hkl) {
        return DllCall("LoadKeyboardLayoutW", "str", Format("{:08x}", hkl), "uint", 0x101)
    }

    static UnloadKeyboardLayout(hkl) {
        return DllCall("UnloadKeyboardLayout", "ptr", hkl)
    }

    static GetFocusedWindow() {
        if foreHwnd := WinExist("A") {
            guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48)
            NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
            DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", foreHwnd, "ptr", 0, "uint"), "ptr", guiThreadInfo)
            if focusedHwnd := NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") {
                return focusedHwnd
            }
            return foreHwnd
        }
        return 0
    }
}

/**
 * 切换输入法状态
 * @param {"CN"|"EN"|"Caps"} state 要切换的输入法状态
 */
switchState(state, pressKey := "", *) {
    if (!state) {
        return
    }
    if (validateMatch(exeName, exeTitle, var.WindowIgnoreStateSwitch)) {
        return
    }

    ; 当按下 shift + 任意键，取消切换
    if (pressKey && InStr(var.%"hotkey" state%, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (state != "Caps") {
        ; 预防热键本身就是 Shift 造成的冲突
        Sleep(50)
    }

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
