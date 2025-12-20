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
                text: lang("startup.need_admin"),
            }], "InputTip - " lang("common.error")).Show()
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
            text: lang("startup.cancel_tip"),
        }], "InputTip - " lang("tray.startup")).Show()
    } else {
        createUniqueGui(startupGui).Show()
        startupGui(info) {
            g := createGuiOpt("InputTip - " lang("startup.title"))
            tab := g.AddTab3("-Wrap", [lang("startup.tab"), lang("common.about")])
            tab.UseTab(1)
            g.AddText("Section cRed", lang("gui.help_tip"))

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddText(, "-------------------------------------------------------------------------")

            if (A_IsAdmin) {
                btnOpt := ''
                pad := ""
                tip := lang("startup.admin_tip")
            } else {
                btnOpt := ' Disabled '
                pad := lang("startup.not_available")
                tip := lang("startup.non_admin_tip")
            }

            btn := g.AddButton("Section w" bw btnOpt, lang("startup.task_scheduler") pad)

            btn.OnEvent("Click", e_useTask)
            e_useTask(*) {
                if (A_IsCompiled) {
                    done := createScheduleTask(A_ScriptFullPath, "abgox.InputTip.noUAC", [0], , , 1)
                } else {
                    done := createScheduleTask(A_AhkPath, "abgox.InputTip.noUAC", [A_ScriptFullPath, 0], , , 1)
                }

                if (done) {
                    fn_update_user(A_UserName)
                    isStartUp := 1
                    ; FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", A_Startup "\" fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", fileDesc, favicon, , , 7)
                    fn_handle()
                } else {
                    fn_err_msg("Failed to add task scheduler!`nCheck if powershell.exe or pwsh.exe exists")
                }
            }
            g.AddButton("xs w" bw btnOpt, lang("startup.registry") pad).OnEvent("Click", e_useReg)
            e_useReg(*) {
                isStartUp := 3
                try {
                    v := A_IsCompiled ? A_ScriptFullPath : '"' A_AhkPath '" "' A_ScriptFullPath '"'
                    RegWrite(v, "REG_SZ", HKEY_startup, regName)
                    fn_handle()
                } catch {
                    fn_err_msg("Failed to add registry entry!")
                }
            }
            btn := g.AddButton("xs w" bw, lang("startup.shortcut"))
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
                    text: "You need to try another method for auto-start"
                }], "InputTip - " lang("common.error")).Show()
            }
            tab.UseTab(2)
            g.AddEdit("ReadOnly r10 w" bw, lang("about_text.startup"))
            g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/startup">Auto-start</a>   <a href="https://support.microsoft.com/en-us/windows/user-account-control-settings-d5b2046b-dcb8-54eb-f732-059f321afe18">UAC Settings</a>')
            return g
        }
    }
}
