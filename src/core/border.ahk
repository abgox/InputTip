; InputTip

e_border(*) {
    showGui(createUniqueGui(borderStyleGui))
    borderStyleGui(info) {
        g := createGuiOpt(i18n("border"))

        if (info.i) {
            g.AddText(, isChinese ? line80 : line90)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        tab := renderTab(g, [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/border"))

        renderRadioGroup(g, "borderActive",
            [
                ["yes", 1],
                ["no", 0]
            ])

        renderEditGroup(g, "borderHideDelay", "Number Limit5")
        renderGroupBox(g, "borderReshowOnChange", , "h80 w" bw)
        g.AddCheckbox("xs+20 yp+40 Disabled", i18n("borderReshowOnChange.state")).Value := 1
        for v in ["Process", "Title", "Class"] {
            _ := g.AddCheckbox("yp", i18n("borderReshowOnChange." StrLower(v)))
            _.Value := var.%"borderReshowOn" v "Change"%
            _.OnEvent("Click", e_change.Bind(v))
        }
        e_change(type, ctrl, *) {
            key := "borderReshowOn" type "Change"
            val := ctrl.Value
            var.%key% := val
            writeIni(key, val)
        }

        renderRadioGroup(g, "borderShowMode",
            [
                ["blacklist", "blacklist"],
                ["whitelist", "whitelist"]
            ])
        _w := bw / 2 - g.MarginX / 4
        for v in [
            ["hide", "xs", "blacklistBtn"],
            ["show", "yp", "whitelistBtn"],
        ] {
            g.AddButton(v[2] " w" _w, i18n(v[3])).OnEvent("Click",
                createProcessMenuGui.Bind({
                    title: i18n("border") " - " i18n(v[3]),
                    tab: [i18n(v[3])],
                    trigger: [v[1]],
                    link: getDocsLink("tip/border/list-mechanism"),
                    section: "Window.Border.Rule",
                    cols: ["process", "condition", "class", "title"],
                    conditions: conditionKeyList
                })
            )
        }

        for i, v in ["Pinned", stateList*] {
            if (Mod(i - 1, 4) == 0) {
                tab.UseTab(((i - 1) // 3) + 2)
                g.AddLink("Section", getDocsLink("tip/border"))
            }

            renderGroupBox(g, v, , "h80 w" bw)

            ; renderEditLabel(g, "borderWidth" v, "w" bw / 3, "borderWidth")
            renderColorPicker(g, "borderColor" v, "borderColor", "xs+20 yp+35")
        }

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

    if (WinGetMinMax(hwnd) == 1) {
        hideBorder()
        var.maximizedBorders := []

        scr := isWhichScreen(hwnd)
        if !scr
            return

        WL := scr.workLeft
        WT := scr.workTop
        WR := scr.workRight
        WB := scr.workBottom

        ; t := finalWidth
        t := 2
        W := WR - WL
        H := WB - WT

        borderConfigs := [{ x: WL, y: WT, w: W, h: t }, ;
            { x: WL, y: WB - t, w: W, h: t }, ;
            { x: WL, y: WT + t, w: t, h: H - (2 * t) }, ;
            { x: WR - t, y: WT + t, w: t, h: H - (2 * t) }  ;
        ]

        for cfg in borderConfigs {
            box := Gui("-Caption AlwaysOnTop ToolWindow E0x20")
            box.BackColor := finalColor
            box.Show("W1 H1 NoActivate")
            SWP_NOACTIVATE := 0x10
            SWP_SHOWWINDOW := 0x40
            DllCall("SetWindowPos",
                "Ptr", box.Hwnd,
                "Ptr", -1,
                "Int", cfg.x,
                "Int", cfg.y,
                "Int", cfg.w,
                "Int", cfg.h,
                "UInt", SWP_NOACTIVATE | SWP_SHOWWINDOW)

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
        while (var.maximizedBorders.Length > 0) {
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
