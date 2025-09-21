; InputTip

/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk
 * @Tip 有所修改，外部必须提供变量 checkTimeout,modeRule,baseStatus
 * @example
 * checkTimeout := 1000 ; 超时时间(单位：毫秒)
 * modeRules := [] ; 状态规则
 * baseStatus := 0 ; 默认状态为英文
 * IME.GetInputMode() ; 获取当前输入法输入模式
 * IME.SetInputMode(!IME.GetInputMode()) ; 切换当前输入法输入模式
 */
class IME {
    /**
     * 获取当前输入法输入模式
     * @param hwnd
     * @returns {1 | 0} 1:中文，0:英文
     */
    static GetInputMode(hwnd := this.GetFocusedWindow()) {
        if (mode = 1) {
            if (!this.GetOpenStatus(hwnd)) {
                return 0
            }
            return this.GetConversionMode(hwnd) & 1
        }

        ; 存储默认状态，如果都不匹配，就返回预先指定的默认状态
        status := baseStatus

        ; 系统返回的状态码
        statusMode := this.GetOpenStatus(hwnd)
        ; 系统返回的切换码
        conversionMode := this.GetConversionMode(hwnd)

        for v in modeRules {
            r := StrSplit(v, "*")

            ; 状态码规则
            sm := r[1]
            ; 切换码规则
            cm := r[2]
            ; 匹配状态
            s := r[3]

            if (matchRule(statusMode, sm) && matchRule(conversionMode, cm)) {
                ; 匹配成功
                status := s
                break
            }
        }

        /**
         * 匹配规则
         * @param value 系统返回的状态值
         * @param ruleValue 规则定义的状态值
         * @returns {1 | 0} 是否匹配成功
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
        return status
    }

    /**
     * 系统返回的状态码和切换码
     * @param hwnd
     * @returns {Object} 系统返回的状态码和切换码
     */
    static CheckInputMode(hwnd := this.GetFocusedWindow()) {
        return {
            statusMode: this.GetOpenStatus(hwnd),
            conversionMode: this.GetConversionMode(hwnd)
        }
    }

    /**
     * 切换到指定的输入法状态
     * @param mode 要切换的指定输入法状态(1:中文，0:英文)
     * @param hwnd
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
            DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x5, "ptr", 0, "uint", 0, "uint", checkTimeout, "ptr*", &status := 0)
            return status
        } catch {
            return 0
        }
    }

    static SetOpenStatus(status, hwnd := this.GetFocusedWindow()) {
        try {
            DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x6, "ptr", status, "uint", 0, "uint", checkTimeout, "ptr*", 0)
        }
    }

    static GetConversionMode(hwnd := this.GetFocusedWindow()) {
        try {
            DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x1, "ptr", 0, "uint", 0, "uint", checkTimeout, "ptr*", &mode := 0)
            return mode
        } catch {
            return 0
        }
    }

    static SetConversionMode(mode, hwnd := this.GetFocusedWindow()) {
        try {
            DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x2, "ptr", mode, "uint", 0, "uint", checkTimeout, "ptr*", 0)
        }
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
 * 判断当前输入法状态是否为中文
 * @returns {1 | 0} 输入法是否为中文
 * @example
 * DetectHiddenWindows 1 ; 前置条件(不为1，可能判断有误)
 * ;...
 * MsgBox isCN()
 */
isCN() {
    return IME.GetInputMode()
}

/**
 * 将输入法状态切换为中文
 * @param pressKey 触发此函数的按键，如果非按键触发，则为空
 * @example
 * SetStoreCapsLockMode 0 ; 前置条件，确保大写锁定可切换
 * ; ...
 * switch_CN()
 */
switch_CN(pressKey := "", *) {
    ; 当按下 shift + 任意键，取消切换
    if (pressKey && InStr(hotkey_CN, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
    Sleep(50)
    if (switchStatus) {
        if (!isCN()) {
            SendInput(switchStatusList[switchStatus])
        }
    } else {
        IME.SetInputMode(1)
    }
}
/**
 * 将输入法状态切换为英文
 * @param pressKey 触发此函数的按键，如果非按键触发，则为空
 * @example
 * SetStoreCapsLockMode 0 ; 前置条件，确保大写锁定可切换
 * ; ...
 * switch_EN()
 */
switch_EN(pressKey := "", *) {
    ; 当按下 shift + 任意键，取消切换
    if (pressKey && InStr(hotkey_EN, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
    Sleep(50)
    if (switchStatus) {
        if (isCN()) {
            SendInput(switchStatusList[switchStatus])
        }
    } else {
        IME.SetInputMode(0)
    }
}
/**
 * 将输入法状态切换为大写锁定
 * @param pressKey 触发此函数的按键，如果非按键触发，则为空
 * @example
 * SetStoreCapsLockMode 0 ; 前置条件，确保大写锁定可切换
 * ; ...
 * switch_Caps()
 */
switch_Caps(pressKey := "", *) {
    ; 当按下 shift + 任意键，取消切换
    if (pressKey && InStr(hotkey_Caps, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (!GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
}
