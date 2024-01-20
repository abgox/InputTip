#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v2
;@AHK2Exe-SetVersion 2.0.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip - 根据输入法中英文状态切换鼠标样式的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2024-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource InputTipCursor.zip
#SingleInstance Force
#Include ..\utils.ahk
ListLines 0
KeyHistory 0

if (!DirExist("InputTipCursor")) {
    FileExist("InputTipCursor.zip") ? 0 : FileInstall("InputTipCursor.zip", "InputTipCursor.zip", 1)
    RunWait("powershell -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_ScriptDir "'", , "Hide")
    FileDelete("InputTipCursor.zip")
}

cur := {
    ARROW: [32512], ; 普通选择
    IBEAM: [32513], ; 文本选择
    WAIT: [32514], ; 繁忙
    CROSS: [32515], ; 精度选择
    UPARROW: [32516], ; 备用选择
    SIZENWSE: [32642], ; 对角线调整大小 1  左上 => 右下
    SIZENESW: [32643], ; 对角线调整大小 2  左下 => 右上
    SIZEWE: [32644], ; 水平调整大小
    SIZENS: [32645], ; 垂直调整大小
    SIZEALL: [32646], ; 移动
    NO: [32648], ; 无法(禁用)
    HAND: [32649], ; 链接选择
    APPSTARTING: [32650], ; 在后台工作
    HELP: [32651], ; 帮助选择
    PIN: [32671], ; 位置选择
    PERSON: [32672] ; 人员选择
}

get_cursors("CN")
get_cursors("EN")

state := get_input_state()
old_state := ''

while 1 {
    if (A_TimeIdle < 50) {
        try {
            state := get_input_state()
        } catch {
            continue
        }
    }
    if (state != old_state) {
        old_state := state
        state ? show("CN", 1) : show("EN", 2)
    }
    Sleep(1)
}

get_cursors(folder) {
    Loop Files, "InputTipCursor\" folder "\*.*" {
        n := StrUpper(SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4))
        for k, v in cur.OwnProps() {
            if (InStr(n, k)) {
                cur.%k%.push(A_LoopFileName)
            }
        }
    }
}

show(lang, num) {
    for k, v in cur.OwnProps() {
        if (v.Length > num) {
            DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", "InputTipCursor\" lang "\" v[num + 1], "Ptr"), "Int", v[1])
        }
    }
}
