#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v2
;@AHK2Exe-SetVersion 2.7.1
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具
;@Ahk2Exe-SetCopyright Copyright (c) 2024-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource InputTipCursor.zip
#SingleInstance Force
ListLines 0
KeyHistory 0
DetectHiddenWindows True

#Include ..\utils\IME.ahk
#Include ..\utils\ini.ahk
#Include ..\utils\showMsg.ahk
#Include ..\utils\checkVersion.ahk

checkVersion("2.7.1", "v2")

try {
    mode := IniRead("InputTip.ini", "InputMethod", "mode")
} catch {
    try {
        mode := IniRead("InputTip.ini", "InputMethod", "CN")
        if (mode = 2) {
            mode := 3
        }
    } catch {
        mode := 1
    }
    writeIni("mode", mode, "InputMethod")
}
try {
    app_hide_CN_EN := IniRead("InputTip.ini", "config-v2", "app_hide_CN_EN")
} catch {
    try {
        app_hide_CN_EN := IniRead("InputTip.ini", "config-v2", "window_no_display")
    } catch {
        app_hide_CN_EN := ""
    }
    writeIni("app_hide_CN_EN", app_hide_CN_EN, "config-v2")
}

HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    changeCursor := readIni("changeCursor", 1, "Config-v2"),
    showSymbol := readIni("showSymbol", 1, "Config-v2"),
    CN_color := StrReplace(readIni("CN_color", "red", "Config-v2"), '#', ''),
    EN_color := StrReplace(readIni("EN_color", "blue", "Config-v2"), '#', ''),
    Caps_color := StrReplace(readIni("Caps_color", "green", "Config-v2"), '#', ''),
    transparent := readIni('transparent', 222, "Config-v2"),
    offset_x := readIni('offset_x', 5, "Config-v2") * A_ScreenDPI / 96,
    offset_y := readIni('offset_y', 0, "Config-v2") * A_ScreenDPI / 96,
    symbol_height := readIni('symbol_height', 7, "Config-v2") * A_ScreenDPI / 96,
    symbol_width := readIni('symbol_width', 7, "Config-v2") * A_ScreenDPI / 96,
    ; 隐藏中英文状态方块符号提示
    app_hide_CN_EN := StrSplit(app_hide_CN_EN, ','),
    ; 隐藏输入法状态方块符号提示
    app_hide_state := StrSplit(readIni('app_hide_state', '', 'Config-v2'), ',')


makeTrayMenu()

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

