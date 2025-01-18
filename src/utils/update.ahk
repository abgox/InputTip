#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off
ListLines 0
KeyHistory 0

try {
    RunWait('taskkill /f /im ' A_Args[1], , "Hide")
    FileDelete(A_Args[2])
    FileMove(A_AppData "\abgox-InputTip-new-version.exe", A_Args[2])
    IniWrite("", A_AppData "\.abgox-InputTip-update-version-done.txt", "")
    Run(A_Args[2])
}
