fn_switch_window(*) {
    showGui()
    showGui(deep := "") {
        createGui(fn).Show()
        fn(x, y, w, h) {
            if (gc.w.windowToggleGui) {
                gc.w.windowToggleGui.Destroy()
                gc.w.windowToggleGui := ""

                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
            }
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            tab := g.AddTab3("-Wrap", ["设置状态自动切换", "关于"])
            tab.UseTab(1)
            g.AddLink("Section cRed", "你首先应该点击上方的「关于」查看具体的操作说明                                              ")
            gc.LV_add := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" bw, ["应用进程列表", "窗口标题", "应用进程文件所在位置"])
            gc.LV_add.OnEvent("DoubleClick", fn_add)
            fn_add(LV, RowNumber) {
                handleClick(LV, RowNumber, "add")
            }
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

            if (CN_color) {
                c := "c" StrReplace(CN_color, "#")
            } else {
                c := ""
            }
            try {
                gc.LV_CN := g.AddListView("xs -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3 " " c, ["自动切换中文"])
            } catch {
                gc.LV_CN := g.AddListView("xs -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3, ["自动切换中文"])
            }
            addItem("CN")
            gc.LV_CN.ModifyCol(1, "AutoHdr")
            gc.LV_CN.OnEvent("DoubleClick", fn_CN)
            fn_CN(LV, RowNumber) {
                handleClick(LV, RowNumber, "CN")
            }
            if (EN_color) {
                c := "c" StrReplace(EN_color, "#")
            } else {
                c := ""
            }
            try {
                gc.LV_EN := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3 " " c, ["自动切换英文"])
            } catch {
                gc.LV_EN := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3, ["自动切换英文"])
            }
            addItem("EN")
            gc.LV_EN.ModifyCol(1, "AutoHdr")
            gc.LV_EN.OnEvent("DoubleClick", fn_EN)
            fn_EN(LV, RowNumber) {
                handleClick(LV, RowNumber, "EN")
            }
            if (Caps_color) {
                c := "c" StrReplace(Caps_color, "#")
            } else {
                c := ""
            }
            try {
                gc.LV_Caps := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3 " " c, ["自动切换大写锁定"])
            } catch {
                gc.LV_Caps := g.AddListView("yp -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 3, ["自动切换大写锁定"])
            }
            addItem("Caps")
            gc.LV_Caps.ModifyCol(1, "AutoHdr")
            gc.LV_Caps.OnEvent("DoubleClick", fn_Caps)
            fn_Caps(LV, RowNumber) {
                handleClick(LV, RowNumber, "Caps")
            }

            handleClick(LV, RowNumber, from) {
                if (!RowNumber) {
                    return
                }
                RowText := LV.GetText(RowNumber)  ; 从行的第一个字段中获取文本.
                createGui(fn).Show()
                fn(x, y, w, h) {
                    _handle(to) {
                        g_1.Destroy()
                        gc.%"LV_" from%.Delete(RowNumber)
                        if (from != "add") {
                            gc.%from "_title"%.Value := SubStr(gc.%from "_title"%.Value, 1, 4) " ( " gc.%"LV_" from%.GetCount() " 个 )"
                            config := "app_" from
                            value := readIni(config, "")
                            res := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != RowText) {
                                    res .= ":" v
                                }
                            }
                            writeIni(config, SubStr(res, 2))
                        }
                        config := "app_" to
                        value := readIni(config, "")

                        if (!InStr(":" value ":", ":" RowText ":")) {
                            gc.%"LV_" to%.Add(, RowText)
                            gc.%to "_title"%.Value := SubStr(gc.%to "_title"%.Value, 1, 4) " ( " gc.%"LV_" to%.GetCount() " 个 )"
                            if (value) {
                                writeIni(config, value ":" RowText)
                            } else {
                                writeIni(config, RowText)
                            }
                        }
                        updateWhiteList(RowText)

                        global app_CN := ":" readIni('app_CN', '') ":"
                        global app_EN := ":" readIni('app_EN', '') ":"
                        global app_Caps := ":" readIni('app_Caps', '') ":"
                    }
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }

                    g_1 := Gui("AlwaysOnTop")
                    g_1.SetFont(fz, "微软雅黑")
                    bw := w - g_1.MarginX * 2

                    g_1.AddLink(, "要将进程")
                    g_1.AddLink("yp cRed", RowText)
                    g_1.AddLink("yp", "添加到哪一个自动切换列表中？")
                    if (useWhiteList) {
                        g_1.AddLink("xs cRed", "如果此应用不在白名单中，则会同步添加到白名单中")
                    }
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
                        {
                            g_1.AddButton("xs w" bw, "「自动切换中文」").OnEvent("Click", fn_CN)
                            g_1.AddButton("xs w" bw, "「自动切换英文」").OnEvent("Click", fn_EN)
                            g_1.AddButton("xs w" bw, "「自动切换大写锁定」").OnEvent("Click", fn_Caps)
                        }
                        case "CN":
                        {
                            g_1.AddButton("xs Disabled w" bw, "「自动切换中文」").OnEvent("Click", fn_CN)
                            g_1.AddButton("xs w" bw, "「自动切换英文」").OnEvent("Click", fn_EN)
                            g_1.AddButton("xs w" bw, "「自动切换大写锁定」").OnEvent("Click", fn_Caps)
                            g_1.AddButton("xs w" bw, "将它移除").OnEvent("Click", fn_rm)
                        }
                        case "EN":
                        {
                            g_1.AddButton("xs w" bw, "「自动切换中文」").OnEvent("Click", fn_CN)
                            g_1.AddButton("xs Disabled w" bw, "「自动切换英文」").OnEvent("Click", fn_EN)
                            g_1.AddButton("xs w" bw, "「自动切换大写锁定」").OnEvent("Click", fn_Caps)
                            g_1.AddButton("xs w" bw, "将它移除").OnEvent("Click", fn_rm)
                        }
                        case "Caps":
                        {
                            g_1.AddButton("xs w" bw, "「自动切换中文」").OnEvent("Click", fn_CN)
                            g_1.AddButton("xs w" bw, "「自动切换英文」").OnEvent("Click", fn_EN)
                            g_1.AddButton("xs Disabled w" bw, "「自动切换大写锁定」").OnEvent("Click", fn_Caps)
                            g_1.AddButton("xs w" bw, "将它移除").OnEvent("Click", fn_rm)
                        }
                    }
                    fn_rm(*) {
                        g_1.Destroy()
                        LV.Delete(RowNumber)
                        gc.%from "_title"%.Value := SubStr(gc.%from "_title"%.Value, 1, 4) " ( " gc.%"LV_" from%.GetCount() " 个 )"
                        try {
                            gc.LV_add.Add(, RowText, WinGetTitle("ahk_exe " RowText))
                        }
                        config := "app_" from
                        value := readIni(config, "")
                        result := ""
                        for v in StrSplit(value, ":") {
                            if (Trim(v) && v != RowText) {
                                result .= ":" v
                            }
                        }
                        writeIni(config, SubStr(result, 2))

                        global app_CN := ":" readIni('app_CN', '') ":"
                        global app_EN := ":" readIni('app_EN', '') ":"
                        global app_Caps := ":" readIni('app_Caps', '') ":"
                    }
                    g_1.AddButton("xs w" bw, "取消操作").OnEvent("Click", no)
                    no(*) {
                        g_1.Destroy()
                    }
                    gc.w.subGui := g_1
                    return g_1
                }
            }

            g.AddButton("xs w" bw / 3, "刷新应用进程列表").OnEvent("Click", fn_refresh)
            fn_refresh(*) {
                fn_close()
                showGui(deep)
            }

            g.AddButton("yp w" bw / 3, "通过输入进程名称手动添加").OnEvent("Click", fn_add_by_hand)
            fn_add_by_hand(*) {
                addApp("xxx.exe")
                addApp(v) {
                    createGui(fn).Show()
                    fn(x, y, w, h) {
                        if (gc.w.subGui) {
                            gc.w.subGui.Destroy()
                            gc.w.subGui := ""
                        }
                        g_2 := Gui("AlwaysOnTop", "InputTip - 通过输入进程名称手动添加")
                        g_2.SetFont(fz, "微软雅黑")
                        bw := w - g_2.MarginX * 2

                        if (useWhiteList) {
                            g_2.AddText("cRed", "如果此应用不在白名单中，则会同步添加到白名单中")
                        }
                        g_2.AddText(, "1. 进程名称应该是")
                        g_2.AddText("yp cRed", "xxx.exe")
                        g_2.AddText("yp", "这样的格式")
                        g_2.AddText("xs", "2. 每一次只能添加一个")
                        g_2.AddText("xs", "应用进程名称: ")
                        g_2.AddEdit("yp vexe_name", "").Value := v

                        g_2.AddButton("xs w" bw, "添加到「自动切换中文」").OnEvent("Click", fn_CN)
                        g_2.AddButton("xs w" bw, "添加到「自动切换英文」").OnEvent("Click", fn_EN)
                        g_2.AddButton("xs w" bw, "添加到「自动切换大写锁定」").OnEvent("Click", fn_Caps)
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
                            exe_name := g_2.Submit().exe_name
                            if (!RegExMatch(exe_name, "^.+\.\w{3}$") || InStr(exe_name, ":")) {
                                createGui(fn).Show()
                                fn(x, y, w, h) {
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
                                    return g_2
                                }
                                return
                            }

                            config := "app_" to
                            value := readIni(config, "")

                            if (InStr(":" value ":", ":" exe_name ":")) {
                                createGui(fn1).Show()
                                fn1(x, y, w, h) {
                                    g_2 := Gui("AlwaysOnTop")
                                    g_2.SetFont(fz, "微软雅黑")
                                    bw := w - g_2.MarginX * 2
                                    g_2.AddText("cRed", exe_name)
                                    g_2.AddText("yp", "已经存在，请重新输入")
                                    g_2.AddButton("xs w" bw, "重新输入").OnEvent("click", close)
                                    close(*) {
                                        g_2.Destroy()
                                        addApp(exe_name)
                                    }
                                    return g_2
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
                        gc.w.subGui := g_2
                        return g_2
                    }
                }
            }
            if (deep) {
                g.AddButton("yp w" bw / 3, "显示更少进程(仅前台窗口)").OnEvent("Click", fn_less_window)
                fn_less_window(*) {
                    fn_close()
                    showGui("")
                }
            } else {
                g.AddButton("yp w" bw / 3, "显示更多进程(后台窗口)").OnEvent("Click", fn_more_window)
                fn_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }
            gc.LV_add.ModifyCol(1, "AutoHdr")
            gc.LV_add.ModifyCol(2, "AutoHdr")
            gc.LV_add.ModifyCol(3, "AutoHdr")
            tab.UseTab(2)
            g.AddEdit("ReadOnly -VScroll w" w, "如何使用这个管理面板？`n`n- 最上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n- 为了便于操作，白名单中的应用进程也会添加到列表中`n- 双击列表中任意应用进程，就可以将其添加到下方任意列表中`n- 如果需要更多的进程，请点击下方的「显示更多进程」以显示后台和隐藏进程`n- 也可以点击下方的「通过输入进程名称手动添加」直接添加进程名称`n- 下方分别是中文、英文、大写锁定这三个自动切换列表`n- 在自动切换列表中的应用窗口被激活时，会自动切换到对应的输入法状态`n- 双击列表中任意应用进程，就可以将它移除或者添加到其他列表中`n- 白名单机制下，选择添加且此应用不在白名单中，则会同步添加到白名单中`n`n- 举个例子: `n  - 你可以双击上方正在运行的应用进程列表中的其中一个应用进程`n  - 然后在弹出的操作窗口中，选择将其添加到哪一个列表中`n  - 添加完成后，会在下方对应列表中显示，并实时生效`n  - 你也可以双击下方列表中的其中一个应用进程进行同样的操作")

            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
            }
            gc.w.windowToggleGui := g
            return g
        }
    }
}
