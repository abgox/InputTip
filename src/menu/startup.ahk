; InputTip

fn_startup(item, *) {
    ; 注册表: 开机自启动
    HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    ; 注册表: 值的名称
    regName := "abgox - " A_ScriptName

    global isStartUp

    if (isStartUp) {
        if (isStartUp != 2 && !A_IsAdmin) {
            createTipGui([{
                opt: "cRed",
                text: "你需要以管理员权限运行来取消【开机自启动】`n设置: 【托盘菜单】=>【以管理员权限启动】",
            }], "InputTip - 错误").Show()
            return
        }

        try {
            FileDelete(A_Startup "/" fileLnk)
        }
        try {
            RegDelete(HKEY_startup, regName)
        }
        try {
            Run('schtasks /delete /tn "abgox.InputTip.noUAC" /f', , "Hide")
        }

        A_TrayMenu.Uncheck(item)
        isStartUp := 0
        writeIni("isStartUp", isStartUp)

        createTipGui([{
            opt: "",
            text: "InputTip 的【开机自启动】已经取消了`n可通过【托盘菜单】=>【开机自启动】再次设置",
        }], "InputTip - 取消开机自启动").Show()
    } else {
        createUniqueGui(startupGui).Show()
        startupGui(info) {
            g := createGuiOpt("InputTip - 设置开机自启动")
            tab := g.AddTab3("-Wrap", ["设置开机自启动", "关于"])
            tab.UseTab(1)
            g.AddText("Section cRed", gui_help_tip)

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddText(, "-------------------------------------------------------------------------")

            if (A_IsAdmin) {
                btnOpt := ''
                pad := ""
                tip := "建议使用: 【任务计划程序】 > 【注册表】 > 【应用快捷方式】`n由于权限或系统限制等环境因素，【应用快捷方式】可能无效"
            } else {
                btnOpt := ' Disabled '
                pad := " (不可用)"
                tip := "当前不是以管理员权限启动，【任务计划程序】和【注册表】不可用`n你可以通过点击【托盘菜单】中的【以管理员权限启动】使它们可用"
            }

            btn := g.AddButton("Section w" bw btnOpt, "任务计划程序" pad)

            btn.OnEvent("Click", e_useTask)
            e_useTask(*) {
                if (A_IsCompiled) {
                    flag := createScheduleTask(A_ScriptFullPath, "abgox.InputTip.noUAC", [0], , , 1)
                } else {
                    flag := createScheduleTask(A_AhkPath, "abgox.InputTip.noUAC", [A_ScriptFullPath, 0], , , 1)
                }

                if (flag) {
                    fn_update_user(A_UserName)
                    isStartUp := 1
                    ; FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", A_Startup "\" fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", fileDesc, favicon, , , 7)
                    fn_handle()
                } else {
                    fn_err_msg("添加任务计划程序失败!")
                }
            }
            g.AddButton("xs w" bw btnOpt, "注册表" pad).OnEvent("Click", e_useReg)
            e_useReg(*) {
                isStartUp := 3
                try {
                    v := A_IsCompiled ? A_ScriptFullPath : '"' A_AhkPath '" "' A_ScriptFullPath '"'
                    RegWrite(v, "REG_SZ", HKEY_startup, regName)
                    fn_handle()
                } catch {
                    fn_err_msg("添加注册表失败!")
                }
            }
            btn := g.AddButton("xs w" bw, "应用快捷方式")
            btn.OnEvent("Click", e_useLnk)
            e_useLnk(*) {
                isStartUp := 2
                if (A_IsCompiled) {
                    FileCreateShortcut(A_ScriptFullPath, A_Startup "\" fileLnk, , , fileDesc, favicon, , , 7)
                } else {
                    FileCreateShortcut(A_AhkPath, A_Startup "\" fileLnk, , '"' A_ScriptFullPath '"', fileDesc, favicon, , , 7)
                }
                fn_handle()
            }

            g.AddText("cGray", tip)

            fn_handle(*) {
                g.Destroy()
                A_TrayMenu.Check(item)
                writeIni("isStartUp", isStartUp)
            }
            fn_err_msg(msg, *) {
                createTipGui([{
                    opt: "cRed",
                    text: msg,
                }, {
                    opt: "cRed",
                    text: "你需要考虑使用其他方式设置开机自启动"
                }], "InputTip - 错误").Show()
            }
            tab.UseTab(2)
            g.AddEdit("ReadOnly r10 w" bw, "1. 简要说明`n   - 这个菜单用来设置 InputTip 的开机自启动`n   - 你可以从以下三种方式中，选择有效的方式`n   - 需要注意: 如果移动了软件所在位置，需要重新设置才有效`n`n2. 按钮 —— 任务计划程序`n   - 点击它，会创建一个任务计划程序 abgox.InputTip.noUAC`n   - 系统启动后，会通过它自动运行 InputTip`n   - 它可以直接避免每次启动都弹出管理员授权(UAC)窗口`n`n3. 按钮 —— 注册表`n   - 点击它，会将程序路径写入开机自启动的注册表`n   - 系统启动后，会通过它自动运行 InputTip`n`n4. 按钮 —— 应用快捷方式`n   - 点击它，会在 shell:startup 目录下创建一个普通的快捷方式`n   - 系统启动后，会通过它自动运行 InputTip`n   - 注意: 由于权限或系统电源计划限制等因素，它可能无效`n`n5. 关于管理员授权(UAC)窗口`n   - 只有【任务计划程序】能直接避免此窗口弹出`n   - 使用【注册表】或【应用快捷方式】需要修改系统设置`n      - 系统设置 =>【更改用户账户控制设置】=>【从不通知】")
            g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/faq/startup">开机自启动</a>   <a href="https://support.microsoft.com/zh-cn/windows/用户帐户控制设置-d5b2046b-dcb8-54eb-f732-059f321afe18">用户账户控制设置(微软帮助)</a>')
            return g
        }
    }
}