if (changeCursor) {
    if (!DirExist("InputTipCursor")) {
        FileExist("InputTipCursor.zip") ? 0 : FileInstall("InputTipCursor.zip", "InputTipCursor.zip", 1)
        RunWait("powershell -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_ScriptDir "'", , "Hide")
        FileDelete("InputTipCursor.zip")
    } else {
        noList := [], dirList := ["CN", "CN_Default", "EN", "EN_Default", "Caps", "Caps_Default"]
        for dir in dirList {
            if (!DirExist("InputTipCursor\" dir)) {
                noList.push(dir)
            }
        }
        if (noList.length > 0) {
            RunWait("powershell -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_AppData "\abgox-InputTipCursor-temp'", , "Hide")
            for dir in noList {
                dirCopy(A_AppData "\abgox-InputTipCursor-temp\InputTipCursor\" dir, "InputTipCursor\" dir)
            }
            DirDelete(A_AppData "\abgox-InputTipCursor-temp", 1)
        }
    }
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
state := 1, old_state := '', old_left := '', old_top := '', isShowCN := 1, isShowEN := 0, isShowCaps := 0
if (changeCursor) {
    show("CN")
    if (showSymbol) {
        TipGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
        WinSetTransparent(transparent)
        TipGui.BackColor := CN_color
        while 1 {
            is_hide_state := 0
            for v in app_hide_state {
                if (WinActive('ahk_exe ' v)) {
                    is_hide_state := 1
                    break
                }
            }
            if (is_hide_state) {
                TipGui.Hide()
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
                TipGui.Hide()
            }
            if (A_TimeIdle < 500) {
                canShowSymbol := GetCaretPosEx(&left, &top, &right, &bottom, true)
                if (GetKeyState("CapsLock", "T")) {
                    TipGui.BackColor := Caps_color
                    if (canShowSymbol) {
                        TipGui.Show("NA w" symbol_width "h" symbol_height "x" left + offset_x "y" top + offset_y)
                    } else {
                        TipGui.Hide()
                    }
                    if (!isShowCaps) {
                        show("Caps")
                    }
                    isShowCN := 0, isShowEN := 0, isShowCaps := 1
                    continue
                }
                try {
                    state := isCN(mode)
                } catch {
                    TipGui.Hide()
                    continue
                }
                if (isShowCaps) {
                    if (state) {
                        show("CN")
                        isShowCN := 1, isShowEN := 0, TipGui.BackColor := CN_color
                    } else {
                        show("EN")
                        isShowCN := 0, isShowEN := 1, TipGui.BackColor := EN_color
                    }
                    isShowCaps := 0, isShow := 1
                }
                if (state != old_state || left != old_left || top != old_top) {
                    old_state := state, old_left := left, old_top := top
                    if (state) {
                        if (!isShowCN) {
                            show("CN")
                            isShowCN := 1, isShowEN := 0, isShowCaps := 0, TipGui.BackColor := CN_color
                        }
                    } else {
                        if (!isShowEN) {
                            show("EN")
                            isShowCN := 0, isShowEN := 1, isShowCaps := 0, TipGui.BackColor := EN_color
                        }
                    }
                    isShow := !is_hide_CN_EN && canShowSymbol
                }
                if (isShow) {
                    TipGui.Show("NA w" symbol_width "h" symbol_height "x" left + offset_x "y" top + offset_y)
                    isShow := 0
                }
            }
            Sleep(50)
        }
    } else {
        while 1 {
            if (A_TimeIdle < 500) {
                if (GetKeyState("CapsLock", "T")) {
                    if (!isShowCaps) {
                        show("Caps")
                        isShowCaps := 1
                    }
                    continue
                }
                try {
                    state := isCN(mode)
                } catch {
                    continue
                }
                if (isShowCaps) {
                    state ? show("CN") : show("EN")
                    isShowCaps := 0
                }
                if (state != old_state) {
                    old_state := state
                    state ? show("CN") : show("EN")
                }
            }
            Sleep(50)
        }
    }
    show(type) {
        for v in info {
            DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%type%, "Ptr"), "Int", v.value)
        }
    }
} else {
    if (showSymbol) {
        TipGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
        WinSetTransparent(transparent)
        TipGui.BackColor := CN_color
        while 1 {
            is_hide_state := 0
            for v in app_hide_state {
                if (WinActive('ahk_exe ' v)) {
                    is_hide_state := 1
                    break
                }
            }
            if (is_hide_state) {
                TipGui.Hide()
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
                TipGui.Hide()
            }
            if (A_TimeIdle < 500) {
                canShowSymbol := GetCaretPosEx(&left, &top, &right, &bottom, true)
                if (GetKeyState("CapsLock", "T")) {
                    TipGui.BackColor := Caps_color
                    if (canShowSymbol) {
                        TipGui.Show("NA w" symbol_width "h" symbol_height "x" left + offset_x "y" top + offset_y)
                        isShowCaps := 1
                    } else {
                        TipGui.Hide()
                    }
                    continue
                }
                try {
                    state := isCN(mode)
                } catch {
                    TipGui.Hide()
                    continue
                }
                if (isShowCaps) {
                    if (state) {
                        TipGui.BackColor := CN_color
                    } else {
                        TipGui.BackColor := EN_color
                    }
                    isShowCaps := 0, isShow := 1
                }
                if (state != old_state || left != old_left || top != old_top) {
                    old_state := state, old_left := left, old_top := top, isShow := 1
                    TipGui.BackColor := state ? CN_color : EN_color
                    if (!is_hide_CN_EN && canShowSymbol) {
                        isShow := 1
                    }
                }
                if (isShow) {
                    TipGui.Show("NA w" symbol_width "h" symbol_height "x" left + offset_x "y" top + offset_y)
                    isShow := 0
                }
            }
            Sleep(50)
        }
    }
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
    sub1.Add("隐藏中英文状态方块符号提示", fn_hide_CN_EN)
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
                value := IniRead("InputTip.ini", "config-v2", tipList[1])
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
                        value := IniRead("InputTip.ini", "config-v2", tipList[1])
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
                            writeIni(tipList[1], result RowText, "Config-v2")
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
                value := IniRead("InputTip.ini", "config-v2", tipList[1])
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
                        value := IniRead("InputTip.ini", "config-v2", tipList[1])
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
                            writeIni(tipList[1], result, "Config-v2")
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
                "将应用添加到隐藏中英文状态方块符号提示的应用列表中",
                "从隐藏中英文状态方块符号提示的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏中英文状态方块符号提示的应用列表中",
                "是否要将 ",
                " 添加到隐藏中英文状态方块符号提示的应用列表中？`n在此列表中的所有应用里，InputTip.exe 都不会根据中英文状态显示不同颜色的方块符号，但会显示大写锁定方块符号",
                "以下列表中是隐藏中英文状态方块符号提示的应用列表",
                "双击应用程序，将其移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据中英文状态显示不同颜色的方块符号"
            ]
        )
    }
    sub1.Add("隐藏输入法状态方块符号提示", fn_hide_state)
    fn_hide_state(*) {
        fn_common(
            [
                "app_hide_state",
                "将应用添加到隐藏输入法状态方块符号提示的应用列表中",
                "从隐藏输入法状态方块符号提示的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏输入法状态方块符号提示的应用列表中",
                "是否要将 ",
                " 添加到隐藏输入法状态方块符号提示的应用列表中？`n在此列表中的所有应用里，InputTip.exe 都不会显示方块符号",
                "以下列表中是隐藏输入法状态方块符号提示的应用列表",
                "双击应用程序，将其移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据输入法状态显示不同颜色的方块符号"
            ]
        )
    }
    A_TrayMenu.Add("设置特殊软件", sub1)
    sub2 := Menu()
    sub2.Add("中文", fn_CN)
    sub2.Add("英文", fn_EN)
    sub2.Add("大写锁定", fn_Caps)
    A_TrayMenu.Add("设置鼠标样式", sub2)
    A_TrayMenu.Add("下载鼠标样式包", dlPackage)
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
        configGui.AddText("Center h30 ", "InputTip v2 - 更改配置")
        configGui.AddText("xs", "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/blob/main/src/v2/config.md">https://github.com/abgox/InputTip/blob/main/src/v2/config.md</a>')
        configGui.AddText("xs", "输入框中的值是配置当前的值")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("AlwaysOnTop OwnDialogs")
        configGui.SetFont("s12", "微软雅黑")
        configGui.AddText("Center h30 ", "InputTip v2 - 更改配置")
        configGui.AddText("xs", "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v2/config">https://inputtip.pages.dev/v2/config</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/v2/config.md">https://github.com/abgox/InputTip/blob/main/src/v2/config.md</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/v2/config.md">https://gitee.com/abgox/InputTip/blob/main/src/v2/config.md</a>')
        configGui.AddText("xs", "请输入框中的值是配置当前的值`n---------------------------------------------------------------------------------")

        configGui.AddText("xs", "changeCursor: ")
        configGui.AddEdit("vchangeCursor yp w100", changeCursor)
        configGui.AddText("yp x" Gui_width / 2, "showSymbol: ")
        configGui.AddEdit("vshowSymbol yp w100", showSymbol)
        configGui.AddText("xs", "CN_color: ")
        configGui.AddEdit("vCN_color yp w100", CN_color)
        configGui.AddText("yp x" Gui_width / 2, "EN_color: ")
        configGui.AddEdit("vEN_color yp w100", EN_color)
        configGui.AddText("xs", "Caps_color: ")
        configGui.AddEdit("vCaps_color yp w100", Caps_color)
        configGui.AddText("yp x" Gui_width / 2, "transparent: ")
        configGui.AddEdit("vtransparent yp w100", transparent)
        configGui.AddText("xs", "offset_x: ")
        configGui.AddEdit("voffset_x yp w100", offset_x / A_ScreenDPI * 96)
        configGui.AddText("yp x" Gui_width / 2, "offset_y: ")
        configGui.AddEdit("voffset_y yp w100", offset_y / A_ScreenDPI * 96)
        configGui.AddText("xs", "symbol_height: ")
        configGui.AddEdit("vsymbol_height yp w100", symbol_height / A_ScreenDPI * 96)
        configGui.AddText("yp x" Gui_width / 2, "symbol_width: ")
        configGui.AddEdit("vsymbol_width yp w100", symbol_width / A_ScreenDPI * 96)
        configGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", changeConfig)
        changeConfig(*) {
            configList := ["changeCursor", "showSymbol", "CN_color", "EN_color", "Caps_color", "transparent", "offset_x", "offset_y", "symbol_height", "symbol_width"]
            for item in configList {
                input := configGui.Submit().%item%
                writeIni(item, input, "Config-v2")
            }
            if (configGui.Submit().changeCursor != 1) {
                for v in info {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
                }
            }
            fn_restart()
        }
        configGui.Show()
    }
    verify(dir, folder) {
        if (!dir) {
            return
        }
        hasFile := false
        Loop Files, dir "\*", "" {
            if (A_LoopFileExt = "cur" || A_LoopFileExt = "ani") {
                hasFile := true
                break
            }
        }
        if (!hasFile) {
            MsgBox("你应该选择一个包含鼠标样式文件的文件夹。`n鼠标样式文件: 后缀名为 .cur 或 .ani 的文件", "InputTip.exe - 选择文件夹错误！", "0x10 0x1000")
            return
        }

        dir_name := StrSplit(dir, "\")[-1]
        MsgBox(dir_name)
        if (dir_name = "EN" || dir_name = "CN" || dir_name = "Caps") {
            MsgBox("不能选择 CN/EN/Caps 文件夹！", , "0x30 0x1000")
            return
        }
        try {
            DirDelete(A_ScriptDir "\InputTipCursor\" folder, 1)
            DirCopy(dir, A_ScriptDir "\InputTipCursor\" folder, 1)
        }
    }
    fn_CN(*) {
        if (!changeCursor) {
            MsgBox("请先在配置中将 changeCursor 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
            return
        }
        dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为中文鼠标样式 (不能是 CN/EN/Caps 文件夹)")
        verify(dir, 'CN')
    }
    fn_EN(*) {
        if (!changeCursor) {
            MsgBox("请先在配置中将 changeCursor 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
            return
        }
        dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为英文鼠标样式 (不能是 CN/EN/Caps 文件夹)")
        verify(dir, 'EN')
    }
    fn_Caps(*) {
        if (!changeCursor) {
            MsgBox("请先在配置中将 changeCursor 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
            return
        }
        dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为大写锁定鼠标样式 (不能是 CN/EN/Caps 文件夹)")
        verify(dir, 'Caps')
    }
    dlPackage(*) {
        dlGui := Gui("AlwaysOnTop OwnDialogs")
        dlGui.SetFont("s12", "微软雅黑")
        dlGui.AddText("Center h30", "从以下任意可用地址中下载鼠标样式包:")
        dlGui.AddLink("xs", '<a href="https://inputtip.pages.dev/releases/v2/cursorStyle.zip">https://inputtip.pages.dev/releases/v2/cursorStyle.zip</a>')
        dlGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/raw/main/src/v2/InputTipCursor.zip">https://github.com/abgox/InputTip/raw/main/src/v2/InputTipCursor.zip</a>')
        dlGui.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/raw/main/src/v2/InputTipCursor.zip">https://gitee.com/abgox/InputTip/raw/main/src/v2/InputTipCursor.zip</a>')
        dlGui.AddText("", "其中的鼠标样式已经完成适配，可以直接解压到 InputTipCursor 目录中使用")
        dlGui.OnEvent("Escape", close)
        dlGui.Show()
        close(*) {
            dlGui.Destroy()
        }
    }
    about(*) {
        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center h30", "InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center h30 w" Gui_width, "InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具")
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

replaceEnvVariables(str) {
    while RegExMatch(str, "%\w+%", &match) {
        env := match[]
        envValue := EnvGet(StrReplace(env, "%", ""))
        str := StrReplace(str, env, envValue)
    }
    return str
}

GetCaretPosEx(&left?, &top?, &right?, &bottom?, useHook := false) {
    if getCaretPosFromGui(&hwnd := 0)
        return true
    try
        className := WinGetClass(hwnd)
    catch
        className := ""
    if className ~= "^(?:Windows|Microsoft)\.UI\..+"
        funcs := [getCaretPosFromUIA, getCaretPosFromHook, getCaretPosFromMSAA]
    else if className ~= "^HwndWrapper\[PowerShell_ISE\.exe;;[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\]"
        funcs := [getCaretPosFromHook, getCaretPosFromWpfCaret]
    else
        funcs := [getCaretPosFromMSAA, getCaretPosFromUIA, getCaretPosFromHook]
    for fn in funcs {
        if fn == getCaretPosFromHook && !useHook
            continue
        if fn()
            return true
    }
    return false

    getCaretPosFromGui(&hwnd) {
        x64 := A_PtrSize == 8
        guiThreadInfo := Buffer(x64 ? 72 : 48)
        NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
            if hwnd := NumGet(guiThreadInfo, x64 ? 48 : 28, "ptr") {
                getRect(guiThreadInfo.Ptr + (x64 ? 56 : 32), &left, &top, &right, &bottom)
                scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
                clientToScreenRect(hwnd, &left, &top, &right, &bottom)
                return true
            }
            hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
        }
        return false
    }

    getCaretPosFromMSAA() {
        if !hOleacc := DllCall("LoadLibraryW", "str", "oleacc.dll", "ptr")
            return false
        hOleacc := { Ptr: hOleacc, __Delete: (_) => DllCall("FreeLibrary", "ptr", _) }
        static IID_IAccessible := guidFromString("{618736e0-3c3d-11cf-810c-00aa00389b71}")
        if !DllCall("oleacc\AccessibleObjectFromWindow", "ptr", hwnd, "uint", 0xfffffff8, "ptr", IID_IAccessible, "ptr*", accCaret := ComValue(13, 0), "int") {
            if A_PtrSize == 8 {
                varChild := Buffer(24, 0)
                NumPut("ushort", 3, varChild)
                hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int")
            }
            else {
                hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "int64", 3, "int64", 0, "int")
            }
            if !hr {
                pt := x | y << 32
                DllCall("ScreenToClient", "ptr", hwnd, "int64*", &pt)
                left := pt & 0xffffffff
                top := pt >> 32
                right := left + w
                bottom := top + h
                scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
                clientToScreenRect(hwnd, &left, &top, &right, &bottom)
                return true
            }
        }
        return false
    }

    getCaretPosFromUIA() {
        try {
            uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
            ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
            if !cacheRequest.Ptr
                return false
            ComCall(4, cacheRequest, "ptr", 10014) ; cacheRequest->AddPattern(UIA_TextPatternId);
            ComCall(4, cacheRequest, "ptr", 10024) ; cacheRequest->AddPattern(UIA_TextPattern2Id);

            ComCall(12, uia, "ptr", cacheRequest, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElementBuildCache(cacheRequest, &focusedEle);
            if !focusedEle.Ptr
                return false

            static IID_IUIAutomationTextPattern2 := guidFromString("{506a921a-fcc9-409f-b23b-37eb74106872}")
            range := ComValue(13, 0)
            ComCall(15, focusedEle, "int", 10024, "ptr", IID_IUIAutomationTextPattern2, "ptr*", textPattern := ComValue(13, 0)) ; focusedEle->GetCachedPatternAs(UIA_TextPattern2Id, IID_PPV_ARGS(&textPattern));
            if textPattern.Ptr {
                ComCall(10, textPattern, "int*", &isActive := 0, "ptr*", range) ; textPattern->GetCaretRange(&isActive, &range);
                if range.Ptr
                    goto getRangeInfo
            }
            ; If no caret range, get selection range.
            static IID_IUIAutomationTextPattern := guidFromString("{32eba289-3583-42c9-9c59-3b6d9a1e9b6a}")
            ComCall(15, focusedEle, "int", 10014, "ptr", IID_IUIAutomationTextPattern, "ptr*", textPattern) ; focusedEle->GetCachedPatternAs(UIA_TextPatternId, IID_PPV_ARGS(&textPattern));
            if textPattern.Ptr {
                ComCall(5, textPattern, "ptr*", ranges := ComValue(13, 0)) ; textPattern->GetSelection(&ranges);
                if ranges.Ptr {
                    ; Retrieve the last selection range.
                    ComCall(3, ranges, "int*", &len := 0) ; ranges->get_Length(&len);
                    if len > 0 {
                        ComCall(4, ranges, "int", len - 1, "ptr*", range) ; ranges->GetElement(len - 1, &range);
                        if range.Ptr {
                            ; Collapse the range.
                            ComCall(15, range, "int", 0, "ptr", range, "int", 1) ; range->MoveEndpointByRange(TextPatternRangeEndpoint_Start, range, TextPatternRangeEndpoint_End);
                            goto getRangeInfo
                        }
                    }
                }
            }
            return false
getRangeInfo:
            psa := 0
            ; This is a degenerate text range, we have to expand it.
            ComCall(6, range, "int", 0) ; range->ExpandToEnclosingUnit(TextUnit_Character);
            ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
            if psa {
                rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
                if rects.MaxIndex() >= 3 {
                    rects[2] := 0
                    goto end
                }
            }
            ; ExpandToEnclosingUnit by character may be invalid in some control if the range is at the end of the document.
            ; Assume that the range is at the end of the document and not in an empty line, try to expand it by line.
            ComCall(6, range, "int", 3) ; range->ExpandToEnclosingUnit(TextUnit_Line)
            ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
            if psa {
                rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
                if rects.MaxIndex() >= 3 {
                    ; Here rects is {x, y, w, h}, we take the end endpoint as the caret position.
                    rects[0] := rects[0] + rects[2]
                    rects[2] := 0
                    goto end
                }
            }
            return false
end:
            left := Round(rects[0])
            top := Round(rects[1])
            right := left + Round(rects[2])
            bottom := top + Round(rects[3])
            return true
        }
        return false
    }

    getCaretPosFromWpfCaret() {
        try {
            uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
            ComCall(8, uia, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElement(&focusedEle);
            if !focusedEle.Ptr
                return false

            ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
            if !cacheRequest.Ptr
                return false

            ComCall(17, uia, "ptr*", rawViewCondition := ComValue(13, 0)) ; uia->get_RawViewCondition(&rawViewCondition);
            if !rawViewCondition.Ptr
                return false

            ComCall(9, cacheRequest, "ptr", rawViewCondition) ; cacheRequest->put_TreeFilter(rawViewCondition);
            ComCall(3, cacheRequest, "int", 30001) ; cacheRequest->AddProperty(UIA_BoundingRectanglePropertyId);

            var := Buffer(24, 0)
            ref := ComValue(0x400C, var.Ptr)
            ref[] := ComValue(8, "WpfCaret")
            ComCall(23, uia, "int", 30012, "ptr", var, "ptr*", condition := ComValue(13, 0)) ; uia->CreatePropertyCondition(UIA_ClassNamePropertyId, CComVariant(L"WpfCaret"), &classNameCondition);
            if !condition.Ptr
                return false

            ComCall(7, focusedEle, "int", 4, "ptr", condition, "ptr", cacheRequest, "ptr*", wpfCaret := ComValue(13, 0)) ; focusedEle->FindFirstBuildCache(TreeScope_Descendants, condition, cacheRequest, &wpfCaret);
            if !wpfCaret.Ptr
                return false

            ComCall(75, wpfCaret, "ptr", rect := Buffer(16)) ; wpfCaret->get_CachedBoundingRectangle(&rect);
            getRect(rect, &left, &top, &right, &bottom)
            return true
        }
        return false
    }

    getCaretPosFromHook() {
        static WM_GET_CARET_POS := DllCall("RegisterWindowMessageW", "str", "WM_GET_CARET_POS", "uint")
        if !tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr*", &pid := 0, "uint")
            return false
        ; Update caret position
        try {
            SendMessage(0x010f, 0, 0, hwnd) ; WM_IME_COMPOSITION
        }
        ; PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ
        if !hProcess := DllCall("OpenProcess", "uint", 1082, "int", false, "uint", pid, "ptr")
            return false
        hProcess := { Ptr: hProcess, __Delete: (_) => DllCall("CloseHandle", "ptr", _) }

        isX64 := isX64Process(hProcess)
        if isX64 && A_PtrSize == 4
            return false
        if !moduleBaseMap := getModulesBases(hProcess, ["kernel32.dll", "user32.dll", "combase.dll"])
            return false
        if isX64 {
            static shellcode64 := compile(true)
            shellcode := shellcode64
        }
        else {
            static shellcode32 := compile(false)
            shellcode := shellcode32
        }
        if !mem := DllCall("VirtualAllocEx", "ptr", hProcess, "ptr", 0, "ptr", shellcode.Size, "uint", 0x1000, "uint", 0x40, "ptr")
            return false
        mem := { Ptr: mem, __Delete: (_) => DllCall("VirtualFreeEx", "ptr", hProcess, "ptr", _, "uptr", 0, "uint", 0x8000) }
        link(isX64, shellcode, mem.Ptr, moduleBaseMap["user32.dll"], moduleBaseMap["combase.dll"], hwnd, tid, WM_GET_CARET_POS, &pThreadProc, &pRect)

        if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", mem, "ptr", shellcode, "uptr", shellcode.Size, "ptr", 0)
            return false
        DllCall("FlushInstructionCache", "ptr", hProcess, "ptr", mem, "uptr", shellcode.Size)

        if !hThread := DllCall("CreateRemoteThread", "ptr", hProcess, "ptr", 0, "uptr", 0, "ptr", pThreadProc, "ptr", mem, "uint", 0, "uint*", &remoteTid := 0, "ptr")
            return false
        hThread := { Ptr: hThread, __Delete: (_) => DllCall("CloseHandle", "ptr", _) }

        if msgWaitForSingleObject(hThread)
            return false
        if !DllCall("GetExitCodeThread", "ptr", hThread, "uint*", exitCode := 0) || exitCode !== 0
            return false

        rect := Buffer(16)
        if !DllCall("ReadProcessMemory", "ptr", hProcess, "ptr", pRect, "ptr", rect, "uptr", rect.Size, "uptr*", &bytesRead := 0) || bytesRead !== rect.Size
            return false
        getRect(rect, &left, &top, &right, &bottom)
        scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
        return true

        static isX64Process(hProcess) {
            DllCall("IsWow64Process", "ptr", hProcess, "int*", &isWow64 := 0)
            if isWow64
                return false
            if A_PtrSize == 8
                return true
            DllCall("IsWow64Process", "ptr", DllCall("GetCurrentProcess", "ptr"), "int*", &isWow64)
            return isWow64
        }

        static getModulesBases(hProcess, modules) {
            hModules := Buffer(A_PtrSize * 350)
            if !DllCall("K32EnumProcessModulesEx", "ptr", hProcess, "ptr", hModules, "uint", hModules.Size, "uint*", &needed := 0, "uint", 3)
                return
            moduleBaseMap := Map()
            moduleBaseMap.CaseSense := false
            for v in modules
                moduleBaseMap[v] := 0
            cnt := modules.Length
            loop Min(350, needed) {
                hModule := NumGet(hModules, A_PtrSize * (A_Index - 1), "ptr")
                VarSetStrCapacity(&name, 12)
                if DllCall("K32GetModuleBaseNameW", "ptr", hProcess, "ptr", hModule, "str", &name, "uint", 13) {
                    if moduleBaseMap.Has(name) {
                        moduleInfo := Buffer(24)
                        if !DllCall("K32GetModuleInformation", "ptr", hProcess, "ptr", hModule, "ptr", moduleInfo, "uint", moduleInfo.Size)
                            return
                        if !base := NumGet(moduleInfo, "ptr")
                            return
                        moduleBaseMap[name] := base
                        cnt--
                    }
                }
            } until cnt == 0
            if cnt == 0
                return moduleBaseMap
        }

        static compile(x64) {
            if x64
                shellcodeBase64 := "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABrnppSh2UjT6uenH1oPjxQAeiAqiEg0hGT4ABgsGe4blNldFdpbmRvd3NIb29rRXhXAAAAVW5ob29rV2luZG93c0hvb2tFeABDYWxsTmV4dEhvb2tFeAAAAAAAAFNlbmRNZXNzYWdlVGltZW91dFcAQ29DcmVhdGVJbnN0YW5jZQAAAAAAAAAASIlcJAhIiXQkEFdIg+wgSYvYSIvyi/mFyXgjSIXbdB6LBQb///9BOUAQdRJIjQ3d/v//6JgBAACJBfL+//9Iiw3L/v//SI0VdP///+jnAgAASIXAdRBIi1wkMEiLdCQ4SIPEIF/DTIvLTIvGi9czyUiLXCQwSIt0JDhIg8QgX0j/4MzMzMzMzDPAw8zMzMzMQFNWSIPsSIvySIvZSIXJdQy4VwAHgEiDxEheW8NIi0kISI1UJGBIiVQkKEG4/////0iNVCQwSIl8JEAz/0iJVCQgiXwkYIvWSIsBRI1PAf9QKIXAeHJIOXwkMHRrOXwkYHRlSItLCEiNVCR4SIl8JHhIiwH/UEiL+IXAeDJIi0wkeEiFyXQoSIsBSI1UJHBMi0QkMEyNSxBIiVQkIIvW/1AgSItMJHiL+EiLAf9QEEiLTCQwSIsB/1AQi8dIi3wkQEiDxEheW8NIi3wkQLgBAAAASIPESF5bw8zMzMzMzMxIhcl0VEiF0nRPTYXAdEpIiwJIhcB1HUi4wAAAAAAAAEZIOUIIdCxJxwAAAAAAuAJAAIDDSbkD6ICqISDSEUk7wXXkSLiT4ABgsGe4bkg5Qgh11EmJCDPAw7hXAAeAw8xAU0iD7EBIi9lIjZHYAAAASItJCOhPAQAASIXAdQu4AQAAAEiDxEBbwzPJx0QkWAEAAABIjVQkaEiJTCRoSIlUJCBMjUt4M9JIiUwkYEiJTCQwiUwkUEiNS2hEjUIX/9CFwA+I7wAAAEiLTCRoSIXJD4ThAAAASIsBSI1UJFD/UBiFwA+IhQAAAEiLTCRoSI1UJGBIiwH/UDiFwHhxSItMJGBIhcl0bEiLAUiNVCQw/1AwhcB4WEiLTCQwSIXJdGZIjUNISIlLMEiJQyhMjUMoSI0Vyf7//0G5AwAAAEiJEEiNBdH9//9IiUNQSI1UJFhIiUNYSI0Fxf3//0iJQ2BIiwFIiVQkIItUJFD/UBhIi0wkYEiLVCQwSIXSdA5IiwJIi8r/UBBIi0wkYEiFyXQGSIsB/1AQSItMJGhIhcl0BkiLAf9QEItEJFj32BvAg+AESIPEQFvDuAQAAABIg8RAW8PMzMzMzMxIiVwkCEiJbCQQSIl0JBhIiXwkIEyL2kyL0UiFyXRwSIXSdGtIY0E8g7wIjAAAAAB0XYuMCIgAAACFyXRSRYtMCiBJjQQKi3AkTQPKi2gcSQPyi3gYSQPqD7YaRTPA/89BixFJA9I6GnUZD7bLSYvDSSvThMl0Lw+2SAFI/8A6DAJ08EH/wEmDwQREO8d20TPASItcJAhIi2wkEEiLdCQYSIt8JCDDSWPAD7cMRotEjQBJA8Lr28zMSIlcJAhIiWwkEEiJdCQYSIl8JCBBVkiD7EBIixlIjZGIAAAASIv5SIvL6Bn///9IjZfEAAAASIvLSIvw6Af///9IjZecAAAASIvLSIvo6PX+//9Mi/BIhfZ0ZUiF7XRgSIXAdFtEi08YSI0VoPv//0UzwEGNSAT/1kiL8EiFwHUFjUYC6z+LVxwzwEiLTxBFM8lIiUQkMEUzwMdEJCjIAAAAiUQkIP/VSIvOSIvYQf/WSIXbdQWNQwPrCotHIOsFuAEAAABIi1wkUEiLbCRYSIt0JGBIi3wkaEiDxEBBXsM="
            else
                shellcodeBase64 := "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGuemlKHZSNPq56cfWg+PFAB6ICqISDSEZPgAGCwZ7huU2V0V2luZG93c0hvb2tFeFcAAABVbmhvb2tXaW5kb3dzSG9va0V4AENhbGxOZXh0SG9va0V4AAAAAAAAU2VuZE1lc3NhZ2VUaW1lb3V0VwBDb0NyZWF0ZUluc3RhbmNlAAAAAFZX6MkCAACDfCQMAIvwi3wkFHwYhf90FItPCDtOEHUMVuhqAQAAg8QEiUYUjYaIAAAAUP826J4CAACDxAiFwHUFX17CDABX/3QkFP90JBRqAP/QX17CDAAzwMIEAMzMzIPsFFaLdCQchfZ1DLhXAAeAXoPEFMIIAItOBI1UJARSjVQkEMdEJAgAAAAAUosBagFq//90JDBR/1AUhcB4bIN8JAwAdGWDfCQEAHRei04EjVQkHFfHRCQgAAAAAFKLAVH/UCSL+IX/eC2LVCQghdJ0JYsCi0gQjUQkDFCNRghQ/3QkGP90JDBS/9GL+ItEJCBQiwj/UQiLRCQQUIsI/1EIi8dfXoPEFMIIALgBAAAAXoPEFMIIAMyLTCQIVot0JAiF9nRfhcl0W4tUJBCF0nRTiwELQQR1IYF5CMAAAAB1CYF5DAAAAEZ0MscCAAAAALgCQACAXsIMAIE5A+iAqnXpgXkEISDSEXXggXkIk+AAYHXXgXkMsGe4bnXOiTIzwF7CDAC4VwAHgF7CDADMzMyD7BBWi3QkGI2GsAAAAFD/dgToMQEAAIvIg8QIhcl1CI1BAV6DxBDDjUQkBMdEJAQAAAAAUI1GUMdEJBwAAAAAUGoXagCNRkDHRCQYAAAAAFDHRCQgAAAAAMdEJCQBAAAA/9GFwA+IywAAAItMJASFyQ+EvwAAAIsBjVQkDFdSUf9QDIXAeHCLTCQIjVQkHFJRiwH/UByFwHhdi0wkHIXJdFmLAY1UJAxSUf9QGIXAeEaLfCQMhf90UI1OMIl+HLjcAQAAiU4YA8aNVhiJAYvGBRwBAACNTCQUUYlGNIlGOLgkAQAAagMDxlL/dCQciUY8iwdX/1AMi0wkHItUJAyF0nQKiwJS/1AIi0wkHF+FyXQGiwFR/1AIi0wkBIXJdAaLAVH/UAiLRCQQ99heG8CD4ASDxBDDuAQAAABeg8QQw7gAAAAAw8zMg+wIU1VWV4t8JByF/w+EgQAAAItcJCCF23R5i0c8g3w4fAB0b4tEOHiFwHRni0w4JDP2i1Q4IAPPi2w4GAPXiUwkEItMOBwDz4lUJByJTCQUTYorixSyA9c6KnUTis2LwyvThMl0FIpIAUA6DAJ080Y79Xcfi1QkHOvZi0QkEItMJBQPtwRwiwSBA8dfXl1bg8QIw19eXTPAW4PECMPMzFNVVleLfCQUizeNR2BQVuhM////iUQkHI2HnAAAAFBW6Dv///+L2I1HdFBW6C////+LTCQsg8QYi+iFyXRshdt0aIXtdGSLxwWUAwAAiXgBuMQAAAD/dwwDx2oAUGoE/9GJRCQUhcB1DF9eXbgCAAAAW8IEAGoAaMgAAABqAGoAagD/dxD/dwj/0/90JBSL8P/VhfZ1Cl+NRgNeXVvCBACLRxRfXl1bwgQAX15duAEAAABbwgQA"
            len := StrLen(shellcodeBase64)
            shellcode := Buffer(len * 0.75)
            if !DllCall("crypt32\CryptStringToBinary", "str", shellcodeBase64, "uint", len, "uint", 1, "ptr", shellcode, "uint*", shellcode.Size, "ptr", 0, "ptr", 0)
                return
            return shellcode
        }

        static link(x64, shellcode, shellcodeBase, user32Base, combaseBase, hwnd, tid, msg, &pThreadProc, &pRect) {
            if x64 {
                NumPut("uint64", user32Base, shellcode, 0)
                NumPut("uint64", combaseBase, shellcode, 8)
                NumPut("uint64", hwnd, shellcode, 16)
                NumPut("uint", tid, shellcode, 24)
                NumPut("uint", msg, shellcode, 28)
                pThreadProc := shellcodeBase + 0x4e0
                pRect := shellcodeBase + 56
            }
            else {
                NumPut("uint", user32Base, shellcode, 0)
                NumPut("uint", combaseBase, shellcode, 4)
                NumPut("uint", hwnd, shellcode, 8)
                NumPut("uint", tid, shellcode, 12)
                NumPut("uint", msg, shellcode, 16)
                pThreadProc := shellcodeBase + 0x43c
                pRect := shellcodeBase + 32
            }
        }

        static msgWaitForSingleObject(handle) {
            while 1 == res := DllCall("MsgWaitForMultipleObjects", "uint", 1, "ptr*", handle, "int", false, "uint", -1, "uint", 7423) { ; QS_ALLINPUT := 7423
                msg := Buffer(A_PtrSize == 8 ? 48 : 28)
                while DllCall("PeekMessageW", "ptr", msg, "ptr", 0, "uint", 0, "uint", 0, "uint", 1) { ; PM_REMOVE := 1
                    DllCall("TranslateMessage", "ptr", msg)
                    DllCall("DispatchMessageW", "ptr", msg)
                }
            }
            return res
        }
    }

    static guidFromString(str) {
        DllCall("ole32\CLSIDFromString", "str", str, "ptr", buf := Buffer(16), "hresult")
        return buf
    }

    static getRect(buf, &left, &top, &right, &bottom) {
        left := NumGet(buf, 0, "int")
        top := NumGet(buf, 4, "int")
        right := NumGet(buf, 8, "int")
        bottom := NumGet(buf, 12, "int")
    }

    static getWindowScale(hwnd) {
        if winDpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
            return A_ScreenDPI / winDpi
        return 1
    }

    static scaleRect(scale, &left, &top, &right, &bottom) {
        left := Round(left * scale)
        top := Round(top * scale)
        right := Round(right * scale)
        bottom := Round(bottom * scale)
    }

    static clientToScreenRect(hwnd, &left, &top, &right, &bottom) {
        w := right - left
        h := bottom - top
        pt := left | top << 32
        DllCall("ClientToScreen", "ptr", hwnd, "int64*", &pt)
        left := pt & 0xffffffff
        top := pt >> 32
        right := left + w
        bottom := top + h
    }
}
