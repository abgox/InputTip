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

        if (gc.w.startupGui) {
            gc.w.startupGui.Destroy()
            gc.w.startupGui := ""
        }
        createGui(cancelGui).Show()
        cancelGui(info) {
            g := createGuiOpt()
            g.AddText(, "InputTip 的")
            g.AddText("yp cRed", "开机自启动")
            g.AddText("yp", "已取消")
            g.AddText("xs", "可通过「托盘菜单」=>「开机自启动」再次启用")

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            y := g.AddButton("w" w, "我知道了")
            y.Focus()
            y.OnEvent("Click", e_yes)
            e_yes(*) {
                g.Destroy()
            }
            gc.w.startupGui := g
            return g
        }
    } else {
        if (gc.w.startupGui) {
            gc.w.startupGui.Destroy()
            gc.w.startupGui := ""
        }
        createGui(startupGui).Show()
        startupGui(info) {
            g := createGuiOpt("InputTip - 设置开机自启动")
            g.AddLink(, '详情请查看: <a href="https://inputtip.pages.dev/FAQ/startup">关于开机自启动</a>')
            g.AddText(, "---------------------------------------------------------------------")

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddEdit("xs ReadOnly -VScroll w" w, "1. 当前有多种方式设置开机自启动，请选择有效的方式 :`n   - 通过「任务计划程序」`n   - 通过应用快捷方式`n   - 通过添加「注册表」`n`n2. 如何避免管理员授权窗口(UAC)的干扰？`n   - 使用「任务计划程序」`n   - 将系统设置中的「更改用户账户控制设置」修改为【从不通知】`n")

            if (A_IsAdmin) {
                btnOpt := ''
                tip := ''
            } else {
                btnOpt := ' Disabled '
                tip := ' (以管理员模式运行时可用)'
            }

            if (!btnOpt && !powershell) {
                btn := g.AddButton("Disabled w" w btnOpt, "使用「任务计划程序」 (无法调用 powershell)")
            } else {
                btn := g.AddButton("w" w btnOpt, "使用「任务计划程序」" tip)
            }

            btn.Focus()
            btn.OnEvent("Click", e_useTask)
            e_useTask(*) {
                isStartUp := 1
                FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", A_Startup "\" fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", , favicon, , , 7)
                fn_handle()
            }
            btn := g.AddButton("w" w, "使用应用快捷方式")
            if (!A_IsAdmin) {
                btn.Focus()
            }
            btn.OnEvent("Click", e_useLnk)
            e_useLnk(*) {
                isStartUp := 2
                FileCreateShortcut(A_ScriptFullPath, A_Startup "\" fileLnk, , , , favicon, , , 7)
                fn_handle()
            }
            g.AddButton("w" w btnOpt, "使用「注册表」" tip).OnEvent("Click", e_useReg)
            e_useReg(*) {
                isStartUp := 3
                try {
                    RegWrite(A_ScriptFullPath, "REG_SZ", "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", A_ScriptName)
                    fn_handle()
                } catch {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    createGui(errGui).Show()
                    errGui(info) {
                        g := createGuiOpt()
                        g.AddText("cRed", "添加注册表失败!")
                        g.AddText("cRed", "你需要考虑使用其他方式设置开机自启动")

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2


                        g.AddButton("w" bw, "我知道了").OnEvent("Click", e_close)
                        e_close(*) {
                            g.Destroy()
                        }
                        gc.w.subGui := g
                        return g
                    }
                }
            }
            fn_handle(*) {
                g.Destroy()
                A_TrayMenu.Check(item)
                writeIni("isStartUp", isStartUp)
            }
            gc.w.startupGui := g
            return g
        }
    }
}
