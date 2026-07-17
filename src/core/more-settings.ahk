; InputTip

e_moreSettings(*) {
    showGui(createUniqueGui(moreSettingsGui))
    moreSettingsGui(info) {
        g := createGuiOpt(i18n("moreSettings"))

        tab := renderTab(g, [i18n("moreSettings")])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("more-settings"))

        renderBoldText(g, "menuFontSize")
        renderDDL(g, "menuFontSize", var.nums_8_50)
        renderBoldText(g, "language")
        renderDDL(g, "language", ["zh-CN", "en-US"])
        renderRadioGroup(g, "menuAnimation", [["none", 0], ["animation.fade", 1]])

        ; renderEditGroup(g, "pollInterval", "Number limit2")

        if info.i {
            g.AddButton("xs", i18n("createDesktopShortcut"))
            g.AddButton("yp", i18n("customizeTrayTip"))
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        optW := " w" bw / 2 - g.MarginX / 4
        g.AddButton("xs w" bw, i18n("openDataDirectory")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data"))
        g.AddButton("xs" optW, i18n("updateCheck")).OnEvent("Click", e_updateCheck)
        e_updateCheck(*) {
            showGui(createUniqueGui(checkUpdateGui))
            checkUpdateGui(info) {
                g := createGuiOpt(i18n("updateCheck"))
                g.AddLink("Section", getDocsLink("update-check"))

                if info.i
                    return g
                g.w := w := info.w
                g.bw := bw := w - g.MarginX * 2

                renderRadioGroup(g, "checkUpdateOnStartup", [
                    ["yes", 1, (key, value, *) => (changeConfig(key, value), runUpdater())],
                    ["no", 0]
                ])

                if A_IsCompiled {
                    g.AddButton("xs w" bw, i18n("checkUpdateNow")).OnEvent("Click", update)
                    update(*) {
                        g.Destroy()
                        try Run("`"" A_Temp "\abgox.InputTip.updater.exe`" " keyCount " " ProcessExist() " `"" A_ScriptFullPath "`"")
                    }
                } else {
                    g.AddButton("xs w" bw, i18n("updateNow")).OnEvent("Click", (*) => (
                        g.Destroy(),
                        Run('"' runtime2 '" "' A_ScriptDir '\InputTip.updater.ahk" ' keyCount " " ProcessExist() "," JAB_PID " `"getRepoCode`"")
                    )
                    )
                }
                return g
            }
        }
        g.AddButton("yp" optW, i18n("customizeTrayIcon")).OnEvent("Click", (*) => showGui(createUniqueGui(customizeTrayIconGui)))
        customizeTrayIconGui(info) {
            g := createGuiOpt(i18n("customizeTrayIcon"))

            if info.i {
                g.AddText(, line70)
                return g
            }
            g.w := w := info.w
            g.bw := bw := w - g.MarginX * 2

            g.AddLink("Section", getDocsLink("customize-tray-icon"))
            iconList := getPicList(iconDir, ["default-app.png", "default-app-paused.png"])
            renderDDLGroup(g, "iconRunning", iconList)
            renderDDLGroup(g, "iconPaused", iconList)

            g.AddButton("xs w" bw, i18n("icon.open")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data\icon"))
            return g
        }
        g.AddButton("xs" optW, i18n("createDesktopShortcut")).OnEvent("Click", (*) => createShortcut(A_Desktop))
        g.AddButton("yp" optW, i18n("customizeTrayTip")).OnEvent("Click", (*) => showGui(createUniqueGui(customizeTrayTipGui)))

        customizeTrayTipGui(info) {
            g := createGuiOpt(i18n("customizeTrayTip"))
            if info.i {
                g.AddText(, line70)
                return g
            }
            g.w := w := info.w
            g.bw := bw := w - g.MarginX * 2

            g.AddLink("Section", getDocsLink("customize-tray-tip"))

            renderRadioGroup(g, "enableCustomTrayTip", [["yes", 1], ["no", 0]])
            renderRadioGroup(g, "enableKeyStats", [["yes", 1], ["no", 0]])
            renderEditGroup(g, "trayTipTemplate", "")
            renderEditGroup(g, "keyStatsTemplate", "")
            renderBoldText(g, "templateVar")
            g.AddEdit("xs ReadOnly w" bw, "              %\n%          %appState%          %keyCount%")

            return g
        }
        g.OnEvent("Close", (*) => g.Destroy())
        return g
    }
}
