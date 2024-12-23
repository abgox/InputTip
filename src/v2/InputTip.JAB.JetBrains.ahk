#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip.JAB.JetBrains
;@AHK2Exe-SetLanguage 0x0804
;@AHK2Exe-SetDescription InputTip(JetBrains 进程) - 一个输入法状态(中文/英文/大写锁定)提示工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-SetMainIcon ..\favicon.ico
#SingleInstance Force
#Warn All, Off
#NoTrayIcon
Persistent
ListLines 0
KeyHistory 0
DetectHiddenWindows 1
InstallKeybdHook
InstallMouseHook
CoordMode 'Mouse', 'Screen'
SetStoreCapsLockMode 0

#Include ..\utils\IME.ahk

/**
 * 读取配置文件
 * @param {String}key 配置文件中的键名
 * @param default 默认值
 * @param {"InputMethod" | "Config-v2"} section 配置文件中的分区名
 * @param {String} path 配置文件的路径
 * @returns {String} 配置文件中的值
 */
readIni(key, default, section := "Config-v2", path := "InputTip.ini") {
    try {
        return IniRead(path, section, key)
    } catch {
        IniWrite(default, path, section, key)
        return default
    }
}

; 输入法模式
mode := readIni("mode", 2, "InputMethod")
delay := readIni("delay", 50)
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
CN_color := StrReplace(readIni("CN_color", "red"), '#', '')
EN_color := StrReplace(readIni("EN_color", "blue"), '#', '')
Caps_color := StrReplace(readIni("Caps_color", "green"), '#', '')
transparent := readIni('transparent', 222)
offset_x := readIni('offset_x', 10)
offset_y := readIni('offset_y', -15)
symbol_width := readIni('symbol_width', 6)
symbol_height := readIni('symbol_height', 6)

CN_pic := readIni("CN_pic", "InputTipSymbol\default\CN.png")
EN_pic := readIni("EN_pic", "InputTipSymbol\default\EN.png")
Caps_pic := readIni("Caps_pic", "InputTipSymbol\default\Caps.png")
pic_offset_x := readIni('pic_offset_x', -22)
pic_offset_y := readIni('pic_offset_y', -40)
pic_symbol_width := readIni('pic_symbol_width', 9)
pic_symbol_height := readIni('pic_symbol_height', 9)
; 应用列表: 需要隐藏符号
app_hide_state := ":" readIni('app_hide_state', '') ":"

; 应用列表: 自动切换到中文
app_CN := ":" readIni('app_CN', '') ":"
; 应用列表: 自动切换到英文
app_EN := ":" readIni('app_EN', '') ":"
; 应用列表: 自动切换到大写锁定
app_Caps := ":" readIni('app_Caps', '') ":"

/*
边框样式
    1: 样式1
    2: 样式2
    3: 样式3
    4: 自定义
*/
border_type := readIni('border_type', 1)
border_color_CN := StrReplace(readIni('border_color_CN', 'yellow'), '#', '')
border_color_EN := StrReplace(readIni('border_color_EN', 'yellow'), '#', '')
border_color_Caps := StrReplace(readIni('border_color_Caps', 'yellow'), '#', '')
border_margin_left := readIni('border_margin_left', 1)
border_margin_right := readIni('border_margin_right', 1)
border_margin_top := readIni('border_margin_top', 1)
border_margin_bottom := readIni('border_margin_bottom', 1)
border_transparent := readIni('border_transparent', 255)
symbolWidth := symbol_width * A_ScreenDPI / 96
symbolHeight := symbol_height * A_ScreenDPI / 96
picSymbolWidth := pic_symbol_width * A_ScreenDPI / 96
picSymbolHeight := pic_symbol_height * A_ScreenDPI / 96
borderWidth := (symbol_width + border_margin_left + border_margin_right) * A_ScreenDPI / 96
borderHeight := (symbol_height + border_margin_top + border_margin_bottom) * A_ScreenDPI / 96
borderOffsetX := offset_x + border_margin_left * (A_ScreenDPI / 96) ** 2
borderOffsetY := offset_y + border_margin_top * (A_ScreenDPI / 96) ** 2

screenList := getScreenInfo()

