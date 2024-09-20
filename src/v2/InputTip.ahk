#Requires AutoHotkey >v2.0
;@AHK2Exe-SetName InputTip v2
;@AHK2Exe-SetVersion 2.16.0
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具
;@Ahk2Exe-SetCopyright Copyright (c) 2024-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource InputTipCursor.zip
#SingleInstance Force
Persistent
ListLines 0
KeyHistory 0
DetectHiddenWindows 1
InstallKeybdHook
InstallMouseHook
CoordMode 'Mouse', 'Screen'
SetStoreCapsLockMode 0

#Include .\utils\ini.ahk
#Include ..\utils\IME.ahk
#Include ..\utils\showMsg.ahk
#Include ..\utils\checkVersion.ahk

currentVersion := "2.16.0"
checkVersion(currentVersion, "v2")

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
    app_hide_CN_EN := IniRead("InputTip.ini", "config-v2", "app_hide_CN_EN")
} catch {
    try {
        app_hide_CN_EN := IniRead("InputTip.ini", "config-v2", "window_no_display")
    } catch {
        app_hide_CN_EN := ""
    }
    writeIni("app_hide_CN_EN", app_hide_CN_EN)
}

HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
changeCursor := readIni("changeCursor", 1)
showSymbol := readIni("showSymbol", 1)
HideSymbolDelay := readIni("HideSymbolDelay", 0)
CN_color := StrReplace(readIni("CN_color", "red"), '#', '')
EN_color := StrReplace(readIni("EN_color", "blue"), '#', '')
Caps_color := StrReplace(readIni("Caps_color", "green"), '#', '')
transparent := readIni('transparent', 222)
offset_x := readIni('offset_x', 10)
offset_y := readIni('offset_y', -10)
symbol_height := readIni('symbol_height', 7)
symbol_width := readIni('symbol_width', 7)
; 隐藏中英文状态方块符号提示
app_hide_CN_EN := "," app_hide_CN_EN ","
; 隐藏输入法状态方块符号提示
app_hide_state := "," readIni('app_hide_state', '') ","
app_CN := "," readIni('app_CN', '') ","
app_EN := "," readIni('app_EN', '') ","
app_Caps := "," readIni('app_Caps', '') ","
hotkey_CN := readIni('hotkey_CN', '')
hotkey_EN := readIni('hotkey_EN', '')
hotkey_Caps := readIni('hotkey_Caps', '')
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
borderWidth := (symbol_width + border_margin_left + border_margin_right) * A_ScreenDPI / 96
borderHeight := (symbol_height + border_margin_top + border_margin_bottom) * A_ScreenDPI / 96
borderOffsetX := offset_x + border_margin_left * A_ScreenDPI / 96 * A_ScreenDPI / 96
borderOffsetY := offset_y + border_margin_top * A_ScreenDPI / 96 * A_ScreenDPI / 96
; 屏幕分辨率
screenList := getScreenInfo()
; 特别的偏移量设置
offset := Map()

; 文本字符相关的配置
showChar := readIni("showChar", 0)
font_family := readIni('font_family', '微软雅黑')
font_size := readIni('font_size', 7)
font_weight := readIni('font_weight', 600)
font_color := StrReplace(readIni('font_color', 'ffffff'), '#', '')
CN_Text := readIni('CN_Text', '中')
EN_Text := readIni('EN_Text', '英')
Caps_Text := readIni('Caps_Text', '大')

for v in screenList {
    offset["offset_x_" v.num] := readIni("offset_x_" v.num, 0)
    offset["offset_y_" v.num] := readIni("offset_y_" v.num, 0)
}
if (hotkey_CN) {
    Hotkey(hotkey_CN, switch_CN)
}
if (hotkey_EN) {
    Hotkey(hotkey_EN, switch_EN)
}
if (hotkey_Caps) {
    Hotkey(hotkey_Caps, switch_Caps)
}
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
}]
curMap := {
    ARROW: "Arrow", IBEAM: "IBeam", WAIT: "Wait", CROSS: "Crosshair", UPARROW: "UpArrow", SIZENWSE: "SizeNWSE", SIZENESW: "SizeNESW", SIZEWE: "SizeWE", SIZENS: "SizeNS", SIZEALL: "SizeAll", NO: "No", HAND: "Hand", APPSTARTING: "AppStarting", HELP: "Help", PIN: "Pin", PERSON: "Person", PEN: "NWPen"
}

