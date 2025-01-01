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
        ; 是否使用白名单机制，如果是第一次使用，就直接使用白名单机制
        useWhiteList := readIni("useWhiteList", 1)

        isContinue := true
        createGui(fn1).Show()
        fn1(x, y, w, h) {
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            g.AddText(, "你是否希望 InputTip 修改鼠标样式?")
            g.AddText(, "当确定修改后，InputTip")
            g.AddText("yp cRed", "会根据不同的输入法状态(中英文/大写锁定)同步修改鼠标样式")
            g.AddEdit("xs Disabled -VScroll", "更多信息，请点击托盘菜单中的 「关于」，前往官网或项目中查看")
            g.AddButton("xs cRed w" bw, "【是】对，我要修改").OnEvent("Click", yes)
            yes(*) {
                g.Destroy()
                createGui(fn).Show()
                fn(x, y, w, h) {
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText(, "你真的确定要修改鼠标样式吗？")
                    g.AddText("cRed", "注意：请谨慎选择，如果是误点了确定，恢复之前的鼠标样式需要以下额外步骤或者重启系统`n1. 点击「托盘菜单」=>「更改配置」`n2. 修改其中「1. 要不要修改鼠标样式」的值`n3. 「系统设置」=>「其他鼠标设置」=> 先更改为另一个鼠标样式方案，再改回你之前使用的方案")
                    g.AddButton("xs cRed w" bw, "【是】对，我很确定").OnEvent("Click", yes)
                    yes(*) {
                        g.Destroy()
                        writeIni("changeCursor", 1)
                        global changeCursor := 1
                        isContinue := false
                    }
                    g.AddButton("w" bw, "【否】不，我点错了").OnEvent("Click", no)
                    no(*) {
                        g.Destroy()
                        writeIni("changeCursor", 0)
                        global changeCursor := 0
                        isContinue := false
                    }
                    return g
                }
            }
            g.AddButton("w" bw, "【否】不，保留现有样式").OnEvent("Click", no)
            no(*) {
                g.Destroy()
                writeIni("changeCursor", 0)
                global changeCursor := 0
                isContinue := false
            }
            g.OnEvent("Close", fn_exit)
            fn_exit(*) {
                ExitApp()
            }
            return g
        }
        while (isContinue) {
            Sleep(500)
        }
        createGui(fn2).Show()
        fn2(x, y, w, h) {
            warning := "注意：请谨慎选择，如果是误点了确定，恢复之前的鼠标样式需要以下额外步骤或者重启系统`n1. 点击「托盘菜单」=>「更改配置」`n2. 修改其中「1. 要不要修改鼠标样式」的值`n3. 「系统设置」=>「其他鼠标设置」=> 先更改为另一个鼠标样式方案，再改回你之前使用的方案"

            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            g.AddText("cRed", "对于符号显示，InputTip 现在默认使用白名单机制。")
            g.AddLink("cRed", '<a href="https://inputtip.pages.dev/FAQ/about-white-list">白名单机制</a> : 只有在白名单中的应用进程窗口会显示符号。')
            g.AddText(, "建议立即添加应用进程到白名单中。")
            _c := g.AddButton("w" bw, "【是】现在就添加应用进程")
            _c.OnEvent("Click", add_white_list)
            _c.Focus()
            g.AddButton("w" bw, "【否】不了，等一下再添加").OnEvent("Click", no)
            add_white_list(*) {
                g.Destroy()
                fn_white_list()
            }
            no(*) {
                g.Destroy()
            }
            return g
        }
    }
}
