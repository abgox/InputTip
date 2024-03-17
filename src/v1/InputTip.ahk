#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v1
;@AHK2Exe-SetVersion 1.0.3
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v1 - 在光标处实时显示输入法中英文状态的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource config.ini
#SingleInstance Force
#Include utils.ahk
ListLines 0
KeyHistory 0
CoordMode 'Mouse', 'Screen'

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
    offset_x := get_config('offset_x', '30') * A_ScreenDPI / 96,
    offset_y := get_config('offset_y', '-50') * A_ScreenDPI / 96,
    no_show := StrSplit(get_config('window_no_display', 'Notepad.exe'), ','),
    state := 1,
    old_x := '', old_y := '', old_i := ''

make_gui(text) {
    g := Gui('-Caption +AlwaysOnTop ToolWindow LastFound'),
        g.BackColor := f_bgcolor, g.MarginX := 5, g.MarginY := 5
    g.SetFont('s' f_size ' c' f_color ' w' f_weight, f_family)
    WinSetTransparent(trans)
    g.AddText(, text)
    return g
}

CN_G := make_gui(CN_Text), EN_G := make_gui(EN_Text)

while 1 {
    MouseGetPos(&x, &y)
    if (A_TimeIdle < 50) {
        try {
            state := get_input_state()
        } catch {
            EN_G.Hide(), CN_G.Hide()
            continue
        }
    }
    if (x != old_x || y != old_y || state != old_i) {
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
