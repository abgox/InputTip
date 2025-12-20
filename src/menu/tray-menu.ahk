; InputTip

#Include "*i startup.ahk"
#Include "*i check-update.ahk"
#Include "*i input-method.ahk"
#Include "*i cursor-mode.ahk"
#Include "*i bw-list.ahk"
#Include "*i symbol-pos.ahk"
#Include "*i app-offset.ahk"
#Include "*i switch-window.ahk"
#Include "*i auto-exit.ahk"
#Include "*i about.ahk"

#Include "*i scheme-cursor.ahk"
#Include "*i scheme-symbol.ahk"
#Include "*i other-config.ahk"

fontList := getFontList()
fontList.InsertAt(1, "Microsoft YaHei")

makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add(lang("tray.guide"), fn_guide)
    fn_guide(*) {
        createTipGui([{
            opt: "",
            text: lang("tray.guide_intro")
        }, {
            opt: "",
            text: lang("tray.guide_tip1"),
        }, {
            opt: "",
            text: lang("tray.guide_tip2")
        }, {
            opt: "",
            text: lang("tray.guide_tip3")
        }], lang("tray.guide_title")).Show()
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.startup"), fn_startup)
    if (isStartUp) {
        A_TrayMenu.Check(lang("tray.startup"))
    }

    if (!A_IsCompiled) {
        A_TrayMenu.Add(lang("tray.admin_mode"), fn_admin_mode)
        fn_admin_mode(*) {
            A_TrayMenu.ToggleCheck(lang("tray.admin_mode"))
            global runCodeWithAdmin := !runCodeWithAdmin
            writeIni("runCodeWithAdmin", runCodeWithAdmin)
            if (runCodeWithAdmin) {
                fn_restart()
            } else {
                createTipGui([{
                    opt: "cRed",
                    text: lang("tray.admin_cancel_tip1"),
                }, {
                    opt: "cRed",
                    text: lang("tray.admin_cancel_tip2")
                }], "InputTip - " lang("tray.admin_mode")).Show()
            }
        }
        if (runCodeWithAdmin) {
            A_TrayMenu.Check(lang("tray.admin_mode"))
        }
    }

    A_TrayMenu.Add(lang("tray.create_shortcut"), fn_create_shortcut)

    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.pause_run"), pauseApp)
    A_TrayMenu.Default := lang("tray.pause_run")
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.input_method"), fn_input_mode)
    A_TrayMenu.Add(lang("tray.hotkey_switch"), (*) => (
        setHotKeyGui([{
            config: "hotkey_CN",
            tip: lang("state.CN")
        }, {
            config: "hotkey_EN",
            tip: lang("state.EN")
        }, {
            config: "hotkey_Caps",
            tip: lang("state.Caps")
        }], lang("tray.hotkey_switch"))
    ))
    A_TrayMenu.Add(lang("tray.auto_switch"), fn_switch_window)

    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.cursor_scheme"), fn_scheme_cursor)
    A_TrayMenu.Add(lang("tray.symbol_scheme"), fn_scheme_symbol)
    A_TrayMenu.Add(lang("tray.symbol_near_cursor"), fn_symbol_pos)
    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.bw_list"), fn_bw_list)
    A_TrayMenu.Add(lang("tray.window_info"), fn_process_info)
    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.cursor_mode"), fn_cursor_mode)
    A_TrayMenu.Add(lang("tray.special_offset"), fn_app_offset)

    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.other_settings"), fn_ohter_config)
    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.about"), fn_about)
    A_TrayMenu.Add(lang("tray.restart"), fn_restart)

    A_TrayMenu.Add()
    A_TrayMenu.Add(lang("tray.exit"), fn_exit)
}

fn_exit(*) {
    killJAB()
    revertCursor(cursorInfo)
    ExitApp()
}
fn_restart(*) {
    if (enableJABSupport) {
        killJAB()
    }

    if (A_IsCompiled) {
        Run('"' A_ScriptFullPath '" ' keyCount)
    } else {
        Run('"' A_AhkPath '" "' A_ScriptFullPath '" ' keyCount)
    }
    ExitApp()
}

