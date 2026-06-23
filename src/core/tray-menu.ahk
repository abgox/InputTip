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
    A_TrayMenu.Add(i18n("usageGuide"), (*) => showGui(createMsgGui(i18n("usageGuide.tips", 1), i18n("usageGuide"))))

    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("startup"), e_startup)
    checkStartup()

    if (!A_IsCompiled) {
        A_TrayMenu.Add(i18n("runCodeWithAdmin"), (*) => (
            A_TrayMenu.ToggleCheck(i18n("runCodeWithAdmin")),
            changeConfig("runCodeWithAdmin", !var.runCodeWithAdmin, 0),
            var.runCodeWithAdmin ? restartApp() : 0
        ))
        if (A_IsAdmin && var.runCodeWithAdmin) {
            A_TrayMenu.Check(i18n("runCodeWithAdmin"))
        }
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("inputMethod"), e_inputMethod)
    A_TrayMenu.Add(i18n("windowRule"), (*) =>
        createProcessMenuGui({
            title: i18n("windowRule"),
            tab: [i18n("windowRule")],
            link: getDocsLink("rule/window"),
            section: "Window.Rule",
            trigger: windowTriggerKeyList,
            cols: ["process", "trigger", "condition", "textMonitor", "hotkeyMonitor", "idleTimer", "class", "title"],
            conditions: windowConditionKeyList
        }
        )
    )
    A_TrayMenu.Add(i18n("hotkeyRule"),
        createProcessMenuGui.Bind({
            title: i18n("hotkey"),
            tab: [i18n("hotkeyRule")],
            trigger: hotkeyTriggerKeyList,
            link: getDocsLink("rule/hotkey"),
            section: "Hotkey.Rule",
            cols: ["hotkey", "trigger", "process", "condition", "class", "title"],
            conditions: conditionKeyList
        })
    )

    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("cursor"), e_cursor)
    A_TrayMenu.Add(i18n("overlay"), e_overlay)
    A_TrayMenu.Add(i18n("caretSymbol"), e_symbol)
    A_TrayMenu.Add(i18n("cursorSymbol"), e_cursorSymbol)
    A_TrayMenu.Add(i18n("border"), e_border)
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("windowInfo"), e_windowInfo)
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("moreSettings"), e_moreSettings)
    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("about"), e_about)
    A_TrayMenu.Add(i18n("Restart"), restartApp)

    A_TrayMenu.Add()
    A_TrayMenu.Add(i18n("Exit"), closeApp)
}

