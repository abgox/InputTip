#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v1
;@AHK2Exe-SetVersion 1.2.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v1 - 在鼠标处实时显示输入法中英文以及大写锁定状态的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-UpdateManifest 1
#SingleInstance Force
ListLines 0
KeyHistory 0
DetectHiddenWindows True
CoordMode 'Mouse', 'Screen'

currentVersion := "1.2.0"

checkVersion()

config := "InputTip.ini"

code := ini("code", "0x005"),
    CN := ini("CN", 1),
    HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    font_family := ini('font_family', 'SimHei', 'Config'),
    font_size := ini('font_size', 12, 'Config') * A_ScreenDPI / 96,
    font_weight := ini('font_weight', 900, 'Config'),
    font_color := StrReplace(ini('font_color', 'ffffff', 'Config'), '#', ''),
    font_bgcolor := StrReplace(ini('font_bgcolor', '474E68', 'Config'), '#', ''),
    windowTransparent := ini('windowTransparent', 222, 'Config'),
    CN_Text := ini('CN_Text', '中', 'Config'),
    EN_Text := ini('EN_Text', '英', 'Config'),
    Caps_Text := ini('Caps_Text', 'Caps', 'Config'),
    offset_x := ini('offset_x', 30, 'Config') * A_ScreenDPI / 96,
    offset_y := ini('offset_y', -50, 'Config') * A_ScreenDPI / 96,
    window_no_display := StrSplit(ini('window_no_display', 'notepad.exe,everything.exe', 'Config'), ','),
    state := 1, old_x := '', old_y := '', old_i := '',
    CN_G := make_gui(CN_Text), EN_G := make_gui(EN_Text), Caps_G := make_gui(Caps_Text), isShowCaps := 0

makeTrayMenu()

while 1 {
    if (A_TimeIdle < 50) {
        MouseGetPos(&x, &y)
        canShow := 1, isShow := 0
        for v in window_no_display {
            if (WinActive('ahk_exe ' v)) {
                canShow := 0
                break
            }
        }
        if (!canShow) {
            EN_G.Hide(), CN_G.Hide()
        }
        if (GetKeyState("CapsLock", "T")) {
            isShowCaps := 1
            EN_G.Hide(), CN_G.Hide(), Caps_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y)
            continue
        }
        try {
            state := getInputState()
        } catch {
            EN_G.Hide(), CN_G.Hide()
            continue
        }
        if (isShowCaps) {
            Caps_G.Hide()
            if (canShow) {
                state ? (EN_G.Hide(), CN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y)) : (CN_G.Hide(), EN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
            }
            isShowCaps := 0
        }
        if (x != old_x || y != old_y || state != old_i) {
            old_x := x, old_y := y, old_i := state, isShow := canShow
        }
        if (isShow) {
            state ? (EN_G.Hide(), CN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y)) : (CN_G.Hide(), EN_G.Show('NA AutoSize X' x + offset_x ' Y' y + offset_y))
            isShow := 0
        }
    }
    Sleep(1)
}

/**
 * 获取当前输入法中英文状态
 * @returns {number} 1:中文 0:英文
 * CN=1, EN=0   微信输入法,微软拼音，搜狗输入法,QQ输入法,冰凌五笔,
 * CN=2, EN=1   讯飞输入法
 * CN=EN=1(无法区分) 百度输入法，手心输入法，谷歌输入法，2345王牌输入法，小鹤音形,小狼毫(rime)
 */
