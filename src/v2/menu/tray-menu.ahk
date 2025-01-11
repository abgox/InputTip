#Include startup.ahk
#Include check-update.ahk
#Include input-mode.ahk
#Include cursor-mode.ahk
#Include bw-list.ahk
#Include pause-key.ahk
#Include config.ahk
#Include app-offset.ahk
#Include switch-key.ahk
#Include switch-window.ahk
#Include JAB.ahk
#Include about.ahk

makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("开机自启动", fn_startup)
    if (isStartUp) {
        A_TrayMenu.Check("开机自启动")
    }
    A_TrayMenu.Add("设置更新检测", fn_check_update)
    A_TrayMenu.Add("设置输入法模式", fn_input_mode)
    A_TrayMenu.Add("设置光标获取模式", fn_cursor_mode)
    A_TrayMenu.Add("符号显示黑/白名单", fn_bw_list)

    A_TrayMenu.Add()
    A_TrayMenu.Add("暂停/运行", pauseApp)
    A_TrayMenu.Add("暂停/运行快捷键", fn_pause_key)
    A_TrayMenu.Add("打开软件所在目录", fn_open_dir)
    fn_open_dir(*) {
        Run("explorer.exe /select," A_ScriptFullPath)
    }

    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    A_TrayMenu.Add("设置特殊偏移量", fn_app_offset)
    A_TrayMenu.Add("设置状态切换快捷键", fn_switch_key)
    A_TrayMenu.Add("指定窗口自动切换状态", fn_switch_window)

    A_TrayMenu.Add()
    A_TrayMenu.Add("启用 JAB/JetBrains IDE 支持", fn_JAB)
    if (enableJetBrainsSupport) {
        A_TrayMenu.Check("启用 JAB/JetBrains IDE 支持")
        runJetBrains()
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("关于", fn_about)
    A_TrayMenu.Add("重启", fn_restart)

    A_TrayMenu.Add()
    A_TrayMenu.Add("退出", fn_exit)
}

fn_exit(*) {
    RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
    ExitApp()
}
fn_restart(flag := 0, *) {
    if (flag || enableJetBrainsSupport) {
        RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
    }
    Run(A_ScriptFullPath)
}

