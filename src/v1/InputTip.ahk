#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v1
;@AHK2Exe-SetVersion 1.9.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v1 - 在鼠标处实时显示输入法中英文以及大写锁定状态的小工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-UpdateManifest 1
#SingleInstance Force
ListLines 0
KeyHistory 0
DetectHiddenWindows 1
CoordMode 'Mouse', 'Screen'
SetStoreCapsLockMode 0

#Include .\utils\ini.ahk
#Include ..\utils\IME.ahk
#Include ..\utils\showMsg.ahk
#Include ..\utils\checkVersion.ahk

currentVersion := "1.9.0"
checkVersion(currentVersion, "v1")

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
    app_hide_CN_EN := IniRead("InputTip.ini", "Config", "app_hide_CN_EN")
} catch {
    try {
        app_hide_CN_EN := IniRead("InputTip.ini", "Config", "window_no_display")
    } catch {
        app_hide_CN_EN := ""
    }
    writeIni("app_hide_CN_EN", app_hide_CN_EN)
}


HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    font_family := readIni('font_family', '微软雅黑'),
    font_size := readIni('font_size', 10),
    font_weight := readIni('font_weight', 600),
    font_color := StrReplace(readIni('font_color', 'ffffff'), '#', ''),
    font_bgcolor := StrReplace(readIni('font_bgcolor', '474E68'), '#', ''),
    windowTransparent := readIni('windowTransparent', 222),
    CN_Text := readIni('CN_Text', '中'),
    EN_Text := readIni('EN_Text', '英'),
    Caps_Text := readIni('Caps_Text', '大'),
    offset_x := readIni('offset_x', 30) * A_ScreenDPI / 96,
    offset_y := readIni('offset_y', -50) * A_ScreenDPI / 96,
    ; 隐藏中英文状态字符提示
    app_hide_CN_EN := "," app_hide_CN_EN ",",
    app_CN := "," readIni('app_CN', '') ",",
    app_EN := "," readIni('app_EN', '') ",",
    app_Caps := "," readIni('app_Caps', '') ",",
    state := 1, old_x := '', old_y := '', old_i := '',
    CN_G := make_gui(CN_Text), EN_G := make_gui(EN_Text), Caps_G := make_gui(Caps_Text), isShowCaps := 0,
    lastWindow := ""
makeTrayMenu()

