; InputTip

e_moreSettings(*) {
    showGui(createUniqueGui(moreSettingsGui))
    moreSettingsGui(info) {
        g := createGuiOpt(i18n("moreSettings"))

        if (info.i) {
            g.AddText(, line70)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        tab := renderTab(g, [i18n("moreSettings"), i18n("moreSettings") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("more-settings"))

        renderRadioGroupList(g, [
            ["language",
                [
                    [".chinese", "zh-CN"],
                    [".english", "en-US"]
                ]
            ],
            [
                "menuAnimation",
                [
                    ["none", 0],
                    ["animation.fade", 1],
                    ["animation.slide", 2],
                    ["animation.scale", 3]
                ]
            ],
        ])

        renderEditGroup(g, "pollInterval", "Number limit2")

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("more-settings"))

        _w := bw / 2
        g.AddButton("xs w" _w, i18n("openDataDirectory")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data"))
        g.AddButton("yp w" _w, i18n("updateCheck")).OnEvent("Click", e_updateCheck)
        g.AddButton("xs w" _w, i18n("openAppDirectory")).OnEvent("Click", (*) => Run("explorer.exe /select," A_ScriptFullPath))
        g.AddButton("yp w" _w, i18n("createDesktopShortcut")).OnEvent("Click", (*) => createShortcut(A_Desktop))
        g.AddButton("xs w" _w, i18n("autoExit.window")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("autoExit.window"),
                [
                    i18n("windowRule")
                ],
                getDocsLink("auto-exit"),
                [
                    "Window.AutoExit"
                ]
            )
        )
        g.AddButton("yp w" _w, i18n("customizeTrayIcon")).OnEvent("Click", (*) => showGui(createUniqueGui(customizeTrayIconGui)))
        customizeTrayIconGui(info) {
            g := createGuiOpt(i18n("customizeTrayIcon"))

            if (info.i) {
                g.AddText(, line70)
                return g
            }
            g.w := w := info.w
            g.bw := bw := w - g.MarginX * 2

            g.AddLink("Section", getDocsLink("more-settings"))
            iconList := getPicList(iconDir, ["default-app.png", "default-app-paused.png"])
            renderDropDownListGroup(g, "iconRunning", iconList)
            renderDropDownListGroup(g, "iconPaused", iconList)

            g.AddButton("xs w" bw, i18n("icon.open")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data\icon"))
            return g
        }
        g.AddButton("xs w" _w, i18n("ignoreStateSwitch.window")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("ignoreStateSwitch.window"),
                [
                    i18n("windowRule")
                ],
                getDocsLink("switch/ignore-state-switch"),
                [
                    "Window.IgnoreStateSwitch"
                ]
            )
        )
        g.AddButton("yp w" _w, i18n("customizeTrayTip")).OnEvent("Click", (*) => showGui(createUniqueGui(customizeTrayTipGui)))

        customizeTrayTipGui(info) {
            g := createGuiOpt(i18n("customizeTrayTip"))
            if (info.i) {
                g.AddText(, line70)
                return g
            }
            g.w := w := info.w
            g.bw := bw := w - g.MarginX * 2

            g.AddLink("Section", getDocsLink("more-settings"))

            renderRadioGroup(g, "enableCustomTrayTip", [["yes", 1], ["no", 0]])
            renderRadioGroup(g, "enableKeyStats", [["yes", 1], ["no", 0]])
            renderEditGroup(g, "trayTipTemplate", "")
            renderEditGroup(g, "keyStatsTemplate", "")
            renderGroupBox(g, "templateVar", , "xs h90 w" bw)
            g.AddEdit("xs+20 yp+40 ReadOnly w" bw - 40, "%\n%          %appState%          %keyCount%")

            return g
        }
        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            gc.tab := 0
            gc.timer := 0
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        return g
    }
}
