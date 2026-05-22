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

        tab := g.AddTab3("-Wrap", [i18n("moreSettings"), i18n("moreSettings") 2])
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
        renderRadioGroup(g, "enableCustomTrayTip", [
            ["yes", 1, customStatsTemplate.Bind("trayTipTemplate")],
            ["no", 0]
        ])
        g.AddText("yp w20")
        renderText(g, "configureViaDoubleClick", "yp", "cGray")

        renderRadioGroup(g, "enableKeyStats", [
            ["yes", 1, customStatsTemplate.Bind("keyStatsTemplate")],
            ["no", 0]
        ])
        g.AddText("yp w20")
        renderText(g, "configureViaDoubleClick", "yp", "cGray")

        customStatsTemplate(key, *) {
            showGui(createUniqueGui(customStatsTemplateGui))
            customStatsTemplateGui(info) {
                g := createGuiOpt(i18n(key))
                if (info.i) {
                    g.AddText(, line70)
                    return g
                }
                g.w := w := info.w
                g.bw := bw := w - g.MarginX * 2

                g.AddLink("Section", getDocsLink("more-settings"))

                renderEditGroup(g, key, "")

                g.SetFont("Bold")
                g.AddGroupBox("xs h90 w" g.bw, i18n("templateVar"))
                g.SetFont("Norm")
                g.AddEdit("xs+20 yp+40 ReadOnly w" g.bw - 40, "%\n%     %keyCount%     %appState%")
                return g
            }
        }

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("more-settings"))

        g.AddButton("xs w" bw, i18n("createDesktopShortcut")).OnEvent("Click", (*) => createShortcut(A_Desktop))
        g.AddButton("xs w" bw, i18n("openAppDirectory")).OnEvent("Click", (*) => Run("explorer.exe /select," A_ScriptFullPath))
        g.AddButton("xs w" bw, i18n("openDataDirectory")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data"))
        g.AddButton("xs w" bw, i18n("updateCheck")).OnEvent("Click", e_updateCheck)
        g.AddButton("xs w" bw, i18n("autoExit.window")).OnEvent("Click", (*) =>
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
        g.AddButton("xs w" bw, i18n("ignoreStateSwitch.window")).OnEvent("Click", (*) =>
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

        g.AddButton("xs w" bw, i18n("customizeTrayIcons")).OnEvent("Click", (*) => showGui(createUniqueGui(customizeTrayIconsGui)))

        customizeTrayIconsGui(info) {
            g := createGuiOpt(i18n("customizeTrayIcons"))

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
