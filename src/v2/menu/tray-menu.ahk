#Include startup.ahk
#Include check-update.ahk
#Include input-mode.ahk
#Include cursor-mode.ahk
#Include bw-list.ahk
#Include pause-key.ahk
#Include config.ahk
#Include symbol-pos.ahk
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
    A_TrayMenu.Add("设置更新检查", fn_check_update)
    A_TrayMenu.Add("更改用户信息", fn_update_user)
    A_TrayMenu.Add()
    A_TrayMenu.Add("设置输入法模式", fn_input_mode)
    A_TrayMenu.Add("设置光标获取模式", fn_cursor_mode)
    A_TrayMenu.Add("设置符号显示位置", fn_symbol_pos)
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
    A_TrayMenu.Add()
    A_TrayMenu.Add("设置特殊偏移量", fn_app_offset)
    A_TrayMenu.Add("设置状态切换快捷键", fn_switch_key)
    A_TrayMenu.Add("指定窗口自动切换状态", fn_switch_window)

    A_TrayMenu.Add()
    A_TrayMenu.Add("启用 JAB/JetBrains IDE 支持", fn_JAB)
    if (enableJABSupport) {
        A_TrayMenu.Check("启用 JAB/JetBrains IDE 支持")
        runJAB()
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("关于", fn_about)
    A_TrayMenu.Add("重启", fn_restart)

    A_TrayMenu.Add()
    A_TrayMenu.Add("退出", fn_exit)
}

fn_update_user(*) {
    if (gc.w.updateUserGui) {
        gc.w.updateUserGui.Destroy()
        gc.w.updateUserGui := ""
    }
    createGui(updateUserGui).Show()
    updateUserGui(info) {
        g := createGuiOpt()
        g.AddText("cRed", "- 如果是域用户，用户名需要添加域`n- 如: xxx\abgox")
        g.AddText(, "用户名: ")
        _ := g.AddEdit("yp")
        g.AddText("xs ReadOnly cGray", "设置完成后，关闭此窗口即可")
        if (info.i) {
            return g
        }

        _._config := "userName"
        _.Value := readIni("userName", A_UserName, "UserInfo")
        _.Focus()
        _.OnEvent("Change", fn_change)

        g.OnEvent("Close", createTaskAndLnk)
        fn_change(item, *) {
            global userName := readIni("userName", A_UserName, "UserInfo")
            writeIni("userName", item.value, "UserInfo")
        }
        gc.w.updateUserGui := g
        return g
    }
}

fn_exit(*) {
    killJAB()
    ExitApp()
}
fn_restart(*) {
    if (enableJABSupport) {
        killJAB()
    }
    Run(A_ScriptFullPath)
}

