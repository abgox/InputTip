; InputTip

try {
    keyCount := A_Args[1]
    if (!IsNumber(keyCount)) {
        keyCount := 0
    }
} catch {
    keyCount := 0
}

gc := {
    init: 0,
    timer: 0,
    stateTimer: 0,
    tab: 0,
    ; 记录窗口 Gui，同一个 Gui 只允许存在一个
    w: {
        updateGui: "",
        subGui: ""
    }
}

var := {
    stateList: ["CN", "EN", "Caps", "JP", "KR"],
    stateVal: {
        CN: {
            id: 1,
            text: i18n("state.CN"),
            color: "0xFF0000",
            colorText: "red",
            picture: "default-triangle-red.png"
        },
        EN: {
            id: 0,
            text: i18n("state.EN"),
            color: "0x0000FF",
            colorText: "blue",
            picture: "default-triangle-blue.png"
        },
        Caps: {
            text: i18n("state.Caps"),
            color: "0x008000",
            colorText: "green",
            picture: "default-triangle-green.png"
        },
        JP: {
            text: i18n("state.JP"),
            color: "0xCCCC00",
            colorText: "yellow",
            picture: "default-triangle-yellow.png"
        },
        KR: {
            text: i18n("state.KR"),
            color: "0x800080",
            colorText: "purple",
            picture: "default-triangle-purple.png"
        },
    },
    screenNum: SysGet(80),
    screenList: getScreenInfo(),
    ; 光标捕获模式
    modeNameList: ["HOOK", "UIA", "GUI_UIA", "MSAA", "HOOK_DLL", "WPF", "ACC", "JAB"],
    cursorInfo: Map(
        "Arrow", [32512, "aero_arrow.cur"],  ; 普通选择
        "IBeam", [32513, "beam_m.cur"],  ; 文本选择/文本输入
        "Wait", [32514, "aero_busy.ani"],  ; 繁忙
        "Crosshair", [32515, "cross_m.cur"],  ; 精度选择
        "UpArrow", [32516, "aero_up.cur"],  ; 备用选择
        "SizeNWSE", [32642, "aero_nwse.cur"],  ; 对角线调整大小 左上=>右下
        "SizeNESW", [32643, "aero_nesw.cur"],  ; 对角线调整大小 左下=>右上
        "SizeWE", [32644, "aero_ew.cur"],  ; 水平调整大小
        "SizeNS", [32645, "aero_ns.cur"],  ; 垂直调整大小
        "SizeAll", [32646, "aero_move.cur"],  ; 移动
        "No", [32648, "aero_unavail.cur"],  ; 无法(禁用)
        "Hand", [32649, "aero_link.cur"],  ; 链接选择
        "AppStarting", [32650, "aero_working.ani"],  ; 在后台工作
        "Help", [32651, "aero_helpsel.cur"],  ; 帮助选择
        "Pin", [32671, "aero_pin.cur"],  ; 位置选择
        "Person", [32672, "aero_person.cur"],  ; 人员选择
        "NWPen", [32631, "aero_pen.cur"],  ; 手写
    ),
    ; 设置
    language: currentLang,
    ; 开机自启动
    launchAtStartup: readIni("launchAtStartup", 0),
    ; 输入法模式
    inputMethodDetectionMode: readIni("inputMethodDetectionMode", "general"),
    ; 更新检查时间间隔，默认是 1440 分钟，即 24 小时
    updateCheckInterval: readIni("updateCheckInterval", 1440),
    ; 是否静默自动更新
    silentUpdate: readIni("silentUpdate", 0),
    ; 当运行 zip 版本时，是否直接以管理员权限运行
    runCodeWithAdmin: readIni("runCodeWithAdmin", 0),
    ; 默认输入法状态(1: 中文, 0: 英文)
    ; 在自定义模式下，如果所有规则都不匹配，则返回此默认状态
    inputMethodBaseState: Number(readIni("inputMethodBaseState", 0)),
    ; 获取输入法状态的超时时间
    inputMethodDetectionTimeout: readIni("inputMethodDetectionTimeout", 200),
    ; 内部实现切换输入法状态的方式
    inputMethodSwitchState: readIni("inputMethodSwitchState", "{LShift}"),
    ; 是否保持大写锁定状态
    keepCapsLockWhenStateSwitch: readIni("keepCapsLockWhenStateSwitch", 0),
    ; 是否将输入法状态导出
    exportState: readIni("exportState", 0),
    exportStateFile: A_Temp "\abgox.InputTip.State",
    ; 快捷键: 实时显示状态码和转换码
    hotkeyShowCode: readIni("hotkeyShowCode", ""),
    ; 是否改变鼠标样式
    cursorActive: readIni("cursorActive", 0),
    ; 是否显示状态浮窗
    overlayActive: readIni("overlayActive", 0),
    overlayCornerPreference: readIni("overlayCornerPreference", 2),
    overlayAnimation: readIni("overlayAnimation", 2),
    overlayShowOnWindowChange: readIni("overlayShowOnWindowChange", 0),
    overlayHideDelay: readIni("overlayHideDelay", 2000),
    overlayTextFont: readIni("overlayTextFont", "Microsoft YaHei"),
    overlayTextSize: readIni("overlayTextSize", 22),
    overlayTextWeight: readIni("overlayTextWeight", 700),
    overlayTransparent: readIni("overlayTransparent", 222),
    overlayEdgeStyle: readIni("overlayEdgeStyle", 0),
    ; 符号
    symbolType: readIni("symbolType", 0),
    symbolTextFont: readIni("symbolTextFont", "Microsoft YaHei"),
    symbolTextEdgeStyle: readIni("symbolTextEdgeStyle", 0),
    symbolTextWeight: readIni("symbolTextWeight", 700),
    symbolTextTransparent: readIni("symbolTextTransparent", 222),
    symbolShapeEdgeStyle: readIni("symbolShapeEdgeStyle", 0),
    symbolTextCornerPreference: readIni("symbolTextCornerPreference", 3),
    symbolShapeCornerPreference: readIni("symbolShapeCornerPreference", 3),
    ; 垂直偏移量的参考原点
    symbolOffsetBaseY: readIni("symbolOffsetBaseY", "below"),
    ; 在鼠标附近显示符号
    symbolNearCursorActive: readIni("symbolNearCursorActive", 0),
    symbolNearCursorWindow: readIni("symbolNearCursorWindow", "all"),
    ; 符号显示在鼠标附近时的特殊偏移量 x
    symbolNearCursorOffsetX: readIni("symbolNearCursorOffsetX", 0),
    ; 符号显示在鼠标附近时的特殊偏移量 y
    symbolNearCursorOffsetY: readIni("symbolNearCursorOffsetY", 30),
    ; 在多少毫秒后隐藏符号，0 表示永不隐藏
    symbolHideDelay: readIni("symbolHideDelay", 0),
    menuAnimation: readIni("menuAnimation", 1),
    ; 轮询响应间隔
    pollInterval: readIni("pollInterval", 20),
    ; 托盘菜单图标
    iconRunning: readIni("iconRunning", "default-app.png"),
    iconPaused: readIni("iconPaused", "default-app-paused.png"),
    ; 启用 JAB/JetBrains 支持
    symbolJABActive: readIni("symbolJABActive", 0),
    enableKeyStats: readIni("enableKeyStats", 0),
    enableCustomTrayTip: readIni("enableCustomTrayTip", 0),
    trayTipTemplate: readIni("trayTipTemplate", i18n("trayTipTemplate.content")),
    keyStatsTemplate: readIni("keyStatsTemplate", i18n("keyStatsTemplate.content"))
}

