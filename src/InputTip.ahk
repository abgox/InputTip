; InputTip

;@AHK2Exe-SetName InputTip
;@Ahk2Exe-SetOrigFilename InputTip.ahk
;@Ahk2Exe-UpdateManifest 1

#Include core\init.ahk

OnMessage(0x404, (wParam, lParam, *) => lParam == 0x202 ? toggleApp() : "")

if A_IsCompiled {
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
    global updaterPID
    try Run("`"" runtime2 "`" `"" A_ScriptDir "\InputTip.updater.ahk`" " keyCount " " ProcessExist() "," JAB_PID, , "Hide", &updaterPID)
}

setTrayIcon(var.iconRunning)

checkIni()

var._shiftAloneFlags := Map()
var._lastHotkeyList := []
var._lastWindowHotkeyList := []

registerHotkey()

setHotkeyTrigger(key, trigger) {
    isShiftUp := RegExMatch(key, "i)~?(L|R)?Shift\s+Up")
    if isShiftUp {
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
    if var._shiftAloneFlags[flagKey] && A_PriorKey = flagKey {
        var._shiftAloneFlags[flagKey] := false
        runTriggers([trigger])
    } else {
        var._shiftAloneFlags[flagKey] := false
    }
}


registerHotkey() {
    if var._lastHotkeyList.Length {
        for v in var._lastHotkeyList
            try Hotkey(v, "Off")
        var._lastHotkeyList := []
    }
    for rule in var.hotkeyRule.Get("", []) {
        if rule.hotkey == "" || rule.trigger == ""
            continue
        registered := setHotkeyTrigger(rule.hotkey, rule.trigger)
        for hk in registered
            var._lastHotkeyList.Push(hk)
    }
}

updateWindowHotkey() {
    if var._paused
        return

    if var._lastWindowHotkeyList.Length {
        for hk in var._lastWindowHotkeyList {
            try Hotkey(hk, "Off")
            for rule in var.hotkeyRule.Get("", []) {
                if rule.hotkey == hk && rule.trigger {
                    setHotkeyTrigger(hk, rule.trigger)
                    break
                }
            }
        }
        var._lastWindowHotkeyList := []
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
                    var._lastWindowHotkeyList.Push(hk)
            }
        }
    }
}

clearAllRegisteredHotkeys() {
    if var._lastHotkeyList.Length {
        remainingHotkeys := []
        for hk in var._lastHotkeyList {
            if isResumeTrigger(hk, "", "global") {
                remainingHotkeys.Push(hk)
                continue
            }
            try Hotkey(hk, "Off")
        }
        var._lastHotkeyList := remainingHotkeys
    }

    if var._lastWindowHotkeyList.Length {
        remainingWindowHotkeys := []
        for hk in var._lastWindowHotkeyList {
            if isResumeTrigger(hk, exeName, "window") {
                remainingWindowHotkeys.Push(hk)
                continue
            }
            try Hotkey(hk, "Off")
        }
        var._lastWindowHotkeyList := remainingWindowHotkeys
    }
}

isResumeTrigger(hk, exeName := "", type := "global") {
    cleanHk := RegExReplace(hk, "i)^~|(?:\s+Up)$", "")

    if (type == "global") {
        for rule in var.hotkeyRule.Get("", []) {
            cleanRuleHk := RegExReplace(rule.hotkey, "i)^~|(?:\s+Up)$", "")
            if (cleanHk == cleanRuleHk && (rule.trigger == "resume" || rule.trigger == "toggle"))
                return true
        }
    } else if (type == "window" && exeName != "") {
        ruleLists := getMatchingRuleLists(exeName, var.hotkeyRule, 1)
        for ruleList in ruleLists {
            for rule in ruleList {
                cleanRuleHk := RegExReplace(rule.hotkey, "i)^~|(?:\s+Up)$", "")
                if (cleanHk == cleanRuleHk && (rule.trigger == "resume" || rule.trigger == "toggle"))
                    return true
            }
        }
    }
    return false
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

    capture := getCaretCapture()
    captureOffsetMap := Map()
    if capture.captureOffset && capture.capture {
        captureMode := StrSplit(capture.capture, ">")
        for i, c in StrSplit(capture.captureOffset, ">") {
            try {
                pos := StrSplit(c, "/")
                captureOffsetMap.Set(captureMode[i], { x: pos[1], y: pos[2] })
            }
        }
    }

    s := isWhichScreen()
    if (s.num) {
        scale := s.scale
        try {
            offset := symbolScreenOffset.caret.%s.num%
            left += toPhysical(offset.x, scale)
            if var.caretSymbolOriginY == "below"
                bottom += toPhysical(offset.y, scale)
            else
                top += toPhysical(offset.y, scale)
        }

        try {
            if captureOffset := captureOffsetMap.Get(var._lastCaptureMode, { x: 0, y: 0 })
                left += toPhysical(captureOffset.x, scale)
            if var.caretSymbolOriginY == "below"
                bottom += toPhysical(captureOffset.y, scale)
            else
                top += toPhysical(captureOffset.y, scale)
        }

        rules := []
        previewTimes := Map()
        for key, item in var._previewOffsetMap {
            if safeRegexMatch(exeName, key) {
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
