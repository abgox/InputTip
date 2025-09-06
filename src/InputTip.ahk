; InputTip

#Warn All, Off

#Include utils/verify-file.ahk

#Include "*i utils/options.ahk"

;@AHK2Exe-SetName InputTip
;@Ahk2Exe-SetOrigFilename InputTip.ahk
;@Ahk2Exe-UpdateManifest 1
;@AHK2Exe-SetDescription InputTip - 一个输入法状态管理工具(提示/切换)

isJAB := 0

#Include "*i utils/tools.ahk"
#Include "*i utils/create-gui.ahk"
#Include "*i utils/ini.ahk"
#Include "*i utils/IME.ahk"
#Include "*i utils/app-list.ahk"
#Include "*i utils/hotkey-gui.ahk"
#Include "*i menu/tray-menu.ahk"
#Include "*i utils/var.ahk"
#Include "*i utils/check-version.ahk"

if (A_IsCompiled) {
    favicon := A_ScriptFullPath
} else {
    favicon := A_ScriptDir "\img\favicon.ico"
    if (runCodeWithAdmin && !A_IsAdmin) {
        try {
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '" ' keyCount
        } catch {
            createTipGui([{
                opt: "cRed",
                text: "以管理员权限启动 InputTip 失败",
            }], "InputTip - 错误").Show()
            writeIni("runCodeWithAdmin", 0)
            global runCodeWithAdmin := 0
        }
    }
}

checkUpdateDone()

checkIni()

checkUpdate(1)

if (hotkey_CN) {
    try {
        Hotkey(hotkey_CN, switch_CN)
    }
}
if (hotkey_EN) {
    try {
        Hotkey(hotkey_EN, switch_EN)
    }
}
if (hotkey_Caps) {
    try {
        Hotkey(hotkey_Caps, switch_Caps)
    }
}
if (hotkey_Pause) {
    try {
        Hotkey(hotkey_Pause, pauseApp)
    }
}
if (hotkey_ShowCode) {
    try {
        Hotkey(hotkey_ShowCode, showCode)
    }
}

enableKeyCount := readIni("enableKeyCount", 0)
trayTipTemplate := readIni("trayTipTemplate", "【%appState%中】" fileDesc)
keyCountTemplate := readIni("keyCountTemplate", "%\n%【统计中】启动以来, 有效的按键输入次数: %keyCount%")
A_IconTip := StrReplace(trayTipTemplate, "%appState%", A_IsPaused ? "暂停" : "运行")

updateTip()

updateTip(flag := "") {
    if (enableKeyCount) {
        if (flag != "") {
            tip := StrReplace(trayTipTemplate keyCountTemplate, "%appState%", flag ? "暂停" : "运行")
            tip := StrReplace(tip, "%keyCount%", keyCount)
            tip := StrReplace(tip, "%\n%", "`n")
            A_IconTip := tip
            return
        }
        SetTimer(countTimer, 50)
        countTimer() {
            static last := ""
            global keyCount
            if (!enableKeyCount) {
                SetTimer(, 0)
                last := ""
                return
            }
            if (A_PriorKey != last) {
                keyCount++
                last := A_PriorKey
                tip := StrReplace(trayTipTemplate keyCountTemplate, "%appState%", A_IsPaused ? "暂停" : "运行")
                tip := StrReplace(tip, "%keyCount%", keyCount)
                tip := StrReplace(tip, "%\n%", "`n")
                A_IconTip := tip
            }
        }
    } else {
        s := flag != "" ? flag : A_IsPaused
        tip := StrReplace(trayTipTemplate, "%appState%", s ? "暂停" : "运行")
        tip := StrReplace(tip, "%\n%", "`n")
        A_IconTip := tip
    }
}

symbolPaths := readIni("symbolPaths", "")
iconPaths := readIni("iconPaths", "")
cursorDir := readIni("cursorDir", "")