closeApp(*) {
    ProcessClose(updaterPID)
    killJAB()
    revertCursor()
    ExitApp()
}
restartApp(*) {
    ProcessClose(updaterPID)
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
        static timer := 0
        g := createGuiOpt(i18n("windowInfo"), , "AlwaysOnTop")

        if (info.i) {
            g.AddText(, line60)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddLink("Section", getDocsLink("menu/window-info"))
        for v in i18n("windowInfo.list", 1) {
            renderGroupBox(g, v, , "h" uicEdit.h " w" bw)
            gc.%v% := _ := g.AddEdit("xs+20 yp+" uicEdit.yp " ReadOnly cGray -VScroll w" bw - 40)
            _.Text := i18n("windowInfo.tip")
        }
        g.OnEvent("Close", (*) => timer := 0)
        timer := 1
        SetTimer(stateTimer, 50)
        stateTimer() {
            static last := ""
            if !timer {
                last := ""
                SetTimer(, 0)
                return
            }
            try {
                if appPid == WinGetPID("A")
                    return
                list := [
                    WinGetProcessName("A"),
                    WinGetClass("A"),
                    WinGetTitle("A"),
                    WinGetProcessPath("A"),
                ]
                info := arrJoin(list, "-")

                if info != last {
                    for i, v in i18n("windowInfo.list", 1) {
                        gc.%v%.Value := list[i]
                        if list[i] != ""
                            gc.%v%.Opt("cDefault")
                    }
                    last := info
                }
            }
        }
        return g
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
createProcessMenuGui(meta, *) {
    showGui(createUniqueGui(processMenuGui))
    processMenuGui(info) {
        g := createGuiOpt(meta.title)

        if (info.i) {
            g.AddText(, line90)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        column := Map()
        for i, v in meta.cols {
            column.Set(v, i)
        }

        tab := renderTab(g, meta.tab)
        loseFocusOnTab(tab)
        tab.UseTab(1)

        addItem(ruleList, LV) {
            for item in ruleList {
                columnList := []
                for i in meta.cols {
                    val := ""
                    if i == "condition" {
                        if indexOfArr(meta.conditions, item.%i%)
                            val := i18n("condition." item.%i%)
                    } else if i == "trigger" {
                        if indexOfArr(meta.trigger, item.%i%) {
                            val := i18n("trigger." item.%i%)
                        }
                    }
                    else {
                        try val := item.%i%
                    }
                    columnList.Push(val)
                }
                columnList.Push(item.time)
                LV.Add(, columnList*)
            }
        }

        e_handleClick(LV, RowNumber, *) {
            if (!RowNumber) {
                return
            }
            colValue := {}
            for k, v in column {
                colValue.%k% := LV.GetText(RowNumber, v)
            }
            colValue.time := LV.GetText(RowNumber, LV.GetCount("Col"))
            showGui(createUniqueGui(fn_edit.Bind(LV, RowNumber, "edit", colValue)))
        }

        fn_edit(LV, RowNumber, action, colValue, info) {
            g := createGuiOpt(i18n(action "Rule"), , "AlwaysOnTop")

            if (info.i) {
                g.AddText(, line70)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            opt := "xs+20 yp+" uicEdit.yp " w" bw - 40
            layout := " h" uicEdit.h " w" bw

            sectionList := []
            i := 0
            while (i < column.Count) {
                sectionList.Push("")
                i++
            }

            groupLayout := ""
            num := column.Get("hotkey", 0)
            if (num) {
                groupLayout := "xs"
                sectionList[num] := fn_hotkey
                fn_hotkey() {
                    renderGroupBox(g, "match.hotkey", layout)
                    _ := g.AddComboBox(opt, [
                        "",
                        "~LShift Up",
                        "~RShift Up",
                        "~Shift Up",
                        "~Ctrl Up",
                        "~Alt Up",
                        "~Win Up",
                        "~Esc Up",
                        "~^/",
                        "~!+a",
                        "~^Space",
                        "~!Space",
                        "~+Space",
                        "~#Space",
                        "#w",
                    ])
                    try _.Text := colValue.hotkey
                    colValue.hotkey := _.Text
                    _.OnEvent("Change", (i, *) => colValue.hotkey := i.Text)
                    SuppressControlWheel(_.Hwnd)
                }
            }

            num := column.Get("process", 0)
            if (num) {
                sectionList[num] := fn_process
                fn_process() {
                    renderGroupBox(g, "match.process", groupLayout layout)
                    _ := g.AddComboBox(opt, [
                        "",
                        "Code.exe",
                        "Code.exe|WindowsTerminal.exe",
                        "msedge\.exe|chrome\.exe|firefox\.exe",
                        ".*"
                    ])
                    try _.Text := colValue.process
                    colValue.process := _.Text
                    _.OnEvent("Change", (i, *) => (colValue.process := i.Text, updateProcessState(i.Text)))
                    SuppressControlWheel(_.Hwnd)
                }

                updateProcessState(value) {
                    static lastCondition := ""
                    if !column.Get("hotkey", 0)
                        return

                    color := "cC0C0C0"
                    if value == "" {
                        var._conditionCtrl.Opt("+Disabled")
                        if var._conditionCtrl.Text != "" {
                            lastCondition := var._conditionCtrl.Text
                            colValue.condition := var._conditionCtrl.Text := ""
                        }
                    } else {
                        var._conditionCtrl.Opt("-Disabled")
                        if var._conditionCtrl.Text == "" && lastCondition
                            colValue.condition := var._conditionCtrl.Text := lastCondition

                        if colValue.condition
                            color := "cDefault"
                    }
                    var._classEditCtrl.Opt(color)
                    var._titleEditCtrl.Opt(color)
                }
            }

            num := column.Get("trigger", 0)
            if (num) {
                sectionList[num] := fn_trigger
                fn_trigger() {
                    triggerList := [""]
                    for v in meta.trigger {
                        triggerList.Push(i18n("trigger." v))
                    }
                    renderGroupBox(g, "match.trigger", "xs" layout)
                    _ := g.AddDropDownList(opt " r9", triggerList)
                    try _.Text := colValue.trigger
                    colValue.trigger := _.Text
                    _.OnEvent("Change", (i, *) => colValue.trigger := i.Text)
                    SuppressControlWheel(_.Hwnd)
                }
            }

            num := column.Get("condition", 0)
            if (num) {
                sectionList[num] := fn_condition
                fn_condition() {
                    conditionList := [""]
                    for v in meta.conditions
                        conditionList.Push(i18n("condition." v))

                    renderGroupBox(g, "match.condition", "xs" layout)
                    var._conditionCtrl := _ := g.AddDropDownList(opt " r9", conditionList)
                    try _.Text := colValue.condition
                    colValue.condition := _.Text
                    _.OnEvent("Change", (i, *) => (updateConditionState(i.Text), colValue.condition := i.Text))
                    SuppressControlWheel(_.Hwnd)
                }
                updateConditionState(conditionText) {
                    isMonitor := conditionText == i18n("condition.idleTimer") || conditionText == i18n("condition.textMonitor") || conditionText == i18n("condition.hotkeyMonitor")
                    isClass := conditionText == i18n("condition.class") || conditionText == i18n("condition.classAndTitle")
                    isTitle := conditionText == i18n("condition.title") || conditionText == i18n("condition.classAndTitle")

                    try var._tthEditCtrl.Opt(isMonitor ? "cDefault" : "cC0C0C0")
                    try var._tthEditCtrl.Opt(isMonitor ? "-ReadOnly" : "+ReadOnly")
                    try var._classEditCtrl.Opt(isClass ? "cDefault" : "cC0C0C0")
                    try var._titleEditCtrl.Opt(isTitle ? "cDefault" : "cC0C0C0")

                    try var._tthEditCtrl.Delete()
                    switch conditionText {
                        case i18n("condition.idleTimer"):
                            try var._tthGroupCtrl.Text := i18n("condition.idleTimer.label")
                            try var._tthEditCtrl.Text := colValue.idleTimer
                            try var._tthEditCtrl.Add(["", "60000", "600000"])
                        case i18n("condition.textMonitor"):
                            try var._tthGroupCtrl.Text := i18n("condition.textMonitor.label")
                            try var._tthEditCtrl.Text := colValue.textMonitor
                            try var._tthEditCtrl.Add(["", "abc", "a.*c", "a\w{5}c", "//\s|\n{2}"])
                        case i18n("condition.hotkeyMonitor"):
                            try var._tthGroupCtrl.Text := i18n("condition.hotkeyMonitor")
                            try var._tthEditCtrl.Text := colValue.hotkeyMonitor
                            try var._tthEditCtrl.Add(["", "^a", "^s", "^/|!+a", "^a>^s|^a>^f"])
                        default:
                            try var._tthGroupCtrl.Text := i18n("match.textMonitorOrHotkeyMonitorOrIdleTimer")
                            try var._tthEditCtrl.Text := arrJoin([
                                colValue.textMonitor ? colValue.textMonitor : i18n("none"),
                                colValue.hotkeyMonitor ? colValue.hotkeyMonitor : i18n("none"),
                                colValue.idleTimer != "" ? colValue.idleTimer : i18n("none")
                            ], "     ")
                            try var._tthEditCtrl.Opt("-Number")
                    }
                }
            }

            num := column.Get("class", 0)
            if (num) {
                sectionList[num] := fn_class
                fn_class() {
                    renderGroupBox(g, "match.class", "xs" layout)
                    var._classEditCtrl := _ := g.AddEdit(opt " r1")
                    try _.Text := colValue.class
                    _.OnEvent("Change", (i, *) => colValue.class := i.Text)
                }
            }

            num := column.Get("title", 0)
            if (num) {
                sectionList[num] := fn_title
                fn_title() {
                    renderGroupBox(g, "match.title", "xs" layout)
                    var._titleEditCtrl := _ := g.AddEdit(opt " r1")
                    try _.Text := colValue.title
                    _.OnEvent("Change", (i, *) => colValue.title := i.Text)
                }
            }

            num := column.Get("capture", 0)
            if (num) {
                sectionList[num] := fn_capture
                fn_capture() {
                    captureList := ["", "", "", "", "", "", "", ""]
                    captureOffsetList := ["", "", "", "", "", "", "", ""]
                    modeNameList := ["GUI", "UIA", "HOOK", "HOOK_DLL", "MSAA", "WPF", "ACC"]
                    if var.symbolJABActive
                        modeNameList.Push("JAB")
                    ddlControls := captureList.Clone()
                    renderGroupBox(g, "symbolCaretCapture", "xs h" uicDDL.h * 1.5 " w" bw)
                    for i, v in captureList {
                        if i == 1 || i == 5 {
                            _opt := "xs+20 yp+" uicDDL.yp
                        } else {
                            _opt := "yp"
                            g.AddText("yp", ">")
                        }
                        ddlControls[i] := _ := g.AddDropDownList(_opt " r9 w" bw / 5 - 5, ["", modeNameList*])
                        try _.Text := StrSplit(colValue.capture, ">")[i]
                        captureList[i] := _.Text
                        _.num := i
                        SuppressControlWheel(_.Hwnd)
                    }

                    renderGroupBox(g, "symbolCaretCapture.offset", "xs h" uicDDL.h * 1.5 " w" bw)
                    for i, v in captureOffsetList {
                        if i == 1 || i == 5 {
                            _opt := "xs+20 yp+" uicDDL.yp
                        } else {
                            _opt := "yp"
                            g.AddText("yp", ">")
                        }
                        _ := g.AddComboBox(_opt " w" bw / 5 - 5, ["", "0/0"])
                        try _.Text := StrSplit(colValue.captureOffset, ">")[i]
                        captureOffsetList[i] := _.Text
                        _.num := i
                        _.OnEvent("Change", (ctrl, *) => (
                            val := ctrl.Text,
                            RegExMatch(val, "^-?\d+/-?\d+$") || val == "" ? (captureOffsetList[ctrl.num] := ctrl.Text, colValue.captureOffset := arrJoin(captureOffsetList, ">", 1)) : ""
                        ))
                        SuppressControlWheel(_.Hwnd)
                    }

                    colValue.capture := arrJoin(captureList, ">", 1)
                    colValue.captureOffset := arrJoin(captureOffsetList, ">", 1)

                    for ctrl in ddlControls
                        (ctrl == "") ? 0 : ctrl.OnEvent("Change", e_changeDDL)

                    e_changeDDL(ctrl, *) {
                        num := ctrl.num
                        captureList[num] := ctrl.Text
                        for i, targetCtrl in ddlControls {
                            if i == num
                                continue
                            cleanList := []
                            for v in modeNameList {
                                idx := indexOfArr(captureList, v)
                                (idx && idx != i) ? 0 : cleanList.Push(v)
                            }
                            currentText := ""
                            try currentText := targetCtrl.Text
                            targetCtrl.Delete()
                            targetCtrl.Add(["", cleanList*])
                            try targetCtrl.Text := currentText
                        }
                        colValue.capture := arrJoin(captureList, ">", 1)
                    }
                }
            }

            num := column.Get("offset", 0)
            btnLayout := "xs"
            if (num) {
                btnLayout := "Section"
                sectionList.Push(fn_offset)
                fn_offset() {
                    pages := []
                    for v in var.screenList {
                        pages.push(i18n("offset.screen") " " v.num)
                    }
                    tab := renderTab(g, pages, "xs w" bw)
                    loseFocusOnTab(tab)

                    offsetMap := Map()
                    if (action == "edit") {
                        for o in StrSplit(colValue.offset, "|") {
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
                        _ := g.AddEdit("yp Limit5 r1")
                        _.Value := x
                        _.OnEvent("Change", e_changeOffset.Bind(n, "x"))

                        g.SetFont("Bold")
                        g.AddText("xs", i18n("offset.offset_y"))
                        g.SetFont("Norm")
                        _ := g.AddEdit("yp Limit5 r1")
                        _.Value := y
                        _.OnEvent("Change", e_changeOffset.Bind(n, "y"))
                    }

                    e_changeOffset(n, pos, item, *) {
                        if !offsetMap.Has(n)
                            offsetMap.Set(n, { x: 0, y: 0 })
                        offsetMap.Get(n).%pos% := returnNumber(item.value)

                        colValue.offset := ""
                        for k, v in offsetMap {
                            colValue.offset .= "|" k "/" v.x "/" v.y
                        }
                        colValue.offset := SubStr(colValue.offset, 2)

                        if process := colValue.process {
                            colValue.offsetMap := Map()
                            for o in StrSplit(colValue.offset, "|") {
                                screenNum := SubStr(o, 1, 1)
                                posPart := StrSplit(SubStr(o, 3), "/")
                                colValue.offsetMap.Set(screenNum, {
                                    x: posPart[1],
                                    y: posPart[2]
                                })
                            }
                            var._previewOffsetMap.Set(process, colValue)
                        }
                    }
                }
            }

            if meta.section == "Window.Rule" {
                sectionList.InsertAt(4, fn_content)
                fn_content() {
                    var._tthGroupCtrl := renderGroupBox(g, "match.textMonitorOrHotkeyMonitorOrIdleTimer", "xs" layout)
                    var._tthEditCtrl := _ := g.AddComboBox(opt)
                    SuppressControlWheel(_.Hwnd)

                    switch colValue.condition {
                        case i18n("condition.idleTimer"):
                            try _.Text := colValue.idleTimer
                            var._tthGroupCtrl.Text := i18n("condition.idleTimer.label")
                            var._tthEditCtrl.Add(["", "60000", "600000"])
                        case i18n("condition.textMonitor"):
                            try _.Text := colValue.textMonitor
                            var._tthGroupCtrl.Text := i18n("condition.textMonitor.label")
                            var._tthEditCtrl.Add(["", "abc", "a.*c", "a\w{5}c", "//\s|\n{2}"])
                        case i18n("condition.hotkeyMonitor"):
                            try _.Text := colValue.hotkeyMonitor
                            var._tthGroupCtrl.Text := colValue.condition
                            var._tthEditCtrl.Add(["", "^a", "^s", "^/|!+a", "^a>^s|^a>^f"])
                    }
                    _.OnEvent("Change", e_content)
                    e_content(i, *) {
                        switch var._conditionCtrl.Text {
                            case i18n("condition.idleTimer"):
                                colValue.idleTimer := i.Text
                            case i18n("condition.textMonitor"):
                                colValue.textMonitor := i.Text
                            case i18n("condition.hotkeyMonitor"):
                                colValue.hotkeyMonitor := i.Text
                        }
                    }
                }
            }

            for v in sectionList
                v ? v() : ""

            try updateConditionState(colValue.condition)
            try updateProcessState(colValue.process)

            tab.UseTab(0)

            needWindowInfo := InStr(meta.section, "Window.") || InStr(meta.section, "Hotkey.")

            if needWindowInfo
                opt := " w" bw / 3 - g.MarginX / 3
            else
                opt := " w" bw / 2 - g.MarginX / 4

            g.AddButton(btnLayout opt, i18n("ok")).OnEvent("Click", fn_set.Bind(LV, RowNumber, action, colValue))
            if action == "edit"
                g.AddButton("yp" opt, i18n("delete")).OnEvent("Click", fn_set.Bind(LV, RowNumber, "delete", colValue))
            else
                g.AddButton("yp" opt, i18n("cancel")).OnEvent("Click", (*) => (g.Destroy(), var._previewOffsetMap.Clear()))

            if needWindowInfo
                g.AddButton("yp" opt, i18n("windowInfo")).OnEvent("Click", e_windowInfo)

            fn_set(LV, RowNumber, action, colValue, *) {
                g.Destroy()
                var._previewOffsetMap.Clear()
                time := colValue.time
                section := meta.section "." time
                if action == "delete" {
                    try {
                        IniDelete(configFile, section)
                        LV.Delete(RowNumber)
                        try autoHdrLV(LV)
                        restartJAB()
                        parseWindowRule()
                        registerHotkey()
                        updateWindowHotkey()
                        initMonitor()
                    }
                    return
                }
                cols := []
                try {
                    for v in meta.cols {
                        if v == "condition" && colValue.%v% {
                            val := conditionTextMap.Get(colValue.%v%)
                            col := i18n("condition." val)
                        } else if v == "trigger" && colValue.%v%{
                            val := triggerTextMap.Get(colValue.%v%)
                            col := i18n("trigger." val)
                        }
                        else {
                            val := colValue.%v%
                            col := val
                        }
                        cols.Push(col)
                        if val {
                            writeIni(v, val, section)
                        } else {
                            IniDelete(configFile, section, v)
                        }
                    }
                    cols.Push(time)
                    trigger := ""
                    try {
                        trigger := triggerTextMap.Get(colValue.trigger, "")
                    } catch {
                        trigger := LV.trigger
                    }
                    writeIni("trigger", trigger, section)
                    restartJAB()
                    parseWindowRule()
                    registerHotkey()
                    updateWindowHotkey()
                    initMonitor()
                    if (action == "edit") {
                        LV.Modify(RowNumber, , cols*)
                    } else {
                        LV.Insert(RowNumber, , cols*)
                    }
                    try autoHdrLV(LV)
                } catch {
                    try IniDelete(configFile, section)
                }
            }

            g.OnEvent("Close", (*) => var._previewOffsetMap.Clear())

            return g
        }

        columnText := []
        for v in meta.cols {
            columnText.Push(i18n("match." v))
        }
        columnText.Push(i18n("match.time"))

        switch meta.section {
            case "Window.Rule":
                g.AddLink("Section", meta.link)
                LV := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, columnText)
                LV.Opt("-Redraw")
                for trigger in meta.trigger {
                    for p, ruleList in var.WindowRule.Get(trigger)
                        try addItem(ruleList, LV)
                }
                for p, ruleList in var.WindowRule.Get("")
                    try addItem(ruleList, LV)
                LV.Opt("+Redraw")
                autoHdrLV(LV)
                LV.OnEvent("DoubleClick", e_handleClick)
                g.AddButton("xs w" w, i18n("addRule")).OnEvent("Click", e_add.Bind(LV))

            case "Hotkey.Rule":
                g.AddLink("Section", meta.link)
                LV := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, columnText)
                LV.Opt("-Redraw")
                for p, ruleList in var.hotkeyRule
                    try addItem(ruleList, LV)
                LV.Opt("+Redraw")
                autoHdrLV(LV)
                LV.OnEvent("DoubleClick", e_handleClick)
                g.AddButton("xs w" w, i18n("addRule")).OnEvent("Click", e_add.Bind(LV))
            default:
                for i, trigger in meta.trigger {
                    tab.UseTab(i)
                    g.AddLink("Section", meta.link)
                    if column.Get("capture", 0) {
                        _ := g.AddCheckbox("xs", i18n("trigger.showCaptureMode"))
                        _.Value := var._showCaptureMode
                        _.OnEvent("Click", (ctrl, *) => (val := ctrl.Value, showCaptureMode(var._showCaptureMode := val)))
                    }
                    LV := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, columnText)
                    LV.trigger := trigger
                    LV.Opt("-Redraw")
                    ruleMap := var.%StrReplace(meta.section, ".", "")%
                    for p, ruleList in ruleMap.Get(trigger) {
                        if type(ruleList) != "Array"
                            ruleList := [ruleList]
                        addItem(ruleList, LV)
                    }
                    for p, ruleList in ruleMap.Get("") {
                        if type(ruleList) != "Array"
                            ruleList := [ruleList]
                        addItem(ruleList, LV)
                    }
                    LV.Opt("+Redraw")
                    autoHdrLV(LV)
                    LV.OnEvent("DoubleClick", e_handleClick)
                    g.AddButton("xs w" w, i18n("addRule")).OnEvent("Click", e_add.Bind(LV))
                }
        }

        e_add(LV, *) {
            colValue := {
                time: returnTimeId(var._ruleIds)
            }
            for k, v in column {
                if (!colValue.HasProp(k)) {
                    colValue.%k% := ""
                }
            }
            showGui(createUniqueGui(fn_edit.Bind(LV, 1, "add", colValue)))
        }
        g.OnEvent("Close", (*) => g.Destroy())
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

toggleApp(*) {
    if var._paused
        resumeApp()
    else
        suspendApp()
}

resumeApp() {
    if !var._paused
        return

    SetTimer(_resumeAppWorker, -200)
    _resumeAppWorker() {
        if !var._paused
            return

        Critical("On")
        var._paused := 0

        updateTrayTip()
        setTrayIcon(var.iconRunning, 0)

        if var.cursorActive
            loadCursor(currentState, 1)
        if var.symbolJABActive
            restartJAB()

        Critical("Off")
    }
}
suspendApp() {
    if var._paused
        return
    SetTimer(_suspendAppWorker, -200)
    _suspendAppWorker() {
        if var._paused
            return

        Critical("On")
        var._paused := 1

        updateTrayTip()
        clearAllRegisteredHotkeys()

        global lastBorderState := ""
        setTrayIcon(var.iconPaused, 1)

        if var.cursorActive
            revertCursor()
        if var.overlayActive
            hideOverlay()
        if var.caretSymbolType
            hideCaretSymbol()
        if var.cursorSymbolType
            hideCursorSymbol()
        if var.borderActive
            hideBorder()
        if var.symbolJABActive
            killJAB(0)

        Critical("Off")
    }
}

; 显示状态码和转换码
showStateCode(show, *) {
    if show {
        if var._showCaptureMode
            showCaptureMode(0)
        SetTimer(showStateCodeTimer, 25)
        return
    }
    ToolTip()
    SetTimer(showStateCodeTimer, 0)
}

showStateCodeTimer() {
    info := IME.CheckInputMode()
    ToolTip(" " i18n("inputMethodDetectionMode.stateCode") ": " info.stateMode "`n " i18n("inputMethodDetectionMode.conversionCode") ": " info.conversionMode "`n CLSID: " info.clsId)
}

; 显示当前的光标捕获模式
showCaptureMode(show, *) {
    if show {
        if var._showStateCode
            showStateCode(0)
        SetTimer(showCaptureModeTimer, 25)
        return
    }
    ToolTip()
    SetTimer(showCaptureModeTimer, 0)
}

showCaptureModeTimer() {
    ToolTip(" " (var._lastCaptureMode ? var._lastCaptureMode : i18n("none")))
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
