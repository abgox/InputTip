#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip v2
;@AHK2Exe-SetVersion 2.21.9
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具
;@Ahk2Exe-SetCopyright Copyright (c) 2024-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource InputTipCursor.zip
;@Ahk2Exe-AddResource InputTipSymbol.zip
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

currentVersion := "2.21.9"

if (!FileExist("InputTip.lnk")) {
    FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", "InputTip.lnk", , "/run /tn `"abgox.InputTip.noUAC`"", , A_ScriptFullPath, , , 7)
}
RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "' A_ScriptFullPath '";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Highest;$task = New-ScheduledTask -Action $action -Principal $principal;Register-ScheduledTask -TaskName "abgox.InputTip.noUAC" -InputObject $task -Force', , "Hide")

if (!FileExist("InputTip.ini")) {
    confirmGui := Gui("AlwaysOnTop OwnDialogs")
    confirmGui.SetFont("s12", "微软雅黑")
    confirmGui.AddText(, "InputTip.exe 会根据不同的输入法状态(中英文/大写锁定)修改鼠标样式`n(更多信息，请点击托盘菜单中的 `"关于`"，前往官网或项目中查看)")
    confirmGui.Show("Hide")
    confirmGui.GetPos(, , &Gui_width)
    confirmGui.Destroy()

    confirmGui := Gui("AlwaysOnTop OwnDialogs")
    confirmGui.SetFont("s12", "微软雅黑")
    confirmGui.AddText(, "InputTip.exe 会根据不同的输入法状态(中英文/大写锁定)修改鼠标样式`n(更多信息，请点击托盘菜单中的 `"关于`"，前往官网或项目中查看)")
    confirmGui.AddText(, "您是否希望 InputTip.exe 修改鼠标样式?")
    confirmGui.AddButton("w" Gui_width, "确认修改").OnEvent("Click", yes)
    yes(*) {
        writeIni("changeCursor", 1)
        Run(A_ScriptFullPath)
    }
    confirmGui.AddButton("w" Gui_width, "不要修改").OnEvent("Click", no)
    no(*) {
        writeIni("changeCursor", 0)
        Run(A_ScriptFullPath)
    }
    confirmGui.Show()
}

ignoreUpdate := readIni("ignoreUpdate", 0)
if (!ignoreUpdate) {
    checkVersion(currentVersion, "v2")
}

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
    for v in ["ApplicationFrameHost.exe"] {
        app_hide_state := IniRead("InputTip.ini", "config-v2", "app_hide_state")
        if (!InStr(app_hide_state, v)) {
            writeIni("app_hide_state", app_hide_state (app_hide_state ? "," : "") v)
        }
    }
}

try {
    symbolType := IniRead("InputTip.ini", "config-v2", "symbolType")
} catch {
    showPic := 0, showSymbol := 1, showChar := 0
    try {
        showPic := IniRead("InputTip.ini", "config-v2", "showPic")
    }
    try {
        showSymbol := IniRead("InputTip.ini", "config-v2", "showSymbol")
    }
    try {
        showChar := IniRead("InputTip.ini", "config-v2", "showChar")
    }
    symbolType := 0
    if (showPic) {
        symbolType := 1
    } else if (showSymbol) {
        symbolType := showChar ? 3 : 2
    }
    writeIni("symbolType", symbolType)
}

isStartUp := readIni("isStartUp", 0)
changeCursor := readIni("changeCursor", 0)
symbolType := readIni("symbolType", 2)
HideSymbolDelay := readIni("HideSymbolDelay", 0)
CN_color := StrReplace(readIni("CN_color", "red"), '#', '')
EN_color := StrReplace(readIni("EN_color", "blue"), '#', '')
Caps_color := StrReplace(readIni("Caps_color", "green"), '#', '')
transparent := readIni('transparent', 222)
offset_x := readIni('offset_x', 10)
offset_y := readIni('offset_y', -10)
symbol_width := readIni('symbol_width', 7)
symbol_height := readIni('symbol_height', 7)
pic_offset_x := readIni('pic_offset_x', 5)
pic_offset_y := readIni('pic_offset_y', -20)
pic_symbol_width := readIni('pic_symbol_width', 9)
pic_symbol_height := readIni('pic_symbol_height', 9)
; 隐藏方块符号
app_hide_state := "," readIni('app_hide_state', 'Taskmgr.exe,explorer.exe,StartMenuExperienceHost.exe') ","
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
picSymbolWidth := pic_symbol_width * A_ScreenDPI / 96
picSymbolHeight := pic_symbol_height * A_ScreenDPI / 96
borderWidth := (symbol_width + border_margin_left + border_margin_right) * A_ScreenDPI / 96
borderHeight := (symbol_height + border_margin_top + border_margin_bottom) * A_ScreenDPI / 96
borderOffsetX := offset_x + border_margin_left * A_ScreenDPI / 96 * A_ScreenDPI / 96
borderOffsetY := offset_y + border_margin_top * A_ScreenDPI / 96 * A_ScreenDPI / 96