; 自定义模式下定义的模式规则
var.inputMethodDetectionRule := readIni("inputMethodDetectionRule", "")
var.inputMethodDetectionRules := StrSplit(var.inputMethodDetectionRule, ":")

defaultSymbolMap := Map()

for v in var.stateList {
    list := [
        ["overlayText", ""],
        ["overlayBgColor", ""],
        ["overlayTextColor", "0xFFFFFF"],
        ["overlayBasePosition", "center"],
        ["overlayOffsetX", 0],
        ["overlayOffsetY", 0],
        ["symbolPicturePath", ""],
        ["symbolPictureOffsetX", -40],
        ["symbolPictureOffsetY", -5],
        ["symbolPictureWidth", 15],
        ["symbolPictureHeight", 15],
        ["symbolShapeColor", ""],
        ["symbolShapeOffsetX", 0],
        ["symbolShapeOffsetY", 10],
        ["symbolShapeWidth", 9],
        ["symbolShapeHeight", 9],
        ["symbolShapeTransparent", 222],
        ["symbolTextContent", ""],
        ["symbolTextBgColor", ""],
        ["symbolTextColor", "0xFFFFFF"],
        ["symbolTextSize", 22],
        ["symbolTextOffsetX", 0],
        ["symbolTextOffsetY", 0],
        ["hotkey", ""]
    ]
    for i in list {
        key := i[1]
        switch key {
            case "symbolPicturePath":
                val := var.stateVal.%v%.picture
            case "overlayText":
                val := var.stateVal.%v%.text
            case "symbolTextContent":
                val := SubStr(var.stateVal.%v%.text, 1, 1)
            case "overlayBgColor", "symbolTextBgColor", "symbolShapeColor":
                val := var.stateVal.%v%.color
            default:
                val := i[2]
        }
        var.%key v% := readIni(key v, val)
    }
    defaultSymbolMap.Set("default-triangle-" var.stateVal.%v%.colorText ".png", 1)

    ; XXX 不支持 JP 和 KR
    if v != "JP" && v != "KR"
        var.%"windowAutoSwitch" v% := parseMatchRules(StrSplit(readIniSection("Window.AutoSwitch." v), "`n"))
}