; 文本符号相关的配置
font_family := readIni('font_family', '微软雅黑')
font_size := readIni('font_size', 7)
font_weight := readIni('font_weight', 600)
font_color := StrReplace(readIni('font_color', 'ffffff'), '#', '')
CN_Text := readIni('CN_Text', '中')
EN_Text := readIni('EN_Text', '英')
Caps_Text := readIni('Caps_Text', '大')


/**
 * 将输入法状态切换为中文
 */
switch_CN(*) {
    if (GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
    if (!isCN(mode)) {
        IME.SetInputMode(1)
    }
    if (!isCN(mode)) {
        SendInput("{Shift}")
    }
}
/**
 * 将输入法状态切换为英文
 */
switch_EN(*) {
    if (GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
    if (isCN(mode)) {
        IME.SetInputMode(0)
    }
    if (isCN(mode)) {
        SendInput("{Shift}")
    }
}
/**
 * 将输入法状态切换为大写锁定
 */
switch_Caps(*) {
    if (!GetKeyState("CapsLock", "T")) {
        SendInput("{CapsLock}")
    }
}

; 鼠标样式相关信息
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
}]
curMap := {
    ARROW: "Arrow", IBEAM: "IBeam", WAIT: "Wait", CROSS: "Crosshair", UPARROW: "UpArrow", SIZENWSE: "SizeNWSE", SIZENESW: "SizeNESW", SIZEWE: "SizeWE", SIZENS: "SizeNS", SIZEALL: "SizeAll", NO: "No", HAND: "Hand", APPSTARTING: "AppStarting", HELP: "Help", PIN: "Pin", PERSON: "Person", PEN: "NWPen"
}
cursor_dir := {
    EN: EN_cursor,
    CN: CN_cursor,
    Caps: Caps_cursor
}

for key in cursor_dir.OwnProps() {
    Loop Files cursor_dir.%key% "\*.*" {
        n := StrUpper(SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4))
        for v in info {
            if (v.type = n) {
                v.%key% := A_LoopFileFullPath
            }
        }
    }
}
for v in info {
    try {
        v.origin := replaceEnvVariables(RegRead("HKEY_CURRENT_USER\Control Panel\Cursors", curMap.%v.type%))
    }
}

state := 0, old_state := '', old_left := '', old_top := '', left := 0, top := 0
TipGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")

if (symbolType = 1) {
    ; 图片字符
    TipGui.BackColor := "000000"
    WinSetTransColor("000000", TipGui)
    TipGui.Opt("-LastFound")
    TipGuiPic := TipGui.AddPicture("w" picSymbolWidth " h" picSymbolHeight, "InputTipSymbol\default\EN.png")
    CN_color := "000000"
    EN_color := "000000"
    Caps_color := "000000"
} else {
    ; 文本字符
    if (symbolType = 3) {
        TipGui.MarginX := 0, TipGui.MarginY := 0
        TipGui.SetFont('s' font_size * A_ScreenDPI / 96 ' c' font_color ' w' font_weight, font_family)
        TipGuiText := TipGui.AddText(, CN_Text)
        TipGuiText := TipGui.AddText(, EN_Text)
        TipGuiText := TipGui.AddText(, Caps_Text)
        TipGui.Show("Hide")
        TipGui.GetPos(, , &Gui_width)
        TipGui.Destroy()

        TipGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
        TipGui.MarginX := 0, TipGui.MarginY := 0
        TipGui.SetFont('s' font_size * A_ScreenDPI / 96 ' c' font_color ' w' font_weight, font_family)

        TipGuiText := TipGui.AddText("w" Gui_width, EN_Text)
    }
    WinSetTransparent(transparent)
    switch border_type {
        case 1: TipGui.Opt("-LastFound +e0x00000001")
        case 2: TipGui.Opt("-LastFound +e0x00000200")
        case 3: TipGui.Opt("-LastFound +e0x00020000")
        default: TipGui.Opt("-LastFound")
    }
    TipGui.BackColor := EN_color
}
borderGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
WinSetTransparent(border_transparent)
borderGui.Opt("-LastFound")
borderGui.BackColor := border_color_EN

lastWindow := ""
lastState := state
needHide := 1
exe_name := ""
exe_str := "::"