while 1 {
    is_hide_CN_EN := 0
    try {
        exe_name := ProcessGetName(WinGetPID("A"))
        if (exe_name != lastWindow) {
            WinWaitActive("ahk_exe" exe_name)
            lastWindow := exe_name
            if (RegExMatch(app_CN, "," exe_name ",")) {
                if (GetKeyState("CapsLock", "T")) {
                    SendInput("{CapsLock}")
                }
                if (!isCN(mode)) {
                    SendInput("{Shift}")
                }
            } else if (RegExMatch(app_EN, "," exe_name ",")) {
                if (GetKeyState("CapsLock", "T")) {
                    SendInput("{CapsLock}")
                }
                if (isCN(mode)) {
                    SendInput("{Shift}")
                }
            } else if (RegExMatch(app_Caps, "," exe_name ",")) {
                if (!isShowCaps) {
                    SendInput("{CapsLock}")
                }
            }
        }

        is_hide_CN_EN := RegExMatch(app_hide_CN_EN, "," exe_name ",")
        if (is_hide_CN_EN && !isShowCaps) {
            EN_G.Hide(), CN_G.Hide()
        }
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
    g.SetFont('s' font_size * A_ScreenDPI / 96 ' c' font_color ' w' font_weight, font_family)
    WinSetTransparent(windowTransparent)
    g.AddText(, text)
    return g
}
makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("开机自启动", fn_startup)
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
    /**
     * 设置输入法
     * @param item 点击的菜单项的名字
     * @param index 点击的菜单项在它的菜单对象中的索引
     */
    fn_input(item, index, *) {
        mode := readIni("mode", 1, "InputMethod")
        msgGui := Gui("AlwaysOnTop +OwnDialogs")
        msgGui.SetFont("s10", "微软雅黑")
        msgGui.AddLink(, '<a href="https://inputtip.pages.dev/v1/#兼容情况">https://inputtip.pages.dev/v1/#兼容情况</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/v1/README.md#兼容情况">https://github.com/abgox/InputTip/blob/main/src/v1/README.md#兼容情况</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/v1/README.md#-4">https://gitee.com/abgox/InputTip/blob/main/src/v1/README.md#-4</a>')
        msgGui.Show("Hide")
        msgGui.GetPos(, , &Gui_width)
        msgGui.Destroy()

        msgGui := Gui("AlwaysOnTop +OwnDialogs")
        msgGui.SetFont("s12", "微软雅黑")
        if (mode != index) {
            msgGui.AddText("", "是否要从 模式" mode " 切换到 模式" index " ?`n----------------------------------------------")
        } else {
            msgGui.AddText("", "当前正在使用 模式" index "`n----------------------------------------------")
        }
        msgGui.AddText(, "模式相关信息请查看以下任意地址:")
        msgGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v1/#兼容情况">https://inputtip.pages.dev/v1/#兼容情况</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/v1/README.md#兼容情况">https://github.com/abgox/InputTip/blob/main/src/v1/README.md#兼容情况</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/v1/README.md#-4">https://gitee.com/abgox/InputTip/blob/main/src/v1/README.md#-4</a>')
        msgGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", yes)
        msgGui.Show()
        yes(*) {
            msgGui.Destroy()
            writeIni("mode", index, "InputMethod")
            Run(A_ScriptFullPath)
        }
    }
    sub.Check("模式" mode)
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    fn_config(*) {
        configGui := Gui("AlwaysOnTop OwnDialogs")
        configGui.SetFont("s12", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v1 - 更改配置")
        configGui.AddText("xs", "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/blob/main/src/v1/config.md">https://github.com/abgox/InputTip/blob/main/src/v1/config.md</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值`n-------------------------------------------------------------------------------------------")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("AlwaysOnTop OwnDialogs")
        configGui.SetFont("s12", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v1 - 更改配置")
        configGui.AddText("xs", "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v1/config">https://inputtip.pages.dev/v1/config</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/v1/config.md">https://github.com/abgox/InputTip/blob/main/src/v1/config.md</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/v1/config.md">https://gitee.com/abgox/InputTip/blob/main/src/v1/config.md</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值`n-------------------------------------------------------------------------------------------")
        offset_x := readIni('offset_x', 30), offset_y := readIni('offset_y', -50)
        configList := [{
            config: "font_family",
            options: "",
            tip: "字体名称"
        }, {
            config: "font_size",
            options: "Number",
            tip: "字体大小"
        }, {
            config: "font_weight",
            options: "Number",
            tip: "字体粗细"
        }, {
            config: "font_color",
            options: "",
            tip: "字体颜色"
        }, {
            config: "font_bgcolor",
            options: "",
            tip: "背景颜色"
        }, {
            config: "windowTransparent",
            options: "Number",
            tip: "显示字符的透明度"
        }, {
            config: "offset_x",
            options: "",
            tip: "显示字符的水平偏移量"
        }, {
            config: "offset_y",
            options: "",
            tip: "显示字符的垂直偏移量"
        }, {
            config: "CN_Text",
            options: "",
            tip: "中文状态时显示的字符"
        }, {
            config: "EN_Text",
            options: "",
            tip: "英文状态时显示的字符"
        }, {
            config: "Caps_Text",
            options: "",
            tip: "大写锁定状态时显示的字符"
        }]
        isFirst := 1
        for v in configList {
            if (isFirst) {
                configGui.AddText("xs", v.tip ": ")
            } else {
                configGui.AddText("yp x" Gui_width / 2, v.tip ": ")
            }
            isFirst := !isFirst
            configGui.AddEdit("v" v.config " yp w100 " v.options, %v.config%)
        }
        configGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", changeConfig)
        changeConfig(*) {
            isColor(v) {
                v := StrReplace(v, "#", "")
                colorList := ",red,blue,green,yellow,purple,gray,black,white,"
                if (RegExMatch(colorList, "," v ",")) {
                    return 1
                }
                if (StrLen(v) > 8) {
                    return 0
                }
                vList := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
                for item in vList {
                    v := StrReplace(v, item, "")
                }
                return !Trim(v)
            }
            isValid := 1
            list := [configList[2], configList[3]]
            for v in list {
                if (!IsNumber(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个数字。"])
                    isValid := 0
                }
            }
            list := [configList[4], configList[5]]
            for v in list {
                if (!isColor(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个颜色英文单词或者十六进制颜色值。", "支持的颜色英文单词: red, blue, green, yellow, purple, gray, black, white"])
                    isValid := 0
                }
            }
            windowTransparent := configGui.Submit().windowTransparent
            if (IsFloat(windowTransparent)) {
                showMsg(["配置错误!", configList[6].tip " 不能是一个小数"])
                isValid := 0
            } else {
                if (windowTransparent < 0 || windowTransparent > 255) {
                    showMsg(["配置错误!", configList[6].tip " 应该是 0 到 255 之间的整数。"])
                    isValid := 0
                }
            }
            list := [configList[7], configList[8]]
            for v in list {
                if (!IsNumber(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个数字。"])
                    isValid := 0
                }
            }
            if(isValid){
                for item in configList {
                    writeIni(item.config, configGui.Submit().%item.config%)
                }
                fn_restart()
            }
        }
        configGui.Show()
    }
    sub1 := Menu()
    fn_common(tipList, addFn) {
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
                addGui.Show("Hide")
                addGui.GetPos(, , &Gui_width)
                addGui.Destroy()

                addGui := Gui("AlwaysOnTop OwnDialogs")
                addGui.SetFont("s12", "微软雅黑")
                addGui.AddText(, tipList[4])
                addGui.AddText(, tipList[5])

                LV := addGui.AddListView("r10 NoSortHdr Sort Grid w" Gui_width, ["应用", "标题"])
                LV.OnEvent("DoubleClick", LV_DoubleClick)
                value := readIni(tipList[1], "")
                value := SubStr(value, -1) = "," ? value : value ","
                temp := ""
                DetectHiddenWindows 0
                for v in WinGetList() {
                    try {
                        exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                        title := WinGetTitle("ahk_id " v)
                        if (!RegExMatch(temp, exe_name ",") && !RegExMatch(value, exe_name ",")) {
                            temp .= exe_name ","
                            LV.Add(, exe_name, WinGetTitle("ahk_id " v))
                        }
                    }
                }
                DetectHiddenWindows 1
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
                        value := readIni(tipList[1], "")
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
                            addFn(RowText)
                            writeIni(tipList[1], result RowText)
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
                value := readIni(tipList[1], "")
                valueArr := StrSplit(value, ",")

                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                rmGui.AddText(, tipList[8])
                rmGui.AddText(, tipList[9])
                rmGui.Show("Hide")
                rmGui.GetPos(, , &Gui_width)
                rmGui.Destroy()

                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                if (valueArr.Length > 0) {
                    rmGui.AddText(, tipList[8])
                    rmGui.AddText(, tipList[9])
                    LV := rmGui.AddListView("r10 NoSortHdr Sort Grid w" Gui_width, ["应用"])
                    LV.OnEvent("DoubleClick", LV_DoubleClick)
                    for v in valueArr {
                        if (Trim(v)) {
                            LV.Add(, v)
                        }
                    }
                    LV.ModifyCol(1, "Auto")
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
                            value := readIni(tipList[1], "")
                            valueArr := StrSplit(value, ",")
                            is_exist := 0
                            result := ""
                            for v in valueArr {
                                if (v = RowText) {
                                    is_exist := 1
                                } else {
                                    if (Trim(v)) {
                                        result .= "," v
                                    }
                                }
                            }
                            if (is_exist) {
                                writeIni(tipList[1], SubStr(result, 2))
                            } else {
                                MsgBox(RowText " 不存在或已经移除!", , "0x1000")
                            }
                            show()
                        }
                    }
                    rmGui.OnEvent("Close", close)
                    close(*) {
                        Run(A_ScriptFullPath)
                    }
                    rmGui.Show()
                } else {
                    rmGui.SetFont("s14", "微软雅黑")
                    rmGui.AddText(, "当前没有可以移除的应用")
                    rmgui.Show("Hide")
                    rmGui.GetPos(, , &Gui_width)
                    rmGui.Destroy()

                    rmGui := Gui("AlwaysOnTop OwnDialogs")
                    rmGui.SetFont("s12", "微软雅黑")
                    rmGui.AddText("Center w" Gui_width, "当前没有可以移除的应用")
                    rmGui.AddButton("w" Gui_width, "确定").OnEvent("Click", esc)
                    rmGui.OnEvent("Close", esc)
                    esc(*) {
                        rmGui.Destroy()
                        Run(A_ScriptFullPath)
                    }
                    rmGui.Show()
                }
            }
        }
    }
    sub1.Add("自动切换中文状态", fn_switch_CN)
    fn_switch_CN(*) {
        fn_common(
            [
                "app_CN",
                "将应用添加到自动切换中文状态的应用列表中",
                "从自动切换中文状态的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到自动切换中文状态的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 添加到自动切换中文状态的应用列表中？`n------------------------------------------------`n此列表中的效果`n- 当在此应用中，InputTip 会自动切换到中文状态",
                "以下列表中是自动切换中文状态的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip 不会再自动切换到中文状态"
            ], fn
        )
        fn(RowText) {
            value_EN := "," readIni("app_EN", "") ","
            value_Caps := "," readIni("app_Caps", "") ","
            if (RegExMatch(value_EN, "," RowText ",")) {
                valueArr := StrSplit(value_EN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
            }

            if (RegExMatch(value_Caps, "," RowText ",")) {
                valueArr := StrSplit(value_Caps, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_Caps", SubStr(result, 2))
            }
        }
    }
    sub1.Add("自动切换英文状态", fn_switch_EN)
    fn_switch_EN(*) {
        fn_common(
            [
                "app_EN",
                "将应用添加到自动切换英文状态的应用列表中",
                "从自动切换英文状态的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到自动切换英文状态的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 添加到自动切换英文状态的应用列表中？`n------------------------------------------------`n此列表中的效果`n- 当在此应用中，InputTip 会自动切换英文状态",
                "以下列表中是自动切换英文状态的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip 不会再自动切换英文状态"
            ],
            fn
        )
        fn(RowText) {
            value_CN := "," readIni("app_CN", "") ","
            value_Caps := "," readIni("app_Caps", "") ","
            if (RegExMatch(value_CN, "," RowText ",")) {
                valueArr := StrSplit(value_CN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
            }

            if (RegExMatch(value_Caps, "," RowText ",")) {
                valueArr := StrSplit(value_Caps, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_Caps", SubStr(result, 2))
            }
        }
    }
    sub1.Add("自动切换大写锁定状态", fn_switch_Caps)
    fn_switch_Caps(*) {
        fn_common(
            [
                "app_Caps",
                "将应用添加到自动切换大写锁定状态的应用列表中",
                "从自动切换大写锁定状态的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到自动切换大写锁定状态的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 添加到自动切换大写锁定状态的应用列表中？`n------------------------------------------------`n此列表中的效果`n- 当在此应用中，InputTip 会自动切换大写锁定状态",
                "以下列表中是自动切换大写锁定状态的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip 不会再自动切换大写锁定状态"
            ],
            fn
        )
        fn(RowText) {
            value_CN := "," readIni("app_CN", "") ","
            value_EN := "," readIni("app_EN", "") ","
            if (RegExMatch(value_CN, "," RowText ",")) {
                valueArr := StrSplit(value_CN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
            }

            if (RegExMatch(value_EN, "," RowText ",")) {
                valueArr := StrSplit(value_EN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
            }
        }
    }
    A_TrayMenu.Add("设置自动切换", sub1)
    sub2 := Menu()
    sub2.Add("隐藏中英文状态字符", fn_hide_CN_EN)
    fn_hide_CN_EN(*) {
        fn_common(
            [
                "app_hide_CN_EN",
                "将应用添加到隐藏中英文状态字符的应用列表中",
                "从隐藏中英文状态字符的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏中英文状态字符的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在两个隐藏列表中(隐藏中英文/输入法状态方块符号提示)，同时添加了同一个应用，只有最新的生效，另一个会被移除",
                "是否要将 ",
                " 添加到隐藏中英文状态字符的应用列表中？`n------------------------------------------------`n此列表中的效果:`n- InputTip.exe 不会根据中英文状态显示字符`n- 只会显示大写锁定字符",
                "以下列表中是隐藏中英文状态字符的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在两个隐藏列表中(隐藏中英文/输入法状态方块符号提示)，同时添加了同一个应用，只有最新的生效，另一个会被移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据中英文状态显示不同字符"
            ],
            fn
        )
        fn(RowText) {
            value := "," readIni("app_hide_state", "") ","
            if (RegExMatch(value, "," RowText ",")) {
                valueArr := StrSplit(value, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_hide_state", SubStr(result, 2))
            }
        }
    }
    A_TrayMenu.Add("设置特殊软件", sub2)
    A_TrayMenu.Add("关于", about)
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
        aboutGui.AddText(, "当前版本: " currentVersion)
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
    A_TrayMenu.Add("重启", fn_restart)
    fn_restart(*) {
        Run(A_ScriptFullPath)
    }
    A_TrayMenu.Add("退出", fn_exit)
    fn_exit(*) {
        ExitApp()
    }
}
