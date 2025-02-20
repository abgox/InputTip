fn_switch_window(*) {
    showGui()
    showGui(deep := "") {
        if (gc.w.windowToggleGui) {
            gc.w.windowToggleGui.Destroy()
            gc.w.windowToggleGui := ""
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        createGui(switchWindowGui).Show()
        switchWindowGui(info) {
            g := createGuiOpt()
            tab := g.AddTab3("-Wrap", ["设置状态自动切换", "关于"])
            tab.UseTab(1)
            g.AddText("Section cRed", "你首先应该点击上方的「关于」查看具体的操作说明                                              ")

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            gc.LV_add := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" bw, ["应用进程列表", "窗口标题", "应用进程文件所在位置"])
            fn_dbClick(LV, RowNumber) {
                handleClick(LV, RowNumber, LV._type)
            }
            gc.LV_add.OnEvent("DoubleClick", fn_dbClick)
            gc.LV_add._type := "add"

            res := []
            for v in ["app_CN", "app_EN", "app_Caps"] {
                res.Push(readIni(v, ""))
            }
            res := ":" arrJoin(res, ":") ":"
            temp := ":"
            DetectHiddenWindows deep
            gc.LV_add.Opt("-Redraw")
            for v in WinGetList() {
                try {
                    exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                    if (!InStr(temp, ":" exe_name ":") && !InStr(res, ":" exe_name ":")) {
                        temp .= exe_name ":"
                        gc.LV_add.Add(, exe_name, WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                    }
                }
            }
            for v in StrSplit(readIni("app_show_state", ''), ":") {
                if (!InStr(temp, ":" v ":") && !InStr(res, ":" v ":")) {
                    temp .= v ":"
                    try {
                        gc.LV_add.Add(, v, WinGetTitle("ahk_exe " v), WinGetProcessPath("ahk_exe " v))
                    } catch {
                        gc.LV_add.Add(, v)
                    }
                }
            }
            gc.LV_add.Opt("+Redraw")
            DetectHiddenWindows 1

            addItem(state) {
                gc.%"LV_" state%.Opt("-Redraw")
                valueArr := StrSplit(readIni("app_" state, ""), ":")
                temp := ":"
                for v in valueArr {
                    if (Trim(v) && !InStr(temp, ":" v ":")) {
                        gc.%"LV_" state%.Add(, v)
                        temp .= v ":"
                    }
                }
                gc.%"LV_" state%.Opt("+Redraw")
                gc.%state "_title"%.Value .= " ( " gc.%"LV_" state%.GetCount() " 个 )"
            }

            gc.CN_title := g.AddText("xs w" bw / 3, "中文状态")
            gc.EN_title := g.AddText("yp w" bw / 3, "英文状态")
            gc.Caps_title := g.AddText("yp w" bw / 3, "大写锁定")

            if (symbolType = 3) {
                c := symbolConfig.textSymbol_CN_color ? "c" StrReplace(symbolConfig.textSymbol_CN_color, "#") : ""
            } else {
                c := symbolConfig.CN_color ? "c" StrReplace(symbolConfig.CN_color, "#") : ""
            }
            try {
                gc.LV_CN := g.AddListView("xs -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3 " " c, ["中文状态"])
            } catch {
                gc.LV_CN := g.AddListView("xs -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3, ["中文状态"])
            }
            addItem("CN")
            gc.LV_CN.ModifyCol(1, "AutoHdr")
            gc.LV_CN.OnEvent("DoubleClick", fn_dbClick)
            gc.LV_CN._type := "CN"

            if (symbolType = 3) {
                c := symbolConfig.textSymbol_EN_color ? "c" StrReplace(symbolConfig.textSymbol_EN_color, "#") : ""
            } else {
                c := symbolConfig.EN_color ? "c" StrReplace(symbolConfig.EN_color, "#") : ""
            }
            try {
                gc.LV_EN := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3 " " c, ["英文状态"])
            } catch {
                gc.LV_EN := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3, ["英文状态"])
            }
            addItem("EN")
            gc.LV_EN.ModifyCol(1, "AutoHdr")
            gc.LV_EN.OnEvent("DoubleClick", fn_dbClick)
            gc.LV_EN._type := "EN"

            if (symbolType = 3) {
                c := symbolConfig.textSymbol_Caps_color ? "c" StrReplace(symbolConfig.textSymbol_Caps_color, "#") : ""
            } else {
                c := symbolConfig.Caps_color ? "c" StrReplace(symbolConfig.Caps_color, "#") : ""
            }
            try {
                gc.LV_Caps := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3 " " c, ["大写锁定"])
            } catch {
                gc.LV_Caps := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3, ["大写锁定"])
            }
            addItem("Caps")
            gc.LV_Caps.ModifyCol(1, "AutoHdr")
            gc.LV_Caps.OnEvent("DoubleClick", fn_dbClick)
            gc.LV_Caps._type := "Caps"

            handleClick(LV, RowNumber, from) {
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
                    _handle(to) {
                        g.Destroy()
                        gc.%"LV_" from%.Delete(RowNumber)
                        if (from != "add") {
                            gc.%from "_title"%.Value := SubStr(gc.%from "_title"%.Value, 1, 4) " ( " gc.%"LV_" from%.GetCount() " 个 )"
                            config := "app_" from
                            value := readIni(config, "")
                            res := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != exe_name) {
                                    res .= ":" v
                                }
                            }
                            writeIni(config, SubStr(res, 2))
                        }
                        config := "app_" to
                        value := readIni(config, "")

                        if (!InStr(":" value ":", ":" exe_name ":")) {
                            gc.%"LV_" to%.Add(, exe_name)
                            gc.%to "_title"%.Value := SubStr(gc.%to "_title"%.Value, 1, 4) " ( " gc.%"LV_" to%.GetCount() " 个 )"
                            if (value) {
                                writeIni(config, value ":" exe_name)
                            } else {
                                writeIni(config, exe_name)
                            }
                        }
                        updateWhiteList(exe_name)

                        global app_CN := ":" readIni('app_CN', '') ":"
                        global app_EN := ":" readIni('app_EN', '') ":"
                        global app_Caps := ":" readIni('app_Caps', '') ":"
                    }
                    g := createGuiOpt()
                    g.AddText(, "要将进程")
                    g.AddText("yp cRed", exe_name)
                    g.AddText("yp", "添加到哪一个自动切换列表中？")
                    if (useWhiteList) {
                        g.AddText("xs cRed", "如果此应用不在白名单中，则会同步添加到白名单中")
                    }

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    fn_CN(*) {
                        _handle("CN")
                    }
                    fn_EN(*) {
                        _handle("EN")
                    }
                    fn_Caps(*) {
                        _handle("Caps")
                    }

                    switch from {
                        case "add":
                            g.AddButton("xs w" bw, "「中文状态」").OnEvent("Click", fn_CN)
                            g.AddButton("xs w" bw, "「英文状态」").OnEvent("Click", fn_EN)
                            g.AddButton("xs w" bw, "「大写锁定」").OnEvent("Click", fn_Caps)
                        case "CN":
                            g.AddButton("xs Disabled w" bw, "「中文状态」").OnEvent("Click", fn_CN)
                            g.AddButton("xs w" bw, "「英文状态」").OnEvent("Click", fn_EN)
                            g.AddButton("xs w" bw, "「大写锁定」").OnEvent("Click", fn_Caps)
                            g.AddButton("xs w" bw, "将它移除").OnEvent("Click", fn_rm)
                        case "EN":
                            g.AddButton("xs w" bw, "「中文状态」").OnEvent("Click", fn_CN)
                            g.AddButton("xs Disabled w" bw, "「英文状态」").OnEvent("Click", fn_EN)
                            g.AddButton("xs w" bw, "「大写锁定」").OnEvent("Click", fn_Caps)
                            g.AddButton("xs w" bw, "将它移除").OnEvent("Click", fn_rm)
                        case "Caps":
                            g.AddButton("xs w" bw, "「中文状态」").OnEvent("Click", fn_CN)
                            g.AddButton("xs w" bw, "「英文状态」").OnEvent("Click", fn_EN)
                            g.AddButton("xs Disabled w" bw, "「大写锁定」").OnEvent("Click", fn_Caps)
                            g.AddButton("xs w" bw, "将它移除").OnEvent("Click", fn_rm)
                    }
                    fn_rm(*) {
                        g.Destroy()
                        LV.Delete(RowNumber)
                        gc.%from "_title"%.Value := SubStr(gc.%from "_title"%.Value, 1, 4) " ( " gc.%"LV_" from%.GetCount() " 个 )"
                        try {
                            gc.LV_add.Add(, exe_name, WinGetTitle("ahk_exe " exe_name))
                        }
                        config := "app_" from
                        value := readIni(config, "")
                        result := ""
                        for v in StrSplit(value, ":") {
                            if (Trim(v) && v != exe_name) {
                                result .= ":" v
                            }
                        }
                        writeIni(config, SubStr(result, 2))

                        global app_CN := ":" readIni('app_CN', '') ":"
                        global app_EN := ":" readIni('app_EN', '') ":"
                        global app_Caps := ":" readIni('app_Caps', '') ":"
                    }
                    g.AddButton("xs w" bw, "取消操作").OnEvent("Click", no)
                    no(*) {
                        g.Destroy()
                    }
                    gc.w.subGui := g
                    return g
                }
            }

            g.AddButton("xs w" bw / 3, "刷新此界面").OnEvent("Click", e_refresh)
            e_refresh(*) {
                fn_close()
                showGui(deep)
            }

            g.AddButton("yp w" bw / 3, "通过输入进程名称手动添加").OnEvent("Click", e_add_by_hand)
            e_add_by_hand(*) {
                addApp("xxx.exe")
                addApp(v) {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    createGui(addGui).Show()
                    addGui(info) {
                        g := createGuiOpt("InputTip - 设置状态自动切换")
                        text := "每次只能添加一个应用进程名称"
                        if (useWhiteList) {
                            text .= "`n如果它不在白名单中，则会同步添加到白名单中"
                        }
                        g.AddText("cRed", text)
                        g.AddText("Section", "应用进程名称: ")
                        gc._exe_name := g.AddEdit("yp")
                        gc._exe_name.Value := v
                        g.AddText("xs cGray", "你想要将它添加到哪个自动切换列表中？")
                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        g.AddButton("xs w" bw, "「中文状态」").OnEvent("Click", fn_CN)
                        g.AddButton("xs w" bw, "「英文状态」").OnEvent("Click", fn_EN)
                        g.AddButton("xs w" bw, "「大写锁定」").OnEvent("Click", fn_Caps)
                        fn_CN(*) {
                            _handle("CN")
                        }
                        fn_EN(*) {
                            _handle("EN")
                        }
                        fn_Caps(*) {
                            _handle("Caps")
                        }

                        _handle(to) {
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

                            config := "app_" to
                            value := readIni(config, "")

                            if (InStr(":" value ":", ":" exe_name ":")) {
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
                                return
                            }

                            gc.%"LV_" to%.Add(, exe_name)
                            if (value) {
                                writeIni(config, value ":" exe_name)
                            } else {
                                writeIni(config, exe_name)
                            }
                            updateWhiteList(exe_name)
                            global app_CN := ":" readIni('app_CN', '') ":"
                            global app_EN := ":" readIni('app_EN', '') ":"
                            global app_Caps := ":" readIni('app_Caps', '') ":"
                        }
                        gc.w.subGui := g
                        return g
                    }
                }
            }
            if (deep) {
                g.AddButton("yp w" bw / 3, "显示更少进程(仅前台窗口)").OnEvent("Click", e_less_window)
                e_less_window(*) {
                    fn_close()
                    showGui("")
                }
            } else {
                g.AddButton("yp w" bw / 3, "显示更多进程(后台窗口)").OnEvent("Click", e_more_window)
                e_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }
            gc.LV_add.ModifyCol(1, "AutoHdr")
            gc.LV_add.ModifyCol(2, "AutoHdr")
            gc.LV_add.ModifyCol(3, "AutoHdr")
            tab.UseTab(2)
            g.AddEdit("ReadOnly -VScroll w" w, "1. 如何使用这个配置菜单？`n`n   - 上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 为了便于操作，白名单中的应用进程也会添加到列表中`n   - 双击列表中任意应用进程，就可以将其添加到下方任意列表中`n   - 如果需要更多的进程，请点击下方的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击下方的「通过输入进程名称手动添加」直接添加进程名称`n`n   - 下方分别是中文、英文、大写锁定这三个自动切换列表`n   - 在自动切换列表中的应用窗口被激活时，会自动切换到对应的输入法状态`n      - 如果对自动切换的逻辑不理解，请查看下方的相关链接`n   - 双击列表中任意应用进程，就可以将它移除或者添加到其他列表中`n   - 白名单机制下，选择添加且此应用不在白名单中，则会同步添加到白名单中`n`n2. 需要特别注意:`n   - 自动切换生效的前提是当前选择的输入法可以切换状态`n   - 以【美式键盘 ENG】为例`n   - 它只有英文状态和大写锁定，所以只有英文状态的和大写锁定的自动切换有效")
            g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/switch-state">关于指定窗口自动切换状态</a>')

            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
            }
            gc.w.windowToggleGui := g
            return g
        }
    }
}