if (changeCursor) {
    if (symbolType) {
        while 1 {
            if (isMouseOver("ahk_class Shell_TrayWnd")) {
                Sleep(delay)
                continue
            }
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                exe_str := ":" exe_name ":"
            }
            if (!InStr(JetBrains_list, exe_str)) {
                TipGui.Hide()
                Sleep(delay)
                continue
            }
            if (exe_name != lastWindow) {
                needHide := 0
                SetTimer(timer, HideSymbolDelay)
                timer(*) {
                    global needHide := 1
                }
                WinWaitActive("ahk_exe" exe_name)
                lastWindow := exe_name
                if (InStr(app_CN, exe_str)) {
                    switch_CN()
                } else if (InStr(app_EN, exe_str)) {
                    switch_EN()
                } else if (InStr(app_Caps, exe_str)) {
                    switch_Caps()
                }
            }
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                Sleep(delay)
                continue
            }
            if (A_TimeIdle < 500) {
                if (InStr(app_hide_state, exe_str)) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    GetCaretPosFromJetBrains(&left, &top)
                    canShowSymbol := left
                    try {
                        left += IniRead("InputTip.ini", "config-v2", "offset_JetBrains_x_" isWhichScreen(screenList).num)
                        top += IniRead("InputTip.ini", "config-v2", "offset_JetBrains_y_" isWhichScreen(screenList).num)
                    }
                }
                if (GetKeyState("CapsLock", "T")) {
                    if (state = 2) {
                        if (left != old_left || top != old_top) {
                            canShowSymbol ? TipShow("Caps") : TipGui.Hide()
                        }
                    } else {
                        state := 2
                        show("Caps")
                        if (canShowSymbol) {
                            TipGui.BackColor := Caps_color, borderGui.BackColor := border_color_Caps
                            TipShow("Caps")
                        } else {
                            TipGui.Hide()
                        }
                    }
                    old_left := left
                    old_top := top
                    old_state := state
                    Sleep(delay)
                    continue
                }
                try {
                    state := isCN(mode)
                    v := state = 1 ? "CN" : "EN"
                } catch {
                    TipGui.Hide()
                    Sleep(delay)
                    continue
                }
                if (state != old_state) {
                    show(v)
                    TipGui.BackColor := %v "_color"%
                    borderGui.BackColor := %"border_color_" v%
                    if (canShowSymbol) {
                        TipShow(v)
                    } else {
                        TipGui.Hide()
                    }
                    old_state := state
                }
                if (left != old_left || top != old_top) {
                    old_left := left
                    old_top := top
                    if (canShowSymbol) {
                        TipShow(v)
                    } else {
                        TipGui.Hide()
                    }
                }
            }
            Sleep(delay)
        }
    } else {
        while 1 {
            if (isMouseOver("ahk_class Shell_TrayWnd")) {
                Sleep(delay)
                continue
            }
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                exe_str := ":" exe_name ":"
            }
            if (!InStr(JetBrains_list, exe_str)) {
                Sleep(delay)
                continue
            }
            if (exe_name != lastWindow) {
                WinWaitActive("ahk_exe" exe_name)
                lastWindow := exe_name
                if (InStr(app_CN, exe_str)) {
                    switch_CN()
                } else if (InStr(app_EN, exe_str)) {
                    switch_EN()
                } else if (InStr(app_Caps, exe_str)) {
                    switch_Caps()
                }
            }
            if (A_TimeIdle < 500) {
                if (GetKeyState("CapsLock", "T")) {
                    if (state != 2) {
                        show("Caps")
                        state := 2
                    }
                    old_state := state
                    Sleep(delay)
                    continue
                }
                try {
                    state := isCN(mode)
                    v := state = 1 ? "CN" : "EN"
                } catch {
                    Sleep(delay)
                    continue
                }
                if (state != old_state) {
                    show(v)
                    old_state := state
                }
            }
            Sleep(delay)
        }
    }
    show(type) {
        for v in info {
            if (v.%type%) {
                DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%type%, "Ptr"), "Int", v.value)
            }
        }
    }
} else {
    if (symbolType) {
        while 1 {
            if (isMouseOver("ahk_class Shell_TrayWnd")) {
                Sleep(delay)
                continue
            }
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                exe_str := ":" exe_name ":"
            }
            if (!InStr(JetBrains_list, exe_str)) {
                TipGui.Hide()
                Sleep(delay)
                continue
            }
            if (exe_name != lastWindow) {
                needHide := 0
                SetTimer(timer2, HideSymbolDelay)
                timer2(*) {
                    global needHide := 1
                }
                WinWaitActive("ahk_exe" exe_name)
                lastWindow := exe_name
                if (InStr(app_CN, exe_str)) {
                    switch_CN()
                } else if (InStr(app_EN, exe_str)) {
                    switch_EN()
                } else if (InStr(app_Caps, exe_str)) {
                    switch_Caps()
                }
            }
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                Sleep(delay)
                continue
            }
            if (A_TimeIdle < 500) {
                if (InStr(app_hide_state, exe_str)) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    GetCaretPosFromJetBrains(&left, &top)
                    canShowSymbol := left
                    try {
                        left += IniRead("InputTip.ini", "config-v2", "offset_JetBrains_x_" isWhichScreen(screenList).num)
                        top += IniRead("InputTip.ini", "config-v2", "offset_JetBrains_y_" isWhichScreen(screenList).num)
                    }
                }
                if (GetKeyState("CapsLock", "T")) {
                    if (state = 2) {
                        if (left != old_left || top != old_top) {
                            canShowSymbol ? TipShow("Caps") : TipGui.Hide()
                        }
                    } else {
                        state := 2
                        if (canShowSymbol) {
                            TipGui.BackColor := Caps_color, borderGui.BackColor := border_color_Caps
                            TipShow("Caps")
                        } else {
                            TipGui.Hide()
                        }
                    }
                    old_left := left
                    old_top := top
                    old_state := state
                    Sleep(delay)
                    continue
                }
                try {
                    state := isCN(mode)
                    v := state = 1 ? "CN" : "EN"
                } catch {
                    TipGui.Hide()
                    Sleep(delay)
                    continue
                }
                if (state != old_state) {
                    TipGui.BackColor := %v "_color"%
                    borderGui.BackColor := %"border_color_" v%
                    if (canShowSymbol) {
                        TipShow(v)
                    } else {
                        TipGui.Hide()
                    }
                    old_state := state
                }
                if (left != old_left || top != old_top) {
                    old_left := left
                    old_top := top
                    if (canShowSymbol) {
                        TipShow(v)
                    } else {
                        TipGui.Hide()
                    }
                }
            }
            Sleep(delay)
        }
    }
}