fn_create_shortcut(*) {
    if (isStartUp = 1) {
        FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", A_Desktop "\" fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", fileDesc, favicon, , , 7)
    } else {
        if (A_IsCompiled) {
            FileCreateShortcut(A_ScriptFullPath, A_Desktop "\" fileLnk, , , fileDesc, favicon, , , 7)
        } else {
            FileCreateShortcut(A_AhkPath, A_Desktop "\" fileLnk, , '"' A_ScriptFullPath '"', fileDesc, favicon, , , 7)
        }
    }
}

fn_update_user(uname, *) {
    global userName := uname
    createUniqueGui(updateUserGui).Show()
    updateUserGui(info) {
        g := createGuiOpt("InputTip - " lang("tray.set_username_title"))
        tab := g.AddTab3("-Wrap", [lang("tray.set_username_title"), lang("common.about")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, "-------------------------------------------------------------------------")

        g.AddText(, lang("tray.current_username"))
        _ := g.AddEdit("yp")
        _._config := "userName"
        _.Value := uname
        _.OnEvent("Change", fn_change)
        fn_change(item, *) {
            global userName := item.value
        }

        g.AddText("xs ReadOnly cGray", lang("tray.username_check_tip")).Focus()

        tab.UseTab(2)
        g.AddEdit("ReadOnly r6 w" bw, lang("tray.username_about"))

        g.OnEvent("Close", e_close)
        e_close(*) {
            writeIni("userName", userName, "UserInfo")
            if (A_IsAdmin) {
                if (A_IsCompiled) {
                    if (isStartUp = 1) {
                        createScheduleTask(A_ScriptFullPath, "abgox.InputTip.noUAC", [0], , , 1)
                    }
                    if (enableJABSupport) {
                        createScheduleTask(A_ScriptDir "\InputTip.JAB.JetBrains.exe", "abgox.InputTip.JAB.JetBrains", , "Limited")
                    }
                } else {
                    if (isStartUp = 1) {
                        createScheduleTask(A_AhkPath, "abgox.InputTip.noUAC", [A_ScriptFullPath, 0], , , 1)
                    }
                    if (enableJABSupport) {
                        createScheduleTask(A_AhkPath, "abgox.InputTip.JAB.JetBrains", [A_ScriptDir "\InputTip.JAB.JetBrains.ahk"], "Limited")
                    }
                }
            }
        }
        return g
    }
}
fn_process_info(*) {
    createUniqueGui(processInfoGui).Show()
    processInfoGui(info) {
        g := createGuiOpt("InputTip - " lang("tray.window_info_title"), , "AlwaysOnTop")

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "-"

        g.AddText("cRed Center w" bw, lang("gui.realtime_info")).Focus()
        g.AddText(, line)

        createGuiOpt("").AddText(, " ").GetPos(, , &__w)
        gc._window_info := g.AddButton("xs w" bw, lang("gui.click_get"))
        gc._window_info.OnEvent("Click", e_window_info)
        g.AddText("xs cRed", lang("gui.current_name")).GetPos(, , &_w)
        _width := bw - _w - g.MarginX + __w
        gc.app_name := g.AddEdit("yp ReadOnly -VScroll w" _width)
        g.AddText("xs cRed", lang("gui.current_title")).GetPos(, , &_w)
        gc.app_title := g.AddEdit("yp ReadOnly -VScroll w" _width)
        g.AddText("xs cRed", lang("gui.current_path")).GetPos(, , &_w)
        gc.app_path := g.AddEdit("yp ReadOnly -VScroll w" _width)
        e_window_info(*) {
            if (gc.timer2) {
                gc.timer2 := 0
                gc._window_info.Text := lang("gui.click_get")
                return
            }
            gc.timer2 := 1
            gc._window_info.Text := lang("gui.stop_get")
            SetTimer(statusTimer, 25)
            statusTimer() {
                static first := "", last := ""

                if (!gc.timer2) {
                    SetTimer(, 0)
                    first := ""
                    last := ""
                    return
                }
                try {
                    if (!first) {
                        name := WinGetProcessName("A")
                        title := WinGetTitle("A")
                        path := WinGetProcessPath("A")
                        gc.app_name.Value := name
                        gc.app_title.Value := title
                        gc.app_path.Value := path
                        first := name title path
                    }

                    name := WinGetProcessName("A")
                    title := WinGetTitle("A")
                    path := WinGetProcessPath("A")
                    info := name title path
                    if (info = last || info = first) {
                        return
                    }
                    gc.app_name.Value := name
                    gc.app_title.Value := title
                    gc.app_path.Value := path
                    last := info
                }
            }
        }
        return g
    }
}

/**
 * 通用的 进程级、标题级匹配菜单
 * @param {Object} args 传入的参数，格式为 {title: "窗口标题", ...}
 * @param {String} args.title - 窗口标题
 * @param {String} args.tab - 标签页名称
 * @param {String} args.config - 配置项名称
 * @param {Func} cb_updateVar 更新变量的回调函数
 */
fn_common(args, cb_updateVar) {
    showGui()
    showGui(deep := 0) {
        createUniqueGui(commonGui).Show()
        commonGui(info) {
            g := createGuiOpt("InputTip - " args.title)
            tab := g.AddTab3("-Wrap", [args.tab, lang("common.about")])
            tab.UseTab(1)
            g.AddLink("Section cRed", lang("gui.help_tip"))

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            LV := "LV_" A_Now

            gc.%LV% := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, [lang("common.process_name"), lang("common.match_scope"), lang("common.match_mode"), lang("common.match_title"), lang("common.create_time")])

            gc.%LV%.Opt("-Redraw")
            valueArr := StrSplit(readIniSection(args.config), "`n")
            for v in valueArr {
                kv := StrSplit(v, "=", , 2)
                part := StrSplit(kv[2], ":", , 4)
                if (part.Length >= 2) {
                    name := part[1]
                    isGlobal := part[2]
                    isRegex := ""
                    title := ""
                    if (part.Length == 4) {
                        isRegex := part[3]
                        title := part[4]
                    }

                    tipGlobal := isGlobal ? lang("common.process_level") : lang("common.title_level")

                    tipRegex := isRegex ? lang("common.regex") : lang("common.equal")
                    gc.%LV%.Add(, name, tipGlobal, tipRegex, title, kv[1])
                } else {
                    IniDelete("InputTip.ini", args.config, kv[1])
                }
            }
            gc.%LV%.Opt("+Redraw")
            autoHdrLV(gc.%LV%)

            gc.%LV%.OnEvent("DoubleClick", handleClick)
            gc.%LV%._LV := LV
            gc.%LV%._config := args.config
            _ := g.AddButton("xs w" w / 2, lang("common.quick_add"))
            _.OnEvent("Click", e_add)
            _._LV := LV
            _._config := args.config
            _._parentTitle := args.title
            e_add(item, *) {
                try {
                    fn_add(item._LV, item._config, item._parentTitle)
                } catch {
                    fn_add(item._LV, item._config, "")
                }
            }

            _ := g.AddButton("yp w" w / 2, lang("common.manual_add"))
            _.OnEvent("Click", e_add_manually)
            _._LV := LV
            _._config := args.config

            e_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    tipGlobal: lang("common.process_level"),
                    tipRegex: lang("common.equal"),
                    title: "",
                    id: returnId(),
                    configName: item._config
                }
                fn_edit(gc.%item._LV%, 1, "add", itemValue).Show()
            }


            handleClick(LV, RowNumber) {
                if (!RowNumber) {
                    return
                }
                exe_name := LV.GetText(RowNumber)
                if (gc.w.subGui) {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }

                itemValue := {
                    exe_name: LV.GetText(RowNumber, 1),
                    tipGlobal: LV.GetText(RowNumber, 2),
                    tipRegex: LV.GetText(RowNumber, 3),
                    title: LV.GetText(RowNumber, 4),
                    id: LV.GetText(RowNumber, 5),
                    configName: LV._config
                }
                createGui(editGui).Show()
                editGui(info) {
                    return fn_edit(gc.%LV._LV%, RowNumber, "edit", itemValue)
                }
            }

            fn_edit(LV, RowNumber, action, itemValue) {
                ; Auto add to symbol whitelist
                needAddWhiteList := 1

                if (action == "edit") {
                    actionText := lang("common.edit")
                } else {
                    actionText := lang("common.add")
                }

                label := action == "edit" ? lang("gui.editing_rule") : lang("gui.adding_rule")

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                if (action != "edit" && itemValue.configName != "App-ShowSymbol") {
                    g.AddText("cRed", lang("gui.add_to_whitelist"))
                    _ := g.AddDropDownList("yp", [lang("gui.add_to_whitelist_no"), lang("gui.add_to_whitelist_yes")])
                    _.Value := needAddWhiteList + 1
                    _.OnEvent("Change", e_change)
                    e_change(item, *) {
                        needAddWhiteList := item.value - 1
                    }
                    g.AddText("xs cGray", lang("gui.add_to_whitelist_tip"))
                }

                scaleWidth := bw / 1.5

                g.AddText(, lang("gui.process_name_label"))
                _ := g.AddEdit("yp w" scaleWidth, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
                }

                g.AddText("xs", lang("gui.match_scope_label"))
                _ := g.AddDropDownList("yp w" scaleWidth, [lang("common.process_level"), lang("common.title_level")])
                _.Text := itemValue.tipGlobal
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.tipGlobal := v
                }

                g.AddText("xs cGray", lang("gui.match_scope_tip"))
                g.AddText("xs", lang("gui.match_mode_label"))
                _ := g.AddDropDownList("yp w" scaleWidth, [lang("common.equal"), lang("common.regex")])
                _.Text := itemValue.tipRegex
                _.OnEvent("Change", e_changeMatch)
                e_changeMatch(item, *) {
                    v := item.Text
                    itemValue.tipRegex := v
                }

                g.AddText("xs", lang("gui.match_title_label"))
                _ := g.AddEdit("yp w" scaleWidth)
                _.Text := itemValue.title
                _.OnEvent("Change", e_changeTitle)
                e_changeTitle(item, *) {
                    v := item.Text
                    itemValue.title := v
                }

                g.AddButton("xs w" bw / 1.2, lang("common.complete_" action)).OnEvent("Click", e_set)
                e_set(*) {
                    fn_set(action, 0)
                }
                if (action == "edit") {
                    g.AddButton("xs w" bw / 1.2, lang("common.delete_it")).OnEvent("Click", e_delete)
                    e_delete(*) {
                        fn_set(action, 1)
                    }
                }

                fn_set(action, delete) {
                    g.Destroy()

                    if (delete) {
                        try {
                            IniDelete("InputTip.ini", itemValue.configName, itemValue.id)
                            LV.Delete(RowNumber)
                        }
                    } else {
                        isGlobal := itemValue.tipGlobal == lang("common.process_level") ? 1 : 0
                        isRegex := itemValue.tipRegex == lang("common.regex") ? 1 : 0
                        value := itemValue.exe_name ":" isGlobal ":" isRegex ":" itemValue.title
                        ; Save the rule
                        writeIni(itemValue.id, value, itemValue.configName, "InputTip.ini")
                        if (action == "edit") {
                            LV.Modify(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.id)
                        } else {
                            LV.Insert(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.id)
                        }

                        if (needAddWhiteList) {
                            updateWhiteList(itemValue.exe_name)
                        }
                    }

                    autoHdrLV(LV)

                    cb_updateVar()
                }
                return g
            }

            fn_add(parentLV, configName, parentTitle) {
                args := {
                    title: parentTitle " - " lang("common.quick_add"),
                    configName: configName,
                    LV: parentLV,
                }
                createProcessListGui(args, addClick, e_add_manually)

                addClick(args) {
                    windowInfo := args.windowInfo
                    RowNumber := args.RowNumber

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        tipGlobal: lang("common.process_level"),
                        tipRegex: lang("common.equal"),
                        title: windowInfo.title,
                        id: windowInfo.id,
                        configName: args.parentArgs.configName
                    }
                    fn_edit(gc.%args.parentArgs.LV%, RowNumber, "add", itemValue).Show()
                }

                e_add_manually(args) {
                    windowInfo := args.windowInfo

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        tipGlobal: lang("common.process_level"),
                        tipRegex: lang("common.equal"),
                        title: windowInfo.title,
                        id: windowInfo.id,
                        configName: args.parentArgs.configName
                    }
                    fn_edit(gc.%args.parentArgs.LV%, 1, "add", itemValue).Show()
                }
            }
            tab.UseTab(2)
            g.AddEdit("ReadOnly VScroll r12 w" w, lang("about_text.fn_common"))
            g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/special-list">Lists</a>')
            return g
        }
    }
}


