; InputTip

e_startup(item, *) {
    if (var.launchAtStartup) {
        if (var.launchAtStartup != 2 && !A_IsAdmin) {
            runAsAdmin()
        }

        try FileDelete(A_Startup "/" var.fileLnk)
        try RegDelete(var.startupHKEY, var.startupRegName)
        try Run('schtasks /delete /tn "abgox.InputTip.noUAC" /f', , "Hide")

        A_TrayMenu.Uncheck(item)

        changeConfig("launchAtStartup", 0)
    } else {
        showGui(createUniqueGui(startupGui))
        startupGui(info) {
            g := createGuiOpt(i18n("startup"))

            if (info.i) {
                g.AddText(, line50)
                return g
            }
            w := info.w
            ; bw := w - g.MarginX * 2

            tab := renderTab(g, [i18n("startup")])
            loseFocusOnTab(tab)
            tab.UseTab(1)

            g.AddLink(, getDocsLink("startup"))


            if (A_IsAdmin) {
                btnOpt := ""
                pad := ""
            } else {
                btnOpt := " Disabled "
                pad := " " i18n("startup.requireAdmin")
            }

            g.AddButton("Section w" w btnOpt, i18n("startup.task") pad).OnEvent("Click", e_useTask)
            e_useTask(*) {
                if (A_IsCompiled) {
                    done := createScheduleTask(A_ScriptFullPath, "abgox.InputTip.noUAC", [0], , , 1)
                } else {
                    done := createScheduleTask(A_AhkPath, "abgox.InputTip.noUAC", [A_ScriptFullPath, 0], , , 1)
                }

                if (done) {
                    var.launchAtStartup := 1
                    ; createShortcut(A_Startup)
                    handle()
                } else {
                    showGui(createErrorTipGui(i18n("startup.fail", 1), i18n("startup")))
                }
            }
            g.AddButton("xs w" w btnOpt, i18n("startup.reg") pad).OnEvent("Click", e_useReg)
            e_useReg(*) {
                var.launchAtStartup := 3
                try {
                    v := A_IsCompiled ? A_ScriptFullPath : "" " A_AhkPath " " " " A_ScriptFullPath " ""
                    RegWrite(v, "REG_SZ", var.startupHKEY, var.startupRegName)
                    handle()
                } catch {
                    showGui(createErrorTipGui(i18n("startup.fail", 1), i18n("startup")))
                }
            }
            g.AddButton("xs w" w, i18n("startup.shortcut")).OnEvent("Click", e_useLnk)
            e_useLnk(*) {
                var.launchAtStartup := 2
                createShortcut(A_Startup)
                handle()
            }

            handle(*) {
                g.Destroy()
                A_TrayMenu.Check(item)
                changeConfig("launchAtStartup", var.launchAtStartup)
            }
            return g
        }
    }
}
