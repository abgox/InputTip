; InputTip

updateOverlay()

hideOverlay() {
    for v in stateList {
        i := var.screenNum
        while i > 0 {
            try var.%"overlayGui" v i%.Hide()
            i--
        }
    }
}

showOverlay(state) {
    hideOverlay()

    if var.%"overlayText" state% == ""
        return

    Ypos := var.%"overlayOffsetY" state%
    Xpos := var.%"overlayOffsetX" state%
    basePosition := var.%"overlayBasePosition" state%

    win := getWinPhysicalRect()
    WinX := win.x, WinY := win.y, WinW := win.w, WinH := win.h

    overlayAnimation := ""
    switch var.overlayAnimation {
        case 1: overlayAnimation := "fade"
        case 2: overlayAnimation := "slideOverlay"
    }
    num := isWhichScreen().num

    try {
        i := var.screenNum
        while i > 0 {
            g := var.%"overlayGui" state i%
            screen := var.screenList[i]

            if var.overlayOnlyFocusScreen && num != screen.num {
                i--
                continue
            }

            scale := screen.scale
            scaledW := g.w
            scaledH := g.h
            scaledXpos := toPhysical(Xpos, scale)
            scaledYpos := toPhysical(Ypos, scale)

            showOnWindow := 0

            if showOnWindow := InStr(basePosition, "Window") {
                Left := 0, Top := 0, Right := 0, Bottom := 0
                WALeft := 0, WATop := 0, WARight := 0, WABottom := 0
            } else {
                Left := screen.left
                Top := screen.top
                Right := screen.right
                Bottom := screen.bottom
                WALeft := screen.workLeft
                WATop := screen.workTop
                WARight := screen.workRight
                WABottom := screen.workBottom
            }
            switch basePosition {
                case "top":
                    x := Left + (Right - Left) / 2 - scaledW / 2
                    y := Top
                case "bottom":
                    x := Left + (Right - Left) / 2 - scaledW / 2
                    y := Bottom - scaledH
                case "left":
                    x := Left
                    y := Top + (Bottom - Top) / 2 - scaledH / 2
                case "right":
                    x := Right - scaledW
                    y := Top + (Bottom - Top) / 2 - scaledH / 2
                case "topLeft":
                    x := Left
                    y := Top
                case "topRight":
                    x := Right - scaledW
                    y := Top
                case "bottomLeft":
                    x := Left
                    y := Bottom - scaledH
                case "bottomRight":
                    x := Right - scaledW
                    y := Bottom - scaledH
                case "bottomWorkArea":
                    x := WALeft + (WARight - WALeft) / 2 - scaledW / 2
                    y := WABottom - scaledH
                case "bottomLeftWorkArea":
                    x := WALeft
                    y := WABottom - scaledH
                case "bottomRightWorkArea":
                    x := WARight - scaledW
                    y := WABottom - scaledH
                case "topWindow":
                    x := WinX + WinW / 2 - scaledW / 2
                    y := WinY
                case "bottomWindow":
                    x := WinX + WinW / 2 - scaledW / 2
                    y := WinY + WinH - scaledH
                case "leftWindow":
                    x := WinX
                    y := WinY + WinH / 2 - scaledH / 2
                case "rightWindow":
                    x := WinX + WinW - scaledW
                    y := WinY + WinH / 2 - scaledH / 2
                case "topLeftWindow":
                    x := WinX
                    y := WinY
                case "topRightWindow":
                    x := WinX + WinW - scaledW
                    y := WinY
                case "bottomLeftWindow":
                    x := WinX
                    y := WinY + WinH - scaledH
                case "bottomRightWindow":
                    x := WinX + WinW - scaledW
                    y := WinY + WinH - scaledH
                case "centerWindow":
                    x := WinX + WinW / 2 - scaledW / 2
                    y := WinY + WinH / 2 - scaledH / 2
                default: ; center
                    x := Left + (Right - Left) / 2 - scaledW / 2
                    y := Top + (Bottom - Top) / 2 - scaledH / 2
            }
            showGui(g, "AutoSize NA", overlayAnimation, 1, var.%"overlayTransparent" state%)
            setGuiPhysicalPos(g.Hwnd, x + scaledXpos, y + scaledYpos)

            if showOnWindow
                break
            i--
        }
    }

    SetTimer(RemoveTip, -returnMaxTimerNumber(var.overlayHideDelay))
    RemoveTip() {
        try hideOverlay()
    }
}

