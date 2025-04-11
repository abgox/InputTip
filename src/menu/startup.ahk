; InputTip

fn_startup(item, *) {
    ; 注册表: 开机自启动
    HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"

    global isStartUp
    if (isStartUp) {
        if (gc.w.updateUserGui) {
            gc.w.updateUserGui.Destroy()
            gc.w.updateUserGui := ""
        }
        if (gc.w.subGui) {
            gc.w.subGui.Destroy()
            gc.w.subGui := ""
        }
        if (isStartUp != 2 && !A_IsAdmin) {
            createTipGui([{
                opt: "cRed",
                text: "你需要以管理员权限运行来取消「开机自启动」`n设置: 「托盘菜单」=>「以管理员权限启动」",
            }], "InputTip - 错误").Show()

            return
        }

        try {
            FileDelete(A_Startup "/" fileLnk)
        }
        try {
            RegDelete(HKEY_startup, "abgox - " A_ScriptName)
        }
        try {
            Run('schtasks /delete /tn "abgox.InputTip.noUAC" /f', , "Hide")
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
            g := createGuiOpt("InputTip - 取消开机自启动")
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
            tab := g.AddTab3("-Wrap", ["设置开机自启动", "关于"])
            tab.UseTab(1)
            g.AddText("Section cRed", "你首先应该点击上方的「关于」或官网查看相关的详细帮助说明")
            g.AddText("xs cRed", "如果移动了软件所在位置，需要重新设置才有效`n")

            if (info.i) {
                g.AddText("cGray", "推荐「任务计划程序」或「注册表」,「应用快捷方式」可能无效")
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            if (A_IsAdmin) {
                btnOpt := ''
                tip := ''
            } else {
                btnOpt := ' Disabled '
                tip := ' (非管理员身份运行时不可用)'
            }

            btn := g.AddButton("Section w" bw btnOpt, "「任务计划程序」" tip)

            btn.Focus()
            btn.OnEvent("Click", e_useTask)
            e_useTask(*) {
                if (A_IsCompiled) {
                    flag := createScheduleTask(A_ScriptFullPath, "abgox.InputTip.noUAC", 0, , , 1)
                } else {
                    flag := createScheduleTask(A_AhkPath, "abgox.InputTip.noUAC", A_ScriptFullPath, , , 1)
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
            g.AddButton("xs w" bw btnOpt, "「注册表」" tip).OnEvent("Click", e_useReg)
            e_useReg(*) {
                isStartUp := 3
                try {
                    v := A_IsCompiled ? A_ScriptFullPath : '"' A_AhkPath '" "' A_ScriptFullPath '"'
                    RegWrite(v, "REG_SZ", HKEY_startup, "abgox - " A_ScriptName)
                    fn_handle()
                } catch {
                    fn_err_msg("添加注册表失败!")
                }
            }
            btn := g.AddButton("xs w" bw, "「应用快捷方式」")
            if (!A_IsAdmin) {
                btn.Focus()
            }
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

            g.AddText("cGray", "推荐使用「任务计划程序」或「注册表」,「应用快捷方式」可能无效")

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
            g.AddText("cRed", "这里有多种方式设置开机自启动，请选择有效的方式")
            g.AddEdit("ReadOnly r9 w" bw, "1. 关于「任务计划程序」`n   - 会创建一个任务计划程序 abgox.InputTip.noUAC`n   - 系统启动后，会通过它自动运行 InputTip`n   - 它可以直接避免每次启动都弹出管理员授权(UAC)窗口`n`n2. 关于「注册表」`n   - 会将程序路径写入注册表`n   - 系统启动后，会通过它自动运行 InputTip`n`n3. 关于「应用快捷方式」`n   - 它会在 shell:startup 目录下创建一个普通的快捷方式`n   - 系统启动后，会通过它自动运行 InputTip`n   - 注意: 由于系统电源计划限制等因素，它可能无效`n`n4. 关于管理员授权(UAC)窗口`n   - 注意: 只有「任务计划程序」能直接避免此窗口弹出`n   - 「注册表」或「应用快捷方式」需要修改系统设置`n      - 系统设置 =>「更改用户账户控制设置」=>「从不通知」")
            g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/startup">关于开机自启动</a>   <a href="https://support.microsoft.com/zh-cn/windows/用户帐户控制设置-d5b2046b-dcb8-54eb-f732-059f321afe18">用户账户控制设置(微软帮助)</a>')

            gc.w.startupGui := g
            return g
        }
    }
}

;
/**
 * 创建/更新任务计划程序
 * @param path 要执行的应用程序
 * @param taskName 任务计划名称
 * @param {String} argument 运行参数
 * @param {Highest | Limited} runLevel 运行级别
 * @param {Boolean} isWait 是否等待完成
 * @param {Boolean} needStartUp 是否需要开机启动
 * @returns {Integer} 是否创建成功
 */
createScheduleTask(path, taskName, argument := "", runLevel := "Highest", isWait := 0, needStartUp := 0, *) {
    if (A_IsAdmin) {
        cmd := 'powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' path '\"`'" -Argument "`'\"' argument '\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' userName '" -RunLevel ' runLevel ';$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);'
        if (needStartUp) {
            cmd .= '$trigger = New-ScheduledTaskTrigger -AtLogOn;$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings -Trigger $trigger;'
        } else {
            cmd .= '$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;'
        }
        cmd .= 'Register-ScheduledTask -TaskName ' taskName ' -InputObject $task -Force;'
        try {
            isWait ? RunWait(cmd, , "Hide") : Run(cmd, , "Hide")
            return 1
        } catch {
            return 0
        }
    }
    return 0
}
