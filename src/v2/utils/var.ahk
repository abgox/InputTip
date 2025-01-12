; 配置菜单的字体大小
fz := "s" readIni("gui_font_size", "12")

; 输入法模式
mode := readIni("mode", 1, "InputMethod")

statusModeEN := readIni("statusModeEN", "", "InputMethod")
conversionModeEN := readIni("conversionModeEN", "", "InputMethod")
checkTimeout := readIni("checkTimeout", 500, "InputMethod")

; 是否使用 Shift 键切换输入法状态
useShift := readIni("useShift", 1)

; 是否使用白名单机制
useWhiteList := readIni("useWhiteList", 0)

; 是否改变鼠标样式
changeCursor := readIni("changeCursor", 0)

/*
符号类型
    1: 图片符号
    2: 方块符号
    3: 文本符号
*/
symbolType := readIni("symbolType", 1)

; 在多少毫秒后隐藏符号，0 表示永不隐藏
HideSymbolDelay := readIni("HideSymbolDelay", 0)

delay := readIni("delay", 50)

; 开机自启动
isStartUp := readIni("isStartUp", 0)

; 启用 JAB/JetBrains 支持
enableJetBrainsSupport := readIni("enableJetBrainsSupport", 0)

updateList(1)

screenList := getScreenInfo()

updateAppOffset(1)

updateCursorMode(1)

; 鼠标样式相关信息
cursorInfo := [{
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
}]

updateCursor(1)

for v in cursorInfo {
    if (v.type = "CROSS") {
        value := "Crosshair"
    } else if (v.type = "PEN") {
        value := "NWPen"
    } else {
        value := v.type
    }
    try {
        v.origin := replaceEnvVariables(RegRead("HKEY_CURRENT_USER\Control Panel\Cursors", value))
    }
}

updateSymbol(1)

left := 0, top := 0
lastWindow := "", lastSymbol := "", lastCursor := ""

needHide := 0
exe_name := ""
exe_str := "::"

leaveDelay := delay + 500

isWait := 0

canShowSymbol := 0

updateCursor(init := 0) {
    global CN_cursor, EN_cursor, Caps_cursor, cursorInfo

    if (!init) {
        restartJetBrains()
    }

    CN_cursor := readIni("CN_cursor", "InputTipCursor\default\CN")
    EN_cursor := readIni("EN_cursor", "InputTipCursor\default\EN")
    Caps_cursor := readIni("Caps_cursor", "InputTipCursor\default\Caps")

    cursor_dir := {
        EN: EN_cursor,
        CN: CN_cursor,
        Caps: Caps_cursor
    }

    for key in cursor_dir.OwnProps() {
        Loop Files cursor_dir.%key% "\*.*" {
            n := StrUpper(SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4))
            for v in cursorInfo {
                if (v.type = n) {
                    v.%key% := A_LoopFileFullPath
                }
            }
        }
    }
}

