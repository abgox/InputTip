fn_JAB(item, *) {
    global enableJetBrainsSupport := !enableJetBrainsSupport
    writeIni("enableJetBrainsSupport", enableJetBrainsSupport)
    A_TrayMenu.ToggleCheck(item)
    if (enableJetBrainsSupport) {
        FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
        waitFileInstall("InputTip.JAB.JetBrains.exe", 0)

        ideGui := Gui("AlwaysOnTop", "InputTip - 启用 JAB/JetBrains IDE 支持")
        ideGui.SetFont(fz, "微软雅黑")
        ideGui.AddText(, "------------------------------------------------------------------------------")
        ideGui.Show("Hide")
        ideGui.GetPos(, , &Gui_width)
        ideGui.Destroy()

        ideGui := Gui("AlwaysOnTop", "InputTip - 启用 JAB/JetBrains IDE 支持")
        ideGui.SetFont(fz, "微软雅黑")
        ideGui.AddText(, "已经成功启用了 JAB/JetBrains IDE 支持，你还需要进行以下步骤:")

        ideGui.AddEdit("xs -VScroll ReadOnly w" Gui_width, "1. 开启 Java Access Bridge`n2. 点击下方的或托盘菜单中的「设置光标获取模式」`n3. 将 JetBrains IDE 或其他 JAB 应用进程添加到其中的「JAB」列表中`n4. 如果未生效，请重启正在使用的 JetBrains IDE 或其他 JAB 应用`n5. 如果仍未生效，请重启 InputTip 或重启系统`n6. 有多块屏幕时，副屏幕上可能有坐标偏差，需要通过「设置特殊偏移量」调整")
        ideGui.AddLink(, '详细操作步骤，请查看:   <a href="https://inputtip.pages.dev/FAQ/use-inputtip-in-jetbrains">InputTip 官网</a>   <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Github</a>   <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Gitee</a>')
        ideGui.AddButton("xs w" Gui_width, "「设置光标获取模式」").OnEvent("Click", fn_cursor_mode)
        y := ideGui.AddButton("xs w" Gui_width, "我知道了")
        y.OnEvent("Click", yes)
        y.Focus()
        ideGui.OnEvent("Close", yes)
        yes(*) {
            ideGui.Destroy()
            gc.w.enableJetBrainsGui := ""
        }
        gc.w.enableJetBrainsGui := ideGui
        ideGui.Show()
        runJetBrains()
    } else {
        if (gc.w.enableJetBrainsGui) {
            gc.w.enableJetBrainsGui.Destroy()
            gc.w.enableJetBrainsGui := ""
        }
        SetTimer(killAppTimer, -10)
        killAppTimer() {
            try {
                RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
                if (A_IsAdmin) {
                    Run('schtasks /delete /tn "abgox.InputTip.JAB.JetBrains" /f', , "Hide")
                    try {
                        FileDelete("InputTip.JAB.JetBrains.exe")
                    }
                }
            }
        }
    }
}
