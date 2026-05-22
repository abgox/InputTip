; InputTip

#Requires AutoHotkey v2.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon temp\icon\default-app.ico
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@AHK2Exe-SetDescription 输入法状态管理: 实时提示 + 状态切换
#SingleInstance Force
#Warn All, Off

Persistent()
ListLines(0)
KeyHistory(5)
DetectHiddenWindows(1)
InstallKeybdHook()
CoordMode("Mouse", "Screen")
SetStoreCapsLockMode(0)

OnError(LogError)

LogError(exception, mode) {
    return false
}

OnMessage(0x20E, (*) => 0) ; 0x20E = WM_MOUSEHWHEEL
OnMessage(0x20A, WM_MOUSEWHEEL_Handler) ; 0x20A = WM_MOUSEWHEEL
WM_MOUSEWHEEL_Handler(wParam, lParam, msg, hwnd) {
    buf := Buffer(256, 0) ; 创建缓冲区
    DllCall("GetClassName", "ptr", hwnd, "ptr", buf.ptr, "int", buf.size)
    controlName := StrGet(buf) ; 获取控件类名
    if (controlName == "ComboBox") {
        return 0 ; 禁用 ComboBox 控件的鼠标滚轮以避免误切换
    }
}

hideOnTrayGui := []
OnMessage(0x0211, onMenuLoop)  ; WM_ENTERMENULOOP
onMenuLoop(wParam, lParam, msg, hwnd) {
    for v in hideOnTrayGui {
        try v.Hide()
    }
}

;@AHK2Exe-SetVersion "3.1.1"

if (A_IsCompiled) {
    ; exe 版本
    currentVersion := "3.1.1"

    versionType := "exe"
    versionKey := "version"
} else {
    ; zip 版本
    currentVersion := "3.1.1"

    versionType := "zip"
    versionKey := "version-zip"
}

dataDir := A_ScriptDir "\data"
configFile := dataDir "\config.ini"
pluginDir := dataDir "\plugin"
cursorDir := dataDir "\cursor"
symbolDir := dataDir "\symbol"
iconDir := dataDir "\icon"
defaultCursorDir := A_ScriptDir "\temp\cursor"
defaultSymbolDir := A_ScriptDir "\temp\symbol"
defaultIconDir := A_ScriptDir "\temp\icon"
