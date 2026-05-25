; InputTip

updateSymbol()

updateSymbol() {
    symbolGui(title, info) {
        return createGuiOpt(title, , "-Caption AlwaysOnTop ToolWindow LastFound E0x20", , 0)
    }
    switch var.symbolType {
        case 1:
            for state in var.stateList {
                key := "symbolPictureGui" state
                w := var.%"symbolPictureWidth" state%
                h := var.%"symbolPictureHeight" state%
                path := var.%"symbolPicturePath" state%
                if (defaultSymbolMap.Has(path)) {
                    path := defaultSymbolDir "\" path
                } else {
                    path := symbolDir "\" path
                }
                if (path) {
                    var.%key% := _ := createUniqueGui(symbolGui.Bind(key))
                    _.BackColor := "010101"
                    WinSetTransColor("010101", _.Hwnd)
                    try _.AddPicture("w" w " h" h, path)
                } else {
                    try var.%key%.Destroy()
                }
            }
        case 2:
            for state in var.stateList {
                key := "symbolShapeGui" state
                color := var.%"symbolShapeColor" state%
                if (color) {
                    var.%key% := _ := createUniqueGui(symbolGui.Bind(key), var.symbolShapeCornerPreference)
                    try _.BackColor := color
                    _.Opt("-LastFound")
                    switch var.symbolShapeEdgeStyle {
                        case 1: _.Opt("-LastFound +e0x00000001")
                        case 2: _.Opt("-LastFound +e0x00000200")
                        case 3: _.Opt("-LastFound +e0x00020000")
                        default: _.Opt("-LastFound")
                    }
                } else {
                    try var.%key%.Destroy()
                }
            }
        case 3:
            for state in var.stateList {
                key := "symbolTextGui" state
                text := var.%"symbolTextContent" state%
                textFont := var.symbolTextFont
                textSize := var.%"symbolTextSize" state%
                textWeight := var.symbolTextWeight
                textColor := var.%"symbolTextColor" state%
                bgColor := var.%"symbolTextBgColor" state%
                if (text) {
                    var.%key% := _ := createUniqueGui(symbolGui.Bind(key), var.symbolTextCornerPreference)
                    _.MarginX := 0, _.MarginY := 0
                    try {
                        _.SetFont("s" textSize " c" textColor " w" textWeight, textFont)
                        _.BackColor := bgColor
                    }
                    _.AddText(, text)
                    switch var.symbolTextEdgeStyle {
                        case 1: _.Opt("-LastFound +e0x00000001")
                        case 2: _.Opt("-LastFound +e0x00000200")
                        case 3: _.Opt("-LastFound +e0x00020000")
                        default: _.Opt("-LastFound")
                    }
                } else {
                    try var.%key%.Destroy()
                }
            }
    }
}

ShowSymbolEx(state) {
    static windowNeedShow := 0
    global canShowSymbol, lastWindow

    if (delayState.needHide) {
        return
    }

    if (hasWindowChange) {
        lastWindow := exeName ":" exeTitle
        windowNeedShow := needShow
    }

    if (windowNeedShow) {
        select := showBesideCursor(exeName, exeTitle)

        if (select) {
            try {
                MouseGetPos(&left, &top)
                canShowSymbol := 1
                showSymbol(state, left, top, left, top, 1)
            } catch {
                hideSymbol()
            }
            return
        }
        try {
            canShowSymbol := returnCanShowSymbol(&left, &top, &right, &bottom)
            WinGetPos(&x, &y, &w, &h, "A")
            if (top < y || top > y + h) {
                hideSymbol()
                return
            }
            showSymbol(state, left, top, right, bottom)
        } catch {
            hideSymbol()
        }
    }
}

showSymbol(state, left, top, right, bottom, nearCursor := 0) {
    global lastSymbol
    static old_left := 0, old_top := 0

    if (!var.symbolType || !canShowSymbol) {
        hideSymbol()
        return
    }

    if (!nearCursor) {
        if (left == old_left && top == old_top) {
            if (state == lastSymbol) {
                return
            }
        }
    }

    old_top := top
    old_left := left

    cursorDeltaX := 0
    cursorDeltaY := 0

    if (nearCursor) {
        offsetY := top
        cursorDeltaX := var.symbolNearCursorOffsetX
        cursorDeltaY := var.symbolNearCursorOffsetY
    } else if (var.modeList.JAB.Has(exeName)) {
        offsetY := top + bottom
    } else {
        offsetY := var.symbolOffsetBaseY == "below" ? bottom : top
    }

    hideSymbol(0)
    switch var.symbolType {
        case 1:
            x := var.%"symbolPictureOffsetX" state% +cursorDeltaX
            y := var.%"symbolPictureOffsetY" state% +cursorDeltaY
            showGui(var.%"symbolPictureGui" state%, "NA AutoSize x" left + x " y" y + offsetY, 0, 1)
        case 2:
            x := var.%"symbolShapeOffsetX" state% +cursorDeltaX
            y := var.%"symbolShapeOffsetY" state% +cursorDeltaY
            w := var.%"symbolShapeWidth" state%
            h := var.%"symbolShapeHeight" state%
            showGui(var.%"symbolShapeGui" state%, "NA w" w " h" h " x" left + x " y" y + offsetY, 0, 1, var.%'symbolShapeTransparent' state%)
        case 3:
            x := var.%"symbolTextOffsetX" state% +cursorDeltaX
            y := var.%"symbolTextOffsetY" state% +cursorDeltaY
            showGui(var.%"symbolTextGui" state%, "NA AutoSize x" left + x " y" y + offsetY, 0, 1, var.symbolTextTransparent)
    }

    lastSymbol := state
}

