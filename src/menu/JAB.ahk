fn_JAB(item, *) {
    global enableJABSupport := !enableJABSupport
    writeIni("enableJABSupport", enableJABSupport)
    A_TrayMenu.ToggleCheck(item)
    if (enableJABSupport) {
        if (runJAB()) {
            return
        }
        createGui(JABGui).Show()
        JABGui(info) {
            g := createGuiOpt("InputTip - 启用 JAB/JetBrains IDE 支持")
            g.AddText(, "已经成功启用了 JAB/JetBrains IDE 支持，你还需要进行以下操作步骤:           ")

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddEdit("xs -VScroll ReadOnly cGray w" w, "1. 开启 Java Access Bridge`n2. 点击下方的或「托盘菜单」中的「设置光标获取模式」`n3. 将 JetBrains IDE 或其他 JAB 应用进程添加到其中的「JAB」列表中`n4. 如果未生效，请重启正在使用的 JetBrains IDE 或其他 JAB 应用`n5. 如果仍未生效，请重启 InputTip 或重启系统`n6. 有多块屏幕时，副屏幕上可能有坐标偏差，需要通过「设置特殊偏移量」调整")
            g.AddLink(, '详细操作步骤，请查看:   <a href="https://inputtip.pages.dev/FAQ/use-inputtip-in-jetbrains">官网</a>   <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Github</a>   <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Gitee</a>')
            g.AddButton("xs w" w, "「设置光标获取模式」").OnEvent("Click", fn_cursor_mode)
            g.AddButton("xs w" w, "「设置特殊偏移量」").OnEvent("Click", fn_app_offset)
            y := g.AddButton("xs w" w, "我知道了")
            y.Focus()
            y.OnEvent("Click", e_close)
            e_close(*) {
                g.Destroy()
            }
            gc.w.enableJABGui := g
            return g
        }
    } else {
        if (gc.w.enableJABGui) {
            gc.w.enableJABGui.Destroy()
            gc.w.enableJABGui := ""
        }
        SetTimer(killAppTimer, -1)
        killAppTimer() {
            try {
                killJAB(1, A_IsCompiled)
                if (A_IsAdmin) {
                    Run('schtasks /delete /tn "abgox.InputTip.JAB.JetBrains" /f', , "Hide")
                }
            }
        }
    }
}
