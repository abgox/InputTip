; 配置菜单的字体大小
fz := A_ScreenHeight < 1000 ? "s10" : "s12"

; 输入法模式
mode := readIni("mode", 1, "InputMethod")

try {
    IniRead("InputTip.ini", "InputMethod", "statusModeEN")
} catch {
    switch mode {
        case 2:
        {
            writeIni("mode", 1, "InputMethod")
        }
        case 3:
        {
            ; 讯飞输入法
            ; 中文时状态码为 2
            ; 英文时状态码为 1
            ; 切换码无规律不唯一
            writeIni("statusModeEN", ":1:", "InputMethod")
            writeIni("conversionModeEN", "", "InputMethod")
            writeIni("mode", 2, "InputMethod")
        }
        case 4:
        {
            ; 手心输入法:
            ; 中文时切换码为 1025
            ; 英文时切换码为 1
            ; 状态码一直为 1
            writeIni("statusModeEN", "", "InputMethod")
            writeIni("conversionModeEN", ":1:", "InputMethod")
            writeIni("mode", 3, "InputMethod")
        }
    }
    border_type := readIni('border_type', 1)
    if (border_type = 4) {
        writeIni('border_type', 0)
    }
}

statusModeEN := readIni("statusModeEN", "", "InputMethod")
conversionModeEN := readIni("conversionModeEN", "", "InputMethod")
checkTimeout := readIni("checkTimeout", 500, "InputMethod")

updateConfig()

; 更新配置
updateConfig() {
    global

    delay := readIni("delay", 50)
    ; 开机自启动
    isStartUp := readIni("isStartUp", 0)
    ; 启用 JetBrains 支持
    enableJetBrainsSupport := readIni("enableJetBrainsSupport", 0)
    ; JetBrains 应用列表
    JetBrains_list := ":" readIni("JetBrains_list", "") ":"
    ; 是否改变鼠标样式
    changeCursor := readIni("changeCursor", 0)
    CN_cursor := readIni("CN_cursor", "InputTipCursor\default\CN")
    EN_cursor := readIni("EN_cursor", "InputTipCursor\default\EN")
    Caps_cursor := readIni("Caps_cursor", "InputTipCursor\default\Caps")
    /*
    符号类型
        1: 图片符号
        2: 方块符号
        3: 文本符号
    */
    symbolType := readIni("symbolType", 2)
    ; 在多少毫秒后隐藏符号，0 表示永不隐藏
    HideSymbolDelay := readIni("HideSymbolDelay", 0)
    ; 方块/文本符号的背景颜色
    CN_color := StrReplace(readIni("CN_color", "red"), '#', '')
    EN_color := StrReplace(readIni("EN_color", "blue"), '#', '')
    Caps_color := StrReplace(readIni("Caps_color", "green"), '#', '')
    ; 方块/文本符号的透明度
    transparent := readIni('transparent', 222)
    ; 方块/文本符号的偏移量
    offset_x := readIni('offset_x', 10)
    offset_y := readIni('offset_y', -15)
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

    ; 图片符号的路径
    CN_pic := readIni("CN_pic", "InputTipSymbol\default\CN.png")
    EN_pic := readIni("EN_pic", "InputTipSymbol\default\EN.png")
    Caps_pic := readIni("Caps_pic", "InputTipSymbol\default\Caps.png")
    ; 图片符号的偏移量
    pic_offset_x := readIni('pic_offset_x', -22)
    pic_offset_y := readIni('pic_offset_y', -40)
    ; 图片符号的宽高
    pic_symbol_width := readIni('pic_symbol_width', 9) * A_ScreenDPI / 96
    pic_symbol_height := readIni('pic_symbol_height', 9) * A_ScreenDPI / 96

    ; 应用列表: 符号显示黑名单
    app_hide_state := ":" readIni('app_hide_state', '') ":"

    ; 应用列表: 自动切换到中文
    app_CN := ":" readIni('app_CN', '') ":"
    ; 应用列表: 自动切换到英文
    app_EN := ":" readIni('app_EN', '') ":"
    ; 应用列表: 自动切换到大写锁定
    app_Caps := ":" readIni('app_Caps', '') ":"

    screenList := getScreenInfo()

    ; 文本符号相关的配置
    font_family := readIni('font_family', '微软雅黑')
    font_size := readIni('font_size', 7)
    font_weight := readIni('font_weight', 600)
    font_color := StrReplace(readIni('font_color', 'ffffff'), '#', '')
    CN_Text := readIni('CN_Text', '中')
    EN_Text := readIni('EN_Text', '英')
    Caps_Text := readIni('Caps_Text', '大')

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

    ; 存放不同状态下的符号
    symbolGui := {
        EN: "",
        CN: "",
        Caps: ""
    }

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
                    symbolGui.%v%.BackColor := %v "_color"%
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
                    symbolGui.%v%.SetFont(symbolGui.fontOpt, font_family)
                    symbolGui.%v%.AddText(, %v "_Text"%)
                    WinSetTransparent(transparent)
                    symbolGui.%v%.BackColor := %v "_color"%
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

    state := 0, old_state := ''
    left := 0, old_left := ''
    top := 0, old_top := ''

    lastWindow := "", lastType := "", lastGui := symbolGui.EN

    needHide := 0
    exe_name := ""
    exe_str := "::"
    needShow := 0

    leaveDelay := delay + 500

    isWait := 0
}

pauseApp(*) {
    if (A_IsPaused) {
        A_TrayMenu.Uncheck("暂停/运行")
    } else {
        A_TrayMenu.Check("暂停/运行")
    }
    hideSymbol()
    Pause(-1)
}

restartJetBrains() {
    if (enableJetBrainsSupport) {
        SetTimer(timer, -100)
        timer() {
            RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
            if (A_IsAdmin) {
                try {
                    RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptDir '\InputTip.JAB.JetBrains.exe\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Limited;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -InputObject $task -Force', , "Hide")
                }
                Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
            } else {
                Run(A_ScriptDir "\InputTip.JAB.JetBrains.exe", , "Hide")
            }
        }
    }
}

updateList() {
    ; 应用列表: 符号显示黑名单
    global app_hide_state := ":" readIni('app_hide_state', '') ":"
    ; 应用列表: 自动切换到中文
    global app_CN := ":" readIni('app_CN', '') ":"
    ; 应用列表: 自动切换到英文
    global app_EN := ":" readIni('app_EN', '') ":"
    ; 应用列表: 自动切换到大写锁定
    global app_Caps := ":" readIni('app_Caps', '') ":"

    ; JetBrains 应用列表
    global JetBrains_list := ":" readIni("JetBrains_list", "") ":"

    restartJetBrains()
}
