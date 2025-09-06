; InputTip

#Include "*i startup.ahk"
#Include "*i check-update.ahk"
#Include "*i input-method.ahk"
#Include "*i cursor-mode.ahk"
#Include "*i bw-list.ahk"
#Include "*i symbol-pos.ahk"
#Include "*i app-offset.ahk"
#Include "*i switch-window.ahk"
#Include "*i about.ahk"

#Include "*i scheme-cursor.ahk"
#Include "*i scheme-symbol.ahk"
#Include "*i other-config.ahk"

fontList := getFontList()
fontList.InsertAt(1, "Microsoft YaHei")

makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("开机自启动", fn_startup)
    if (isStartUp) {
        A_TrayMenu.Check("开机自启动")
    }

    if (!A_IsCompiled) {
        A_TrayMenu.Add("以管理员权限启动", fn_admin_mode)
        fn_admin_mode(*) {
            A_TrayMenu.ToggleCheck("以管理员权限启动")
            global runCodeWithAdmin := !runCodeWithAdmin
            writeIni("runCodeWithAdmin", runCodeWithAdmin)
            if (runCodeWithAdmin) {
                fn_restart()
            } else {
                createTipGui([{
                    opt: "cRed",
                    text: "【管理员权限】无法直接降权至【用户权限】",
                }, {
                    opt: "cRed",
                    text: "如果想要立即生效，你需要手动退出并重新启动 InputTip"
                }], "InputTip - 取消以管理员权限启动").Show()
            }
        }
        if (runCodeWithAdmin) {
            A_TrayMenu.Check("以管理员权限启动")
        }
    }

    A_TrayMenu.Add("创建快捷方式到桌面", fn_create_shortcut)

    A_TrayMenu.Add()
    A_TrayMenu.Add("暂停/运行", pauseApp)
    A_TrayMenu.Default := "暂停/运行"
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Add("暂停/运行快捷键", (*) => (
        setHotKeyGui([{
            config: "hotkey_Pause",
            preTip: "设置快捷键",
            tip: "暂停/运行"
        }], "软件暂停/运行")
    ))
    A_TrayMenu.Add()
    A_TrayMenu.Add("输入法相关", fn_input_mode)
    A_TrayMenu.Add("状态切换快捷键", (*) => (
        setHotKeyGui([{
            config: "hotkey_CN",
            preTip: "强制切换到",
            tip: "中文状态"
        }, {
            config: "hotkey_EN",
            preTip: "强制切换到",
            tip: "英文状态"
        }, {
            config: "hotkey_Caps",
            preTip: "强制切换到",
            tip: "大写锁定"
        }], "输入法状态切换")
    ))
    A_TrayMenu.Add("指定窗口自动切换状态", fn_switch_window)

    A_TrayMenu.Add()
    A_TrayMenu.Add("状态提示 - 鼠标方案", fn_scheme_cursor)
    A_TrayMenu.Add("状态提示 - 符号方案", fn_scheme_symbol)
    A_TrayMenu.Add("在鼠标附近显示符号", fn_symbol_pos)
    A_TrayMenu.Add()
    A_TrayMenu.Add("符号的黑/白名单", fn_bw_list)
    A_TrayMenu.Add("获取窗口信息", fn_process_info)
    A_TrayMenu.Add()
    A_TrayMenu.Add("光标获取模式", fn_cursor_mode)
    A_TrayMenu.Add("特殊偏移量", fn_app_offset)

    A_TrayMenu.Add()
    A_TrayMenu.Add("其他设置", fn_ohter_config)
    A_TrayMenu.Add()
    A_TrayMenu.Add("关于", fn_about)
    A_TrayMenu.Add("重启", fn_restart)

    A_TrayMenu.Add()
    A_TrayMenu.Add("退出", fn_exit)

    if (enableJABSupport) {
        runJAB()
    }
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
        g := createGuiOpt("InputTip - 设置用户信息")
        tab := g.AddTab3("-Wrap", ["设置用户信息", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, "-------------------------------------------------------------------------")

        g.AddText(, "当前的用户名: ")
        _ := g.AddEdit("yp")
        _._config := "userName"
        _.Value := uname
        _.OnEvent("Change", fn_change)
        fn_change(item, *) {
            global userName := item.value
        }

        g.AddText("xs ReadOnly cGray", "请自行检查，确保用户名无误后，点击右上角的 × 直接关闭此窗口即可").Focus()

        tab.UseTab(2)
        g.AddEdit("ReadOnly r6 w" bw, "1. 简要说明`n   - 这个菜单用来设置用户名信息`n   - 如果是域用户，在填写时还需要添加域，参考以下格式`n      - DOMAIN\Username`n      - Username@domain.com`n   - 如果用户名信息有误，以下功能可能会失效`n      - 【开机自启动】中的 【任务计划程序】`n      - 【其他设置】中的【JAB/JetBrains IDE 支持】")

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
        g := createGuiOpt("InputTip - 获取窗口信息", , "AlwaysOnTop")

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "-"

        g.AddText("cRed", "实时获取当前激活的窗口进程信息(窗口进程名称、窗口进程路径、窗口标题)").Focus()
        g.AddText(, line)

        createGuiOpt("").AddText(, " ").GetPos(, , &__w)
        gc._window_info := g.AddButton("xs w" bw, "点击获取")
        gc._window_info.OnEvent("Click", e_window_info)
        g.AddText("xs cRed", "名称: ").GetPos(, , &_w)
        _width := bw - _w - g.MarginX + __w
        gc.app_name := g.AddEdit("yp ReadOnly -VScroll w" _width)
        g.AddText("xs cRed", "标题: ").GetPos(, , &_w)
        gc.app_title := g.AddEdit("yp ReadOnly -VScroll w" _width)
        g.AddText("xs cRed", "路径: ").GetPos(, , &_w)
        gc.app_path := g.AddEdit("yp ReadOnly -VScroll w" _width)
        e_window_info(*) {
            if (gc.timer2) {
                gc.timer2 := 0
                gc._window_info.Text := "点击获取"
                return
            }
            gc.timer2 := 1
            gc._window_info.Text := "停止获取"
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
            tab := g.AddTab3("-Wrap", [args.tab, "关于"])
            tab.UseTab(1)
            g.AddLink("Section cRed", gui_help_tip)

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            LV := "LV_" A_Now

            gc.%LV% := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, ["进程名称", "匹配范围", "匹配模式", "匹配标题", "创建时间"])

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

                    tipGlobal := isGlobal ? "进程级" : "标题级"

                    tipRegex := isRegex ? "正则" : "相等"
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
            _ := g.AddButton("xs w" w / 2, "快捷添加")
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

            _ := g.AddButton("yp w" w / 2, "手动添加")
            _.OnEvent("Click", e_add_manually)
            _._LV := LV
            _._config := args.config

            e_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    tipGlobal: "进程级",
                    tipRegex: "相等",
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
                ; 是否自动添加到符号的白名单中
                needAddWhiteList := 1

                if (action == "edit") {
                    actionText := "编辑"
                } else {
                    actionText := "添加"
                }

                label := "正在" actionText "规则"

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                if (action != "edit" && itemValue.configName != "App-ShowSymbol") {
                    g.AddText("cRed", "是否添加到【符号的白名单】中: ")
                    _ := g.AddDropDownList("yp", ["【否】不添加", "【是】自动添加"])
                    _.Value := needAddWhiteList + 1
                    _.OnEvent("Change", e_change)
                    e_change(item, *) {
                        needAddWhiteList := item.value - 1
                    }
                    g.AddText("xs cGray", "如果选择【是】，且它在白名单中不存在，将以【进程级】自动添加")
                }

                scaleWidth := bw / 1.5

                g.AddText(, "1. 进程名称: ")
                _ := g.AddEdit("yp w" scaleWidth, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
                }

                g.AddText("xs", "2. 匹配范围: ")
                _ := g.AddDropDownList("yp w" scaleWidth, ["进程级", "标题级"])
                _.Text := itemValue.tipGlobal
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.tipGlobal := v
                }

                g.AddText("xs cGray", "【匹配模式】和【匹配标题】仅在【匹配范围】为【标题级】时有效")
                g.AddText("xs", "3. 匹配模式: ")
                _ := g.AddDropDownList("yp w" scaleWidth, ["相等", "正则"])
                _.Text := itemValue.tipRegex
                _.OnEvent("Change", e_changeMatch)
                e_changeMatch(item, *) {
                    v := item.Text
                    itemValue.tipRegex := v
                }

                g.AddText("xs", "4. 匹配标题: ")
                _ := g.AddEdit("yp w" scaleWidth)
                _.Text := itemValue.title
                _.OnEvent("Change", e_changeTitle)
                e_changeTitle(item, *) {
                    v := item.Text
                    itemValue.title := v
                }

                g.AddButton("xs w" bw / 1.2, "完成" actionText).OnEvent("Click", e_set)
                e_set(*) {
                    fn_set(action, 0)
                }
                if (action == "edit") {
                    g.AddButton("xs w" bw / 1.2, "删除它").OnEvent("Click", e_delete)
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
                        isGlobal := itemValue.tipGlobal == "进程级" ? 1 : 0
                        isRegex := itemValue.tipRegex == "正则" ? 1 : 0
                        value := itemValue.exe_name ":" isGlobal ":" isRegex ":" itemValue.title
                        ; 没有进行移动
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
                    title: parentTitle " - 快捷添加",
                    configName: configName,
                    LV: parentLV,
                }
                createProcessListGui(args, addClick, e_add_manually)

                addClick(args) {
                    windowInfo := args.windowInfo
                    RowNumber := args.RowNumber

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        tipGlobal: "进程级",
                        tipRegex: "相等",
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
                        tipGlobal: "进程级",
                        tipRegex: "相等",
                        title: windowInfo.title,
                        id: windowInfo.id,
                        configName: args.parentArgs.configName
                    }
                    fn_edit(gc.%args.parentArgs.LV%, 1, "add", itemValue).Show()
                }
            }
            tab.UseTab(2)
            g.AddEdit("Section r13 w" w, "1. 简要说明`n   - 这个菜单用来配置【" args.tab "】的匹配规则`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】`n   - 【进程级】: 只要在这个进程中时，就会触发`n   - 【标题级】: 只有在这个进程中，且标题匹配成功时，才会触发`n`n4. 规则列表 —— 匹配模式`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 【相等】或【正则】，它控制标题匹配的模式`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发`n   - 【正则】: 使用正则表达式匹配标题，匹配成功才会触发`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式，与【匹配模式】相对应`n   - 如果不知道当前窗口的相关信息(进程/标题等)，可以通过以下方式获取`n      - 【托盘菜单】=>【获取窗口信息】`n`n6. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n7. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n8. 按钮 —— 快捷添加`n   - 点击它，可以添加一条新的规则`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n9. 按钮 —— 手动添加`n   - 点击它，可以添加一条新的规则`n   - 它会直接弹出添加窗口，你需要手动填写进程名称、标题等信息")
            return g
        }
    }
}


