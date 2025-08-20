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

;@AHK2Exe-SetVersion 2025.08.20

if (A_IsCompiled) {
    ; exe 版本
    currentVersion := "2025.08.20"

    versionType := "exe"
    versionKey := "version"
} else {
    ; zip 版本
    currentVersion := "2025.08.20"

    versionType := "zip"
    versionKey := "version-zip"
}
