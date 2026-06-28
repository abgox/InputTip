; InputTip

e_border(*) {
    showGui(createUniqueGui(borderStyleGui))
    borderStyleGui(info) {
        g := createGuiOpt(i18n("border"))

        if info.i {
            g.AddText(, isChinese ? line80 : line90)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        ctrlList := []

        tab := renderTab(g, [i18n("basicConfig"), i18n("basicConfig") 2, i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/border"))

        renderRadioGroup(g, "borderActive", [
            ["yes", 1, (key, value, *) => (changeConfig(key, value), disableCtrl(ctrlList, 0))],
            ["no", 0, (key, value, *) => (changeConfig(key, value), disableCtrl(ctrlList))]
        ])

        _ := renderEditGroup(g, "borderHideDelay", "Number Limit5")
        ctrlList.Push(_.edit)

        _ := renderRadioGroup(g, "borderShowMode", [["blacklist", "blacklist"], ["whitelist", "whitelist"]])
        ctrlList.Push(_.radios*)

        _w := bw / 2 - g.MarginX / 4
        for i, v in [["hide", "blacklistBtn"], ["show", "whitelistBtn"]] {
            _ := g.AddButton((i == 1 ? "xs" : "yp") " w" _w, i18n(v[2]))
            _.OnEvent("Click",
                createProcessMenuGui.Bind({
                    title: i18n("border") " - " i18n(v[2]),
                    tab: [i18n(v[2])],
                    trigger: [v[1]],
                    link: getDocsLink("tip/border/list-mechanism"),
                    section: "Window.Border.Rule",
                    cols: ["process", "condition", "class", "title"],
                    conditions: conditionKeyList
                })
            )
            ctrlList.Push(_)
        }

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("tip/border"))

        renderGroupBox(g, "borderReshowOnChange", , "h" uicText.h " w" bw)
        g.AddCheckbox("xs+20 yp+" uicText.yp " Disabled", i18n("borderReshowOnChange.state")).Value := 1
        for v in ["Process", "Title", "Class"] {
            _ := g.AddCheckbox("yp", i18n("borderReshowOnChange." StrLower(v)))
            key := "borderReshowOn" v "Change"
            _.Value := var.%key%
            _.OnEvent("Click", e_change.Bind(key))
            ctrlList.Push(_)
        }
        e_change(key, ctrl, *) {
            val := ctrl.Value
            var.%key% := val
            writeIni(key, val)
        }

        renderGroupBox(g, "showOnWindowState", , "h" uicText.h " w" bw)
        for i, v in ["Normal", "Maximized", "Fullscreen"] {
            _ := g.AddCheckbox(i == 1 ? "xs+20 yp+" uicText.yp : "yp", i18n("showOnWindowState." StrLower(v)))
            key := "borderShowOn" v
            _.Value := var.%key%
            _.OnEvent("Click", e_change.Bind(key))
            ctrlList.Push(_)
        }

        renderGroupBox(g, "borderShowOnMaximized", , "h" uicText.h " w" bw)
        for i, v in ["Top", "Bottom", "Left", "Right"] {
            _ := g.AddCheckbox(i == 1 ? "xs+20 yp+" uicText.yp : "yp", i18n("position." v))
            key := "borderShowOnMaximized" v
            _.Value := var.%key%
            _.OnEvent("Click", e_change.Bind(key))
            ctrlList.Push(_)
        }
        renderGroupBox(g, "borderShowOnFullscreen", , "h" uicText.h " w" bw)
        for i, v in ["Top", "Bottom", "Left", "Right"] {
            _ := g.AddCheckbox(i == 1 ? "xs+20 yp+" uicText.yp : "yp", i18n("position." v))
            key := "borderShowOnFullscreen" v
            _.Value := var.%key%
            _.OnEvent("Click", e_change.Bind(key))
            ctrlList.Push(_)
        }

        for i, v in ["Pinned", stateList*] {
            if (Mod(i - 1, 4) == 0) {
                tab.UseTab(((i - 1) // 3) + 3)
                opt := "Section"
                g.AddText("cGray", i18n("borderWidth.tip"))
            } else {
                opt := "xs"
            }
            renderGroupBox(g, v, opt, "h" uicText.h " w" bw)
            _ := renderEditLabel(g, "borderWidth" v, "yp Number Limit2 w" bw / 6, "borderWidth")
            ctrlList.Push(_.edit)
            _ := renderColorPicker(g, "borderColor" v, "borderColor", "yp")
            ctrlList.Push(_.picker)
        }

        if !var.borderActive
            disableCtrl(ctrlList)
        return g
    }
}

var._lastBorderHwnd := 0

showBorder(finalColor, finalWidth, hwnd) {
    if var._lastBorderHwnd && var._lastBorderHwnd != hwnd {
        if WinExist(var._lastBorderHwnd) {
            try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", var._lastBorderHwnd, "UInt", 34, "Ptr*", -1, "UInt", 4)
            try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", var._lastBorderHwnd, "UInt", 37, "Ptr*", -1, "UInt", 4)
        }
    }
    var._lastBorderHwnd := hwnd

    scr := isWhichScreen(hwnd)

    if isFullscreen(hwnd) {
        hideBorder()

        SL := scr.left
        ST := scr.top
        SR := scr.right
        SB := scr.bottom

        t := finalWidth
        W := SR - SL
        H := SB - ST

        rawConfigs := [{ side: "Top", x: SL, y: ST, w: W, h: t }, ;
            { side: "Bottom", x: SL, y: SB - t, w: W, h: t }, ;
            { side: "Left", x: SL, y: ST + t, w: t, h: H - (2 * t) }, ;
            { side: "Right", x: SR - t, y: ST + t, w: t, h: H - (2 * t) } ;
        ]

        borderConfigs := []
        for cfg in rawConfigs
            var.%"borderShowOnFullscreen" cfg.side% ? borderConfigs.Push(cfg) : ""

        for cfg in borderConfigs {
            box := Gui("-Caption AlwaysOnTop ToolWindow E0x20 -DPIScale")
            box.BackColor := finalColor
            box.Show("W1 H1 NoActivate")
            DllCall("SetWindowPos", "Ptr", box.Hwnd, "Ptr", -1, "Int", cfg.x, "Int", cfg.y, "Int", cfg.w, "Int", cfg.h, "UInt", 0x10 | 0x40)
            var.maximizedBorders.Push(box)
        }
    }
    else if WinGetMinMax(hwnd) == 1 {
        hideBorder()

        if !scr
            return

        WL := scr.workLeft
        WT := scr.workTop
        WR := scr.workRight
        WB := scr.workBottom

        t := finalWidth
        W := WR - WL
        H := WB - WT

        rawConfigs := [{ side: "Top", x: WL, y: WT, w: W, h: t }, ;
            { side: "Bottom", x: WL, y: WB - t, w: W, h: t }, ;
            { side: "Left", x: WL, y: WT + t, w: t, h: H - (2 * t) }, ;
            { side: "Right", x: WR - t, y: WT + t, w: t, h: H - (2 * t) } ;
        ]
        borderConfigs := []
        for cfg in rawConfigs
            var.%"borderShowOnMaximized" cfg.side% ? borderConfigs.Push(cfg) : ""

        for cfg in borderConfigs {
            box := Gui("-Caption AlwaysOnTop ToolWindow E0x20 -DPIScale")
            box.BackColor := finalColor
            box.Show("W1 H1 NoActivate")
            DllCall("SetWindowPos", "Ptr", box.Hwnd, "Ptr", -1, "Int", cfg.x, "Int", cfg.y, "Int", cfg.w, "Int", cfg.h, "UInt", 0x10 | 0x40)
            var.maximizedBorders.Push(box)
        }
    }
    else {
        hideBorder()
        try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 34, "Ptr*", RGBtoBGR(finalColor), "UInt", 4)
        try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "UInt", 37, "Ptr*", finalWidth, "UInt", 4)
    }
}


hideBorder(hwnd := 0) {
    if var.HasProp("maximizedBorders") && var.maximizedBorders.Length > 0 {
        for box in var.maximizedBorders
            try box.Hide()
        while var.maximizedBorders.Length > 0 {
            box := var.maximizedBorders.Pop()
            try box.Destroy()
        }
    }
    targetHwnd := hwnd ? hwnd : var._lastBorderHwnd
    if targetHwnd && WinExist(targetHwnd) {
        try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", targetHwnd, "UInt", 34, "Ptr*", -1, "UInt", 4)
        try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", targetHwnd, "UInt", 37, "Ptr*", -1, "UInt", 4)
    }
    var.maximizedBorders := []
    global lastBorderState := ""
}