updateOverlay() {
    for state in stateList {
        text := var.%"overlayText" state%
        textFont := var.%"overlayTextFont" state%
        textSize := var.%"overlayTextSize" state%
        textWeight := var.%"overlayTextWeight" state%
        textColor := var.%"overlayTextColor" state%
        bgColor := var.%"overlayBgColor" state%

        i := var.screenNum
        while i > 0 {
            var.%"overlayGui" state i% := createUniqueGui(tipGui.Bind(state, i), var.overlayCornerPreference)
            tipGui(state, num, info) {
                g := createGuiOpt("overlayGui" state num, , "-Caption AlwaysOnTop ToolWindow E0x20", , 0)
                g.MarginX := "5", g.MarginY := "5"
                try {
                    g.SetFont("s" textSize " c" textColor " w" textWeight " q5", textFont)
                    g.BackColor := bgColor
                    g.AddText("c" textColor, text)
                }
                if info.i
                    return g

                switch var.overlayEdgeStyle {
                    case 1: g.Opt("e0x00000001")
                    case 2: g.Opt("e0x00000200")
                    case 3: g.Opt("e0x00020000")
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

        if info.i {
            g.AddText(, isChinese ? line80 : line90)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        ctrlList := []

        tab := renderTab(g, [i18n("basicConfig"), i18n("basicConfig") 2, i18n("stateStyle"), i18n("stateStyle") 2, i18n("stateStyle") 3])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/overlay"))
        renderRadioGroup(g, "overlayActive", [
            ["yes", 1, (key, value, *) => (changeConfig(key, value), disableCtrl(ctrlList, 0))],
            ["no", 0, (key, value, *) => (changeConfig(key, value), disableCtrl(ctrlList))]
        ])

        _ := renderRadioGroup(g, "overlayOnlyFocusScreen", [["yes", 1], ["no", 0]])
        ctrlList.Push(_.radios*)

        renderBoldText(g, "overlayHideDelay")
        ctrlList.Push(renderEdit(g, "overlayHideDelay", "Number Limit8"))

        _ := renderRadioGroup(g, "overlayShowMode",
            [
                ["blacklist", "blacklist"],
                ["whitelist", "whitelist"]
            ])
        ctrlList.Push(_.radios*)
        _w := bw / 2 - g.MarginX / 4
        for v in [
            ["hide", "xs", "blacklistBtn"],
            ["show", "yp", "whitelistBtn"],
        ] {
            _ := g.AddButton(v[2] " w" _w, i18n(v[3]))
            _.OnEvent("Click",
                createProcessMenuGui.Bind({
                    title: i18n("overlay") " - " i18n(v[3]),
                    tab: [i18n(v[3])],
                    trigger: [v[1]],
                    link: getDocsLink("tip/overlay/list-mechanism"),
                    section: "Window.Overlay.Rule",
                    cols: ["process", "condition", "class", "title"],
                    conditions: conditionKeyList
                })
            )
            ctrlList.Push(_)
        }

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("tip/overlay"))

        renderBoldText(g, "overlayReshowOnChange")
        g.AddCheckbox("xs Disabled", i18n("overlayReshowOnChange.state")).Value := 1
        for v in ["Process", "Title", "Class"] {
            _ := g.AddCheckbox("yp", i18n("overlayReshowOnChange." StrLower(v)))
            key := "overlayReshowOn" v "Change"
            _.Value := var.%key%
            _.OnEvent("Click", e_change.Bind(key))
            ctrlList.Push(_)
        }
        e_change(key, ctrl, *) {
            val := ctrl.Value
            var.%key% := val
            writeIni(key, val)
        }
        renderBoldText(g, "showOnWindowState")
        for i, v in ["Normal", "Maximized", "Fullscreen"] {
            _ := g.AddCheckbox(i == 1 ? "xs" : "yp", i18n("showOnWindowState." StrLower(v)))
            key := "overlayShowOn" v
            _.Value := var.%key%
            _.OnEvent("Click", e_change.Bind(key))
            ctrlList.Push(_)
        }

        _ := renderRadioGroup(g, "overlayAnimation",
            [
                ["none", 0],
                ["animation.fade", 1],
                ["animation.slide", 2],
            ])
        ctrlList.Push(_.radios*)
        _ := renderRadioGroup(g, "overlayCornerPreference",
            [
                ["none", 0],
                ["cornerPreference.sharp", 1],
                ["cornerPreference.round", 2],
                ["cornerPreference.roundSmall", 3]
            ])
        ctrlList.Push(_.radios*)
        _ := renderRadioGroup(g, "overlayEdgeStyle",
            [
                ["none", 0],
                ["edgeStyle.modal", 1],
                ["edgeStyle.client", 2],
                ["edgeStyle.static", 3]
            ])
        ctrlList.Push(_.radios*)

        posTextMap := Map()  ; text -> value
        posValueMap := Map() ; value -> text
        posList := [
            "topWindow", "bottomWindow", "leftWindow", "rightWindow", "centerWindow", "topLeftWindow", "topRightWindow", "bottomLeftWindow", "bottomRightWindow",
            "top", "bottom", "left", "right", "center", "topLeft", "topRight", "bottomLeft", "bottomRight",
            "bottomWorkArea", "bottomLeftWorkArea", "bottomRightWorkArea"
        ]
        for i, v in posList {
            text := i18n("overlayBasePosition." v)
            posTextMap.Set(text, v)
            posValueMap.Set(v, text)
            posList[i] := text
        }
        for i, v in stateList {
            if Mod(i - 1, 2) == 0 {
                tab.UseTab(((i - 1) // 2) + 3)
                opt := "Section"
            } else {
                opt := "xs"
            }

            renderBoldText(g, v, opt)
            _ := renderEditLabel(g, "overlayText" v, "w" bw / 3, "overlayText")
            ctrlList.Push(_.edit)
            _ := renderEditLabel(g, "overlayOffsetX" v, "Limit5 w" bw / 10, "overlayOffsetX", "yp")
            ctrlList.Push(_.edit)
            _ := renderColorPicker(g, "overlayTextColor" v, "overlayTextColor")
            ctrlList.Push(_.picker)

            renderText(g, "overlayBasePosition")
            _ := g.AddDropDownList("yp r9 w" bw / 3, posList)
            try _.Text := posValueMap.Get(var.%"overlayBasePosition" v%)
            _.state := v
            _.OnEvent("Change", (i, *) => changeConfig("overlayBasePosition" i.state, posTextMap.Get(i.Text), 1))
            ctrlList.Push(_)
            SuppressControlWheel(_.Hwnd)

            _ := renderEditLabel(g, "overlayOffsetY" v, "Limit5 w" bw / 10, "overlayOffsetY", "yp")
            ctrlList.Push(_.edit)
            _ := renderColorPicker(g, "overlayBgColor" v, "overlayBgColor")
            ctrlList.Push(_.picker)

            renderText(g, "overlayTextFont")
            ctrlList.Push(renderDDL(g, "overlayTextFont" v, fontList, "yp w" bw / 1.2))
            renderText(g, "overlayTextSize")
            ctrlList.Push(renderDDL(g, "overlayTextSize" v, var.nums_8_100, "yp w" bw / 6))
            renderText(g, "overlayTextWeight", "yp")
            ctrlList.Push(renderDDL(g, "overlayTextWeight" v, var.nums_100_900, "yp w" bw / 6))
            renderText(g, "overlayTransparent", "yp")
            ctrlList.Push(renderDDL(g, "overlayTransparent" v, var.nums_0_255, "yp w" bw / 6))
        }

        if !var.overlayActive
            disableCtrl(ctrlList)
        return g
    }
}