fn_common(tipList, handleFn, addClickFn := "", rmClickFn := "", addFn := "") {
    showGui()
    showGui(deep := "") {
        if (gc.w.%tipList.gui%) {
            gc.w.%tipList.gui%.Destroy()
            gc.w.%tipList.gui% := ""
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        createGui(commonGui).Show()
        commonGui(info) {
            g := createGuiOpt()
            tab := g.AddTab3("-Wrap", tipList.tab)
            tab.UseTab(1)
            g.AddLink("Section cRed", tipList.tip)

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            tabs := ["应用进程列表", "窗口标题", "应用进程文件所在位置"]
            _gui := tipList.gui

            LV_add := gc.%_gui "_LV_add"% := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, tabs)
            LV_add.OnEvent("DoubleClick", e_add_dbClick)
            e_add_dbClick(LV, RowNumber) {
                if (addClickFn) {
                    addClickFn(LV, RowNumber, tipList)
                } else {
                    handleClick(LV, RowNumber, "add", tipList)
                }
            }
            if (tipList.config = "app_offset") {
                res := ":"
                for v in app_offset.OwnProps() {
                    res .= v ":"
                }
            } else {
                res := ":" readIni(tipList.config, "") ":"
            }
            temp := ":"
            DetectHiddenWindows deep
            LV_add.Opt("-Redraw")
            for v in WinGetList() {
                try {
                    exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                    exe_str := ":" exe_name ":"
                    if (!InStr(temp, exe_str) && !InStr(res, exe_str)) {
                        temp .= exe_name ":"
                        LV_add.Add(, exe_name, WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                    }
                }
            }
            if (tipList.config != "app_show_state") {
                for v in StrSplit(readIni("app_show_state", ''), ":") {
                    if (!InStr(temp, ":" v ":") && !InStr(res, ":" v ":")) {
                        temp .= v ":"
                        try {
                            LV_add.Add(, v, WinGetTitle("ahk_exe " v), WinGetProcessPath("ahk_exe " v))
                        } catch {
                            LV_add.Add(, v)
                        }
                    }
                }
            }

            LV_add.Opt("+Redraw")
            DetectHiddenWindows 1

            gc.%_gui "_LV_rm_title"% := g.AddText("w" w, tipList.list)
            LV_rm := gc.%_gui "_LV_rm"% := g.AddListView("xs -Hdr -LV0x10 -Multi r8 NoSortHdr Sort Grid w" w / 2 " " tipList.color, [tipList.list])
            valueArr := StrSplit(readIni(tipList.config, ""), ":")
            temp := ":"
            LV_rm.Opt("-Redraw")
            for v in valueArr {
                if (Trim(v) && !InStr(temp, ":" v ":")) {
                    if (tipList.config = "app_offset") {
                        LV_rm.Add(, StrSplit(v, "|")[1])
                    } else {
                        LV_rm.Add(, v)
                    }
                    temp .= v ":"
                }
            }
            LV_rm.Opt("+Redraw")
            gc.%_gui "_LV_rm_title"%.Text := tipList.list " ( " LV_rm.GetCount() " 个 )"
            LV_rm.ModifyCol(1, "AutoHdr")
            LV_rm.OnEvent("DoubleClick", e_rm_dbClick)
            e_rm_dbClick(LV, RowNumber) {
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
                exe_name := LV.GetText(RowNumber)
                if (gc.w.subGui) {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
                createGui(addGui).Show()
                addGui(info) {
                    g := createGuiOpt()
                    g.AddLink(, tipList.%from "Confirm"%)
                    g.AddLink("yp cRed", exe_name)
                    g.AddLink("yp", tipList.%from "Confirm2"%)
                    g.AddLink("xs", tipList.%from "Confirm3"%)

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    if (from = "add") {
                        if (useWhiteList && tipList.config = "showCursorPosList") {
                            g.AddText("xs cRed", "如果它不在白名单中，则会同步添加到白名单中")
                        }
                        _ := g.AddButton("xs w" bw, "添加")
                        _.Focus()
                        _.OnEvent("Click", fn_add)
                        fn_add(*) {
                            g.Destroy()
                            if (useWhiteList && tipList.config = "showCursorPosList") {
                                updateWhiteList(exe_name)
                            }
                            gc.%_gui "_LV_add"%.Delete(RowNumber)
                            gc.%_gui "_LV_rm"%.Add(, exe_name)
                            config := tipList.config
                            value := readIni(config, "")
                            if (value) {
                                result := value ":" exe_name
                                writeIni(config, value ":" exe_name)
                            } else {
                                result := exe_name
                                writeIni(config, exe_name)
                            }
                            handleFn(result)
                        }
                    } else {
                        _ := g.AddButton("xs w" bw, "移除")
                        _.Focus()
                        _.OnEvent("Click", e_rm)
                        e_rm(*) {
                            g.Destroy()
                            LV.Delete(RowNumber)
                            gc.%_gui "_LV_rm_title"%.Text := tipList.list " ( " gc.%_gui "_LV_rm"%.GetCount() " 个 )"
                            try {
                                gc.%_gui "_LV_add"%.Add(, exe_name, WinGetTitle("ahk_exe " exe_name))
                            }
                            config := tipList.config
                            value := readIni(config, "")
                            result := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != exe_name) {
                                    result .= ":" v
                                }
                            }
                            result := SubStr(result, 2)
                            writeIni(config, result)
                            handleFn(result)
                        }
                    }
                    g.AddButton("xs w" bw, "取消").OnEvent("Click", no)
                    no(*) {
                        g.Destroy()
                    }
                    gc.w.subGui := g
                    return g
                }
            }
            g.AddButton("Section yp w" w / 2, "刷新此界面").OnEvent("Click", e_refresh)
            e_refresh(*) {
                fn_close()
                showGui(deep)
            }
            g.AddButton("xs w" w / 2, "通过输入进程名称手动添加").OnEvent("Click", e_add_by_hand)
            e_add_by_hand(*) {
                if (addFn) {
                    addFn(tipList)
                    return
                }
                addApp("xxx.exe")
                addApp(v) {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    createGui(addGui).Show()
                    addGui(info) {
                        g := createGuiOpt("InputTip - " tipList.tab[1])
                        text := "每次只能添加一个应用进程名称"
                        if (useWhiteList) {
                            text .= "`n如果它不在白名单中，则会同步添加到白名单中"
                        }
                        g.AddText("cRed", text)
                        g.AddText("xs", "应用进程名称: ")

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        gc._exe_name := g.AddEdit("yp")
                        gc._exe_name.Value := v
                        g.AddButton("xs w" bw, "添加").OnEvent("Click", e_yes)
                        e_yes(*) {
                            exe_name := gc._exe_name.value
                            g.Destroy()
                            if (!RegExMatch(exe_name, "^.*\.\w{3}$") || RegExMatch(exe_name, '[\\/:*?\"<>|]')) {
                                if (gc.w.subGui) {
                                    gc.w.subGui.Destroy()
                                    gc.w.subGui := ""
                                }
                                createGui(errGui).Show()
                                errGui(info) {
                                    g := createGuiOpt()
                                    g.AddText("cRed", exe_name)
                                    g.AddText("yp", "是一个错误的应用进程名称")
                                    g.AddText("xs cRed", '正确的应用进程名称是 xxx.exe 这样的格式`n同时文件名中不能包含这些英文符号 \ / : * ? " < >|')

                                    if (info.i) {
                                        return g
                                    }
                                    w := info.w
                                    bw := w - g.MarginX * 2

                                    y := g.AddButton("xs w" bw, "重新输入")
                                    y.Focus()
                                    y.OnEvent("click", e_close)
                                    e_close(*) {
                                        g.Destroy()
                                        addApp(exe_name)
                                    }
                                    gc.w.subGui := g
                                    return g
                                }
                                return
                            }
                            value := readIni(tipList.config, "")
                            valueArr := StrSplit(value, ":")
                            res := ""
                            isExist := 0
                            for v in valueArr {
                                if (v = exe_name) {
                                    isExist := 1
                                }
                                if (Trim(v)) {
                                    res .= v ":"
                                }
                            }
                            if (isExist) {
                                if (gc.w.subGui) {
                                    gc.w.subGui.Destroy()
                                    gc.w.subGui := ""
                                }
                                createGui(existGui).Show()
                                existGui(info) {
                                    g := createGuiOpt()
                                    g.AddText("cRed", exe_name)
                                    g.AddText("yp", "这个应用进程已经存在了")

                                    if (info.i) {
                                        return g
                                    }
                                    w := info.w
                                    bw := w - g.MarginX * 2

                                    g.AddButton("xs w" bw, "重新输入").OnEvent("click", e_close)
                                    e_close(*) {
                                        g.Destroy()
                                        addApp(exe_name)
                                    }
                                    gc.w.subGui := g
                                    return g
                                }
                            } else {
                                updateWhiteList(exe_name)
                                gc.%_gui "_LV_rm"%.Add(, exe_name)
                                result := res exe_name
                                writeIni(tipList.config, result)
                                handleFn(result)
                            }
                        }
                        gc.w.subGui := g
                        return g
                    }
                }
            }
            g.AddButton("xs w" w / 2, "一键清空「" tipList.list "」").OnEvent("Click", e_clear)
            e_clear(*) {
                count := gc.%tipList.gui "_LV_rm"%.GetCount()
                if (gc.w.subGui) {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
                createGui(clearGui).Show()
                clearGui(info) {
                    g := createGuiOpt()
                    g.AddText(, "确定要清空「" tipList.list "」吗？")
                    g.AddText("cRed", "请谨慎选择，它会移除其中的 " count " 个应用进程`n一旦清空，无法恢复，只能重新一个一个添加")

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    g.AddButton("xs w" bw, "【是】我确定要清空").OnEvent("Click", yes)
                    _ := g.AddButton("xs w" bw, "【否】不，我点错了")
                    _.Focus()
                    _.OnEvent("Click", no)
                    yes(*) {
                        g.Destroy()
                        gc.%_gui "_LV_rm"%.Delete()
                        writeIni(tipList.config, "")
                        handleFn("")
                        fn_close()
                        showGui(deep)
                    }
                    no(*) {
                        g.Destroy()
                    }
                    gc.w.subGui := g
                    return g
                }
            }
            if (deep) {
                g.AddButton("xs w" w / 2, "显示更少进程(前台窗口)").OnEvent("Click", e_less_window)
                e_less_window(*) {
                    fn_close()
                    showGui("")
                }
            } else {
                g.AddButton("xs w" w / 2, "显示更多进程(后台窗口)").OnEvent("Click", e_more_window)
                e_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }
            LV_add.ModifyCol(1, "AutoHdr")
            LV_add.ModifyCol(2, "AutoHdr")
            LV_add.ModifyCol(3, "AutoHdr")
            tab.UseTab(2)
            g.AddEdit("ReadOnly -VScroll w" w, tipList.about)
            if (tipList.link) {
                g.AddLink(, tipList.link)
            }
            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
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
        tab: ["设置白名单", "关于"],
        tip: "你首先应该点击上方的「关于」查看具体的操作说明                                    ",
        list: "符号显示白名单",
        color: "cRed",
        about: '1. 如何使用这个管理面板？`n`n   - 上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 双击列表中任意应用进程，就可以将其添加到「符号显示白名单」中`n   - 如果需要更多的进程，请点击右下角的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击右下角的「通过输入进程名称手动添加」直接添加进程名称`n`n   - 下方是「符号显示白名单」应用进程列表，如果使用白名单机制，它将生效`n   - 双击列表中任意应用进程，就可以将它移除`n`n   - 白名单机制: 只有在白名单中的应用进程窗口才会显示符号`n   - 建议使用白名单机制，这样可以精确控制哪些应用进程窗口需要显示符号`n   - 使用白名单机制，只需要添加常用的窗口，可以减少一些特殊窗口的兼容性问题`n   - 如果选择了白名单机制，请及时添加你需要使用的应用进程到白名单中`n`n2. 如何快速添加应用进程？`n`n   - 每次双击应用进程后，会弹出操作窗口，需要选择添加/移除或取消`n   - 如果你确定当前操作不需要取消，可以在操作窗口弹出后，按下空格键快速确认',
        link: '相关链接: <a href="https://inputtip.pages.dev/FAQ/white-list">白名单机制</a>',
        addConfirm: "是否要将",
        addConfirm2: "添加到「符号显示白名单」中？",
        addConfirm3: "添加后，白名单机制下，在此应用窗口中时，会显示符号",
        addConfirm4: "",
        rmConfirm: "是否要将",
        rmConfirm2: "从「符号显示白名单」中移除？",
        rmConfirm3: "移除后，白名单机制下，在此应用窗口中时，不会显示符号",
    },
    fn
    )
    fn(value) {
        global app_show_state := ":" value ":"
        gc.whiteListGui_LV_rm_title.Text := "符号显示白名单 ( " gc.whiteListGui_LV_rm.GetCount() " 个 )"
        restartJAB()
    }
}

/**
 * 创建任务计划程序和快捷方式
 */
createTaskAndLnk(*) {
    if (A_IsAdmin) {
        try {
            Run('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptFullPath '\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' userName '" -RunLevel Highest;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.noUAC" -InputObject $task -Force', , "Hide")
            if (A_IsCompiled) {
                if (isDiff("C:\WINDOWS\system32\schtasks.exe")) {
                    FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", fileDesc, favicon, , , 7)
                }
            } else {
                if (isDiff(A_ScriptFullPath)) {
                    FileCreateShortcut(A_ScriptFullPath, fileLnk, , , fileDesc, favicon, , , 7)
                }
            }
        } catch {
            global has_powershell := 0
        }
    } else {
        if (isDiff(A_ScriptFullPath)) {
            FileCreateShortcut(A_ScriptFullPath, fileLnk, , , fileDesc, favicon, , , 7)
        }
    }

    isDiff(new) {
        if (!FileExist("InputTip.lnk")) {
            return 1
        }
        FileGetShortcut("InputTip.lnk", &old)
        return new != old
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
    disableList := ":InputTipSymbol\default\offer.png:InputTipSymbol\default\favicon.png:InputTipSymbol\default\favicon-pause.png:"
    Loop Files "InputTipSymbol\*", "R" {
        if (A_LoopFileExt = "png" && !InStr(disableList, ":" A_LoopFilePath ":")) {
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
 * 启动 JAB 进程
 * @returns {1|0} 1/0: 是否存在错误
 */
runJAB() {
    if (!has_powershell && enableJABSupport) {
        if (isStartUp = 1) {
            global isStartUp := 0
            writeIni("isStartUp", 0)
            A_TrayMenu.Uncheck("开机自启动")
        }
        global enableJABSupport := 0
        writeIni("enableJABSupport", 0)
        A_TrayMenu.Uncheck("启用 JAB/JetBrains IDE 支持")
        if (A_IsCompiled) {
            try {
                FileDelete("InputTip.JAB.JetBrains.exe")
            }
        }

        if (gc.w.subGui) {
            gc.w.subGui.Destroy()
            gc.w.subGui := ""
        }
        createGui(errGui).Show()
        errGui(info) {
            g := createGuiOpt("InputTip - powershell 调用失败!")
            g.AddText("cRed", "- 在当前系统环境中，尝试调用 powershell 失败了`n- 以下功能会被自动禁用`n   -「开机自启动」中的「任务计划程序」`n   -「启用 JAB/JetBrains IDE 支持」")
            g.AddText("cRed", "- 如果你想继续使用它们，你需要解决 cmd 调用 powershell 失败的问题")

            if (info.i) {
                return g
            }
            w := info.w

            g.AddButton("w" w, "我知道了").OnEvent("Click", e_close)
            e_close(*) {
                g.Destroy()
            }
            gc.w.subGui := g
            return g
        }
        return 1
    }
    if (A_IsCompiled && !FileExist("InputTip.JAB.JetBrains.exe")) {
        FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
    }
    SetTimer(runAppTimer, -1)
    runAppTimer() {
        if (A_IsAdmin) {
            try {
                RunWait('powershell -NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' A_ScriptDir '\InputTip.JAB.JetBrains.exe\"`'";$principal = New-ScheduledTaskPrincipal -UserId "' userName '" -LogonType ServiceAccount -RunLevel Limited;$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;Register-ScheduledTask -TaskName "abgox.InputTip.JAB.JetBrains" -InputObject $task -Force', , "Hide")
                Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
            }
        } else {
            Run(A_ScriptDir "\InputTip.JAB.JetBrains.exe", , "Hide")
        }
    }
    return 0
}
/**
 * 停止 JAB 进程
 * @param {1|0} wait 等待停止进程
 * @param {0|1} delete 停止进程后，是否需要删除进程文件
 */
killJAB(wait := 1, delete := 0) {
    cmd := 'taskkill /f /im InputTip.JAB.JetBrains.exe'
    try {
        wait ? RunWait(cmd, , "Hide") : Run(cmd, , "Hide")
    }
    if (delete) {
        try {
            FileDelete("InputTip.JAB.JetBrains.exe")
        }
    }
}