TipShow(type) {
    switch symbolType {
        case 1:
        {
            if (%type "_pic"%) {
                try {
                    TipGuiPic.Value := %type "_pic"%
                    try {
                        TipGui.Show("NA x" left + pic_offset_x "y" top + pic_offset_y)
                    }
                } catch {
                    TipGui.Hide()
                }
            } else {
                TipGui.Hide()
            }
        }
        case 2:
        {
            if (border_type = 4) {
                if (TipGui.BackColor) {
                    try {
                        borderGui.Show("NA w" borderWidth "h" borderHeight "x" left + offset_x "y" top + offset_y)
                        TipGui.Show("NA w" symbolWidth "h" symbolHeight "x" left + borderOffsetX "y" top + borderOffsetY)
                    }
                } else {
                    borderGui.Hide()
                    TipGui.Hide()
                }
                return
            }
            if (TipGui.BackColor) {
                try {
                    TipGui.Show("NA w" symbolWidth "h" symbolHeight "x" left + offset_x "y" top + offset_y)
                }
            } else {
                TipGui.Hide()
            }
        }
        case 3:
        {
            if (TipGui.BackColor && %type "_Text"%) {
                TipGuiText.Value := %type "_Text"%
                try {
                    TipGui.Show("NA x" left + offset_x "y" top + offset_y)
                }
            } else {
                TipGui.Hide()
            }
        }
        default: return
    }
}

isMouseOver(WinTitle) {
    MouseGetPos , , &Win
    return WinExist(WinTitle " ahk_id " Win)
}

replaceEnvVariables(str) {
    while RegExMatch(str, "%\w+%", &match) {
        env := match[]
        envValue := EnvGet(StrReplace(env, "%", ""))
        str := StrReplace(str, env, envValue)
    }
    return str
}