reloadSymbol() {
    if (var.symbolType) {
        canShowSymbol := returnCanShowSymbol(&left, &top, &right, &bottom)
        type := IME.GetInputModeText()
        if (type && canShowSymbol) {
            showSymbol(type, left, top, right, bottom)
        }
    }
}

hideSymbol(all := 1) {
    for type in ["Picture", "Shape", "Text"] {
        for v in var.stateList {
            if (all || currentState != v) {
                try var.%"symbol" type "Gui" v%.Hide()
            }
        }
    }
    global lastSymbol := ""
}

getSymbolPicturePath() {
    symbolPicList := []
    for state in var.stateList {
        symbolPicList.Push("default-triangle-" var.stateVal.%state%.colorText ".png")
    }
    return getPicList(symbolDir, symbolPicList)
}

e_symbol(*) {
    showGui(createUniqueGui(symbolStyleGui))
    symbolStyleGui(info) {
        g := createGuiOpt(i18n("symbol"))
        tab := renderTab(g, [i18n("basicConfig"), i18n("symbolNearCursor")])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/symbol"))

        if (info.i) {
            g.AddText(, line80)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        g.AddText("yp w20")
        gc.previewSymbol := g.AddEdit("yp cGray", i18n("symbol.preview"))

        renderRadioGroup(g, "symbolType", [
            ["none", 0, ""],
            [".picture", 1],
            [".shape", 2],
            [".text", 3]
        ])

        _w := bw / 3 - g.MarginX / 2.5
        g.AddButton("xs w" _w, i18n("symbolPicture")).OnEvent("Click", symbolPictureConfig)
        g.AddButton("yp w" _w, i18n("symbolShape")).OnEvent("Click", symbolShapeConfig)
        g.AddButton("yp w" _w, i18n("symbolText")).OnEvent("Click", symbolTextConfig)

        renderRadioGroup(g, "symbolOffsetBaseY", [[".above", "above"], [".below", "below"]])

        renderRadioGroup(g, "symbolJABActive", [["yes", 1], ["no", 0]])
        g.AddLink("yp", getHelpLink("tip/symbol/use-inputtip-in-jetbrains"))

        renderEditGroup(g, "symbolHideDelay", "Number Limit5")

        _w := bw / 4 - g.MarginX / 2.5
        g.AddButton("xs w" _w, i18n("symbol.white/blacklist")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("symbol.white/blacklist"),
                [
                    i18n("symbol.whitelist"),
                    i18n("symbol.blacklist"),
                ],
                getDocsLink("tip/symbol/list-mechanism"),
                [
                    "Window.Symbol.Show",
                    "Window.Symbol.Hide"
                ]
            )
        )
        g.AddButton("yp w" _w, i18n("symbolScreenOffset")).OnEvent("Click", e_screenOffset)
        g.AddButton("yp w" _w, i18n("symbolWindowOffset")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("symbolWindowOffset"),
                [
                    i18n("windowRule")
                ],
                getDocsLink("tip/symbol/window-offset"),
                [
                    "Window.Symbol.Offset"
                ], Map(
                    "exe", { config: 1, gui: 1 },
                    "range", { config: 2, gui: 2 },
                    "mode", { config: 3, gui: 3 },
                    "offset", { config: 4, gui: 5 },
                    "title", { config: 5, gui: 4 },
                    "time", { config: 6, gui: 6 },
                )
            )
        )
        g.AddButton("yp w" _w, i18n("symbolCursorCapture")).OnEvent("Click", (*) =>
            createProcessMenuGui(
                i18n("symbolCursorCapture"),
                [
                    i18n("windowRule")
                ],
                getDocsLink("tip/symbol/cursor-capture-mode"),
                [
                    "Window.Symbol.CursorCapture"
                ], Map(
                    "exe", { config: 1, gui: 1 },
                    "capture", { config: 2, gui: 2 },
                    "time", { config: 3, gui: 3 },
                )
            )
        )

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("tip/symbol/show-it-near-cursor"))

        renderRadioGroup(g, "symbolNearCursorActive", [["yes", 1], ["no", 0]])
        renderRadioGroup(g, "symbolNearCursorWindow", [[".specify", "specify"], [".all", "all"]])
        renderEditGroup(g, "symbolNearCursorOffsetX", "")
        renderEditGroup(g, "symbolNearCursorOffsetY", "")

        g.AddButton("xs w" bw, i18n("symbolNearCursor.window")).OnEvent("Click", set_app_list)
        set_app_list(*) {
            createProcessMenuGui(
                i18n("symbolNearCursor.window"),
                [
                    i18n("windowRule")
                ],
                getDocsLink("tip/symbol/show-it-near-cursor"),
                [
                    "Window.Symbol.NearCursor"
                ]
            )
        }
        return g
    }
}

