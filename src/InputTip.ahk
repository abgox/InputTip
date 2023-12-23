#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip
;@AHK2Exe-SetVersion 1.0.2
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon favicon.ico
;@AHK2Exe-SetDescription InputTip - 在光标处实时显示当前输入法状态的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023 abgox <https://github.com/abgox>
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource config.ini
#SingleInstance Force
#Include function\get_input_state.ahk
ListLines 0
KeyHistory 0
CoordMode 'Mouse', 'Screen'

config_path := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4) '.ini'

FileExist(config_path) ? 0 : FileInstall('config.ini', config_path, 1)

get_config(k) {
    try {
        return IniRead(config_path, 'Config', k)
    } catch {
        MsgBox('配置项缺失(两种解决方案)`n1.检查 ' config_path ' 文件内容,自行添加缺失项`n2.删除 ' config_path ' 文件,重新启动应用以生成默认配置')
        ExitApp()
    }
}

f_family := get_config('font_family'),
    f_size := get_config('font_size') * A_ScreenDPI / 96,
    f_weight := get_config('font_weight'),
    f_color := get_config('font_color'),
    f_bgcolor := get_config('font_bgcolor'),
    trans := get_config('windowTransparent'),
    CN_Text := get_config('CN_Text'),
    EN_Text := get_config('EN_Text'),
    offset_x := get_config('offset_x') * A_ScreenDPI / 96,
    offset_y := get_config('offset_y') * A_ScreenDPI / 96,
    no_show := StrSplit(get_config('window_no_display'), ','),
    state := get_input_state(),
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
    if (A_TimeIdle < 30) {
        state := get_input_state()
    }
    if (!state) {
        continue
    }
    if (x != old_x || y != old_y || state != old_i) {
        old_x := x, old_y := y, old_i := state
        for v in no_show {
            if (WinActive('ahk_exe ' v)) {
                EN_G.Hide(), CN_G.Hide()
                continue 2
            }
        }
        state = 1
            ? (CN_G.Hide(), EN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
            : (EN_G.Hide(), CN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
    }
    Sleep(1)
}