fn_white_list(*) {
    fn_common({
        title: lang("bw_list.set_white_list"),
        tab: lang("bw_list.white_list"),
        config: "App-ShowSymbol",
        link: 'Related links: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">Symbol List Mechanism</a>'
    }, fn)
    fn() {
        global app_ShowSymbol := StrSplit(readIniSection("App-ShowSymbol"), "`n")
        restartJAB()
    }
}

/**
 * 解析鼠标样式文件夹目录，并生成目录列表
 * @returns {Array} 目录路径列表
 */
getCursorDir() {
    dirList := ":InputTipCursor\default\oreo-red:InputTipCursor\default\oreo-blue:InputTipCursor\default\oreo-green:"
    loopDir("InputTipCursor")
    loopDir(path) {
        Loop Files path "\*", "DR" {
            if (A_LoopFileAttrib ~= "D") {
                loopDir A_LoopFilePath
                if (!hasChildDir(A_LoopFilePath)) {
                    if (!InStr(dirList, ":" A_LoopFilePath ":")) {
                        dirList .= A_LoopFilePath ":"
                    }
                }
            }
        }
    }
    dirList := StrSplit(SubStr(dirList, 2, StrLen(dirList) - 2), ":")
    return dirList
}

/**
 * 解析图片目录，并生成路径列表
 * @param {String} picDir 图片目录
 * @param {String} topList 顶部列表，会在最前面
 * @returns {Array} 路径列表
 * @example
 * getPicList("InputTipIcon", ":InputTipIcon\default\app.png:InputTipIcon\default\app-paused.png:")
 */
