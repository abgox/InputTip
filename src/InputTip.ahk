; InputTip

;@AHK2Exe-SetName InputTip
;@Ahk2Exe-SetOrigFilename InputTip.ahk
;@Ahk2Exe-UpdateManifest 1

#Include core\init.ahk

OnMessage(0x404, (wParam, lParam, *) => lParam == 0x202 ? pauseApp() : "")

if (A_IsCompiled) {
    favicon := A_ScriptFullPath
} else {
    favicon := A_ScriptDir "\temp\icon\default-app.ico"
    if var.runCodeWithAdmin && !A_IsAdmin
        runAsAdmin()
}

if var.checkUpdateOnStartup
    SetTimer(() => (isLocked() ? 0 : (SetTimer(, 0), runUpdater())), 1000)

runUpdater() {
    A_IconHidden := 0
    if A_IsCompiled {
        try Run("`"" A_Temp "\abgox.InputTip.updater.exe`" " keyCount " " ProcessExist() " `"" A_ScriptFullPath "`"")
        return
    }
    try Run('"' A_AhkPath '" "' A_ScriptDir '\InputTip.updater.ahk" ' keyCount " " ProcessExist(), , "Hide")
}

setTrayIcon(var.iconRunning)

checkIni()

var._shiftAloneFlags := Map()
var._shiftWildcardRegistered := false

registerHotkey()

setHotkeyTrigger(key, trigger) {
    isShiftUp := RegExMatch(key, "i)~?(L|R)?Shift\s+Up")
    if (isShiftUp) {
        downKey := Trim(RegExReplace(key, "i)\s*Up$", ""))
        downKey := LTrim(downKey, "~")
        flagKey := downKey
        var._shiftAloneFlags[flagKey] := false
        try Hotkey("~" downKey, setShiftAloneFlag.Bind(flagKey), "On")
        try Hotkey("~" downKey " Up", checkAndRunShiftTrigger.Bind(flagKey, trigger), "On")
        return ["~" downKey, "~" downKey " Up"]
    } else {
        try Hotkey(key, runTriggers.Bind([trigger]), "On")
        return [key]
    }
}

setShiftAloneFlag(flagKey, *) {
    var._shiftAloneFlags[flagKey] := true
}

checkAndRunShiftTrigger(flagKey, trigger, *) {
    priorKey := A_PriorKey
    if (var._shiftAloneFlags[flagKey] && priorKey = flagKey) {
        var._shiftAloneFlags[flagKey] := false
        runTriggers([trigger])
    } else {
        var._shiftAloneFlags[flagKey] := false
    }
}

registerHotkey() {
    static lastHotkeyList := []
    if lastHotkeyList.Length {
        for v in lastHotkeyList
            try Hotkey(v, "Off")
        lastHotkeyList := []
    }
    for rule in var.hotkeyRule.Get("", []) {
        if rule.hotkey == "" || rule.trigger == ""
            continue
        registered := setHotkeyTrigger(rule.hotkey, rule.trigger)
        for hk in registered
            lastHotkeyList.Push(hk)
    }
}
updateWindowHotkey() {
    static lastWindowHotkeyList := []

    if lastWindowHotkeyList.Length {
        for hk in lastWindowHotkeyList {
            try Hotkey(hk, "Off")
            for rule in var.hotkeyRule.Get("", []) {
                if rule.hotkey == hk {
                    setHotkeyTrigger(hk, rule.trigger)
                    break
                }
            }
        }
        lastWindowHotkeyList := []
    }
    if !exeName
        return

    ruleLists := getMatchingRuleLists(exeName, var.hotkeyRule, 1)
    if !ruleLists.Length
        return

    for ruleList in ruleLists {
        for rule in ruleList {
            if rule.hotkey == "" || rule.trigger == ""
                continue
            if matchCondition(rule, exeTitle, exeClass) {
                registered := setHotkeyTrigger(rule.hotkey, rule.trigger)
                for hk in registered
                    lastWindowHotkeyList.Push(hk)
            }
        }
    }
}

makeTrayMenu()
updateTrayTip()

if var.symbolJABActive
    runJAB()

returnCanShowSymbol(&left, &top, &right, &bottom) {
    try {
        res := GetCaretPosEx(&left, &top, &right, &bottom)
    } catch {
        left := 0, top := 0, right := 0, bottom := 0
        return 0
    }
    s := isWhichScreen()
    if (s.num) {
        scale := getMonitorScale(s)
        try {
            offset := symbolScreenOffset.caret.%s.num%
            left += toPhysical(offset.x, scale)
            if (var.caretSymbolOriginY == "below") {
                bottom += toPhysical(offset.y, scale)
            } else {
                top += toPhysical(offset.y, scale)
            }
        }

        rules := []
        previewTimes := Map()
        for key, item in var._previewOffsetMap {
            if RegExMatch(exeName, key) {
                previewTimes.Set(item.time, 1)
                rules.Push(item)
            }
        }
        for ruleList in getMatchingRuleLists(exeName, var.WindowCaretSymbolRule["offset"]) {
            for rule in ruleList {
                if !previewTimes.Has(rule.time)
                    rules.Push(rule)
            }
        }

        num := String(s.num)
        for rule in rules {
            if rule && rule.offsetMap.Has(num) {
                offset := rule.offsetMap.Get(num)
                left += toPhysical(offset.x, scale)
                if (var.caretSymbolOriginY == "below") {
                    bottom += toPhysical(offset.y, scale)
                } else {
                    top += toPhysical(offset.y, scale)
                }
            }
        }
        return res && left
    }
    return 0
}

#Include "*i data\plugin\InputTip.plugin.ahk"

#Include "*i core\core.ahk"
