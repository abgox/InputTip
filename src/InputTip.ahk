#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip
;@AHK2Exe-SetVersion 1.0.0
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

$Shift::Shift

name := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4),
    cname := name '.ini'

FileExist(cname) ? 0 : FileInstall('config.ini', cname, 1)

get_config(key) {
    try {
        return IniRead(cname, 'Config', key)
    } catch {
        MsgBox('配置项缺失(两种解决方案)`n1.检查 ' cname ' 文件内容,自行添加缺失项`n2.删除 ' cname ' 文件,重新启动应用以生成默认配置')
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
    state := get_input_state(), win := '',
    old_x := '', old_y := '', old_i := ''

make_gui(text) {
    g := Gui('-Caption +AlwaysOnTop ToolWindow LastFound'),
        g.BackColor := f_bgcolor, g.MarginX := 5, g.MarginY := 5
    g.SetFont('s' f_size ' c' f_color ' w' f_weight, f_family)
    WinSetTransparent(trans)
    g.AddText(, text)
    return g
}

CN_Gui := make_gui(CN_Text), EN_GUi := make_gui(EN_Text)

while 1 {
    MouseGetPos(&x, &y)
    try {
        if ((A_TimeSincePriorHotkey && A_TimeSincePriorHotkey < 300) || win != WinGetID('A')) {
            state := get_input_state(), win := WinGetID('A')
        }
    } catch {
        state := get_input_state()
    }
    if (!state) {
        continue
    }
    if (x != old_x || y != old_y || state != old_i) {
        old_x := x, old_y := y, old_i := state
        for v in no_show {
            if (WinActive('ahk_exe ' v)) {
                EN_GUi.Hide(), CN_Gui.Hide()
                continue 2
            }
        }
        state = 1
            ? (CN_Gui.Hide(), EN_GUi.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
            : (EN_GUi.Hide(), CN_Gui.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
    }
    Sleep(1)
}