getPicList(picDir, topList := "") {
    picList := topList ? topList : ":"
    Loop Files picDir "\*", "R" {
        if (A_LoopFileExt = "png" && !InStr(picList, ":" A_LoopFilePath ":")) {
            picList .= A_LoopFilePath ":"
        }
    }

    picList := StrSplit(SubStr(picList, 2, StrLen(picList) - 2), ":")
    return picList
}

/**
 * 获取字体名称列表
 */
getFontList() {
    list := []
    for v in ["HKEY_CURRENT_USER", "HKEY_LOCAL_MACHINE"] {
        loop reg v "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        {
            ; 去除注册表项中的括号及后缀（如 "(TrueType)"）
            list.Push(RegExReplace(A_LoopRegName, "\s*\(.*?\)$", ""))
        }
    }
    return list
}

pauseApp(*) {
    updateTip(!A_IsPaused)
    if (A_IsPaused) {
        A_TrayMenu.Uncheck(lang("tray.pause_run"))
        setTrayIcon(iconRunning, 0)
        reloadSymbol()
        reloadCursor()
        restartJAB()
    } else {
        A_TrayMenu.Check(lang("tray.pause_run"))
        setTrayIcon(iconPaused, 1)
        hideSymbol()
        if (enableJABSupport) {
            killJAB(0)
        }
        if (changeCursor) {
            revertCursor(cursorInfo)
        }
    }
    Pause(-1)

    for state in ["CN", "EN", "Caps"] {
        if (%"hotkey_" state%) {
            try {
                Hotkey(%"hotkey_" state%, "Toggle")
            }
        }
    }
}

