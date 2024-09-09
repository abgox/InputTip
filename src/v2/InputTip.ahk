#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v2
;@AHK2Exe-SetVersion 2.2.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v2 - 根据输入法中英文以及大写锁定状态切换鼠标样式的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2024-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource InputTipCursor.zip
#SingleInstance Force
#Include utils.ahk
ListLines 0
KeyHistory 0
DetectHiddenWindows True

currentVersion := "2.2.0"

try {
    req := ComObject("Msxml2.XMLHTTP")
    ; 异步请求
    req.open("GET", "https://inputtip.pages.dev/releases/v2/version.txt", true)
    req.onreadystatechange := Ready
    req.send()
    Ready() {
        if (req.readyState != 4) {
            ; 没有完成.
            return
        }
        compareVersion(new, old) {
            newParts := StrSplit(new, ".")
            oldParts := StrSplit(old, ".")
            for i, part1 in newParts {
                try {
                    part2 := oldParts[i]
                } catch {
                    part2 := 0
                }
                if (part1 > part2) {
                    return 1  ; new > old
                } else if (part1 < part2) {
                    return -1  ; new < old
                }
            }
            return 0  ; new == old
        }
        newVersion := StrReplace(StrReplace(req.responseText, "`r", ""), "`n", "")
        if (req.status == 200 && compareVersion(newVersion, currentVersion) > 0) {
            TipGui := Gui("AlwaysOnTop +OwnDialogs")
            TipGui.SetFont("q4 s12 w600", "微软雅黑")
            TipGui.AddText(, "InputTip v2 有新版本了!")
            TipGui.AddText(, currentVersion " => " newVersion)
            TipGui.AddText(, "前往官网下载最新版本!")
            TipGui.AddText(, "----------------------")
            TipGui.AddText("xs", "官网:")
            TipGui.AddLink("yp", '<a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
            TipGui.AddText("xs", "Github:")
            TipGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
            TipGui.AddText("xs", "Gitee: :")
            TipGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
            TipGui.Show()
        }
    }
}

if (!DirExist("InputTipCursor")) {
    FileExist("InputTipCursor.zip") ? 0 : FileInstall("InputTipCursor.zip", "InputTipCursor.zip", 1)
    RunWait("powershell -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_ScriptDir "'", , "Hide")
    FileDelete("InputTipCursor.zip")
}

info := [{
    ; 普通选择
    type: "ARROW", value: "32512", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 文本选择/文本输入
    type: "IBEAM", value: "32513", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 繁忙
    type: "WAIT", value: "32514", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 精度选择
    type: "CROSS", value: "32515", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 备用选择
    type: "UPARROW", value: "32516", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 对角线调整大小 1  左上 => 右下
    type: "SIZENWSE", value: "32642", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 对角线调整大小 2  左下 => 右上
    type: "SIZENESW", value: "32643", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 水平调整大小
    type: "SIZEWE", value: "32644", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 垂直调整大小
    type: "SIZENS", value: "32645", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 移动
    type: "SIZEALL", value: "32646", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 无法(禁用)
    type: "NO", value: "32648", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 链接选择
    type: "HAND", value: "32649", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 在后台工作
    type: "APPSTARTING", value: "32650", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 帮助选择
    type: "HELP", value: "32651", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 位置选择
    type: "PIN", value: "32671", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 人员选择
    type: "PERSON", value: "32672", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 手写
    type: "PEN", value: "32631", origin: "", CN: "", EN: "", Caps: ""
}
]

for p in ["EN", "CN", "Caps"] {
    Loop Files, "InputTipCursor\" p "\*.*" {
        n := StrUpper(SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4))
        for v in info {
            if (v.type = n) {
                v.%p% := A_LoopFileFullPath
            }
        }
    }
}

curMap := {
    ARROW: "Arrow",
    IBEAM: "IBeam",
    WAIT: "Wait",
    CROSS: "Crosshair",
    UPARROW: "UpArrow",
    SIZENWSE: "SizeNWSE",
    SIZENESW: "SizeNESW",
    SIZEWE: "SizeWE",
    SIZENS: "SizeNS",
    SIZEALL: "SizeAll",
    NO: "No",
    HAND: "Hand",
    APPSTARTING: "AppStarting",
    HELP: "Help",
    PIN: "Pin",
    PERSON: "Person",
    PEN: "NWPen"
}

for v in info {
    try {
        v.origin := replaceEnvVariables(RegRead("HKEY_CURRENT_USER\Control Panel\Cursors", curMap.%v.type%))
    }
    if (v.EN = "" || v.CN = "" || v.Caps = "") {
        if (v.origin) {
            v.EN := v.CN := v.Caps := v.origin
        } else {
            v.EN := v.CN := v.Caps := ""
        }
    }
}

state := 1, old_state := ''

while 1 {
    if (A_TimeIdle < 50) {
        if (GetKeyState("CapsLock", "T")) {
            show("Caps")
            continue
        } else {
            state ? show("CN") : show("EN")
        }
        try {
            state := getInputState()
        } catch {
            continue
        }
    }
    if (state != old_state) {
        old_state := state
        state ? show("CN") : show("EN")
    }
    Sleep(50)
}

show(type) {
    for v in info {
        DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%type%, "Ptr"), "Int", v.value)
    }
}
