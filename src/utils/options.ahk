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

;@AHK2Exe-SetVersion 2025.08.29

if (A_IsCompiled) {
    ; exe 版本
    currentVersion := "2025.08.29"

    versionType := "exe"
    versionKey := "version"
} else {
    ; zip 版本
    currentVersion := "2025.08.29"

    versionType := "zip"
    versionKey := "version-zip"
}
