; InputTip

#Include "*i about.ahk"
#Include "*i input-method.ahk"
#Include "*i more-settings.ahk"
#Include "*i startup.ahk"
#Include "*i offset.ahk"
#Include "*i ui.ahk"
#Include "*i config.ahk"

fontList := getFontList()
fontList.InsertAt(1, "Microsoft YaHei")

makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add(i18n("usageGuide"), (*) => Run("https://inputtip.abgox.com/zh-cn/docs/guide"))
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("startup"), e_startup)
    if (var.launchAtStartup) {
        A_TrayMenu.Check(i18n("startup"))
    }

    if (!A_IsCompiled) {
        A_TrayMenu.Add(i18n("runCodeWithAdmin"), (*) => (
            A_TrayMenu.ToggleCheck(i18n("runCodeWithAdmin")),
            changeConfig("runCodeWithAdmin", !var.runCodeWithAdmin, 0),
            var.runCodeWithAdmin ? fn_restart() : 0
        ))
        if (A_IsAdmin && var.runCodeWithAdmin) {
            A_TrayMenu.Check(i18n("runCodeWithAdmin"))
        }
    }

    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("state.Pause/Run"), pauseApp)
    A_TrayMenu.Default := i18n("state.Pause/Run")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("inputMethod"), e_inputMethod)
    A_TrayMenu.Add(i18n("stateSwitch.window"), (*) =>
        createProcessMenuGui(
            i18n("stateSwitch.window"),
            [
                i18n("state.CN"),
                i18n("state.EN"),
                i18n("state.Caps")
            ],
            getDocsLink("switch/window"),
            [
                "Window.AutoSwitch.CN",
                "Window.AutoSwitch.EN",
                "Window.AutoSwitch.Caps"
            ]
        )
    )
    A_TrayMenu.Add(i18n("stateSwitch.hotkey"), (*) =>
        showHotKeyGui([{
            config: "hotkeyCN",
            tip: i18n("state.CN")
        }, {
            config: "hotkeyEN",
            tip: i18n("state.EN")
        }, {
            config: "hotkeyCaps",
            tip: i18n("state.Caps")
        }], i18n("stateSwitch.hotkey"))
    )

    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("cursor"), e_cursor)
    A_TrayMenu.Add(i18n("overlay"), e_overlay)
    A_TrayMenu.Add(i18n("symbol"), e_symbol)
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("windowInfo"), e_windowInfo)
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("moreSettings"), e_moreSettings)
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("about"), e_about)
    A_TrayMenu.Add(i18n("state.Restart"), fn_restart)

    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("state.Exit"), fn_exit)
}

fn_exit(*) {
    killJAB()
    revertCursor()
    ExitApp()
}
fn_restart(*) {
    if (var.symbolJABActive) {
        killJAB()
    }
    if (A_IsCompiled) {
        Run('"' A_ScriptFullPath '" ' keyCount)
    } else {
        Run('"' A_AhkPath '" "' A_ScriptFullPath '" ' keyCount)
    }
}

e_windowInfo(*) {
    showGui(createUniqueGui(windowInfoGui))
    windowInfoGui(info) {
        g := createGuiOpt(i18n("windowInfo"), , "AlwaysOnTop")

        if (info.i) {
            g.AddText(, line70)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddLink("Section", getDocsLink("menu/window-info"))
        for v in i18n("windowInfo.list", 1) {
            g.SetFont("Bold")
            g.AddGroupBox("xs h70 w" bw, v)
            g.SetFont("Norm")
            gc.%v% := g.AddEdit("xs+20 yp+30 ReadOnly -VScroll w" bw - 40)
        }
        g.OnEvent("Close", (*) => gc.stateTimer := 0)
        gc.stateTimer := 1
        SetTimer(stateTimer, 50)
        stateTimer() {
            static first := "", last := ""
            if (!gc.stateTimer) {
                SetTimer(, 0)
                first := ""
                last := ""
                return
            }
            try {
                list := [
                    WinGetProcessName("A"),
                    WinGetTitle("A"),
                    WinGetProcessPath("A")
                ]
                if (!first) {
                    for i, v in i18n("windowInfo.list", 1) {
                        gc.%v%.Value := list[i]
                    }
                    first := arrJoin(list, "-")
                }
                info := arrJoin(list, "-")
                if (info == last || info == first) {
                    return
                }
                for i, v in i18n("windowInfo.list", 1) {
                    gc.%v%.Value := list[i]
                }
                last := info
            }
        }
        return g
    }
}

/**
 * 将进程以【进程级】添加到白名单中
 * @param app 要添加的进程名称
 */
updateWhiteList(app) {
    exist := 0
    for v in var.WindowSymbolShow {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 3)
        try {
            if (part[1] == app) {
                isGlobal := part[2]
                if (isGlobal) {
                    exist := 1
                    return
                } else {
                    continue
                }
            }
        }
    }
    if (!exist) {
        writeIniDebounced(returnTime(), app ":1", (key, value, section) => var.WindowSymbolShow := StrSplit(readIniSection(section), "`n"), "Window.Symbol.Show")
    }
}

