fn_startup(item, *) {
    global isStartUp
    if (isStartUp) {
        try {
            FileDelete(A_Startup "\" fileLnk)
        }
        try {
            RegDelete(HKEY_startup, A_ScriptName)
        }
        A_TrayMenu.Uncheck(item)
        isStartUp := 0
        writeIni("isStartUp", isStartUp)

        createGui(_fn).Show()
        _fn(x, y, w, h) {
            if (gc.w.startupGui) {
                gc.w.startupGui.Destroy()
                gc.w.startupGui := ""
            }
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            g.AddText(, "InputTip 的")
            g.AddText("yp cRed", "开机自启动")
            g.AddText("yp", "已取消")
            g.AddText("xs", "可通过「托盘菜单」=>「开机自启动」再次启用")
            y := g.AddButton("w" w, "我知道了")
            y.OnEvent("Click", yes)
            y.Focus()
            g.OnEvent("Close", yes)
            yes(*) {
                g.Destroy()
            }
            gc.w.startupGui := g
            return g
        }
    } else {
        if (A_IsAdmin) {
            isDisabled := ''
            pad := ''
        } else {
            isDisabled := ' Disabled'
            pad := ' (以管理员模式运行时可用)'
        }
        createGui(fn).Show()
        fn(x, y, w, h) {
            if (gc.w.startupGui) {
                gc.w.startupGui.Destroy()
                gc.w.startupGui := ""
            }
            g := Gui("AlwaysOnTop +OwnDialogs", "设置开机自启动")
            g.SetFont(fz, "微软雅黑")
            g.AddLink(, '详情请查看: <a href="https://inputtip.pages.dev/FAQ/about-startup">关于开机自启动</a>                                                     `n')
            g.AddEdit("xs ReadOnly -VScroll w" w, "1. 当前有多种方式设置开机自启动，请选择有效的方式 :`n   - 通过「任务计划程序」`n   - 通过应用快捷方式`n   - 通过添加「注册表」`n`n2. 如何避免管理员授权窗口(UAC)的干扰？`n   - 使用「任务计划程序」`n   - 将系统设置中的「更改用户账户控制设置」修改为【从不通知】`n")

            btn := g.AddButton("w" w isDisabled, "使用「任务计划程序」" pad)
            btn.Focus()
            btn.OnEvent("Click", fn_startUp_task)
            fn_startUp_task(*) {
                isStartUp := 1
                FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", A_Startup "\" fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", , favicon, , , 7)
                fn_handle()
            }
            btn := g.AddButton("w" w, "使用应用快捷方式")
            if (!A_IsAdmin) {
                btn.Focus()
            }
            btn.OnEvent("Click", fn_startUp_lnk)
            fn_startUp_lnk(*) {
                isStartUp := 2
                FileCreateShortcut(A_ScriptFullPath, A_Startup "\" fileLnk, , , , favicon, , , 7)
                fn_handle()
            }
            g.AddButton("w" w isDisabled, "使用「注册表」" pad).OnEvent("Click", fn_startUp_reg)
            fn_startUp_reg(*) {
                isStartUp := 3
                try {
                    RegWrite(A_ScriptFullPath, "REG_SZ", "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", A_ScriptName)
                    fn_handle()
                } catch {
                    fn_handle(1)
                    MsgBox("添加注册表失败!", , "0x1000 0x10")
                }
            }
            g.OnEvent("Close", fn_handle)
            fn_handle(err := 0, *) {
                g.Destroy()
                if (!err) {
                    if (isStartUp) {
                        A_TrayMenu.Check(item)
                    } else {
                        A_TrayMenu.Uncheck(item)
                    }
                    writeIni("isStartUp", isStartUp)
                }
            }
            gc.w.startupGui := g
            return g
        }
    }
}
