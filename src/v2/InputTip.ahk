#Requires AutoHotkey v2.0
;@AHK2Exe-SetName InputTip
;@AHK2Exe-SetVersion 2.24.1
;@AHK2Exe-SetLanguage 0x0804
;@Ahk2Exe-SetMainIcon ..\favicon.ico
;@AHK2Exe-SetDescription InputTip - 一个输入法状态(中文/英文/大写锁定)提示工具
;@Ahk2Exe-SetCopyright Copyright (c) 2023-present abgox
;@Ahk2Exe-UpdateManifest 1
;@Ahk2Exe-AddResource InputTipCursor.zip
;@Ahk2Exe-AddResource InputTipSymbol.zip
;@Ahk2Exe-AddResource InputTip.JAB.JetBrains.exe
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

currentVersion := "2.24.1"

if (!FileExist("InputTip.lnk")) {
    FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", "InputTip.lnk", , "/run /tn `"abgox.InputTip.noUAC`"", , A_ScriptFullPath, , , 7)
}

try {
    Run('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptFullPath '\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Highest;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.noUAC" -InputObject $task -Force', , "Hide")
}

isContinue := 0

if (FileExist("InputTip.ini")) {
    c := IniRead("InputTip.ini", "config-v2")
    if (InStr(c, "isStartUp") && !InStr(c, "JetBrains_list")) {
        writeIni("JetBrains_list", "WebStorm64.exe:DataGrip64.exe:PhpStorm64.exe:PyCharm64.exe:Rider64.exe:CLion64.exe:RubyMine64.exe:GoLand64.exe:Idea64.exe:DataSpell64.exe")
    }
} else {
    confirmGui := Gui("AlwaysOnTop OwnDialogs")
    confirmGui.SetFont("s12", "微软雅黑")
    confirmGui.AddText(, "InputTip.exe 会根据不同的输入法状态(中英文/大写锁定)修改鼠标样式`n(更多信息，请点击托盘菜单中的 「关于」，前往官网或项目中查看)")
    confirmGui.Show("Hide")
    confirmGui.GetPos(, , &Gui_width)
    confirmGui.Destroy()

    confirmGui := Gui("AlwaysOnTop OwnDialogs")
    confirmGui.SetFont("s12", "微软雅黑")
    confirmGui.AddText(, "InputTip.exe 会根据不同的输入法状态(中英文/大写锁定)修改鼠标样式`n(更多信息，请点击托盘菜单中的 「关于」，前往官网或项目中查看)")
    confirmGui.AddText(, "您是否希望 InputTip.exe 修改鼠标样式?")
    confirmGui.AddButton("w" Gui_width, "确认修改").OnEvent("Click", yes)
    yes(*) {
        writeIni("changeCursor", 1)
        isContinue := 1
        Run(A_ScriptFullPath)
    }
    confirmGui.AddButton("w" Gui_width, "不要修改").OnEvent("Click", no)
    no(*) {
        writeIni("changeCursor", 0)
        isContinue := 1
        Run(A_ScriptFullPath)
    }
    confirmGui.OnEvent("Close", fn_exit)
    fn_exit(*) {
        ExitApp()
    }
    confirmGui.Show()
    while (!isContinue) {
        Sleep(500)
    }
}

ignoreUpdate := readIni("ignoreUpdate", 0)
if (!ignoreUpdate) {
    checkVersion(currentVersion, "v2")
}

mode := readIni("mode", 2, "InputMethod")
isStartUp := readIni("isStartUp", 0)
enableJetBrainsSupport := readIni("enableJetBrainsSupport", 0)
JetBrains_list := ":" readIni("JetBrains_list", "") ":"
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
app_hide_state := readIni('app_hide_state', '')
if (InStr(app_hide_state, "exe,")) {
    app_hide_state := StrReplace(app_hide_state, ",", ":")
    writeIni('app_hide_state', app_hide_state)
}
app_hide_state := ":" app_hide_state ":"

app_CN := readIni('app_CN', '')
if (InStr(app_CN, "exe,")) {
    app_CN := StrReplace(app_CN, ",", ":")
    writeIni('app_CN', app_CN)
}
app_CN := ":" app_CN ":"

app_EN := readIni('app_EN', '')
if (InStr(app_EN, "exe,")) {
    app_EN := StrReplace(app_EN, ",", ":")
    writeIni('app_EN', app_EN)
}
app_EN := ":" app_EN ":"

app_Caps := readIni('app_Caps', '')
if (InStr(app_Caps, "exe,")) {
    app_Caps := StrReplace(app_Caps, ",", ":")
    writeIni('app_Caps', app_Caps)
}
app_Caps := ":" app_Caps ":"

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

waitFileInstall(path, isExit := 1) {
    t := 0
    while (!FileExist(path)) {
        if (t > 30) {
            MsgBox("软件相关文件释放失败!", , "0x10")
            if (isExit) {
                ExitApp()
            } else {
                break
            }
        }
        t++
        Sleep(1000)
    }
}

cursor_temp_zip := A_Temp "\abgox-InputTipCursor-temp.zip"
cursor_temp_dir := A_Temp "\abgox-InputTipCursor-temp"
if (!DirExist("InputTipCursor")) {
    FileInstall("InputTipCursor.zip", cursor_temp_zip, 1)
    waitFileInstall(cursor_temp_zip)
    RunWait("powershell -NoProfile -Command Expand-Archive -Path '" cursor_temp_zip "' -DestinationPath '" A_ScriptDir "'", , "Hide")
    try {
        FileDelete(cursor_temp_zip)
    }
} else {
    noList := [], dirList := ["CN", "EN", "Caps", "default"]
    for dir in dirList {
        if (!DirExist("InputTipCursor\" dir)) {
            noList.push(dir)
        }
    }
    if (noList.length > 0) {
        FileInstall("InputTipCursor.zip", cursor_temp_zip, 1)
        waitFileInstall(cursor_temp_zip)
        RunWait("powershell -NoProfile -Command Expand-Archive -Path '" cursor_temp_zip "' -DestinationPath '" cursor_temp_dir "'", , "Hide")
        for dir in noList {
            dirCopy(cursor_temp_dir "\InputTipCursor\" dir, "InputTipCursor\" dir)
        }
        try {
            DirDelete(cursor_temp_dir, 1)
        }
        try {
            FileDelete(cursor_temp_zip)
        }
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
showPicList := ":"
fileList := ["CN", "EN", "Caps"]

symbol_temp_zip := A_Temp "\abgox-InputTipSymbol-temp.zip"
symbol_temp_dir := A_Temp "\abgox-InputTipSymbol-temp"
if (!DirExist("InputTipSymbol")) {
    FileInstall("InputTipSymbol.zip", symbol_temp_zip, 1)
    waitFileInstall(symbol_temp_zip)
    RunWait("powershell -NoProfile -Command Expand-Archive -Path '" symbol_temp_zip "' -DestinationPath '" A_ScriptDir "'", , "Hide")
    try {
        FileDelete(symbol_temp_zip)
    }
} else {
    noList := []
    for f in fileList {
        if (!FileExist("InputTipSymbol\default\" f ".png")) {
            noList.push(f)
        }
    }
    if (noList.length > 0 || !FileExist("InputTipSymbol\default\offer.png")) {
        FileInstall("InputTipSymbol.zip", symbol_temp_zip, 1)
        waitFileInstall(symbol_temp_zip)
        RunWait("powershell -NoProfile -Command Expand-Archive -Path '" symbol_temp_zip "' -DestinationPath '" symbol_temp_dir "'", , "Hide")
        dirCopy(symbol_temp_dir "\InputTipSymbol\default", "InputTipSymbol\default", 1)
        try {
            DirDelete(symbol_temp_dir, 1)
        }
        try {
            FileDelete(symbol_temp_zip)
        }
    }
}
for f in fileList {
    if (FileExist("InputTipSymbol\" f ".png")) {
        showPicList .= f ":"
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

if (changeCursor) {
    if (symbolType) {
        while 1 {
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
            }
            if (InStr(JetBrains_list, ":" exe_name ":")) {
                TipGui.Hide()
                Sleep(50)
                continue
            }
            is_hide_state := 0
            if (exe_name != lastWindow) {
                needHide := 0
                SetTimer(timer, HideSymbolDelay)
                timer(*) {
                    global needHide := 1
                }
                WinWaitActive("ahk_exe" exe_name)
                lastWindow := exe_name
                if (InStr(app_CN, ":" exe_name ":")) {
                    switch_CN()
                } else if (InStr(app_EN, ":" exe_name ":")) {
                    switch_EN()
                } else if (InStr(app_Caps, ":" exe_name ":")) {
                    switch_Caps()
                }
            }
            is_hide_state := InStr(app_hide_state, ":" exe_name ":")
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                continue
            }
            if (A_TimeIdle < 500) {
                if (is_hide_state) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    canShowSymbol := GetCaretPosEx(&left, &top)
                    canShowSymbol := canShowSymbol && left
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
            }
            if (InStr(JetBrains_list, ":" exe_name ":")) {
                Sleep(50)
                continue
            }
            if (exe_name != lastWindow) {
                WinWaitActive("ahk_exe" exe_name)
                lastWindow := exe_name
                if (InStr(app_CN, ":" exe_name ":")) {
                    switch_CN()
                } else if (InStr(app_EN, ":" exe_name ":")) {
                    switch_EN()
                } else if (InStr(app_Caps, ":" exe_name ":")) {
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
            try {
                exe_name := ProcessGetName(WinGetPID("A"))
            }
            if (InStr(JetBrains_list, ":" exe_name ":")) {
                TipGui.Hide()
                Sleep(50)
                continue
            }
            is_hide_state := 0
            if (exe_name != lastWindow) {
                needHide := 0
                SetTimer(timer2, HideSymbolDelay)
                timer2(*) {
                    global needHide := 1
                }
                WinWaitActive("ahk_exe" exe_name)
                lastWindow := exe_name
                if (InStr(app_CN, ":" exe_name ":")) {
                    switch_CN()
                } else if (InStr(app_EN, ":" exe_name ":")) {
                    switch_EN()
                } else if (InStr(app_Caps, ":" exe_name ":")) {
                    switch_Caps()
                }
            }
            is_hide_state := InStr(app_hide_state, ":" exe_name ":")
            if (needHide && HideSymbolDelay && A_TimeIdleKeyboard > HideSymbolDelay) {
                TipGui.Hide()
                continue
            }
            if (A_TimeIdle < 500) {
                if (is_hide_state) {
                    canShowSymbol := 0
                    TipGui.Hide()
                } else {
                    canShowSymbol := GetCaretPosEx(&left, &top)
                    if !canShowSymbol{
                        TipGui.Hide()
                    }
                    canShowSymbol := canShowSymbol && left
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
            if (InStr(showPicList, ":" type ":")) {
                try {
                    TipGuiPic.Value := "InputTipSymbol/" type ".png"
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
makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("忽略更新", fn_ignore_update)
    fn_ignore_update(item, *) {
        global ignoreUpdate := !ignoreUpdate
        writeIni("ignoreUpdate", ignoreUpdate)
        A_TrayMenu.ToggleCheck(item)
    }
    ignoreUpdate ? A_TrayMenu.Check("忽略更新") : 0
    A_TrayMenu.Add("开机自启动", fn_startup)
    fn_startup(item, *) {
        global isStartUp := !isStartUp
        if (isStartUp) {
            FileCopy(A_ScriptDir "\InputTip.lnk", A_Startup, 1)
        } else {
            try {
                FileDelete(A_Startup "\InputTip.lnk")
            }
        }
        writeIni("isStartUp", isStartUp)
        A_TrayMenu.ToggleCheck(item)
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
    sub := Menu()
    list := ["模式1", "模式2", "模式3", "模式4"]
    for v in list {
        sub.Add(v, fn_mode)
        fn_mode(item, index, *) {
            mode := readIni("mode", 1, "InputMethod")
            msgGui := Gui("AlwaysOnTop +OwnDialogs")
            msgGui.SetFont("s10", "微软雅黑")
            msgGui.AddText(, "------------------------------------------------------------------------------------------------------------")
            msgGui.Show("Hide")
            msgGui.GetPos(, , &Gui_width)
            msgGui.Destroy()

            modeInfo := [
                "-「模式1」和「模式2」都是通用的输入法模式`n- 和「模式2」相比，「模式1」兼容的输入法和应用窗口少一点，但识别输入法状态更稳定一点",
                "-「模式1」和「模式2」都是通用的输入法模式`n- 和「模式1」相比，「模式2」兼容的输入法和应用窗口更多，但有极小概率出现状态识别错误`n- 如果在某个应用窗口中出现识别错误，请尝试重启这个应用窗口",
                "-「模式3」: 主要用于讯飞输入法`n- 如果你使用的输入法其他模式都无法识别，你才应该尝试「模式3」",
                "-「模式4」: 主要用于手心输入法`n- 如果你使用的输入法其他模式都无法识别，你才应该尝试「模式4」"
            ]

            msgGui := Gui("AlwaysOnTop +OwnDialogs", A_ScriptName " - 模式切换")
            msgGui.SetFont("s12", "微软雅黑")
            if (mode != index) {
                msgGui.AddText("", "是否要从 「模式" mode "」 切换到 「模式" index "」?`n--------------------------------------------------------------------------------------------------")
                msgGui.AddText(, modeInfo[index])
            } else {
                msgGui.AddText(, "当前正在使用 「模式" index "」`n--------------------------------------------------------------------------------------------------")
                msgGui.AddText(, modeInfo[index])
            }
            msgGui.AddText(, "模式相关信息请查看以下任意地址:")
            msgGui.AddLink("xs", '官网: <a href="https://inputtip.pages.dev/v2/#兼容情况">https://inputtip.pages.dev/v2/#兼容情况</a>`nGithub: <a href="https://github.com/abgox/InputTip#兼容情况">https://github.com/abgox/InputTip#兼容情况</a>`nGitee: <a href="https://gitee.com/abgox/InputTip#兼容情况">https://gitee.com/abgox/InputTip#兼容情况</a>')
            msgGui.AddButton("xs w" Gui_width + msgGui.MarginX * 2, "确认").OnEvent("Click", yes)
            yes(*) {
                msgGui.Destroy()
                writeIni("mode", index, "InputMethod")
                fn_restart()
            }
            msgGui.Show()
        }
    }
    A_TrayMenu.Add("设置输入法模式", sub)
    sub.Check("模式" mode)
    A_TrayMenu.Add("符号显示黑名单", fn_hide_app)
    fn_hide_app(*) {
        fn_common({
            config: "app_hide_state",
            text: "什么是「符号显示黑名单」？`n- 如果应用在「符号显示黑名单」中，当处于此应用窗口中时，InputTip 不会显示符号`n  - 符号: 图片符号、方块符号、文本符号`n- 如果部分应用出现了一些奇怪的bug，你可以临时将此应用添加到「符号显示黑名单」中",
            btn1: "添加应用到「符号显示黑名单」中",
            btn1_text1: "双击应用程序，将其添加到「符号显示黑名单」中`n- 添加后，当处于此应用窗口中时，InputTip 不再显示符号`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的修改才生效",
            btn1_text2: "以下是当前系统正在运行的应用程序列表",
            btn1_text3: "是否要将 ",
            btn1_text4: " 添加到「符号显示黑名单」中？`n添加后，当处于此应用窗口中时，InputTip 不再显示符号",
            btn2: "从「符号显示黑名单」中移除应用",
            btn2_text1: "双击应用程序，将其从「符号显示黑名单」中移除`n- 移除后，当处于此应用窗口中时，InputTip 会显示符号`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的修改才生效",
            btn2_text2: "以下是「符号显示黑名单」",
            btn2_text3: "是否要将 ",
            btn2_text4: " 移除？`n移除后，当处于此应用窗口中时，InputTip 会显示符号",
        },
        fn
        )
        fn(*) {
        }
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("暂停软件运行", fn_pause)
    fn_pause(item, *) {
        A_TrayMenu.ToggleCheck(item)
        Pause(-1)
    }
    A_TrayMenu.Add("打开软件所在目录", fn_open_dir)
    fn_open_dir(*) {
        Run("explorer.exe /select," A_ScriptFullPath)
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    fn_config(*) {
        line := "-----------------------------------------------------------------------------------------------"
        size := A_ScreenHeight < 1000 ? "s10" : "s12"
        configGui := Gui("OwnDialogs")
        configGui.SetFont(size, "微软雅黑")
        configGui.AddText(, "-------------------------------------------------------------------------------------------")
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("OwnDialogs", "InputTip - 更改配置")
        configGui.SetFont(size, "微软雅黑")
        tab := configGui.AddTab3(, ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号", "配色网站"])
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
        }]
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
        }]
        configGui.AddText("Section", "- 对于不同状态时方块符号的颜色设置，可以留空，留空表示不显示对应的方块符号`n" line)
        for v in symbolBlockColorConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddComboBox("v" v.config " yp w150 " v.options, v.colors).Text := readIni(v.config, "")
        }
        for v in symbolBlockConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%)
        }
        symbolStyle := ["无", "样式1", "样式2", "样式3", "自定义"]
        configGui.AddText("xs", "边框样式: ")
        configGui.AddDropDownList("AltSubmit vborder_type" " yp w150 ", symbolStyle).Value := readIni("border_type", "") + 1
        configGui.AddButton("yp", "自定义样式边框").OnEvent("Click", fn_custom_border)
        fn_custom_border(*) {
            configGui.Destroy()
            customGui := Gui("AlwaysOnTop OwnDialogs")
            customGui.SetFont("s12", "微软雅黑")
            customGui.AddText("", "注意: 如果使用了文本字符，自定义边框样式不会生效`n-----------------------------------------------------------------------------------")
            customGui.Show("Hide")
            customGui.GetPos(, , &Gui_width)
            customGui.Destroy()

            customGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 自定义方块符号样式边框")
            customGui.SetFont("s12", "微软雅黑")
            customGui.AddText("", "注意: 如果使用了文本字符，自定义边框样式不会生效`n-----------------------------------------------------------------------------------")
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
            for v in configList {
                customGui.AddText("xs", v.tip ": ")
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
        tab.UseTab(5)
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
        }]
        configGui.AddText("Section", "- 不同状态下的背景颜色以及偏移量由方块符号配置中的相关配置决定`n- 对于不同状态时显示的文本字符设置，可以留空，留空表示不显示对应的文本字符`n" line)
        for v in symbolCharConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%)
        }
        tab.UseTab(6)
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
                writeIni("border_type", configGui.Submit().border_type - 1)
                fn_restart()
            }
        }
        configGui.Show()
    }
    A_TrayMenu.Add("设置快捷键", fn_switch_key)
    fn_switch_key(*) {
        hotkeyGui := Gui("AlwaysOnTop OwnDialogs")
        hotkeyGui.SetFont("s12", "微软雅黑")
        hotkeyGui.AddText(, "- 目前直接设置单键，如 LShfit,会直接导致原按键功能失效，请设置组合快捷键")
        hotkeyGui.Show("Hide")
        hotkeyGui.GetPos(, , &Gui_width)
        hotkeyGui.Destroy()

        hotkeyGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 设置强制切换输入法状态的快捷键")
        hotkeyGui.SetFont("s12", "微软雅黑")

        tab := hotkeyGui.AddTab3(, ["设置单键", "设置组合快捷键", "手动输入快捷键"])
        tab.UseTab(1)
        hotkeyGui.AddText("Section", "- LShift 指的是左侧的 Shift 键，RShift 指的是右侧的 Shift 键，以此类推`n- 如果要移除快捷键，请选择「无」`n-------------------------------------------------------------------------------------")

        singleHotKeylist := [{
            tip: "强制切换到中文状态",
            config: "single_hotkey_CN",
        }, {
            tip: "强制切换到英文状态",
            config: "single_hotkey_EN",
        }, {
            tip: "强制切换到大写锁定",
            config: "single_hotkey_Caps",
        }]
        for v in singleHotKeylist {
            hotkeyGui.AddText("xs", v.tip ": ")
            DownList := hotkeyGui.AddDropDownList("yp v" v.config, ["无", "LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "Esc"])
            try {
                DownList.Text := Trim(StrReplace(StrReplace(readIni(StrReplace(v.config, "single_", " "), ""), "~", ""), "Up", ""))
                if (!DownList.Value) {
                    DownList.Value := 1
                }
            } catch {
                DownList.Value := 1
            }
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", confirm)
        confirm(*) {
            for v in singleHotKeylist {
                value := hotkeyGui.Submit().%v.config%
                if (value = "无") {
                    key := ""
                } else {
                    key := "~" value " Up"
                }
                writeIni(StrReplace(v.config, "single_", " "), key)
            }
            fn_restart()
        }
        tab.UseTab(2)
        hotkeyGui.AddText("Section", "- 当右侧的 Win 复选框勾选后，表示快捷键中加入 Win 修饰键`n- 使用 Backspace(退格键) 或 Delete(删除键) 可以移除不需要的快捷键`n-------------------------------------------------------------------------------------")

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
        tab.UseTab(3)
        hotkeyGui.AddText("Section", "- 你首先应该点击下方的 「快捷键手动输入的相关帮助」按钮")
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
                ; ["LShift", "左侧 Shift (单独使用)，组合其他按键时需要使用 +"],
                ; ["RShift", "右侧 Shift (单独使用)，组合其他按键时需要使用 +"],
                ; ["LAlt", "左侧 Alt (单独使用)，组合其他按键时需要使用 !"],
                ; ["RAlt", "右侧 Alt (单独使用)，组合其他按键时需要使用 !"],
                ; ["LCtrl", "左侧 Ctrl (单独使用)，组合其他按键时需要使用 ^"],
                ; ["RCtrl", "右侧 Ctrl (单独使用)，组合其他按键时需要使用 ^"],
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
                ["!Enter", "Alt + Enter"]]
            LV := helpGui.AddListView("r10 NoSortHdr Grid w" Gui_width, ["你需要输入的值", "实际会生效的快捷键"])
            helpGui.AddLink(, '点击链接，查看完整按键映射列表: <a href="https://wyagd001.github.io/v2/docs/KeyList.htm#general">https://wyagd001.github.io/v2/docs/KeyList.htm#general</a>')
            for k in key_list {
                LV.Add("", k[1], k[2])
            }
            helpGui.Show()
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes2)
        yes2(*) {
            for v in configList {
                key := hotkeyGui.Submit().%v.config "2"%
                writeIni(v.config, key)
            }
            fn_restart()
        }
        hotkeyGui.Show()
    }
    sub1 := Menu()
    need_restart := 0
    fn_common(tipList, addFn) {
        hideGui := Gui("AlwaysOnTop +OwnDialogs")
        hideGui.SetFont("s12", "微软雅黑")
        hideGui.AddText("", tipList.text)
        hideGui.Show("Hide")
        hideGui.GetPos(, , &Gui_width)
        hideGui.Destroy()

        hideGui := Gui("AlwaysOnTop +OwnDialogs")
        hideGui.SetFont("s12", "微软雅黑")
        hideGui.SetFont("s12", "微软雅黑")
        hideGui.AddText("", tipList.text)
        hideGui.AddButton("w" Gui_width, tipList.btn1).OnEvent("Click", fn_common_1)
        fn_common_1(*) {
            hideGui.Destroy()
            show()
            show() {
                addGui := Gui("AlwaysOnTop OwnDialogs")
                addGui.SetFont("s12", "微软雅黑")
                addGui.AddText(, tipList.btn1_text1)
                addGui.AddText(, tipList.btn1_text2)
                addGui.Show("Hide")
                addGui.GetPos(, , &Gui_width)
                addGui.Destroy()

                addGui := Gui("AlwaysOnTop OwnDialogs")
                addGui.SetFont("s12", "微软雅黑")
                addGui.AddText(, tipList.btn1_text1)
                addGui.AddText(, tipList.btn1_text2)

                LV := addGui.AddListView("r8 NoSortHdr Sort Grid w" Gui_width, ["应用程序", "窗口标题"])
                LV.OnEvent("DoubleClick", fn_double_click)
                fn_double_click(LV, RowNumber) {
                    addGui.Hide()
                    RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                    confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                    confirmGui.SetFont("s12", "微软雅黑")
                    confirmGui.AddText(, tipList.btn1_text3 RowText tipList.btn1_text4)
                    confirmGui.Show("Hide")
                    confirmGui.GetPos(, , &Gui_width)
                    confirmGui.Destroy()

                    confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                    confirmGui.SetFont("s12", "微软雅黑")
                    confirmGui.AddText(, tipList.btn1_text3 RowText tipList.btn1_text4)
                    confirmGui.AddButton("xs w" Gui_width, "确认添加").OnEvent("Click", yes)
                    yes(*) {
                        addGui.Destroy()
                        confirmGui.Destroy()
                        value := readIni(tipList.config, "")
                        valueArr := StrSplit(value, ":")
                        result := ""
                        is_exist := 0
                        for v in valueArr {
                            if (v = RowText) {
                                is_exist := 1
                            }
                            if (Trim(v)) {
                                result .= v ":"
                            }
                        }
                        if (is_exist) {
                            MsgBox(RowText " 已存在!", , "0x1000")
                        } else {
                            addFn(RowText)
                            writeIni(tipList.config, result RowText)
                            need_restart := 1
                        }
                        show()
                    }
                    confirmGui.Show()
                }
                value := readIni(tipList.config, "")
                value := SubStr(value, -1) = ":" ? value : value ":"
                temp := ""
                DetectHiddenWindows 0
                for v in WinGetList() {
                    try {
                        exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                        title := WinGetTitle("ahk_id " v)
                        if (!InStr(temp, exe_name ":") && !InStr(value, exe_name ":")) {
                            temp .= exe_name ":"
                            LV.Add(, exe_name, WinGetTitle("ahk_id " v))
                        }
                    }
                }
                DetectHiddenWindows 1
                addGui.AddButton("xs w" Gui_width, "没有找到需要添加的进程？你可以点击此按钮手动添加进程").OnEvent("Click", fn_add_by_hand)
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
                        value := readIni(tipList.config, "")
                        valueArr := StrSplit(value, ":")
                        result := ""
                        is_exist := 0
                        for v in valueArr {
                            if (v = exe_name) {
                                is_exist := 1
                            }
                            if (Trim(v)) {
                                result .= v ":"
                            }
                        }
                        if (is_exist) {
                            MsgBox(exe_name " 已存在!", , "0x1000")
                        } else {
                            addFn(exe_name)
                            writeIni(tipList.config, result exe_name)
                            need_restart := 1
                        }
                        g.Destroy()
                    }
                    g.Show()
                }
                LV.ModifyCol(1, "Auto")
                addGui.OnEvent("Close", fn_close)
                addGui.Show()
            }
        }
        hideGui.AddButton("xs w" Gui_width, tipList.btn2).OnEvent("Click", fn_common_2)
        fn_common_2(*) {
            hideGui.Destroy()
            show()
            show() {
                value := readIni(tipList.config, "")
                valueArr := StrSplit(value, ":")

                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                rmGui.AddText(, tipList.btn2_text1)
                rmGui.AddText(, tipList.btn2_text2)
                rmGui.Show("Hide")
                rmGui.GetPos(, , &Gui_width)
                rmGui.Destroy()

                rmGui := Gui("AlwaysOnTop OwnDialogs")
                rmGui.SetFont("s12", "微软雅黑")
                if (valueArr.Length > 0) {
                    rmGui.AddText(, tipList.btn2_text1)
                    rmGui.AddText(, tipList.btn2_text2)
                    LV := rmGui.AddListView("r10 NoSortHdr Sort Grid w" Gui_width, ["应用程序"])
                    LV.OnEvent("DoubleClick", fn_double_click)
                    fn_double_click(LV, RowNumber) {
                        rmGui.Hide()
                        RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                        confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                        confirmGui.SetFont("s12", "微软雅黑")
                        confirmGui.AddText(, tipList.btn2_text3 RowText tipList.btn2_text4)
                        confirmGui.Show("Hide")
                        confirmGui.GetPos(, , &Gui_width)
                        confirmGui.Destroy()

                        confirmGui := Gui("AlwaysOnTop +OwnDialogs")
                        confirmGui.SetFont("s12", "微软雅黑")
                        confirmGui.AddText(, tipList.btn2_text3 RowText tipList.btn2_text4)
                        confirmGui.AddButton("xs w" Gui_width, "确认移除").OnEvent("Click", yes)
                        confirmGui.Show()
                        yes(*) {
                            rmGui.Destroy()
                            confirmGui.Destroy()
                            value := readIni(tipList.config, "")
                            valueArr := StrSplit(value, ":")
                            is_exist := 0
                            result := ""
                            for v in valueArr {
                                if (v = RowText) {
                                    is_exist := 1
                                } else {
                                    if (Trim(v)) {
                                        result .= ":" v
                                    }
                                }
                            }
                            if (is_exist) {
                                writeIni(tipList.config, SubStr(result, 2))
                                need_restart := 1
                            } else {
                                MsgBox(RowText " 不存在或已经移除!", , "0x1000")
                            }
                            show()
                        }
                    }
                    temp := ":"
                    for v in valueArr {
                        if (Trim(v) && !InStr(temp, ":" v ":")) {
                            LV.Add(, v)
                            temp .= v ":"
                        }
                    }
                    LV.ModifyCol(1, "Auto")
                    rmGui.OnEvent("Close", fn_close)
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
                    rmGui.AddButton("w" Gui_width, "确定").OnEvent("Click", fn_close)
                    rmGui.OnEvent("Close", fn_close)
                    rmGui.Show()
                }
            }
        }
        hideGui.Show()
        fn_close(*) {
            if (need_restart) {
                fn_restart(1)
            }
        }
    }
    sub1.Add("自动切换中文状态", fn_switch_CN)
    fn_switch_CN(*) {
        fn_common({
            config: "app_CN",
            text: "什么是「自动切换中文状态的应用列表」？`n- 如果应用在此列表中，当此应用窗口激活时，InputTip 会尝试自动切换为中文状态",
            btn1: "添加应用到「自动切换中文状态的应用列表」中",
            btn1_text1: "双击应用程序，将其添加到「自动切换中文状态的应用列表」中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的添加才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
            btn1_text2: "以下列表中是当前系统正在运行的应用程序",
            btn1_text3: "是否要将 ",
            btn1_text4: " 添加到「自动切换中文状态的应用列表」中？`n- 添加后，当从其他应用首次切换到此应用中，InputTip 会自动切换到中文状态",
            btn2: "从「自动切换中文状态的应用列表」中移除应用",
            btn2_text1: "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的移除才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
            btn2_text2: "以下列表中是「自动切换中文状态的应用列表」",
            btn2_text3: "是否要将 ",
            btn2_text4: " 移除？`n移除后，当从其他应用首次切换到此应用中，InputTip 不会再自动切换到中文状态",
        }, fn
        )
        fn(RowText) {
            value_EN := ":" readIni("app_EN", "") ":"
            value_Caps := ":" readIni("app_Caps", "") ":"
            if (InStr(value_EN, ":" RowText ":")) {
                valueArr := StrSplit(value_EN, ":")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
            }

            if (InStr(value_Caps, ":" RowText ":")) {
                valueArr := StrSplit(value_Caps, ":")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_Caps", SubStr(result, 2))
            }
        }
    }
    sub1.Add("自动切换英文状态", fn_switch_EN)
    fn_switch_EN(*) {
        fn_common({
            config: "app_EN",
            text: "什么是「自动切换英文状态的应用列表」？`n- 如果应用在此列表中，当此应用窗口激活时，InputTip 会尝试自动切换为英文状态",
            btn1: "添加应用到「自动切换英文状态的应用列表」中",
            btn1_text1: "双击应用程序，将其添加到「自动切换英文状态的应用列表」中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的添加才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
            btn1_text2: "以下列表中是当前系统正在运行的应用程序",
            btn1_text3: "是否要将 ",
            btn1_text4: " 添加到「自动切换英文状态的应用列表」中？`n- 添加后，当从其他应用首次切换到此应用中，InputTip 会自动切换到英文状态",
            btn2: "从「自动切换英文状态的应用列表」中移除应用",
            btn2_text1: "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的移除才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
            btn2_text2: "以下列表中是「自动切换英文状态的应用列表」",
            btn2_text3: "是否要将 ",
            btn2_text4: " 移除？`n移除后，当从其他应用首次切换到此应用中，InputTip 不会再自动切换到英文状态",
        },
        fn
        )
        fn(RowText) {
            value_CN := ":" readIni("app_CN", "") ":"
            value_Caps := ":" readIni("app_Caps", "") ":"
            if (InStr(value_CN, ":" RowText ":")) {
                valueArr := StrSplit(value_CN, ":")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
            }

            if (InStr(value_Caps, ":" RowText ":")) {
                valueArr := StrSplit(value_Caps, ":")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_Caps", SubStr(result, 2))
            }
        }
    }
    sub1.Add("自动切换大写锁定状态", fn_switch_Caps)
    fn_switch_Caps(*) {
        fn_common({
            config: "app_Caps",
            text: "什么是「自动切换大写锁定状态的应用列表」？`n- 如果应用在此列表中，当此应用窗口激活时，InputTip 会尝试自动切换为大写锁定状态",
            btn1: "添加应用到「自动切换大写锁定状态的应用列表」中",
            btn1_text1: "双击应用程序，将其添加到「自动切换大写锁定状态的应用列表」中`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的添加才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
            btn1_text2: "以下列表中是当前系统正在运行的应用程序",
            btn1_text3: "是否要将 ",
            btn1_text4: " 添加到「自动切换大写锁定状态的应用列表」中？`n- 添加后，当从其他应用首次切换到此应用中，InputTip 会自动切换到大写锁定状态",
            btn2: "从「自动切换大写锁定状态的应用列表」中移除应用",
            btn2_text1: "双击应用程序，将其移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的移除才生效`n- 在三个自动切换列表(中/英/大写)中，同时添加了同一个应用，只有最新的生效，其他两个会被移除",
            btn2_text2: "以下列表中是「自动切换大写锁定状态的应用列表」",
            btn2_text3: "是否要将 ",
            btn2_text4: " 移除？`n移除后，当从其他应用首次切换到此应用中，InputTip 不会再自动切换到大写锁定状态",
        },
        fn
        )
        fn(RowText) {
            value_CN := ":" readIni("app_CN", "") ":"
            value_EN := ":" readIni("app_EN", "") ":"
            if (InStr(value_CN, ":" RowText ":")) {
                valueArr := StrSplit(value_CN, ":")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
            }

            if (InStr(value_EN, ":" RowText ":")) {
                valueArr := StrSplit(value_EN, ":")
                result := ""
                for v in valueArr {
                    if (v != RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
            }
        }
    }
    A_TrayMenu.Add("设置自动切换", sub1)
    A_TrayMenu.Add("设置特殊偏移量", fn_offset)
    fn_offset(*) {
        offsetGui := Gui("AlwaysOnTop OwnDialogs")
        offsetGui.SetFont("s12", "微软雅黑")
        offsetGui.AddText("Section", "- 由于 JetBrains 系列 IDE，在副屏上会存在极大的坐标偏差`n- 需要自己手动的通过调整对应屏幕的偏移量，使其正确显示`n- 注意: 你需要先开启 Java Access Bridge，具体操作步骤，请查看以下网址:")
        offsetGui.AddLink(, '<a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
        offsetGui.Show("Hide")
        offsetGui.GetPos(, , &Gui_width)
        offsetGui.Destroy()

        offsetGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 设置特殊偏移量")
        offsetGui.SetFont("s12", "微软雅黑")
        tab := offsetGui.AddTab3("", ["JetBrains IDE"])
        tab.UseTab(1)
        offsetGui.AddText("Section", "- 由于 JetBrains 系列 IDE，在副屏上会存在极大的坐标偏差`n- 需要自己通过手动调整对应屏幕的偏移量，使其正确显示`n- 你可以通过以下链接了解如何在 JetBrains 系列 IDE 中使用 InputTip :")
        offsetGui.AddLink(, '- <a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>`n- <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>`n- <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
        offsetGui.AddButton("w" Gui_width, "设置 JetBrains 系列 IDE 的副屏偏移量").OnEvent("Click", JetBrains_offset)

        JetBrains_offset(*) {
            offsetGui.Destroy()
            JetBrainsGui := Gui("AlwaysOnTop OwnDialogs", "InputTip.exe - 设置 JetBrains 系列 IDE 的副屏偏移量")
            JetBrainsGui.SetFont("s12", "微软雅黑")
            screenList := getScreenInfo()
            JetBrainsGui.AddText(, "你需要通过屏幕坐标信息判断具体是哪一块屏幕`n - 假设你有两块屏幕，主屏幕在左侧，副屏幕在右侧`n - 那么副屏幕的左上角 X 坐标一定大于主屏幕的右下角 X 坐标`n - 以此判断以下屏幕哪一块是右侧的屏幕")
            pages := []
            for v in screenList {
                pages.push("屏幕 " v.num)
            }
            tab := JetBrainsGui.AddTab3("", pages)
            for v in screenList {
                tab.UseTab(v.num)
                if (v.num = v.main) {
                    JetBrainsGui.AddText(, "这是主屏幕(主显示器)")
                } else {
                    JetBrainsGui.AddText(, "这是副屏幕(副显示器)")
                }

                JetBrainsGui.AddText(, "屏幕坐标信息: 左上角(" v.left ", " v.top ")，右下角(" v.right ", " v.bottom ")")

                x := 0, y := 0
                try {
                    x := IniRead("InputTip.ini", "config-v2", "offset_JetBrains_x_" v.num)
                }
                try {
                    y := IniRead("InputTip.ini", "config-v2", "offset_JetBrains_y_" v.num)
                }

                JetBrainsGui.AddText(, "水平方向的偏移量: ")
                JetBrainsGui.AddEdit("voffset_JetBrains_x_" v.num " yp w100", x)
                JetBrainsGui.AddText("yp", "垂直方向的偏移量: ")
                JetBrainsGui.AddEdit("voffset_JetBrains_y_" v.num " yp w100", y)
            }
            tab.UseTab(0)
            JetBrainsGui.AddButton("w" Gui_width, "确定").OnEvent("Click", save)
            save(*) {
                isValid := 1
                for v in screenList {
                    x := JetBrainsGui.Submit().%"offset_JetBrains_x_" v.num%
                    if (!IsNumber(x)) {
                        showMsg(["配置错误!", "它应该是一个数字。"])
                        isValid := 0
                    } else {
                        writeIni("offset_JetBrains_x_" v.num, x)
                    }
                    y := JetBrainsGui.Submit().%"offset_JetBrains_y_" v.num%
                    if (!IsNumber(y)) {
                        showMsg(["配置错误!", "它应该是一个数字。"])
                        isValid := 0
                    } else {
                        writeIni("offset_JetBrains_x_" v.num, y)
                    }
                }
                if (isValid) {
                    fn_restart()
                }
            }
            JetBrainsGui.Show()
        }
        offsetGui.Show()
    }
    A_TrayMenu.Add("启用 JetBrains IDE 支持", fn_JetBrains)
    fn_JetBrains(item, *) {
        global enableJetBrainsSupport := !enableJetBrainsSupport
        writeIni("enableJetBrainsSupport", enableJetBrainsSupport)
        A_TrayMenu.ToggleCheck(item)
        if (enableJetBrainsSupport) {
            FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
            waitFileInstall("InputTip.JAB.JetBrains.exe", 0)

            try {
                RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptDir '\InputTip.JAB.JetBrains.exe\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Limited;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -InputObject $task -Force', , "Hide")
            }

            jGui := Gui("AlwaysOnTop OwnDialogs")
            jGui.SetFont("s12", "微软雅黑")
            jGui.AddText(, "1. 开启 Java Access Bridge`n2. 点击托盘菜单中的 「添加 JetBrains IDE 应用」，确保你使用的 JetBrains IDE 已经被添加`n3. 重启 InputTip")
            jGui.Show("Hide")
            jGui.GetPos(, , &Gui_width)
            jGui.Destroy()

            jGui := Gui("AlwaysOnTop OwnDialogs")
            jGui.SetFont("s12", "微软雅黑")
            jGui.AddText(, "已成功启用 JetBrains IDE 支持，你还需要进行以下步骤:")
            jGui.AddText(, "1. 开启 Java Access Bridge`n2. 点击托盘菜单中的 「添加 JetBrains IDE 应用」，确保你使用的 JetBrains IDE 已经被添加`n3. 重启 InputTip")
            jGui.AddText(, "具体操作步骤，请查看以下任意网址:")
            jGui.AddLink(, '<a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
            jGui.AddLink(, '<a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
            jGui.AddLink(, '<a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
            jGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", confirm)
            confirm(*) {
                fn_contorl_JetBrains(1)
                jGui.Destroy()
            }
            jGui.Show()
        } else {
            RunWait('powershell -NoProfile -Command Stop-Process -Name InputTip.JAB.JetBrains -Force', , "Hide")
            Run('powershell -NoProfile -Command Unregister-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -Confirm:$false', , "Hide")
            try {
                FileDelete("InputTip.JAB.JetBrains.exe")
            }
        }
    }
    A_TrayMenu.Add("添加 JetBrains IDE 应用", fn_add_JetBrains)
    fn_add_JetBrains(*) {
        fn_common({
            config: "JetBrains_list",
            text: "当勾选「启用 JetBrains IDE 支持」后，你需要确保你使用的 JetBrains IDE 已经被添加",
            btn1: "添加 JetBrains 系列 IDE 应用程序",
            btn1_text1: "双击应用程序进程进行添加`n- 你只应该添加 JetBrains 系列 IDE 应用程序进程`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的修改才生效",
            btn1_text2: "以下是当前系统正在运行的应用程序列表",
            btn1_text3: "是否要添加  ",
            btn1_text4: " ？`n注意: 如果此应用程序进程不是 JetBrains 系列 IDE 应用程序，你不应该添加它",
            btn2: "移除 JetBrains 系列 IDE 应用程序",
            btn2_text1: "双击应用程序进程进行移除`n- 此菜单会循环触发，除非点击右上角的 x 退出，退出后所有的修改才生效",
            btn2_text2: "以下是已添加的 JetBrains 系列 IDE 应用程序列表(如果有其他应用，需立即移除)",
            btn2_text3: "是否要将 ",
            btn2_text4: " 移除？",
        },
        fn
        )
        fn(*) {
        }
    }
    if (enableJetBrainsSupport) {
        A_TrayMenu.Check("启用 JetBrains IDE 支持")
        try {
            RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptDir '\InputTip.JAB.JetBrains.exe\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Limited;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -InputObject $task -Force', , "Hide")
        }
        fn_contorl_JetBrains(1)
    }

    A_TrayMenu.Add()
    A_TrayMenu.Add("关于", fn_about)
    fn_about(*) {
        aboutGui := Gui("AlwaysOnTop OwnDialogs")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText(, "InputTip - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.AddText(, "如果 InputTip 对您有所帮助，`n您也可以出于善意, 向我捐款。`n非常感谢对 InputTip 的支持!`n希望 InputTip 能一直帮助您!")
        aboutGui.AddPicture("w365 h-1", "InputTipSymbol\default\offer.png")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop OwnDialogs", "InputTip.exe - 关于")
        aboutGui.SetFont("s12", "微软雅黑")
        aboutGui.AddText("Center w" Gui_width, "InputTip - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.AddText("Center w" Gui_width, "当前使用的版本: v" currentVersion)
        tab := aboutGui.AddTab3("w" Gui_width + aboutGui.MarginX * 2, ["关于项目", "赞赏支持", "参考项目"])
        tab.UseTab(1)
        aboutGui.AddText("Section", '作者: ')
        aboutGui.AddEdit("yp ReadOnly", 'abgox')
        aboutGui.AddText("xs", '作者 QQ: ')
        aboutGui.AddEdit("yp ReadOnly", '1151676611')
        aboutGui.AddText("xs", 'QQ 交流群: ')
        aboutGui.AddEdit("yp ReadOnly", '451860327')
        aboutGui.AddText("xs", "------------------------------------------------------------------")
        aboutGui.AddLink("xs", '官网: <a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
        aboutGui.AddLink("xs", 'Github: <a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        aboutGui.AddLink("xs", 'Gitee: <a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
        tab.UseTab(2)
        aboutGui.AddText("Section", "如果 InputTip 对您有所帮助，您也可以出于善意, 向我捐款。`n非常感谢对 InputTip 的支持！希望 InputTip 能一直帮助您！")
        aboutGui.AddPicture("w365 h-1", "InputTipSymbol\default\offer.png")
        tab.UseTab(3)
        aboutGui.AddText("Section", "参考并借鉴了以下项目 : ")
        aboutGui.AddLink("xs", '<a href="https://github.com/aardio/ImTip">ImTip - aardio</a>')
        aboutGui.AddLink("xs", '<a href="https://github.com/flyinclouds/KBLAutoSwitch">KBLAutoSwitch - flyinclouds</a>')
        aboutGui.AddLink("xs", '<a href="https://github.com/Tebayaki/AutoHotkeyScripts">AutoHotkeyScripts - Tebayaki</a>')
        aboutGui.AddLink("xs", '<a href="https://github.com/yakunins/language-indicator">language-indicator - yakunins</a>')
        aboutGui.AddLink("xs", '<a href="https://github.com/Autumn-one/RedDot">RedDot - Autumn-one(木瓜太香)</a>')
        aboutGui.AddLink("xs", '- 在输入光标处显示色块，通过颜色区分这个思路设计的早期借鉴')
        tab.UseTab(0)
        aboutGui.AddButton("Section w" Gui_width + aboutGui.MarginX * 2, "关闭").OnEvent("Click", fn_close)
        fn_close(*) {
            aboutGui.Destroy()
        }
        aboutGui.Show()
    }
    A_TrayMenu.Add("重启", fn_restart)
    A_TrayMenu.Add("退出", fn_exit)
    fn_exit(*) {
        fn_contorl_JetBrains(0)
        ExitApp()
    }
    isColor(v) {
        v := StrReplace(v, "#", "")
        colorList := ":red:blue:green:yellow:purple:gray:black:white:"
        if (InStr(colorList, ":" v ":")) {
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

/**
 * @param runOrStop 1: Run; 0:Stop
 */
fn_contorl_JetBrains(runOrStop) {
    if (runOrStop) {
        Run('C:\Windows\System32\schtasks.exe /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
    } else {
        Run('powershell -NoProfile -Command Stop-Process -Name InputTip.JAB.JetBrains -Force', , "Hide")
    }
}

fn_restart(flag := 0, *) {
    if (flag || enableJetBrainsSupport) {
        fn_contorl_JetBrains(0)
    }
    Run(A_ScriptFullPath)
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
* XXX: 确保文本光标位置合法，处于屏幕和活动窗口工作区域范围内。
* NOTE: 1. 并不能检测内部Text控件的X、Y、W、H。
*       2. 没有按比例计算。
* TODO: 按比例计算
* @param X: 文本光标 X 坐标
* @param Y: 文本光标 Y 坐标
* @returns 1: 合法; 0: 不合法
*/
checkCaretPosRight(&X?,&Y?){
    if WinExist("A")
    {
       WinGetClientPos &CX, &CY, &CW, &CH ; CX活动窗口工作区域左上角X坐标，CY~Y坐标；CW~宽度，CH~高度
       if X <= 0 || Y <= 0 || X < CX || (X-CX) > CW || Y < CY || (Y-CY) > CH || X >= A_ScreenWidth-5 || Y >= A_ScreenHeight-10{
           ; X：要显示的tip的X坐标；Y：~Y坐标
           ; X<CX：小于活动窗口宽度
           ; (X-CX) > CW：超过活动窗口宽度
           ; Y<CY：小于活动窗口高度
           ; (Y-CY) > CH：超过活动窗口高度
           ; (X >= A_ScreenWidth-5 && Y >= A_ScreenHeight-10)：不超过屏幕
           return 0
       }else{
           return 1
       }
    }else{
        return 0
    }
}


/**
 * @link https://github.com/Tebayaki/AutoHotkeyScripts/blob/main/lib/GetCaretPosEx/GetCaretPosEx.ahk
 */
GetCaretPosEx(&left?, &top?, &right?, &bottom?) {
    try {
        DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
    }
    hwnd := getHwnd()
    disable_lsit := ":StartMenuExperienceHost.exe:wetype_update.exe:AnLink.exe:wps.exe:PotPlayer.exe:PotPlayer64.exe:PotPlayerMini.exe:PotPlayerMini64.exe:HBuilderX.exe:ShareX.exe:clipdiary-portable.exe:"
    Wpf_list := ":powershell_ise.exe:"
    UIA_list := ":WINWORD.EXE:WindowsTerminal.exe:wt.exe:OneCommander.exe:YoudaoDict.exe:Mempad.exe:Taskmgr.exe:"
    ; MSAA 可能有符号残留
    MSAA_list := ":EXCEL.EXE:DingTalk.exe:Notepad.exe:Notepad3.exe:Quicker.exe:skylark.exe:aegisub32.exe:aegisub64.exe:aegisub.exe:PandaOCR.exe:PandaOCR.Pro.exe:VStart6.exe:TIM.exe:PowerToys.PowerLauncher.exe:Foxmail.exe:"
    ACC_list := ":explorer.exe:ApplicationFrameHost.exe:"
    Gui_UIA_list := ":POWERPNT.EXE:Notepad++.exe:firefox.exe:devenv.exe:"
    ; 需要调用有兼容性问题的 dll 来更新光标位置的应用列表
    Hook_list_with_dll := ":WeChat.exe:"

    if (InStr(disable_lsit, ":" exe_name ":")) {
        return 0
    }
    else if (InStr(UIA_list, ":" exe_name ":")) {
        if (getCaretPosFromUIA()) {
            return checkCaretPosRight(&left, &top)
        }
    }
    else if (InStr(MSAA_list, ":" exe_name ":")) {
        if (getCaretPosFromMSAA()) {
            return checkCaretPosRight(&left, &top)
        }
    }
    else if (InStr(Gui_UIA_list, ":" exe_name ":")) {
        if (getCaretPosFromGui(&hwnd := 0)) {
            return checkCaretPosRight(&left, &top)
        }
        if (getCaretPosFromUIA()) {
            return checkCaretPosRight(&left, &top)
        }
    }
    else if (InStr(Hook_list_with_dll, ":" exe_name ":")) {
        if (getCaretPosFromHook(1)) {
            return checkCaretPosRight(&left, &top)
        }
    }
    else if (InStr(Wpf_list, ":" exe_name ":")) {
        if (getCaretPosFromWpfCaret()) {
            return checkCaretPosRight(&left, &top)
        }
    }
    else {
        if (getCaretPosFromHook(0)) {
            return checkCaretPosRight(&left, &top)
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
            ; ! 有兼容性问题的 dll 调用，部分应用会因为它触发意外错误
            ; ! 如: 崩溃，自动复制/输入/删除/等
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

    getCaretPosFromACC() {
        static _ := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
        try {
            idObject := 0xFFFFFFF8 ; OBJID_CARET
            if DllCall("oleacc\AccessibleObjectFromWindow", "ptr", WinExist("A"), "uint", idObject &= 0xFFFFFFFF
            , "ptr", -16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID := Buffer(16)))
            , "ptr*", oAcc := ComValue(9, 0)) = 0 {
                x := Buffer(4), y := Buffer(4), w := Buffer(4), h := Buffer(4)
                oAcc.accLocation(ComValue(0x4003, x.ptr, 1), ComValue(0x4003, y.ptr, 1), ComValue(0x4003, w.ptr, 1), ComValue(0x4003, h.ptr, 1), 0)
                left := NumGet(x, 0, "int"), top := NumGet(y, 0, "int"), right := NumGet(w, 0, "int"), bottom := NumGet(h, 0, "int")
                if (left | top) != 0
                    return 0
                return 1
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