/**
 * 通用的进程菜单
 * @param {String} title 菜单标题
 * @param {Array} tabList 标签页列表
 * @param {String} link 标签页顶部的链接
 * @param {Array} configSectionList 配置列表
 * @param {Map} column 表格的列和顺序
 * - 每个值是一个对象，包含 config、gui、label 三个属性
 * - config: 配置项中的位置，从 1 开始
 * - gui: 表格列的位置，从 1 开始
 * - label: 表格列的标题
 */
createProcessMenuGui(title, tabList, link, configSectionList, column := Map(
    "exe", { config: 1, gui: 1 },
    "range", { config: 2, gui: 2 },
    "mode", { config: 3, gui: 3 },
    "title", { config: 4, gui: 4 },
    "time", { config: 5, gui: 5 },
), addBtn := (g, width, config, e_add, e_addManually) => (
    w := " w" width / 2 - g.MarginX / 4,
    g.AddButton("xs" w, i18n("addQuickly")).OnEvent("Click", e_add.Bind(config)),
    g.AddButton("yp" w, i18n("addManually")).OnEvent("Click", e_addManually.Bind(config))
)) {
    ; 列表菜单
    static listView := {}
    showGui(createUniqueGui(processMenuGui))
    processMenuGui(info) {
        g := createGuiOpt(title)

        if (info.i) {
            g.AddText(, line70)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        tab := renderTab(g, tabList)
        loseFocusOnTab(tab)
        tab.UseTab(1)

        addItem(config) {
            listView.%config%.Opt("-Redraw")
            for v in StrSplit(readIniSection(config), "`n") {
                try {
                    kv := StrSplit(v, "=", , 2)
                    part := StrSplit(kv[2], ":", , column.Count - 1)
                    cols := []
                    i := 0
                    while (i < column.Count) {
                        cols.Push("")
                        i++
                    }
                    num := column.Get("exe", 0)
                    if (num) {
                        cols[num.gui] := part[num.config]
                    }
                    num := column.Get("range", 0)
                    if (num) {
                        cols[num.gui] := part[num.config] ? i18n("match.process") : i18n("match.titleLevel")
                    }
                    num := column.Get("mode", 0)
                    if (num) {
                        cols[num.gui] := part[num.config] ? i18n("match.regex") : i18n("match.equal")
                    }
                    num := column.Get("title", 0)
                    if (num) {
                        cols[num.gui] := part[num.config]
                    }
                    num := column.Get("capture", 0)
                    if (num) {
                        cols[num.gui] := part[num.config]
                    }
                    num := column.Get("offset", 0)
                    if (num) {
                        cols[num.gui] := part[num.config]
                    }
                    num := column.Get("time", 0)
                    if (num) {
                        cols[num.gui] := kv[1]
                    }
                    listView.%config%.Add(, cols*)
                } catch {
                    IniDelete(configFile, config, kv[1])
                }
            }
            listView.%config%.Opt("+Redraw")
            autoHdrLV(listView.%config%)
        }

        e_dbClick(config, LV, RowNumber, *) {
            handleClick(RowNumber, config)
        }

        handleClick(RowNumber, config) {
            if (!RowNumber) {
                return
            }
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }

            itemValue := {}
            for k, v in column {
                itemValue.%k% := listView.%config%.GetText(RowNumber, v.gui)
            }
            showGui(createUniqueGui((info) => fn_edit(RowNumber, config, "edit", itemValue)))
        }

        fn_edit(RowNumber, config, action, itemValue) {
            if (action == "edit") {
                g := createGuiOpt(i18n("editRule"))
            } else {
                g := createGuiOpt(i18n("addRule"))
            }

            if (info.i) {
                g.AddText(, i18n("match.range.invalid"))
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            opt := "xs+20 yp+30 w" bw - 40

            sectionList := []
            i := 0
            while (i < column.Count) {
                sectionList.Push("")
                i++
            }

            num := column.Get("exe", 0)
            if (num) {
                sectionList[num.gui] := fn_exe
                fn_exe() {
                    g.SetFont("Bold")
                    g.AddGroupBox("Section h70 w" bw, i18n("match.exe"))
                    g.SetFont("Norm")
                    _ := g.AddEdit(opt, "")
                    try _.Text := itemValue.exe
                    itemValue.exe := _.Text
                    _.OnEvent("Change", (i, *) => itemValue.exe := i.Text)
                }
            }

            num := column.Get("range", 0)
            if (num) {
                sectionList[num.gui] := fn_range
                fn_range() {
                    g.SetFont("Bold")
                    g.AddGroupBox("xs h70 w" bw, i18n("match.range"))
                    g.SetFont("Norm")
                    _ := g.AddDropDownList(opt, [i18n("match.process"), i18n("match.titleLevel")])
                    try {
                        _.Text := itemValue.range
                    } catch {
                        _.Text := i18n("match.process")
                    }
                    itemValue.range := _.Text
                    _.OnEvent("Change", (i, *) => itemValue.range := i.Text)
                }
            }

            num := column.Get("mode", 0)
            if (num) {
                sectionList[num.gui] := fn_mode
                fn_mode() {
                    g.AddText("xs cGray", i18n("match.range.invalid"))
                    g.SetFont("Bold")
                    g.AddGroupBox("xs h70 w" bw, i18n("match.mode"))
                    g.SetFont("Norm")
                    _ := g.AddDropDownList(opt, [i18n("match.equal"), i18n("match.regex")])
                    try {
                        _.Text := itemValue.mode
                    } catch {
                        _.Text := i18n("match.equal")
                    }
                    itemValue.mode := _.Text
                    _.OnEvent("Change", (i, *) => itemValue.mode := i.Text)
                }
            }

            num := column.Get("title", 0)
            if (num) {
                sectionList[num.gui] := fn_title
                fn_title() {
                    g.SetFont("Bold")
                    g.AddGroupBox("xs h70 w" bw, i18n("match.title"))
                    g.SetFont("Norm")
                    _ := g.AddEdit(opt)
                    try _.Text := itemValue.title
                    itemValue.title := _.Text
                    _.OnEvent("Change", (i, *) => itemValue.title := i.Text)
                }
            }

            num := column.Get("capture", 0)
            if (num) {
                sectionList[num.gui] := fn_capture
                fn_capture() {
                    g.SetFont("Bold")
                    g.AddGroupBox("xs h70 w" bw, i18n("symbolCursorCapture"))
                    g.SetFont("Norm")
                    _ := g.AddDropDownList(opt, var.modeNameList)
                    try {
                        _.Text := itemValue.capture
                    } catch {
                        _.Text := var.modeNameList[1]
                    }
                    itemValue.capture := _.Text
                    _.OnEvent("Change", (i, *) => itemValue.capture := i.Text)
                }
            }

            num := column.Get("offset", 0)
            btnLayout := "xs"
            if (num) {
                btnLayout := "Section"
                sectionList[num.gui] := fn_offset
                fn_offset() {
                    pages := []
                    for v in var.screenList {
                        pages.push(i18n("offset.screen") " " v.num)
                    }
                    tab := renderTab(g, pages, "w" bw)
                    loseFocusOnTab(tab)

                    offsetMap := Map()
                    if (action == "edit") {
                        for o in StrSplit(itemValue.offset, "|") {
                            if (o == "")
                                continue
                            p := StrSplit(o, "/")
                            try offsetMap.Set(p[1], { x: p[2], y: p[3] })
                        }
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
                        _ := g.AddEdit("yp")
                        _.Value := x
                        _.OnEvent("Change", e_changeOffset.Bind(n, "x"))
                        _.OnEvent("LoseFocus", e_changeOffset.Bind(n, "x"))

                        g.SetFont("Bold")
                        g.AddText("xs", i18n("offset.offset_y"))
                        g.SetFont("Norm")
                        _ := g.AddEdit("yp")
                        _.Value := y
                        _.OnEvent("Change", e_changeOffset.Bind(n, "y"))
                        _.OnEvent("LoseFocus", e_changeOffset.Bind(n, "y"))
                    }

                    e_changeOffset(n, pos, item, *) {
                        if !offsetMap.Has(n)
                            offsetMap.Set(n, { x: 0, y: 0 })
                        offsetMap.Get(n).%pos% := returnNumber(item.value)

                        if (item.Focused)
                            return

                        itemValue.offset := ""
                        for k, v in offsetMap {
                            itemValue.offset .= "|" k "/" v.x "/" v.y
                        }
                        itemValue.offset := SubStr(itemValue.offset, 2)
                    }
                }
            }
            if (InStr(config, "Window.AutoSwitch.")) {
                state := StrSplit(config, ".")[-1]
                itemValue.stateText := itemValue.oldStateText := var.stateVal.%state%.text
                sectionList.InsertAt(2, fn_state)
                fn_state() {
                    g.SetFont("Bold")
                    g.AddGroupBox("xs h70 w" bw, i18n("match.state"))
                    g.SetFont("Norm")
                    _ := g.AddDropDownList(opt, tabList)
                    try _.Text := itemValue.stateText
                    _.OnEvent("Change", (i, *) => itemValue.stateText := i.Text)
                }
            }

            for v in sectionList {
                if (v) {
                    v()
                }
            }
            tab.UseTab(0)

            g.AddButton(btnLayout " w" bw, i18n("ok")).OnEvent("Click", (*) => fn_set(action, 0, 0))
            ; if (action != "edit" && config != "Window.Symbol.Show") {
            ;     g.AddButton("xs w" bw, i18n("okAndAddWhitelist")).OnEvent("Click", (*) => fn_set(action, 0, 1))
            ; }
            if (action == "edit") {
                g.AddButton("xs w" bw, i18n("delete")).OnEvent("Click", (*) => fn_set(action, 1, 0))
            }

            fn_set(action, delete, needAddWhiteList) {
                g.Destroy()

                if (delete) {
                    changeSectionConfig(itemValue.time, '', config, 1)
                    try listView.%config%.Delete(RowNumber)
                } else {
                    value := []
                    i := 0
                    while (i < column.Count) {
                        value.Push("")
                        i++
                    }
                    num := column.Get("exe", 0)
                    if (num) {
                        value[num.config] := itemValue.exe
                    }
                    num := column.Get("range", 0)
                    if (num) {
                        value[num.config] := itemValue.range == i18n("match.process") ? 1 : 0
                    }
                    num := column.Get("mode", 0)
                    if (num) {
                        value[num.config] := itemValue.mode == i18n("match.regex") ? 1 : 0
                    }
                    num := column.Get("title", 0)
                    if (num) {
                        value[num.config] := itemValue.title
                    }
                    num := column.Get("capture", 0)
                    if (num) {
                        value[num.config] := itemValue.capture
                    }
                    num := column.Get("offset", 0)
                    if (num) {
                        value[num.config] := itemValue.offset
                    }

                    if (value[-1] == "") {
                        value.Pop()
                    }
                    value := arrJoin(value, ":")

                    cols := []
                    i := 0
                    while (i < column.Count) {
                        cols.Push("")
                        i++
                    }
                    for k, v in column {
                        cols[v.gui] := itemValue.%k%
                    }

                    if (InStr(config, "Window.AutoSwitch.")) {
                        ; 没有进行移动
                        if (itemValue.stateText == itemValue.oldStateText) {
                            changeSectionConfig(itemValue.time, value, config)
                            if (action == "edit") {
                                listView.%config%.Modify(RowNumber, , cols*)
                            } else {
                                listView.%config%.Insert(RowNumber, , cols*)
                            }
                        } else {
                            if (action == "edit") {
                                try {
                                    IniDelete(configFile, config, itemValue.time)
                                    listView.%config%.Delete(RowNumber)
                                }
                            }

                            newState := ""
                            for v in var.stateVal.OwnProps() {
                                if (itemValue.stateText == var.stateVal.%v%.text) {
                                    newState := v
                                    break
                                }
                            }
                            if (newState) {
                                newConfig := "Window.AutoSwitch." newState
                                changeSectionConfig(itemValue.time, value, newConfig)
                                listView.%newConfig%.Insert(RowNumber, , cols*)
                            }
                        }
                    } else {
                        changeSectionConfig(itemValue.time, value, config)
                        if (action == "edit") {
                            listView.%config%.Modify(RowNumber, , cols*)
                        } else {
                            listView.%config%.Insert(RowNumber, , cols*)
                        }
                    }
                    if (needAddWhiteList) {
                        updateWhiteList(itemValue.exe)
                    }
                }
                try autoHdrLV(listView.%config%)
                try autoHdrLV(listView.%newConfig%)
            }
            return g
        }

        columnText := []
        i := 0
        while (i < column.Count) {
            columnText.Push("")
            i++
        }
        for k, v in column {
            columnText[v.gui] := i18n("match." k)
        }

        for i, v in configSectionList {
            tab.UseTab(i)
            g.AddLink("Section", link)

            _ := listView.%v% := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, columnText)
            addItem(v)
            autoHdrLV(_)
            _.OnEvent("DoubleClick", e_dbClick.Bind(v))
            addBtn(g, w, v, e_add, e_addManually)
        }

        e_addManually(config, *) {
            itemValue := {
                range: i18n("match.process"),
                mode: i18n("match.equal"),
                time: returnTime()
            }
            for k, v in column {
                if (!itemValue.HasProp(k)) {
                    itemValue.%k% := ""
                }
            }
            showGui(createUniqueGui((info) => fn_edit(1, config, "add", itemValue)))
        }

        e_add(config, *) {
            args := {
                title: i18n("addQuickly"),
                configName: config,
            }
            createProcessListGui(args, addClick)

            addClick(args) {
                windowInfo := args.windowInfo
                RowNumber := args.RowNumber
                itemValue := {
                    exe: windowInfo.exe,
                    range: i18n("match.process"),
                    mode: i18n("match.equal"),
                    title: windowInfo.title,
                    time: windowInfo.time
                }

                for k, v in column {
                    if (!itemValue.HasProp(k)) {
                        itemValue.%k% := ""
                    }
                }
                showGui(createUniqueGui((info) => fn_edit(RowNumber, args.parentArgs.configName, "add", itemValue)))
            }
        }
        g.OnEvent("Close", fn_close)
        fn_close(*) {
            g.Destroy()
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        return g
    }
}

/**
 * 获取字体名称列表
 */
getFontList() {
    seen := Map()

    enumFontProc(lpelfe, lpntme, FontType, lParam) {
        name := StrGet(lpelfe + 28, 32, "UTF-16")
        if !InStr(name, "@") && !seen.Has(name) {
            seen[name] := true
            ObjFromPtrAddRef(lParam).Push(name)
        }
        return 1
    }

    list := []
    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    callback := CallbackCreate(enumFontProc, "F", 4)
    DllCall("EnumFontFamiliesEx"
        , "Ptr", hDC
        , "Ptr", 0
        , "Ptr", callback
        , "Ptr", ObjPtr(list)
        , "UInt", 0)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    CallbackFree(callback)
    return list
}

pauseApp(*) {
    updateTrayTip(!A_IsPaused)
    if (A_IsPaused) {
        A_TrayMenu.Uncheck(i18n("state.Pause/Run"))
        setTrayIcon(var.iconRunning, 0)
        showOverlay(currentState)
        reloadSymbol()
        loadCursor(currentState, 1)
        restartJAB()
    } else {
        A_TrayMenu.Check(i18n("state.Pause/Run"))
        setTrayIcon(var.iconPaused, 1)
        hideOverlay()
        hideSymbol(1)
        if (var.cursorActive) {
            revertCursor()
        }
        if (var.symbolJABActive) {
            killJAB(0)
        }
    }
    Pause(-1)

    for state in var.stateList {
        if (var.%"hotkey" state%) {
            try Hotkey(var.%"hotkey" state%, "Toggle")
        }
    }
}


; 显示状态码和转换码
showCode(*) {
    if (gc.timer) {
        gc.timer := 0
        try gc.state_btn.Text := i18n("inputMethodDetectionMode.showCodeDoubleClick")
        return
    }

    gc.timer := 1
    try gc.state_btn.Text := i18n("inputMethodDetectionMode.stopShowCode")

    SetTimer(stateTimer, 25)
    stateTimer() {
        if (!gc.timer) {
            ToolTip()
            SetTimer(, 0)
            return
        }

        info := IME.CheckInputMode()
        ToolTip(i18n("inputMethodDetectionMode.stateCode") ": " info.stateMode "`n" i18n("inputMethodDetectionMode.conversionCode") ": " info.conversionMode)
    }
}

/**
 * 自动设置列的宽度
 * @param LV
 */
autoHdrLV(LV) {
    try {
        col := LV.GetCount("Col")
        while (col >= 1) {
            LV.ModifyCol(col, "AutoHdr")
            col--
        }
    }
}

/**
 * 创建一个包含当前正在运行的进程列表的窗口，用于提取信息，便于进行后续操作
 * @param {Object} args 传入的参数，格式为 {title: "窗口标题", ...}
 * @param {String} args.title - 窗口标题
 * @param {Func} cb_addClick 点击添加按钮的回调函数
 */
createProcessListGui(args, cb_addClick) {
    showProcessListGui(0)
    showProcessListGui(deep) {
        showGui(createUniqueGui(processListGui))
        processListGui(info) {
            g := createGuiOpt(args.title)

            if (info.i) {
                g.AddText(, line70)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            tab := renderTab(g, [i18n("processList.label")])
            loseFocusOnTab(tab)
            tab.UseTab(1)
            g.AddLink("Section", getDocsLink("menu/process-list"))

            gc.LV_processList := g.AddListView("-LV0x10 -Multi r11 NoSortHdr Sort Grid w" bw, [i18n("processList.exe"), i18n("processList.from"), i18n("processList.title"), i18n("processList.path")])

            gc.LV_processList.OnEvent("DoubleClick", e_click_add)
            e_click_add(LV, RowNumber, *) {
                windowInfo := {
                    exe: LV.GetText(RowNumber, 1),
                    title: LV.GetText(RowNumber, 3),
                    time: returnTime()
                }
                cb_addClick({
                    windowInfo: windowInfo,
                    LV: LV,
                    RowNumber: RowNumber,
                    parentArgs: args
                })
            }

            gc.LV_processList._type := "add"

            seen := Map()
            DetectHiddenWindows(deep)
            gc.LV_processList.Opt("-Redraw")

            for v in WinGetList() {
                try {
                    exe := ProcessGetName(WinGetPID("ahk_id " v))
                    if !seen.Has(exe) {
                        seen.Set(exe, 1)
                        gc.LV_processList.Add(, exe, i18n("processList.from.system"), WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                    }
                }
            }

            if (args.configName != "Window.Symbol.Show") {
                for name in var.WindowSymbolShow {
                    if !seen.Has(name) {
                        seen.Set(name, 1)
                        gc.LV_processList.Add(, name, i18n("processList.from.whitelist"))
                    }
                }
            }

            gc.LV_processList.Opt("+Redraw")
            DetectHiddenWindows(1)
            autoHdrLV(gc.LV_processList)

            w := " w" bw / 2 - g.MarginX / 4
            g.AddButton("Section" w, i18n("processList.refresh")).OnEvent("Click", (*) => showProcessListGui(deep))
            if (deep) {
                g.AddButton("yp" w, i18n("processList.less")).OnEvent("Click", (*) => showProcessListGui(0))
            } else {
                g.AddButton("yp" w, i18n("processList.more")).OnEvent("Click", (*) => showProcessListGui(1))
            }
            return g
        }
    }
}
