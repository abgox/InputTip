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

    static GuidStrategyMap := Map()
    static DefaultStrategyCN := { open: "oddNum", conv: "" }
    static StrategyMapCN := Map(
        "Microsoft Pinyin|Microsoft Wubi", { open: "", conv: "oddNum" },
        "小狼毫|Rime|小小输入法", { open: "", conv: "oddNum" },
        "小鹤音形", { open: "", conv: 1025 },
        "讯飞输入法", { open: 2, conv: "" },
    )

    static Initialize() {
        installedIME := this.GetInstalledIME()
        for configName, strategy in this.StrategyMapCN {
            names := StrSplit(configName, "|")
            for key, info in installedIME {
                for nameInConfig in names {
                    if InStr(info.name, nameInConfig) {
                        this.GuidStrategyMap[info.id] := strategy
                        break
                    }
                }
            }
        }
    }

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
                clsId := this.GetActiveIMEClsId()
                rule := (clsId != "" && this.GuidStrategyMap.Has(clsId)) ? this.GuidStrategyMap[clsId] : this.DefaultStrategyCN
                return lastState := (this.MatchRule(opened, rule.open) && this.MatchRule(convMode, rule.conv)) ? "CN" : "EN"
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
            stateMode: this.GetOpenStatus(hwnd),
            conversionMode: this.GetConversionMode(hwnd),
            clsId: this.GetActiveIMEClsId()
        }
    }

    /**
     * 切换到指定的输入法状态/布局
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

        clsId := this.GetActiveIMEClsId()
        rule := (clsId != "" && this.GuidStrategyMap.Has(clsId)) ? this.GuidStrategyMap[clsId] : this.DefaultStrategyCN
        if (targetState == "CN") {
            targetOpen := (rule.open == "oddNum" || rule.open == "evenNum") ? 1 : rule.open
            targetConv := (rule.conv == "oddNum" || rule.conv == "evenNum") ? this.LangMap["CN"].convMode : rule.conv
            if targetOpen !== ""
                this.SetOpenStatus(targetOpen, hwnd)
            if targetConv !== ""
                this.SetConversionMode(targetConv, hwnd)
        } else {
            if rule.open !== ""
                this.SetOpenStatus(0, hwnd)
            if rule.conv !== ""
                this.SetConversionMode(0, hwnd)
        }
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

    static GetActiveIMEClsId() {
        static currentThreadID := DllCall("GetCurrentThreadId", "uint")

        g := Gui()
        g.Show("Hide")

        imeThreadID := 0
        if imeHwnd := DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", g.Hwnd, "ptr")
            imeThreadID := DllCall("GetWindowThreadProcessId", "ptr", imeHwnd, "ptr", 0, "uint")
        if imeThreadID && imeThreadID != currentThreadID {
            try DllCall("AttachThreadInput", "uint", currentThreadID, "uint", imeThreadID, "int", 0)
            DllCall("AttachThreadInput", "uint", currentThreadID, "uint", imeThreadID, "int", 1)
        }

        currentClsId := ""
        ppv := 0
        ppMgr := 0
        try {
            CLSID := Buffer(16), IID_Unknown := Buffer(16), IID_Mgr := Buffer(16)
            DllCall("ole32\CLSIDFromString", "str", "{33C53A50-F456-4884-B049-85FD643ECFED}", "ptr", CLSID)
            DllCall("ole32\CLSIDFromString", "str", "{00000000-0000-0000-C000-000000000046}", "ptr", IID_Unknown)
            DllCall("ole32\CLSIDFromString", "str", "{71C6E74C-0F28-11D8-A82A-00065B84435C}", "ptr", IID_Mgr)

            if (DllCall("ole32\CoCreateInstance", "ptr", CLSID, "ptr", 0, "uint", 1, "ptr", IID_Unknown, "ptr*", &ppv, "int") == 0 && ppv) {
                vtable := NumGet(ppv, 0, "ptr")
                fn := NumGet(vtable, 0, "ptr")
                if (DllCall(fn, "ptr", ppv, "ptr", IID_Mgr, "ptr*", &ppMgr, "int") == 0 && ppMgr) {
                    catBuf := Buffer(16)
                    DllCall("ole32\CLSIDFromString", "str", "{34745C63-B2F0-4784-8B67-5E12C8701A31}", "ptr", catBuf)
                    profileBuf := Buffer(84, 0)
                    vtableMgr := NumGet(ppMgr, 0, "ptr")
                    fnGetActive := NumGet(vtableMgr, 10 * A_PtrSize, "ptr")
                    if (DllCall(fnGetActive, "ptr", ppMgr, "ptr", catBuf, "ptr", profileBuf, "int") == 0) {
                        pStr := 0
                        DllCall("ole32\StringFromCLSID", "ptr", profileBuf.Ptr + 8, "ptr*", &pStr)
                        currentClsId := StrUpper(StrGet(pStr, "UTF-16"))
                        DllCall("ole32\CoTaskMemFree", "ptr", pStr)
                    }
                }
            }
        } finally {
            if ppMgr
                ObjRelease(ppMgr)
            if ppv
                ObjRelease(ppv)

            g.Destroy()
        }
        return currentClsId
    }

    static GetInstalledIME() {
        imeMap := Map()
        paths := [
            "HKLM\SOFTWARE\Microsoft\CTF\TIP",
            "HKLM\SOFTWARE\WOW6432Node\Microsoft\CTF\TIP",
            "HKCU\SOFTWARE\Microsoft\CTF\TIP",
        ]

        for path in paths {
            Loop Reg, path, "VR" {
                val := RegRead()
                currentPath := A_LoopRegKey

                hkl := ""
                id := ""
                if currentPath ~= "i)\\LanguageProfile\\" && RegExMatch(currentPath, "i)\\TIP\\({[^}]+})\\LanguageProfile\\([^\\]+)", &match) {
                    id := StrUpper(match[1])
                    hkl := match[2]
                }

                if hkl == "" || id == "" || !(A_LoopRegName ~= "i)^(Description|Layout Text)$")
                    continue

                rawName := (Type(val) == "String" && val != "") ? val : hkl
                name := RegExReplace(rawName, "i).*\\")
                imeMap[hkl "|" id] := {
                    hkl: hkl,
                    id: id,
                    name: name
                }
            }
        }
        return imeMap
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
    if matchWindowRules(exeName, exeTitle, exeClass, var.WindowRule["ignoreKeyboardSwitch"]).Length
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
