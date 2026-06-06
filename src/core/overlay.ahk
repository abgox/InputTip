; InputTip

updateOverlay()

hideOverlay() {
    for v in var.stateList {
        i := var.screenNum
        while (i > 0) {
            try var.%"overlayGui" v i%.Hide()
            i--
        }
    }
}

showOverlay(state) {
    hideOverlay()

    if var.%"overlayText" state% == ""
        return

    hideDelay := var.overlayHideDelay
    if (hideDelay == "") {
        hideDelay := 0
    }
    Ypos := var.%"overlayOffsetY" state%
    Xpos := var.%"overlayOffsetX" state%
    basePosition := var.%"overlayBasePosition" state%

    WinX := 0, WinY := 0, WinW := 0, WinH := 0
    try WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")

    try {
        i := var.screenNum
        while (i > 0) {
            g := var.%"overlayGui" state i%
            MonitorGet(i, &Left, &Top, &Right, &Bottom)
            MonitorGetWorkArea(i, &WALeft, &WATop, &WARight, &WABottom)
            pt := Buffer(8, 0)
            NumPut("Int", (Left + Right) // 2, pt, 0)
            NumPut("Int", (Top + Bottom) // 2, pt, 4)
            hMonitor := DllCall("MonitorFromPoint", "Ptr", pt, "Int", 2, "Ptr")
            DllCall("Shcore\GetDpiForMonitor", "Ptr", hMonitor, "Int", 0, "UInt*", &dpiX := 0, "UInt*", &dpiY := 0)
            scale := dpiX / 96
            scaledW := g.w * scale
            scaledH := g.h * scale
            switch basePosition {
                case "top":
                    x := Left + Abs(Right - Left) / 2 - scaledW / 2 + Xpos
                    y := Top + Ypos
                case "bottom":
                    x := Left + Abs(Right - Left) / 2 - scaledW / 2 + Xpos
                    y := Bottom - scaledH + Ypos
                case "left":
                    x := Left + Xpos
                    y := Top + Abs(Bottom - Top) / 2 - scaledH / 2 + Ypos
                case "right":
                    x := Right - scaledW + Xpos
                    y := Top + Abs(Bottom - Top) / 2 - scaledH / 2 + Ypos
                case "topLeft":
                    x := Left + Xpos
                    y := Top + Ypos
                case "topRight":
                    x := Right - scaledW + Xpos
                    y := Top + Ypos
                case "bottomLeft":
                    x := Left + Xpos
                    y := Bottom - scaledH + Ypos
                case "bottomRight":
                    x := Right - scaledW + Xpos
                    y := Bottom - scaledH + Ypos
                case "bottomWorkArea":
                    x := WALeft + Abs(WARight - WALeft) / 2 - scaledW / 2 + Xpos
                    y := WABottom - scaledH + Ypos
                case "bottomLeftWorkArea":
                    x := WALeft + Xpos
                    y := WABottom - scaledH + Ypos
                case "bottomRightWorkArea":
                    x := WARight - scaledW + Xpos
                    y := WABottom - scaledH + Ypos
                case "topWindow":
                    x := WinX + WinW / 2 - scaledW / 2 + Xpos
                    y := WinY + Ypos
                case "bottomWindow":
                    x := WinX + WinW / 2 - scaledW / 2 + Xpos
                    y := WinY + WinH - scaledH + Ypos
                case "leftWindow":
                    x := WinX + Xpos
                    y := WinY + WinH / 2 - scaledH / 2 + Ypos
                case "rightWindow":
                    x := WinX + WinW - scaledW + Xpos
                    y := WinY + WinH / 2 - scaledH / 2 + Ypos
                case "topLeftWindow":
                    x := WinX + Xpos
                    y := WinY + Ypos
                case "topRightWindow":
                    x := WinX + WinW - scaledW + Xpos
                    y := WinY + Ypos
                case "bottomLeftWindow":
                    x := WinX + Xpos
                    y := WinY + WinH - scaledH + Ypos
                case "bottomRightWindow":
                    x := WinX + WinW - scaledW + Xpos
                    y := WinY + WinH - scaledH + Ypos
                case "centerWindow":
                    x := WinX + WinW / 2 - scaledW / 2 + Xpos
                    y := WinY + WinH / 2 - scaledH / 2 + Ypos
                default: ; center
                    x := Left + Abs(Right - Left) / 2 - scaledW / 2 + Xpos
                    y := Top + Abs(Bottom - Top) / 2 - scaledH / 2 + Ypos
            }
            showGui(g, "AutoSize X" x " Y" y " NA", var.overlayAnimation, 1, var.overlayTransparent)
            i--
        }
    }

    SetTimer(RemoveTip, -hideDelay)
    RemoveTip() {
        try hideOverlay()
    }
}

updateOverlay() {
    for state in var.stateList {
        text := var.%"overlayText" state%
        textFont := var.overlayTextFont
        textSize := var.overlayTextSize
        textWeight := var.overlayTextWeight
        textColor := var.%"overlayTextColor" state%
        bgColor := var.%"overlayBgColor" state%

        i := var.screenNum
        while (i > 0) {
            var.%"overlayGui" state i% := createUniqueGui(tipGui.Bind(state, i), var.overlayCornerPreference)
            tipGui(state, num, info) {
                g := createGuiOpt("overlayGui" state num, , "-Caption AlwaysOnTop ToolWindow LastFound E0x20", , 0)
                g.MarginX := "5", g.MarginY := "5"
                try {
                    g.SetFont("s" textSize " c" textColor " w" textWeight " q5", textFont)
                    g.BackColor := bgColor
                    g.AddText("c" textColor, text)
                }
                if (info.i) {
                    return g
                }
                switch var.overlayEdgeStyle {
                    case 1: g.Opt("-LastFound +e0x00000001")
                    case 2: g.Opt("-LastFound +e0x00000200")
                    case 3: g.Opt("-LastFound +e0x00020000")
                    default: g.Opt("-LastFound")
                }
                g.w := info.w, g.h := info.h
                return g
            }
            i--
        }
    }
}

e_overlay(*) {
    showGui(createUniqueGui(overlayStyleGui, var.overlayCornerPreference))
    overlayStyleGui(info) {
        g := createGuiOpt(i18n("overlay"))

        if (info.i) {
            g.AddText(, line80)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        tab := renderTab(g, [i18n("basicConfig"), i18n("basicConfig") 2, i18n("basicConfig") 3, i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/overlay"))

        renderRadioGroup(g, "overlayActive",
            [
                ["yes", 1],
                ["no", 0]
            ])

        renderEditGroup(g, "overlayHideDelay", "Number Limit5")
        renderRadioGroup(g, "overlayShowOnProcessChange", [["yes", 1], ["no", 0]])
        renderRadioGroup(g, "overlayShowOnWindowChange", [["yes", 1], ["no", 0]])

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("tip/overlay"))
        renderRadioGroup(g, "overlayAnimation",
            [
                ["none", 0],
                ["animation.fade", 1],
                ["animation.slide", 2],
                ["animation.scale", 3]
            ])

        renderRadioGroup(g, "overlayCornerPreference",
            [
                ["none", 0],
                ["cornerPreference.sharp", 1],
                ["cornerPreference.round", 2],
                ["cornerPreference.roundSmall", 3]
            ])
        renderRadioGroup(g, "overlayEdgeStyle",
            [
                ["none", 0],
                ["edgeStyle.modal", 1],
                ["edgeStyle.client", 2],
                ["edgeStyle.static", 3]
            ])

        renderRadioGroup(g, "overlayShowMode",
            [
                ["overlayBlacklist", "blacklist"],
                ["overlayWhitelist", "whitelist"]
            ])

        _w := bw / 2 - g.MarginX / 4
        g.AddButton("xs w" _w, i18n("overlayBlacklistBtn")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("overlay") " - " i18n("overlayBlacklistBtn"),
                [
                    i18n("overlayBlacklistBtn"),
                ],
                getDocsLink("tip/overlay/list-mechanism"),
                [
                    "Window.Overlay.Hide"
                ]
            )
        )
        g.AddButton("yp w" _w, i18n("overlayWhitelistBtn")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("overlay") " - " i18n("overlayWhitelistBtn"),
                [
                    i18n("overlayWhitelistBtn"),
                ],
                getDocsLink("tip/overlay/list-mechanism"),
                [
                    "Window.Overlay.Show"
                ]
            )
        )

        tab.UseTab(3)
        g.AddLink("Section", getDocsLink("tip/overlay"))
        renderDropDownListGroup(g, "overlayTextFont", fontList)
        renderEditGroup(g, "overlayTextSize", "Number Limit2")
        renderEditGroup(g, "overlayTextWeight", "Number Limit3")
        renderEditGroup(g, "overlayTransparent", "Number Limit3")

        posTextMap := Map()  ; text -> value
        posValueMap := Map() ; value -> text
        posList := [
            "center", "top", "bottom", "left", "right", "topLeft", "topRight", "bottomLeft", "bottomRight",
            "centerWindow", "topWindow", "bottomWindow", "leftWindow", "rightWindow", "topLeftWindow", "topRightWindow", "bottomLeftWindow", "bottomRightWindow",
            "bottomWorkArea", "bottomLeftWorkArea", "bottomRightWorkArea"
        ]
        for i, v in posList {
            text := i18n("overlayBasePosition." v)
            posTextMap.Set(text, v)
            posValueMap.Set(v, text)
            posList[i] := text
        }
        for i, v in var.stateList {
            if (Mod(i - 1, 3) == 0) {
                tab.UseTab(((i - 1) // 3) + 4)
                g.AddLink("Section", getDocsLink("tip/overlay"))
            }

            g.SetFont("Bold")
            g.AddGroupBox("xs h120 w" bw, i18n("state." v))
            g.SetFont("Norm")

            renderEditLabel(g, "overlayText" v, "w" bw / 3, "overlayText")
            renderEditLabel(g, "overlayOffsetX" v, "w" bw / 8, "overlayOffsetX", "yp")
            renderColorPicker(g, "overlayTextColor" v, "overlayTextColor")

            g.AddText("xs+20 yp+40", i18n("overlayBasePosition"))
            _ := g.AddDropDownList("yp r9 w" bw / 3, posList)
            try _.Text := posValueMap.Get(var.%"overlayBasePosition" v%)
            _.state := v
            _.OnEvent("Change", (i, *) => changeConfig("overlayBasePosition" i.state, posTextMap.Get(i.Text), 1))

            renderEditLabel(g, "overlayOffsetY" v, "w" bw / 8, "overlayOffsetY", "yp")
            renderColorPicker(g, "overlayBgColor" v, "overlayBgColor")

        }
        return g
    }
}
