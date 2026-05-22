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
    hideDelay := var.overlayHideDelay
    if (hideDelay == "") {
        hideDelay := 0
    }
    Ypos := var.%"overlayOffsetY" state%
    Xpos := var.%"overlayOffsetX" state%

    hideOverlay()

    i := var.screenNum
    while (i > 0) {
        g := var.%"overlayGui" state i%
        MonitorGet(i, &Left, &Top, &Right, &Bottom)
        hMonitor := DllCall("MonitorFromPoint", "Int64", (Left + Right) // 2 | ((Top + Bottom) // 2) << 32, "Int", 2, "Ptr")
        DllCall("Shcore\GetDpiForMonitor", "Ptr", hMonitor, "Int", 0, "UInt*", &dpiX := 0, "UInt*", &dpiY := 0)
        scale := dpiX / 96
        scaledW := g.w * scale
        scaledH := g.h * scale
        switch var.%"overlayBasePosition" currentState% {
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
            default: ; center
                x := Left + Abs(Right - Left) / 2 - scaledW / 2 + Xpos
                y := Top + Abs(Bottom - Top) / 2 - scaledH / 2 + Ypos
        }
        showGui(g, "AutoSize X" x " Y" y " NA", var.overlayAnimation, 1, var.%"overlayTransparent" state%)
        i--
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
        textSize := var.%"overlayTextSize" state%
        textWeight := var.%"overlayTextWeight" state%
        textColor := var.%"overlayTextColor" state%
        bgColor := var.%"overlayBgColor" state%

        i := var.screenNum
        while (i > 0) {
            var.%"overlayGui" state i% := createUniqueGui(tipGui.Bind(state, i), var.overlayCornerPreference)
            tipGui(state, num, info) {
                g := createGuiOpt("overlayGui" state num, , "-Caption AlwaysOnTop ToolWindow LastFound E0x20", , 0)
                g.SetFont("s" textSize " c" textColor " w" textWeight " q5", textFont)
                g.BackColor := bgColor, g.MarginX := "5", g.MarginY := "5"
                g.AddText("c" textColor, text)
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

        tab := g.AddTab3("-Wrap", [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/overlay"))

        renderRadioGroupList(g, [
            ["overlayActive",
                [
                    ["yes", 1],
                    ["no", 0]
                ]
            ],
            ["overlayCornerPreference",
                [
                    ["none", 0],
                    ["cornerPreference.sharp", 1],
                    ["cornerPreference.round", 2],
                    ["cornerPreference.roundSmall", 3]
                ]
            ],
            ["overlayEdgeStyle",
                [
                    ["none", 0],
                    ["edgeStyle.modal", 1],
                    ["edgeStyle.client", 2],
                    ["edgeStyle.static", 3]
                ]
            ],
            [
                "overlayAnimation",
                [
                    ["none", 0],
                    ["animation.fade", 1],
                    ["animation.slide", 2],
                    ["animation.scale", 3]
                ]
            ],
            ["overlayShowOnWindowChange",
                [
                    ["yes", 1],
                    ["no", 0]
                ]
            ]
        ])

        renderGroupBox(g, "overlayHideDelay", "xs h70 w" bw)
        renderEdit(g, "overlayHideDelay", "xs+20 yp+30 Number Limit5 w" bw - 40)

        renderFontGroup(g, "overlayTextFont")


        posTextMap := Map()  ; text -> value
        posValueMap := Map() ; value -> text
        posList := ["center", "top", "bottom", "left", "right", "topLeft", "topRight", "bottomLeft", "bottomRight"]
        for i, v in posList {
            text := i18n("overlayBasePosition." v)
            posTextMap.Set(text, v)
            posValueMap.Set(v, text)
            posList[i] := text
        }

        editOpt := " w" bw / 6

        for i, v in var.stateList {
            if (Mod(i - 1, 3) == 0) {
                tab.UseTab(((i - 1) // 3) + 2)
                g.AddLink("Section", getDocsLink("tip/overlay"))
            }

            g.SetFont("Bold")
            g.AddGroupBox("xs h160 w" bw, i18n("state." v))
            g.SetFont("Norm")

            renderText(g, "overlayText", "xs+20 yp+40")
            renderEdit(g, "overlayText" v, "yp" editOpt)

            renderText(g, "overlayOffsetX", "yp")
            renderEdit(g, "overlayOffsetX" v, "yp" editOpt)

            g.AddText("yp", i18n("overlayBasePosition"))
            _ := g.AddDropDownList("yp w" bw / 6, posList)
            try _.Text := posValueMap.Get(var.%"overlayBasePosition" v%)
            _.state := v
            _.OnEvent("Change", (i, *) => changeConfig("overlayBasePosition" i.state, posTextMap.Get(i.Text)))

            renderText(g, "overlayTextSize", "xs+20 yp+40")
            renderEdit(g, "overlayTextSize" v, "yp Number Limit2" editOpt)

            renderText(g, "overlayOffsetY", "yp")
            renderEdit(g, "overlayOffsetY" v, "yp" editOpt)

            renderColorPicker(g, "overlayTextColor", v)

            renderText(g, "overlayTextWeight", "xs+20 yp+40")
            renderEdit(g, "overlayTextWeight" v, "yp Number Limit3" editOpt)

            renderText(g, "overlayTransparent", "yp")
            renderEdit(g, "overlayTransparent" v, "yp Number Limit3" editOpt)

            renderColorPicker(g, "overlayBgColor", v)
        }
        return g
    }
}
