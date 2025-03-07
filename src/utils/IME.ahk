/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/IME.ahk
 * @Tip 有所修改，外部必须提供变量 checkTimeout,baseStatus,statusMode,conversionMode,evenStatusMode,evenConversionMode
 * @example
 * checkTimeout := 1000 ; 超时时间(单位：毫秒)
 * baseStatus := 0 ; 以英文状态作为判断依据
 * statusMode := 0 ; 状态码
 * conversionMode := 0 ; 转换码
 * evenStatusMode := "" ; 状态码规则
 * evenConversionMode := "" ; 转换码规则
 * IME.GetInputMode() ; 获取当前输入法输入模式
 * IME.SetInputMode(!IME.GetInputMode()) ; 切换当前输入法输入模式
 */
class IME {
    static GetInputMode(hwnd := this.GetFocusedWindow()) {
        if (statusMode = "" && evenStatusMode = "" && conversionMode = "" && evenConversionMode = "") {
            if (!this.GetOpenStatus(hwnd)) {
                return {
                    code: 0,
                    isCN: 0
                }
            }

            v := this.GetConversionMode(hwnd)
            return {
                code: v,
                isCN: v & 1
            }
        }

        ; 切换码
        v := this.GetConversionMode(hwnd)
        flag := v & 1

        if (baseStatus) {
            if (evenConversionMode != "") {
                return {
                    code: v,
                    isCN: evenConversionMode ? !flag : flag
                }
            }
            if (conversionMode != "") {
                return {
                    code: v,
                    isCN: InStr(conversionMode, ":" v ":")
                }
            }
        } else {
            if (evenConversionMode != "") {
                return {
                    code: v,
                    isCN: evenConversionMode ? flag : !flag
                }
            }
            if (conversionMode != "") {
                return {
                    code: v,
                    isCN: !(InStr(conversionMode, ":" v ":"))
                }
            }
        }

        ; 状态码
        v := this.GetOpenStatus(hwnd)
        flag := v & 1

        if (baseStatus) {
            if (evenStatusMode != "") {
                return {
                    code: v,
                    isCN: evenStatusMode ? !flag : flag
                }
            }
            if (statusMode != "") {
                return {
                    code: 0,
                    isCN: InStr(statusMode, ":" v ":")
                }
            }
        } else {
            if (evenStatusMode != "") {
                return {
                    code: v,
                    isCN: evenStatusMode ? flag : !flag
                }
            }
            if (statusMode != "") {
                return {
                    code: 0,
                    isCN: !(InStr(statusMode, ":" v ":"))
                }
            }
        }
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
    return IME.GetInputMode().isCN
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
