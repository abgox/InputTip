; InputTip

#Requires AutoHotkey v2.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon img/favicon.ico
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
#SingleInstance Force
#Warn All, Off

Persistent
ListLines 0
KeyHistory 5
DetectHiddenWindows 1
InstallKeybdHook
CoordMode 'Mouse', 'Screen'
SetStoreCapsLockMode 0

OnError LogError

LogError(exception, mode) {
    if (InStr(exception.Message, "Invalid memory read/write")) {
        MsgBox("InputTip 内存读写错误，请尝试重启 InputTip", "InputTip 内存读写错误", "0x10")
        return true
    }
    return false
}

OnMessage(0x20A, WM_MOUSEWHEEL_Handler) ; 0x20A = WM_MOUSEWHEEL
WM_MOUSEWHEEL_Handler(wParam, lParam, msg, hwnd) {
    buf := Buffer(256, 0) ; 创建缓冲区
    DllCall("GetClassName", "ptr", hwnd, "ptr", buf.ptr, "int", buf.size)
    controlName := StrGet(buf) ; 获取控件类名
    if (controlName == "ComboBox") {
        return 0 ; 禁用 ComboBox 控件的鼠标滚轮以避免误切换
    }
}

OnMessage(0x20E, (*) => 0) ; 0x20E = WM_MOUSEHWHEEL

;@AHK2Exe-SetVersion 2025.09.06

if (A_IsCompiled) {
    ; exe 版本
    currentVersion := "2025.09.06"

    versionType := "exe"
    versionKey := "version"
} else {
    ; zip 版本
    currentVersion := "2025.09.06.1"

    versionType := "zip"
    versionKey := "version-zip"
}