fn_white_list(*) {
    fn_common({
        title: "设置符号的白名单",
        tab: "符号的白名单",
        config: "App-ShowSymbol",
        link: '相关链接: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">符号的名单机制</a>'
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
    dirList := ":"
    defaultList := ":InputTipCursor\default\Caps:InputTipCursor\default\EN:InputTipCursor\default\CN:"
    loopDir("InputTipCursor")
    loopDir(path) {
        Loop Files path "\*", "DR" {
            if (A_LoopFileAttrib ~= "D") {
                loopDir A_LoopFilePath
                if (!hasChildDir(A_LoopFilePath)) {
                    if (!InStr(dirList, ":" A_LoopFilePath ":") && !InStr(defaultList, ":" A_LoopFilePath ":")) {
                        dirList .= A_LoopFilePath ":"
                    }
                }
            }
        }
    }
    dirList := StrSplit(SubStr(dirList, 2, StrLen(dirList) - 2), ":")

    for v in StrSplit(SubStr(defaultList, 2, StrLen(defaultList) - 2), ":") {
        dirList.InsertAt(1, v)
    }
    return dirList
}

/**
 * 解析图片符号文件夹目录，并生成路径列表
 * @param {String} defaultList 默认列表，会放在最前面
 * @param {String} disableList 禁用列表，不会显示在列表中
 * @returns {Array} 路径列表
 */
getPicList(defaultList := "", disableList := "") {
    picList := ":"
    if (!defaultList) {
        defaultList := ":InputTipSymbol\default\Caps.png:InputTipSymbol\default\EN.png:InputTipSymbol\default\CN.png:"
    }
    if (!disableList) {
        disableList := ":InputTipSymbol\default\favicon.png:InputTipSymbol\default\favicon-pause.png:"
    }
    Loop Files "InputTipSymbol\*", "R" {
        if (A_LoopFileExt = "png" && !InStr(disableList, ":" A_LoopFilePath ":") && !InStr(picList, ":" A_LoopFilePath ":") && !InStr(defaultList, ":" A_LoopFilePath ":")) {
            picList .= A_LoopFilePath ":"
        }
    }

    picList := StrSplit(SubStr(picList, 2, StrLen(picList) - 2), ":")

    for v in StrSplit(SubStr(defaultList, 2, StrLen(defaultList) - 2), ":") {
        picList.InsertAt(1, v)
    }
    picList.InsertAt(1, '')
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
        A_TrayMenu.Uncheck("暂停/运行")
        setTrayIcon(iconRunning)
        reloadSymbol()
        reloadCursor()
        if (enableJABSupport) {
            runJAB()
        }
    } else {
        A_TrayMenu.Check("暂停/运行")
        setTrayIcon(iconPaused)
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
        SetTimer(runAppTimer1, -1)
        runAppTimer1() {
            try {
                createScheduleTask(A_ScriptDir "\InputTip.JAB.JetBrains.exe", "abgox.InputTip.JAB.JetBrains", , "Limited", 1)
                Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
            }
        }
    } else if (A_IsAdmin) {
        SetTimer(runAppTimer2, -1)
        runAppTimer2() {
            try {
                createScheduleTask(A_AhkPath, "abgox.InputTip.JAB.JetBrains", [A_ScriptDir "\InputTip.JAB.JetBrains.ahk"], "Limited", 1)
                Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
            }
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
                tab := g.AddTab3("-Wrap", ["应用进程列表", "关于"])
                tab.UseTab(1)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                g.AddText("Section cRed", gui_help_tip)

                gc.LV_processList := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["进程名称", "来源", "窗口标题", "文件路径"])

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
                            gc.LV_processList.Add(, exe_name, "系统", WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
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
                                gc.LV_processList.Add(, name, "白名单")
                            }
                        }
                    }
                }
                gc.LV_processList.Opt("+Redraw")
                DetectHiddenWindows 1
                autoHdrLV(gc.LV_processList)
                g.AddButton("Section w" bw / 2, "刷新此界面").OnEvent("Click", e_fresh)
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
                    g.AddButton("yp w" bw / 2, "显示更少进程").OnEvent("Click", e_less_window)
                    e_less_window(*) {
                        g.Destroy()
                        showGui(0).Show()
                    }
                } else {
                    g.AddButton("yp w" bw / 2, "显示更多进程").OnEvent("Click", e_more_window)
                    e_more_window(*) {
                        g.Destroy()
                        showGui(1).Show()
                    }
                }
                tab.UseTab(2)
                g.AddEdit("ReadOnly VScroll r12 w" w, "1. 简要说明`n   - 这个菜单中显示的是所有正在运行的【应用进程列表】`n   - 整个列表根据【进程名称】的首字母进行排序`n   - 双击列表中的任意一行，即可添加对应的这个应用进程`n`n2. 应用进程列表 —— 进程名称`n   - 应用程序实际运行的进程名称`n   - 如果不清楚是哪个应用的进程，可能需要通过【窗口标题】、【文件路径】来判断`n   - 或者使用第 6 点的技巧`n`n3. 应用进程列表 —— 来源`n   - 【系统】表明这个进程是从系统中获取的，它正在运行`n   - 【白名单】表明这个进程是存在于白名单中的，为了方便操作，被添加到列表中`n`n4. 应用进程列表 —— 窗口标题`n   - 这个应用进程所显示的窗口的标题`n   - 你可能需要通过它来判断这是哪一个应用的进程`n`n5. 应用进程列表 —— 文件路径`n   - 这个应用进程的可执行文件的所在路径`n   - 你可能需要通过它来判断这是哪一个应用的进程`n`n6. 技巧 —— 获取当前窗口的实时的相关进程信息`n   - 你可以使用【托盘菜单】中的【获取窗口信息】`n   - 它会实时获取当前激活的窗口的【进程名称】【窗口标题】【文件路径】`n`n7. 按钮 —— 刷新此界面`n   - 因为列表中显示的是当前正在运行的应用进程`n   - 如果你是先打开这个配置菜单，再打开对应的应用，它不会显示在这里`n   - 你需要重新打开这个配置菜单，或者点击这个按钮进行刷新`n`n8. 按钮 —— 显示更多进程`n   - 默认情况下，【应用进程列表】中显示的是前台应用进程，就是有窗口的应用进程`n   - 你可以点击它来显示更多的进程，比如后台进程`n`n9. 按钮 —— 显示更少进程`n   - 当你点击【显示更多进程】按钮后，会出现这个按钮`n   - 点击它又会重新显示前台应用进程")
                return g
            }
            return showGui()
        }
    }
}
