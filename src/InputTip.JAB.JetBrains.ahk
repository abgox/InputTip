; InputTip

#Warn All, Off

#Include utils/options.ahk

#NoTrayIcon
;@AHK2Exe-SetName InputTip.JAB
;@Ahk2Exe-SetOrigFilename InputTip.JAB.JetBrains.ahk
;@AHK2Exe-SetDescription InputTip.JAB - 一个输入法状态管理工具(提示/切换)

isJAB := 1

#Include utils/tools.ahk
#Include utils/create-gui.ahk
#Include utils/ini.ahk
#Include utils/IME.ahk
#Include utils/app-list.ahk
#Include utils/var.ahk

/**
 * 跳过非 JAB/JetBrains IDE 程序，交由 InputTip 处理
 * @param exe_str 进程字符串，如 ":webstorm64.exe:"
 * @returns {1 | 0} 是否需要跳过
 */
needSkip(exe_str) {
    return showCursorPos || !InStr(modeList.JAB, exe_str)
}

returnCanShowSymbol(&left, &top, &right, &bottom) {
    try {
        GetCaretPosFromJAB(&left, &top, &right, &bottom)
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
        return left
    }

    return 0
}

/**
 * Gets the position of the caret with UIA, Acc or CaretGetPos.
 * @link https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/
 * @link https://www.autohotkey.com/boards/viewtopic.php?t=130941#p576439
 * @param X Value is set to the screen X-coordinate of the caret
 * @param Y Value is set to the screen Y-coordinate of the caret
 * @param W Value is set to the width of the caret
 * @param H Value is set to the height of the caret
 */
GetCaretPosFromJAB(&X?, &Y?, &W?, &H?) {
    static JAB := InitJAB() ; Source: https://github.com/Elgin1/Java-Access-Bridge-for-AHK
    if JAB && (hWnd := WinExist("A")) && DllCall(JAB.module "\isJavaWindow", "ptr", hWnd, "CDecl Int") {
        if JAB.firstRun
            Sleep(200), JAB.firstRun := 0
        prevThreadDpiAwarenessContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -2, "ptr")
        DllCall(JAB.module "\getAccessibleContextWithFocus", "ptr", hWnd, "Int*", &vmID := 0, JAB.acType "*", &ac := 0, "Cdecl Int") "`n"
        DllCall(JAB.module "\getCaretLocation", "Int", vmID, JAB.acType, ac, "Ptr", Info := Buffer(16, 0), "Int", 0, "Cdecl Int")
        DllCall(JAB.module "\releaseJavaObject", "Int", vmId, JAB.acType, ac, "CDecl")
        DllCall("SetThreadDpiAwarenessContext", "ptr", prevThreadDpiAwarenessContext, "ptr")
        X := NumGet(Info, 0, "Int"), Y := NumGet(Info, 4, "Int"), W := NumGet(Info, 8, "Int"), H := NumGet(Info, 12, "Int")
        hMonitor := DllCall("MonitorFromWindow", "ptr", hWnd, "int", 2, "ptr") ; MONITOR_DEFAULTTONEAREST
        DllCall("Shcore.dll\GetDpiForMonitor", "ptr", hMonitor, "int", 0, "uint*", &dpiX := 0, "uint*", &dpiY := 0)
        if dpiX
            X := DllCall("MulDiv", "int", X, "int", dpiX, "int", 96, "int"), Y := DllCall("MulDiv", "int", Y, "int", dpiX, "int", 96, "int")
        if X || Y || W || H
            return
    }
    InitJAB() {
        ret := {}, ret.firstRun := 1, ret.module := A_PtrSize = 8 ? "WindowsAccessBridge-64.dll" : "WindowsAccessBridge-32.dll", ret.acType := "Int64"
        ret.DefineProp("__Delete", { call: (this) => DllCall("FreeLibrary", "ptr", this) })
        if !(ret.ptr := DllCall("LoadLibrary", "Str", ret.module, "ptr")) && A_PtrSize = 4 {
            ; try legacy, available only for 32-bit
            ret.acType := "Int", ret.module := "WindowsAccessBridge.dll", ret.ptr := DllCall("LoadLibrary", "Str", ret.module, "ptr")
        }
        if !ret.ptr
            return ; Failed to load library. Make sure you are running the script in the correct bitness and/or Java for the architecture is installed.
        DllCall(ret.module "\Windows_run", "Cdecl Int")
        return ret
    }
}

#Include utils/show.ahk