/**
 * 启动 JAB 进程
 * @returns {1 | 0} 1/0: 是否存在错误
 */
runJAB() {
    if isJAB
        return
    if (A_IsCompiled) {
        try {
            if (compareVersion(currentVersion, FileGetVersion("InputTip.JAB.JetBrains.exe")) != 0) {
                FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
            }
        } catch {
            FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
        }
        try {
            done := createScheduleTask(A_ScriptDir "\InputTip.JAB.JetBrains.exe", "abgox.InputTip.JAB.JetBrains", , "Limited", 1)
            if (!done) {
                createTipGui([{
                    opt: "cRed",
                    text: "启动 JAB 进程失败!",
                }, {
                    opt: "cRed",
                    text: "请检查系统中是否存在 powershell.exe 或 pwsh.exe"
                }], "InputTip - 错误").Show()
                writeIni("enableJABSupport", 0)
                global enableJABSupport := 0
                return 1
            }
            Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
        }
    } else if (A_IsAdmin) {
        try {
            done := createScheduleTask(A_AhkPath, "abgox.InputTip.JAB.JetBrains", [A_ScriptDir "\InputTip.JAB.JetBrains.ahk"], "Limited", 1)
            if (!done) {
                createTipGui([{
                    opt: "cRed",
                    text: "启动 JAB 进程失败!",
                }, {
                    opt: "cRed",
                    text: "请检查系统中是否存在 powershell.exe 或 pwsh.exe"
                }], "InputTip - 错误").Show()
                writeIni("enableJABSupport", 0)
                global enableJABSupport := 0
                return 1
            }
            Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
        }
    } else {
        global JAB_PID
        Run('"' A_AhkPath '" "' A_ScriptDir '\InputTip.JAB.JetBrains.ahk"', , "Hide", &JAB_PID)
    }
    return 0
}


