#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v1
;@AHK2Exe-SetVersion 1.6.2
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

#Include ..\utils\IME.ahk
#Include ..\utils\ini.ahk
#Include ..\utils\showMsg.ahk
#Include ..\utils\checkVersion.ahk

checkVersion("1.6.2", "v1")

try {
    mode := IniRead("InputTip.ini", "InputMethod", "mode")
} catch {
    try {
        mode := IniRead("InputTip.ini", "InputMethod", "CN")
        if (mode = 2) {
            mode := 3
        }
    } catch {
        mode := 2
    }
    writeIni("mode", mode, "InputMethod")
}
try {
    app_hide_CN_EN := IniRead("InputTip.ini", "config", "app_hide_CN_EN")
} catch {
    try {
        app_hide_CN_EN := IniRead("InputTip.ini", "config", "window_no_display")
    } catch {
        app_hide_CN_EN := ""
    }
    writeIni("app_hide_CN_EN", app_hide_CN_EN, "config")
}


HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    font_family := readIni('font_family', '微软雅黑', 'Config'),
    font_size := readIni('font_size', 10, 'Config') * A_ScreenDPI / 96,
    font_weight := readIni('font_weight', 600, 'Config'),
    font_color := StrReplace(readIni('font_color', 'ffffff', 'Config'), '#', ''),
    font_bgcolor := StrReplace(readIni('font_bgcolor', '474E68', 'Config'), '#', ''),
    windowTransparent := readIni('windowTransparent', 222, 'Config'),
    CN_Text := readIni('CN_Text', '中', 'Config'),
    EN_Text := readIni('EN_Text', '英', 'Config'),
    Caps_Text := readIni('Caps_Text', '大', 'Config'),
    offset_x := readIni('offset_x', 30, 'Config') * A_ScreenDPI / 96,
    offset_y := readIni('offset_y', -50, 'Config') * A_ScreenDPI / 96,
    ; 隐藏中英文状态字符提示
    app_hide_CN_EN := StrSplit(app_hide_CN_EN, ','),
    ; 隐藏输入法状态字符提示
    app_hide_state := StrSplit(readIni('app_hide_state', '', 'Config'), ','),
    state := 1, old_x := '', old_y := '', old_i := '',
    CN_G := make_gui(CN_Text), EN_G := make_gui(EN_Text), Caps_G := make_gui(Caps_Text), isShowCaps := 0

makeTrayMenu()

while 1 {
    is_hide_state := 0
    for v in app_hide_state {
        if (WinActive('ahk_exe ' v)) {
            is_hide_state := 1
            break
        }
    }
    if (is_hide_state) {
        EN_G.Hide(), CN_G.Hide()
        continue
    }
    is_hide_CN_EN := 0
    for v in app_hide_CN_EN {
        if (WinActive('ahk_exe ' v)) {
            is_hide_CN_EN := 1
            break
        }
    }
    if (is_hide_CN_EN && !isShowCaps) {
        EN_G.Hide(), CN_G.Hide()
    }
    if (A_TimeIdle < 500) {
        MouseGetPos(&x, &y)
        isShow := 0
        if (GetKeyState("CapsLock", "T")) {
            isShowCaps := 1
            EN_G.Hide(), CN_G.Hide(), Caps_G.Show('NA X' x + offset_x ' Y' y + offset_y)
            continue
        }
        try {
            state := isCN(mode)
        } catch {
            EN_G.Hide(), CN_G.Hide()
            continue
        }
        if (isShowCaps) {
            Caps_G.Hide()
            if (!is_hide_CN_EN) {
                state ? (EN_G.Hide(), CN_G.Show('NA X' x + offset_x ' Y' y + offset_y)) : (CN_G.Hide(), EN_G.Show('NA X' x + offset_x ' Y' y + offset_y))
            }
            isShowCaps := 0
        }
        if (x != old_x || y != old_y || state != old_i) {
            old_x := x, old_y := y, old_i := state, isShow := !is_hide_CN_EN
        }
        if (isShow) {
            state ? (EN_G.Hide(), CN_G.Show('NA X' x + offset_x ' Y' y + offset_y)) : (CN_G.Hide(), EN_G.Show('NA X' x + offset_x ' Y' y + offset_y))
            isShow := 0
        }
    }
    Sleep(50)
}