fn_common(tipList, handleFn, addClickFn := "", rmClickFn := "", addFn := "") {
    showGui()
    showGui(deep := "") {
        createGui(fn).Show()
        fn(x, y, w, h) {
            if (gc.w.%tipList.gui%) {
                gc.w.%tipList.gui%.Destroy()
                gc.w.%tipList.gui% := ""
                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
            }
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            _gui := tipList.gui
            tab := g.AddTab3("-Wrap", tipList.tab)
            tab.UseTab(1)
            g.AddLink("Section cRed", tipList.tip)

            tabs := ["应用进程列表", "窗口标题", "应用进程文件所在位置"]

            gc.%_gui "_LV_add"% := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" bw, tabs)
            gc.%_gui "_LV_add"%.OnEvent("DoubleClick", fn_double_click)
            fn_double_click(LV, RowNumber) {
                if (addClickFn) {
                    addClickFn(LV, RowNumber, tipList)
                } else {
                    handleClick(LV, RowNumber, "add", tipList)
                }
            }
            if (tipList.config = "app_offset") {
                value := ":"
                for v in app_offset.OwnProps() {
                    value .= v ":"
                }
            } else {
                value := ":" readIni(tipList.config, "") ":"
            }
            temp := ":"
            DetectHiddenWindows deep
            gc.%_gui "_LV_add"%.Opt("-Redraw")
            for v in WinGetList() {
                try {
                    exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                    exe_str := ":" exe_name ":"
                    if (!InStr(temp, exe_str) && !InStr(value, exe_str)) {
                        temp .= exe_name ":"
                        gc.%_gui "_LV_add"%.Add(, exe_name, WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                    }
                }
            }
            if (tipList.config != "app_show_state") {
                for v in StrSplit(readIni("app_show_state", ''), ":") {
                    if (!InStr(temp, ":" v ":") && !InStr(value, ":" v ":")) {
                        temp .= v ":"
                        try {
                            gc.%_gui "_LV_add"%.Add(, v, WinGetTitle("ahk_exe " v), WinGetProcessPath("ahk_exe " v))
                        } catch {
                            gc.%_gui "_LV_add"%.Add(, v)
                        }
                    }
                }
            }

            gc.%_gui "_LV_add"%.Opt("+Redraw")
            DetectHiddenWindows 1

            ; gc.title := g.AddText("Section w" bw, tipList.list)
            ; gc.%_gui "_LV_rm"% := g.AddListView("xs IconSmall -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw " " tipList.color)
            gc.%_gui "_LV_rm"% := g.AddListView("xs -LV0x10 -Multi r6 NoSortHdr Sort Grid w" bw / 2 " " tipList.color, [tipList.list])
            valueArr := StrSplit(readIni(tipList.config, ""), ":")
            temp := ":"
            gc.%_gui "_LV_rm"%.Opt("-Redraw")
            for v in valueArr {
                if (Trim(v) && !InStr(temp, ":" v ":")) {
                    if (tipList.config = "app_offset") {
                        gc.%_gui "_LV_rm"%.Add(, StrSplit(v, "|")[1])
                    } else {
                        gc.%_gui "_LV_rm"%.Add(, v)
                    }
                    temp .= v ":"
                }
            }
            gc.%_gui "_LV_rm"%.Opt("+Redraw")
            ; gc.title.Text := tipList.list "(" gc.%_gui "_LV_rm"%.GetCount() "项)"
            gc.%_gui "_LV_rm"%.ModifyCol(1, "AutoHdr")
            gc.%_gui "_LV_rm"%.OnEvent("DoubleClick", fn_dbClick)
            fn_dbClick(LV, RowNumber) {
                if (rmClickFn) {
                    rmClickFn(LV, RowNumber, tipList)
                } else {
                    handleClick(LV, RowNumber, "rm", tipList)
                }
            }
            handleClick(LV, RowNumber, from, tipList) {
                if (!RowNumber) {
                    return
                }
                RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                createGui(fn).Show()
                fn(x, y, w, h) {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    g_1 := Gui("AlwaysOnTop")
                    g_1.SetFont(fz, "微软雅黑")
                    bw := w - g_1.MarginX * 2

                    g_1.AddLink(, tipList.%from "Confirm"%)
                    g_1.AddLink("yp cRed", RowText)
                    g_1.AddLink("yp", tipList.%from "Confirm2"%)
                    g_1.AddLink("xs", tipList.%from "Confirm3"%)

                    if (from = "add") {
                        ; 需要同步添加到白名单
                        if (useWhiteList && tipList.addConfirm4) {
                            g_1.AddLink("xs cRed", tipList.addConfirm4)
                        }
                        if (useWhiteList) {
                            _g := g_1.AddButton("xs w" bw, "添加")
                            _g.OnEvent("Click", fn_add_with_white_list)
                            _g.Focus()
                            fn_add_with_white_list(*) {
                                updateWhiteList(RowText)
                                g_1.Destroy()
                                gc.%_gui "_LV_add"%.Delete(RowNumber)
                                gc.%_gui "_LV_rm"%.Add(, RowText)
                                ; gc.title.Text := tipList.list "(" gc.%_gui "_LV_rm"%.GetCount() "项)"
                                config := tipList.config
                                value := readIni(config, "")
                                if (value) {
                                    result := value ":" RowText
                                    writeIni(config, value ":" RowText)
                                } else {
                                    result := RowText
                                    writeIni(config, RowText)
                                }
                                handleFn(result)
                            }
                        } else {
                            _g := g_1.AddButton("xs w" bw, "添加")
                            _g.OnEvent("Click", fn_add)
                            _g.Focus()
                            fn_add(*) {
                                g_1.Destroy()
                                gc.%_gui "_LV_add"%.Delete(RowNumber)
                                gc.%_gui "_LV_rm"%.Add(, RowText)
                                ; gc.title.Text := tipList.list "(" gc.%_gui "_LV_rm"%.GetCount() "项)"
                                config := tipList.config
                                value := readIni(config, "")
                                if (value) {
                                    result := value ":" RowText
                                    writeIni(config, value ":" RowText)
                                } else {
                                    result := RowText
                                    writeIni(config, RowText)
                                }
                                handleFn(result)
                            }
                        }
                    } else {
                        _g := g_1.AddButton("xs w" bw, "移除")
                        _g.OnEvent("Click", fn_rm)
                        _g.Focus()
                    }
                    fn_rm(*) {
                        g_1.Destroy()
                        LV.Delete(RowNumber)
                        ; gc.title.Text := tipList.list "(" LV.GetCount() "项)"
                        try {
                            gc.%_gui "_LV_add"%.Add(, RowText, WinGetTitle("ahk_exe " RowText))
                        }
                        config := tipList.config
                        value := readIni(config, "")
                        result := ""
                        for v in StrSplit(value, ":") {
                            if (Trim(v) && v != RowText) {
                                result .= ":" v
                            }
                        }
                        result := SubStr(result, 2)
                        writeIni(config, result)
                        handleFn(result)
                    }
                    g_1.AddButton("xs w" bw, "取消").OnEvent("Click", no)
                    no(*) {
                        g_1.Destroy()
                    }
                    gc.w.subGui := g_1
                    return g_1
                }
            }
            g.AddButton("Section yp w" bw / 2, "刷新应用进程列表").OnEvent("Click", fn_refresh)
            fn_refresh(*) {
                fn_close()
                showGui(deep)
            }
            g.AddButton("xs w" bw / 2, "通过输入进程名称手动添加").OnEvent("Click", fn_add_by_hand)
            fn_add_by_hand(*) {
                if (addFn) {
                    addFn(tipList)
                    return
                }
                addApp("xxx.exe")
                addApp(v) {
                    createGui(fn).Show()
                    fn(x, y, w, h) {
                        if (gc.w.subGui) {
                            gc.w.subGui.Destroy()
                            gc.w.subGui := ""
                        }
                        g_2 := Gui("AlwaysOnTop", "InputTip - 手动添加进程")
                        g_2.SetFont(fz, "微软雅黑")
                        bw := w - g_2.MarginX * 2

                        ; 需要同步添加到白名单
                        if (useWhiteList && tipList.addConfirm4) {
                            g_2.AddText("cRed", tipList.addConfirm4)
                        }
                        g_2.AddText(, "1. 进程名称应该是")
                        g_2.AddText("yp cRed", "xxx.exe")
                        g_2.AddText("yp", "这样的格式")
                        g_2.AddText("xs", "2. 每一次只能添加一个")
                        g_2.AddText("xs", "应用进程名称: ")
                        g_2.AddEdit("yp vexe_name", "").Value := v
                        g_2.AddButton("xs w" bw, "添加").OnEvent("Click", yes)
                        yes(*) {
                            exe_name := g_2.Submit().exe_name
                            if (!RegExMatch(exe_name, "^.+\.\w{3}$")) {
                                createGui(fn).Show()
                                fn(x, y, w, h) {
                                    if (gc.w.subGui) {
                                        gc.w.subGui.Destroy()
                                        gc.w.subGui := ""
                                    }
                                    g_2 := Gui("AlwaysOnTop")
                                    g_2.SetFont(fz, "微软雅黑")
                                    bw := w - g_2.MarginX * 2
                                    g_2.AddText(, "进程名称不符合格式要求，请重新输入")
                                    y := g_2.AddButton("w" bw, "我知道了")
                                    y.OnEvent("click", close)
                                    y.Focus()
                                    close(*) {
                                        g_2.Destroy()
                                        addApp(exe_name)
                                    }
                                    gc.w.subGui := g_2
                                    return g_2
                                }
                                return
                            }
                            value := readIni(tipList.config, "")
                            valueArr := StrSplit(value, ":")
                            res := ""
                            is_exist := 0
                            for v in valueArr {
                                if (v = exe_name) {
                                    is_exist := 1
                                }
                                if (Trim(v)) {
                                    res .= v ":"
                                }
                            }
                            if (is_exist) {
                                createGui(fn1).Show()
                                fn1(x, y, w, h) {
                                    if (gc.w.subGui) {
                                        gc.w.subGui.Destroy()
                                        gc.w.subGui := ""
                                    }
                                    g_2 := Gui("AlwaysOnTop")
                                    g_2.SetFont(fz, "微软雅黑")
                                    bw := w - g_2.MarginX * 2
                                    g_2.AddText(, exe_name " 已经存在了，请重新输入")
                                    g_2.AddButton("w" bw, "重新输入").OnEvent("click", close)
                                    close(*) {
                                        g_2.Destroy()
                                        addApp(exe_name)
                                    }
                                    gc.w.subGui := g_2
                                    return g_2
                                }
                            } else {
                                updateWhiteList(exe_name)
                                gc.%_gui "_LV_rm"%.Add(, exe_name)
                                result := res exe_name
                                writeIni(tipList.config, result)
                                handleFn(result)
                            }
                        }
                        gc.w.subGui := g_2
                        return g_2
                    }
                }
            }
            g.AddButton("xs w" bw / 2, "一键清空「" tipList.list "」").OnEvent("Click", fn_clear)
            fn_clear(*) {
                createGui(fn).Show()
                fn(x, y, w, h) {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    g_3 := Gui("AlwaysOnTop")
                    g_3.SetFont(fz, "微软雅黑")
                    bw := w - g_3.MarginX * 2
                    g_3.AddText(, "确定要清空「" tipList.list "」吗？")
                    g_3.AddText("cRed", "请谨慎选择，一旦清空，无法恢复，只能重新一个一个添加")
                    g_3.AddButton("xs w" bw, "【是】我确定要清空").OnEvent("Click", yes)
                    _g := g_3.AddButton("xs w" bw, "【否】不，我点错了")
                    _g.OnEvent("Click", no)
                    _g.Focus()
                    yes(*) {
                        g_3.Destroy()
                        gc.%_gui "_LV_rm"%.Delete()
                        writeIni(tipList.config, "")
                        handleFn("")
                        fn_close()
                        showGui(deep)
                    }
                    no(*) {
                        g_3.Destroy()
                    }
                    gc.w.subGui := g_3
                    return g_3
                }
            }
            if (deep) {
                g.AddButton("xs w" bw / 2, "显示更少进程(前台窗口)").OnEvent("Click", fn_less_window)
                fn_less_window(*) {
                    fn_close()
                    showGui("")
                }
            } else {
                g.AddButton("xs w" bw / 2, "显示更多进程(后台窗口)").OnEvent("Click", fn_more_window)
                fn_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }
            gc.%_gui "_LV_add"%.ModifyCol(1, "AutoHdr")
            gc.%_gui "_LV_add"%.ModifyCol(2, "AutoHdr")
            gc.%_gui "_LV_add"%.ModifyCol(3, "AutoHdr")
            tab.UseTab(2)
            g.AddLink(, tipList.about)
            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
            }
            gc.w.%tipList.gui% := g
            return g
        }
    }
}

fn_white_list(*) {
    fn_common({
        gui: "whiteListGui",
        config: "app_show_state",
        tab: ["管理白名单", "关于"],
        tip: "你首先应该点击上方的「关于」查看具体的操作说明",
        list: "符号显示白名单",
        color: "cRed",
        about: '1. 如何使用这个管理面板？`n   - 最上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 双击列表中任意应用进程，就可以将其添加到「符号显示白名单」中`n   - 如果需要更多的进程，请点击右下角的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击右下角的「通过输入进程名称手动添加」直接添加进程名称`n   - 下方是「符号显示白名单」应用进程列表，如果使用白名单机制，它将生效`n   - 双击列表中任意应用进程，就可以将它移除`n`n   - <a href="https://inputtip.pages.dev/FAQ/about-white-list">白名单机制</a> : 只有在白名单中的应用进程窗口才会显示符号`n   - 建议使用白名单机制，这样可以精确控制哪些应用进程窗口需要显示符号`n   - 使用白名单机制，只需要添加常用的窗口，可以减少一些特殊窗口的兼容性问题`n   - 如果选择了白名单机制，请及时添加你需要使用的应用进程到白名单中`n`n2. 如何快速添加应用进程？`n   - 每次双击应用进程后，会弹出操作窗口，需要选择添加/移除或取消`n   - 如果你确定当前操作不需要取消，可以在操作窗口弹出后，按下空格键快速确认',
        addConfirm: "是否要将",
        addConfirm2: "添加到「符号显示白名单」中？",
        addConfirm3: "添加后，白名单机制下，在此应用窗口中时，会显示符号(图片/方块/文本符号)",
        addConfirm4: "",
        rmConfirm: "是否要将",
        rmConfirm2: "从「符号显示白名单」中移除？",
        rmConfirm3: "移除后，白名单机制下，在此应用窗口中时，不会显示符号(图片/方块/文本符号)",
    },
    fn
    )
    fn(value) {
        global app_show_state := ":" value ":"
        restartJetBrains()
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
 * @returns {Array} 路径列表
 */
getPicDir() {
    picList := ":"
    defaultList := ":InputTipSymbol\default\Caps.png:InputTipSymbol\default\EN.png:InputTipSymbol\default\CN.png:"
    Loop Files "InputTipSymbol\*", "R" {
        if (A_LoopFileExt = "png" && A_LoopFilePath != "InputTipSymbol\default\offer.png") {
            if (!InStr(picList, ":" A_LoopFilePath ":") && !InStr(defaultList, ":" A_LoopFilePath ":")) {
                picList .= A_LoopFilePath ":"
            }
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
 * @param runOrStop 1: Run; 0:Stop
 */
runJetBrains() {
    SetTimer(runAppTimer, -10)
    runAppTimer() {
        if (A_IsAdmin) {
            try {
                RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptDir '\InputTip.JAB.JetBrains.exe\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' A_UserName '" -LogonType ServiceAccount -RunLevel Limited;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -InputObject $task -Force', , "Hide")
            }
            Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
        } else {
            Run(A_ScriptDir "\InputTip.JAB.JetBrains.exe", , "Hide")
        }
    }
}
