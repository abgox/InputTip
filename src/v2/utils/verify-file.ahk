dirList := ["InputTipSymbol", "InputTipSymbol\default"]

for d in dirList {
    if (!DirExist(d)) {
        DirCreate(d)
    }
}

if (!FileExist("InputTipSymbol\default\CN.png")) {
    FileInstall("InputTipSymbol\default\CN.png", "InputTipSymbol\default\CN.png", 1)
}
if (!FileExist("InputTipSymbol\default\EN.png")) {
    FileInstall("InputTipSymbol\default\EN.png", "InputTipSymbol\default\EN.png", 1)
}
if (!FileExist("InputTipSymbol\default\Caps.png")) {
    FileInstall("InputTipSymbol\default\Caps.png", "InputTipSymbol\default\Caps.png", 1)
}
if (!FileExist("InputTipSymbol\default\offer.png")) {
    FileInstall("InputTipSymbol\default\offer.png", "InputTipSymbol\default\offer.png", 1)
}
if (!FileExist("InputTipSymbol\default\favicon.png")) {
    FileInstall("img\favicon.png", "InputTipSymbol\default\favicon.png", 1)
}
if (!FileExist("InputTipSymbol\default\favicon-pause.png")) {
    FileInstall("img\favicon-pause.png", "InputTipSymbol\default\favicon-pause.png", 1)
}

cursor_temp_zip := A_Temp "\abgox-InputTipCursor-temp.zip"
if (!DirExist("InputTipCursor") || !DirExist("InputTipCursor\default")) {
    FileInstall("InputTipCursor.zip", cursor_temp_zip, 1)
    waitFileInstall(cursor_temp_zip)
    try {
        RunWait("powershell -NoProfile -Command Expand-Archive -Path '" cursor_temp_zip "' -DestinationPath '" A_ScriptDir "'", , "Hide")
    } catch {
        MsgBox("软件相关文件释放失败!", , "0x1000 0x10")
        ExitApp()
    }
    try {
        FileDelete(cursor_temp_zip)
    }
}

waitFileInstall(path, isExit := 1) {
    t := 0
    while (!FileExist(path)) {
        if (t > 30) {
            MsgBox("软件相关文件释放失败!", , "0x1000 0x10")
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

/**
 * - 检查配置文件
 * - 当配置文件不存在时，选择是否修改鼠标样式
 */
checkIni() {
    if (!FileExist("InputTip.ini")) {
        gc.init := 1

        ; 是否使用白名单机制，如果是第一次使用，就直接使用白名单机制
        useWhiteList := readIni("useWhiteList", 1)

        isContinue := true
        fz := "s14"
        createGui(confirmGui).Show()
        confirmGui(info) {
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            g.AddText(, "你是否希望 InputTip 修改鼠标样式?")
            g.AddText("xs cRed", "InputTip 会根据不同输入法状态同步修改鼠标样式")
            g.AddEdit("xs Disabled -VScroll", "更多详情，请点击托盘菜单中的「关于」，前往官网或项目中查看")
            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2
            g.AddButton("xs cRed w" bw, "【是】修改鼠标样式").OnEvent("Click", e_yes)
            e_yes(*) {
                g.Destroy()
                createGui(yesGui).Show()
                yesGui(info) {
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    g.AddText(, "你真的确定要修改鼠标样式吗？")
                    g.AddText("cRed", "请谨慎选择，如果误点了确定，恢复鼠标样式需要以下步骤: `n  1. 点击「托盘菜单」=>「更改配置」`n  2. 将「1. 要不要同步修改鼠标样式」的值更改为【否】")
                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2
                    g.AddButton("xs cRed w" bw, "【是】对，我很确定").OnEvent("Click", e_yes)
                    e_yes(*) {
                        g.Destroy()
                        writeIni("changeCursor", 1)
                        global changeCursor := 1
                        isContinue := false
                    }
                    g.AddButton("w" bw, "【否】不，我点错了").OnEvent("Click", e_no)
                    e_no(*) {
                        g.Destroy()
                        writeIni("changeCursor", 0)
                        global changeCursor := 0
                        isContinue := false
                    }
                    return g
                }
            }
            g.AddButton("w" bw, "【否】保留现有样式").OnEvent("Click", e_no)
            e_no(*) {
                g.Destroy()
                writeIni("changeCursor", 0)
                global changeCursor := 0
                isContinue := false
            }
            g.OnEvent("Close", e_exit)
            e_exit(*) {
                ExitApp()
            }
            return g
        }
        while (isContinue) {
            Sleep(500)
        }
        createGui(listTipGui).Show()
        listTipGui(info) {
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            g.AddText("cRed", "对于符号显示，InputTip 现在默认使用白名单机制。")
            g.AddLink("cRed", '<a href="https://inputtip.pages.dev/FAQ/white-list">白名单机制</a> : 只有在白名单中的应用进程窗口会显示符号。')
            g.AddText(, "建议立即添加你常用的应用进程窗口到白名单中。")
            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2
            _c := g.AddButton("w" bw, "【是】现在去添加")
            _c.Focus()
            _c.OnEvent("Click", add_white_list)
            add_white_list(*) {
                close()
                fn_white_list()
            }
            g.AddButton("w" bw, "【否】暂时不添加").OnEvent("Click", close)
            close(*) {
                g.Destroy()
                gc.init := 0
                checkUpdate(1, 1)
            }
            return g
        }
    }
}