make_gui(text) {
    g := Gui('-Caption AlwaysOnTop ToolWindow LastFound'),
        g.BackColor := font_bgcolor, g.MarginX := 5, g.MarginY := 5
    g.SetFont('s' font_size ' c' font_color ' w' font_weight, font_family)
    WinSetTransparent(windowTransparent)
    g.AddText(, text)
    return g
}
makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("开机自启动", fn_startup)
    try {
        path_exe := RegRead(HKEY_startup, A_ScriptName)
        if (path_exe = A_ScriptFullPath) {
            A_TrayMenu.Check("开机自启动")
        }
    }
    sub := Menu()
    sub.Add("模式1", fn_input)
    sub.Add("模式2", fn_input)
    sub.Add("模式3", fn_input)
    sub.Add("模式4", fn_input)
    A_TrayMenu.Add("设置输入法", sub)
    sub.Check("模式" mode)
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    sub1 := Menu()
    sub1.Add("隐藏中英文状态字符提示", fn_hide_CN_EN)
    fn_common(tipList) {
        hideGui := Gui("AlwaysOnTop +OwnDialogs")
        hideGui.SetFont("s12", "微软雅黑")
        hideGui.AddButton("", tipList[2]).OnEvent("Click", add)
        hideGui.AddButton("xs", tipList[3]).OnEvent("Click", remove)
        hideGui.Show()
        add(*) {
            hideGui.Destroy()
            show()
            show() {
                addGui := Gui("AlwaysOnTop OwnDialogs")
                addGui.SetFont("s12", "微软雅黑")
                addGui.AddText(, tipList[4])
                addGui.AddText(, tipList[5])
                LV := addGui.Add("ListView", "r10 NoSortHdr Sort", ["应用程序"])
                LV.OnEvent("DoubleClick", LV_DoubleClick)
                value := IniRead("InputTip.ini", "config", tipList[1])
                value := SubStr(value, -1) = "," ? value : value ","
                temp := ""
                for v in WinGetList() {
                    try {
                        exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                        if (!RegExMatch(temp, exe_name ",") && !RegExMatch(value, exe_name ",")) {
                            temp .= exe_name ","
                            LV.Add(, exe_name)
                        }
                    }
                }
                LV.ModifyCol(1, "Auto")
                addGui.OnEvent("Close", close)
                close(*) {
                    Run(A_ScriptFullPath)
                }
                addGui.Show()
                LV_DoubleClick(LV, RowNumber)
                {
                    addGui.Hide()
                    RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                    confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                    confirmGui.SetFont("s12", "微软雅黑")
                    confirmGui.AddText(, tipList[6] RowText tipList[7])
                    confirmGui.Show("Hide")
                    confirmGui.GetPos(, , &Gui_width)
                    confirmGui.Destroy()

                    confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                    confirmGui.SetFont("s12", "微软雅黑")
                    confirmGui.AddText(, tipList[6] RowText tipList[7])
                    confirmGui.AddButton("xs w" Gui_width, "确认添加").OnEvent("Click", yes)
                    confirmGui.Show()
                    yes(*) {
                        addGui.Destroy()
                        confirmGui.Destroy()
                        value := IniRead("InputTip.ini", "config", tipList[1])
                        valueArr := StrSplit(value, ",")
                        result := ""
                        is_exist := 0
                        for v in valueArr {
                            if (v = RowText) {
                                is_exist := 1
                            }
                            if (Trim(v)) {
                                result .= v ","
                            }
                        }
                        if (is_exist) {
                            MsgBox(RowText " 已存在!", , "0x1000")
                        } else {
                            writeIni(tipList[1], result RowText, "config")
                        }
                        show()
                    }
                }
            }
        }
        remove(*) {
            hideGui.Destroy()
            show()
            show() {
                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                rmGui.AddText(, tipList[8])
                rmGui.AddText(, tipList[9])
                LV := rmGui.Add("ListView", "r10 NoSortHdr Sort", ["应用程序"])
                LV.OnEvent("DoubleClick", LV_DoubleClick)
                value := IniRead("InputTip.ini", "config", tipList[1])
                valueArr := StrSplit(value, ",")

                for v in valueArr {
                    if (Trim(v)) {
                        LV.Add(, v)
                    }
                }
                LV.ModifyCol(1, "Auto")
                rmGui.OnEvent("Close", close)
                close(*) {
                    Run(A_ScriptFullPath)
                }
                rmGui.Show()
                LV_DoubleClick(LV, RowNumber) {
                    rmGui.Hide()
                    RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                    confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                    confirmGui.SetFont("s12", "微软雅黑")
                    confirmGui.AddText(, tipList[10] RowText tipList[11])
                    confirmGui.Show("Hide")
                    confirmGui.GetPos(, , &Gui_width)
                    confirmGui.Destroy()

                    confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                    confirmGui.SetFont("s12", "微软雅黑")
                    confirmGui.AddText(, tipList[10] RowText tipList[11])
                    confirmGui.AddButton("xs w" Gui_width, "确认移除").OnEvent("Click", yes)
                    confirmGui.Show()
                    yes(*) {
                        rmGui.Destroy()
                        confirmGui.Destroy()
                        value := IniRead("InputTip.ini", "config", tipList[1])
                        valueArr := StrSplit(value, ",")
                        is_exist := 0
                        result := ""
                        for v in valueArr {
                            if (v = RowText) {
                                is_exist := 1
                            } else {
                                if (Trim(v)) {
                                    result .= v ","
                                }
                            }
                        }
                        if (is_exist) {
                            writeIni(tipList[1], result, "config")
                        } else {
                            MsgBox(RowText " 不存在或已经移除!", , "0x1000")
                        }
                        show()
                    }
                }
            }
        }
    }
    fn_hide_CN_EN(*) {
        fn_common(
            [
                "app_hide_CN_EN",
                "将应用添加到隐藏中英文状态字符提示的应用列表中",
                "从隐藏中英文状态字符提示的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏中英文状态字符提示的应用列表中",
                "是否要将 ",
                " 添加到隐藏中英文状态字符提示的应用列表中？`n在此列表中的所有应用里，InputTip.exe 都不会根据中英文状态显示不同颜色的字符，但会显示大写锁定字符",
                "以下列表中是隐藏中英文状态字符提示的应用列表",
                "双击应用程序，将其移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据中英文状态显示不同颜色的字符"
            ]
        )
    }
    sub1.Add("隐藏输入法状态字符提示", fn_hide_state)
    fn_hide_state(*) {
        fn_common(
            [
                "app_hide_state",
                "将应用添加到隐藏输入法状态字符提示的应用列表中",
                "从隐藏输入法状态字符提示的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏输入法状态字符提示的应用列表中",
                "是否要将 ",
                " 添加到隐藏输入法状态字符提示的应用列表中？`n在此列表中的所有应用里，InputTip.exe 都不会显示字符",
                "以下列表中是隐藏输入法状态字符提示的应用列表",
                "双击应用程序，将其移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据输入法状态显示不同颜色的字符"
            ]
        )
    }
    A_TrayMenu.Add("设置特殊软件", sub1)
    A_TrayMenu.Add("关于", about)
    A_TrayMenu.Add("重启", fn_restart)
    A_TrayMenu.Add("退出", fn_exit)
    /**
     * 设置输入法
     * @param item 点击的菜单项的名字
     * @param index 点击的菜单项在它的菜单对象中的索引
     */
    fn_input(item, index, *) {
        mode := readIni("mode", 1, "InputMethod")
        list := [
            [
                "模式1 适用于以下输入法:",
                "- 微信输入法",
                "- 微软(拼音/五笔)输入法",
                "- 搜狗输入法",
                "- QQ输入法",
                "- 冰凌五笔输入法",
                "如果没有你使用的输入法，请选择其他模式",
                "----------------------------------------------",
            ],
            [
                "模式2 适用于以下输入法:",
                "- 小狼毫(rime)输入法",
                "- 百度输入法",
                "- 谷歌输入法",
                "如果没有你使用的输入法，请选择其他模式",
                "----------------------------------------------",
            ],
            [
                "模式3 适用于以下输入法:",
                "- 讯飞输入法",
                "如果没有你使用的输入法，请选择其他模式",
                "----------------------------------------------",
            ],
            [
                "模式4 适用于以下输入法:",
                "- 手心输入法",
                "如果没有你使用的输入法，请选择其他模式",
                "----------------------------------------------",
            ]
        ]

        msgGui := Gui("AlwaysOnTop +OwnDialogs")
        msgGui.SetFont("s10", "微软雅黑")
        msgGui.AddText("", "是否要从 模式" mode " 切换到 模式" index " ?")
        for item in list[mode] {
            msgGui.AddText("xs", item)
        }
        msgGui.Show("Hide")
        msgGui.GetPos(, , &Gui_width)
        msgGui.Destroy()

        msgGui := Gui("AlwaysOnTop +OwnDialogs")
        msgGui.SetFont("s12", "微软雅黑")
        str := ""
        for item in list[mode] {
            str .= "`n" item
        }
        if (mode != index) {
            for item in list[index] {
                str .= "`n" item
            }
            msgGui.AddText("", "是否要从 模式" mode " 切换到 模式" index " ?`n----------------------------------------------" str)
        } else {
            msgGui.AddText("", "当前正在使用 模式" index "`n----------------------------------------------" str)
        }
        msgGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", yes)
        msgGui.Show()
        yes(*) {
            msgGui.Destroy()
            writeIni("mode", index, "InputMethod")
            Run(A_ScriptFullPath)
        }
    }
    fn_config(*) {
        configGui := Gui("AlwaysOnTop OwnDialogs")
        configGui.SetFont("s12", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v1 - 更改配置")
        configGui.AddText("xs", "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/blob/main/src/v1/config.md">https://github.com/abgox/InputTip/blob/main/src/v1/config.md</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("AlwaysOnTop OwnDialogs")
        configGui.SetFont("s12", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v1 - 更改配置")
        configGui.AddText("xs", "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v1/config">https://inputtip.pages.dev/v1/config</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/v1/config.md">https://github.com/abgox/InputTip/blob/main/src/v1/config.md</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/v1/config.md">https://gitee.com/abgox/InputTip/blob/main/src/v1/config.md</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值`n---------------------------------------------------------------------------------")

        configGui.AddText("xs", "font_family: ")
        configGui.AddEdit("vfont_family yp w100", font_family)
        configGui.AddText("yp x" Gui_width / 2, "font_size: ")
        configGui.AddEdit("vfont_size yp w100", font_size / A_ScreenDPI * 96)
        configGui.AddText("xs", "font_weight: ")
        configGui.AddEdit("vfont_weight yp w100", font_weight)
        configGui.AddText("yp x" Gui_width / 2, "font_color: ")
        configGui.AddEdit("vfont_color yp w100", font_color)
        configGui.AddText("xs", "font_bgcolor: ")
        configGui.AddEdit("vfont_bgcolor yp w100", font_bgcolor)
        configGui.AddText("yp x" Gui_width / 2, "CN_Text: ")
        configGui.AddEdit("vCN_Text yp w100", CN_Text)
        configGui.AddText("xs ", "EN_Text: ")
        configGui.AddEdit("vEN_Text yp w100", EN_Text)
        configGui.AddText("yp x" Gui_width / 2, "Caps_Text: ")
        configGui.AddEdit("vCaps_Text yp w100", Caps_Text)
        configGui.AddText("xs", "offset_x: ")
        configGui.AddEdit("voffset_x yp w100", offset_x / A_ScreenDPI * 96)
        configGui.AddText("yp x" Gui_width / 2, "offset_y: ")
        configGui.AddEdit("voffset_y yp w100", offset_y / A_ScreenDPI * 96)
        configGui.AddText("xs", "windowTransparent: ")
        configGui.AddEdit("vwindowTransparent yp w100", windowTransparent)
        configGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", changeConfig)
        changeConfig(*) {
            configList := ["font_family", "font_size", "font_weight", "font_color", "font_bgcolor", "windowTransparent", "CN_Text", "EN_Text", "Caps_Text", "offset_x", "offset_y"]
            for item in configList {
                input := configGui.Submit().%item%
                writeIni(item, input, "Config")
            }
            fn_restart()
        }
        configGui.Show()
    }
    about(*) {
        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center h30", "InputTip v1 - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center h30 w" Gui_width, "InputTip v1 - 一个输入法状态(中文/英文/大写锁定)提示工具")
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
    fn_restart(*) {
        Run(A_ScriptFullPath)
    }
    fn_exit(*) {
        ExitApp()
    }
}
