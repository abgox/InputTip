; InputTip

updateSymbol("caret")
updateSymbol("cursor")

updateSymbol(prefix) {
    symbolGui(title, info) {
        return createGuiOpt(title, , "-Caption AlwaysOnTop ToolWindow E0x20", , 0)
    }
    switch var.%prefix "SymbolType"% {
        case 1:
            for state in stateList {
                key := prefix "SymbolPictureGui" state
                w := var.%prefix "SymbolPictureWidth" state%
                h := var.%prefix "SymbolPictureHeight" state%
                path := var.%prefix "SymbolPicturePath" state%
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
            for state in stateList {
                key := prefix "SymbolShapeGui" state
                color := var.%prefix "SymbolShapeColor" state%
                if (color) {
                    var.%key% := _ := createUniqueGui(symbolGui.Bind(key), var.%prefix "SymbolShapeCornerPreference"%)
                    try _.BackColor := color
                    switch var.%prefix "SymbolShapeEdgeStyle"% {
                        case 1: _.Opt("e0x00000001")
                        case 2: _.Opt("e0x00000200")
                        case 3: _.Opt("e0x00020000")
                    }
                } else {
                    try var.%key%.Destroy()
                }
            }
        case 3:
            for state in stateList {
                key := prefix "SymbolTextGui" state
                text := var.%prefix "SymbolTextContent" state%
                textFont := var.%prefix "SymbolTextFont" state%
                textSize := var.%prefix "SymbolTextSize" state%
                textWeight := var.%prefix "SymbolTextWeight" state%
                textColor := var.%prefix "SymbolTextColor" state%
                bgColor := var.%prefix "SymbolTextBgColor" state%
                if (text) {
                    var.%key% := _ := createUniqueGui(symbolGui.Bind(key), var.%prefix "SymbolTextCornerPreference"%)
                    _.MarginX := 0, _.MarginY := 0
                    try {
                        _.SetFont("s" textSize " c" textColor " w" textWeight, textFont)
                        _.BackColor := bgColor
                    }
                    _.AddText(, text)
                    switch var.%prefix "SymbolTextEdgeStyle"% {
                        case 1: _.Opt("e0x00000001")
                        case 2: _.Opt("e0x00000200")
                        case 3: _.Opt("e0x00020000")
                    }
                } else {
                    try var.%key%.Destroy()
                }
            }
    }
}

ShowCaretSymbolEx(state) {
    static windowNeedShow := 0

    if !var.caretSymbolType {
        hideCaretSymbol()
        return
    }

    if delayState.needHide
        return

    if hasTitleChange || hasClassChange || hasProcessChange
        windowNeedShow := needShow

    if !windowNeedShow
        return

    try {
        if !returnCanShowSymbol(&left, &top, &right, &bottom) {
            hideCaretSymbol()
            return
        }
        win := getWinPhysicalRect()
        if top < win.y || top > win.y + win.h {
            hideCaretSymbol()
            return
        }
        showCaretSymbol(state, left, top, right, bottom)
    } catch {
        hideCaretSymbol()
    }
}

showCaretSymbol(state, left, top, right, bottom) {
    global lastCaretSymbol
    static old_left := 0, old_top := 0

    if left == old_left && top == old_top {
        if state == lastCaretSymbol
            return
    }
    old_top := top
    old_left := left

    s := isWhichScreen()
    scale := s.scale

    if var.caretSymbolOriginY == "below"
        offsetY := var._lastCaptureMode == "JAB" ? top + bottom : bottom
    else
        offsetY := top

    hideCaretSymbol()
    switch var.caretSymbolType {
        case 1:
            x := toPhysical(var.%"caretSymbolPictureOffsetX" state%, scale)
            y := toPhysical(var.%"caretSymbolPictureOffsetY" state%, scale)
            g := var.%"caretSymbolPictureGui" state%
            try {
                showGui(g, "NA", 0, 1)
                setGuiPhysicalPos(g.Hwnd, left + x, offsetY + y)
            }
        case 2:
            x := toPhysical(var.%"caretSymbolShapeOffsetX" state%, scale)
            y := toPhysical(var.%"caretSymbolShapeOffsetY" state%, scale)
            w := toPhysical(var.%"caretSymbolShapeWidth" state%, scale)
            h := toPhysical(var.%"caretSymbolShapeHeight" state%, scale)
            g := var.%"caretSymbolShapeGui" state%
            try {
                showGui(g, "NA", 0, 1, var.%'caretSymbolShapeTransparent' state%)
                setGuiPhysicalPos(g.Hwnd, left + x, offsetY + y, w, h)
            }
        case 3:
            x := toPhysical(var.%"caretSymbolTextOffsetX" state%, scale)
            y := toPhysical(var.%"caretSymbolTextOffsetY" state%, scale)
            g := var.%"caretSymbolTextGui" state%
            try {
                showGui(g, "NA", 0, 1, var.%"caretSymbolTextTransparent" state%)
                setGuiPhysicalPos(g.Hwnd, left + x, offsetY + y)
            }
    }

    lastCaretSymbol := state
}

reloadCaretSymbol() {
    global lastProcess := "", lastTitle := "", lastClass := "", lastCaretSymbol := ""
    if var.caretSymbolType {
        if returnCanShowSymbol(&left, &top, &right, &bottom)
            showCaretSymbol(currentState, left, top, right, bottom)
    }
}

hideCaretSymbol(all := 1) {
    for type in ["Picture", "Shape", "Text"] {
        for v in stateList {
            if (all || currentState != v) {
                try var.%"caretSymbol" type "Gui" v%.Hide()
            }
        }
    }
    global lastCaretSymbol := ""
}

ShowCursorSymbolEx(state := currentState) {
    try {
        MouseGetPos(&left, &top)
        showCursorSymbol(state, left, top)
    } catch {
        hideCursorSymbol()
    }
}

showCursorSymbol(state, left, top) {
    global lastCursorSymbol
    if lastCursorSymbol != state {
        hideCursorSymbol()
    }

    s := isWhichScreen()
    scale := s.scale

    if (s.num) {
        try {
            offset := symbolScreenOffset.cursor.%s.num%
            left += toPhysical(offset.x, scale)
            top += toPhysical(offset.y, scale)
        }
    }
    switch var.cursorSymbolType {
        case 1:
            x := toPhysical(var.%"cursorSymbolPictureOffsetX" state%, scale)
            y := toPhysical(var.%"cursorSymbolPictureOffsetY" state%, scale)
            g := var.%"cursorSymbolPictureGui" state%
            showGui(g, "NA AutoSize", 0, 0)
            setGuiPhysicalPos(g.Hwnd, left + x, top + y)
        case 2:
            x := toPhysical(var.%"cursorSymbolShapeOffsetX" state%, scale)
            y := toPhysical(var.%"cursorSymbolShapeOffsetY" state%, scale)
            w := toPhysical(var.%"cursorSymbolShapeWidth" state%, scale)
            h := toPhysical(var.%"cursorSymbolShapeHeight" state%, scale)
            g := var.%"cursorSymbolShapeGui" state%
            applyTransparency(g, var.%'cursorSymbolShapeTransparent' state%)
            showGui(g, "NA", 0, 0)
            setGuiPhysicalPos(g.Hwnd, left + x, top + y, w, h)
        case 3:
            x := toPhysical(var.%"cursorSymbolTextOffsetX" state%, scale)
            y := toPhysical(var.%"cursorSymbolTextOffsetY" state%, scale)
            g := var.%"cursorSymbolTextGui" state%
            applyTransparency(g, var.%"cursorSymbolTextTransparent" state%)
            showGui(g, "NA AutoSize", 0, 0)
            setGuiPhysicalPos(g.Hwnd, left + x, top + y)
    }

    lastCursorSymbol := state
}

reloadCursorSymbol() {
    global lastProcess := "", lastTitle := "", lastClass := "", lastCursorSymbol := ""

    if var.cursorSymbolType {
        try {
            MouseGetPos(&left, &top)
            hideCursorSymbol()
            showCursorSymbol(currentState, left, top)
        } catch {
            hideCursorSymbol()
        }
    }
}

hideCursorSymbol(all := 1) {
    for type in ["Picture", "Shape", "Text"] {
        for v in stateList {
            if (all || currentState != v) {
                try var.%"cursorSymbol" type "Gui" v%.Hide()
            }
        }
    }
    global lastCursorSymbol := ""
}

getSymbolPicturePath() {
    symbolPicList := []
    for state in stateList
        symbolPicList.Push("default-triangle-" stateVal.%state%.colorText ".png")
    return getPicList(symbolDir, symbolPicList)
}

e_symbol(*) {
    showGui(createUniqueGui(symbolStyleGui))
    symbolStyleGui(info) {
        g := createGuiOpt(i18n("caretSymbol"))
        tab := renderTab(g, [i18n("basicConfig"), i18n("basicConfig") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/symbol-caret"))

        if (info.i) {
            g.AddText(, isChinese ? line70 : line80)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        symbolTypeBtns := []
        gc.previewSymbol := g.AddEdit("xs cGray r1 w" bw, i18n("symbol.preview"))
        previewSymbol := (key, value, *) => (changeConfig(key, value), var.caretSymbolType ? gc.previewSymbol.Focus() : "", reloadCaretSymbol(), toggleState())
        toggleState() {
            opt := var.caretSymbolType ? "-Disabled" : "+Disabled"
            for v in symbolTypeBtns
                v.Opt(opt)
        }

        renderRadioGroup(g, "caretSymbolType", [["none", 0, previewSymbol], ["symbolType.picture", 1, previewSymbol], ["symbolType.shape", 2, previewSymbol], ["symbolType.text", 3, previewSymbol]])

        g.AddLink("yp", getDocsLink("tip/symbol-caret/list-mechanism", i18n("symbol.whitelist.tip")))

        btnOpt := " w" bw / 2 - g.MarginX / 4 (var.caretSymbolType ? "" : " Disabled")
        _ := g.AddButton("xs" btnOpt, i18n("symbolConfig"))
        _.OnEvent("Click", e_symbolConfig.Bind("caret"))
        symbolTypeBtns.Push(_)
        _ := g.AddButton("yp" btnOpt, i18n("symbolCaretCapture"))
        _.OnEvent("Click",
            createProcessMenuGui.Bind({
                title: i18n("caretSymbol") " - " i18n("symbolCaretCapture"),
                tab: [i18n("symbolCaretCapture")],
                trigger: ["capture"],
                link: getDocsLink("tip/symbol-caret/caret-capture-mode"),
                section: "Window.CaretSymbol.Rule",
                cols: ["process", "capture", "captureOffset"],
                conditions: []
            })
        )
        symbolTypeBtns.Push(_)
        _ := g.AddButton("xs" btnOpt, i18n("symbol.whitelist"))
        _.OnEvent("Click",
            createProcessMenuGui.Bind({
                title: i18n("caretSymbol") " - " i18n("symbol.whitelist"),
                tab: [i18n("symbol.whitelist")],
                trigger: ["show"],
                link: getDocsLink("tip/symbol-caret/list-mechanism"),
                section: "Window.CaretSymbol.Rule",
                cols: ["process", "condition", "class", "title"],
                conditions: conditionKeyList
            })
        )
        symbolTypeBtns.Push(_)
        _ := g.AddButton("yp" btnOpt, i18n("symbolWindowOffset"))
        _.OnEvent("Click",
            createProcessMenuGui.Bind({
                title: i18n("caretSymbol") " - " i18n("symbolWindowOffset"),
                tab: [i18n("symbolWindowOffset")],
                trigger: ["offset"],
                link: getDocsLink("tip/symbol-caret/window-offset"),
                section: "Window.CaretSymbol.Rule",
                cols: ["process", "offset", "condition", "class", "title"],
                conditions: conditionKeyList
            })
        )
        symbolTypeBtns.Push(_)
        _ := g.AddButton("xs" btnOpt, i18n("symbol.blacklist"))
        _.OnEvent("Click",
            createProcessMenuGui.Bind({
                title: i18n("caretSymbol") " - " i18n("symbol.blacklist"),
                tab: [i18n("symbol.blacklist")],
                trigger: ["hide"],
                link: getDocsLink("tip/symbol-caret/list-mechanism"),
                section: "Window.CaretSymbol.Rule",
                cols: ["process", "condition", "class", "title"],
                conditions: conditionKeyList
            })
        )
        symbolTypeBtns.Push(_)
        _ := g.AddButton("yp" btnOpt, i18n("symbolScreenOffset"))
        _.OnEvent("Click", e_screenOffset.Bind("caret"))
        symbolTypeBtns.Push(_)

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("tip/symbol-caret"))
        renderEditGroup(g, "caretSymbolHideDelay", "Number Limit5")

        renderRadioGroup(g, "caretSymbolOriginY", [[".above", "above", previewSymbol], [".below", "below", previewSymbol]])

        renderRadioGroup(g, "symbolJABActive", [["yes", 1], ["no", 0]])
        g.AddLink("yp", getHelpLink("tip/symbol-caret/use-inputtip-in-jetbrains"))

        return g
    }
}

e_cursorSymbol(*) {
    showGui(createUniqueGui(symbolStyleGui))
    symbolStyleGui(info) {
        g := createGuiOpt(i18n("cursorSymbol"))
        tab := renderTab(g, [i18n("basicConfig")])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/symbol-cursor"))

        if (info.i) {
            g.AddText(, isChinese ? line70 : line80)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        symbolTypeBtns := []
        previewSymbol := (key, value, *) => (changeConfig(key, value), reloadCursorSymbol(), toggleState())
        toggleState() {
            opt := var.cursorSymbolType ? "-Disabled" : "+Disabled"
            for v in symbolTypeBtns
                v.Opt(opt)
        }

        renderRadioGroup(g, "cursorSymbolType", [["none", 0, previewSymbol], ["symbolType.picture", 1, previewSymbol], ["symbolType.shape", 2, previewSymbol], ["symbolType.text", 3, previewSymbol]])

        btnOpt := " w" bw / 2 - g.MarginX / 4 (var.cursorSymbolType ? "" : " Disabled")

        _ := g.AddButton("xs" btnOpt, i18n("symbolConfig"))
        _.OnEvent("Click", e_symbolConfig.Bind("cursor"))
        symbolTypeBtns.Push(_)

        _ := g.AddButton("yp" btnOpt, i18n("symbolScreenOffset"))
        _.OnEvent("Click", e_screenOffset.Bind("cursor"))
        symbolTypeBtns.Push(_)

        renderEditGroup(g, "cursorSymbolHideDelay", "Number Limit5")

        renderRadioGroup(g, "cursorSymbolShowMode",
            [
                ["blacklist", "blacklist"],
                ["whitelist", "whitelist"]
            ])
        for v in [
            ["hide", "xs", "blacklistBtn"],
            ["show", "yp", "whitelistBtn"],
        ] {
            _ := g.AddButton(v[2] btnOpt, i18n(v[3]))
            _.OnEvent("Click",
                createProcessMenuGui.Bind({
                    title: i18n("cursorSymbol") " - " i18n(v[3]),
                    tab: [i18n(v[3])],
                    trigger: [v[1]],
                    link: getDocsLink("tip/symbol-cursor"),
                    section: "Window.CursorSymbol.Rule",
                    cols: ["process", "condition", "class", "title"],
                    conditions: conditionKeyList
                })
            )
            symbolTypeBtns.Push(_)
        }
        return g
    }
}

e_symbolConfig(prefix, *) {
    switch var.%prefix "SymbolType"% {
        case 1:
            showGui(createUniqueGui(symbolStyleGui1))
            symbolStyleGui1(info) {
                g := createGuiOpt(i18n(prefix "Symbol") " - " i18n("symbolPicture"))
                tab := renderTab(g, [i18n("stateStyle"), i18n("stateStyle") 2, i18n("stateStyle") 3])
                loseFocusOnTab(tab)
                tab.UseTab(1)
                g.AddLink("Section", getDocsLink("tip/symbol-caret/picture"))

                if (info.i) {
                    g.AddText(, isChinese ? line70 : line80)
                    return g
                }
                g.w := w := info.w
                g.bw := bw := w - g.MarginX * 2

                previewCtrl := prefix == "caret" ? g.AddEdit("xs cGray r1 w" bw, i18n("symbol.preview")) : { Focus: (*) => "" }

                gc.%prefix "PreviewSymbolPicture1"% := previewCtrl

                picList := getSymbolPicturePath()
                picList.InsertAt(1, "")

                editOpt := " w" bw / 10

                page := 1
                for i, state in stateList {
                    if (i == 3 || i == 5) {
                        page++
                        addBtn()
                        tab.UseTab(page)
                        g.AddLink("Section", getDocsLink("tip/symbol-caret/picture"))
                        gc.%prefix "PreviewSymbolPicture" page% := prefix == "caret" ? g.AddEdit("xs cGray r1 w" bw, i18n("symbol.preview")) : { Focus: (*) => "" }
                    }
                    renderGroupBox(g, state, "xs", "h120 w" bw)
                    _ := prefix "SymbolPictureOffsetX"
                    renderEditLabel(g, _ state, "Limit5 " editOpt, _)
                    _ := prefix "SymbolPictureOffsetY"
                    renderEditLabel(g, _ state, "Limit5 " editOpt, _, "yp")
                    _ := prefix "SymbolPictureWidth"
                    renderEditLabel(g, _ state, "Number Limit3" editOpt, _, "yp")
                    _ := prefix "SymbolPictureHeight"
                    renderEditLabel(g, _ state, "Number Limit3" editOpt, _, "yp")

                    _ := g.AddDropDownList("xs+20 yp+40 r9 w" bw - 40, picList)
                    key := prefix "SymbolPicturePath" state
                    _.key := key
                    _.page := page
                    try _.Text := var.%key%
                    _.OnEvent("Change", (ctrl, *) => changeConfig(ctrl.key, ctrl.Text, , (*) => gc.%prefix "PreviewSymbolPicture" ctrl.page%.Focus()))

                    if i > 5
                        addBtn()
                }
                addBtn() {
                    _w := bw / 2 - g.MarginX / 4
                    g.AddButton("xs w" _w, i18n("symbolPicture.open")).OnEvent("Click", (*) => Run("explorer.exe " A_ScriptDir "\data\symbol"))
                    g.AddButton("yp w" _w, i18n("symbolPicture.download")).OnEvent("Click", (*) => Run("https://inputtip.abgox.com/download/extra"))
                }

                return g
            }
        case 2:
            showGui(createUniqueGui(symbolStyleGui2))
            symbolStyleGui2(info) {
                g := createGuiOpt(i18n(prefix "Symbol") " - " i18n("symbolShape"))
                tab := renderTab(g, [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2, i18n("stateStyle") 3])
                loseFocusOnTab(tab)
                tab.UseTab(1)
                g.AddLink("Section", getDocsLink("tip/symbol-caret/shape"))


                if (info.i) {
                    g.AddText(, isChinese ? line60 : line70)
                    return g
                }
                g.w := w := info.w
                g.bw := bw := w - g.MarginX * 2

                previewCtrl := prefix == "caret" ? g.AddEdit("xs cGray r1 w" bw, i18n("symbol.preview")) : { Focus: (*) => "" }

                gc.%prefix "PreviewSymbolShape"% := previewCtrl

                list := [
                    [prefix "SymbolShapeCornerPreference", [["none", 0], ["cornerPreference.sharp", 1], ["cornerPreference.round", 2], ["cornerPreference.roundSmall", 3]]],
                    [prefix "SymbolShapeEdgeStyle", [["none", 0], ["edgeStyle.modal", 1], ["edgeStyle.client", 2], ["edgeStyle.static", 3]]]
                ]
                for i, v in list
                    for item in v[2]
                        item.Push((key, value, *) => (changeConfig(key, value), gc.%prefix "PreviewSymbolShape"%.Focus(), reloadCaretSymbol()))
                renderRadioGroupList(g, list)

                editOpt := " w" bw / 8

                for i, state in stateList {
                    if (Mod(i - 1, 2) == 0) {
                        tab.UseTab(((i - 1) // 2) + 2)
                        g.AddLink("Section", getDocsLink("tip/symbol-caret/shape"))
                    }
                    renderGroupBox(g, state, , "h120 w" bw)

                    _ := prefix "SymbolShapeOffsetX"
                    renderEditLabel(g, _ state, "Limit5 " editOpt, _)
                    _ := prefix "SymbolShapeWidth"
                    renderEditLabel(g, _ state, "Number Limit3" editOpt, _, "yp")
                    _ := prefix "SymbolShapeColor"
                    renderColorPicker(g, _ state, _)
                    _ := prefix "SymbolShapeOffsetY"
                    renderEditLabel(g, _ state, "Limit5 " editOpt, _, "xs+20 yp+40")
                    _ := prefix "SymbolShapeHeight"
                    renderEditLabel(g, _ state, "Number Limit3" editOpt, _, "yp")
                    _ := prefix "SymbolShapeTransparent"
                    renderEditLabel(g, _ state, "Number Limit3" editOpt, _, "yp")
                }

                return g
            }
        case 3:
            showGui(createUniqueGui(symbolStyleGui3))
            symbolStyleGui3(info) {
                g := createGuiOpt(i18n(prefix "Symbol") " - " i18n("symbolText"))
                tab := renderTab(g, [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2, i18n("stateStyle") 3])
                loseFocusOnTab(tab)
                tab.UseTab(1)
                g.AddLink("Section", getDocsLink("tip/symbol-caret/text"))

                if (info.i) {
                    g.AddText(, line70)
                    return g
                }
                g.w := w := info.w
                g.bw := bw := w - g.MarginX * 2

                previewCtrl := prefix == "caret" ? g.AddEdit("xs cGray r1 w" bw, i18n("symbol.preview")) : { Focus: (*) => "" }

                gc.%prefix "previewSymbolText"% := previewCtrl

                list := [
                    [prefix "SymbolTextCornerPreference", [["none", 0], ["cornerPreference.sharp", 1], ["cornerPreference.round", 2], ["cornerPreference.roundSmall", 3]]],
                    [prefix "SymbolTextEdgeStyle", [["none", 0], ["edgeStyle.modal", 1], ["edgeStyle.client", 2], ["edgeStyle.static", 3]]]
                ]
                for i, v in list
                    for item in v[2]
                        item.Push((key, value, *) => (changeConfig(key, value), gc.%prefix "previewSymbolText"% .Focus(), reloadCaretSymbol()))
                renderRadioGroupList(g, list)

                editOpt := " w" bw / 6

                for i, state in stateList {
                    if (Mod(i - 1, 2) == 0) {
                        tab.UseTab(((i - 1) // 2) + 2)
                        g.AddLink("Section", getDocsLink("tip/symbol-caret/text"))
                    }

                    renderGroupBox(g, state, , "h210 w" bw)

                    renderEditLabel(g, prefix "SymbolTextContent" state, editOpt, prefix "SymbolTextContent")
                    renderEditLabel(g, prefix "SymbolTextOffsetX" state, "Limit5 " editOpt, prefix "SymbolTextOffsetX", "yp")
                    renderColorPicker(g, prefix "SymbolTextColor" state, prefix "SymbolTextColor")
                    renderEditLabel(g, prefix "SymbolTextSize" state, "Number Limit2" editOpt, prefix "SymbolTextSize", "xs+20 yp+40")
                    renderEditLabel(g, prefix "SymbolTextOffsetY" state, "Limit5 " editOpt, prefix "SymbolTextOffsetY", "yp")
                    renderColorPicker(g, prefix "SymbolTextBgColor" state, prefix "SymbolTextBgColor")

                    renderText(g, prefix "SymbolTextFont", "xs+20 yp+50", "")
                    renderDropDownList(g, prefix "SymbolTextFont" state, fontList, "yp", "w" bw / 1.2)
                    renderEditLabel(g, prefix "SymbolTextWeight" state, "Number Limit3" editOpt, prefix "SymbolTextWeight")
                    renderEditLabel(g, prefix "SymbolTextTransparent" state, "Number Limit3" editOpt, prefix "SymbolTextTransparent", "yp")
                }

                return g
            }
    }
}

e_screenOffset(prefix, *) {
    showGui(createUniqueGui(offsetScreenGui))
    offsetScreenGui(info) {
        g := createGuiOpt(i18n(prefix "Symbol") " - " i18n("symbolScreenOffset"))

        g.AddLink("Section", getDocsLink("tip/symbol-caret/screen-offset"))

        if info.i {
            g.AddText(, line60)
            return g
        }

        pages := []
        for v in var.screenList {
            pages.push(i18n("offset.screen") " " v.num)
        }
        tab := renderTab(g, pages, "w" info.w)

        offsetMap := Map()
        for o in StrSplit(readIni(prefix "SymbolScreenOffset", ""), "|") {
            if (o == "")
                continue
            p := StrSplit(o, "/")
            try offsetMap.Set(p[1], { x: p[2], y: p[3] })
        }

        for v in var.screenList {
            tab.UseTab(v.num)
            n := String(v.num)

            g.AddText("Section", i18n("offset.coordinate") "(X,Y): " i18n("offset.topLeft") "(" v.left ", " v.top "), " i18n("offset.bottomRight") "(" v.right ", " v.bottom ")")

            x := 0, y := 0
            if offsetMap.Has(n) {
                x := offsetMap.Get(n).x
                y := offsetMap.Get(n).y
            } else {
                offsetMap.Set(n, { x: 0, y: 0 })
            }

            g.SetFont("Bold")
            g.AddText("xs", i18n("offset.offset_x"))
            g.SetFont("Norm")
            _ := g.AddEdit("yp Limit5 r1")
            _.Value := x
            _.OnEvent("Change", e_changeOffset.Bind(n, "x"))

            g.SetFont("Bold")
            g.AddText("xs", i18n("offset.offset_y"))
            g.SetFont("Norm")
            _ := g.AddEdit("yp Limit5 r1")
            _.Value := y
            _.OnEvent("Change", e_changeOffset.Bind(n, "y"))
            e_changeOffset(n, pos, item, *) {
                if !offsetMap.Has(n)
                    offsetMap.Set(n, { x: 0, y: 0 })
                offsetMap.Get(n).%pos% := returnNumber(item.value)

                offsets := ""
                for k, v in offsetMap {
                    offsets .= "|" k "/" v.x "/" v.y
                }

                writeIniDebounced(prefix "SymbolScreenOffset", SubStr(offsets, 2), (*) => (
                    updateScreenOffset(prefix),
                    prefix == "caret" ? reloadCaretSymbol() : reloadCursorSymbol(),
                    restartJAB()
                ))
            }
        }

        return g
    }
}