updateSymbol(init := 0) {
    global

    if (!init) {
        restartJetBrains()
    }
    ; 存放不同状态下的符号
    symbolGui := {
        EN: "",
        CN: "",
        Caps: ""
    }

    ; 图片符号的宽高
    pic_symbol_width := readIni('pic_symbol_width', 9) * A_ScreenDPI / 96
    pic_symbol_height := readIni('pic_symbol_height', 9) * A_ScreenDPI / 96

    ; 图片符号的路径
    CN_pic := readIni("CN_pic", "InputTipSymbol\default\CN.png")
    EN_pic := readIni("EN_pic", "InputTipSymbol\default\EN.png")
    Caps_pic := readIni("Caps_pic", "InputTipSymbol\default\Caps.png")

    ; 图片符号的偏移量
    pic_offset_x := readIni('pic_offset_x', -30)
    pic_offset_y := readIni('pic_offset_y', -40)

    ; 方块/文本符号的背景颜色
    CN_color := StrReplace(readIni("CN_color", "red"), '#', '')
    EN_color := StrReplace(readIni("EN_color", "blue"), '#', '')
    Caps_color := StrReplace(readIni("Caps_color", "green"), '#', '')

    ; 方块/文本符号的透明度
    transparent := readIni('transparent', 222)

    ; 方块/文本符号的偏移量
    offset_x := readIni('offset_x', 10)
    offset_y := readIni('offset_y', -30)
    ; 方块符号的宽高
    symbol_width := readIni('symbol_width', 6) * A_ScreenDPI / 96
    symbol_height := readIni('symbol_height', 6) * A_ScreenDPI / 96

    /*
        边框样式
        0: 无边框
        1: 样式1
        2: 样式2
        3: 样式3
    */
    border_type := readIni('border_type', 1)

    ; 文本符号相关的配置
    font_family := readIni('font_family', '微软雅黑')
    font_size := readIni('font_size', 7)
    font_weight := readIni('font_weight', 600)
    font_color := StrReplace(readIni('font_color', 'ffffff'), '#', '')
    CN_Text := readIni('CN_Text', '中')
    EN_Text := readIni('EN_Text', '英')
    Caps_Text := readIni('Caps_Text', '大')

    switch symbolType {
        case 1:
        {
            ; 图片字符
            for v in ["CN", "EN", "Caps"] {
                if (%v "_pic"%) {
                    symbolGui.%v% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    symbolGui.%v%.BackColor := "000000"
                    WinSetTransColor("000000", symbolGui.%v%)
                    symbolGui.%v%.AddPicture("w" pic_symbol_width " h" pic_symbol_height, %v "_pic"%)
                }
            }
        }
        case 2:
        {
            ; 方块符号
            for v in ["CN", "EN", "Caps"] {
                if (%v "_color"%) {
                    symbolGui.%v% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    WinSetTransparent(transparent)
                    try {
                        symbolGui.%v%.BackColor := %v "_color"%
                    }

                    switch border_type {
                        case 1: symbolGui.%v%.Opt("-LastFound +e0x00000001")
                        case 2: symbolGui.%v%.Opt("-LastFound +e0x00000200")
                        case 3: symbolGui.%v%.Opt("-LastFound +e0x00020000")
                        default: symbolGui.%v%.Opt("-LastFound")
                    }
                }
            }
        }
        case 3:
        {
            ; 文本字符
            symbolGui.fontOpt := 's' font_size * A_ScreenDPI / 96 ' c' font_color ' w' font_weight
            for v in ["CN", "EN", "Caps"] {
                if (%v "_Text"% && %v "_color"%) {
                    symbolGui.%v% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    symbolGui.%v%.MarginX := 0, symbolGui.%v%.MarginY := 0
                    try {
                        symbolGui.%v%.SetFont(symbolGui.fontOpt, font_family)
                    }
                    symbolGui.%v%.AddText(, %v "_Text"%)
                    WinSetTransparent(transparent)
                    try {
                        symbolGui.%v%.BackColor := %v "_color"%
                    }
                    switch border_type {
                        case 1: symbolGui.%v%.Opt("-LastFound +e0x00000001")
                        case 2: symbolGui.%v%.Opt("-LastFound +e0x00000200")
                        case 3: symbolGui.%v%.Opt("-LastFound +e0x00020000")
                        default: symbolGui.%v%.Opt("-LastFound")
                    }
                }
            }
        }
    }
}

reloadCursor() {
    if (changeCursor) {
        if (GetKeyState("CapsLock", "T")) {
            loadCursor("Caps", 1)
        } else {
            if (isCN()) {
                loadCursor("CN", 1)
            } else {
                loadCursor("EN", 1)
            }
        }
    }
}

reloadSymbol() {
    if (symbolType) {
        canShowSymbol := returnCanShowSymbol(&left, &top)
        if (GetKeyState("CapsLock", "T")) {
            type := "Caps"
        } else {
            if (isCN()) {
                type := "CN"
            } else {
                type := "EN"
            }
        }
        if (canShowSymbol) {
            loadSymbol(type, left, top)
        }
    }
}

