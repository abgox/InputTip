; InputTip

/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk
 * @Tip 有所修改，外部必须提供变量 checkTimeout,modeRule,defaultStatus
 * @example
 * checkTimeout := 1000 ; 超时时间(单位：毫秒)
 * modeRules := [] ; 状态规则
 * baseStatus := 0 ; 默认状态为英文
 * IME.GetInputMode() ; 获取当前输入法输入模式
 * IME.SetInputMode(!IME.GetInputMode()) ; 切换当前输入法输入模式
 */
class IME {
    static GetInputMode(hwnd := this.GetFocusedWindow()) {
        if (mode = 1) {
            if (!this.GetOpenStatus(hwnd)) {
                return 0
            }

            v := this.GetConversionMode(hwnd)
            return v & 1
        }

        defaultStatus := baseStatus

        ; 系统返回的状态码
        statusMode := this.GetOpenStatus(hwnd)
        ; 系统返回的切换码
        conversionMode := this.GetConversionMode(hwnd)

        for v in modeRules {
            r := StrSplit(v, "*")

            ; 状态码
            sm := r[1]
            ; 切换码
            cm := r[2]
            ; 状态
            status := r[3]

            ; 是否匹配
            isMatch := true

            if (matchRule(statusMode, sm) && matchRule(conversionMode, cm)) {
                ; 匹配成功
                defaultStatus := status
                break
            }
        }

        /**
         * 匹配规则
         * @param value 实际的值
         * @param ruleValue 规则的值
         * @returns
         */
        matchRule(value, ruleValue) {
            ; 规则为空，默认匹配成功
            if (ruleValue == "") {
                return 1
            } else {
                ; 是否是奇数
                isOdd := value & 1

                if (ruleValue == "evenNum") {
                    ; 如果状态码规则是偶数
                    isMatch := !isOdd
                } else if (ruleValue == "oddNum") {
                    ; 如果状态码规则是奇数
                    isMatch := isOdd
                } else {
                    str := "/" value "/"
                    isMatch := InStr(str, "/" ruleValue "/")
                }
                return isMatch
            }
        }

        return defaultStatus
    }

    static CheckInputMode(hwnd := this.GetFocusedWindow()) {
        return {
            statusMode: this.GetOpenStatus(hwnd),
            conversionMode: this.GetConversionMode(hwnd)
        }
    }

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
 * @returns {Boolean} 输入法是否为中文
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
 * @Tip 外部必须提供变量 useShift(是否使用 Shift 切换输入法状态)
 * @example
 * SetStoreCapsLockMode 0 ; 前置条件，确保大写锁定可切换
 * ; ...
 * switch_CN()
 */
switch_CN(pressKey := "", *) {
    ; 当按下 shift + 任意键，取消强制切换
    if (pressKey && InStr(hotkey_CN, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
    if (!useShift) {
        if (isCN()) {
            IME.SetInputMode(1)
        }
    }
    Sleep(50)
    if (!isCN()) {
        SendInput("{LShift}")
        Sleep(50)
        if (!isCN()) {
            SendInput("{RShift}")
        }
    }
}
/**
 * 将输入法状态切换为英文
 * @param pressKey 触发此函数的按键，如果非按键触发，则为空
 * @Tip 外部必须提供变量 useShift(是否使用 Shift 切换输入法状态)
 * @example
 * SetStoreCapsLockMode 0 ; 前置条件，确保大写锁定可切换
 * ; ...
 * switch_EN()
 */
switch_EN(pressKey := "", *) {
    ; 当按下 shift + 任意键，取消强制切换
    if (pressKey && InStr(hotkey_EN, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
    if (!useShift) {
        if (isCN()) {
            IME.SetInputMode(0)
        }
    }
    Sleep(50)
    if (isCN()) {
        SendInput("{LShift}")
        Sleep(50)
        if (isCN()) {
            SendInput("{RShift}")
        }
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
    ; 当按下 shift + 任意键，取消强制切换
    if (pressKey && InStr(hotkey_Caps, "shift") && A_TimeIdleKeyboard < 200 && !InStr(A_PriorKey, "shift")) {
        return
    }
    if (!GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
}
