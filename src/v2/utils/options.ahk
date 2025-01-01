#Requires AutoHotkey v2.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
#SingleInstance Force
#Warn All, Off
Persistent
ListLines 0
KeyHistory 0
DetectHiddenWindows 1
InstallKeybdHook
InstallMouseHook
CoordMode 'Mouse', 'Screen'
SetStoreCapsLockMode 0

;@AHK2Exe-SetVersion 2.28.4
currentVersion := "2.28.4"
