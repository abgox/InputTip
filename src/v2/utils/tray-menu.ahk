makeTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("忽略更新", fn_ignore_update)
    fn_ignore_update(item, *) {
        global ignoreUpdate := !ignoreUpdate
        writeIni("ignoreUpdate", ignoreUpdate)
        A_TrayMenu.ToggleCheck(item)
        checkUpdate()
    }
    ignoreUpdate ? A_TrayMenu.Check("忽略更新") : 0
    A_TrayMenu.Add("开机自启动", fn_startup)
    fn_startup(item, *) {
        global isStartUp
        if (isStartUp) {
            try {
                FileDelete(A_Startup "\" fileLnk)
            }
            try {
                RegDelete(HKEY_startup, A_ScriptName)
            }
            A_TrayMenu.Uncheck(item)
            isStartUp := 0
            writeIni("isStartUp", isStartUp)
            showMsg(["InputTip 开机自启动已取消", "可通过「托盘菜单」=> 「开机自启动」 再次启用"], "我知道了")
        } else {
            createGui(fn).Show()
            fn(x, y, w, h) {
                g := Gui("AlwaysOnTop +OwnDialogs", "设置开机自启动")
                g.SetFont(fz, "微软雅黑")
                g.AddLink(, '详情: <a href="https://inputtip.pages.dev/FAQ/#关于开机自启动">https://inputtip.pages.dev/FAQ/#关于开机自启动</a>')
                g.AddLink(, "当前有多种方式设置开机自启动，请选择有效的方式 :`n`n1. 通过「任务计划程序」`n2. 通过软件快捷方式`n3. 通过添加「注册表」`n`n「任务计划程序」可以避免管理员授权窗口(UAC)的干扰(部分用户无效)")
                if (A_IsAdmin) {
                    isDisabled := ''
                    pad := ''
                } else {
                    isDisabled := ' Disabled'
                    pad := ' (以管理员模式运行时可用)'
                }
                btn := g.AddButton("w" w isDisabled, "使用「任务计划程序」" pad)
                btn.Focus()
                btn.OnEvent("Click", fn_startUp_task)
                fn_startUp_task(*) {
                    isStartUp := 1
                    FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", A_Startup "\" fileLnk, , "/run /tn `"abgox.InputTip.noUAC`"", , favicon, , , 7)
                    fn_handle()
                }
                btn := g.AddButton("w" w, "使用软件快捷方式")
                if (!A_IsAdmin) {
                    btn.Focus()
                }
                btn.OnEvent("Click", fn_startUp_lnk)
                fn_startUp_lnk(*) {
                    isStartUp := 2
                    FileCreateShortcut(A_ScriptFullPath, A_Startup "\" fileLnk, , , , favicon, , , 7)
                    fn_handle()
                }
                g.AddButton("w" w isDisabled, "使用「注册表」" pad).OnEvent("Click", fn_startUp_reg)
                fn_startUp_reg(*) {
                    isStartUp := 3
                    try {
                        RegWrite(A_ScriptFullPath, "REG_SZ", "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run", A_ScriptName)
                        fn_handle()
                    } catch {
                        MsgBox("添加注册表失败!", , "0x1000 0x10")
                    }
                }
                fn_handle() {
                    g.Destroy()
                    if (isStartUp) {
                        A_TrayMenu.Check(item)
                    } else {
                        A_TrayMenu.Uncheck(item)
                    }
                    writeIni("isStartUp", isStartUp)
                }
                return g
            }
        }
    }
    if (isStartUp) {
        A_TrayMenu.Check("开机自启动")
    }
    A_TrayMenu.Add("设置输入法模式", fn_input_mode)
    fn_input_mode(item, *) {
        createGui(fn).Show()
        fn(x, y, w, h) {
            global statusModeEN, conversionModeEN, mode, checkTimeout, gc

            g := Gui("AlwaysOnTop", A_ScriptName "- 设置输入法模式")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            gc.imList := ["1. 自定义", "2. 通用模式", "3. 讯飞输入法", "4. 手心输入法"]
            statusModeEN := readIni("statusModeEN", "", "InputMethod")
            conversionModeEN := readIni("conversionModeEN", "", "InputMethod")
            mode := readIni("mode", 1, "InputMethod")

            tab := g.AddTab3("-Wrap", ["基础配置", "自定义"])
            tab.UseTab(1)
            g.AddText("Section cRed", "- 一般情况，使用「通用模式」，如果是讯飞或手心输入法，则选择对应模式。`n- 当修改了输入法模式之后，如果已经打开的窗口不生效，需要重新打开。`n- 如果需要自定义，请前往 「自定义」 页面配置。")
            g.AddText(, "1. 当前输入法模式: ")
            gc.mode := g.AddDropDownList("yp AltSubmit vmode", gc.imList)
            gc.mode.OnEvent("Change", fn_change_mode)
            fn_change_mode(item, *) {
                static last := mode + 1
                if (last = item.Value) {
                    return
                }
                last := item.Value

                if (item.Value = 1) {
                    createGui(fn).Show()
                    fn(x, y, w, h) {
                        g := Gui("AlwaysOnTop")
                        g.SetFont(fz, "微软雅黑")
                        bw := w - g.MarginX * 2
                        g.AddText("cRed", "请前往 「自定义」 配置页面中设置，此处无法直接修改")
                        g.AddText("cRed", "在配置页面的左上角，「基础配置」的右侧")
                        g.AddButton("w" bw, "我知道了").OnEvent("Click", yes)
                        g.OnEvent("Close", yes)
                        yes(*) {
                            g.Destroy()
                            try {
                                gc.mode.Value := mode + 1
                            }
                        }
                        return g
                    }
                } else {
                    switch (item.Value) {
                        case 2:
                        {
                            writeIni("statusModeEN", "", "InputMethod")
                            writeIni("conversionModeEN", "", "InputMethod")
                            gc.statusModeEN.Value := ""
                            gc.conversionModeEN.Value := ""
                            statusModeEN := ""
                            conversionModeEN := ""
                        }
                        case 3:
                        {
                            ; 讯飞输入法
                            ; 中文时状态码为 2
                            ; 英文时状态码为 1
                            ; 切换码无规律不唯一
                            writeIni("statusModeEN", ":1:", "InputMethod")
                            writeIni("conversionModeEN", "", "InputMethod")
                            gc.statusModeEN.Value := "1"
                            gc.conversionModeEN.Value := ""
                            statusModeEN := ":1:"
                            conversionModeEN := ""
                        }
                        case 4:
                        {
                            ; 手心输入法:
                            ; 中文时切换码为 1025
                            ; 英文时切换码为 1
                            ; 状态码一直为 1
                            writeIni("statusModeEN", "", "InputMethod")
                            writeIni("conversionModeEN", ":1:", "InputMethod")
                            gc.statusModeEN.Value := ""
                            gc.conversionModeEN.Value := "1"
                            statusModeEN := ""
                            conversionModeEN := ":1:"
                        }
                    }
                    writeIni("mode", gc.mode.Value - 1, "InputMethod")
                    mode := readIni("mode", gc.mode.Value - 1, "InputMethod")
                    restartJetBrains()
                }
            }
            gc.mode.Value := mode + 1
            g.AddText("xs", "2. 设置获取输入法状态的超时时间: ")
            timeout := g.AddEdit("yp Number Limit5 vcheckTimeout", "")
            timeout.OnEvent("Change", fn_change_timeout)
            fn_change_timeout(item, *) {
                if (item.value != "") {
                    writeIni("checkTimeout", item.value, "InputMethod")
                    checkTimeout := item.value
                    restartJetBrains()
                }
            }
            timeout.Value := checkTimeout
            g.AddEdit("xs Disabled -VScroll w" w, "单位：毫秒，默认 500 毫秒。`n每次切换输入法状态，InputTip 会从系统获取新的输入法状态。`n如果超过了这个时间，则认为获取失败，直接显示英文状态。`n它可能是有时识别不到输入法状态的原因，可以尝试调节它。")
            g.AddText("xs", "3. Shift 按键是否可以切换输入法状态")
            gc.useShift := g.AddDropDownList("yp vuseShift Choose" useShift + 1, ["【否】(慎重选择)", "【是】"])
            gc.useShift.OnEvent("Change", fn_change_useShift)
            fn_change_useShift(item, *) {
                if (useShift = item.Value) {
                    createGui(fn).Show()
                    fn(x, y, w, h) {
                        g := Gui("AlwaysOnTop")
                        g.SetFont(fz, "微软雅黑")
                        bw := w - g.MarginX * 2
                        g.AddText("cRed", "确定要使用 【否】 吗？")
                        g.AddText("cRed", "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择 【否】。`n如果选择 【否】，在美式键盘或部分特殊输入法中，可能会导致状态提示间歇性错误。")
                        g.AddText("cRed", "更建议不要使用【否】，而是启用 Shift 切换状态，这也是几乎所有输入法的默认设置。")
                        g.AddButton("w" bw, "我确定要使用【否】").OnEvent("Click", yes)
                        g.AddButton("w" bw, "不，我只是误点了").OnEvent("Click", no)
                        yes(*) {
                            g.Destroy()
                            value := item.Value - 1
                            writeIni("useShift", value)
                            global useShift := value
                        }
                        no(*) {
                            g.Destroy()
                            try {
                                gc.useShift.Value := useShift + 1
                            }
                        }
                        return g
                    }
                } else {
                    value := item.Value - 1
                    writeIni("useShift", value)
                    global useShift := value
                    restartJetBrains()
                }
            }
            g.AddEdit("xs Disabled -VScroll w" w, "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择 【否】。`n如果选择 【否】，在美式键盘或部分特殊输入法中，可能会导致状态提示间歇性错误。")
            tab.UseTab(2)
            g.AddText("Section", "1.")
            g.AddText("yp cRed", "英文状态")
            g.AddText("yp", "时应该返回的")
            g.AddText("yp cRed", "状态码")
            g.AddText("yp", ": ")
            gc.statusModeEN := g.AddEdit("yp vstatusMode w" 100, "")
            gc.statusModeEN.Value := Trim(StrReplace(statusModeEN, ":", " "))
            gc.statusModeEN.OnEvent("Change", fn_change_statusModeEN)
            fn_change_statusModeEN(item, *) {
                if (Trim(item.Value) = "") {
                    if (conversionModeEN = "") {
                        ; 如果状态码和切换码都为空，则恢复到通用模式
                        writeIni("mode", 1, "InputMethod")
                        mode := 1
                        gc.mode.Value := 2
                    }
                    writeIni("statusModeEN", "", "InputMethod")
                    statusModeEN := ""
                } else {
                    if (mode != 0) {
                        writeIni("mode", 0, "InputMethod")
                        mode := 0
                        gc.mode.Value := 1
                    }
                    value := ":"
                    for v in StrSplit(item.value, " ") {
                        value .= v ":"
                    }
                    writeIni("statusModeEN", value, "InputMethod")
                    statusModeEN := value
                }
                restartJetBrains()
            }
            g.AddText("xs", "2.")
            g.AddText("yp cRed", "英文状态")
            g.AddText("yp", "时应该返回的")
            g.AddText("yp cRed", "切换码")
            g.AddText("yp", ": ")
            gc.conversionModeEN := g.AddEdit("yp vconversionMode w" 100, "")
            gc.conversionModeEN.Value := Trim(StrReplace(conversionModeEN, ":", " "))
            gc.conversionModeEN.OnEvent("Change", fn_change_conversionModeEN)
            fn_change_conversionModeEN(item, *) {
                if (Trim(item.Value) = "") {
                    if (statusModeEN = "") {
                        ; 如果状态码和切换码都为空，则恢复到通用模式
                        writeIni("mode", 1, "InputMethod")
                        mode := 1
                        gc.mode.Value := 2
                    }
                    writeIni("conversionModeEN", "", "InputMethod")
                    conversionModeEN := ""
                } else {
                    if (mode != 0) {
                        writeIni("mode", 0, "InputMethod")
                        mode := 0
                        gc.mode.Value := 1
                    }
                    value := ":"
                    for v in StrSplit(item.value, " ") {
                        value .= v ":"
                    }
                    writeIni("conversionModeEN", value, "InputMethod")
                    conversionModeEN := value
                }
                restartJetBrains()
            }
            g.AddButton("xs w" bw, "显示/关闭实时的状态码和切换码").OnEvent("Click", showStatus)
            showStatus(*) {
                static isOpen := 0

                if (isOpen) {
                    isOpen := 0
                } else {
                    isOpen := 1
                    SetTimer(timer, 25)
                    timer() {
                        if (isOpen) {
                            info := IME.CheckInputMode()
                            ToolTip("状态码: " IME.CheckInputMode().statusMode "`n切换码: " IME.CheckInputMode().conversionMode)
                        } else {
                            ToolTip()
                            SetTimer(, 0)
                        }
                    }
                }
            }
            g.AddEdit("xs r10 ReadOnly cGray w" w, "1. 当点击按钮 「显示实时的状态码和切换码」之后，在鼠标位置会实时显示当前的状态码和切换码。`n2. 你需要来回切换输入法中英文状态进行观察，如果不同状态时的值是唯一的，就将它填入对应的输入框中。`n3. 英文状态时的状态码和切换码在不同窗口可能不同，但只要是唯一的，就应该被填写，多个就用空格分割。`n`n举个例子: `n假如当你切换到英文后，状态码显示 0，切换码显示 1025。`n切换到中文后，状态码显示 1，切换码显示 1025。`n换到另一个窗口后又发现，英文时状态码显示 3，切换码显示 1025，中文时状态码显示 4，切换码显示 1025。`n可以发现，英文的状态码 0 和 3 是唯一的，没有在中文状态时出现，因此当状态码是它们时，可以确定当前一定是英文状态，像这样的就应该将它们填入状态码输入框中，用空格分割，即 0 3`n而切换码相反，中英文状态时都为 1025，没有办法通过 1025 去判断当前是中文还是英文，就不填切换码，保持切换码为空。")
            return g
        }
    }
    A_TrayMenu.Add("符号显示黑/白名单", fn_bw_list)
    fn_bw_list(*) {
        createGui(fn).Show()
        fn(x, y, w, h) {
            g := Gui("AlwaysOnTop", A_ScriptName "- 设置符号显示的黑/白名单")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            g.AddText("cRed", "「白」名单机制: 只有在白名单中的应用进程窗口会显示符号。`n「黑」名单机制: 只有不在黑名单中的应用进程窗口会显示符号。")
            g.AddText(, "1. 建议使用白名单机制，这样可以精确控制哪些应用进程窗口需要显示符号。`n2. 使用白名单机制，可以减少大量特殊窗口的兼容性问题。`n3. 如果选择了白名单机制，请及时添加你需要使用的应用进程到白名单中")
            g.AddText(, "-------------------------------------------------------------------------------------")

            g.AddText(, "选择显示符号的名单机制: ")
            g.AddDropDownList("yp AltSubmit vuseWhiteList Choose" useWhiteList + 1, ["使用「黑」名单", "使用「白」名单"]).OnEvent("Change", fn_change_list)
            fn_change_list(item, *) {
                value := item.Value - 1
                writeIni("useWhiteList", value)
                global useWhiteList := value
                restartJetBrains()
            }
            g.AddButton("xs w" bw, "设置「白」名单").OnEvent("Click", fn_white_list)
            g.AddButton("xs w" bw, "设置「黑」名单").OnEvent("Click", fn_black_list)
            fn_black_list(*) {
                fn_common({
                    config: "app_hide_state",
                    tip: "1. 点击上方的 「关于」查看",
                    tip2: "「符号显示黑名单」",
                    tip3: "的相关说明。",
                    about: "什么是「符号显示白名单」？`n`n1. 黑名单机制: 只有不在黑名单中的应用进程窗口才会显示符号。`n2. 使用黑名单，可能会有一些特殊窗口的兼容性问题。`n3. 建议使用白名单机制，最好少用黑名单机制。",
                    addTopText: "2. 双击应用进程，即可将其添加到「符号显示黑名单」中`n3. 添加后，黑名单机制下，在此应用窗口中时，不会显示符号(图片/方块/文本符号)",
                    addList: "以下列表是当前正在运行的应用进程",
                    addList1: "以下列表是当前正在运行的应用进程",
                    addConfirm: "是否要将",
                    addConfirm2: "添加到「符号显示黑名单」中？",
                    addConfirm3: "添加后，黑名单机制下，在此应用窗口中时，不会显示符号(图片/方块/文本符号)",
                    rmTopText: "2. 双击应用进程，将其从「符号显示黑名单」中移除`n3. 移除后，黑名单机制下，在此应用窗口中时，会显示符号(图片/方块/文本符号)",
                    rmList: "以下列表是「符号显示黑名单」",
                    rmConfirm: "是否要将",
                    rmConfirm2: "从「符号显示黑名单」中移除？",
                    rmConfirm3: "移除后，黑名单机制下，在此应用窗口中时，会显示符号(图片/方块/文本符号)",
                },
                fn
                )
                fn(info) {
                    writeIni("app_hide_state", info.newValue)
                    global app_hide_state := ":" info.newValue ":"
                    restartJetBrains()
                }
            }
            return g
        }
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("暂停/运行", pauseApp)
    A_TrayMenu.Add("暂停/运行快捷键", fn_pause_hotkey)
    fn_pause_hotkey(*) {
        hotkeyGui := Gui("AlwaysOnTop")
        hotkeyGui.SetFont(fz, "微软雅黑")
        hotkeyGui.AddText(, "-------------------------------------------------------------------------------------")
        hotkeyGui.Show("Hide")
        hotkeyGui.GetPos(, , &Gui_width)
        hotkeyGui.Destroy()

        hotkeyGui := Gui("AlwaysOnTop", A_ScriptName " - 设置暂停/运行快捷键的快捷键")
        hotkeyGui.SetFont(fz, "微软雅黑")

        tab := hotkeyGui.AddTab3("-Wrap", ["设置组合快捷键", "手动输入快捷键"])
        tab.UseTab(1)
        hotkeyGui.AddText("Section", "1.  当右侧的 Win 复选框勾选后，表示快捷键中加入 Win 修饰键")
        hotkeyGui.AddText("xs", "2.  使用 Backspace(退格键) 或 Delete(删除键) 可以移除不需要的快捷键")
        hotkeyGui.AddText("xs", "3.  如果 InputTip 正在运行，此时按下快捷键，会停止运行。")
        hotkeyGui.AddText("xs", "4.  如果 InputTip 已经暂停，此时按下快捷键，会恢复运行。")
        hotkeyGui.AddText("xs", "-------------------------------------------------------------------------------------")

        hotkeyGui.AddText("xs", "设置")
        hotkeyGui.AddText("yp cRed", "暂停/运行")
        hotkeyGui.AddText("yp", "的快捷键: ")
        value := readIni('hotkey_Pause', '')
        gc.hotkey_Pause := hotkeyGui.AddHotkey("yp vhotkey_Pause", StrReplace(value, "#", ""))

        gc.hotkey_Pause.OnEvent("Change", fn_change_hotkey1)
        fn_change_hotkey1(item, *) {
            ; 同步修改到 「手动输入快捷键」
            v := item.Value
            if (gc.win.Value) {
                v := "#" v
            }
            gc.%item.Name "2"%.Value := v
        }
        gc.win := hotkeyGui.AddCheckbox("yp vwin", "Win 键")
        gc.win.OnEvent("Click", fn_win_key)
        fn_win_key(item, *) {
            ; 同步修改到「手动输入快捷键」
            v := gc.hotkey_Pause.Value
            if (item.Value) {
                gc.hotkey_Pause2.Value := "#" v
            } else {
                gc.hotkey_Pause2.Value := v
            }
        }

        gc.win.Value := InStr(value, "#") ? 1 : 0
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes)
        yes(*) {
            if (hotkeyGui.Submit().win) {
                key := "#" hotkeyGui.Submit().hotkey_Pause
            } else {
                key := hotkeyGui.Submit().hotkey_Pause
            }
            writeIni("hotkey_Pause", key)
            fn_restart()
        }
        tab.UseTab(2)
        hotkeyGui.AddLink("Section", "1.")
        hotkeyGui.AddLink("yp cRed", "优先使用「设置组合快捷键」设置，除非因为快捷键占用无法设置。")
        hotkeyGui.AddLink("xs", '2.  如何手动输入快捷键：<a href="https://inputtip.pages.dev/enter-shortcuts-manually">https://inputtip.pages.dev/enter-shortcuts-manually</a>')
        hotkeyGui.AddText("xs", "3.  如果 InputTip 正在运行，此时按下快捷键，会停止运行。")
        hotkeyGui.AddText("xs", "4.  如果 InputTip 已经暂停，此时按下快捷键，会恢复运行。")
        hotkeyGui.AddText("xs", "-------------------------------------------------------------------------------------")

        hotkeyGui.AddText("xs", "设置")
        hotkeyGui.AddText("yp cRed", "暂停/运行")
        hotkeyGui.AddText("yp", "的快捷键: ")
        value := readIni('hotkey_Pause', '')
        gc.hotkey_Pause2 := hotkeyGui.AddEdit("yp w300 vhotkey_Pause2", readIni("hotkey_Pause", ''))
        gc.hotkey_Pause2.OnEvent("Change", fn_change_hotkey2)

        fn_change_hotkey2(item, *) {
            gc.win.Value := InStr(item.Value, "#") ? 1 : 0
            if (item.Value ~= "^~\w+\sUp$") {
                gc.hotkey_Pause.Value := ""
            } else {
                ; 当输入的快捷键符合组合快捷键时，同步修改
                try {
                    gc.hotkey_Pause.Value := StrReplace(item.Value, "#", "")
                } catch {
                    gc.hotkey_Pause.Value := ""
                }
            }
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes2)
        yes2(*) {
            if (hotkeyGui.Submit().win) {
                key := "#" hotkeyGui.Submit().hotkey_Pause
            } else {
                key := hotkeyGui.Submit().hotkey_Pause
            }
            writeIni("hotkey_Pause", key)
            fn_restart()
        }
        hotkeyGui.Show()
    }
    A_TrayMenu.Add("打开软件所在目录", fn_open_dir)
    fn_open_dir(*) {
        Run("explorer.exe /select," A_ScriptFullPath)
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("更改配置", fn_config)
    fn_config(*) {
        line := "-----------------------------------------------------------------------------------------------"
        configGui := Gui("AlwaysOnTop")
        configGui.SetFont(fz, "微软雅黑")
        configGui.AddText(, line)
        configGui.Show("Hide")
        configGui.GetPos(, , &Gui_width)
        configGui.Destroy()

        configGui := Gui("AlwaysOnTop", "InputTip - 更改配置")
        configGui.SetFont(fz, "微软雅黑")
        ; tab := configGui.AddTab3("-Wrap 0x100", ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号", "配色网站"])
        tab := configGui.AddTab3("-Wrap", ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号", "配色网站"])
        tab.UseTab(1)

        configGui.AddText("Section cRed", "在更改配置前，你应该首先阅读一下相关的说明文档")
        configGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v2/">文档官网</a>')
        configGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">Github</a>')
        configGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">Gitee</a>')
        configGui.AddLink("yp", '<a href="https://inputtip.pages.dev/FAQ/">一些常见的使用问题</a>')

        configGui.AddText("xs cRed", "所有的配置项的更改会实时生效，你可以立即看到最新效果。")
        configGui.AddText("xs", line)
        configGui.AddText("xs", "1. 要不要同步修改鼠标样式: ")
        _g := configGui.AddDropDownList("w" Gui_width / 1.6 " yp AltSubmit Choose" changeCursor + 1, ["【否】不要修改鼠标样式，保持原本的鼠标样式", "【是】需要修改鼠标样式，随输入法状态而变化"])
        _g.OnEvent("Change", fn_change_cursor)
        _g.Focus()

        fn_change_cursor(item, *) {
            static last := changeCursor + 1
            if (last = item.Value) {
                return
            }
            last := item.Value

            if (item.Value = 1) {
                writeIni("changeCursor", 0)
                global changeCursor := 0
                for v in cursorInfo {
                    if (v.origin) {
                        DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
                    }
                }

                createGui(fn).Show()
                fn(x, y, w, h) {
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText(, "正在尝试恢复到使用 InputTip 之前的鼠标样式。")
                    g.AddText("cRed", "可能无法完全恢复，你需要进行以下额外步骤或者重启系统:`n1. 进入「系统设置」=>「蓝牙和其他设备」=> 「鼠标」=>「其他鼠标设置」`n2. 先更改为另一个鼠标样式方案，再改回你之前使用的方案")
                    g.AddButton("w" bw, "我知道了").OnEvent("Click", yes)
                    yes(*) {
                        g.Destroy()
                    }
                    return g
                }
            } else {
                writeIni("changeCursor", 1)
                global changeCursor := 1

                reloadCursor()
            }
            restartJetBrains()
        }

        configGui.addText("xs", "2. 在输入光标附近显示什么类型的符号: ")
        configGui.AddDropDownList("yp AltSubmit Choose" symbolType + 1, ["不显示符号", "显示图片符号", "显示方块符号", "显示文本符号"]).OnEvent("Change", fn_symbol_type)
        fn_symbol_type(item, *) {
            writeIni("symbolType", item.Value - 1)
            global symbolType := item.Value - 1
            hideSymbol()
            updateSymbol()
            reloadSymbol()
        }
        configGui.AddText("xs", "3. 无操作时，符号在多少")
        configGui.AddText("yp cRed", "毫秒")
        configGui.AddText("yp", "后隐藏:")
        configGui.AddEdit("yp w150 Number", HideSymbolDelay).OnEvent("Change", fn_hide_symbol_delay)

        fn_hide_symbol_delay(item, *) {
            value := item.Value
            if (value = "") {
                return
            }
            if (value != 0 && value < 150) {
                value := 150
            }
            writeIni("HideSymbolDelay", value)
            global HideSymbolDelay := value
            if (value > 0) {
                updateDelay()
            }
            restartJetBrains()
        }
        configGui.AddEdit("xs Disabled -VScroll w" Gui_width, "单位: 毫秒，默认为 0 毫秒，表示不隐藏符号。`n当不为 0 时，此值不能小于 150，若小于 150，实际生效的值是 150。建议 500 以上。`n符号隐藏后，下次键盘操作或点击鼠标左键会再次显示符号")
        configGui.AddText("xs", "4. 每多少")
        configGui.AddText("yp cRed", "毫秒")
        configGui.AddText("yp", "后更新符号的显示位置和状态:")
        configGui.AddEdit("yp w150 Number Limit3", delay).OnEvent("Change", fn_delay)
        fn_delay(item, *) {
            value := item.Value
            if (value = "") {
                return
            }
            value += value <= 0
            if (value > 500) {
                value := 500
            }
            writeIni("delay", value)
            global delay := value
            restartJetBrains()
        }
        ; configGui.AddUpDown("Range1-500", delay)
        configGui.AddEdit("xs Disabled -VScroll w" Gui_width, "单位：毫秒，默认为 50 毫秒。一般使用 1-100 之间的值。`n此值的范围是 1-500，如果超出范围则无效，会取最近的可用值。`n值越小，响应越快，性能消耗越大，根据电脑性能适当调整")

        tab.UseTab(2)
        configGui.AddText(, "你可以点击以下任意网址获取设置鼠标样式文件夹的相关说明:")
        configGui.AddLink(, '<a href="https://inputtip.pages.dev/v2/#自定义鼠标样式">官网</a>   <a href="https://github.com/abgox/InputTip#自定义鼠标样式">Github</a>   <a href="https://gitee.com/abgox/InputTip#自定义鼠标样式">Gitee</a>`n' line)
        configGui.AddText("cRed", "如果列表中显示的鼠标样式文件夹路径不是最新的，请重新打开这个配置界面")
        typeList := [{
            label: "中文状态",
            type: "CN",
        }, {
            label: "英文状态",
            type: "EN",
        }, {
            label: "大写锁定",
            type: "Caps",
        }]

        dirList := StrSplit(cursorDir, ":")
        if (dirList.Length = 0) {
            dirList := getCursorDir()
        }

        configGui.AddText("Section", "选择不同状态下的鼠标样式文件夹目录路径: ")
        for i, v in typeList {
            configGui.AddText("xs", i ".")
            configGui.AddText("yp cRed", v.label)
            configGui.AddText("yp", "鼠标样式: ")
            _g := configGui.AddDropDownList("xs r9 w" Gui_width " v" v.type "_cursor", dirList)
            _g.OnEvent("Change", fn_cursor_dir)
            fn_cursor_dir(item, *) {
                if (item.Text = "") {
                    return
                }
                writeIni(item.Name, item.Text)
                switch (item.Name) {
                    case "CN_cursor":
                    {
                        global CN_cursor := item.Text
                    }
                    case "EN_cursor":
                    {
                        global EN_cursor := item.Text
                    }
                    case "Caps_cursor":
                    {
                        global Caps_cursor := item.Text
                    }
                }
                updateCursor()
                reloadCursor()
            }
            try {
                _g.Text := %v.type "_cursor"%
            } catch {
                _g.Text := ""
            }
        }
        configGui.AddButton("xs w" Gui_width, "下载鼠标样式扩展包").OnEvent("Click", fn_cursor_package)
        fn_cursor_package(*) {
            dlGui := Gui("AlwaysOnTop", "下载鼠标样式扩展包")
            dlGui.SetFont(fz, "微软雅黑")
            dlGui.AddText("Center h30", "从以下任意可用地址中下载鼠标样式扩展包:")
            dlGui.AddLink("xs", '<a href="https://inputtip.pages.dev/download/extra">https://inputtip.pages.dev/download/extra</a>')
            dlGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/releases/tag/extra">https://github.com/abgox/InputTip/releases/tag/extra</a>')
            dlGui.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/releases/tag/extra">https://gitee.com/abgox/InputTip/releases/tag/extra</a>')
            dlGui.AddText(, "其中的鼠标样式已经完成适配，解压到 InputTipCursor 目录中即可使用")
            dlGui.Show()
        }
        tab.UseTab(3)
        configGui.AddLink("Section", '点击下方链接查看图片符号的详情说明: <a href="https://inputtip.pages.dev/v2/#图片符号">官网</a>   <a href="https://github.com/abgox/InputTip#图片符号">Github</a>   <a href="https://gitee.com/abgox/InputTip#图片符号">Gitee</a>' "`n" line)

        symbolPicConfig := [{
            config: "pic_offset_x",
            options: "xs",
            opts: "",
            tip: "图片符号的水平偏移量"
        }, {
            config: "pic_symbol_width",
            options: "yp",
            opts: "Number",
            tip: "图片符号的宽度"
        }, {
            config: "pic_offset_y",
            options: "xs",
            opts: "",
            tip: "图片符号的垂直偏移量"
        }, {
            config: "pic_symbol_height",
            options: "yp",
            opts: "Number",
            tip: "图片符号的高度"
        }]
        for v in symbolPicConfig {
            configGui.AddText(v.options, v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.opts, readIni(v.config, 0)).OnEvent("Change", fn_pic_config)

            fn_pic_config(item, *) {
                value := returnNumber(item.Value)
                writeIni(item.Name, value)
                switch (item.Name) {
                    case "pic_offset_x":
                    {
                        global pic_offset_x := value
                        restartJetBrains()
                    }
                    case "pic_offset_y":
                    {
                        global pic_offset_y := value
                        restartJetBrains()
                    }
                    case "pic_symbol_width":
                    {
                        global pic_symbol_width := value
                        hideSymbol()
                        updateSymbol()
                        reloadSymbol()
                    }
                    case "pic_symbol_height":
                    {
                        global pic_symbol_height := value
                        hideSymbol()
                        updateSymbol()
                        reloadSymbol()
                    }
                }
            }
        }

        dirList := StrSplit(picDir, ":")
        if (dirList.Length = 0) {
            dirList := getPicDir()
        }

        configGui.AddText("xs Section cRed", "如果列表中显示的图片符号路径不是最新的，请重新打开这个配置界面")
        configGui.AddText(, "选择或输入不同状态下的图片符号的图片路径(只能是 .png 图片或设置为空): ")
        for i, v in typeList {
            configGui.AddText("xs", i ".")
            configGui.AddText("yp cRed", v.label)
            configGui.AddText("yp", "图片符号: ")
            _g := configGui.AddDropDownList("xs r9 w" Gui_width " v" v.type "_pic", dirList)
            _g.OnEvent("Change", fn_pic_path)
            fn_pic_path(item, *) {
                writeIni(item.Name, item.Text)
                switch (item.Name) {
                    case "CN_pic":
                    {
                        global CN_pic := item.Text
                    }
                    case "EN_pic":
                    {
                        global EN_pic := item.Text
                    }
                    case "Caps_pic":
                    {
                        global Caps_pic := item.Text
                    }
                }
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }

            try {
                _g.Text := readIni(v.type "_pic", "")
            } catch {
                _g.Text := ""
            }
        }

        configGui.AddButton("xs w" Gui_width, "下载图片符号扩展包").OnEvent("Click", fn_pic_package)
        fn_pic_package(*) {
            dlGui := Gui("AlwaysOnTop", "下载图片符号扩展包")
            dlGui.SetFont(fz, "微软雅黑")
            dlGui.AddText("Center h30", "从以下任意可用地址中下载图片符号扩展包:")
            dlGui.AddLink("xs", '<a href="https://inputtip.pages.dev/download/extra">https://inputtip.pages.dev/download/extra</a>')
            dlGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/releases/tag/extra">https://github.com/abgox/InputTip/releases/tag/extra</a>')
            dlGui.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/releases/tag/extra">https://gitee.com/abgox/InputTip/releases/tag/extra</a>')
            dlGui.AddText(, "将其中的图片解压到 InputTipSymbol 目录中即可使用")
            dlGui.Show()
        }

        tab.UseTab(4)
        symbolBlockColorConfig := [{
            config: "CN_color",
            options: "",
            tip: "中文状态时方块符号的颜色",
            colors: ["red", "#FF5555", "#F44336", "#D23600", "#FF1D23", "#D40D12", "#C30F0E", "#5C0002", "#450003"]
        }, {
            config: "EN_color",
            options: "",
            tip: "英文状态时方块符号的颜色",
            colors: ["blue", "#528BFF", "#0EEAFF", "#59D8E6", "#2962FF", "#1B76FF", "#2C1DFF", "#1C3FFD", "#1510F0"]
        }, {
            config: "Caps_color",
            options: "",
            tip: "大写锁定时方块符号的颜色",
            colors: ["green", "#4E9A06", "#96ED89", "#66BB6A", "#8BC34A", "#45BF55", "#43A047", "#2E7D32", "#33691E"]
        }]
        symbolBlockConfig := [{
            config: "transparent",
            options: "Number Limit3",
            tip: "方块符号的透明度"
        }, {
            config: "offset_x",
            options: "",
            tip: "方块符号的水平偏移量"
        }, {
            config: "offset_y",
            options: "",
            tip: "方块符号的垂直偏移量"
        }, {
            config: "symbol_height",
            options: "Number",
            tip: "方块符号的高度"
        }, {
            config: "symbol_width",
            options: "Number",
            tip: "方块符号的宽度"
        }]
        configGui.AddText("Section", "不同状态时方块符号的颜色可以设置为空，表示不显示对应的方块符号`n" line)
        for v in symbolBlockColorConfig {
            configGui.AddText("xs", v.tip ": ")
            _g := configGui.AddComboBox("v" v.config " yp w150 " v.options, v.colors)
            _g.OnEvent("Change", fn_color_config)
            fn_color_config(item, *) {
                value := item.Text
                writeIni(item.Name, value)
                switch (item.Name) {
                    case "CN_color":
                    {
                        global CN_color := value
                    }
                    case "EN_color":
                    {
                        global EN_color := value
                    }
                    case "Caps_color":
                    {
                        global Caps_color := value
                    }
                }
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }
            _g.Text := readIni(v.config, "red")
        }
        for v in symbolBlockConfig {
            configGui.AddText("xs", v.tip ": ")
            if (v.config = "transparent") {
                configGui.AddEdit("v" v.config " yp w150 " v.options, readIni(v.config, 1)).OnEvent("Change", fn_trans_config)
                fn_trans_config(item, *) {
                    value := item.Text
                    if (value = "") {
                        return
                    }
                    if (value > 255) {
                        value := 255
                    }
                    writeIni(item.Name, value)
                    hideSymbol()
                    updateSymbol()
                    reloadSymbol()
                }
            } else {
                configGui.AddEdit("v" v.config " yp w150 " v.options, readIni(v.config, 1)).OnEvent("Change", fn_block_config)
                fn_block_config(item, *) {
                    value := returnNumber(item.Text)
                    writeIni(item.Name, value)
                    switch (item.Name) {
                        case "transparent":
                        {
                            global transparent := value
                        }
                        case "offset_x":
                        {
                            global offset_x := value
                        }
                        case "offset_y":
                        {
                            global offset_y := value
                        }
                        case "symbol_height":
                        {
                            global symbol_height := value
                        }
                        case "symbol_width":
                        {
                            global symbol_width := value
                        }
                    }
                    hideSymbol()
                    updateSymbol()
                    reloadSymbol()
                }
            }
        }
        symbolStyle := ["无", "样式1", "样式2", "样式3"]
        configGui.AddText("xs", "边框样式: ")
        _g := configGui.AddDropDownList("AltSubmit vborder_type" " yp w150 ", symbolStyle)
        _g.OnEvent("Change", fn_border_config)
        fn_border_config(item, *) {
            value := item.Value
            writeIni("border_type", value - 1)
            global border_type := value - 1
            hideSymbol()
            updateSymbol()
            reloadSymbol()
        }
        _g.Value := readIni("border_type", "") + 1
        tab.UseTab(5)
        symbolCharConfig := [{
            config: "font_family",
            options: "",
            tip: "文本字符的字体"
        }, {
            config: "font_size",
            options: "Number",
            tip: "文本字符的大小"
        }, {
            config: "font_weight",
            options: "Number",
            tip: "文本字符的粗细"
        }, {
            config: "font_color",
            options: "",
            tip: "文本字符的颜色"
        }, {
            config: "CN_Text",
            options: "",
            tip: "中文状态时显示的文本字符"
        }, {
            config: "EN_Text",
            options: "",
            tip: "英文状态时显示的文本字符"
        }, {
            config: "Caps_Text",
            options: "",
            tip: "大写锁定时显示的文本字符"
        }]
        configGui.AddText("Section cRed", "1. 符号偏移量、透明度、边框样式以及不同状态下的背景颜色由方块符号中的相关配置决定")
        configGui.AddText("xs", "2. 不同状态时显示的文本字符可以设置为空，表示不显示对应的文本字符")
        configGui.AddText("xs", "3. 当方块符号中的背景颜色设置为空时，对应的文本字符也不显示`n" line)
        for v in symbolCharConfig {
            configGui.AddText("xs", v.tip ": ")
            configGui.AddEdit("v" v.config " yp w150 " v.options, %v.config%).OnEvent("Change", fn_char_config)

            fn_char_config(item, *) {
                value := item.Text
                switch (item.Name) {
                    case "font_family":
                    {
                        global font_family := value
                    }
                    case "font_size":
                    {
                        if (value = "") {
                            return
                        }
                        global font_size := value
                    }
                    case "font_weight":
                    {
                        if (value = "") {
                            return
                        }
                        global font_weight := value
                    }
                    case "font_color":
                    {
                        global font_color := value
                    }
                    case "CN_Text":
                    {
                        global CN_Text := value
                    }
                    case "EN_Text":
                    {
                        global EN_Text := value
                    }
                    case "Caps_Text":
                    {
                        global Caps_Text := value
                    }
                }
                writeIni(item.Name, value)
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }
        }
        tab.UseTab(6)
        configGui.AddText(, "1. 对于颜色相关的配置，建议使用 16 进制的颜色值`n2. 不过由于没有调色板，可能并不好设置`n3. 建议使用以下配色网站(也可以自己去找)，找到喜欢的颜色，复制 16 进制值`n4. 显示的颜色以最终渲染的颜色效果为准")
        configGui.AddLink(, '<a href="https://colorhunt.co">https://colorhunt.co</a>')
        configGui.AddLink(, '<a href="https://materialui.co/colors">https://materialui.co/colors</a>')
        configGui.AddLink(, '<a href="https://color.adobe.com/zh/create/color-wheel">https://color.adobe.com/zh/create/color-wheel</a>')
        configGui.AddLink(, '<a href="https://colordesigner.io/color-palette-builder">https://colordesigner.io/color-palette-builder</a>')

        configGui.Show()
        SetTimer(getDir, -1)
        getDir() {
            _cursorDir := arrJoin(getCursorDir(), ":")
            _picDir := arrJoin(getPicDir(), ":")
            if (cursorDir != _cursorDir) {
                global cursorDir := _cursorDir
                writeIni("cursorDir", _cursorDir)
            }
            if (picDir != _picDir) {
                global picDir := _picDir
                writeIni("picDir", _picDir)
            }
        }
    }
    A_TrayMenu.Add("设置快捷键", fn_switch_key)
    fn_switch_key(*) {
        hotkeyGui := Gui("AlwaysOnTop")
        hotkeyGui.SetFont(fz, "微软雅黑")
        hotkeyGui.AddText(, "-------------------------------------------------------------------------------------")
        hotkeyGui.Show("Hide")
        hotkeyGui.GetPos(, , &Gui_width)
        hotkeyGui.Destroy()

        hotkeyGui := Gui("AlwaysOnTop", A_ScriptName " - 设置强制切换输入法状态的快捷键")
        hotkeyGui.SetFont(fz, "微软雅黑")

        tab := hotkeyGui.AddTab3("-Wrap", ["设置单键", "设置组合快捷键", "手动输入快捷键"])
        tab.UseTab(1)
        hotkeyGui.AddText("Section", "1.  LShift 指的是左侧的 Shift 键，RShift 指的是右侧的 Shift 键，以此类推")
        hotkeyGui.AddText("xs", "2.  如果要移除快捷键，请选择「无」`n-------------------------------------------------------------------------------------")

        singleHotKeyList := [{
            tip: "中文状态",
            config: "single_hotkey_CN",
        }, {
            tip: "英文状态",
            config: "single_hotkey_EN",
        }, {
            tip: "大写锁定",
            config: "single_hotkey_Caps",
        }]
        for v in singleHotKeyList {
            hotkeyGui.AddText("xs", "强制切换到")
            hotkeyGui.AddText("yp cRed", v.tip)
            hotkeyGui.AddText("yp", ":")
            gc.%v.config% := hotkeyGui.AddDropDownList("yp v" v.config, ["无", "LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "Esc"])
            gc.%v.config%.OnEvent("Change", fn_change_hotkey)
            fn_change_hotkey(item, *) {
                static last := ""
                if (last = item.Value) {
                    return
                }
                last := item.Value

                ; 同步修改到 「设置组合快捷键」和 「手动输入快捷键」
                if (item.Text = "无") {
                    key := ""
                } else {
                    key := "~" item.Text " Up"
                }
                type := SubStr(item.Name, 15)
                gc.%"hotkey_" type%.Value := ""
                gc.%"hotkey_" type "2"%.Value := key
                gc.%"win_" type%.Value := 0
            }

            config := readIni(StrReplace(v.config, "single_", " "), "")

            if (config ~= "^~\w+\sUp$") {
                try {
                    gc.%v.config%.Text := Trim(StrReplace(StrReplace(config, "~", ""), "Up", ""))
                    if (!gc.%v.config%.Value) {
                        gc.%v.config%.Value := 1
                    }
                } catch {
                    gc.%v.config%.Text := "无"
                }
            } else {
                gc.%v.config%.Text := "无"
            }
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", confirm)
        confirm(*) {
            for v in singleHotKeyList {
                value := hotkeyGui.Submit().%v.config%
                if (value = "无") {
                    key := ""
                } else {
                    key := "~" value " Up"
                }
                writeIni(StrReplace(v.config, "single_", " "), key)
            }
            fn_restart()
        }
        tab.UseTab(2)
        hotkeyGui.AddText("Section", "1.  当右侧的 Win 复选框勾选后，表示快捷键中加入 Win 修饰键")
        hotkeyGui.AddText("xs", "2.  使用 Backspace(退格键) 或 Delete(删除键) 可以移除不需要的快捷键`n-------------------------------------------------------------------------------------")

        configList := [{
            config: "hotkey_CN",
            options: "",
            tip: "中文状态",
            with: "win_CN",
        }, {
            config: "hotkey_EN",
            options: "",
            tip: "英文状态",
            with: "win_EN",
        }, {
            config: "hotkey_Caps",
            options: "",
            tip: "大写锁定",
            with: "win_Caps",
        }]

        for v in configList {
            hotkeyGui.AddText("xs", "强制切换到")
            hotkeyGui.AddText("yp cRed", v.tip)
            hotkeyGui.AddText("yp", ":")
            value := readIni(v.config, '')
            gc.%v.config% := hotkeyGui.AddHotkey("yp v" v.config, StrReplace(value, "#", ""))

            gc.%v.config%.OnEvent("Change", fn_change_hotkey1)
            fn_change_hotkey1(item, *) {
                ; 同步修改到 「设置单键」和 「手动输入快捷键」
                gc.%"single_" item.Name%.Text := "无"
                v := item.Value
                if (gc.%"win_" SubStr(item.Name, 8)%.Value) {
                    v := "#" v
                }
                gc.%item.Name "2"%.Value := v
            }
            gc.%v.with% := hotkeyGui.AddCheckbox("yp v" v.with, "Win 键")
            gc.%v.with%.OnEvent("Click", fn_win_key)
            fn_win_key(item, *) {
                ; 同步修改到 「设置单键」和 「手动输入快捷键」
                type := SubStr(item.Name, 5)
                gc.%"single_hotkey_" type%.Text := "无"

                v := gc.%"hotkey_" type%.Value
                if (item.Value) {
                    gc.%"hotkey_" type "2"%.Value := "#" v
                } else {
                    gc.%"hotkey_" type "2"%.Value := v
                }
            }
            gc.%v.with%.Value := InStr(value, "#") ? 1 : 0
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes)
        yes(*) {
            for v in configList {
                if (hotkeyGui.Submit().%v.with%) {
                    key := "#" hotkeyGui.Submit().%v.config%
                } else {
                    key := hotkeyGui.Submit().%v.config%
                }
                writeIni(v.config, key)
            }
            fn_restart()
        }
        tab.UseTab(3)
        hotkeyGui.AddLink("Section", "1.")
        hotkeyGui.AddLink("yp cRed", "优先使用「设置单键」或「设置组合快捷键」设置，除非因为快捷键占用无法设置。")
        hotkeyGui.AddLink("xs", '2.  如何手动输入快捷键：<a href="https://inputtip.pages.dev/enter-shortcuts-manually">https://inputtip.pages.dev/enter-shortcuts-manually</a>`n-------------------------------------------------------------------------------------')
        for v in configList {
            hotkeyGui.AddText("xs", "强制切换到")
            hotkeyGui.AddText("yp cRed", v.tip)
            hotkeyGui.AddText("yp", ":")
            gc.%v.config "2"% := hotkeyGui.AddEdit("yp w300 v" v.config "2", readIni(v.config, ''))
            gc.%v.config "2"%.OnEvent("Change", fn_change_hotkey2)
            fn_change_hotkey2(item, *) {
                type := StrReplace(SubStr(item.Name, 8), "2", "")
                gc.%"win_" type%.Value := InStr(item.Value, "#") ? 1 : 0

                ; 当输入的快捷键符合单键时，同步修改
                if (item.Value ~= "^~\w+\sUp$") {
                    try {
                        gc.%"single_hotkey_" type%.Text := Trim(StrReplace(StrReplace(item.Value, "~", ""), "Up", ""))
                    } catch {
                        gc.%"single_hotkey_" type%.Text := "无"
                    }
                    gc.%"hotkey_" type%.Value := ""
                } else {
                    gc.%"single_hotkey_" type%.Text := "无"
                    ; 当输入的快捷键符合组合快捷键时，同步修改
                    try {
                        gc.%"hotkey_" type%.Value := StrReplace(item.Value, "#", "")
                    } catch {
                        gc.%"hotkey_" type%.Value := ""
                    }
                }
            }
        }
        hotkeyGui.AddButton("xs w" Gui_width, "确定").OnEvent("Click", yes2)
        yes2(*) {
            for v in configList {
                key := hotkeyGui.Submit().%v.config "2"%
                writeIni(v.config, key)
            }
            fn_restart()
        }
        hotkeyGui.Show()
    }
    sub1 := Menu()
    sub1.Add("自动切换到中文状态", fn_switch_CN)
    fn_switch_CN(*) {
        fn_common({
            config: "app_CN",
            tip: "1. 点击上方的 「关于」查看",
            tip2: "「自动切换中文状态的应用列表」",
            tip3: "的相关说明。",
            about: "什么是「自动切换中文状态的应用列表」？`n`n1. 如果应用在此列表中，当此应用窗口激活时，会尝试将输入法切换到中文状态`n2. 三个自动切换的应用列表(中文/英文/大写)，不会冲突，始终以最新的添加为主",
            addTopText: "2. 双击应用进程，即可将其添加到「自动切换中文状态的应用列表」中。`n3. 双击每一行的任意位置都可以，然后根据后续提示操作。",
            addList: "以下列表是当前正在运行的应用进程",
            addList1: "以下列表是当前系统正在运行的应用进程(包含后台和隐藏窗口)",
            addConfirm: "是否要将",
            addConfirm2: "添加到「自动切换中文状态的应用列表」中？",
            addConfirm3: "添加后，当此应用窗口激活时，会自动尝试将输入法切换到中文状态",
            rmTopText: "2. 双击应用进程，即可将其移除。`n3. 双击每一行的任意位置都可以，然后根据后续提示操作。",
            rmList: "以下列表中是「自动切换中文状态的应用列表」",
            rmConfirm: "是否要将",
            rmConfirm2: "从「自动切换中文状态的应用列表」中移除？",
            rmConfirm3: "移除后，当此应用窗口激活时，不会再自动尝试将输入法切换到中文状态",
        }, fn
        )
        fn(info) {
            value_EN := ":" readIni("app_EN", "") ":"
            value_Caps := ":" readIni("app_Caps", "") ":"
            if (InStr(value_EN, ":" info.RowText ":")) {
                valueArr := StrSplit(value_EN, ":")
                result := ""
                for v in valueArr {
                    if (v != info.RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
                global app_EN := ":" readIni("app_EN", "") ":"
            }

            if (InStr(value_Caps, ":" info.RowText ":")) {
                valueArr := StrSplit(value_Caps, ":")
                result := ""
                for v in valueArr {
                    if (v != info.RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_Caps", SubStr(result, 2))
                global app_Caps := ":" readIni("app_Caps", "") ":"
            }

            writeIni("app_CN", info.newValue)
            global app_CN := ":" info.newValue ":"
            restartJetBrains()
        }
    }
    sub1.Add("自动切换到英文状态", fn_switch_EN)
    fn_switch_EN(*) {
        fn_common({
            config: "app_EN",
            tip: "1. 点击上方的 「关于」查看",
            tip2: "「自动切换英文状态的应用列表」",
            tip3: "的相关说明。",
            about: "什么是「自动切换英文状态的应用列表」？`n`n1. 如果应用在此列表中，当此应用窗口激活时，会尝试将输入法切换到英文状态`n2. 三个自动切换的应用列表(中文/英文/大写)，不会冲突，始终以最新的添加为主",
            addTopText: "2. 双击应用进程，即可将其添加到「自动切换英文状态的应用列表」中。`n3. 双击每一行的任意位置都可以，然后根据后续提示操作。",
            addList: "以下列表是当前正在运行的应用进程",
            addList1: "以下列表是当前系统正在运行的应用进程(包含后台和隐藏窗口)",
            addConfirm: "是否要将",
            addConfirm2: "添加到「自动切换英文状态的应用列表」中？",
            addConfirm3: "添加后，当此应用窗口激活时，会自动尝试将输入法切换到英文状态",
            rmTopText: "2. 双击应用进程，即可将其移除。`n3. 双击每一行的任意位置都可以，然后根据后续提示操作。",
            rmList: "以下列表中是「自动切换英文状态的应用列表」",
            rmConfirm: "是否要将",
            rmConfirm2: "从「自动切换英文状态的应用列表」中移除？",
            rmConfirm3: "移除后，当此应用窗口激活时，不会再自动尝试将输入法切换到英文状态",
        },
        fn
        )
        fn(info) {
            value_CN := ":" readIni("app_CN", "") ":"
            value_Caps := ":" readIni("app_Caps", "") ":"
            if (InStr(value_CN, ":" info.RowText ":")) {
                valueArr := StrSplit(value_CN, ":")
                result := ""
                for v in valueArr {
                    if (v != info.RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
                global app_CN := ":" readIni("app_CN", "") ":"
            }

            if (InStr(value_Caps, ":" info.RowText ":")) {
                valueArr := StrSplit(value_Caps, ":")
                result := ""
                for v in valueArr {
                    if (v != info.RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_Caps", SubStr(result, 2))
                global app_Caps := ":" readIni("app_Caps", "") ":"
            }

            writeIni("app_EN", info.newValue)
            global app_EN := ":" info.newValue ":"
            restartJetBrains()
        }
    }
    sub1.Add("自动切换到大写锁定", fn_switch_Caps)
    fn_switch_Caps(*) {
        fn_common({
            config: "app_Caps",
            tip: "1. 点击上方的 「关于」查看",
            tip2: "「自动切换大写锁定的应用列表」",
            tip3: "的相关说明。",
            about: "什么是「自动切换大写锁定的应用列表」？`n`n1. 如果应用在此列表中，当此应用窗口激活时，会尝试将输入法切换到大写锁定`n2. 三个自动切换的应用列表(中文/英文/大写)，不会冲突，始终以最新的添加为主",
            addTopText: "2. 双击应用进程，即可将其添加到「自动切换大写锁定的应用列表」中。`n3. 双击每一行的任意位置都可以，然后根据后续提示操作。",
            addList: "以下列表是当前正在运行的应用进程",
            addList1: "以下列表是当前系统正在运行的应用进程(包含后台和隐藏窗口)",
            addConfirm: "是否要将",
            addConfirm2: "添加到「自动切换大写锁定的应用列表」中？",
            addConfirm3: "添加后，当此应用窗口激活时，会自动尝试将输入法切换到大写锁定",
            rmTopText: "2. 双击应用进程，即可将其移除。`n3. 双击每一行的任意位置都可以，然后根据后续提示操作。",
            rmList: "以下列表中是「自动切换大写锁定的应用列表」",
            rmConfirm: "是否要将",
            rmConfirm2: "从「自动切换大写锁定的应用列表」中移除？",
            rmConfirm3: "移除后，当此应用窗口激活时，不会再自动尝试将输入法切换到大写锁定",
        },
        fn
        )
        fn(info) {
            value_CN := ":" readIni("app_CN", "") ":"
            value_EN := ":" readIni("app_EN", "") ":"
            if (InStr(value_CN, ":" info.RowText ":")) {
                valueArr := StrSplit(value_CN, ":")
                result := ""
                for v in valueArr {
                    if (v != info.RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_CN", SubStr(result, 2))
                global app_CN := ":" readIni("app_CN", "") ":"
            }
            if (InStr(value_EN, ":" info.RowText ":")) {
                valueArr := StrSplit(value_EN, ":")
                result := ""
                for v in valueArr {
                    if (v != info.RowText && Trim(v)) {
                        result .= ":" v
                    }
                }
                writeIni("app_EN", SubStr(result, 2))
                global app_EN := ":" readIni("app_EN", "") ":"
            }

            writeIni("app_Caps", info.newValue)
            global app_Caps := ":" info.newValue ":"
            restartJetBrains()
        }
    }
    A_TrayMenu.Add("设置自动切换", sub1)
    A_TrayMenu.Add("设置特殊偏移量", fn_offset)
    fn_offset(*) {
        offsetGui := Gui("AlwaysOnTop")
        offsetGui.SetFont(fz, "微软雅黑")
        offsetGui.AddText("Section", "- 由于 JetBrains 系列 IDE，在副屏上会存在极大的坐标偏差`n- 需要自己手动的通过调整对应屏幕的偏移量，使其正确显示`n- 注意: 你需要先开启 Java Access Bridge，具体操作步骤，请查看以下网址:")
        offsetGui.AddLink(, '<a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
        offsetGui.Show("Hide")
        offsetGui.GetPos(, , &Gui_width)
        offsetGui.Destroy()

        offsetGui := Gui("AlwaysOnTop", A_ScriptName " - 设置特殊偏移量")
        offsetGui.SetFont(fz, "微软雅黑")
        tab := offsetGui.AddTab3("-Wrap", ["JetBrains IDE"])
        tab.UseTab(1)
        offsetGui.AddText("Section", "- 由于 JetBrains 系列 IDE，在副屏上会存在极大的坐标偏差`n- 需要自己通过手动调整对应屏幕的偏移量，使其正确显示`n- 你可以通过以下链接了解如何在 JetBrains 系列 IDE 中使用 InputTip :")
        offsetGui.AddLink(, '- <a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>`n- <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>`n- <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
        btn := offsetGui.AddButton("w" Gui_width, "设置 JetBrains 系列 IDE 的偏移量")
        btn.Focus()
        btn.OnEvent("Click", JetBrains_offset)

        JetBrains_offset(*) {
            offsetGui.Destroy()
            JetBrainsGui := Gui("AlwaysOnTop", A_ScriptName " - 设置 JetBrains 系列 IDE 的偏移量")
            JetBrainsGui.SetFont(fz, "微软雅黑")
            screenList := getScreenInfo()
            JetBrainsGui.AddText(, "你需要通过屏幕坐标信息判断具体是哪一块屏幕`n`n - 假设你有两块屏幕，主屏幕在左侧，另一块屏幕在右侧`n - 那么另一块屏幕的左上角 X 坐标一定大于主屏幕的右下角 X 坐标`n - 以此判断以下屏幕哪一块是右侧的屏幕")
            pages := []
            for v in screenList {
                pages.push("屏幕 " v.num)
            }
            tab := JetBrainsGui.AddTab3("-Wrap", pages)
            for v in screenList {
                tab.UseTab(v.num)
                if (v.num = v.main) {
                    JetBrainsGui.AddText(, "这是主屏幕(主显示器)")
                } else {
                    JetBrainsGui.AddText(, "这是副屏幕(副显示器)")
                }

                JetBrainsGui.AddText(, "屏幕坐标信息: 左上角(" v.left ", " v.top ")，右下角(" v.right ", " v.bottom ")")

                x := 0, y := 0
                try {
                    x := IniRead("InputTip.ini", "config-v2", "offset_JetBrains_x_" v.num)
                }
                try {
                    y := IniRead("InputTip.ini", "config-v2", "offset_JetBrains_y_" v.num)
                }

                JetBrainsGui.AddText(, "水平方向的偏移量: ")
                _g := JetBrainsGui.AddEdit("voffset_JetBrains_x_" v.num " yp w100", x)
                _g.__num := v.num
                _g.OnEvent("Change", fn_change_offset_x)
                fn_change_offset_x(item, *) {
                    writeIni("offset_JetBrains_x_" item.__num, returnNumber(item.Value))
                }
                JetBrainsGui.AddText("yp", "垂直方向的偏移量: ")
                _g := JetBrainsGui.AddEdit("voffset_JetBrains_y_" v.num " yp w100", y)
                _g.__num := v.num
                _g.OnEvent("Change", fn_change_offset_y)
                fn_change_offset_y(item, *) {
                    writeIni("offset_JetBrains_y_" item.__num, returnNumber(item.Value))
                }
            }
            JetBrainsGui.Show()
        }
        offsetGui.Show()
    }
    A_TrayMenu.Add("启用 JetBrains IDE 支持", fn_JetBrains)
    fn_JetBrains(item, *) {
        global enableJetBrainsSupport := !enableJetBrainsSupport
        writeIni("enableJetBrainsSupport", enableJetBrainsSupport)
        A_TrayMenu.ToggleCheck(item)
        if (enableJetBrainsSupport) {
            FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
            waitFileInstall("InputTip.JAB.JetBrains.exe", 0)
            createGui(fn).Show()
            fn(x, y, w, h) {
                g := Gui("AlwaysOnTop")
                g.SetFont(fz, "微软雅黑")
                bw := w - g.MarginX * 2
                g.AddText(, "已成功启用 JetBrains IDE 支持，你还需要进行以下步骤:")
                g.AddText(, "1. 开启 Java Access Bridge`n2. 点击托盘菜单中的 「添加 JetBrains IDE 应用」，确保你使用的 JetBrains IDE 已经被添加`n3. 重启 InputTip 和你正在使用的 JetBrains IDE`n5. 如果没有生效，请重启电脑")
                g.AddText(, "具体操作步骤，请查看以下任意网址:")
                g.AddLink(, '- <a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
                g.AddLink(, '- <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
                g.AddLink(, '- <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>')
                g.AddButton("xs w" bw, "我知道了").OnEvent("Click", yes)
                yes(*) {
                    g.Destroy()
                }
                return g
            }
            runJetBrains()
        } else {
            SetTimer(timer2, -100)
            timer2() {
                try {
                    RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
                    if (A_IsAdmin) {
                        Run('schtasks /delete /tn "abgox.InputTip.JAB.JetBrains" /f', , "Hide")
                        try {
                            FileDelete("InputTip.JAB.JetBrains.exe")
                        }
                    }
                }
            }
        }
    }
    A_TrayMenu.Add("添加 JetBrains IDE 应用", fn_add_JetBrains)
    fn_add_JetBrains(*) {
        fn_common({
            config: "JetBrains_list",
            tip: "1. 当勾选",
            tip2: "「启用 JetBrains IDE 支持」",
            tip3: "后，请确保 JetBrains IDE 已经被添加。",
            about: '- 首先你需要添加 JetBrains 系列 IDE 应用程序进程。`n- 然后勾选「启用 JetBrains IDE 支持」，就可以在这些应用中使用 InputTip。`n- 如果未生效，你需要检查以下步骤是否完成:`n  1. 开启 Java Access Bridge`n  2. 点击托盘菜单中的 「添加 JetBrains IDE 应用」，确保 JetBrains IDE 已经添加`n  3. 重启你正在使用的 JetBrains IDE`n  4. 如果没有生效，请重启电脑。`n`n相关链接: `n`n<a href="https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip">https://inputtip.pages.dev/FAQ/#如何在-jetbrains-系列-ide-中使用-inputtip</a>`n`n<a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>`n`n<a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip</a>',
            addTopText: "2. 双击应用进程进行添加`n3. 如果有非 JetBrains 系列 IDE 应用进程被意外添加，请立即移除`n4. 白名单机制下，还需要再添加到白名单中才会有效。",
            addList: "以下列表是当前正在运行的应用进程",
            addList1: "以下列表是当前系统正在运行的应用进程(包含后台和隐藏窗口)",
            addConfirm: "是否要添加",
            addConfirm2: "？",
            addConfirm3: "注意: 如果此应用进程不是 JetBrains 系列 IDE 应用程序，你不应该添加它",
            rmTopText: "2. 双击应用进程进行移除`n3. 如果有非 JetBrains 系列 IDE 应用进程被意外添加，请立即移除",
            rmList: "以下列表是已经添加的 JetBrains 系列 IDE 应用程序",
            rmConfirm: "是否要将",
            rmConfirm2: "移除？",
            rmConfirm3: "如果它是一个 JetBrains 系列 IDE 应用程序，不建议移除它。`n反之，如果它不是，请立即移除。",
        },
        fn
        )
        fn(info) {
            writeIni("JetBrains_list", info.newValue)
            global JetBrains_list := ":" readIni("JetBrains_list", "") ":"
            restartJetBrains()
        }
    }
    if (enableJetBrainsSupport) {
        A_TrayMenu.Check("启用 JetBrains IDE 支持")
        runJetBrains()
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("关于", fn_about)
    fn_about(*) {
        aboutGui := Gui("AlwaysOnTop")
        aboutGui.SetFont(fz, "微软雅黑")
        aboutGui.AddText(, "InputTip - 一个输入法状态(中文/英文/大写锁定)提示工具")
        aboutGui.AddLink(, '- 因为实现简单，就是去掉 v1 中方块符号的文字，加上不同的背景颜色')
        aboutGui.AddPicture("w365 h-1", "InputTipSymbol\default\offer.png")
        aboutGui.Show("Hide")
        aboutGui.GetPos(, , &Gui_width)
        aboutGui.Destroy()

        aboutGui := Gui("AlwaysOnTop", A_ScriptName " - v" currentVersion)
        aboutGui.SetFont(fz, "微软雅黑")
        aboutGui.AddText("Center w" Gui_width, "InputTip - 一个输入法状态(中文/英文/大写锁定)实时提示工具")
        tab := aboutGui.AddTab3("-Wrap", ["关于项目", "赞赏支持", "参考项目", "其他项目"])
        tab.UseTab(1)
        aboutGui.AddText("Section", '当前版本: ')
        aboutGui.AddEdit("yp ReadOnly cRed", currentVersion)
        aboutGui.AddText("xs", '开发人员: ')
        aboutGui.AddEdit("yp ReadOnly", 'abgox')
        aboutGui.AddText("xs", 'QQ 账号: ')
        aboutGui.AddEdit("yp ReadOnly", '1151676611')
        aboutGui.AddText("xs", 'QQ 群聊(交流反馈): ')
        aboutGui.AddEdit("yp ReadOnly", '451860327')
        aboutGui.AddText("xs", "-------------------------------------------------------------------------------")
        aboutGui.AddLink("xs", '1. 官网: <a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
        aboutGui.AddLink("xs", '2. Github: <a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        aboutGui.AddLink("xs", '3. Gitee: <a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
        tab.UseTab(2)
        aboutGui.AddText("Section", "如果 InputTip 对你有所帮助，你也可以出于善意, 向我捐款。`n非常感谢对 InputTip 的支持！希望 InputTip 能一直帮助你！")
        aboutGui.AddPicture("w432 h-1", "InputTipSymbol\default\offer.png")
        tab.UseTab(3)
        aboutGui.AddLink("Section", '1. <a href="https://github.com/aardio/ImTip">ImTip - aardio</a>')
        aboutGui.AddLink("xs", '2. <a href="https://github.com/flyinclouds/KBLAutoSwitch">KBLAutoSwitch - flyinclouds</a>')
        aboutGui.AddLink("xs", '3. <a href="https://github.com/Tebayaki/AutoHotkeyScripts">AutoHotkeyScripts - Tebayaki</a>')
        aboutGui.AddLink("xs", '4. <a href="https://github.com/Autumn-one/RedDot">RedDot - Autumn-one</a>')
        aboutGui.AddLink("xs", '5. <a href="https://github.com/yakunins/language-indicator">language-indicator - yakunins</a>')
        aboutGui.AddLink("xs", '- InputTip v1 是在鼠标附近显示带文字的方块符号')
        aboutGui.AddLink("xs", '- InputTip v2 默认通过不同颜色的鼠标样式来区分')
        aboutGui.AddLink("xs", '- 后来参照了 RedDot 和 language-indicator 的设计')
        aboutGui.AddLink("xs", '- 因为实现很简单，就是去掉 v1 中方块符号的文字，加上不同的背景颜色')

        tab.UseTab(4)
        aboutGui.AddLink("Section w" Gui_width, '1. <a href="https://pscompletions.pages.dev/">PSCompletions</a> : 一个 PowerShell 补全模块，它能让你在 PowerShell 中更简单、更方便地使用命令补全。')
        aboutGui.AddLink("Section w" Gui_width, '2. ...')

        tab.UseTab(0)
        btn := aboutGui.AddButton("Section w" Gui_width + aboutGui.MarginX * 2, "关闭")
        btn.Focus()
        btn.OnEvent("Click", fn_close)
        fn_close(*) {
            aboutGui.Destroy()
        }
        aboutGui.Show()
    }
    A_TrayMenu.Add("重启", fn_restart)
    fn_restart(flag := 0, *) {
        if (flag || enableJetBrainsSupport) {
            RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
        }
        Run(A_ScriptFullPath)
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add("退出", fn_exit)
    fn_exit(*) {
        RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
        ExitApp()
    }
}

fn_common(tipList, handleFn) {
    show()
    show(deep := "") {
        createGui(fn).Show()
        fn(x, y, w, h) {
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            tab := g.AddTab3("-Wrap", ["添加应用", "移除应用", "关于"])
            tab.UseTab(1)
            g.AddLink("Section", tipList.tip)
            g.AddLink("yp cRed", tipList.tip2)
            g.AddLink("yp", tipList.tip3)
            g.AddLink("xs", tipList.addTopText)
            g.AddLink(, tipList.%"addList" deep%)
            gc.addLV := g.AddListView("-Multi r9 NoSortHdr Sort Grid w" bw, ["应用进程", "窗口标题"])
            gc.addLV.OnEvent("DoubleClick", fn_double_click)
            fn_double_click(LV, RowNumber) {
                RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                createGui(fn).Show()
                fn(x, y, w, h) {
                    g_1 := Gui("AlwaysOnTop")
                    g_1.SetFont(fz, "微软雅黑")
                    bw := w - g_1.MarginX * 2

                    g_1.AddLink(, tipList.addConfirm)
                    g_1.AddLink("yp cRed", RowText)
                    g_1.AddLink("yp", tipList.addConfirm2)
                    g_1.AddLink("xs", tipList.addConfirm3)
                    g_1.AddButton("xs w" bw, "确认添加").OnEvent("Click", yes)
                    yes(*) {
                        g_1.Destroy()
                        gc.addLV.Delete(RowNumber)
                        gc.rmLV.Add(, RowText)
                        value := readIni(tipList.config, "")
                        if (value) {
                            res := value ":"
                        } else {
                            res := ""
                        }
                        handleFn({
                            RowText: RowText,
                            config: tipList.config,
                            newValue: res RowText
                        })
                    }
                    return g_1
                }
            }
            value := readIni(tipList.config, "")
            value := SubStr(value, -1) = ":" ? value : value ":"
            temp := ""
            DetectHiddenWindows deep
            for v in WinGetList() {
                try {
                    exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                    title := WinGetTitle("ahk_id " v)
                    if (!InStr(temp, exe_name ":") && !InStr(value, exe_name ":")) {
                        temp .= exe_name ":"
                        gc.addLV.Add(, exe_name, WinGetTitle("ahk_id " v))
                    }
                }
            }
            DetectHiddenWindows 1
            g.AddButton("xs w" bw / 2, "手动添加进程").OnEvent("Click", fn_add_by_hand)
            fn_add_by_hand(*) {
                addApp("xxx.exe")
                addApp(v) {
                    createGui(fn).Show()
                    fn(x, y, w, h) {
                        g_2 := Gui("AlwaysOnTop", A_ScriptName " - 手动添加进程")
                        g_2.SetFont(fz, "微软雅黑")
                        bw := w - g_2.MarginX * 2
                        g_2.AddText(, "1. 进程名称应该是")
                        g_2.AddText("yp cRed", "xxx.exe")
                        g_2.AddText("yp", "这样的格式")
                        g_2.AddText("xs", "2. 每一次只能添加一个")
                        g_2.AddText("xs", "进程名称: ")
                        g_2.AddEdit("yp vexe_name", "").Value := v
                        g_2.AddButton("xs w" bw, "确认添加").OnEvent("Click", yes)
                        yes(*) {
                            exe_name := g_2.Submit().exe_name
                            if (!RegExMatch(exe_name, "^.+\.\w{3}$")) {
                                createGui(fn).Show()
                                fn(x, y, w, h) {
                                    g_2 := Gui("AlwaysOnTop")
                                    g_2.SetFont(fz, "微软雅黑")
                                    bw := w - g_2.MarginX * 2
                                    g_2.AddText(, "进程名称不符合格式要求，请重新输入")
                                    g_2.AddButton("w" bw, "我知道了").OnEvent("click", close)
                                    close(*) {
                                        g_2.Destroy()
                                        addApp(exe_name)
                                    }
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
                                    g_2 := Gui("AlwaysOnTop")
                                    g_2.SetFont(fz, "微软雅黑")
                                    bw := w - g_2.MarginX * 2
                                    g_2.AddText(, exe_name " 已经存在了，请重新输入")
                                    g_2.AddButton("w" bw, "重新输入").OnEvent("click", close)
                                    close(*) {
                                        g_2.Destroy()
                                        addApp(exe_name)
                                    }
                                    return g_2
                                }
                            } else {
                                gc.rmLV.Add(, exe_name)
                                handleFn({
                                    RowText: exe_name,
                                    config: tipList.config,
                                    newValue: res exe_name
                                })
                            }
                        }
                        return g_2
                    }
                }
            }
            if (deep) {
                g.AddButton("yp w" bw / 2, "显示更少进程(仅包含已经打开的窗口)").OnEvent("Click", fn_less_window)
                fn_less_window(*) {
                    g.Destroy()
                    show("")
                }
            } else {
                g.AddButton("yp w" bw / 2, "显示更多进程(包含后台和隐藏窗口)").OnEvent("Click", fn_more_window)
                fn_more_window(*) {
                    g.Destroy()
                    show(1)
                }
            }
            gc.addLV.ModifyCol(1, "AutoHdr")
            tab.UseTab(2)
            value := readIni(tipList.config, "")
            valueArr := StrSplit(value, ":")
            g.AddLink("Section", tipList.tip)
            g.AddLink("yp cRed", tipList.tip2)
            g.AddLink("yp", tipList.tip3)
            g.AddLink("xs", tipList.rmTopText)
            g.AddLink(, tipList.rmList)
            gc.rmLV := g.AddListView("-Multi r9 NoSortHdr Sort Grid w" bw, ["应用进程"])
            gc.rmLV.OnEvent("DoubleClick", fn_double_click1)
            fn_double_click1(LV, RowNumber) {
                RowText := Trim(LV.GetText(RowNumber))  ; 从行的第一个字段中获取文本.
                createGui(fn).Show()
                fn(x, y, w, h) {
                    g_3 := Gui("AlwaysOnTop")
                    g_3.SetFont(fz, "微软雅黑")
                    bw := w - g_3.MarginX * 2

                    g_3.AddLink(, tipList.rmConfirm)
                    g_3.AddLink("yp cRed", RowText)
                    g_3.AddLink("yp", tipList.rmConfirm2)
                    g_3.AddLink("xs", tipList.rmConfirm3)
                    g_3.AddButton("xs w" bw, "确认移除").OnEvent("Click", yes)
                    yes(*) {
                        g_3.Destroy()
                        value := readIni(tipList.config, "")
                        result := ""
                        for v in StrSplit(value, ":") {
                            if (Trim(v) && v != RowText) {
                                result .= ":" v
                            }
                        }
                        gc.rmLV.Delete(RowNumber)
                        try {
                            gc.addLV.Add(, RowText, WinGetTitle("ahk_exe " RowText))
                        } catch {
                            gc.addLV.Add(, RowText)
                        }
                        handleFn({
                            RowText: RowText,
                            config: tipList.config,
                            newValue: SubStr(result, 2)
                        })
                    }
                    return g_3
                }
            }
            temp := ":"
            for v in valueArr {
                if (Trim(v) && !InStr(temp, ":" v ":")) {
                    gc.rmLV.Add(, v)
                    temp .= v ":"
                }
            }
            gc.rmLV.ModifyCol(1, "AutoHdr")

            tab.UseTab(3)
            g.AddLink(, tipList.about)
            return g
        }
    }
}

fn_white_list(*) {
    fn_common({
        config: "app_show_state",
        tip: "1. 点击上方的 「关于」查看",
        tip2: "「符号显示白名单」",
        tip3: "的相关说明。",
        about: "什么是「符号显示白名单」？`n`n1. 白名单机制: 只有在白名单中的应用进程窗口才会显示符号。`n2. 建议使用白名单机制，这样可以精确控制哪些应用进程窗口需要显示符号。`n3. 使用白名单机制，只需要添加常用的窗口，可以减少一些特殊窗口的兼容性问题。`n4. 如果选择了白名单机制，请及时添加你需要使用的应用进程到白名单中。`n5. 如果使用 「启用 JetBrains IDE 支持」，还需要将 IDE 进程添加到白名单中。",
        addTopText: "2. 双击应用进程，即可将其添加到「符号显示白名单」中",
        addList: "以下列表是当前正在运行的应用进程",
        addList1: "以下列表是当前正在运行的应用进程",
        addConfirm: "是否要将",
        addConfirm2: "添加到「符号显示白名单」中？",
        addConfirm3: "添加后，白名单机制下，在此应用窗口中时，会显示符号(图片/方块/文本符号)",
        rmTopText: "2. 双击应用进程，将其从「符号显示白名单」中移除`n3. 移除后，白名单机制下，在此应用窗口中时，不会显示符号(图片/方块/文本符号)",
        rmList: "以下列表是「符号显示白名单」",
        rmConfirm: "是否要将",
        rmConfirm2: "从「符号显示白名单」中移除？",
        rmConfirm3: "移除后，白名单机制下，在此应用窗口中时，不会显示符号(图片/方块/文本符号)",
    },
    fn
    )
    fn(info) {
        writeIni("app_show_state", info.newValue)
        global app_show_state := ":" info.newValue ":"
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
                loopDir A_LoopFileShortPath
                if (!hasChildDir(A_LoopFileShortPath)) {
                    if (!InStr(dirList, ":" A_LoopFileShortPath ":") && !InStr(defaultList, ":" A_LoopFileShortPath ":")) {
                        dirList .= A_LoopFileShortPath ":"
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
        if (A_LoopFileExt = "png" && A_LoopFileShortPath != "InputTipSymbol\default\offer.png") {
            if (!InStr(picList, ":" A_LoopFileShortPath ":") && !InStr(defaultList, ":" A_LoopFileShortPath ":")) {
                picList .= A_LoopFileShortPath ":"
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
    SetTimer(timer, -100)
    timer() {
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