SetTimer(getPathList, -1)
getPathList() {
    _symbolPaths := arrJoin(getPicList(), ":")
    _iconPaths := arrJoin(getPicList(":InputTipSymbol\default\favicon.png:InputTipSymbol\default\favicon-pause.png:", ":InputTipSymbol\default\Caps.png:InputTipSymbol\default\EN.png:InputTipSymbol\default\CN.png:"), ":")
    _cursorDir := arrJoin(getCursorDir(), ":")
    if (symbolPaths != _symbolPaths) {
        global symbolPaths := _symbolPaths
        writeIni("symbolPaths", _symbolPaths)
    }
    if (iconPaths != _iconPaths) {
        global iconPaths := _iconPaths
        writeIni("iconPaths", _iconPaths)
    }
    if (cursorDir != _cursorDir) {
        global cursorDir := _cursorDir
        writeIni("cursorDir", _cursorDir)
    }
}

makeTrayMenu() ; 生成托盘菜单


/**
 * 跳过 JAB/JetBrains IDE 程序，交由 InputTip.JAB 处理
 * @param exe_str 进程字符串，如 ":webstorm64.exe:"
 * @returns {1 | 0} 是否需要跳过
 */
needSkip(exe_str) {
    return !showCursorPos && InStr(modeList.JAB, exe_str)
}

returnCanShowSymbol(&left, &top, &right, &bottom) {
    res := 0

    try {
        res := GetCaretPosEx(&left, &top, &right, &bottom)
    } catch {
        left := 0, top := 0, right := 0, bottom := 0
        return 0
    }

    s := isWhichScreen(screenList)
    if (s.num) {
        try {
            offset := app_offset_screen.%s.num%
            left += offset.x
            top += offset.y
        }
        try {
            offset := app_offset.%exe_name exe_title%.%s.num%
            left += offset.x
            top += offset.y
        } catch {
            try {
                left += app_offset.%exe_name%.%s.num%.x
                top += app_offset.%exe_name%.%s.num%.y
            }
        }
        return res && left
    }

    return 0
}


/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/GetCaretPosEx/GetCaretPosEx.ahk
 */
