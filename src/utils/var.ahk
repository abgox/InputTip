; InputTip

; 更新检查时间间隔，默认是 1440 分钟，即 24 小时
checkUpdateDelay := readIni("checkUpdateDelay", 1440)

; 输入法模式
mode := readIni("mode", 1, "InputMethod")

; 光标获取模式
modeList := {}

; 默认输入法状态(1: 中文, 0: 英文)
; 在自定义模式下，如果所有规则都不匹配，则返回此状态
baseStatus := readIni("baseStatus", 0, "InputMethod")

; 自定义模式下定义的模式规则
modeRule := readIni("modeRule", "", "InputMethod")
modeRules := StrSplit(modeRule, ":")

; 获取输入法状态的超时时间
checkTimeout := readIni("checkTimeout", 500, "InputMethod")

; 指定内部实现切换输入法状态的方式
switchStatus := readIni("switchStatus", 1)
switchStatusList := ["{LShift}", "{RShift}", "^{Space}"]

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
; 符号的垂直偏移量的参考原点
symbolOffsetBase := readIni("symbolOffsetBase", 0)

; 是否在任意窗口中，符号都显示在鼠标附近
showCursorPos := readIni("showCursorPos", 0)
; 需要将符号显示在鼠标附近的窗口列表
ShowNearCursor := StrSplit(readIniSection("ShowNearCursor"), "`n")
; 符号显示在鼠标附近时的特殊偏移量 x
showCursorPos_x := readIni("showCursorPos_x", 0)
; 符号显示在鼠标附近时的特殊偏移量 y
showCursorPos_y := readIni("showCursorPos_y", -20)

; 当鼠标悬浮在符号上时，符号是否需要隐藏
hoverHide := readIni("hoverHide", 1)

; 在多少毫秒后隐藏符号，0 表示永不隐藏
hideSymbolDelay := readIni("hideSymbolDelay", 0)

; 每多少毫秒后更新符号的显示位置和状态
delay := readIni("delay", 20)

; 托盘菜单图标
iconRunning := readIni("iconRunning", "InputTipSymbol\default\favicon.png")
iconPaused := readIni("iconPaused", "InputTipSymbol\default\favicon-pause.png")

; 开机自启动
isStartUp := readIni("isStartUp", 0)

; 启用 JAB/JetBrains 支持
enableJABSupport := readIni("enableJABSupport", 0)

; 快捷键: 切换到中文
hotkey_CN := readIni('hotkey_CN', '')
; 快捷键: 切换到英文
hotkey_EN := readIni('hotkey_EN', '')
; 快捷键: 切换到大写锁定
hotkey_Caps := readIni('hotkey_Caps', '')
; 快捷键: 软件启停
hotkey_Pause := readIni('hotkey_Pause', '')
; 快捷键: 实时显示状态码和切换码
hotkey_ShowCode := readIni('hotkey_ShowCode', '')

stateMap := {
    CN: "中文状态",
    1: "中文状态",
    EN: "英文状态",
    0: "英文状态",
    Caps: "大写锁定"
}
stateTextMap := {
    中文状态: "CN",
    英文状态: "EN",
    大写锁定: "Caps"
}

left := 0, top := 0, right := 0, bottom := 0
lastWindow := "", lastSymbol := "", lastCursor := ""

needHide := 0
exe_name := ""
exe_str := "::"
exe_title := ""

leaveDelay := delay + 500

isWait := 0

; 配置菜单默认的宽度参考线
gui_width_line := "------------------------------------------------------------------------------------"

gui_help_tip := "你首先应该点击上方的【关于】或相关文档查看此菜单的使用说明"

canShowSymbol := 0

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