/**
 * 获取到屏幕信息
 * @returns {Array} 一个数组 [{num:1,left:0,top:0,right:0,bottom:0}]
 */
getScreenInfo() {
    list := []
    MonitorCount := MonitorGetCount()
    MonitorPrimary := MonitorGetPrimary()
    Loop MonitorCount
    {
        MonitorGet A_Index, &L, &T, &R, &B
        MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB
        list.Push({
            main: MonitorPrimary,
            count: MonitorCount,
            num: A_Index,
            left: L,
            top: T,
            right: R,
            bottom: B
        })
    }
    return list
}
isWhichScreen(screenList) {
    MouseGetPos(&x, &y)
    for v in screenList {
        if (x >= v.left && x <= v.right && y >= v.top && y <= v.bottom) {
            return v
        }
    }
}

/**
 * Gets the position of the caret with UIA, Acc or CaretGetPos.
 * Credit: plankoe (https://www.reddit.com/r/AutoHotkey/comments/ysuawq/get_the_caret_location_in_any_program/)
 * @param X Value is set to the screen X-coordinate of the caret
 * @param Y Value is set to the screen Y-coordinate of the caret
 * @param W Value is set to the width of the caret
 * @param H Value is set to the height of the caret
 */
GetCaretPosFromJetBrains(&X?, &Y?, &W?, &H?) {
    static JAB := InitJAB() ; Source: https://github.com/Elgin1/Java-Access-Bridge-for-AHK
    if JAB && (hWnd := WinExist("A")) && DllCall(JAB.module "\isJavaWindow", "ptr", hWnd, "CDecl Int") {
        if JAB.firstRun
            Sleep(200), JAB.firstRun := 0
        prevThreadDpiAwarenessContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -2, "ptr")
        DllCall(JAB.module "\getAccessibleContextWithFocus", "ptr", hWnd, "Int*", &vmID := 0, JAB.acType "*", &ac := 0, "Cdecl Int") "`n"
        DllCall(JAB.module "\getCaretLocation", "Int", vmID, JAB.acType, ac, "Ptr", Info := Buffer(16, 0), "Int", 0, "Cdecl Int")
        DllCall(JAB.module "\releaseJavaObject", "Int", vmId, JAB.acType, ac, "CDecl")
        DllCall("SetThreadDpiAwarenessContext", "ptr", prevThreadDpiAwarenessContext, "ptr")
        X := NumGet(Info, 0, "Int"), Y := NumGet(Info, 4, "Int"), W := NumGet(Info, 8, "Int"), H := NumGet(Info, 12, "Int")
        hMonitor := DllCall("MonitorFromWindow", "ptr", hWnd, "int", 2, "ptr") ; MONITOR_DEFAULTTONEAREST
        DllCall("Shcore.dll\GetDpiForMonitor", "ptr", hMonitor, "int", 0, "uint*", &dpiX := 0, "uint*", &dpiY := 0)
        if dpiX
            X := DllCall("MulDiv", "int", X, "int", dpiX, "int", 96, "int"), Y := DllCall("MulDiv", "int", Y, "int", dpiX, "int", 96, "int")
        if X || Y || W || H
            return
    }
    InitJAB() {
        ret := {}, ret.firstRun := 1, ret.module := A_PtrSize = 8 ? "WindowsAccessBridge-64.dll" : "WindowsAccessBridge-32.dll", ret.acType := "Int64"
        ret.DefineProp("__Delete", { call: (this) => DllCall("FreeLibrary", "ptr", this) })
        if !(ret.ptr := DllCall("LoadLibrary", "Str", ret.module, "ptr")) && A_PtrSize = 4 {
            ; try legacy, available only for 32-bit
            ret.acType := "Int", ret.module := "WindowsAccessBridge.dll", ret.ptr := DllCall("LoadLibrary", "Str", ret.module, "ptr")
        }
        if !ret.ptr
            return ; Failed to load library. Make sure you are running the script in the correct bitness and/or Java for the architecture is installed.
        DllCall(ret.module "\Windows_run", "Cdecl Int")
        return ret
    }
}
