; InputTip

#NoTrayIcon

#Include core\manifest.ahk

isJAB := 1

;@AHK2Exe-SetName InputTip.JAB
;@Ahk2Exe-SetOrigFilename InputTip.JAB.JetBrains.ahk
;@AHK2Exe-SetDescription InputTip.JAB.JetBrains

#Include core\utils.ahk
#Include core\gui.ahk
#Include core\config.ahk
#Include core\i18n.ahk
#Include core\ini.ahk
#Include core\ime.ahk
#Include core\var.ahk
#Include core\symbol.ahk

; JAB 子进程
needSkip(exeName) {
    return var.symbolNearCursorActive || !var.modeList.JAB.Has(exeName)
}
needSkipSymbol(exeName) {
    return 0
}

returnCanShowSymbol(&left, &top, &right, &bottom) {
    try {
        GetCaretPosFromJAB(&left, &top, &right, &bottom)
    } catch {
        left := 0, top := 0, right := 0, bottom := 0
        return 0
    }
    if (!left && !top && !right && !bottom) {
        return returnCanShowSymbolN(&left, &top, &right, &bottom)
    }
    s := isWhichScreen(var.screenList)
    if (s.num) {
        try {
            offset := screenSymbolOffset.%s.num%
            left += offset.x
            top += offset.y
        }
        rule := matchOffsetRule(exeName, exeTitle, windowSymbolOffset)
        num := String(s.num)
        if (rule && rule.offset.Has(num)) {
            offset := rule.offset.Get(num)
            left += offset.x
            top += offset.y
        }
        return left
    }
    return 0
}

/**
 * Gets the position of the caret with UIA, Acc or CaretGetPos.
 * @param X Value is set to the screen X-coordinate of the caret
 * @param Y Value is set to the screen Y-coordinate of the caret
 * @param W Value is set to the width of the caret
 * @param H Value is set to the height of the caret
 * @link https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/
 * @link https://www.autohotkey.com/boards/viewtopic.php?t=130941#p576439
 */
GetCaretPosFromJAB(&X?, &Y?, &W?, &H?) {
    static JAB := InitJAB() ; Source: https://github.com/Elgin1/Java-Access-Bridge-for-AHK
    if JAB && (hWnd := WinExist("A")) && DllCall(JAB.module "\isJavaWindow", "ptr", hWnd, "CDecl Int") {
        if JAB.firstRun
            Sleep(200), JAB.firstRun := 0
        prevThreadDpiAwarenessContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -2, "ptr")
        DllCall(JAB.module "\getAccessibleContextWithFocus", "ptr", hWnd, "Int*", &vmID := 0, JAB.acType "*", &ac := 0, "Cdecl Int") "`n"
        DllCall(JAB.module "\getCaretLocation", "Int", vmID, JAB.acType, ac, "Ptr", Info := Buffer(16, 0), "Int", 0, "Cdecl Int")
        DllCall(JAB.module "\releaseJavaObject", "Int", vmID, JAB.acType, ac, "CDecl")
        DllCall("SetThreadDpiAwarenessContext", "ptr", prevThreadDpiAwarenessContext, "ptr")
        X := NumGet(Info, 0, "Int"), Y := NumGet(Info, 4, "Int"), W := NumGet(Info, 8, "Int"), H := NumGet(Info, 12, "Int")
        hMonitor := DllCall("MonitorFromWindow", "ptr", hWnd, "int", 2, "ptr") ; MONITOR_DEFAULTTONEAREST
        DllCall("Shcore.dll\GetDpiForMonitor", "ptr", hMonitor, "int", 0, "uint*", &dpiX := 0, "uint*", &dpiY := 0)
        if dpiX
            X := DllCall("MulDiv", "int", X, "int", dpiX, "int", 96, "int"), Y := DllCall("MulDiv", "int", Y, "int", dpiX, "int", 96, "int"), W := DllCall("MulDiv", "int", W, "int", dpiX, "int", 96, "int"), H := DllCall("MulDiv", "int", H, "int", dpiX, "int", 96, "int")
        if X || Y || W || H
            return
    }
    InitJAB() {
        ret := {}, ret.firstRun := 1, ret.module := A_PtrSize == 8 ? "WindowsAccessBridge-64.dll" : "WindowsAccessBridge-32.dll", ret.acType := "Int64"
        ret.DefineProp("__Delete", { call: (this) => DllCall("FreeLibrary", "ptr", this) })
        if !(ret.ptr := DllCall("LoadLibrary", "Str", ret.module, "ptr")) && A_PtrSize == 4 {
            ; try legacy, available only for 32-bit
            ret.acType := "Int", ret.module := "WindowsAccessBridge.dll", ret.ptr := DllCall("LoadLibrary", "Str", ret.module, "ptr")
        }
        if !ret.ptr
            return ; Failed to load library. Make sure you are running the script in the correct bitness and/or Java for the architecture is installed.
        DllCall(ret.module "\Windows_run", "Cdecl Int")
        return ret
    }
}

#Include returnCanShowSymbolN.ahk
#Include core\core.ahk