GetCaretPosEx(&left?, &top?, &right?, &bottom?) {
    try {
        DllCall("SetThreadDpiAwarenessContext", "ptr", -2, "ptr")
    }
    hwnd := getHwnd()

    if (InStr(modeList.HOOK, exe_str)) {
        return getCaretPosFromHook(0)
    }
    else if (InStr(modeList.UIA, exe_str)) {
        return getCaretPosFromUIA()
    }
    else if (InStr(modeList.GUI_UIA, exe_str)) {
        if (getCaretPosFromGui(&hwnd := 0)) {
            return 1
        }
        return getCaretPosFromUIA()
    }
    else if (InStr(modeList.MSAA, exe_str)) {
        return getCaretPosFromMSAA()
    }
    else if (InStr(modeList.Hook_DLL, exe_str)) {
        return getCaretPosFromHook(1)
    }
    else if (InStr(modeList.WPF, exe_str)) {
        return getCaretPosFromWpfCaret()
    }
    else if (InStr(modeList.ACC, exe_str)) {
        return getCaretPosFromACC()
    }
    else {
        if (getCaretPosFromGui(&hwnd := 0)) {
            return 1
        }
        if (getCaretPosFromHook(0)) {
            return 1
        }
        functions := [getCaretPosFromMSAA, getCaretPosFromUIA]
        for fn in functions {
            if (fn()) {
                return 1
            }
        }
    }
    return 0

    getHwnd(hwnd := 0) {
        x64 := A_PtrSize == 8
        guiThreadInfo := Buffer(x64 ? 72 : 48)
        NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
            hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
        }
        return hwnd
    }

    getCaretPosFromGui(&hwnd) {
        x64 := A_PtrSize == 8
        guiThreadInfo := Buffer(x64 ? 72 : 48)
        NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
            if hwnd := NumGet(guiThreadInfo, x64 ? 48 : 28, "ptr") {
                getRect(guiThreadInfo.Ptr + (x64 ? 56 : 32), &left, &top, &right, &bottom)
                scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
                clientToScreenRect(hwnd, &left, &top, &right, &bottom)
                return true
            }
            hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
        }
        return false
    }

    getCaretPosFromMSAA() {
        if !hOleacc := DllCall("LoadLibraryW", "str", "oleacc.dll", "ptr")
            return false
        hOleacc := { Ptr: hOleacc, __Delete: (_) => DllCall("FreeLibrary", "ptr", _) }
        static IID_IAccessible := guidFromString("{618736e0-3c3d-11cf-810c-00aa00389b71}")
        if !DllCall("oleacc\AccessibleObjectFromWindow", "ptr", hwnd, "uint", 0xfffffff8, "ptr", IID_IAccessible, "ptr*", accCaret := ComValue(13, 0), "int") {
            if A_PtrSize == 8 {
                varChild := Buffer(24, 0)
                NumPut("ushort", 3, varChild)
                hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int")
            }
            else {
                hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "int64", 3, "int64", 0, "int")
            }
            if !hr {
                pt := x | y << 32
                DllCall("ScreenToClient", "ptr", hwnd, "int64*", &pt)
                left := pt & 0xffffffff
                top := pt >> 32
                right := left + w
                bottom := top + h
                scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
                clientToScreenRect(hwnd, &left, &top, &right, &bottom)
                return true
            }
        }
        return false
    }

    getCaretPosFromUIA() {
        try {
            uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
            ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
            if !cacheRequest.Ptr
                return false
            ComCall(4, cacheRequest, "ptr", 10014) ; cacheRequest->AddPattern(UIA_TextPatternId);
            ComCall(4, cacheRequest, "ptr", 10024) ; cacheRequest->AddPattern(UIA_TextPattern2Id);

            ComCall(12, uia, "ptr", cacheRequest, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElementBuildCache(cacheRequest, &focusedEle);
            if !focusedEle.Ptr
                return false

            static IID_IUIAutomationTextPattern2 := guidFromString("{506a921a-fcc9-409f-b23b-37eb74106872}")
            range := ComValue(13, 0)
            ComCall(15, focusedEle, "int", 10024, "ptr", IID_IUIAutomationTextPattern2, "ptr*", textPattern := ComValue(13, 0)) ; focusedEle->GetCachedPatternAs(UIA_TextPattern2Id, IID_PPV_ARGS(&textPattern));
            if textPattern.Ptr {
                ComCall(10, textPattern, "int*", &isActive := 0, "ptr*", range) ; textPattern->GetCaretRange(&isActive, &range);
                if range.Ptr
                    goto getRangeInfo
            }
            ; If no caret range, get selection range.
            static IID_IUIAutomationTextPattern := guidFromString("{32eba289-3583-42c9-9c59-3b6d9a1e9b6a}")
            ComCall(15, focusedEle, "int", 10014, "ptr", IID_IUIAutomationTextPattern, "ptr*", textPattern) ; focusedEle->GetCachedPatternAs(UIA_TextPatternId, IID_PPV_ARGS(&textPattern));
            if textPattern.Ptr {
                ComCall(5, textPattern, "ptr*", ranges := ComValue(13, 0)) ; textPattern->GetSelection(&ranges);
                if ranges.Ptr {
                    ; Retrieve the last selection range.
                    ComCall(3, ranges, "int*", &len := 0) ; ranges->get_Length(&len);
                    if len > 0 {
                        ComCall(4, ranges, "int", len - 1, "ptr*", range) ; ranges->GetElement(len - 1, &range);
                        if range.Ptr {
                            ; Collapse the range.
                            ComCall(15, range, "int", 0, "ptr", range, "int", 1) ; range->MoveEndpointByRange(TextPatternRangeEndpoint_Start, range, TextPatternRangeEndpoint_End);
                            goto getRangeInfo
                        }
                    }
                }
            }
            return false
getRangeInfo:
            psa := 0
            ; This is a degenerate text range, we have to expand it.
            ComCall(6, range, "int", 0) ; range->ExpandToEnclosingUnit(TextUnit_Character);
            ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
            if psa {
                rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
                if rects.MaxIndex() >= 3 {
                    rects[2] := 0
                    goto end
                }
            }
            ; ExpandToEnclosingUnit by character may be invalid in some control if the range is at the end of the document.
            ; Assume that the range is at the end of the document and not in an empty line, try to expand it by line.
            ComCall(6, range, "int", 3) ; range->ExpandToEnclosingUnit(TextUnit_Line)
            ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
            if psa {
                rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
                if rects.MaxIndex() >= 3 {
                    ; Here rects is {x, y, w, h}, we take the end endpoint as the caret position.
                    rects[0] := rects[0] + rects[2]
                    rects[2] := 0
                    goto end
                }
            }
            return false
end:
            left := Round(rects[0])
            top := Round(rects[1])
            right := left + Round(rects[2])
            bottom := top + Round(rects[3])
            return true
        }
        return false
    }

    getCaretPosFromWpfCaret() {
        try {
            uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
            ComCall(8, uia, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElement(&focusedEle);
            if !focusedEle.Ptr
                return false

            ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
            if !cacheRequest.Ptr
                return false

            ComCall(17, uia, "ptr*", rawViewCondition := ComValue(13, 0)) ; uia->get_RawViewCondition(&rawViewCondition);
            if !rawViewCondition.Ptr
                return false

            ComCall(9, cacheRequest, "ptr", rawViewCondition) ; cacheRequest->put_TreeFilter(rawViewCondition);
            ComCall(3, cacheRequest, "int", 30001) ; cacheRequest->AddProperty(UIA_BoundingRectanglePropertyId);

            var := Buffer(24, 0)
            ref := ComValue(0x400C, var.Ptr)
            ref[] := ComValue(8, "WpfCaret")
            ComCall(23, uia, "int", 30012, "ptr", var, "ptr*", condition := ComValue(13, 0)) ; uia->CreatePropertyCondition(UIA_ClassNamePropertyId, CComVariant(L"WpfCaret"), &classNameCondition);
            if !condition.Ptr
                return false

            ComCall(7, focusedEle, "int", 4, "ptr", condition, "ptr", cacheRequest, "ptr*", wpfCaret := ComValue(13, 0)) ; focusedEle->FindFirstBuildCache(TreeScope_Descendants, condition, cacheRequest, &wpfCaret);
            if !wpfCaret.Ptr
                return false

            ComCall(75, wpfCaret, "ptr", rect := Buffer(16)) ; wpfCaret->get_CachedBoundingRectangle(&rect);
            getRect(rect, &left, &top, &right, &bottom)
            return true
        }
        return false
    }

    getCaretPosFromHook(flag) {
        static WM_GET_CARET_POS := DllCall("RegisterWindowMessageW", "str", "WM_GET_CARET_POS", "uint")
        if !tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr*", &pid := 0, "uint")
            return false
        if (flag) {
            ; ! 有兼容性问题的 dll 调用，部分应用会因为它触发意外错误
            ; ! 如: 崩溃，自动复制/输入/删除/等
            ; Update caret position
            try {
                SendMessage(0x010f, 0, 0, hwnd) ; WM_IME_COMPOSITION
            }
        }
        ; PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ
        if !hProcess := DllCall("OpenProcess", "uint", 1082, "int", false, "uint", pid, "ptr")
            return false
        hProcess := { Ptr: hProcess, __Delete: (_) => DllCall("CloseHandle", "ptr", _) }

        isX64 := isX64Process(hProcess)
        if isX64 && A_PtrSize == 4
            return false
        if !moduleBaseMap := getModulesBases(hProcess, ["kernel32.dll", "user32.dll", "combase.dll"])
            return false
        if isX64 {
            static shellcode64 := compile(true)
            shellcode := shellcode64
        }
        else {
            static shellcode32 := compile(false)
            shellcode := shellcode32
        }
        if !mem := DllCall("VirtualAllocEx", "ptr", hProcess, "ptr", 0, "ptr", shellcode.Size, "uint", 0x1000, "uint", 0x40, "ptr")
            return false
        mem := { Ptr: mem, __Delete: (_) => DllCall("VirtualFreeEx", "ptr", hProcess, "ptr", _, "uptr", 0, "uint", 0x8000) }
        link(isX64, shellcode, mem.Ptr, moduleBaseMap["user32.dll"], moduleBaseMap["combase.dll"], hwnd, tid, WM_GET_CARET_POS, &pThreadProc, &pRect)

        if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", mem, "ptr", shellcode, "uptr", shellcode.Size, "ptr", 0)
            return false
        DllCall("FlushInstructionCache", "ptr", hProcess, "ptr", mem, "uptr", shellcode.Size)

        if !hThread := DllCall("CreateRemoteThread", "ptr", hProcess, "ptr", 0, "uptr", 0, "ptr", pThreadProc, "ptr", mem, "uint", 0, "uint*", &remoteTid := 0, "ptr")
            return false
        hThread := { Ptr: hThread, __Delete: (_) => DllCall("CloseHandle", "ptr", _) }

        if msgWaitForSingleObject(hThread)
            return false
        if !DllCall("GetExitCodeThread", "ptr", hThread, "uint*", exitCode := 0) || exitCode !== 0
            return false

        rect := Buffer(16)
        if !DllCall("ReadProcessMemory", "ptr", hProcess, "ptr", pRect, "ptr", rect, "uptr", rect.Size, "uptr*", &bytesRead := 0) || bytesRead !== rect.Size
            return false
        getRect(rect, &left, &top, &right, &bottom)
        scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
        return true

        static isX64Process(hProcess) {
            DllCall("IsWow64Process", "ptr", hProcess, "int*", &isWow64 := 0)
            if isWow64
                return false
            if A_PtrSize == 8
                return true
            DllCall("IsWow64Process", "ptr", DllCall("GetCurrentProcess", "ptr"), "int*", &isWow64)
            return isWow64
        }

        static getModulesBases(hProcess, modules) {
            hModules := Buffer(A_PtrSize * 350)
            if !DllCall("K32EnumProcessModulesEx", "ptr", hProcess, "ptr", hModules, "uint", hModules.Size, "uint*", &needed := 0, "uint", 3)
                return
            moduleBaseMap := Map()
            moduleBaseMap.CaseSense := false
            for v in modules
                moduleBaseMap[v] := 0
            cnt := modules.Length
            loop Min(350, needed) {
                hModule := NumGet(hModules, A_PtrSize * (A_Index - 1), "ptr")
                VarSetStrCapacity(&name, 12)
                if DllCall("K32GetModuleBaseNameW", "ptr", hProcess, "ptr", hModule, "str", &name, "uint", 13) {
                    if moduleBaseMap.Has(name) {
                        moduleInfo := Buffer(24)
                        if !DllCall("K32GetModuleInformation", "ptr", hProcess, "ptr", hModule, "ptr", moduleInfo, "uint", moduleInfo.Size)
                            return
                        if !base := NumGet(moduleInfo, "ptr")
                            return
                        moduleBaseMap[name] := base
                        cnt--
                    }
                }
            } until cnt == 0
            if cnt == 0
                return moduleBaseMap
        }

        static compile(x64) {
            if x64
                shellcodeBase64 := "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABrnppSh2UjT6uenH1oPjxQAeiAqiEg0hGT4ABgsGe4blNldFdpbmRvd3NIb29rRXhXAAAAVW5ob29rV2luZG93c0hvb2tFeABDYWxsTmV4dEhvb2tFeAAAAAAAAFNlbmRNZXNzYWdlVGltZW91dFcAQ29DcmVhdGVJbnN0YW5jZQAAAAAAAAAASIlcJAhIiXQkEFdIg+wgSYvYSIvyi/mFyXgjSIXbdB6LBQb///9BOUAQdRJIjQ3d/v//6JgBAACJBfL+//9Iiw3L/v//SI0VdP///+jnAgAASIXAdRBIi1wkMEiLdCQ4SIPEIF/DTIvLTIvGi9czyUiLXCQwSIt0JDhIg8QgX0j/4MzMzMzMzDPAw8zMzMzMQFNWSIPsSIvySIvZSIXJdQy4VwAHgEiDxEheW8NIi0kISI1UJGBIiVQkKEG4/////0iNVCQwSIl8JEAz/0iJVCQgiXwkYIvWSIsBRI1PAf9QKIXAeHJIOXwkMHRrOXwkYHRlSItLCEiNVCR4SIl8JHhIiwH/UEiL+IXAeDJIi0wkeEiFyXQoSIsBSI1UJHBMi0QkMEyNSxBIiVQkIIvW/1AgSItMJHiL+EiLAf9QEEiLTCQwSIsB/1AQi8dIi3wkQEiDxEheW8NIi3wkQLgBAAAASIPESF5bw8zMzMzMzMxIhcl0VEiF0nRPTYXAdEpIiwJIhcB1HUi4wAAAAAAAAEZIOUIIdCxJxwAAAAAAuAJAAIDDSbkD6ICqISDSEUk7wXXkSLiT4ABgsGe4bkg5Qgh11EmJCDPAw7hXAAeAw8xAU0iD7EBIi9lIjZHYAAAASItJCOhPAQAASIXAdQu4AQAAAEiDxEBbwzPJx0QkWAEAAABIjVQkaEiJTCRoSIlUJCBMjUt4M9JIiUwkYEiJTCQwiUwkUEiNS2hEjUIX/9CFwA+I7wAAAEiLTCRoSIXJD4ThAAAASIsBSI1UJFD/UBiFwA+IhQAAAEiLTCRoSI1UJGBIiwH/UDiFwHhxSItMJGBIhcl0bEiLAUiNVCQw/1AwhcB4WEiLTCQwSIXJdGZIjUNISIlLMEiJQyhMjUMoSI0Vyf7//0G5AwAAAEiJEEiNBdH9//9IiUNQSI1UJFhIiUNYSI0Fxf3//0iJQ2BIiwFIiVQkIItUJFD/UBhIi0wkYEiLVCQwSIXSdA5IiwJIi8r/UBBIi0wkYEiFyXQGSIsB/1AQSItMJGhIhcl0BkiLAf9QEItEJFj32BvAg+AESIPEQFvDuAQAAABIg8RAW8PMzMzMzMxIiVwkCEiJbCQQSIl0JBhIiXwkIEyL2kyL0UiFyXRwSIXSdGtIY0E8g7wIjAAAAAB0XYuMCIgAAACFyXRSRYtMCiBJjQQKi3AkTQPKi2gcSQPyi3gYSQPqD7YaRTPA/89BixFJA9I6GnUZD7bLSYvDSSvThMl0Lw+2SAFI/8A6DAJ08EH/wEmDwQREO8d20TPASItcJAhIi2wkEEiLdCQYSIt8JCDDSWPAD7cMRotEjQBJA8Lr28zMSIlcJAhIiWwkEEiJdCQYSIl8JCBBVkiD7EBIixlIjZGIAAAASIv5SIvL6Bn///9IjZfEAAAASIvLSIvw6Af///9IjZecAAAASIvLSIvo6PX+//9Mi/BIhfZ0ZUiF7XRgSIXAdFtEi08YSI0VoPv//0UzwEGNSAT/1kiL8EiFwHUFjUYC6z+LVxwzwEiLTxBFM8lIiUQkMEUzwMdEJCjIAAAAiUQkIP/VSIvOSIvYQf/WSIXbdQWNQwPrCotHIOsFuAEAAABIi1wkUEiLbCRYSIt0JGBIi3wkaEiDxEBBXsM="
            else
                shellcodeBase64 := "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGuemlKHZSNPq56cfWg+PFAB6ICqISDSEZPgAGCwZ7huU2V0V2luZG93c0hvb2tFeFcAAABVbmhvb2tXaW5kb3dzSG9va0V4AENhbGxOZXh0SG9va0V4AAAAAAAAU2VuZE1lc3NhZ2VUaW1lb3V0VwBDb0NyZWF0ZUluc3RhbmNlAAAAAFZX6MkCAACDfCQMAIvwi3wkFHwYhf90FItPCDtOEHUMVuhqAQAAg8QEiUYUjYaIAAAAUP826J4CAACDxAiFwHUFX17CDABX/3QkFP90JBRqAP/QX17CDAAzwMIEAMzMzIPsFFaLdCQchfZ1DLhXAAeAXoPEFMIIAItOBI1UJARSjVQkEMdEJAgAAAAAUosBagFq//90JDBR/1AUhcB4bIN8JAwAdGWDfCQEAHRei04EjVQkHFfHRCQgAAAAAFKLAVH/UCSL+IX/eC2LVCQghdJ0JYsCi0gQjUQkDFCNRghQ/3QkGP90JDBS/9GL+ItEJCBQiwj/UQiLRCQQUIsI/1EIi8dfXoPEFMIIALgBAAAAXoPEFMIIAMyLTCQIVot0JAiF9nRfhcl0W4tUJBCF0nRTiwELQQR1IYF5CMAAAAB1CYF5DAAAAEZ0MscCAAAAALgCQACAXsIMAIE5A+iAqnXpgXkEISDSEXXggXkIk+AAYHXXgXkMsGe4bnXOiTIzwF7CDAC4VwAHgF7CDADMzMyD7BBWi3QkGI2GsAAAAFD/dgToMQEAAIvIg8QIhcl1CI1BAV6DxBDDjUQkBMdEJAQAAAAAUI1GUMdEJBwAAAAAUGoXagCNRkDHRCQYAAAAAFDHRCQgAAAAAMdEJCQBAAAA/9GFwA+IywAAAItMJASFyQ+EvwAAAIsBjVQkDFdSUf9QDIXAeHCLTCQIjVQkHFJRiwH/UByFwHhdi0wkHIXJdFmLAY1UJAxSUf9QGIXAeEaLfCQMhf90UI1OMIl+HLjcAQAAiU4YA8aNVhiJAYvGBRwBAACNTCQUUYlGNIlGOLgkAQAAagMDxlL/dCQciUY8iwdX/1AMi0wkHItUJAyF0nQKiwJS/1AIi0wkHF+FyXQGiwFR/1AIi0wkBIXJdAaLAVH/UAiLRCQQ99heG8CD4ASDxBDDuAQAAABeg8QQw7gAAAAAw8zMg+wIU1VWV4t8JByF/w+EgQAAAItcJCCF23R5i0c8g3w4fAB0b4tEOHiFwHRni0w4JDP2i1Q4IAPPi2w4GAPXiUwkEItMOBwDz4lUJByJTCQUTYorixSyA9c6KnUTis2LwyvThMl0FIpIAUA6DAJ080Y79Xcfi1QkHOvZi0QkEItMJBQPtwRwiwSBA8dfXl1bg8QIw19eXTPAW4PECMPMzFNVVleLfCQUizeNR2BQVuhM////iUQkHI2HnAAAAFBW6Dv///+L2I1HdFBW6C////+LTCQsg8QYi+iFyXRshdt0aIXtdGSLxwWUAwAAiXgBuMQAAAD/dwwDx2oAUGoE/9GJRCQUhcB1DF9eXbgCAAAAW8IEAGoAaMgAAABqAGoAagD/dxD/dwj/0/90JBSL8P/VhfZ1Cl+NRgNeXVvCBACLRxRfXl1bwgQAX15duAEAAABbwgQA"
            len := StrLen(shellcodeBase64)
            shellcode := Buffer(len * 0.75)
            if !DllCall("crypt32\CryptStringToBinary", "str", shellcodeBase64, "uint", len, "uint", 1, "ptr", shellcode, "uint*", shellcode.Size, "ptr", 0, "ptr", 0)
                return
            return shellcode
        }

        static link(x64, shellcode, shellcodeBase, user32Base, combaseBase, hwnd, tid, msg, &pThreadProc, &pRect) {
            if x64 {
                NumPut("uint64", user32Base, shellcode, 0)
                NumPut("uint64", combaseBase, shellcode, 8)
                NumPut("uint64", hwnd, shellcode, 16)
                NumPut("uint", tid, shellcode, 24)
                NumPut("uint", msg, shellcode, 28)
                pThreadProc := shellcodeBase + 0x4e0
                pRect := shellcodeBase + 56
            }
            else {
                NumPut("uint", user32Base, shellcode, 0)
                NumPut("uint", combaseBase, shellcode, 4)
                NumPut("uint", hwnd, shellcode, 8)
                NumPut("uint", tid, shellcode, 12)
                NumPut("uint", msg, shellcode, 16)
                pThreadProc := shellcodeBase + 0x43c
                pRect := shellcodeBase + 32
            }
        }

        static msgWaitForSingleObject(handle) {
            while 1 == res := DllCall("MsgWaitForMultipleObjects", "uint", 1, "ptr*", handle, "int", false, "uint", -1, "uint", 7423) { ; QS_ALLINPUT := 7423
                msg := Buffer(A_PtrSize == 8 ? 48 : 28)
                while DllCall("PeekMessageW", "ptr", msg, "ptr", 0, "uint", 0, "uint", 0, "uint", 1) { ; PM_REMOVE := 1
                    DllCall("TranslateMessage", "ptr", msg)
                    DllCall("DispatchMessageW", "ptr", msg)
                }
            }
            return res
        }
    }

    getCaretPosFromACC() {
        static _ := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
        try {
            idObject := 0xFFFFFFF8 ; OBJID_CARET
            if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint", idObject &= 0xFFFFFFFF
                , "ptr", -16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
                , "ptr*", oAcc := ComValue(9, 0)) = 0 {
                x := Buffer(4), y := Buffer(4), w := Buffer(4), h := Buffer(4)
                oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
                left := NumGet(x, 0, "int"), top := NumGet(y, 0, "int"), right := NumGet(w, 0, "int"), bottom := NumGet(h, 0, "int")
                if (left | top) != 0
                    return 0
                return 1
            }
        }
    }

    static guidFromString(str) {
        DllCall("ole32\CLSIDFromString", "str", str, "ptr", buf := Buffer(16), "hresult")
        return buf
    }

    static getRect(buf, &left, &top, &right, &bottom) {
        left := NumGet(buf, 0, "int")
        top := NumGet(buf, 4, "int")
        right := NumGet(buf, 8, "int")
        bottom := NumGet(buf, 12, "int")
    }

    static getWindowScale(hwnd) {
        if winDpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
            return A_ScreenDPI / winDpi
        return 1
    }

    static scaleRect(scale, &left, &top, &right, &bottom) {
        left := Round(left * scale)
        top := Round(top * scale)
        right := Round(right * scale)
        bottom := Round(bottom * scale)
    }

    static clientToScreenRect(hwnd, &left, &top, &right, &bottom) {
        w := right - left
        h := bottom - top
        pt := left | top << 32
        DllCall("ClientToScreen", "ptr", hwnd, "int64*", &pt)
        left := pt & 0xffffffff
        top := pt >> 32
        right := left + w
        bottom := top + h
    }
}


; 强制显示托盘菜单图标
SetTimer(showIconTimer, 10000)
showIconTimer() {
    static n := 0
    if (n > 30) {
        SetTimer(, 0)
    }
    n++

    ; 强制显示托盘菜单图标
    A_IconHidden := 0
}

#Include "*i plugins/InputTip.plugin.ahk"

#Include "*i utils/show.ahk"