getInputState() {
    res := SendMessage(
        0x283,    ; Message : WM_IME_CONTROL
        code,    ; wParam  : IMC_GETCONVERSIONMODE
        0,    ; lParam  ： (NoArgs)
        , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinGetID("A"), "Uint") ; Control ： (Window)
    )
    return res = CN
}
checkVersion() {
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
                TipGui.AddText(, "版本更新日志:")
                TipGui.AddLink("yp", '<a href="https://inputtip.pages.dev/v1/changelog">https://inputtip.pages.dev/v1/changelog</a>')
                TipGui.Show("Hide")
                TipGui.GetPos(, , &Gui_width)
                TipGui.Destroy()

                TipGui := Gui("AlwaysOnTop +OwnDialogs")
                TipGui.SetFont("q4 s12 w600", "微软雅黑")
                TipGui.AddText(, "InputTip v1 有新版本了!")
                TipGui.AddText(, currentVersion " => " newVersion)
                TipGui.AddText(, "版本更新日志:")
                TipGui.AddLink("yp", '<a href="https://inputtip.pages.dev/v1/changelog">https://inputtip.pages.dev/v1/changelog</a>')
                TipGui.AddText("xs", "是否更新到最新版本?")
                TipGui.AddText("xs", "只需要确认更新，会自动下载新版本替代旧版本并重启")
                TipGui.AddButton("xs w" Gui_width, "确认更新").OnEvent("Click", updateVersion)
                TipGui.Show()
                updateVersion(*) {
                    TipGui.Destroy()
                    try {
                        Download("https://inputtip.pages.dev/releases/v1/InputTip.exe", A_AppData "\abgox-InputTip.exe")
                        Run("powershell -Command Start-Sleep -Seconds 1;Move-Item -Force '" A_AppData "\abgox-InputTip.exe' '" A_ScriptDir "\" A_ScriptName "';Start-Process '" A_ScriptDir "\" A_ScriptName "'", , "Hide")
                        ExitApp()
                    } catch {
                        errGui := Gui("AlwaysOnTop +OwnDialogs")
                        errGui.SetFont("q4 s12 w600", "微软雅黑")
                        errGui.AddText(, "InputTip v1 新版本下载错误!")
                        errGui.AddText("xs", "手动前往官网下载最新版本!")
                        errGui.AddText(, "----------------------")
                        errGui.AddText("xs", "官网:")
                        errGui.AddLink("yp", '<a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
                        errGui.AddText("xs", "Github:")
                        errGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
                        errGui.AddText("xs", "Gitee: :")
                        errGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
                        errGui.Show()
                    }
                }
            }
        }
    }
}
ini(key, default, section := "InputMethod") {
    try {
        return IniRead(config, section, key)
    } catch {
        IniWrite(default, config, section, key)
        return default
    }
}
make_gui(text) {
    g := Gui('-Caption +AlwaysOnTop ToolWindow LastFound'),
        g.BackColor := font_bgcolor, g.MarginX := 5, g.MarginY := 5
    g.SetFont('s' font_size ' c' font_color ' w' font_weight, font_family)
    WinSetTransparent(windowTransparent)
    g.AddText(, text)
    return g
}
makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("开机自启动", fn_startup)
    subMap := {
        默认: ["0x005", "1"],
        讯飞输入法: ["0x005", "2"]
    }
    sub := Menu()
    sub.Add("默认", fn)
    sub.Add("讯飞输入法", fn)
    A_TrayMenu.Add("设置输入法", sub)
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    fn_config(*) {
        configGui := Gui("AlwaysOnTop +OwnDialogs")
        configGui.SetFont("q4 s12 w600", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v2 - 更改配置")
        configGui.AddText("xs", "配置项详细说明:")
        configGui.AddLink("yp", '<a href="https://inputtip.pages.dev/v2/config">https://inputtip.pages.dev/v2/config</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("AlwaysOnTop +OwnDialogs")
        configGui.SetFont("q4 s12 w600", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v1 - 更改配置")
        configGui.AddText("xs", "配置项详细说明:")
        configGui.AddLink("yp", '<a href="https://inputtip.pages.dev/v1/config">https://inputtip.pages.dev/v1/config</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值")
        configGui.AddText("xs", "-------------------------------------")

        configGui.AddText("xs", "font_family: ")
        configGui.AddEdit("vfont_family yp w150", font_family)
        configGui.AddText("xs", "font_size: ")
        configGui.AddEdit("vfont_size yp w150", font_size / A_ScreenDPI * 96)
        configGui.AddText("xs", "font_weight: ")
        configGui.AddEdit("vfont_weight yp w150", font_weight)
        configGui.AddText("xs", "font_color: ")
        configGui.AddEdit("vfont_color yp w150", font_color)
        configGui.AddText("xs", "font_bgcolor: ")
        configGui.AddEdit("vfont_bgcolor yp w150", font_bgcolor)
        configGui.AddText("xs", "windowTransparent: ")
        configGui.AddEdit("vwindowTransparent yp w150", windowTransparent)
        configGui.AddText("xs", "CN_Text: ")
        configGui.AddEdit("vCN_Text yp w150", CN_Text)
        configGui.AddText("xs", "EN_Text: ")
        configGui.AddEdit("vEN_Text yp w150", EN_Text)
        configGui.AddText("xs", "Caps_Text: ")
        configGui.AddEdit("vCaps_Text yp w150", Caps_Text)
        configGui.AddText("xs", "offset_x: ")
        configGui.AddEdit("voffset_x yp w150", offset_x / A_ScreenDPI * 96)
        configGui.AddText("xs", "offset_y: ")
        configGui.AddEdit("voffset_y yp w150", offset_y / A_ScreenDPI * 96)
        configGui.AddText("xs", "window_no_display: ")
        window_no_display_str := ""
        for v in window_no_display {
            window_no_display_str .= v ","
        }
        configGui.AddEdit("vwindow_no_display xs w" Gui_width, window_no_display_str)
        configGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", changeConfig)
        changeConfig(*) {
            configList := ["font_family", "font_size", "font_weight", "font_color", "font_bgcolor", "windowTransparent", "CN_Text", "EN_Text", "Caps_Text", "offset_x", "offset_y", "window_no_display"]
            for item in configList {
                input := configGui.Submit().%item%
                IniWrite(input, config, "Config", item)
            }
            input := configGui.Submit().window_no_display
            IniWrite(RegExReplace(input, ",", "", , , StrLen(input) - 1), config, "Config", "window_no_display")
            fn_restart()
        }
        configGui.Show()
    }
    A_TrayMenu.Add("关于", about)
    A_TrayMenu.Add("重启", fn_restart)
    A_TrayMenu.Add("退出", fn_exit)
    try {
        select := ini("select", "默认")
        sub.Check(select)
    } catch {
        IniWrite("默认", config, "InputMethod", "select")
        select := "默认"
        sub.Check(select)
    }
    try {
        path_exe := RegRead(HKEY_startup, A_ScriptName)
        if (path_exe = A_ScriptFullPath) {
            A_TrayMenu.Check("开机自启动")
        }
    }
    fn_startup(item, *) {
        try {
            path_exe := RegRead(HKEY_startup, A_ScriptName)
            if (path_exe != A_ScriptFullPath) {
                RegWrite(A_ScriptFullPath, "REG_SZ", HKEY_startup, A_ScriptName)
            } else {
                RegDelete(HKEY_startup, A_ScriptName)
            }
        } catch {
            RegWrite(A_ScriptFullPath, "REG_SZ", HKEY_startup, A_ScriptName)
        }
        A_TrayMenu.ToggleCheck(item)
    }
    about(*) {
        aboutGui := Gui("AlwaysOnTop +OwnDialogs")
        aboutGui.SetFont("q4 s12 w600", "微软雅黑")
        aboutGui.AddText("Center h30", "InputTip v1 - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop +OwnDialogs")
        aboutGui.SetFont("q4 s12 w600", "微软雅黑")
        aboutGui.AddText("Center h30 w" Gui_width, "InputTip - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.AddText("xs", "获取更多信息，你应该查看 : ")
        aboutGui.AddText("xs", "官网:")
        aboutGui.AddLink("yp", '<a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
        aboutGui.AddText("xs", "Github:")
        aboutGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        aboutGui.AddText("xs", "Gitee: :")
        aboutGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')

        aboutGui.AddButton("xs w" Gui_width, "关闭").OnEvent("Click", close)
        aboutGui.OnEvent("Escape", close)
        aboutGui.Show()

        close(*) {
            aboutGui.Destroy()
        }

    }
    fn_restart(*) {
        Run(A_ScriptFullPath)
    }
    fn_exit(*) {
        ExitApp()
    }
    fn(item, *) {
        do(k, v) {
            try {
                old_v := IniRead(config, "InputMethod", k)
                if (old_v != v) {
                    IniWrite(v, config, "InputMethod", k)
                }
            } catch {
                IniWrite(v, config, "InputMethod", k)
            }
        }
        do("select", item)
        do("code", subMap.%item%[1])
        do("CN", subMap.%item%[2])
        Run(A_ScriptFullPath)
    }
}
