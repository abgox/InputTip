fn_cursor_mode(*) {
    showGui()
    showGui(deep := "") {
        createGui(fn).Show()
        fn(x, y, w, h) {
            if (gc.w.cursorModeGui) {
                gc.w.cursorModeGui.Destroy()
                gc.w.cursorModeGui := ""

                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
            }
            g := Gui("AlwaysOnTop")
            g.SetFont(fz, "微软雅黑")
            bw := w - g.MarginX * 2

            tab := g.AddTab3("-Wrap", ["设置光标获取模式", "关于"])
            tab.UseTab(1)
            g.AddLink("Section cRed", "你首先应该点击上方的「关于」查看具体的操作说明")
            gc.LV_add := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["应用进程列表", "窗口标题", "应用进程文件所在位置"])
            gc.LV_add.OnEvent("DoubleClick", fn_add)
            fn_add(LV, RowNumber) {
                handleClick(LV, RowNumber, "add")
            }
            res := []
            for v in modeNameList {
                res.Push(readIni("cursor_mode_" v, ""))
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
                valueArr := StrSplit(readIni("cursor_mode_" state, ""), ":")
                temp := ":"
                for v in valueArr {
                    if (Trim(v) && !InStr(temp, ":" v ":")) {
                        gc.%"LV_" state%.Add(, v)
                        temp .= v ":"
                    }
                }
                gc.%"LV_" state%.Opt("+Redraw")
            }

            for i, v in modeNameList {
                opt := i = 1 || i = 5 ? "xs" : "yp"
                gc.%"LV_" v% := g.AddListView(opt " cRed -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 4, [v])
                addItem(v)
                gc.%"LV_" v%.ModifyCol(1, "AutoHdr")
                gc.%"LV_" v%.OnEvent("DoubleClick", fn_mode)
                gc.%"LV_" v%._mode := v
                fn_mode(LV, RowNumber) {
                    handleClick(LV, RowNumber, LV._mode)
                }
            }

            handleClick(LV, RowNumber, from) {
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
                    _handle(to) {
                        g_1.Destroy()
                        gc.%"LV_" from%.Delete(RowNumber)
                        if (from != "add") {
                            config := "cursor_mode_" from
                            value := readIni(config, "")
                            res := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != RowText) {
                                    res .= ":" v
                                }
                            }
                            writeIni(config, SubStr(res, 2))
                        }
                        config := "cursor_mode_" to
                        value := readIni(config, "")

                        if (!InStr(":" value ":", ":" RowText ":")) {
                            gc.%"LV_" to%.Add(, RowText)
                            if (value) {
                                writeIni(config, value ":" RowText)
                            } else {
                                writeIni(config, RowText)
                            }
                        }
                        updateWhiteList(RowText)
                        updateCursorMode(config != "cursor_mode_JAB")
                    }
                    g_1 := Gui("AlwaysOnTop")
                    g_1.SetFont(fz, "微软雅黑")
                    bw := w - g_1.MarginX * 2

                    g_1.AddLink(, "要将进程")
                    g_1.AddLink("yp cRed", RowText)
                    g_1.AddLink("yp", "添加到哪一个光标获取模式中？")
                    if (useWhiteList) {
                        g_1.AddLink("xs cRed", "如果此应用不在白名单中，则会同步添加到白名单中")
                    }

                    mode_list := modeNameList.Clone()
                    if (from != "add") {
                        mode_list.RemoveAt(modeListMap.%from%)
                    }
                    for i, v in mode_list {
                        opt := i = 1 || i = 5 ? "xs" : "yp"
                        _g := g_1.AddButton(opt " w" bw / 4, v)
                        _g._mode := v
                        _g.OnEvent("Click", fn_mode)
                        fn_mode(item, *) {
                            _handle(item._mode)
                        }
                    }
                    if (from != "add") {
                        g_1.AddButton("xs w" w, "将它移除").OnEvent("Click", fn_rm)
                        fn_rm(*) {
                            g_1.Destroy()
                            LV.Delete(RowNumber)
                            try {
                                gc.LV_add.Add(, RowText, WinGetTitle("ahk_exe " RowText))
                            }
                            config := "cursor_mode_" from
                            value := readIni(config, "")
                            result := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != RowText) {
                                    result .= ":" v
                                }
                            }
                            writeIni(config, SubStr(result, 2))
                            updateCursorMode(config != "cursor_mode_JAB")
                        }
                    }

                    g_1.AddButton("xs w" w, "取消操作").OnEvent("Click", no)
                    no(*) {
                        g_1.Destroy()
                    }
                    gc.w.subGui := g_1
                    return g_1
                }
            }

            g.AddButton("xs w" w / 3, "刷新应用进程列表").OnEvent("Click", fn_refresh)
            fn_refresh(*) {
                fn_close()
                showGui(deep)
            }

            g.AddButton("yp w" w / 3, "通过输入进程名称手动添加").OnEvent("Click", fn_add_by_hand)
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
                            g_2.AddLink("cRed", "如果此应用不在白名单中，则会同步添加到白名单中")
                        }
                        g_2.AddText(, "1. 进程名称应该是")
                        g_2.AddText("yp cRed", "xxx.exe")
                        g_2.AddText("yp", "这样的格式")
                        g_2.AddText("xs", "2. 每一次只能添加一个")
                        g_2.AddText("xs", "进程名称: ")
                        g_2.AddEdit("yp vexe_name", "").Value := v
                        g_2.AddText("xs cGray", "要这个应用进程添加到下方哪一个光标获取模式中？")

                        for i, v in modeNameList {
                            opt := i = 1 || i = 5 ? "xs" : "yp"
                            _g := g_2.AddButton(opt " w" bw / 4, v)
                            _g._mode := v
                            _g.OnEvent("Click", fn_handle)
                            fn_handle(item, *) {
                                _handle(item._mode)
                            }
                        }

                        _handle(to) {
                            exe_name := g_2.Submit().exe_name
                            if (!RegExMatch(exe_name, "^.+\.\w{3}$")) {
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

                            config := "cursor_mode_" to
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
                            updateCursorMode(config != "cursor_mode_JAB")
                        }
                        gc.w.subGui := g_2
                        return g_2
                    }
                }
            }
            if (deep) {
                g.AddButton("yp w" w / 3, "显示更少进程(仅前台窗口)").OnEvent("Click", fn_less_window)
                fn_less_window(*) {
                    fn_close()
                    showGui("")
                }
            } else {
                g.AddButton("yp w" w / 3, "显示更多进程(后台窗口)").OnEvent("Click", fn_more_window)
                fn_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }

            gc.LV_add.ModifyCol(1, "AutoHdr")
            gc.LV_add.ModifyCol(2, "AutoHdr")
            gc.LV_add.ModifyCol(3, "AutoHdr")
            tab.UseTab(2)
            g.AddLink(, '1. 如何使用这个管理面板？`n   - 最上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 双击列表中任意应用进程，就可以将其添加到下方任意列表中`n   - 如果需要更多的进程，请点击下方的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击下方的「通过输入进程名称手动添加」直接添加进程名称`n   - 下方分别是 InputTip 的多种光标获取模式`n   - 不用在意这些模式是啥，只要记住，哪个能用，就用哪个即可`n   - 这几个模式列表中的应用进程会使用对应的模式尝试去获取光标位置`n   - 双击列表中任意应用进程，就可以将它移除或者添加到其他列表中`n   - 如果选择添加且此应用不在白名单中，则会同步添加到白名单中`n`n2. 什么时候需要去添加？`n  - 当你发现一个应用窗口，无法获取到光标位置，或者有兼容性问题`n  - 就可以尝试将其添加到下方的各个列表中，看哪个模式是可用的且无兼容性问题的`n  - 如果所有模式都不可用，则表示在此窗口中获取不到光标位置，暂时无法解决`n  - 如果已知都不可用，记得移除它`n`n3. JetBrains 系列 IDE`n   - JetBrains 系列 IDE 需要添加到「JAB」列表中`n   - 如果未生效，请检查是否完成「启用 JetBrains IDE 支持」中的所有操作步骤`n      - 你应该访问这些相关链接:   <a href="https://inputtip.pages.dev/FAQ/use-inputtip-in-jetbrains">InputTip 官网</a>   <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Github</a>   <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Gitee</a>')

            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
            }
            gc.w.cursorModeGui := g
            return g
        }
    }
}
