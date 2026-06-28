; InputTip

startupHKEY := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"

e_startup(item, *) {
    if var.launchAtStartup {
        if var.launchAtStartup != 2 && !A_IsAdmin
            runAsAdmin()
        try FileDelete(A_Startup "/" appid ".lnk")
        try RegDelete(startupHKEY, appid)
        try Run("schtasks /delete /tn `"" taskNameNoUAC "`" /f", , "Hide")
        A_TrayMenu.Uncheck(item)
        changeConfig("launchAtStartup", 0, 1)
    } else {
        showGui(createUniqueGui(startupGui))
        startupGui(info) {
            g := createGuiOpt(i18n("startup"))

            if info.i {
                g.AddText(, line50)
                return g
            }
            w := info.w
            ; bw := w - g.MarginX * 2

            tab := renderTab(g, [i18n("startup")])
            loseFocusOnTab(tab)
            tab.UseTab(1)

            g.AddLink(, getDocsLink("startup"))

            if A_IsAdmin
                btnOpt := "", pad := ""
            else
                btnOpt := " Disabled ", pad := " " i18n("startup.requireAdmin")

            g.AddButton("Section w" w btnOpt, i18n("startup.task") pad).OnEvent("Click", e_useTask)
            e_useTask(*) {
                if A_IsCompiled ? createScheduleTask(A_ScriptFullPath, taskNameNoUAC, [0], , , 1) : createScheduleTask(A_AhkPath, taskNameNoUAC, [A_ScriptFullPath, 0], , , 1)
                    g.Destroy(), A_TrayMenu.Check(item), changeConfig("launchAtStartup", 1, 1)
                else
                    showGui(createErrorTipGui(i18n("startup.fail", 1), i18n("startup")))
            }
            g.AddButton("xs w" w btnOpt, i18n("startup.reg") pad).OnEvent("Click", e_useReg)
            e_useReg(*) {
                try {
                    v := A_IsCompiled ? "`"" A_ScriptFullPath "`"" : "`"" A_AhkPath "`" `"" A_ScriptFullPath "`""
                    RegWrite(v, "REG_SZ", startupHKEY, appid)
                    g.Destroy()
                    A_TrayMenu.Check(item)
                    changeConfig("launchAtStartup", 3, 1)
                } catch {
                    showGui(createErrorTipGui(i18n("startup.fail", 1), i18n("startup")))
                }
            }
            g.AddButton("xs w" w, i18n("startup.shortcut")).OnEvent("Click", e_useLnk)
            e_useLnk(*) {
                g.Destroy()
                A_TrayMenu.Check(item)
                changeConfig("launchAtStartup", 2, 1)
                createShortcut(A_Startup)
            }
            return g
        }
    }
}

checkStartup() {
    startupFlag := 0
    switch var.launchAtStartup {
        case 1:
            taskExists := 0
            try {
                scheduler := ComObject("Schedule.Service")
                scheduler.Connect()
                folder := scheduler.GetFolder("\")
                folder.GetTask(taskNameNoUAC)
                taskExists := 1
            } catch {
                taskExists := 0
            }
            if taskExists
                startupFlag := 1
        case 2:
            try {
                FileGetShortcut(A_Startup "\abgox.InputTip.lnk", &target, , &args)
                if target == A_AhkPath && args == "`"" A_ScriptFullPath "`""
                    startupFlag := 2
            }
        case 3:
            if RegRead(startupHKEY, appid, "") == "`"" A_AhkPath "`" `"" A_ScriptFullPath "`""
                startupFlag := 3
        default:
            A_TrayMenu.Uncheck(i18n("startup"))
    }
    if startupFlag
        A_TrayMenu.Check(i18n("startup"))

    var.launchAtStartup := startupFlag
}
