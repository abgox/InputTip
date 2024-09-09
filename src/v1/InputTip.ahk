#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v1
;@AHK2Exe-SetVersion 1.1.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v1 - 在鼠标处实时显示输入法中英文以及大写锁定状态的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource config.ini
#SingleInstance Force
#Include utils.ahk
ListLines 0
KeyHistory 0
DetectHiddenWindows True
CoordMode 'Mouse', 'Screen'

currentVersion := "1.1.0"

try {
    req := ComObject("Msxml2.XMLHTTP")
    ; 异步请求
    req.open("GET", "https://inputtip.pages.dev/releases/v1/version.txt", true)
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
            TipGui.AddText(, "InputTip v1 有新版本了!")
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

config_path := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4) '.ini'

FileExist(config_path) ? 0 : FileInstall('config.ini', config_path, 1)

get_config(k, v) {
    try {
        return IniRead(config_path, 'Config', k)
    } catch {
        IniWrite(v, config_path, "Config", k)
        return v
    }
}

f_family := get_config('font_family', 'SimHei'),
    f_size := get_config('font_size', '12') * A_ScreenDPI / 96,
    f_weight := get_config('font_weight', '900'),
    f_color := get_config('font_color', 'ffffff'),
    f_bgcolor := get_config('font_bgcolor', '474E68'),
    trans := get_config('windowTransparent', 222),
    CN_Text := get_config('CN_Text', '中'),
    EN_Text := get_config('EN_Text', '英'),
    Caps_Text := get_config('Caps_Text', 'Caps'),
    offset_x := get_config('offset_x', '30') * A_ScreenDPI / 96,
    offset_y := get_config('offset_y', '-50') * A_ScreenDPI / 96,
    no_show := StrSplit(get_config('window_no_display', 'Notepad.exe'), ','),
    state := 1, old_x := '', old_y := '', old_i := ''

make_gui(text) {
    g := Gui('-Caption +AlwaysOnTop ToolWindow LastFound'),
        g.BackColor := f_bgcolor, g.MarginX := 5, g.MarginY := 5
    g.SetFont('s' f_size ' c' f_color ' w' f_weight, f_family)
    WinSetTransparent(trans)
    g.AddText(, text)
    return g
}

CN_G := make_gui(CN_Text), EN_G := make_gui(EN_Text), Caps_G := make_gui(Caps_Text), isCaps := 0

while 1 {
    MouseGetPos(&x, &y)
    if (A_TimeIdle < 50) {
        if (GetKeyState("CapsLock", "T")) {
            isCaps := 1
            EN_G.Hide(), CN_G.Hide(), Caps_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y)
            continue
        } else {
            isCaps := 0
            Caps_G.Hide()
            state ? (EN_G.Hide(), CN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y)) : (CN_G.Hide(), EN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
        }
        try {
            state := getInputState()
        } catch {
            EN_G.Hide(), CN_G.Hide()
            continue
        }
    }
    if (!isCaps && (x != old_x || y != old_y || state != old_i)) {
        old_x := x, old_y := y, old_i := state
        for v in no_show {
            if (WinActive('ahk_exe ' v)) {
                EN_G.Hide(), CN_G.Hide()
                continue 2
            }
        }
        state ? (EN_G.Hide(), CN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y)) : (CN_G.Hide(), EN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
    }
    Sleep(1)
}