pauseApp(*) {
    if (A_IsPaused) {
        A_TrayMenu.Uncheck("暂停/运行")
        reloadSymbol()
        if (enableJetBrainsSupport) {
            runJetBrains()
        }
    } else {
        A_TrayMenu.Check("暂停/运行")
        hideSymbol()
        if (enableJetBrainsSupport) {
            RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
        }
    }
    Pause(-1)
}

restartJetBrains() {
    static done := 1
    if (done && enableJetBrainsSupport) {
        SetTimer(restartAppTimer, -10)
        restartAppTimer() {
            done := 0
            RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
            if (A_IsAdmin) {
                try {
                    RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptDir '\InputTip.JAB.JetBrains.exe\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Limited;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -InputObject $task -Force', , "Hide")
                }
                Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
            } else {
                Run(A_ScriptDir "\InputTip.JAB.JetBrains.exe", , "Hide")
            }
            done := 1
        }
    }
}

updateList(init := 0) {
    global

    if (!init) {
        restartJetBrains()
    }
    ; 应用列表: 符号显示黑名单
    app_hide_state := ":" readIni('app_hide_state', '') ":"

    ; 应用列表: 符号显示白名单
    app_show_state := ":" readIni('app_show_state', '') ":"

    ; 应用列表: 自动切换到中文
    app_CN := ":" readIni('app_CN', '') ":"
    ; 应用列表: 自动切换到英文
    app_EN := ":" readIni('app_EN', '') ":"
    ; 应用列表: 自动切换到大写锁定
    app_Caps := ":" readIni('app_Caps', '') ":"
}
updateAppOffset(init := 0) {
    global app_offset := {}
    if (!init) {
        restartJetBrains()
    }
    for i, v in StrSplit(readIni("app_offset", ""), ":") {
        part := StrSplit(v, "|")
        app_offset.%part[1]% := {}
        for i, v in StrSplit(part[2], "*") {
            p := StrSplit(v, "/")
            app_offset.%part[1]%.%p[1]% := {}
            app_offset.%part[1]%.%p[1]%.x := p[2]
            app_offset.%part[1]%.%p[1]%.y := p[3]
        }
    }
}
updateCursorMode(init := 0) {
    global modeList
    if (!init) {
        restartJetBrains()
    }
    modeList := {
        HOOK: ":" arrJoin(defaultModeList.HOOK, ":") ":",
        UIA: ":" arrJoin(defaultModeList.UIA, ":") ":",
        GUI_UIA: ":" arrJoin(defaultModeList.Gui_UIA, ":") ":",
        MSAA: ":" arrJoin(defaultModeList.MSAA, ":") ":",
        HOOK_DLL: ":" arrJoin(defaultModeList.HOOK_DLL, ":") ":",
        WPF: ":" arrJoin(defaultModeList.WPF, ":") ":",
        ACC: ":" arrJoin(defaultModeList.ACC, ":") ":",
        JAB: ":" arrJoin(defaultModeList.JAB, ":") ":"
    }
    HOOK := readIni('cursor_mode_HOOK', '')
    UIA := readIni('cursor_mode_UIA', '')
    GUI_UIA := readIni('cursor_mode_GUI_UIA', '')
    MSAA := readIni('cursor_mode_MSAA', '')
    HOOK_DLL := readIni('cursor_mode_HOOK_DLL', '')
    WPF := readIni('cursor_mode_WPF', '')
    ACC := readIni('cursor_mode_ACC', '')
    JAB := readIni('cursor_mode_JAB', '')

    for item in modeNameList {
        for v in StrSplit(%item%, ":") {
            for value in modeNameList {
                modeList.%value% := StrReplace(modeList.%value%, ":" v ":", ":")
            }
        }
    }
    for item in modeNameList {
        modeList.%item% .= %item% ":"
    }
}

updateWhiteList(app) {
    if (!useWhiteList) {
        return
    }
    global app_show_state
    _app_show_state := readIni("app_show_state", "")
    if (!InStr(app_show_state, ":" app ":")) {
        if (_app_show_state) {
            _app_show_state .= ":" app
        } else {
            _app_show_state := app
        }
        app_show_state := ":" _app_show_state ":"
        writeIni("app_show_state", _app_show_state)
    }
}