; 显示实时的状态码和切换码
showCode(*) {
    if (gc.timer) {
        gc.timer := 0
        try {
            gc.status_btn.Text := "显示实时的状态码和切换码(双击设置快捷键)"
        }
        return
    }

    gc.timer := 1
    try {
        gc.status_btn.Text := "停止显示实时的状态码和切换码(双击设置快捷键)"
    }

    SetTimer(statusTimer, 25)
    statusTimer() {
        if (!gc.timer) {
            ToolTip()
            SetTimer(, 0)
            return
        }

        info := IME.CheckInputMode()
        ToolTip("状态码: " info.statusMode "`n切换码: " info.conversionMode)
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
 * @param {Func} cb_addManual 手动添加应用进程的回调函数
 */
createProcessListGui(args, cb_addClick, cb_addManual := "") {
    showGui()
    showGui(deep := 0) {
        createUniqueGui(processListGui).Show()
        processListGui(info) {
            showGui(deep := 0) {
                g := createGuiOpt("InputTip - " args.title)
                tab := g.AddTab3("-Wrap", [lang("process_list.tab_list"), lang("common.about")])
                tab.UseTab(1)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                g.AddText("Section cRed", lang("gui.help_tip"))

                gc.LV_processList := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, [lang("gui.lv_name"), lang("gui.lv_source"), lang("gui.lv_title"), lang("gui.lv_path")])

                gc.LV_processList.OnEvent("DoubleClick", e_click_add)
                e_click_add(LV, RowNumber, *) {
                    windowInfo := {
                        exe_name: LV.GetText(RowNumber, 1),
                        title: LV.GetText(RowNumber, 3),
                        id: returnId()
                    }
                    cb_addClick({
                        windowInfo: windowInfo,
                        LV: LV,
                        RowNumber: RowNumber,
                        parentArgs: args
                    })
                }

                gc.LV_processList._type := "add"

                res := ":"
                DetectHiddenWindows deep
                gc.LV_processList.Opt("-Redraw")
                for v in WinGetList() {
                    try {
                        exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                        if (!InStr(res, ":" exe_name ":")) {
                            res .= exe_name ":"
                            gc.LV_processList.Add(, exe_name, lang("process_list.source_system"), WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                        }
                    }
                }
                if (args.configName != "App-ShowSymbol") {
                    for v in StrSplit(readIniSection("App-ShowSymbol"), "`n") {
                        kv := StrSplit(v, "=", , 2)
                        part := StrSplit(kv[2], ":", , 2)
                        try {
                            name := part[1]
                            if (!InStr(res, ":" name ":") && Trim(name)) {
                                res .= exe_name ":"
                                gc.LV_processList.Add(, name, lang("process_list.source_whitelist"))
                            }
                        }
                    }
                }
                gc.LV_processList.Opt("+Redraw")
                DetectHiddenWindows 1
                autoHdrLV(gc.LV_processList)
                g.AddButton("Section w" bw / 2, lang("process_list.refresh_list")).OnEvent("Click", e_fresh)
                e_fresh(*) {
                    g.Destroy()
                    showGui(deep).Show()
                }

                ; g.AddButton("yp w" bw / 3, "手动添加").OnEvent("Click", e_add_manually)

                ; e_add_manually(*) {
                ;     windowInfo := {
                ;         exe_name: "",
                ;         title: "",
                ;         id: returnId()
                ;     }
                ;     cb_addManual({
                ;         windowInfo: windowInfo,
                ;         parentArgs: args
                ;     })
                ; }

                if (deep) {
                    g.AddButton("yp w" bw / 2, lang("process_list.show_less")).OnEvent("Click", e_less_window)
                    e_less_window(*) {
                        g.Destroy()
                        showGui(0).Show()
                    }
                } else {
                    g.AddButton("yp w" bw / 2, lang("process_list.show_more")).OnEvent("Click", e_more_window)
                    e_more_window(*) {
                        g.Destroy()
                        showGui(1).Show()
                    }
                }
                tab.UseTab(2)
                g.AddEdit("ReadOnly VScroll r12 w" w, lang("about_text.process_list"))
                return g
            }
            return showGui()
        }
    }
}
