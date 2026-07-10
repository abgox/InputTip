; InputTip

#Requires AutoHotkey v2.0

runtimeVersion := "2.0.26.0"
if A_IsCompiled
    versionType := "exe", currentVersion := "3.6.10"
else
    versionType := "zip", currentVersion := "3.6.10"

;@Ahk2Exe-SetVersion 3.6.10
;@Ahk2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon temp\icon\default-app.ico
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-SetDescription 规则驱动的输入法状态管理器
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

isJAB := 0
try DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr") ; -4 (DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
OnMessage(0x007E, (*) => SetTimer(updateScreenInfo, -500))
updateScreenInfo() {
    try {
        var.screenNum := MonitorGetCount()
        var.screenList := getScreenInfo()
        if !isJAB
            updateOverlay()
    }
}

hideOnTrayGui := []
OnMessage(0x0211, onMenuLoop)  ; WM_ENTERMENULOOP
onMenuLoop(wParam, lParam, msg, hwnd) {
    for v in hideOnTrayGui
        try v.Hide()
}

author := "abgox"
appname := "InputTip"
appid := author "." appname
taskNameNoUAC := appid ".noUAC"
taskNameJAB := appid ".JAB.JetBrains"

appPid := DllCall("GetCurrentProcessId")
runtime := A_ScriptDir "\AutoHotkey\AutoHotkey64.exe"
runtime2 := A_ScriptDir "\AutoHotkey\_AutoHotkey64.exe"

dataDir := A_ScriptDir "\data"
configFile := dataDir "\config.ini"
statsFile := dataDir "\stats.ini"
pluginDir := dataDir "\plugin"
cursorDir := dataDir "\cursor"
symbolDir := dataDir "\symbol"
iconDir := dataDir "\icon"
defaultCursorDir := A_ScriptDir "\temp\cursor"
defaultSymbolDir := A_ScriptDir "\temp\symbol"
defaultIconDir := A_ScriptDir "\temp\icon"

baseUrl := [
    "https://raw.giteeusercontent.com/abgox/InputTip/raw/main/",
    "https://raw.githubusercontent.com/abgox/InputTip/main/",
    "https://gh-proxy.org/https://raw.githubusercontent.com/abgox/InputTip/main/"
]


stateList := ["CN", "EN", "Caps", "US", "JP", "KR"]
stateVal := {
    CN: {
        color: "0xFF0000",
        colorText: "red",
    },
    EN: {
        color: "0x0000FF",
        colorText: "blue",
    },
    Caps: {
        color: "0x008000",
        colorText: "green",
    },
    US: {
        color: "0x0000FF",
        colorText: "blue",
    },
    JP: {
        color: "0xCCCC00",
        colorText: "yellow",
    },
    KR: {
        color: "0x800080",
        colorText: "purple",
    },
}
