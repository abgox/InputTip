; InputTip

#Requires AutoHotkey v2.0

if (A_IsCompiled) {
    currentVersion := "3.2.1"
    versionType := "exe"
} else {
    currentVersion := "3.2.1"
    versionType := "zip"
}

;@AHK2Exe-SetVersion 3.2.1
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

OnError((*) => 0)

OnMessage(0x007E, OnDisplayChange)
OnDisplayChange(wParam, lParam, msg, hwnd) {
    SetTimer(updateScreenInfo, -500)
}
updateScreenInfo() {
    var.screenNum := MonitorGetCount()
    var.screenList := getScreenInfo()
    if !isJAB
        updateOverlay()
}

hideOnTrayGui := []
OnMessage(0x0211, onMenuLoop)  ; WM_ENTERMENULOOP
onMenuLoop(wParam, lParam, msg, hwnd) {
    for v in hideOnTrayGui {
        try v.Hide()
    }
}

author := "abgox"
appname := "InputTip"
appid := author "." appname
taskNameNoUAC := appid ".noUAC"
taskNameJAB := appid ".JAB.JetBrains"

dataDir := A_ScriptDir "\data"
configFile := dataDir "\config.ini"
pluginDir := dataDir "\plugin"
cursorDir := dataDir "\cursor"
symbolDir := dataDir "\symbol"
iconDir := dataDir "\icon"
defaultCursorDir := A_ScriptDir "\temp\cursor"
defaultSymbolDir := A_ScriptDir "\temp\symbol"
defaultIconDir := A_ScriptDir "\temp\icon"