symbolPictureConfig(*) {
    showGui(createUniqueGui(symbolStyleGui))
    symbolStyleGui(info) {
        g := createGuiOpt(i18n("symbolPicture"))
        tab := renderTab(g, [i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/symbol/picture"))

        if (info.i) {
            g.AddText(, line80)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        g.AddText("yp w20")
        gc.previewSymbolPicture := g.AddEdit("yp cGray", i18n("symbol.preview"))

        picList := getSymbolPicturePath()
        picList.InsertAt(1, "")

        editOpt := " w" bw / 8

        for i, state in var.stateList {
            if (i == 4) {
                addBtn()
                tab.UseTab(2)
                g.AddLink("Section", getDocsLink("tip/symbol/picture"))
            }
            renderGroupBox(g, "state." state, "xs", "h120 w" bw)
            renderEditLabel(g, "symbolPictureOffsetX" state, editOpt, "symbolPictureOffsetX")
            renderEditLabel(g, "symbolPictureOffsetY" state, editOpt, "symbolPictureOffsetY", "yp")
            renderEditLabel(g, "symbolPictureWidth" state, "Number Limit3" editOpt, "symbolPictureWidth", "yp")
            renderEditLabel(g, "symbolPictureHeight" state, "Number Limit3" editOpt, "symbolPictureHeight", "yp")

            _ := g.AddDropDownList("xs+20 yp+40 AltSubmit r9 w" bw - 40, picList)
            key := "symbolPicturePath" state
            _.key := key
            try _.Text := var.%key%
            _.OnEvent("Change", (ctrl, *) => changeConfig(ctrl.key, ctrl.Text, , (*) => gc.previewSymbolPicture.Focus()))

            if (i > 4) {
                addBtn()
            }
        }
        addBtn() {
            _w := bw / 2 - g.MarginX / 4
            g.AddButton("xs w" _w, i18n("symbolPicture.open")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data\symbol"))
            g.AddButton("yp w" _w, i18n("symbolPicture.download")).OnEvent("Click", (*) => Run("https://inputtip.abgox.com/download/extra"))
        }

        return g
    }
}

symbolShapeConfig(*) {
    showGui(createUniqueGui(symbolStyleGui))
    symbolStyleGui(info) {
        g := createGuiOpt(i18n("symbolShape"))
        tab := renderTab(g, [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/symbol/shape"))


        if (info.i) {
            g.AddText(, line70)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        g.AddText("yp w20")
        gc.previewSymbolShape := g.AddEdit("yp cGray", i18n("symbol.preview"))

        renderRadioGroupList(g, [
            ["symbolShapeCornerPreference",
                [
                    ["none", 0],
                    ["cornerPreference.sharp", 1],
                    ["cornerPreference.round", 2],
                    ["cornerPreference.roundSmall", 3]
                ]
            ],
            ["symbolShapeEdgeStyle",
                [
                    ["none", 0],
                    ["edgeStyle.modal", 1],
                    ["edgeStyle.client", 2],
                    ["edgeStyle.static", 3]
                ]
            ]
        ])

        editOpt := " w" bw / 6

        for i, state in var.stateList {
            if (Mod(i - 1, 3) == 0) {
                tab.UseTab(((i - 1) // 3) + 2)
                g.AddLink("Section", getDocsLink("tip/symbol/shape"))
            }
            g.SetFont("Bold")
            g.AddGroupBox("xs h130 w" bw, i18n("state." state))
            g.SetFont("Norm")

            renderEditLabel(g, "symbolShapeOffsetX" state, editOpt, "symbolShapeOffsetX")
            renderEditLabel(g, "symbolShapeWidth" state, "Number Limit3" editOpt, "symbolShapeWidth", "yp")
            renderColorPicker(g, "symbolShapeColor" state, "symbolShapeColor")
            renderEditLabel(g, "symbolShapeOffsetY" state, editOpt, "symbolShapeOffsetY", "xs+20 yp+35")
            renderEditLabel(g, "symbolShapeHeight" state, "Number Limit3" editOpt, "symbolShapeHeight", "yp")
            renderEditLabel(g, "symbolShapeTransparent" state, "Number Limit3" editOpt, "symbolShapeTransparent", "yp")
        }

        return g
    }
}

symbolTextConfig(*) {
    showGui(createUniqueGui(symbolStyleGui))
    symbolStyleGui(info) {
        g := createGuiOpt(i18n("symbolText"))
        tab := renderTab(g, [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/symbol/text"))

        if (info.i) {
            g.AddText(, line70)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        g.AddText("yp w20")
        gc.previewSymbolText := g.AddEdit("yp cGray", i18n("symbol.preview"))

        renderDropDownListGroup(g, "symbolTextFont", fontList)

        renderEditGroup(g, "symbolTextWeight", "Number Limit3")
        renderEditGroup(g, "symbolTextTransparent", "Number Limit3")

        renderRadioGroupList(g, [
            ["symbolTextCornerPreference",
                [
                    ["none", 0],
                    ["cornerPreference.sharp", 1],
                    ["cornerPreference.round", 2],
                    ["cornerPreference.roundSmall", 3]
                ]
            ],
            ["symbolTextEdgeStyle",
                [
                    ["none", 0],
                    ["edgeStyle.modal", 1],
                    ["edgeStyle.client", 2],
                    ["edgeStyle.static", 3]
                ]
            ]
        ])

        editOpt := " w" bw / 6

        for i, state in var.stateList {
            if (Mod(i - 1, 3) == 0) {
                tab.UseTab(((i - 1) // 3) + 2)
                g.AddLink("Section", getDocsLink("tip/symbol/shape"))
            }
            g.SetFont("Bold")
            g.AddGroupBox("xs h130 w" bw, i18n("state." state))
            g.SetFont("Norm")

            renderEditLabel(g, "symbolTextContent" state, editOpt, "symbolTextContent")
            renderEditLabel(g, "symbolTextOffsetX" state, editOpt, "symbolTextOffsetX", "yp")
            renderColorPicker(g, "symbolTextColor" state, "symbolTextColor")
            renderEditLabel(g, "symbolTextSize" state, "Number Limit2" editOpt, "symbolTextSize", "xs+20 yp+35")
            renderEditLabel(g, "symbolTextOffsetY" state, editOpt, "symbolTextOffsetY", "yp")
            renderColorPicker(g, "symbolTextBgColor" state, "symbolTextBgColor")
        }

        return g
    }
}

e_screenOffset(*) {
    showGui(createUniqueGui(offsetScreenGui))
    offsetScreenGui(info) {
        g := createGuiOpt(i18n("symbolScreenOffset"))

        g.AddLink("Section", getDocsLink("tip/symbol/screen-offset"))
        pages := []
        for v in var.screenList {
            pages.push(i18n("offset.screen") " " v.num)
        }
        tab := renderTab(g, pages)

        for v in var.screenList {
            tab.UseTab(v.num)
            g.AddText("Section", i18n("offset.coordinate") "(X,Y): " i18n("offset.topLeft") "(" v.left ", " v.top "), " i18n("offset.bottomRight") "(" v.right ", " v.bottom ")")

            try {
                x := screenSymbolOffset.%v.num%.x
                y := screenSymbolOffset.%v.num%.y
            } catch {
                screenSymbolOffset.%v.num% := { x: 0, y: 0 }
                x := 0, y := 0
            }

            g.SetFont("Bold")
            g.AddText("xs", i18n("offset.offset_x"))
            g.SetFont("Norm")
            _ := g.AddEdit("yp")
            _.Value := x
            _.OnEvent("Change", e_changeOffset.Bind(v.num, "x"))
            _.OnEvent("LoseFocus", e_changeOffset.Bind(v.num, "x"))

            if (info.i) {
                return g
            }

            g.SetFont("Bold")
            g.AddText("xs", i18n("offset.offset_y"))
            g.SetFont("Norm")
            _ := g.AddEdit("yp")
            _.Value := y
            _.OnEvent("Change", e_changeOffset.Bind(v.num, "y"))
            _.OnEvent("LoseFocus", e_changeOffset.Bind(v.num, "y"))
            e_changeOffset(num, pos, item, *) {
                if (item.value == "") {
                    item.value := 0
                }

                value := returnNumber(item.value)
                if (pos == "x") {
                    val := value "/" screenSymbolOffset.%num%.y
                } else {
                    val := screenSymbolOffset.%num%.x "/" value
                }

                writeIniDebounced(num, val, (*) => (
                    updateScreenOffset(),
                    reloadSymbol(),
                    restartJAB()
                ), "Screen.Symbol.Offset")
            }
        }

        return g
    }
}