for v in [
    "Window.Symbol.Show", "Window.Symbol.Hide", "Window.Symbol.NearCursor",
    "Window.AutoExit", "Window.IgnoreStateSwitch"
] {
    var.%StrReplace(v, ".", "")% := parseMatchRules(StrSplit(readIniSection(v), "`n"))
}

windowSymbolOffset := parseOffsetRules(StrSplit(readIniSection("Window.Symbol.Offset"), "`n"))
screenSymbolOffset := {}

updateScreenOffset()
updateCursorMode()
updateScreenOffset() {
    for v in StrSplit(readIniSection("Screen.Symbol.Offset"), "`n") {
        kv := StrSplit(v, "=")
        part := StrSplit(kv[2], "/")
        try {
            screenSymbolOffset.%kv[1]% := { x: part[1], y: part[2] }
        } catch {
            screenSymbolOffset.%kv[1]% := { x: 0, y: 0 }
        }
    }
}

updateCursorMode() {
    modeList := {}
    for v in var.modeNameList {
        modeList.%v% := Map()
    }
    for v in StrSplit(readIniSection("Window.Symbol.CursorCapture"), "`n") {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(RegExReplace(kv[2], ":$", ""), ":", , 2)
        try modeList.%part[2]%.Set(part[1], 1)
    }
    var.modeList := modeList
}

getScreenInfo() {
    list := []
    MonitorCount := MonitorGetCount()
    MonitorPrimary := MonitorGetPrimary()
    Loop MonitorCount
    {
        MonitorGet(A_Index, &L, &T, &R, &B)
        ; MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB
        list.Push({
            main: MonitorPrimary,
            count: MonitorCount,
            num: A_Index,
            left: L,
            top: T,
            right: R,
            bottom: B,
            ; workLeft: WL,
            ; workTop: WT,
            ; workRight: WR,
            ; workBottom: WB,
        })
    }
    return list
}

isWhichScreen(screenList) {
    try {
        WinGetClientPos(&x, &y, &w, &h, "A")
        ; 窗口的中心坐标
        cx := x + w / 2
        cy := y + h / 2
    } catch {
        return { main: 0, count: 0, num: 0, left: 0, top: 0, right: 0, bottom: 0 }
    }

    for v in screenList {
        if (cx >= v.left && cx <= v.right && cy >= v.top && cy <= v.bottom) {
            return v
        }
    }
}

getLink(link, label := link) {
    return '<a href="https://' link '">' label '</a>'
}

getDocsLink(section, label := prefix section, prefix := "inputtip.abgox.com/docs/") {
    return getLink(prefix section, label)
}
getHelpLink(link) {
    return getDocsLink(link, i18n("howToUse"))
}

/**
 * 预处理窗口偏移规则
 * @param {Array} configValue 原始配置数组
 * @returns {Map} 以进程名为键的规则 Map
 */
parseOffsetRules(configValue) {
    rules := Map()
    for v in configValue {
        if (v == "")
            continue
        kv := StrSplit(v, "=", , 2)
        if kv.Length < 2
            continue
        part := StrSplit(kv[2], ":", , 5)
        if part.Length < 2
            continue
        name := part[1]
        if (name == "")
            continue
        offsetMap := Map()
        if part.Length >= 4 {
            for o in StrSplit(part[4], "|") {
                if (o == "")
                    continue
                p := StrSplit(o, "/")
                try {
                    offsetMap.Set(p[1], { x: p[2], y: p[3] })
                } catch {
                    offsetMap.Set(p[1], { x: 0, y: 0 })
                }
            }
        }
        rule := {
            isByProcess: part[2] == "1" ? 1 : 0,
            isRegex: part.Length >= 5 ? part[3] : "",
            offset: offsetMap,
            title: part.Length >= 5 ? RTrim(part[5], ":") : ""
        }
        if !rules.Has(name)
            rules.Set(name, [])
        rules.Get(name).Push(rule)
    }
    return rules
}

/**
 * 匹配窗口偏移规则
 * @param {String} exeName 程序名
 * @param {String} exeTitle 程序标题
 * @param {Map} rules 预处理后的规则 Map
 * @returns {Object|0} 命中的规则或 0
 */
matchOffsetRule(exeName, exeTitle, rules) {
    if !rules.Has(exeName)
        return 0
    byProcess := 0
    for rule in rules.Get(exeName) {
        if (rule.isByProcess) {
            byProcess := rule
            continue
        }
        isMatch := rule.isRegex ? RegExMatch(exeTitle, rule.title) : exeTitle == rule.title
        if (isMatch)
            return rule
    }
    return byProcess
}