if (changeCursor) {
    if (!DirExist("InputTipCursor")) {
        FileExist("InputTipCursor.zip") ? 0 : FileInstall("InputTipCursor.zip", "InputTipCursor.zip", 1)
        RunWait("powershell -NoProfile -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_ScriptDir "'", , "Hide")
        FileDelete("InputTipCursor.zip")
    } else {
        noList := [], dirList := ["CN", "CN_Default", "EN", "EN_Default", "Caps", "Caps_Default"]
        for dir in dirList {
            if (!DirExist("InputTipCursor\" dir)) {
                noList.push(dir)
            }
        }
        if (noList.length > 0) {
            RunWait("powershell -NoProfile -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_AppData "\abgox-InputTipCursor-temp'", , "Hide")
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
} else {
    for v in info {
        try {
            v.origin := replaceEnvVariables(RegRead("HKEY_CURRENT_USER\Control Panel\Cursors", curMap.%v.type%))
        }
    }
}

state := 1, old_state := '', old_left := '', old_top := '', isShowCN := 1, isShowEN := 0, isShowCaps := 0, left := 0, top := 0
TipGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
if (showChar) {
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

    TipGuiText := TipGui.AddText("w" Gui_width, CN_Text)
}
WinSetTransparent(transparent)
switch border_type {
    case 1: TipGui.Opt("-LastFound +e0x00000001")
    case 2: TipGui.Opt("-LastFound +e0x00000200")
    case 3: TipGui.Opt("-LastFound +e0x00020000")
    default: TipGui.Opt("-LastFound")
}

TipGui.BackColor := CN_color

borderGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
WinSetTransparent(border_transparent)
borderGui.Opt("-LastFound")
borderGui.BackColor := border_color_CN
lastWindow := ""
needHide := 1
if (changeCursor) {
    show("CN")
    if (showSymbol) {
        while 1 {
            is_hide_CN_EN := 0
            is_hide_state := 0
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                if (exe_name != lastWindow) {
                    needHide := 0
                    SetTimer((*) {
                        global needHide := 1
                    }, HideSymbolDelay)
                    WinWaitActive("ahk_exe" exe_name)
                    lastWindow := exe_name
                    if (InStr(app_CN, "," exe_name ",")) {
                        switch_CN()
                    } else if (InStr(app_EN, "," exe_name ",")) {
                        switch_EN()
                    } else if (InStr(app_Caps, "," exe_name ",")) {
                        switch_Caps()
                    }
                }
                is_hide_state := InStr(app_hide_state, "," exe_name ",")
                is_hide_CN_EN := InStr(app_hide_CN_EN, "," exe_name ",")
            }
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                continue
            }
            if (A_TimeIdle < 500) {
                if (is_hide_state || (is_hide_CN_EN && !isShowCaps)) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
                    canShowSymbol := GetCaretPosEx(&left, &top)
                }
                if (GetKeyState("CapsLock", "T")) {
                    if (isShowCaps) {
                        if (left != old_left || top != old_top) {
                            old_left := left
                            old_top := top
                            canShowSymbol ? TipShow("Caps") : TipGui.Hide()
                        }
                    } else {
                        isShowCN := 0
                        isShowEN := 0
                        isShowCaps := 1
                        old_left := left
                        old_top := top
                        show("Caps")
                        if (canShowSymbol) {
                            TipGui.BackColor := Caps_color, borderGui.BackColor := border_color_Caps
                            TipShow("Caps")
                        } else {
                            TipGui.Hide()
                        }
                    }
                    Sleep(50)
                    continue
                }
                try {
                    state := isCN(mode)
                } catch {
                    TipGui.Hide()
                    Sleep(50)
                    continue
                }
                if (isShowCaps) {
                    if (state) {
                        show("CN")
                        isShowCN := 1
                        isShowEN := 0
                        TipGui.BackColor := CN_color
                        borderGui.BackColor := border_color_CN
                    } else {
                        show("EN")
                        isShowCN := 0
                        isShowEN := 1
                        TipGui.BackColor := EN_color
                        borderGui.BackColor := border_color_EN
                    }
                    isShowCaps := 0
                    isShow := 1
                }
                if (state != old_state || left != old_left || top != old_top) {
                    old_state := state
                    old_left := left
                    old_top := top
                    if (state) {
                        if (!isShowCN) {
                            show("CN")
                            isShowCN := 1
                            isShowEN := 0
                            isShowCaps := 0
                            TipGui.BackColor := CN_color
                            borderGui.BackColor := border_color_CN
                        }
                    } else {
                        if (!isShowEN) {
                            show("EN")
                            isShowCN := 0
                            isShowEN := 1
                            isShowCaps := 0
                            TipGui.BackColor := EN_color
                            borderGui.BackColor := border_color_EN
                        }
                    }
                    isShow := !is_hide_CN_EN && canShowSymbol
                }
                if (isShow) {
                    state ? TipShow("CN") : TipShow("EN")
                    isShow := 0
                }
            }
            Sleep(50)
        }
    } else {
        while 1 {
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                if (exe_name != lastWindow) {
                    WinWaitActive("ahk_exe" exe_name)
                    lastWindow := exe_name
                    if (InStr(app_CN, "," exe_name ",")) {
                        switch_CN()
                    } else if (InStr(app_EN, "," exe_name ",")) {
                        switch_EN()
                    } else if (InStr(app_Caps, "," exe_name ",")) {
                        switch_Caps()
                    }
                }
            }
            if (A_TimeIdle < 500) {
                if (GetKeyState("CapsLock", "T")) {
                    if (!isShowCaps) {
                        show("Caps")
                        isShowCaps := 1
                    }
                    Sleep(50)
                    continue
                }
                try {
                    state := isCN(mode)
                } catch {
                    Sleep(50)
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
        while 1 {
            is_hide_CN_EN := 0
            is_hide_state := 0
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                if (exe_name != lastWindow) {
                    WinWaitActive("ahk_exe" exe_name)
                    lastWindow := exe_name
                    if (InStr(app_CN, "," exe_name ",")) {
                        switch_CN()
                    } else if (InStr(app_EN, "," exe_name ",")) {
                        switch_EN()
                    } else if (InStr(app_Caps, "," exe_name ",")) {
                        switch_Caps()
                    }
                }
                is_hide_state := InStr(app_hide_state, "," exe_name ",")
                is_hide_CN_EN := InStr(app_hide_CN_EN, "," exe_name ",")
            }
            if (A_TimeIdle < 500) {
                if (is_hide_state || (is_hide_CN_EN && !isShowCaps)) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
                    canShowSymbol := GetCaretPosEx(&left, &top)
                }
                if (GetKeyState("CapsLock", "T")) {
                    if (isShowCaps) {
                        if (left != old_left || top != old_top) {
                            old_left := left
                            old_top := top
                            canShowSymbol ? TipShow("Caps") : TipGui.Hide()
                        }
                    } else {
                        isShowCN := 0
                        isShowEN := 0
                        isShowCaps := 1
                        old_left := left
                        old_top := top
                        show("Caps")
                        if (canShowSymbol) {
                            TipGui.BackColor := Caps_color, borderGui.BackColor := border_color_Caps
                            TipShow("Caps")
                        } else {
                            TipGui.Hide()
                        }
                    }
                    Sleep(50)
                    continue
                }
                try {
                    state := isCN(mode)
                } catch {
                    TipGui.Hide()
                    Sleep(50)
                    continue
                }
                if (isShowCaps) {
                    if (state) {
                        isShowCN := 1
                        isShowEN := 0
                        TipGui.BackColor := CN_color
                        borderGui.BackColor := border_color_CN
                    } else {
                        isShowCN := 0
                        isShowEN := 1
                        TipGui.BackColor := EN_color
                        borderGui.BackColor := border_color_EN
                    }
                    isShowCaps := 0
                    isShow := 1
                }
                if (state != old_state || left != old_left || top != old_top) {
                    old_state := state
                    old_left := left
                    old_top := top
                    if (state) {
                        if (!isShowCN) {
                            isShowCN := 1
                            isShowEN := 0
                            isShowCaps := 0
                            TipGui.BackColor := CN_color
                            borderGui.BackColor := border_color_CN
                        }
                    } else {
                        if (!isShowEN) {
                            isShowCN := 0
                            isShowEN := 1
                            isShowCaps := 0
                            TipGui.BackColor := EN_color
                            borderGui.BackColor := border_color_EN
                        }
                    }
                    isShow := !is_hide_CN_EN && canShowSymbol
                }
                if (isShow) {
                    state ? TipShow("CN") : TipShow("EN")
                    isShow := 0
                }
            }
            Sleep(50)
        }
    }
}

TipShow(type) {
    if (showChar) {
        if (%type "_Text"%) {
            TipGuiText.Value := %type "_Text"%
            TipGui.Show("NA x" left + offset_x "y" top + offset_y)
        } else {
            TipGui.Hide()
        }
    } else {
        if (border_type = 4) {
            if (TipGui.BackColor) {
                borderGui.Show("NA w" borderWidth "h" borderHeight "x" left + offset_x "y" top + offset_y)
                TipGui.Show("NA w" symbolWidth "h" symbolHeight "x" left + borderOffsetX "y" top + borderOffsetY)
            } else {
                borderGui.Hide()
                TipGui.Hide()
            }
            return
        }
        if (TipGui.BackColor) {
            TipGui.Show("NA w" symbolWidth "h" symbolHeight "x" left + offset_x "y" top + offset_y)
        } else {
            TipGui.Hide()
        }
    }
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
    list := ["模式1", "模式2", "模式3", "模式4"]
    for v in list {
        sub.Add(v, (item, index, *) {
            mode := readIni("mode", 1, "InputMethod")
            msgGui := Gui("AlwaysOnTop +OwnDialogs")
            msgGui.SetFont("s10", "微软雅黑")
            msgGui.AddLink("", '<a href="https://inputtip.pages.dev/v2/#兼容情况">https://inputtip.pages.dev/v2/#兼容情况</a>`n<a href="https://github.com/abgox/InputTip#兼容情况">https://github.com/abgox/InputTip#兼容情况</a>`n<a href="https://gitee.com/abgox/InputTip#兼容情况">https://gitee.com/abgox/InputTip#兼容情况</a>')
            msgGui.Show("Hide")
            msgGui.GetPos(, , &Gui_width)
            msgGui.Destroy()

            msgGui := Gui("AlwaysOnTop +OwnDialogs", A_ScriptName " - 模式切换")
            msgGui.SetFont("s12", "微软雅黑")
            if (mode != index) {
                msgGui.AddText("", "是否要从 模式" mode " 切换到 模式" index " ?`n----------------------------------------------")
            } else {
                msgGui.AddText("", "当前正在使用 模式" index "`n----------------------------------------------")
            }
            msgGui.AddText(, "模式相关信息请查看以下任意地址:")
            msgGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v2/#兼容情况">https://inputtip.pages.dev/v2/#兼容情况</a>`n<a href="https://github.com/abgox/InputTip#兼容情况">https://github.com/abgox/InputTip#兼容情况</a>`n<a href="https://gitee.com/abgox/InputTip#兼容情况">https://gitee.com/abgox/InputTip#兼容情况</a>')
            msgGui.AddButton("xs w" Gui_width + msgGui.MarginX * 2, "确认").OnEvent("Click", yes)
            msgGui.Show()
            yes(*) {
                msgGui.Destroy()
                writeIni("mode", index, "InputMethod")
                fn_restart()
            }
        })
    }
    A_TrayMenu.Add("设置输入法", sub)
    sub.Check("模式" mode)
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", (*) {
        size := A_ScreenHeight < 1000 ? "s10" : "s12"
        configGui := Gui("AlwaysOnTop OwnDialogs")
        configGui.SetFont(size, "微软雅黑")
        configGui.AddText(, "输入框中的值是当前生效的值`n-----------------------------------------------------------------------------------------------")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()
        configGui := Gui("AlwaysOnTop OwnDialogs", "InputTip v2 - 更改配置")
        configGui.SetFont(size, "微软雅黑")
        configList := [{
            config: "changeCursor",
            options: "Number Limit1",
            tip: "是否更改鼠标样式"
        }, {
            config: "showSymbol",
            options: "Number Limit1",
            tip: "是否显示方块符号"
        }, {
            config: "showChar",
            options: "Number Limit1",
            tip: "是否显示文本字符"
        }, {
            config: "CN_color",
            options: "",
            tip: "中文状态时方块符号的颜色"
        }, {
            config: "EN_color",
            options: "",
            tip: "英文状态时方块符号的颜色"
        }, {
            config: "Caps_color",
            options: "",
            tip: "大写锁定时方块符号的颜色"
        }, {
            config: "transparent",
            options: "Number",
            tip: "方块符号的透明度"
        }, {
            config: "offset_x",
            options: "",
            tip: "方块符号的水平偏移量"
        }, {
            config: "offset_y",
            options: "",
            tip: "方块符号的垂直偏移量"
        }, {
            config: "symbol_height",
            options: "",
            tip: "方块符号的高度"
        }, {
            config: "symbol_width",
            options: "",
            tip: "方块符号的宽度"
        }, {
            config: "HideSymbolDelay",
            options: "Number",
            tip: "方块符号在多少毫秒后隐藏(默认为0，即不隐藏)"
        }, {
            config: "font_family",
            options: "",
            tip: "设置字符的字体"
        }, {
            config: "font_size",
            options: "Number",
            tip: "设置字符的大小"
        }, {
            config: "font_weight",
            options: "Number",
            tip: "设置字符的粗细"
        }, {
            config: "font_color",
            options: "",
            tip: "设置字符的颜色"
        }, {
            config: "CN_Text",
            options: "",
            tip: "设置中文状态时显示的字符"
        }, {
            config: "EN_Text",
            options: "",
            tip: "设置英文状态时显示的字符"
        }, {
            config: "Caps_Text",
            options: "",
            tip: "设置大写锁定时显示的字符"
        }]

        tab := configGui.AddTab3(, ["显示形式", "鼠标样式配置", "方块符号配置", "方块符号边框配置", "文本字符配置", "在线配置文件说明", "配色网站"])
        tab.UseTab(1)
        configGui.AddText("Section", "- 以下配置项只能使用 1 或 0，1 表示是，0 表示否`n- 文本字符是在方块符号的基础上添加的`n  - 因此如果显示文本字符设置为 1，则显示方块符号也必须设置为 1`n  - 当显示方块符号设置为 0，即使显示文本字符设置为 1 也无效")
        list := [configList[1], configList[2], configList[3]]
        for v in list {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w100 " v.options, %v.config%)
        }
        tab.UseTab(2)
        configGui.AddText(, "你可以从以下任意可用地址中获取设置鼠标样式文件夹的相关说明:")
        configGui.AddLink(, '<a href="https://inputtip.pages.dev/v2/#自定义光标样式">https://inputtip.pages.dev/v2/#自定义光标样式</a>`n<a href="https://github.com/abgox/InputTip#自定义光标样式">https://github.com/abgox/InputTip#自定义光标样式</a>`n<a href="https://gitee.com/abgox/InputTip#自定义光标样式">https://gitee.com/abgox/InputTip#自定义光标样式</a>')
        configGui.AddButton("w" Gui_width, "设置中文状态鼠标样式").OnEvent("Click", (*) {
            configGui.Destroy()
            if (!changeCursor) {
                MsgBox("请先在配置中将 是否更改鼠标样式 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
                return
            }
            dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为中文鼠标样式 (不能是 CN/EN/Caps 文件夹)")
            verify(dir, 'CN')
        })
        configGui.AddButton("w" Gui_width, "设置英文状态鼠标样式").OnEvent("Click", (*) {
            configGui.Destroy()
            if (!changeCursor) {
                MsgBox("请先在配置中将 是否更改鼠标样式 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
                return
            }
            dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为英文鼠标样式 (不能是 CN/EN/Caps 文件夹)")
            verify(dir, 'EN')
        })
        configGui.AddButton("w" Gui_width, "设置大写锁定鼠标样式").OnEvent("Click", (*) {
            configGui.Destroy()
            if (!changeCursor) {
                MsgBox("请先在配置中将 是否更改鼠标样式 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
                return
            }
            dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为大写锁定鼠标样式 (不能是 CN/EN/Caps 文件夹)")
            verify(dir, 'Caps')
        })
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
            if (dir_name = "EN" || dir_name = "CN" || dir_name = "Caps") {
                MsgBox("不能选择 CN/EN/Caps 文件夹！", , "0x30 0x1000")
                return
            }
            try {
                DirDelete(A_ScriptDir "\InputTipCursor\" folder, 1)
                DirCopy(dir, A_ScriptDir "\InputTipCursor\" folder, 1)
                MsgBox("鼠标样式文件夹修改成功!")
            }
        }
        configGui.AddButton("w" Gui_width, "下载鼠标样式包").OnEvent("Click", (*) {
            configGui.Destroy()
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
        })
        tab.UseTab(3)
        configGui.AddText("Section", "- 对于不同状态时的颜色设置，可以留空，留空表示不显示方块符号")
        list := [configList[4], configList[5], configList[6], configList[7], configList[8], configList[9], configList[10], configList[11], configList[12]]
        for v in list {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w100 " v.options, %v.config%)
        }
        tab.UseTab(4)
        configGui.AddText(, "目前可以使用三种样式`n- 样式1: 普通边框`n- 样式2: 带有凹陷边缘的边框`n- 样式3: 与样式2相比，差别不大，更细一点`n建议可以都尝试一下，然后选择自己喜欢的样式，也可以自定义样式边框")
        configGui.AddButton("w" Gui_width, "设置为样式1").OnEvent("Click", (*) {
            set(1)
        })
        configGui.AddButton("w" Gui_width, "设置为样式2").OnEvent("Click", (*) {
            set(2)
        })
        configGui.AddButton("w" Gui_width, "设置为样式3").OnEvent("Click", (*) {
            set(3)
        })
        configGui.AddButton("w" Gui_width, "去掉边框样式").OnEvent("Click", (*) {
            set(0)
        })
        set(type) {
            writeIni("border_type", type)
            fn_restart()
        }
        configGui.AddButton("w" Gui_width, "自定义样式边框").OnEvent("Click", (*) {
            configGui.Destroy()
            customGui := Gui("AlwaysOnTop OwnDialogs")
            customGui.SetFont("s12", "微软雅黑")
            customGui.AddText("", "输入框中的值是当前生效的值`n-----------------------------------------------------------------------------------")
            customGui.Show("Hide")
            customGui.GetPos(, , &Gui_width)
            customGui.Destroy()

            customGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 自定义方块符号样式边框")
            customGui.SetFont("s12", "微软雅黑")
            customGui.AddText("", "输入框中的值是当前生效的值`n-----------------------------------------------------------------------------------")

            configList := [{
                config: "border_margin_left",
                options: "Number",
                tip: "左边的边框宽度"
            }, {
                config: "border_margin_right",
                options: "Number",
                tip: "右边的边框宽度"
            }, {
                config: "border_margin_top",
                options: "Number",
                tip: "上边的边框宽度"
            }, {
                config: "border_margin_bottom",
                options: "Number",
                tip: "下边的边框宽度"
            }, {
                config: "border_color_CN",
                options: "",
                tip: "中文状态时的边框颜色"
            }, {
                config: "border_color_EN",
                options: "",
                tip: "英文状态时的边框颜色"
            }, {
                config: "border_color_Caps",
                options: "",
                tip: "大写状态时的边框颜色"
            }, {
                config: "border_transparent",
                options: "Number",
                tip: "边框的透明度"
            }]
            isFirst := 1
            for v in configList {
                if (isFirst) {
                    customGui.AddText("xs", v.tip ": ")
                } else {
                    customGui.AddText("yp x" Gui_width / 2, v.tip ": ")
                }
                isFirst := !isFirst
                customGui.AddEdit("v" v.config " yp w100 " v.options, %v.config%)
            }
            customGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", saveConfig)
            customGui.Show()

            saveConfig(*) {
                list := [configList[1], configList[2], configList[3], configList[4]]
                isValid := 1
                for v in list {
                    if (!IsNumber(customGui.Submit().%v.config%)) {
                        showMsg(["配置错误!", v.tip " 应该是一个数字。"])
                        isValid := 0
                    }
                }
                list := [configList[5], configList[6], configList[7]]
                for v in list {
                    if (!isColor(customGui.Submit().%v.config%)) {
                        showMsg(["配置错误!", v.tip " 应该是一个颜色英文单词或者十六进制颜色值。", "支持的颜色英文单词: red, blue, green, yellow, purple, gray, black, white"])
                        isValid := 0
                    }
                }
                transparent := customGui.Submit().border_transparent
                if (IsFloat(transparent)) {
                    showMsg(["配置错误!", "它不能是一个小数", configList[8].tip " 应该是 0 到 255 之间的整数。"])
                    isValid := 0
                } else {
                    if (transparent < 0 || transparent > 255) {
                        showMsg(["配置错误!", configList[8].tip " 应该是 0 到 255 之间的整数。"])
                        isValid := 0
                    }
                }
                isColor(v) {
                    v := StrReplace(v, "#", "")
                    colorList := ",red,blue,green,yellow,purple,gray,black,white,"
                    if (InStr(colorList, "," v ",")) {
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
                if (isValid) {
                    writeIni("border_type", 4)
                    for item in configList {
                        writeIni(item.config, customGui.Submit().%item.config%)
                    }
                    fn_restart()
                }
            }
        })

        tab.UseTab(5)
        list := [configList[13], configList[14], configList[15], configList[16], configList[17], configList[18], configList[19]]
        configGui.AddText("Section", "- 不同状态下的背景颜色以及偏移量由方块符号配置中的相关配置决定`n- 对于不同状态时的字符设置，可以留空，留空表示不显示")
        for v in list {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w100 " v.options, %v.config%)
        }
        tab.UseTab(6)
        configGui.AddText(, "你可以从以下任意可用地址中获取配置说明:")
        configGui.AddLink(, '<a href="https://inputtip.pages.dev/v2/config">https://inputtip.pages.dev/v2/config</a>')
        configGui.AddLink(, '<a href="https://github.com/abgox/InputTip/blob/main/src/v2/config.md">https://github.com/abgox/InputTip/blob/main/src/v2/config.md</a>')
        configGui.AddLink(, '<a href="https://gitee.com/abgox/InputTip/blob/main/src/v2/config.md">https://gitee.com/abgox/InputTip/blob/main/src/v2/config.md</a>')
        tab.UseTab(7)
        configGui.AddText(, "- 对于配置中颜色相关的配置，建议使用16进制的颜色值`n- 不过由于没有调色板，可能并不好设置`n- 建议使用以下配色网站(也可以自己去找)，找到喜欢的颜色，复制16进制值`n- 显示的颜色以最终渲染的颜色效果为准")
        configGui.AddLink(, '<a href="https://colorhunt.co">https://colorhunt.co</a>')
        configGui.AddLink(, '<a href="https://materialui.co/colors">https://materialui.co/colors</a>')
        configGui.AddLink(, '<a href="https://color.adobe.com/zh/create/color-wheel">https://color.adobe.com/zh/create/color-wheel</a>')
        configGui.AddLink(, '<a href="https://colordesigner.io/color-palette-builder">https://colordesigner.io/color-palette-builder</a>')
        tab.UseTab(0)
        configGui.AddButton(" w" Gui_width + configGui.MarginX * 2, "确认").OnEvent("Click", changeConfig)
        changeConfig(*) {
            isColor(v) {
                v := StrReplace(v, "#", "")
                colorList := ",red,blue,green,yellow,purple,gray,black,white,"
                if (InStr(colorList, "," v ",")) {
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
            list := [configList[1], configList[2], configList[3]]
            for v in list {
                value := configGui.Submit().%v.config%
                if (value != 1 && value != 0) {
                    showMsg(["配置错误!", v.tip " 的值只能是 0 或 1。"])
                    isValid := 0
                }
            }
            list := [configList[4], configList[5], configList[6], configList[15]]
            for v in list {
                if (!isColor(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个颜色英文单词或者十六进制颜色值。", "支持的颜色英文单词: red, blue, green, yellow, purple, gray, black, white"])
                    isValid := 0
                }
            }
            transparent := configGui.Submit().transparent
            if (IsFloat(transparent)) {
                showMsg(["配置错误!", configList[7].tip " 不能是一个小数"])
                isValid := 0
            } else {
                if (transparent < 0 || transparent > 255) {
                    showMsg(["配置错误!", configList[7].tip " 应该是 0 到 255 之间的整数。"])
                    isValid := 0
                }
            }
            list := [configList[8], configList[9]]
            for v in list {
                if (!IsNumber(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个数字。"])
                    isValid := 0
                }
            }
            list := [configList[10], configList[11]]
            for v in list {
                value := configGui.Submit().%v.config%
                if (!IsNumber(value) || value < 0) {
                    showMsg(["配置错误!", v.tip " 应该是一个大于 0 的数字。"])
                    isValid := 0
                }
            }
            if (isValid) {
                if (configGui.Submit().changeCursor = 0) {
                    for v in info {
                        DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
                    }
                    MsgBox("尝试恢复默认鼠标样式。`n如果没有正常恢复，请重启电脑。")
                }
                for item in configList {
                    writeIni(item.config, configGui.Submit().%item.config%)
                }
                fn_restart()
            }
        }
        configGui.Show()
    })
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
                        if (!InStr(temp, exe_name ",") && !InStr(value, exe_name ",")) {
                            temp .= exe_name ","
                            LV.Add(, exe_name, WinGetTitle("ahk_id " v))
                        }
                    }
                }
                DetectHiddenWindows 1
                addGui.AddButton("xs w" Gui_width, "没有找到需要添加的进程，你可以点击此按钮手动添加进程").OnEvent("Click", (*) {
                    g := Gui("AlwaysOnTop OwnDialogs")
                    g.SetFont("s12", "微软雅黑")
                    g.AddText(, "- 进程名称应该是 xxx.exe 这样的格式，例如: QQ.exe`n- 每一次只能添加一个")
                    g.Show("Hide")
                    g.GetPos(, , &Gui_width)
                    g.Destroy()

                    g := Gui("AlwaysOnTop OwnDialogs")
                    g.SetFont("s12", "微软雅黑")
                    g.AddText(, "手动添加进程")
                    g.AddText(, "- 进程名称应该是 xxx.exe 这样的格式，例如: QQ.exe`n- 每一次只能添加一个")
                    g.AddText(, "进程名称: ")
                    g.AddEdit("yp vexe_name", "")
                    g.AddButton("xs w" Gui_width, "确认添加").OnEvent("Click", (*) {
                        exe_name := g.Submit().exe_name
                        value := readIni(tipList[1], "")
                        valueArr := StrSplit(value, ",")
                        result := ""
                        is_exist := 0
                        for v in valueArr {
                            if (v = exe_name) {
                                is_exist := 1
                            }
                            if (Trim(v)) {
                                result .= v ","
                            }
                        }
                        if (is_exist) {
                            MsgBox(exe_name " 已存在!", , "0x1000")
                        } else {
                            addFn(exe_name)
                            writeIni(tipList[1], result exe_name)
                        }
                        g.Destroy()
                    })
                    g.Show()
                })
                LV.ModifyCol(1, "Auto")
                addGui.OnEvent("Close", close)
                close(*) {
                    fn_restart()
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
                        fn_restart()
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
                        fn_restart()
                    }
                    rmGui.Show()
                }
            }
        }
    }
    sub1.Add("自动切换中文状态", (*) {
        fn_common(
            [
                "app_CN",
                "将应用添加到自动切换中文状态的应用列表中",
                "从自动切换中文状态的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到自动切换中文状态的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 添加到自动切换中文状态的应用列表中？`n--------------------------------------------------------------------------------------------------------------`n- 添加后，当从其他应用首次切换到此应用中，InputTip 会自动切换到中文状态",
                "以下列表中是自动切换中文状态的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 移除？`n移除后，当从其他应用首次切换到此应用中，InputTip 不会再自动切换到中文状态"
            ], fn
        )
        fn(RowText) {
            value_EN := "," readIni("app_EN", "") ","
            value_Caps := "," readIni("app_Caps", "") ","
            if (InStr(value_EN, "," RowText ",")) {
                valueArr := StrSplit(value_EN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
            }

            if (InStr(value_Caps, "," RowText ",")) {
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
    })
    sub1.Add("自动切换英文状态", (*) {
        fn_common(
            [
                "app_EN",
                "将应用添加到自动切换英文状态的应用列表中",
                "从自动切换英文状态的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到自动切换英文状态的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 添加到自动切换英文状态的应用列表中？`n--------------------------------------------------------------------------------------------------------------`n- 添加后，当从其他应用首次切换到此应用中，InputTip 会自动切换英文状态",
                "以下列表中是自动切换英文状态的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 移除？`n移除后，当从其他应用首次切换到此应用中，InputTip 不会再自动切换英文状态"
            ],
            fn
        )
        fn(RowText) {
            value_CN := "," readIni("app_CN", "") ","
            value_Caps := "," readIni("app_Caps", "") ","
            if (InStr(value_CN, "," RowText ",")) {
                valueArr := StrSplit(value_CN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
            }

            if (InStr(value_Caps, "," RowText ",")) {
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
    })
    sub1.Add("自动切换大写锁定状态", (*) {
        fn_common(
            [
                "app_Caps",
                "将应用添加到自动切换大写锁定状态的应用列表中",
                "从自动切换大写锁定状态的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到自动切换大写锁定状态的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 添加到自动切换大写锁定状态的应用列表中？`n--------------------------------------------------------------------------------------------------------------`n- 添加后，当从其他应用首次切换到此应用中，InputTip 会自动切换大写锁定状态",
                "以下列表中是自动切换大写锁定状态的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
                "是否要将 ",
                " 移除？`n移除后，当从其他应用首次切换到此应用中，InputTip 不会再自动切换大写锁定状态"
            ],
            fn
        )
        fn(RowText) {
            value_CN := "," readIni("app_CN", "") ","
            value_EN := "," readIni("app_EN", "") ","
            if (InStr(value_CN, "," RowText ",")) {
                valueArr := StrSplit(value_CN, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
            }

            if (InStr(value_EN, "," RowText ",")) {
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
    })
    A_TrayMenu.Add("设置自动切换", sub1)
    A_TrayMenu.Add("设置强制切换快捷键", (*) {
        hotkeyGui := Gui("AlwaysOnTop OwnDialogs")
        hotkeyGui.SetFont("s12", "微软雅黑")
        hotkeyGui.AddText(, "- 当右侧的 Win 复选框勾选后，表示快捷键中加入 Win 修饰键`n- 使用 Backspace(退格键) 或 Delete(删除键) 可以移除不需要的快捷键")
        hotkeyGui.Show("Hide")
        hotkeyGui.GetPos(, , &Gui_width)
        hotkeyGui.Destroy()

        hotkeyGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 设置强制切换输入法状态的快捷键")
        hotkeyGui.SetFont("s12", "微软雅黑")
        hotkeyGui.AddText(, "- 当右侧的 Win 复选框勾选后，表示快捷键中加入 Win 修饰键`n- 使用 Backspace(退格键) 或 Delete(删除键) 可以移除不需要的快捷键")
        hotkeyGui.AddText("Center w" Gui_width, "-----------------------------------------------------------------------------------")

        configList := [{
            config: "hotkey_CN",
            options: "",
            tip: "强制切换到中文状态",
            with: "win_CN",
        }, {
            config: "hotkey_EN",
            options: "",
            tip: "强制切换到英文状态",
            with: "win_EN",
        }, {
            config: "hotkey_Caps",
            options: "",
            tip: "强制切换到大写锁定",
            with: "win_Caps",
        }]

        for v in configList {
            hotkeyGui.AddText("xs", v.tip ": ")
            value := readIni(v.config, '')
            hotkeyGui.AddHotkey("yp v" v.config, StrReplace(value, "#", ""))
            hotkeyGui.AddCheckbox("yp v" v.with, "Win").Value := InStr(value, "#")
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", (*) {
            for v in configList {
                if (hotkeyGui.Submit().%v.with%) {
                    key := "#" hotkeyGui.Submit().%v.config%
                } else {
                    key := hotkeyGui.Submit().%v.config%
                }
                writeIni(v.config, key)
            }
            fn_restart()
        })
        hotkeyGui.Show()
    })
    sub2 := Menu()
    sub2.Add("隐藏中英文状态方块符号提示", (*) {
        fn_common(
            [
                "app_hide_CN_EN",
                "将应用添加到隐藏中英文状态方块符号提示的应用列表中",
                "从隐藏中英文状态方块符号提示的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏中英文状态方块符号提示的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在两个隐藏列表中(隐藏中英文/输入法状态方块符号提示)，同时添加了同一个应用，只有最新的生效，另一个会被移除",
                "是否要将 ",
                " 添加到隐藏中英文状态方块符号提示的应用列表中？`n------------------------------------------------`n此列表中的效果:`n- InputTip.exe 不会根据中英文状态显示不同颜色的方块符号`n- 只会显示大写锁定方块符号",
                "以下列表中是隐藏中英文状态方块符号提示的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在两个隐藏列表中(隐藏中英文/输入法状态方块符号提示)，同时添加了同一个应用，只有最新的生效，另一个会被移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据中英文状态显示不同颜色的方块符号"
            ],
            fn
        )
        fn(RowText) {
            value := "," readIni("app_hide_state", "") ","
            if (InStr(value, "," RowText ",")) {
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
    })
    sub2.Add("隐藏输入法状态方块符号提示", (*) {
        fn_common(
            [
                "app_hide_state",
                "将应用添加到隐藏输入法状态方块符号提示的应用列表中",
                "从隐藏输入法状态方块符号提示的应用列表中移除应用",
                "以下列表中是当前系统正在运行的应用程序",
                "双击应用程序，将其添加到隐藏输入法状态方块符号提示的应用列表中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在两个隐藏列表中(隐藏中英文/输入法状态方块符号提示)，同时添加了同一个应用，只有最新的生效，另一个会被移除",
                "是否要将 ",
                " 添加到隐藏输入法状态方块符号提示的应用列表中？`n------------------------------------------------`n此列表中的效果`n- InputTip.exe 不会显示方块符号`n- 中英文/大写锁定状态下的方块符号都不会显示",
                "以下列表中是隐藏输入法状态方块符号提示的应用列表",
                "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的窗口设置才生效`n- 在两个隐藏列表中(隐藏中英文/输入法状态方块符号提示)，同时添加了同一个应用，只有最新的生效，另一个会被移除",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会根据输入法状态显示不同颜色的方块符号"
            ],
            fn
        )
        fn(RowText) {
            value := "," readIni("app_hide_CN_EN", "") ","
            if (InStr(value, "," RowText ",")) {
                valueArr := StrSplit(value, ",")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= "," v
                    }
                }
                writeIni("app_hide_CN_EN", SubStr(result, 2))
            }
        }
    })
    A_TrayMenu.Add("设置特殊软件", sub2)
    A_TrayMenu.Add("关于", (*) {
        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center h30", "InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center h30 w" Gui_width, "InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具")
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

    })
    A_TrayMenu.Add("重启", fn_restart)
    fn_restart(*) {
        Run(A_ScriptFullPath)
    }
    A_TrayMenu.Add("退出", (*) {
        ExitApp()
    })
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
isWhichScreen() {
    MouseGetPos(&x, &y)
    for v in screenList {
        if (x >= v.left && x <= v.right && y >= v.top && y <= v.bottom) {
            return v
        }
    }
}
GetCaretPosEx(&left?, &top?, &right?, &bottom?) {
    hwnd := getHwnd()

    Wpf_list := ",powershell_ise.exe,"
    UIA_list := ",WINWORD.EXE,WindowsTerminal.exe,wt.exe,"
    MSAA_list := ",EXCEL.EXE,DingTalk.exe,"
    Gui_UIA_list := ",ONENOTE.EXE,POWERPNT.EXE,"

    if (InStr(Wpf_list, "," exe_name ",")) {
        if (getCaretPosFromWpfCaret()) {
            return 1
        }
    } else if (InStr(UIA_list, "," exe_name ",")) {
        if (getCaretPosFromUIA()) {
            return 1
        }
    }
    else if (InStr(MSAA_list, "," exe_name ",")) {
        if (getCaretPosFromMSAA()) {
            return 1
        }
    } else if (InStr(Gui_UIA_list, "," exe_name ",")) {
        if (getCaretPosFromGui(&hwnd := 0)) {
            return 1
        }
        if (getCaretPosFromUIA()) {
            return 1
        }
    }
    else {
        if (getCaretPosFromHook()) {
            return 1
        }
    }
    return 0

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