; 文本符号相关的配置
font_family := readIni('font_family', '微软雅黑')
font_size := readIni('font_size', 7)
font_weight := readIni('font_weight', 600)
font_color := StrReplace(readIni('font_color', 'ffffff'), '#', '')
CN_Text := readIni('CN_Text', '中')
EN_Text := readIni('EN_Text', '英')
Caps_Text := readIni('Caps_Text', '大')

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
        FileExist("InputTipCursor.zip") ? 0 : FileInstall("InputTipCursor.zip", "InputTipCursor.zip", 1)
        RunWait("powershell -NoProfile -Command Expand-Archive -Path '" A_ScriptDir "\InputTipCursor.zip' -DestinationPath '" A_AppData "\abgox-InputTipCursor-temp'", , "Hide")
        for dir in noList {
            dirCopy(A_AppData "\abgox-InputTipCursor-temp\InputTipCursor\" dir, "InputTipCursor\" dir)
        }
        DirDelete(A_AppData "\abgox-InputTipCursor-temp", 1)
        FileDelete("InputTipCursor.zip")
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
showPicList := ","
fileList := ["CN", "EN", "Caps"]
if (!DirExist("InputTipSymbol")) {
    FileExist("InputTipSymbol.zip") ? 0 : FileInstall("InputTipSymbol.zip", "InputTipSymbol.zip", 1)
    RunWait("powershell -NoProfile -Command Expand-Archive -Path '" A_ScriptDir "\InputTipSymbol.zip' -DestinationPath '" A_ScriptDir "'", , "Hide")
    FileDelete("InputTipSymbol.zip")
} else {
    noList := []
    for f in fileList {
        if (!FileExist("InputTipSymbol\default\" f ".png")) {
            noList.push(f)
        }
    }
    if (noList.length > 0 || !FileExist("InputTipSymbol\default\offer.png")) {
        FileExist("InputTipSymbol.zip") ? 0 : FileInstall("InputTipSymbol.zip", "InputTipSymbol.zip", 1)
        RunWait("powershell -NoProfile -Command Expand-Archive -Path '" A_ScriptDir "\InputTipSymbol.zip' -DestinationPath '" A_AppData "\abgox-InputTipSymbol-temp'", , "Hide")
        dirCopy(A_AppData "\abgox-InputTipSymbol-temp\InputTipSymbol\default", "InputTipSymbol\default", 1)
        DirDelete(A_AppData "\abgox-InputTipSymbol-temp", 1)
        FileDelete("InputTipSymbol.zip")
    }
}
for f in fileList {
    if (FileExist("InputTipSymbol\" f ".png")) {
        showPicList .= f ","
    }
}

state := 1, old_state := '', old_left := '', old_top := '', left := 0, top := 0
TipGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")

if (symbolType = 1) {
    ; 图片字符
    TipGui.BackColor := "000000"
    WinSetTransColor("000000", TipGui)
    TipGui.Opt("-LastFound")
    TipGuiPic := TipGui.AddPicture("w" picSymbolWidth " h" picSymbolHeight, "InputTipSymbol\default\CN.png")
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
}
borderGui := Gui("-Caption AlwaysOnTop ToolWindow LastFound")
WinSetTransparent(border_transparent)
borderGui.Opt("-LastFound")
borderGui.BackColor := border_color_CN

lastWindow := ""
lastState := state
needHide := 1
exe_name := ""
if (changeCursor) {
    if (symbolType) {
        while 1 {
            is_hide_state := 0
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                if (exe_name != lastWindow) {
                    needHide := 0
                    SetTimer(timer, HideSymbolDelay)
                    timer(*) {
                        global needHide := 1
                    }
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
            }
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                continue
            }
            if (A_TimeIdle < 500) {
                if (is_hide_state) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    try {
                        DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
                    }
                    canShowSymbol := GetCaretPosEx(&left, &top)
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
                    Sleep(50)
                    continue
                }
                try {
                    state := isCN(mode)
                    v := state = 1 ? "CN" : "EN"
                } catch {
                    TipGui.Hide()
                    Sleep(50)
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
                    if (state != 2) {
                        show("Caps")
                        state := 2
                    }
                    old_state := state
                    Sleep(50)
                    continue
                }
                try {
                    state := isCN(mode)
                    v := state = 1 ? "CN" : "EN"
                } catch {
                    Sleep(50)
                    continue
                }
                if (state != old_state) {
                    show(v)
                    old_state := state
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
    if (symbolType) {
        while 1 {
            is_hide_state := 0
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
                if (exe_name != lastWindow) {
                    needHide := 0
                    SetTimer(timer2, HideSymbolDelay)
                    timer2(*) {
                        global needHide := 1
                    }
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
            }
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                continue
            }
            if (A_TimeIdle < 500) {
                if (is_hide_state) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    try {
                        DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
                    }
                    canShowSymbol := GetCaretPosEx(&left, &top)
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
                    Sleep(50)
                    continue
                }
                try {
                    state := isCN(mode)
                    v := state = 1 ? "CN" : "EN"
                } catch {
                    TipGui.Hide()
                    Sleep(50)
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
            Sleep(50)
        }
    }
}

TipShow(type) {
    switch symbolType {
        case 1:
        {
            if (InStr(showPicList, "," type ",")) {
                try {
                    TipGuiPic.Value := "InputTipSymbol/" type ".png"
                    TipGui.Show("NA x" left + pic_offset_x "y" top + pic_offset_y)
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
        case 3:
        {
            if (%type "_Text"%) {
                TipGuiText.Value := %type "_Text"%
                TipGui.Show("NA x" left + offset_x "y" top + offset_y)
            } else {
                TipGui.Hide()
            }
        }
        default: return
    }
}
makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("开机自启动", fn_startup)
    fn_startup(item, *) {
        flag := A_TrayMenu.ToggleCheck(item)
        writeIni("isStartUp", flag)
        if (flag) {
            FileCopy(A_ScriptDir "\InputTip.lnk", A_Startup, 1)
        } else {
            FileDelete(A_Startup "\InputTip.lnk")
        }
    }

    if (isStartUp) {
        A_TrayMenu.Check("开机自启动")
    }
    try {
        HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
        path_exe := RegRead(HKEY_startup, A_ScriptName)
        writeIni("isStartUp", 1)
        FileCopy(A_ScriptDir "\InputTip.lnk", A_Startup, 1)
        A_TrayMenu.Check("开机自启动")
        RegDelete(HKEY_startup, A_ScriptName)
    }
    A_TrayMenu.Add("忽略更新", fn_ignore_update)
    fn_ignore_update(item, *) {
        writeIni("ignoreUpdate", A_TrayMenu.ToggleCheck(item))
    }
    ignoreUpdate ? A_TrayMenu.Check("忽略更新") : 0
    sub := Menu()
    list := ["模式1", "模式2", "模式3", "模式4"]
    for v in list {
        sub.Add(v, fn_mode)
        fn_mode(item, index, *) {
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
            yes(*) {
                msgGui.Destroy()
                writeIni("mode", index, "InputMethod")
                fn_restart()
            }
            msgGui.Show()
        }
    }
    A_TrayMenu.Add("设置输入法", sub)
    sub.Check("模式" mode)
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    fn_config(*) {
        line := "-----------------------------------------------------------------------------------------------"
        size := A_ScreenHeight < 1000 ? "s10" : "s12"
        configGui := Gui("OwnDialogs")
        configGui.SetFont(size, "微软雅黑")
        configGui.AddText(, "输入框中的值是当前生效的值`n-------------------------------------------------------------------------------------------")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("OwnDialogs", "InputTip v2 - 更改配置")
        configGui.SetFont(size, "微软雅黑")
        tab := configGui.AddTab3(, ["显示形式", "鼠标样式", "图片符号", "方块符号", "方块符号边框", "文本符号", "配色网站"])
        tab.UseTab(1)

        configGui.AddText("Section", "在更改配置前，你应该首先阅读一下项目的 README，相当于软件的说明书")
        configGui.AddText("xs", "你可以在以下任意网址中查看软件使用说明:")
        configGui.AddLink("xs", '官网: <a href="https://inputtip.pages.dev/v2/">https://inputtip.pages.dev/v2/</a>')
        configGui.AddLink("xs", 'Github: <a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        configGui.AddLink("xs", 'Gitee: <a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
        configGui.AddText("xs", line)
        configGui.AddText("xs", "要不要修改鼠标样式: ")
        configGui.AddDropDownList("w" Gui_width / 2 " yp AltSubmit vchangeCursor Choose" changeCursor + 1, ["不修改鼠标样式，保持原本的鼠标样式", "要修改鼠标样式，随输入法状态而变化"])
        configGui.addText("xs", "在输入光标附近显示什么类型的符号: ")
        configGui.AddDropDownList("yp AltSubmit vsymbolType Choose" symbolType + 1, ["不显示符号", "显示图片符号", "显示方块符号", "显示文本符号"])
        configGui.AddText("xs", "符号在多少毫秒后隐藏(0 表示不隐藏):")
        configGui.AddEdit("vHideSymbolDelay" " yp w150 Number", HideSymbolDelay)
        configGui.AddText("xs", "(符号隐藏后，当前应用中的任何鼠标操作都不会再显示，直到下一次键盘操作或切换应用)")

        tab.UseTab(2)
        configGui.AddText(, "你可以从以下任意可用地址中获取设置鼠标样式文件夹的相关说明:")
        configGui.AddLink(, '<a href="https://inputtip.pages.dev/v2/#自定义鼠标样式">https://inputtip.pages.dev/v2/#自定义鼠标样式</a>`n<a href="https://github.com/abgox/InputTip#自定义鼠标样式">https://github.com/abgox/InputTip#自定义鼠标样式</a>`n<a href="https://gitee.com/abgox/InputTip#自定义鼠标样式">https://gitee.com/abgox/InputTip#自定义鼠标样式</a>`n' line)
        cursorDirlist := [{
            label: "中文状态鼠标样式",
            folder: "CN",
        }, {
            label: "英文状态鼠标样式",
            folder: "EN",
        }, {
            label: "大写锁定鼠标样式",
            folder: "Caps",
        }]
        for v in cursorDirlist {
            btnGui := configGui.AddButton("w" Gui_width, "设置" v.label)
            btnGui.data := v
            btnGui.OnEvent("Click", fn_btn)
            fn_btn(item, *) {
                if (!changeCursor) {
                    MsgBox("请先在配置中将 是否更改鼠标样式 设置为 1，再进行此操作。", "InputTip.exe - 错误！", "0x10 0x1000")
                    return
                }
                dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为" item.data.label " (不能是 CN/EN/Caps 文件夹)")
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
                    DirDelete(A_ScriptDir "\InputTipCursor\" item.data.folder, 1)
                    DirCopy(dir, A_ScriptDir "\InputTipCursor\" item.data.folder, 1)
                    MsgBox("鼠标样式文件夹修改成功!")
                }
            }
        }
        configGui.AddButton("w" Gui_width, "下载鼠标样式包").OnEvent("Click", fn_package)
        fn_package(*) {
            dlGui := Gui("AlwaysOnTop OwnDialogs", "下载鼠标样式包")
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
        tab.UseTab(3)
        configGui.AddText("Section", "- 图片符号通过加载图片实现，你可以通过替换图片来自定义任何符号，不一定是圆点符号`n    - 你可以用自己喜欢的符号图片、或者自己制作符号图片来替换`n    - 唯一限制: 图片必须是 .png 类型的图片`n- 如果在特定状态下，你不想显示图片符号，把 InputTipSymbol 目录下对应的图片删除即可`n    - 中文状态: CN.png`n    - 英文状态: EN.png`n    - 大写锁定: Caps.png`n- 如果后悔了，从 InputTipSymbol 目录下的 default 目录中把对应的默认图片复制回来即可`n" line)

        symbolPicConfig := [{
            config: "pic_offset_x",
            options: "",
            tip: "图片符号的水平偏移量"
        }, {
            config: "pic_offset_y",
            options: "",
            tip: "图片符号的垂直偏移量"
        }, {
            config: "pic_symbol_width",
            options: "",
            tip: "图片符号的宽度"
        }, {
            config: "pic_symbol_height",
            options: "",
            tip: "图片符号的高度"
        }]
        for v in symbolPicConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%)
        }
        tab.UseTab(4)
        symbolBlockColorConfig := [{
            config: "CN_color",
            options: "",
            tip: "中文状态时方块符号的颜色",
            colors: ["red", "#FF5252", "#F44336", "#D23600", "#FF1D23", "#D40D12", "#C30F0E", "#5C0002", "#450003"]
        }, {
            config: "EN_color",
            options: "",
            tip: "英文状态时方块符号的颜色",
            colors: ["blue", "#ADD5F7", "#0EEAFF", "#59D8E6", "#2962FF", "#1B76FF", "#2C1DFF", "#1C3FFD", "#1510F0"]
        }, {
            config: "Caps_color",
            options: "",
            tip: "大写锁定时方块符号的颜色",
            colors: ["green", "#B1FF91", "#96ED89", "#66BB6A", "#8BC34A", "#45BF55", "#43A047", "#2E7D32", "#33691E"]
        }
        ]
        symbolBlockConfig := [{
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
        }
        ]
        configGui.AddText("Section", "- 对于不同状态时方块符号的颜色设置，可以留空，留空表示不显示对应的方块符号`n" line)
        for v in symbolBlockColorConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddComboBox("v" v.config " yp w150 " v.options, v.colors).Text := readIni(v.config, "")
        }
        for v in symbolBlockConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%)
        }
        tab.UseTab(5)
        configGui.AddText(, "目前可以使用三种样式`n- 样式1: 普通边框`n- 样式2: 带有凹陷边缘的边框`n- 样式3: 与样式2相比，差别不大，更细一点`n建议可以都尝试一下，然后选择自己喜欢的样式，也可以自定义样式边框`n" line)
        list := ["去掉边框样式", "设置为样式1", "设置为样式2", "设置为样式3"]
        for i, v in list {
            btnGui := configGui.AddButton("w" Gui_width, v)
            btnGui.data := i - 1
            btnGui.OnEvent("Click", fn_btn2)
            fn_btn2(item, *) {
                writeIni("border_type", item.data)
                fn_restart()
            }
        }
        configGui.AddButton("w" Gui_width, "自定义样式边框").OnEvent("Click", fn_custom_border)
        fn_custom_border(*) {
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
                customGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%)
            }
            customGui.AddButton("xs w" Gui_width, "确认").OnEvent("Click", yes2)
            yes2(*) {
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
                if (isValid) {
                    writeIni("border_type", 4)
                    for item in configList {
                        writeIni(item.config, customGui.Submit().%item.config%)
                    }
                    fn_restart()
                }
            }
            customGui.Show()
        }
        tab.UseTab(6)
        symbolCharConfig := [{
            config: "font_family",
            options: "",
            tip: "文本字符的字体"
        }, {
            config: "font_size",
            options: "Number",
            tip: "文本字符的大小"
        }, {
            config: "font_weight",
            options: "Number",
            tip: "文本字符的粗细"
        }, {
            config: "font_color",
            options: "",
            tip: "文本字符的颜色"
        }, {
            config: "CN_Text",
            options: "",
            tip: "中文状态时显示的文本字符"
        }, {
            config: "EN_Text",
            options: "",
            tip: "英文状态时显示的文本字符"
        }, {
            config: "Caps_Text",
            options: "",
            tip: "大写锁定时显示的文本字符"
        }
        ]
        configGui.AddText("Section", "- 不同状态下的背景颜色以及偏移量由方块符号配置中的相关配置决定`n- 对于不同状态时显示的文本字符设置，可以留空，留空表示不显示对应的文本字符`n" line)
        for v in symbolCharConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%)
        }
        tab.UseTab(7)
        configGui.AddText(, "- 对于颜色相关的配置，建议使用16进制的颜色值`n- 不过由于没有调色板，可能并不好设置`n- 建议使用以下配色网站(也可以自己去找)，找到喜欢的颜色，复制16进制值`n- 显示的颜色以最终渲染的颜色效果为准")
        configGui.AddLink(, '<a href="https://colorhunt.co">https://colorhunt.co</a>')
        configGui.AddLink(, '<a href="https://materialui.co/colors">https://materialui.co/colors</a>')
        configGui.AddLink(, '<a href="https://color.adobe.com/zh/create/color-wheel">https://color.adobe.com/zh/create/color-wheel</a>')
        configGui.AddLink(, '<a href="https://colordesigner.io/color-palette-builder">https://colordesigner.io/color-palette-builder</a>')
        tab.UseTab(0)
        configGui.AddButton(" w" Gui_width + configGui.MarginX * 2, "确认").OnEvent("Click", yes3)
        yes3(*) {
            isValid := 1

            list := symbolBlockColorConfig.Clone()
            list.Push(symbolCharConfig[4])
            for v in list {
                if (!isColor(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个颜色英文单词或者十六进制颜色值。", "支持的颜色英文单词: red, blue, green, yellow, purple, gray, black, white"])
                    isValid := 0
                }
            }

            transparent := configGui.Submit().transparent
            if (IsFloat(transparent)) {
                showMsg(["配置错误!", symbolBlockConfig[1].tip " 不能是一个小数"])
                isValid := 0
            } else {
                if (transparent < 0 || transparent > 255) {
                    showMsg(["配置错误!", symbolBlockConfig[1].tip " 应该是 0 到 255 之间的整数。"])
                    isValid := 0
                }
            }
            list := [symbolBlockConfig[2], symbolBlockConfig[3]]
            for v in list {
                if (!IsNumber(configGui.Submit().%v.config%)) {
                    showMsg(["配置错误!", v.tip " 应该是一个数字。"])
                    isValid := 0
                }
            }
            list := [symbolBlockConfig[4], symbolBlockConfig[5]]
            for v in list {
                value := configGui.Submit().%v.config%
                if (!IsNumber(value) || value < 0) {
                    showMsg(["配置错误!", v.tip " 应该是一个大于 0 的数字。"])
                    isValid := 0
                }
            }
            if (isValid) {
                if (configGui.Submit().changeCursor = changeCursor) {
                    for v in info {
                        DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
                    }
                    MsgBox("尝试恢复默认鼠标样式。`n如果没有完全恢复，请重启电脑。")
                }
                for item in symbolPicConfig {
                    writeIni(item.config, configGui.Submit().%item.config%)
                }
                for item in symbolBlockColorConfig {
                    writeIni(item.config, configGui.Submit().%item.config%)
                }
                for item in symbolBlockConfig {
                    writeIni(item.config, configGui.Submit().%item.config%)
                }
                for item in symbolCharConfig {
                    writeIni(item.config, configGui.Submit().%item.config%)
                }
                writeIni("HideSymbolDelay", configGui.Submit().HideSymbolDelay)
                writeIni("symbolType", configGui.Submit().symbolType - 1)
                writeIni("changeCursor", configGui.Submit().changeCursor - 1)
                fn_restart()
            }
        }
        configGui.Show()
    }
    sub1 := Menu()
    fn_common(tipList, addFn) {
        hideGui := Gui("AlwaysOnTop +OwnDialogs")
        hideGui.SetFont("s12", "微软雅黑")
        hideGui.AddButton("", tipList[2]).OnEvent("Click", fn_common_1)
        fn_common_1(*) {
            hideGui.Destroy()
            show()
            show() {
                addGui := Gui("AlwaysOnTop OwnDialogs")
                addGui.SetFont("s12", "微软雅黑")
                addGui.AddText(, tipList[5])
                addGui.AddText(, tipList[4])
                addGui.Show("Hide")
                addGui.GetPos(, , &Gui_width)
                addGui.Destroy()

                addGui := Gui("AlwaysOnTop OwnDialogs")
                addGui.SetFont("s12", "微软雅黑")
                addGui.AddText(, tipList[5])
                addGui.AddText(, tipList[4])

                LV := addGui.AddListView("r8 NoSortHdr Sort Grid w" Gui_width, ["应用", "标题"])
                LV.OnEvent("DoubleClick", fn_double_click)
                fn_double_click(LV, RowNumber) {
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
                    confirmGui.Show()
                }
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
                addGui.AddButton("xs w" Gui_width, "没有找到需要添加的进程，你可以点击此按钮手动添加进程").OnEvent("Click", fn_add_by_hand)
                fn_add_by_hand(*) {
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
                    g.AddButton("xs w" Gui_width, "确认添加").OnEvent("Click", yes2)
                    yes2(*) {
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
                    }
                    g.Show()
                }
                LV.ModifyCol(1, "Auto")
                addGui.OnEvent("Close", fn_restart)
                addGui.Show()
            }
        }
        hideGui.AddButton("xs", tipList[3]).OnEvent("Click", fn_common_2)
        fn_common_2(*) {
            hideGui.Destroy()
            show()
            show() {
                value := readIni(tipList[1], "")
                valueArr := StrSplit(value, ",")

                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                rmGui.AddText(, tipList[9])
                rmGui.AddText(, tipList[8])
                rmGui.Show("Hide")
                rmGui.GetPos(, , &Gui_width)
                rmGui.Destroy()

                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                if (valueArr.Length > 0) {
                    rmGui.AddText(, tipList[9])
                    rmGui.AddText(, tipList[8])
                    LV := rmGui.AddListView("r10 NoSortHdr Sort Grid w" Gui_width, ["应用"])
                    LV.OnEvent("DoubleClick", fn_double_click)
                    fn_double_click(LV, RowNumber) {
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
                    temp := ","
                    for v in valueArr {
                        if (Trim(v) && !InStr(temp, "," v ",")) {
                            LV.Add(, v)
                            temp .= v ","
                        }
                    }
                    LV.ModifyCol(1, "Auto")
                    rmGui.OnEvent("Close", fn_restart)
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
                    rmGui.AddButton("w" Gui_width, "确定").OnEvent("Click", fn_restart)
                    rmGui.OnEvent("Close", fn_restart)
                    rmGui.Show()
                }
            }
        }
        hideGui.Show()
    }
    sub1.Add("自动切换中文状态", fn_switch_CN)
    fn_switch_CN(*) {
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
    }
    sub1.Add("自动切换英文状态", fn_switch_EN)
    fn_switch_EN(*) {
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
    }
    sub1.Add("自动切换大写锁定状态", fn_switch_Caps)
    fn_switch_Caps(*) {
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
    }
    A_TrayMenu.Add("设置自动切换", sub1)
    A_TrayMenu.Add("设置强制切换快捷键", fn_switch_key)
    fn_switch_key(*) {
        hotkeyGui := Gui("AlwaysOnTop OwnDialogs")
        hotkeyGui.SetFont("s12", "微软雅黑")
        hotkeyGui.AddText(, "--------------------------------------------------------------------")
        hotkeyGui.Show("Hide")
        hotkeyGui.GetPos(, , &Gui_width)
        hotkeyGui.Destroy()

        hotkeyGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 设置强制切换输入法状态的快捷键")
        hotkeyGui.SetFont("s12", "微软雅黑")

        tab := hotkeyGui.AddTab3(, ["设置快捷键", "手动输入快捷键"])
        tab.UseTab(1)
        hotkeyGui.AddText("Section", "- 当右侧的 Win 复选框勾选后，表示快捷键中加入 Win 修饰键`n- 使用 Backspace(退格键) 或 Delete(删除键) 可以移除不需要的快捷键")
        hotkeyGui.AddText("Center w" Gui_width, "--------------------------------------------------------------------")

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
            hotkeyGui.AddCheckbox("yp v" v.with, "Win 键").Value := InStr(value, "#")
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes)
        yes(*) {
            for v in configList {
                if (hotkeyGui.Submit().%v.with%) {
                    key := "#" hotkeyGui.Submit().%v.config%
                } else {
                    key := hotkeyGui.Submit().%v.config%
                }
                writeIni(v.config, key)
            }
            fn_restart()
        }
        tab.UseTab(2)
        hotkeyGui.AddText("Section", "- 你首先应该点击下方的手动输入快捷键相关帮助")
        for v in configList {
            hotkeyGui.AddText("xs", v.tip ": ")
            hotkeyGui.AddEdit("yp w300 v" v.config "2", readIni(v.config, ''))
        }
        hotkeyGui.AddButton("xs w" Gui_width, "快捷键手动输入的相关帮助").OnEvent("Click", fn_key_help)
        fn_key_help(*) {
            helpGui := Gui("AlwaysOnTop OwnDialogs")
            helpGui.SetFont("s12", "微软雅黑")
            helpGui.AddText(, "--------------------------------------------------------------------------------------------")
            helpGui.Show("Hide")
            helpGui.GetPos(, , &Gui_width)
            helpGui.Destroy()

            helpGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 手动输入快捷键相关帮助")
            helpGui.SetFont("s12", "微软雅黑")
            helpGui.AddText(, "- 你首先要清楚以下符号和按键之间的对应关系`n- ^ 表示 Ctrl， + 表示 Shift， # 表示 Win, ! 表示 Alt`n- 下面有一些常见的快捷键组合对应列表，相信你看了就知道大概需要如何输入你想要的快捷键了`n- 需要注意: 如果你输入的快捷键中有 #，# 必须放在最前面，比如 #^Space")
            key_list := [
                ["LShift", "左侧 Shift (单独使用)，组合其他按键时需要使用 +"],
                ["RShift", "右侧 Shift (单独使用)，组合其他按键时需要使用 +"],
                ["LAlt", "左侧 Alt (单独使用)，组合其他按键时需要使用 !"],
                ["RAlt", "右侧 Alt (单独使用)，组合其他按键时需要使用 !"],
                ["LCtrl", "左侧 Ctrl (单独使用)，组合其他按键时需要使用 ^"],
                ["RCtrl", "右侧 Ctrl (单独使用)，组合其他按键时需要使用 ^"],
                ["^Space", "Ctrl + Space(空格键)"],
                ["<^Space", "左侧的 Ctrl + Space"],
                [">^Space", "右侧的 Ctrl + Space"],
                ["^,", "Ctrl + ,"],
                ["^.", "Ctrl + ."],
                ["!/", "Alt + /"],
                ["!a", "Alt + A"],
                ["#b", "Win + C"],
                ["#^c", "Win + Ctrl + C"],
                ["#+^d", "Win + Shift + Ctrl + D"],
                ["!Up", "Alt + ↑"],
                ["!Down", "Alt + ↓"],
                ["!Left", "Alt + ←"],
                ["!Right", "Alt + →"],
                ["!Home", "Alt + Home"],
                ["!End", "Alt + End"],
                ["!PgUp", "Alt + ↑"],
                ["!PgDn", "Alt + ↓"],
                ["!Tab", "Alt + Tab"],
                ["!Esc", "Alt + Esc"],
                ["!Enter", "Alt + Enter"]
            ]
            LV := helpGui.AddListView("r10 NoSortHdr Grid w" Gui_width, ["你需要输入的值", "实际会生效的快捷键"])
            helpGui.AddLink(, '点击链接，查看完整按键映射列表: <a href="https://wyagd001.github.io/v2/docs/KeyList.htm#general">https://wyagd001.github.io/v2/docs/KeyList.htm#general</a>')
            for k in key_list {
                LV.Add("", k[1], k[2])
            }
            helpGui.Show()
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes)
        yse(*) {
            for v in configList {
                key := hotkeyGui.Submit().%v.config "2"%
                writeIni(v.config, key)
            }
            fn_restart()
        }
        hotkeyGui.Show()
    }
    A_TrayMenu.Add("指定隐藏符号的应用", fn_hide_app)
    fn_hide_app(*) {
        fn_common(
            [
                "app_hide_state",
                "将应用添加到隐藏符号的应用列表中",
                "从隐藏符号的应用列表中移除应用",
                "以下是当前系统正在运行的应用程序列表",
                "双击应用程序，将其添加到隐藏符号的应用列表中`n- 在已添加的应用中，InputTip.exe 不再显示符号`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的修改才生效",
                "是否要将 ",
                " 添加到隐藏符号的应用列表中？`n添加后，在此应用中，InputTip.exe 不再显示符号",
                "以下是隐藏符号的应用列表",
                "双击应用程序，将其从隐藏符号的应用列表中移除`n- 在已移除的应用中，InputTip.exe 会显示符号`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的修改才生效",
                "是否要将 ",
                " 移除？`n移除后，在此应用中，InputTip.exe 会显示符号"
            ],
            fn
        )
        fn(*) {
        }
    }
    A_TrayMenu.Add("关于", fn_about)
    fn_about(*) {
        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("", "InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.AddText(, "如果 InputTip 对您有所帮助，`n您也可以出于善意, 向我捐款。`n非常感谢对 InputTip 的支持!`n希望 InputTip 能一直帮助您!")
        aboutGui.AddPicture("yp w" 330 * 150 / A_ScreenDPI " h-1", "InputTipSymbol\default\offer.png")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop OwnDialogs", "InputTip.exe - 关于")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center w" Gui_width, "InputTip v2 - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.AddText(, "当前版本: " currentVersion)
        aboutGui.AddText("xs", "获取更多信息，你应该查看 : ")
        aboutGui.AddLink("xs", '官网: <a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
        aboutGui.AddLink("xs", 'Github: <a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        aboutGui.AddLink("xs", 'Gitee: <a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
        aboutGui.AddText("xs", "---------------------------------------------------------------------")
        aboutGui.AddText(, "如果 InputTip 对您有所帮助，`n您也可以出于善意, 向我捐款。`n非常感谢对 InputTip 的支持!`n希望 InputTip 能一直帮助您!")
        aboutGui.AddPicture("yp w" 330 * 150 / A_ScreenDPI " h-1", "InputTipSymbol\default\offer.png")
        aboutGui.AddButton("xs w" Gui_width, "关闭").OnEvent("Click", fn_close)
        fn_close(*) {
            aboutGui.Destroy()
        }
        aboutGui.Show()
    }
    A_TrayMenu.Add("重启", fn_restart)
    fn_restart(*) {
        Run(A_ScriptFullPath)
    }
    A_TrayMenu.Add("退出", fn_exit)
    fn_exit(*) {
        ExitApp()
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
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/GetCaretPosEx/GetCaretPosEx.ahk
 */
GetCaretPosEx(&left?, &top?, &right?, &bottom?) {
    hwnd := getHwnd()
    disable_lsit := ",wetype_update.exe,AnLink.exe,Notepad--.exe,wps.exe,"
    Wpf_list := ",powershell_ise.exe,"
    UIA_list := ",WINWORD.EXE,WindowsTerminal.exe,wt.exe,OneCommander.exe,YoudaoDict.exe,"
    MSAA_list := ",EXCEL.EXE,DingTalk.exe,Notepad.exe,Notepad3.exe,QQ.exe,firefox.exe,Quicker.exe,skylark.exe,aegisub32.exe,aegisub64.exe,aegisub.exe,PandaOCR.exe,PandaOCR.Pro.exe,"
    Gui_UIA_list := ",POWERPNT.EXE,Notepad++.exe,"
    Hook_list_avoid_err := ",ONENOTE.EXE,dbeaver.exe,mspaint.exe,Obsidian.exe,Acrobat.exe,"

    if (InStr(disable_lsit, "," exe_name ",")) {
        return 0
    } else if (InStr(Wpf_list, "," exe_name ",")) {
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
    else if (InStr(Hook_list_avoid_err, "," exe_name ",")) {
        if (getCaretPosFromHook(0)) {
            return 1
        }
    }
    else {
        if (getCaretPosFromHook(1)) {
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

    getCaretPosFromHook(flag) {
        static WM_GET_CARET_POS := DllCall("RegisterWindowMessageW", "str", "WM_GET_CARET_POS", "uint")
        if !tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr*", &pid := 0, "uint")
            return false
        if (flag) {
            ; ! 部分应用会因为它触发意外错误
            ; ! 如: 崩溃，自动输入/删除等
            ; Update caret position
            try {
                SendMessage(0x010f, 0, 0, hwnd) ; WM_IME_COMPOSITION
            }
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