updateCursor(init := 0) {
    global CN_cursor, EN_cursor, Caps_cursor, cursorInfo

    if (!init) {
        restartJAB()
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
            n := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4)
            for v in cursorInfo {
                if (v.type = n) {
                    v.%key% := A_LoopFileFullPath
                }
            }
        }
    }
}
loadCursor(state, change := 0) {
    global lastCursor
    if (changeCursor) {
        if (state != lastCursor || change) {
            for v in cursorInfo {
                if (v.%state%) {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%state%, "Ptr"), "Int", v.value)
                }
            }
            lastCursor := state
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

updateSymbol(init := 0) {
    global symbolGui, symbolConfig

    hideSymbol()

    if (!init) {
        restartJAB()
    }
    ; 存放不同状态下的符号
    symbolGui := {
        EN: "",
        CN: "",
        Caps: ""
    }
    symbolConfig := {
        ; 启用独立配置
        enableIsolateConfigPic: readIni("enableIsolateConfigPic", 0),
        enableIsolateConfigBlock: readIni("enableIsolateConfigBlock", 0),
        enableIsolateConfigText: readIni("enableIsolateConfigText", 0),
    }

    infoCN := {
        CN_color: "red",
        CN_Text: "中",
        textSymbol_CN_color: "red",
    }
    infoEN := {
        EN_color: "blue",
        EN_Text: "英",
        textSymbol_EN_color: "blue",
    }
    infoCaps := {
        Caps_color: "green",
        Caps_Text: "大",
        textSymbol_Caps_color: "green",
    }

    for state in ["", "CN", "EN", "Caps"] {
        ; * 图片字符相关配置
        ; 文件路径
        if (state) {
            symbolConfig.%state "_pic"% := readIni(state "_pic", "InputTipSymbol\default\" state ".png")
        }
        ; 偏移量
        _ := "pic_offset_x" state
        symbolConfig.%_% := readIni(_, -30)
        _ := "pic_offset_y" state
        symbolConfig.%_% := readIni(_, -40)
        ; 宽高
        _ := "pic_symbol_width" state
        symbolConfig.%_% := readIni(_, 15)
        _ := "pic_symbol_height" state
        symbolConfig.%_% := readIni(_, 15)

        ; * 方块符号相关配置
        ; 背景颜色
        if (state) {
            _ := state "_color"
            symbolConfig.%_% := StrReplace(readIni(_, %"info" state%.%_%), '#', '')
        }
        ; 偏移量
        _ := "offset_x" state
        symbolConfig.%_% := readIni(_, 10)
        _ := "offset_y" state
        symbolConfig.%_% := readIni(_, -30)
        ; 透明度
        _ := "transparent" state
        symbolConfig.%_% := readIni(_, 222)
        ; 宽高
        _ := "symbol_width" state
        symbolConfig.%_% := readIni(_, 9)
        _ := "symbol_height" state
        symbolConfig.%_% := readIni(_, 9)
        ; 边框样式: 0(无边框),1(样式1),2(样式2),3(样式3)
        _ := "border_type" state
        symbolConfig.%_% := readIni(_, 1)

        ; * 文本符号相关配置
        ; 文本字符
        if (state) {
            _ := state "_Text"
            symbolConfig.%_% := readIni(_, %"info" state%.%_%)
        }
        ; 背景颜色
        if (state) {
            _ := "textSymbol_" state "_color"
            symbolConfig.%_% := StrReplace(readIni(_, %"info" state%.%_%), '#', '')
        }
        ; 字体
        _ := "font_family" state
        symbolConfig.%_% := readIni(_, 'Microsoft YaHei')
        ; 大小
        _ := "font_size" state
        symbolConfig.%_% := readIni(_, 12)
        ; 粗细
        _ := "font_weight" state
        symbolConfig.%_% := readIni(_, 600)
        ; 颜色
        _ := "font_color" state
        symbolConfig.%_% := StrReplace(readIni(_, 'ffffff'), '#', '')
        ; 偏移量
        _ := "textSymbol_offset_x" state
        symbolConfig.%_% := readIni(_, 0)
        _ := "textSymbol_offset_y" state
        symbolConfig.%_% := readIni(_, -45)
        ; 透明度
        _ := "textSymbol_transparent" state
        symbolConfig.%_% := readIni(_, 222)
        ; 边框样式: 0(无边框),1(样式1),2(样式2),3(样式3)
        _ := "textSymbol_border_type" state
        symbolConfig.%_% := readIni(_, 1)
    }

    switch symbolType {
        case 1:
            ; 图片字符
            for state in ["CN", "EN", "Caps"] {
                pic_path := symbolConfig.%state "_pic"%
                if (pic_path) {
                    _ := symbolGui.%state% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    _.BackColor := "000000"
                    WinSetTransColor("000000", _)

                    if (symbolConfig.enableIsolateConfigPic) {
                        w := symbolConfig.%"pic_symbol_width" state%
                        h := symbolConfig.%"pic_symbol_height" state%
                    } else {
                        w := symbolConfig.pic_symbol_width
                        h := symbolConfig.pic_symbol_height
                    }
                    try {
                        _.AddPicture("w" w " h" h, pic_path)
                    }
                }
            }
        case 2:
            ; 方块符号
            for state in ["CN", "EN", "Caps"] {
                if (symbolConfig.%state "_color"%) {
                    _ := symbolGui.%state% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    __ := symbolConfig.enableIsolateConfigBlock

                    t := __ ? symbolConfig.%"transparent" state% : symbolConfig.transparent
                    WinSetTransparent(t)

                    try {
                        _.BackColor := symbolConfig.%state "_color"%
                    }

                    bt := __ ? symbolConfig.%"border_type" state% : symbolConfig.border_type
                    _.Opt("-LastFound")
                    switch bt {
                        case 1: _.Opt("+e0x00000001")
                        case 2: _.Opt("+e0x00000200")
                        case 3: _.Opt("+e0x00020000")
                    }
                }
            }
        case 3:
            ; 文本符号
            for state in ["CN", "EN", "Caps"] {
                if (symbolConfig.%state "_Text"%) {
                    _ := symbolGui.%state% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    __ := symbolConfig.enableIsolateConfigText

                    _.MarginX := 0, _.MarginY := 0

                    ff := __ ? symbolConfig.%"font_family" state% : symbolConfig.font_family
                    fz := __ ? symbolConfig.%"font_size" state% : symbolConfig.font_size
                    fc := __ ? symbolConfig.%"font_color" state% : symbolConfig.font_color
                    fw := __ ? symbolConfig.%"font_weight" state% : symbolConfig.font_weight
                    try {
                        _.SetFont('s' fz ' c' fc ' w' fw, ff)
                    }

                    _.AddText(, symbolConfig.%state "_Text"%)

                    t := __ ? symbolConfig.%"textSymbol_transparent" state% : symbolConfig.textSymbol_transparent
                    WinSetTransparent(t)

                    try {
                        _.BackColor := symbolConfig.%"textSymbol_" state "_color"%
                    }

                    bt := __ ? symbolConfig.%"textSymbol_border_type" state% : symbolConfig.textSymbol_border_type
                    switch bt {
                        case 1: _.Opt("-LastFound +e0x00000001")
                        case 2: _.Opt("-LastFound +e0x00000200")
                        case 3: _.Opt("-LastFound +e0x00020000")
                        default: _.Opt("-LastFound")
                    }
                }
            }
    }
}
loadSymbol(state, left, top, right, bottom, isShowCursorPos := 0) {
    global lastSymbol, isOverSymbol
    static old_left := 0, old_top := 0

    if (!isShowCursorPos) {
        if (left = old_left && top = old_top) {
            ; XXX: 如果鼠标一直悬浮在符号上，同时有键盘操作，就会出现符号闪烁
            if (state = lastSymbol || (isOverSymbol && A_TimeIdleKeyboard > leaveDelay)) {
                return
            }
        } else {
            isOverSymbol := 0
        }
    }

    if (!symbolType || !canShowSymbol) {
        hideSymbol()
        return
    }
    showConfig := "NA "
    ; 在 JAB 程序中获取到的 bottom 有误，因此始终使用 top
    if (InStr(modeList.JAB, exe_str)) {
        offsetY := top
    } else {
        offsetY := symbolOffsetBase ? bottom : top
    }
    if (symbolType = 1) {
        if (symbolConfig.enableIsolateConfigPic) {
            x := symbolConfig.%"pic_offset_x" state%
            y := symbolConfig.%"pic_offset_y" state%
        } else {
            x := symbolConfig.pic_offset_x
            y := symbolConfig.pic_offset_y
        }
        if (isShowCursorPos) {
            x += showCursorPos_x
            y += showCursorPos_y
        }
        showConfig .= "x" left + x " y" y + offsetY
    } else if (symbolType = 2) {
        if (symbolConfig.enableIsolateConfigBlock) {
            w := symbolConfig.%"symbol_width" state%
            h := symbolConfig.%"symbol_height" state%
            x := symbolConfig.%"offset_x" state%
            y := symbolConfig.%"offset_y" state%
        } else {
            w := symbolConfig.symbol_width
            h := symbolConfig.symbol_height
            x := symbolConfig.offset_x
            y := symbolConfig.offset_y
        }

        if (isShowCursorPos) {
            x += showCursorPos_x
            y += showCursorPos_y
        }
        showConfig .= "w" w "h" h "x" left + x " y" y + offsetY
    } else if (symbolType = 3) {
        if (symbolConfig.enableIsolateConfigText) {
            x := symbolConfig.%"textSymbol_offset_x" state%
            y := symbolConfig.%"textSymbol_offset_y" state%
        } else {
            x := symbolConfig.textSymbol_offset_x
            y := symbolConfig.textSymbol_offset_y
        }

        if (isShowCursorPos) {
            x += showCursorPos_x
            y += showCursorPos_y
        }
        showConfig .= "x" left + x " y" y + offsetY
    }
    if (lastSymbol != state) {
        hideSymbol()
    }

    if (symbolGui.%state%) {
        symbolGui.%state%.Show(showConfig)
    }

    lastSymbol := state
    old_top := top
    old_left := left
}
reloadSymbol() {
    if (symbolType) {
        canShowSymbol := returnCanShowSymbol(&left, &top, &right, &bottom)
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
            loadSymbol(type, left, top, right, bottom)
        }
    }
}
hideSymbol() {
    for state in ["CN", "EN", "Caps"] {
        try {
            symbolGui.%state%.Hide()
        }
    }
    global lastSymbol := ""
}

pauseApp(*) {
    if (A_IsPaused) {
        updateTip(!A_IsPaused)
        A_TrayMenu.Uncheck("暂停/运行")
        setTrayIcon(iconRunning)
        reloadSymbol()
        if (enableJABSupport) {
            runJAB()
        }
    } else {
        updateTip(!A_IsPaused)
        A_TrayMenu.Check("暂停/运行")
        setTrayIcon(iconPaused)
        hideSymbol()
        if (enableJABSupport) {
            killJAB(0)
        }
    }
    Pause(-1)

    for state in ["CN", "EN", "Caps"] {
        if (%"hotkey_" state%) {
            try {
                Hotkey(%"hotkey_" state%, "Toggle")
            }
        }
    }
}
restartJAB() {
    static done := 1
    if (done && enableJABSupport) {
        SetTimer(restartAppTimer, -1)
        restartAppTimer() {
            done := 0
            killJAB(1)
            if (A_IsAdmin) {
                try {
                    Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
                }
            } else {
                global JAB_PID
                Run('"' A_AhkPath '" "' A_ScriptDir '\InputTip.JAB.JetBrains.ahk"', , "Hide", &JAB_PID)
            }
            done := 1
        }
    }
}

; 更新符号显示黑白名单和自动切换列表
updateList(init := 0) {
    global

    if (!init) {
        restartJAB()
    }
    ; 应用列表: 符号显示黑名单
    app_HideSymbol := StrSplit(readIniSection("App-HideSymbol"), "`n")

    ; 应用列表: 符号显示白名单
    app_ShowSymbol := StrSplit(readIniSection("App-ShowSymbol"), "`n")

    updateAutoSwitchList()
}

; 更新自动切换列表
updateAutoSwitchList() {
    global
    ; 应用列表: 自动切换到中文
    app_CN := StrSplit(readIniSection("App-CN"), "`n")
    ; 应用列表: 自动切换到英文
    app_EN := StrSplit(readIniSection("App-EN"), "`n")
    ; 应用列表: 自动切换到大写锁定
    app_Caps := StrSplit(readIniSection("App-Caps"), "`n")
}

/**
 * 将进程以【进程级】添加到白名单中
 * @param app 要添加的进程名称
 */
updateWhiteList(app) {
    exist := 0

    for v in StrSplit(readIniSection("App-ShowSymbol"), "`n") {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 3)
        try {
            if (part[1] == app) {
                isGlobal := part[2]
                if (isGlobal) {
                    exist := 1
                    return
                } else {
                    continue
                }
            }
        }
    }
    if (!exist) {
        id := FormatTime(A_Now, "yyyy-MM-dd-HH:mm:ss") "." A_MSec
        writeIni(id, app ":1", "App-ShowSymbol")

        global app_ShowSymbol := StrSplit(readIniSection("App-ShowSymbol"), "`n")
    }
}
updateAppOffset(init := 0) {
    global app_offset := {}
    if (!init) {
        restartJAB()
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
        restartJAB()
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

; 显示实时的状态码和切换码
showCode(*) {
    if (gc.timer) {
        gc.timer := 0
        try {
            gc.status_btn.Text := "显示实时的状态码和切换码(双击设置快捷键)"
        }
        return
    }

    gc.timer := 1
    try {
        gc.status_btn.Text := "停止显示实时的状态码和切换码(双击设置快捷键)"
    }

    SetTimer(statusTimer, 25)
    statusTimer() {
        if (!gc.timer) {
            ToolTip()
            SetTimer(, 0)
            return
        }

        info := IME.CheckInputMode()
        ToolTip("状态码: " info.statusMode "`n切换码: " info.conversionMode)
    }
}
