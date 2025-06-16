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

;@AHK2Exe-SetVersion 2.40.0

if (A_IsCompiled) {
    ; 当前版本
    currentVersion := "2.40.0"
    ; 版本字段
    versionKey := "version"
} else {
    ; 当前的 zip 版本
    currentVersion := "2.40.0.2"
    ; zip 版本字段
    versionKey := "version-zip"
}
