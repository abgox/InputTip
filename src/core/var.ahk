; InputTip

try {
    keyCount := A_Args[1]
    if (!IsNumber(keyCount)) {
        keyCount := 0
    }
} catch {
    keyCount := 0
}

line50 := "------------------------------------------------"
line60 := line50 "----------"
line70 := line60 "----------"
line80 := line70 "----------"
line90 := line80 "----------"
line100 := line90 "----------"

gc := {}

var := {
    screenNum: MonitorGetCount(),
    screenList: getScreenInfo(),
    cursorInfo: Map(
        "ARROW", [32512, "aero_arrow.cur"],  ; 普通选择
        "IBEAM", [32513, "beam_m.cur"],  ; 文本选择/文本输入
        "WAIT", [32514, "aero_busy.ani"],  ; 繁忙
        "CROSSHAIR", [32515, "cross_m.cur"],  ; 精度选择
        "UPARROW", [32516, "aero_up.cur"],  ; 备用选择
        "SIZENWSE", [32642, "aero_nwse.cur"],  ; 对角线调整大小 左上=>右下
        "SIZENESW", [32643, "aero_nesw.cur"],  ; 对角线调整大小 左下=>右上
        "SIZEWE", [32644, "aero_ew.cur"],  ; 水平调整大小
        "SIZENS", [32645, "aero_ns.cur"],  ; 垂直调整大小
        "SIZEALL", [32646, "aero_move.cur"],  ; 移动
        "NO", [32648, "aero_unavail.cur"],  ; 无法(禁用)
        "HAND", [32649, "aero_link.cur"],  ; 链接选择
        "APPSTARTING", [32650, "aero_working.ani"],  ; 在后台工作
        "HELP", [32651, "aero_helpsel.cur"],  ; 帮助选择
        "PIN", [32671, "aero_pin.cur"],  ; 位置选择
        "PERSON", [32672, "aero_person.cur"],  ; 人员选择
        "NWPEN", [32631, "aero_pen.cur"],  ; 手写
    ),
    loadOnlyIBeamCursor: readIni("loadOnlyIBeamCursor", 0),
    language: currentLang,
    ; 开机自启动
    launchAtStartup: readIni("launchAtStartup", 0),
    ; 输入法模式
    inputMethodDetectionMode: readIni("inputMethodDetectionMode", "general"),
    checkUpdateOnStartup: readIni("checkUpdateOnStartup", 1),
    ; 当运行 zip 版本时，是否直接以管理员权限运行
    runCodeWithAdmin: readIni("runCodeWithAdmin", 0),
    ; 默认输入法状态，在自定义模式下，如果所有规则都不匹配，则返回此默认状态
    inputMethodBaseState: readIni("inputMethodBaseState", "EN"),
    ; 获取输入法状态的超时时间
    inputMethodDetectionTimeout: readIni("inputMethodDetectionTimeout", 200),
    ; 是否保持大写锁定状态
    keepCapsLockWhenStateSwitch: readIni("keepCapsLockWhenStateSwitch", 0),
    keepCapsLockWhenKeyboardSwitch: readIni("keepCapsLockWhenKeyboardSwitch", 0),
    ; 是否将输入法状态导出
    exportState: readIni("exportState", 0),
    exportStateFile: A_Temp "\abgox.InputTip.State",
    ; 是否改变鼠标样式
    cursorActive: readIni("cursorActive", 0),
    ; 是否显示状态悬浮小窗
    overlayActive: readIni("overlayActive", 0),
    overlayOnlyFocusScreen: readIni("overlayOnlyFocusScreen", 0),
    overlayCornerPreference: readIni("overlayCornerPreference", 3),
    overlayAnimation: readIni("overlayAnimation", 1),
    overlayReshowOnProcessChange: readIni("overlayReshowOnProcessChange", 0),
    overlayReshowOnTitleChange: readIni("overlayReshowOnTitleChange", 0),
    overlayReshowOnClassChange: readIni("overlayReshowOnClassChange", 0),
    overlayShowOnNormal: readIni("overlayShowOnNormal", 1),
    overlayShowOnMaximized: readIni("overlayShowOnMaximized", 1),
    overlayShowOnFullscreen: readIni("overlayShowOnFullscreen", 1),
    overlayHideDelay: readIni("overlayHideDelay", 2000),
    overlayShowMode: readIni("overlayShowMode", "blacklist"),
    overlayTextWeight: readIni("overlayTextWeight", 700),
    overlayTransparent: readIni("overlayTransparent", 255),
    overlayEdgeStyle: readIni("overlayEdgeStyle", 0),
    borderActive: readIni("borderActive", 0),
    borderReshowOnProcessChange: readIni("borderReshowOnProcessChange", 0),
    borderReshowOnTitleChange: readIni("borderReshowOnTitleChange", 0),
    borderReshowOnClassChange: readIni("borderReshowOnClassChange", 0),
    borderShowOnMaximizedTop: readIni("borderShowOnMaximizedTop", 1),
    borderShowOnMaximizedBottom: readIni("borderShowOnMaximizedBottom", 1),
    borderShowOnMaximizedLeft: readIni("borderShowOnMaximizedLeft", 1),
    borderShowOnMaximizedRight: readIni("borderShowOnMaximizedRight", 1),
    borderShowOnFullscreenTop: readIni("borderShowOnFullscreenTop", 1),
    borderShowOnFullscreenBottom: readIni("borderShowOnFullscreenBottom", 1),
    borderShowOnFullscreenLeft: readIni("borderShowOnFullscreenLeft", 1),
    borderShowOnFullscreenRight: readIni("borderShowOnFullscreenRight", 1),
    borderShowOnNormal: readIni("borderShowOnNormal", 1),
    borderShowOnMaximized: readIni("borderShowOnMaximized", 1),
    borderShowOnFullscreen: readIni("borderShowOnFullscreen", 1),
    borderHideDelay: readIni("borderHideDelay", 0),
    borderShowMode: readIni("borderShowMode", "blacklist"),
    borderWidthPinned: readIni("borderWidthPinned", 2),
    borderColorPinned: readIni("borderColorPinned", "0x00CCCC"),
    ; 符号
    caretSymbolType: readIni("caretSymbolType", 0),
    caretSymbolHideDelay: readIni("caretSymbolHideDelay", 0),
    caretSymbolTextEdgeStyle: readIni("caretSymbolTextEdgeStyle", 0),
    caretSymbolShapeEdgeStyle: readIni("caretSymbolShapeEdgeStyle", 0),
    caretSymbolTextCornerPreference: readIni("caretSymbolTextCornerPreference", 3),
    caretSymbolShapeCornerPreference: readIni("caretSymbolShapeCornerPreference", 3),
    ; 垂直偏移量的参考原点
    caretSymbolOriginY: readIni("caretSymbolOriginY", "below"),
    ; 在鼠标附近显示符号
    cursorSymbolType: readIni("cursorSymbolType", 0),
    cursorSymbolShowMode: readIni("cursorSymbolShowMode", "blacklist"),
    cursorSymbolHideDelay: readIni("cursorSymbolHideDelay", 0),
    cursorSymbolTextEdgeStyle: readIni("cursorSymbolTextEdgeStyle", 0),
    cursorSymbolShapeEdgeStyle: readIni("cursorSymbolShapeEdgeStyle", 0),
    cursorSymbolTextCornerPreference: readIni("cursorSymbolTextCornerPreference", 3),
    cursorSymbolShapeCornerPreference: readIni("cursorSymbolShapeCornerPreference", 3),
    menuAnimation: readIni("menuAnimation", 1),
    menuFontSize: Max(readIni("menuFontSize", 16), 12),
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

var._paused := 0

if indexOfArr([12, 14, 16, 18, 20], var.menuFontSize)
    fontOpt[1] := "s" Max(var.menuFontSize, 12)
else
    var.menuFontSize := 16
try updateUIC()

; 自定义模式下定义的模式规则
var.inputMethodDetectionRule := readIni("inputMethodDetectionRule", "")
var.inputMethodDetectionRules := StrSplit(var.inputMethodDetectionRule, "|")

defaultSymbolMap := Map()

_list := [
    ["SymbolPicturePath", "", ""],
    ["SymbolPictureOffsetX", -25, 0],
    ["SymbolPictureOffsetY", 0, 30],
    ["SymbolPictureWidth", 20, 20],
    ["SymbolPictureHeight", 20, 20],
    ["SymbolShapeColor", "", ""],
    ["SymbolShapeOffsetX", 0, 0],
    ["SymbolShapeOffsetY", 0, 30],
    ["SymbolShapeWidth", 12, 12],
    ["SymbolShapeHeight", 12, 12],
    ["SymbolShapeTransparent", 255, 255],
    ["SymbolTextContent", "", ""],
    ["SymbolTextBgColor", "", ""],
    ["SymbolTextColor", "0xFFFFFF", "0xFFFFFF"],
    ["SymbolTextFont", "Microsoft YaHei", "Microsoft YaHei"],
    ["SymbolTextWeight", 700, 700],
    ["SymbolTextTransparent", 255, 255],
    ["SymbolTextSize", 16, 16],
    ["SymbolTextOffsetX", 0, 0],
    ["SymbolTextOffsetY", 0, 30],
]

for v in stateList {
    list := [
        ["borderWidth", 2],
        ["borderColor", ""],
        ["overlayText", ""],
        ["overlayTextFont", "Microsoft YaHei"],
        ["overlayTextSize", 16],
        ["overlayTextWeight", 700],
        ["overlayTransparent", 255],
        ["overlayBgColor", ""],
        ["overlayTextColor", "0xFFFFFF"],
        ["overlayBasePosition", "topWindow"],
        ["overlayOffsetX", 0],
        ["overlayOffsetY", 0],
    ]
    for _v in _list
        list.Push(["caret" _v[1], _v[2]]), list.Push(["cursor" _v[1], _v[3]])
    for i in list {
        key := i[1]
        switch key {
            case "overlayText":
                val := i18n(v)
            case "overlayBgColor", "caretSymbolTextBgColor", "caretSymbolShapeColor", "cursorSymbolTextBgColor", "cursorSymbolShapeColor", "borderColor":
                val := stateVal.%v%.color
            case "caretSymbolPicturePath", "cursorSymbolPicturePath":
                val := "default-triangle-" stateVal.%v%.colorText ".png"
            case "caretSymbolTextContent", "cursorSymbolTextContent":
                val := isChinese ? SubStr(i18n(v), 1, 1) : v
            default:
                val := i[2]
        }
        var.%key v% := readIni(key v, val)
    }
    defaultSymbolMap.Set("default-triangle-" stateVal.%v%.colorText ".png", 1)
}

windowRuleKeys := ["process", "condition", "class", "trigger", "title", "offset", "capture", "captureOffset", "hotkey", "idleTimer", "textMonitor", "hotkeyMonitor"]

conditionKeyList := ["title", "class", "classAndTitle"]
windowConditionKeyList := ["textMonitor", "hotkeyMonitor", "idleTimer", conditionKeyList*]
conditionTextMap := Map()
for v in windowConditionKeyList
    conditionTextMap.Set(i18n("condition." v), v)


allTriggerKeyList := ["hotkey"]
switchTriggerKeyList := [
    "switchStateCaps-CapsLock",
    "switchStateCN-IME", "switchStateCN-LShift", "switchStateCN-RShift", "switchStateCN-CtrlSpace",
    "switchStateEN-IME", "switchStateEN-LShift", "switchStateEN-RShift", "switchStateEN-CtrlSpace",
    "switchStateCN/EN-IME", "switchStateCN/EN-LShift", "switchStateCN/EN-RShift", "switchStateCN/EN-CtrlSpace",
    "switchKeyboardCN", "switchKeyboardUS",
    "switchKeyboardJP", "switchKeyboardJPHiragana", "switchKeyboardJPKatakana", "switchKeyboardJPHalfKana", "switchKeyboardJPFullAlpha", "switchKeyboardJPHalfAlpha",
    "switchKeyboardKR", "switchKeyboardKRHangul", "switchKeyboardKRAlpha",
]
allTriggerKeyList.Push(switchTriggerKeyList.Clone()*)

triggerKeyList := switchTriggerKeyList.Clone()
_ := ["setWindowTop", "cancelWindowTop", "toggleWindowTop", "exit", "restart", "pause", "resume", "toggle"]
triggerKeyList.Push(_*)
allTriggerKeyList.Push(_*)

hotkeyTriggerKeyList := triggerKeyList.Clone()
hotkeyTriggerKeyList.InsertAt(1, "none")
hotkeyTriggerKeyList.Push("showStateCode", "showCaptureMode")
allTriggerKeyList.Push("none", "showStateCode", "showCaptureMode")

windowTriggerKeyList := triggerKeyList.Clone()
windowTriggerKeyList.InsertAt(1, "ignoreStateSwitch")
windowTriggerKeyList.InsertAt(15, "ignoreKeyboardSwitch")
windowTriggerKeyList.Push("showStateCode", "showCaptureMode")
allTriggerKeyList.Push("ignoreStateSwitch", "ignoreKeyboardSwitch")

triggerTextMap := Map()
for v in allTriggerKeyList
    triggerTextMap.Set(i18n("trigger." v), v)

runTriggers(triggers, *) {
    for trigger in triggers {
        switch trigger {
            case "switchStateCaps-CapsLock": _switchState("Caps", "{CapsLock}")
            case "switchStateCN-IME": _switchState("CN", "IME")
            case "switchStateCN-LShift": _switchState("CN", "{LShift}")
            case "switchStateCN-RShift": _switchState("CN", "{RShift}")
            case "switchStateCN-CtrlSpace": _switchState("CN", "{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}")
            case "switchStateEN-IME": _switchState("EN", "IME")
            case "switchStateEN-LShift": _switchState("EN", "{LShift}")
            case "switchStateEN-RShift": _switchState("EN", "{RShift}")
            case "switchStateEN-CtrlSpace": _switchState("EN", "{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}")
            case "switchStateCN/EN-IME": _switchState(currentState == "CN" ? "EN" : "CN", "IME")
            case "switchStateCN/EN-LShift": _switchState(currentState == "CN" ? "EN" : "CN", "{LShift}")
            case "switchStateCN/EN-RShift": _switchState(currentState == "CN" ? "EN" : "CN", "{RShift}")
            case "switchStateCN/EN-CtrlSpace": _switchState(currentState == "CN" ? "EN" : "CN", "{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}")
            case "switchKeyboardCN": switchKeyboard("CN")
            case "switchKeyboardUS": switchKeyboard("US")
            case "switchKeyboardJP": switchKeyboard("JP")
            case "switchKeyboardJPHiragana": switchKeyboard("JP", 1, 9)
            case "switchKeyboardJPKatakana": switchKeyboard("JP", 1, 11)
            case "switchKeyboardJPHalfKana": switchKeyboard("JP", 1, 3)
            case "switchKeyboardJPFullAlpha": switchKeyboard("JP", 1, 8)
            case "switchKeyboardJPHalfAlpha": switchKeyboard("JP", 0, 0)
            case "switchKeyboardKR": switchKeyboard("KR")
            case "switchKeyboardKRHangul": switchKeyboard("KR", 1, 1)
            case "switchKeyboardKRAlpha": switchKeyboard("KR", 1, 0)
            case "toggle": toggleApp()
            case "pause": suspendApp()
            case "resume": resumeApp()
            case "exit": SetTimer(closeApp, -500)
            case "restart": SetTimer(restartApp, -500)
            case "showStateCode": showCaptureMode(0), showStateCode(var._showStateCode := !var._showStateCode)
            case "showCaptureMode": showStateCode(0), showCaptureMode(var._showCaptureMode := !var._showCaptureMode)
            case "toggleWindowTop": try WinSetAlwaysOnTop((WinGetExStyle("A") & 0x8) ? 0 : 1, "A")
            case "setWindowTop":
                if !(WinGetExStyle("A") & 0x8)
                    try WinSetAlwaysOnTop(1, "A")
            case "cancelWindowTop": try WinSetAlwaysOnTop(0, "A")
            default:
                if !var._showStateCode
                    showStateCode(0)
                if !var._showCaptureMode
                    showCaptureMode(0)
        }
    }
    _switchState(state, key) {
        switchKeyboard("CN", , , 1), SetTimer(switchState.Bind(state, key), -20)
    }
}

returnTriggers(exeName, exeTitle, exeClass) {
    conditionalTriggers := []
    unconditionalTriggers := []

    for trigger in windowTriggerKeyList {
        rules := matchWindowRules(exeName, exeTitle, exeClass, var.WindowRule[trigger])

        for rule in rules {
            if !rule.trigger
                continue
            if rule.condition {
                if rule.condition == "idleTimer" || rule.condition == "textMonitor" || rule.condition == "hotkeyMonitor"
                    continue
                if trigger == "exit" && exeName == "explorer.exe"
                    continue
                conditionalTriggers.Push(trigger)
            } else {
                if hasProcessChange
                    unconditionalTriggers.Push(trigger)
            }
        }
    }

    unconditionalTriggers.Push(conditionalTriggers*)
    return unconditionalTriggers
}

textToState(stateText) {
    for state in stateList {
        if i18n(state) == stateText
            return state
    }
}


var._previewOffsetMap := Map() ; 用于窗口偏移量的实时预览
var._matchCache := Map()
var._ruleIds := Map()

parseWindowRule()

parseWindowRule() {
    newWindowRule := Map()
    for v in ["", windowTriggerKeyList*]
        newWindowRule.Set(v, Map())

    newWindowOverlayRule := Map(
        "show", Map(),
        "hide", Map(),
        "", Map(),
    )
    newWindowBorderRule := Map(
        "show", Map(),
        "hide", Map(),
        "", Map(),
    )
    newWindowCursorSymbolRule := Map(
        "show", Map(),
        "hide", Map(),
        "", Map(),
    )
    newWindowCaretSymbolRule := Map(
        "show", Map(),
        "hide", Map(),
        "showNearCursor", Map(),
        "offset", Map(),
        "capture", Map(),
        "", Map(),
    )
    newHotkeyRule := Map("", [])
    newWindowIdleTimerRule := Map()
    newWindowTextMonitorRule := Map()
    newWindowHotkeyMonitorRule := Map()
    for v in hotkeyTriggerKeyList
        newHotkeyRule.Set(v, Map())

    for name in StrSplit(IniRead(configFile, , , ""), "`n") {
        rule := {}

        rulePos := InStr(name, ".Rule.")
        if !rulePos
            continue
        timeStr := SubStr(name, rulePos + 6)
        rule.time := timeStr
        id := InStr(timeStr, ":") ? timeStr : StrSplit(timeStr, ".")[2]
        var._ruleIds.Set(id, 1)

        for k in windowRuleKeys
            rule.%k% := IniRead(configFile, name, k, "")
        if InStr(name, "Window.Rule.") {
            if rule.trigger == "switchKeyboardEN" {
                try IniWrite("switchKeyboardUS", configFile, name, "trigger")
                rule.trigger := "switchKeyboardUS"
            }
            if !newWindowRule.Has(rule.trigger) {
                try IniDelete(configFile, name)
                continue
            }
            triggerMap := newWindowRule[rule.trigger]
            if !triggerMap.Has(rule.process)
                triggerMap.Set(rule.process, [])
            triggerMap.Get(rule.process).Push(rule)

            if rule.condition == "idleTimer" && rule.idleTimer {
                if !newWindowIdleTimerRule.Has(rule.process)
                    newWindowIdleTimerRule.Set(rule.process, [])
                newWindowIdleTimerRule.Get(rule.process).Push(rule)
            }
            if rule.condition == "textMonitor" && rule.textMonitor != "" {
                if !newWindowTextMonitorRule.Has(rule.process)
                    newWindowTextMonitorRule.Set(rule.process, [])
                newWindowTextMonitorRule.Get(rule.process).Push(rule)
            }
            if rule.condition == "hotkeyMonitor" && rule.hotkeyMonitor != "" {
                if !newWindowHotkeyMonitorRule.Has(rule.process)
                    newWindowHotkeyMonitorRule.Set(rule.process, [])
                newWindowHotkeyMonitorRule.Get(rule.process).Push(rule)
            }
        } else if InStr(name, "Window.Overlay.Rule.") {
            if !newWindowOverlayRule.Has(rule.trigger) {
                try IniDelete(configFile, name)
                continue
            }
            triggerMap := newWindowOverlayRule[rule.trigger]
            if !triggerMap.Has(rule.process)
                triggerMap.Set(rule.process, [])
            triggerMap.Get(rule.process).Push(rule)
        } else if InStr(name, "Window.Border.Rule.") {
            if !newWindowBorderRule.Has(rule.trigger) {
                try IniDelete(configFile, name)
                continue
            }
            triggerMap := newWindowBorderRule[rule.trigger]
            if !triggerMap.Has(rule.process)
                triggerMap.Set(rule.process, [])
            triggerMap.Get(rule.process).Push(rule)
        } else if InStr(name, "Window.CursorSymbol.Rule") {
            if !newWindowCursorSymbolRule.Has(rule.trigger) {
                try IniDelete(configFile, name)
                continue
            }
            triggerMap := newWindowCursorSymbolRule[rule.trigger]
            if !triggerMap.Has(rule.process)
                triggerMap.Set(rule.process, [])
            triggerMap.Get(rule.process).Push(rule)
        } else if InStr(name, "Window.CaretSymbol.Rule.") {
            if !newWindowCaretSymbolRule.Has(rule.trigger) {
                try IniDelete(configFile, name)
                continue
            }
            triggerMap := newWindowCaretSymbolRule[rule.trigger]

            if rule.trigger == "capture" {
                triggerMap.Set(rule.process, rule)
                continue
            }

            if !triggerMap.Has(rule.process)
                triggerMap.Set(rule.process, [])
            if rule.offset {
                rule.offsetMap := Map()
                for o in StrSplit(rule.offset, "|") {
                    screenNum := SubStr(o, 1, 1)
                    posPart := StrSplit(SubStr(o, 3), "/")
                    rule.offsetMap.Set(screenNum, {
                        x: posPart[1],
                        y: posPart[2]
                    })
                }
                triggerMap.Get(rule.process).Push(rule)
                continue
            }
            triggerMap.Get(rule.process).Push(rule)
        } else if InStr(name, "Hotkey.Rule.") {
            if rule.trigger == "switchKeyboardEN" {
                try IniWrite("switchKeyboardUS", configFile, name, "trigger")
                rule.trigger := "switchKeyboardUS"
            }
            if !newHotkeyRule.Has(rule.trigger) {
                try IniDelete(configFile, name)
                continue
            }
            for k in windowRuleKeys
                rule.%k% := IniRead(configFile, name, k, "")
            if !newHotkeyRule.Has(rule.process)
                newHotkeyRule.Set(rule.process, [])
            try newHotkeyRule.Get(rule.process).Push(rule)
        }
    }

    Critical("On")

    var.WindowRule := newWindowRule
    var.WindowOverlayRule := newWindowOverlayRule
    var.WindowBorderRule := newWindowBorderRule

    var.WindowCaretSymbolRule := newWindowCaretSymbolRule
    var.WindowCursorSymbolRule := newWindowCursorSymbolRule

    var.WindowIdleTimerRule := newWindowIdleTimerRule
    var.WindowTextMonitorRule := newWindowTextMonitorRule
    var.WindowHotkeyMonitorRule := newWindowHotkeyMonitorRule

    var.hotkeyRule := newHotkeyRule

    var._showStateCode := 0
    var._showCaptureMode := 0

    var._matchCache.Clear()

    Critical("Off")
}
getMatchingRuleLists(exeName, triggerMap, hotkey := 0) {
    cacheKey := exeName . "|" . ObjPtr(triggerMap)
    if var._matchCache.Has(cacheKey)
        return var._matchCache[cacheKey]

    result := []
    if triggerMap.Has(exeName)
        result.Push(triggerMap[exeName])

    for key, ruleList in triggerMap {
        if (key == "" && !hotkey) || key == exeName
            continue
        if safeRegexMatch(exeName, key)
            result.Push(ruleList)
    }

    if result.Length > 0
        var._matchCache.Set(cacheKey, result)
    return result
}

matchCondition(rule, exeTitle, exeClass) {
    switch rule.condition {
        case "class":
            return safeRegexMatch(exeClass, rule.class)
        case "title":
            return safeRegexMatch(exeTitle, rule.title)
        case "classAndTitle":
            return safeRegexMatch(exeClass, rule.class) && safeRegexMatch(exeTitle, rule.title)
        default:
            return true
    }
}

/**
 * 匹配所有符合条件的规则
 * 规则逻辑：相同 Trigger 下只保留第一个命中的，不同 Trigger 互不影响
 * @param {String} exeName 进程名
 * @param {String} exeTitle 窗口标题
 * @param {String} exeClass 窗口类名
 * @param {Map} triggerMap 包含所有规则的 Map
 * @returns {Array} 命中的规则数组
 */
matchWindowRules(exeName, exeTitle, exeClass, triggerMap) {
    conditionalTriggers := []
    unconditionalTriggers := []

    ruleLists := getMatchingRuleLists(exeName, triggerMap)
    if ruleLists.Length == 0
        return unconditionalTriggers

    for ruleList in ruleLists {
        for rule in ruleList {
            if !rule.trigger
                continue

            isMatch := matchCondition(rule, exeTitle, exeClass)

            if !isMatch
                continue

            if rule.condition {
                conditionalTriggers.Push(rule)
            } else {
                if hasProcessChange
                    unconditionalTriggers.Push(rule)
            }
        }
    }

    unconditionalTriggers.Push(conditionalTriggers*)
    return unconditionalTriggers
}

matchWindowDisplay(exeName, exeTitle, exeClass, triggerMap) {
    ruleLists := getMatchingRuleLists(exeName, triggerMap)
    if ruleLists.Length == 0
        return 0

    for ruleList in ruleLists {
        for rule in ruleList {
            if !rule.trigger
                continue
            if matchCondition(rule, exeTitle, exeClass)
                return 1
        }
    }
    return 0
}

symbolScreenOffset := { caret: {}, cursor: {} }

updateScreenOffset("caret")
updateScreenOffset("cursor")
updateScreenOffset(prefix) {
    val := readIni(prefix "SymbolScreenOffset", "")
    if !val
        return
    for v in StrSplit(val, "|") {
        part := StrSplit(v, "/")
        try {
            symbolScreenOffset.%prefix%.%part[1]% := { x: part[2], y: part[3] }
        } catch {
            symbolScreenOffset.%prefix%.%part[1]% := { x: 0, y: 0 }
        }
    }
}

getCaretCapture() {
    captureMap := var.WindowCaretSymbolRule["capture"]
    if captureMap.Has(exeName)
        return captureMap[exeName]
    for key, rule in captureMap {
        if key == ""
            continue
        if RegExMatch(exeName, key)
            return rule
    }
    return { capture: "", captureOffset: "" }
}

getScreenInfo() {
    list := []
    MonitorCount := MonitorGetCount()
    MonitorPrimary := MonitorGetPrimary()

    probeHwnd := DllCall("CreateWindowEx", "UInt", 0x08000000 ; WS_EX_NOACTIVATE
        , "Str", "Static", "Str", ""
        , "UInt", 0x80000000 ; WS_POPUP
        , "Int", 0, "Int", 0, "Int", 0, "Int", 0
        , "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")

    Loop MonitorCount
    {
        MonitorGet(A_Index, &L, &T, &R, &B)
        MonitorGetWorkArea(A_Index, &WL, &WT, &WR, &WB)

        currentScale := 1.0
        if probeHwnd {
            midX := (L + R) // 2
            midY := (T + B) // 2
            DllCall("SetWindowPos", "Ptr", probeHwnd, "Ptr", 0
                , "Int", midX, "Int", midY, "Int", 0, "Int", 0
                , "UInt", 0x0001 | 0x0004 | 0x0010 | 0x0040)
            realDpi := DllCall("GetDpiForWindow", "Ptr", probeHwnd, "UInt")
            currentScale := realDpi / 96
        }

        list.Push({
            main: MonitorPrimary,
            count: MonitorCount,
            num: A_Index,
            left: L,
            top: T,
            right: R,
            bottom: B,
            workLeft: WL,
            workTop: WT,
            workRight: WR,
            workBottom: WB,
            scale: currentScale ;
        })
    }
    if probeHwnd
        DllCall("DestroyWindow", "Ptr", probeHwnd)

    return list
}

isWhichScreen(hwnd := 0) {

    try {
        if hwnd
            WinGetPos(&x, &y, &w, &h, hwnd)
        else
            WinGetPos(&x, &y, &w, &h, "A")
        cx := x + w // 2
        cy := y + h // 2
    } catch {
        return { main: 0, count: 0, num: 0, left: 0, top: 0, right: 0, bottom: 0,
            workLeft: 0, workTop: 0, workRight: 0, workBottom: 0 }
    }
    primary := ""
    for v in var.screenList {
        if v.num == v.main
            primary := v
        if cx >= v.left && cx < v.right && cy >= v.top && cy < v.bottom
            return v
    }
    for v in var.screenList {
        if x >= v.left && x < v.right && y >= v.top && y < v.bottom
            return v
    }
    return primary ? primary : { main: 0, count: 0, num: 0, left: 0, top: 0, right: 0, bottom: 0,
        workLeft: 0, workTop: 0, workRight: 0, workBottom: 0 }
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

delayState := {
    timer: 0,
    isWait: 0,
    needHide: 0
}
updateSymbolDelay() {
    if !var.caretSymbolHideDelay
        return
    SetTimer(onDelayTick, 0)
    SetTimer(onDelayTick, 25)
}
onDelayTick() {
    if (var.caretSymbolHideDelay == 0) {
        SetTimer(onDelayTick, 0)
        delayState.needHide := 0
        delayState.isWait := 0
        return
    }

    if (GetKeyState("LButton", "P")) {
        delayState.needHide := 0
        delayState.isWait := 1
        SetTimer(() => delayState.isWait := 0, -returnMaxTimerNumber(var.caretSymbolHideDelay))
    }

    if A_TimeIdleKeyboard <= leaveDelay
        delayState.timer := 0

    if (!delayState.isWait) {
        if (A_TimeIdleKeyboard >= var.caretSymbolHideDelay - var.pollInterval
            || delayState.timer >= var.caretSymbolHideDelay) {
            delayState.needHide := 1
            hideCaretSymbol()
            delayState.timer := 0
        } else {
            delayState.needHide := 0
        }
    }
    delayState.timer += 25
}

cursorDelayState := {
    hidden: 0,
    timer: 0
}

updateCursorDelay() {
    if !var.cursorSymbolHideDelay
        return
    cursorDelayState.hidden := 0
    SetTimer(onCursorDelayTick, 0)
    SetTimer(onCursorDelayTick, 25)
}

onCursorDelayTick() {
    if !var.cursorSymbolHideDelay {
        SetTimer(onCursorDelayTick, 0)
        return
    }
    if cursorDelayState.hidden {
        if A_TimeIdleMouse < 100
            cursorDelayState.hidden := 0
        return
    }
    if A_TimeIdleMouse >= var.cursorSymbolHideDelay {
        cursorDelayState.hidden := 1
        hideCursorSymbol()
    }
}

initMonitor() {
    ; 空闲计时器
    clearIdleTimer()
    runIdleTimer()

    ; 文本监控
    newTextRules := []
    for ruleList in getMatchingRuleLists(exeName, var.WindowTextMonitorRule) {
        for rule in ruleList
            newTextRules.Push({ textMonitor: rule.textMonitor, trigger: rule.trigger })
    }
    stopTextMonitor()
    startTextMonitor(newTextRules)

    ; 热键监控
    newHotkeyRules := []
    for ruleList in getMatchingRuleLists(exeName, var.WindowHotkeyMonitorRule) {
        for rule in ruleList
            newHotkeyRules.Push({ hotkeyMonitor: rule.hotkeyMonitor, trigger: rule.trigger })
    }
    stopHotkeyMonitor()
    startHotkeyMonitor(newHotkeyRules)
}

; 空闲计时器
idleTimer := {
    timer: 0,
    delay: 0,
    trigger: ""
}
updateIdleTimer(delay, trigger) {
    idleTimer.timer := 0
    idleTimer.delay := delay
    idleTimer.trigger := trigger
    SetTimer(onIdleTimerTick, 50)
}
clearIdleTimer() {
    SetTimer(onIdleTimerTick, 0)
    idleTimer.timer := 0
    idleTimer.delay := 0
    idleTimer.trigger := ""
}
onIdleTimerTick() {
    if idleTimer.delay == 0 || !IsNumber(idleTimer.delay) {
        SetTimer(onIdleTimerTick, 0)
        return
    }
    if A_TimeIdleKeyboard <= leaveDelay {
        idleTimer.timer := 0
        return
    }
    idleTimer.timer += 50
    if idleTimer.timer >= idleTimer.delay {
        SetTimer(onIdleTimerTick, 0)
        idleTimer.timer := 0
        trigger := idleTimer.trigger
        idleTimer.trigger := ""
        idleTimer.delay := 0
        runTriggers([trigger])
        runIdleTimer()
    }
}

runIdleTimer() {
    for ruleList in getMatchingRuleLists(exeName, var.WindowIdleTimerRule) {
        for rule in ruleList {
            if !matchWindowRules(exeName, exeTitle, exeClass, var.WindowRule[rule.trigger]).Length
                continue
            updateIdleTimer(rule.idleTimer, rule.trigger)
            return
        }
    }
}

textMonitorState := {
    ih: 0,
    rules: [],
    buffer: ""
}

parseTextRule(userRegex) {
    if !RegExMatch(userRegex, "^[imnsxADJOUX]*\)")
        userRegex := "i)" . userRegex
    try {
        RegExMatch("", userRegex)
    } catch {
        return ""
    }
    return userRegex
}

startTextMonitor(rules) {
    stopTextMonitor()
    if rules.Length = 0
        return
    processed := []
    for rule in rules {
        regex := parseTextRule(rule.textMonitor)
        if regex != ""
            processed.Push({ regex: regex, trigger: rule.trigger })
    }
    textMonitorState.buffer := ""
    ih := InputHook("V")
    ih.OnChar := onTextMonitorChar
    ih.Start()
    textMonitorState.ih := ih
    textMonitorState.rules := processed
}

stopTextMonitor() {
    if textMonitorState.ih {
        textMonitorState.ih.Stop()
        textMonitorState.ih := 0
    }
    textMonitorState.rules := []
    textMonitorState.buffer := ""
}

onTextMonitorChar(ih, char) {
    textMonitorState.buffer .= char
    if StrLen(textMonitorState.buffer) > 50
        textMonitorState.buffer := SubStr(textMonitorState.buffer, -50)

    for rule in textMonitorState.rules {
        if safeRegexMatch(textMonitorState.buffer, rule.regex) {
            textMonitorState.buffer := ""
            runTriggers([rule.trigger])
            return
        }
    }
}


hotkeyMonitorState := {
    hotkeys: [],
    rules: [],
    buffer: [],
    maxLen: 0,
    lastTime: 0
}

startHotkeyMonitor(rules) {
    stopHotkeyMonitor()
    if rules.Length = 0
        return

    parsed := []
    allKeys := Map()
    maxLen := 0

    for rule in rules {
        seqs := []
        for part in StrSplit(rule.hotkeyMonitor, "|") {
            if part = ""
                continue
            seq := StrSplit(part, ">")
            seqs.Push(seq)
            maxLen := Max(maxLen, seq.Length)
            for hk in seq
                allKeys[hk] := true
        }
        parsed.Push({ seqs: seqs, trigger: rule.trigger })
    }

    hotkeyMonitorState.rules := parsed
    hotkeyMonitorState.buffer := []
    hotkeyMonitorState.maxLen := maxLen
    hotkeyMonitorState.lastTime := 0

    for hk, _ in allKeys {
        try {
            Hotkey("~" hk, ((k) => (*) => onHotkeyMonitor(k))(hk), "On")
            hotkeyMonitorState.hotkeys.Push(hk)
        }
    }
}

stopHotkeyMonitor() {
    for hk in hotkeyMonitorState.hotkeys
        try Hotkey("~" hk, , "Off")
    hotkeyMonitorState.hotkeys := []
    hotkeyMonitorState.rules := []
    hotkeyMonitorState.buffer := []
    hotkeyMonitorState.maxLen := 0
}

onHotkeyMonitor(hk) {
    if (A_TickCount - hotkeyMonitorState.lastTime > 5000)
        hotkeyMonitorState.buffer := []
    hotkeyMonitorState.lastTime := A_TickCount

    hotkeyMonitorState.buffer.Push(hk)
    if hotkeyMonitorState.buffer.Length > hotkeyMonitorState.maxLen {
        newBuffer := []
        start := hotkeyMonitorState.buffer.Length - hotkeyMonitorState.maxLen + 1
        loop hotkeyMonitorState.maxLen
            newBuffer.Push(hotkeyMonitorState.buffer[start + A_Index - 1])
        hotkeyMonitorState.buffer := newBuffer
    }

    for rule in hotkeyMonitorState.rules {
        for seq in rule.seqs {
            if matchSequence(hotkeyMonitorState.buffer, seq) {
                hotkeyMonitorState.buffer := []
                textMonitorState.buffer := ""
                SetTimer(onHotkeyWait.Bind(rule.trigger), 50)
                return
            }
        }
    }
}

onHotkeyWait(trigger) {
    static modifiers := ["Ctrl", "Alt", "Shift", "LWin", "RWin"]
    for mod in modifiers {
        if GetKeyState(mod, "P")
            return
    }
    SetTimer(, 0)
    textMonitorState.buffer := ""
    runTriggers([trigger])
}

matchSequence(buffer, seq) {
    if buffer.Length < seq.Length
        return false
    offset := buffer.Length - seq.Length
    for i, hk in seq {
        if buffer[offset + i] != hk
            return false
    }
    return true
}

var._lastCaptureMode := ""

/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/GetCaretPosEx/GetCaretPosEx.ahk
 */
GetCaretPosEx(&left?, &top?, &right?, &bottom?) {
    hwnd := 0
    captureModeChain := getCaretCapture().capture
    modes := StrSplit(captureModeChain, ">")
    if modes.Length {
        for mode in modes {
            if _trySingleCaptureMode(mode) {
                var._lastCaptureMode := mode
                return 1
            }
        }
    } else {
        if getCaretPosFromGui(&hwnd) {
            var._lastCaptureMode := "GUI"
            return 1
        }
        if getCaretPosFromHook(0) {
            var._lastCaptureMode := "HOOK"
            return 1
        }
        if getCaretPosFromUIA() {
            var._lastCaptureMode := "UIA"
            return 1
        }
        if !hwnd
            hwnd := getHwnd()
        if getCaretPosFromMSAA() {
            var._lastCaptureMode := "MSAA"
            return 1
        }
    }
    var._lastCaptureMode := ""
    return 0

    _trySingleCaptureMode(mode) {
        switch mode {
            case "HOOK":
                hwnd := getHwnd()
                return getCaretPosFromHook(0)
            case "GUI":
                return getCaretPosFromGui(&hwnd)
            case "UIA":
                return getCaretPosFromUIA()
            case "MSAA":
                hwnd := getHwnd()
                return getCaretPosFromMSAA()
            case "Hook_DLL":
                hwnd := getHwnd()
                return getCaretPosFromHook(1)
            case "WPF":
                return getCaretPosFromWpfCaret()
            case "ACC":
                return getCaretPosFromACC()
            default:
                return 0
        }
    }

    getHwnd(hwnd := 0) {
        x64 := A_PtrSize == 8
        guiThreadInfo := Buffer(x64 ? 72 : 48)
        NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
            hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
        }
        return hwnd
    }

    getCaretPosFromGui(&hwnd) {
        x64 := A_PtrSize == 8
        guiThreadInfo := Buffer(x64 ? 72 : 48)
        NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
            if hwnd := NumGet(guiThreadInfo, x64 ? 48 : 28, "ptr") {
                getRect(guiThreadInfo.Ptr + (x64 ? 56 : 32), &left, &top, &right, &bottom)
                clientToScreenRect(hwnd, &left, &top, &right, &bottom)
                return true
            }
            hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
        }
        return false
    }

    getCaretPosFromMSAA() {
        static hOleacc := DllCall("LoadLibraryW", "str", "oleacc.dll", "ptr")
        if !hOleacc
            return false
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
                left := x
                top := y
                right := x + w
                bottom := y + h
                return true
            }
        }
        return false
    }

    getCaretPosFromUIA() {
        static uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
        static IID_IUIAutomationTextPattern2 := guidFromString("{506a921a-fcc9-409f-b23b-37eb74106872}")
        static IID_IUIAutomationTextPattern := guidFromString("{32eba289-3583-42c9-9c59-3b6d9a1e9b6a}")
        try {
            ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
            if !cacheRequest.Ptr
                return false
            ComCall(4, cacheRequest, "ptr", 10014) ; cacheRequest->AddPattern(UIA_TextPatternId);
            ComCall(4, cacheRequest, "ptr", 10024) ; cacheRequest->AddPattern(UIA_TextPattern2Id);

            ComCall(12, uia, "ptr", cacheRequest, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElementBuildCache(cacheRequest, &focusedEle);
            if !focusedEle.Ptr
                return false

            range := ComValue(13, 0)
            ComCall(15, focusedEle, "int", 10024, "ptr", IID_IUIAutomationTextPattern2, "ptr*", textPattern := ComValue(13, 0)) ; focusedEle->GetCachedPatternAs(UIA_TextPattern2Id, IID_PPV_ARGS(&textPattern));
            if textPattern.Ptr {
                ComCall(10, textPattern, "int*", &isActive := 0, "ptr*", range) ; textPattern->GetCaretRange(&isActive, &range);
                if range.Ptr
                    goto getRangeInfo
            }
            ; If no caret range, get selection range.
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
        } catch {
            uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
            return false
        }
    }

    getCaretPosFromWpfCaret() {
        static uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
        try {
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
        } catch {
            uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
            return false
        }
    }

    getCaretPosFromHook(updateCaret) {
        static WM_GET_CARET_POS := DllCall("RegisterWindowMessageW", "str", "WM_GET_CARET_POS", "uint")
        if !tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr*", &pid := 0, "uint")
            return false
        if (updateCaret) {
            ; Update caret position
            ; There may be problems with 32-bit programs
            try SendMessage(0x010f, 0, 0, hwnd) ; WM_IME_COMPOSITION
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
            loop Min(350, needed // A_PtrSize) {
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

    getCaretPosFromACC() {
        static _ := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
        try {
            idObject := 0xFFFFFFF8 ; OBJID_CARET
            if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint", idObject &= 0xFFFFFFFF
                , "ptr", -16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
                , "ptr*", oAcc := ComValue(9, 0)) == 0 {
                x := Buffer(4), y := Buffer(4), w := Buffer(4), h := Buffer(4)
                oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
                left := NumGet(x, 0, "int")
                top := NumGet(y, 0, "int")
                right := left + NumGet(w, 0, "int")
                bottom := top + NumGet(h, 0, "int")
                if (left | top) != 0
                    return 1
                return 0
            }
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
