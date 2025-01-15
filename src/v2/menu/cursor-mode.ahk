fn_cursor_mode(*) {
    showGui()
    showGui(deep := "") {
        if (gc.w.cursorModeGui) {
            gc.w.cursorModeGui.Destroy()
            gc.w.cursorModeGui := ""
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        createGui(modeGui).Show()
        modeGui(info) {
            g := createGuiOpt()
            tab := g.AddTab3("-Wrap", ["设置光标获取模式", "关于"])
            tab.UseTab(1)
            g.AddText("Section cRed", "你首先应该点击上方的「关于」查看具体的操作说明                                              ")

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            gc.LV_add := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["应用进程列表", "窗口标题", "应用进程文件所在位置"])
            gc.LV_add.OnEvent("DoubleClick", e_add)
            e_add(LV, RowNumber) {
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

            addItem(mode) {
                gc.%"LV_" mode%.Opt("-Redraw")
                valueArr := StrSplit(readIni("cursor_mode_" mode, ""), ":")
                temp := ":"
                for v in valueArr {
                    if (Trim(v) && !InStr(temp, ":" v ":")) {
                        gc.%"LV_" mode%.Add(, v)
                        temp .= v ":"
                    }
                }
                gc.%"LV_" mode%.Opt("+Redraw")
                gc.%mode "_title"%.Value .= " ( " gc.%"LV_" mode%.GetCount() " 个 )"
            }

            for i, v in modeNameList {
                opt := i = 1 || i = 5 ? "xs" : "yp"
                if (i = 1) {
                    for value in [1, 2, 3, 4] {
                        o := value = 1 ? "xs" : "yp"
                        item := modeNameList[value]
                        gc.%item "_title"% := g.AddText(o " w" bw / 4, item)
                    }
                }
                if (i = 5) {
                    for value in [5, 6, 7, 8] {
                        o := value = 5 ? "xs" : "yp"
                        item := modeNameList[value]
                        gc.%item "_title"% := g.AddText(o " w" bw / 4, item)
                    }
                }
                gc.%"LV_" v% := g.AddListView(opt " cRed -Hdr -LV0x10 -Multi r5 NoSortHdr Sort Grid w" bw / 4, [v])
                addItem(v)
                gc.%"LV_" v%.ModifyCol(1, "AutoHdr")
                gc.%"LV_" v%.OnEvent("DoubleClick", e_mode)
                gc.%"LV_" v%._mode := v
                e_mode(LV, RowNumber) {
                    handleClick(LV, RowNumber, LV._mode)
                }
            }

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
                            v := gc.%from "_title"%.Value
                            gc.%from "_title"%.Value := SubStr(v, 1, InStr(v, " ")) "( " gc.%"LV_" from%.GetCount() " 个 )"

                            config := "cursor_mode_" from
                            value := readIni(config, "")
                            res := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != exe_name) {
                                    res .= ":" v
                                }
                            }
                            writeIni(config, SubStr(res, 2))
                        }
                        config := "cursor_mode_" to
                        value := readIni(config, "")

                        if (!InStr(":" value ":", ":" exe_name ":")) {
                            gc.%"LV_" to%.Add(, exe_name)
                            v := gc.%to "_title"%.Value
                            gc.%to "_title"%.Value := SubStr(v, 1, InStr(v, " ")) "( " gc.%"LV_" to%.GetCount() " 个 )"
                            if (value) {
                                writeIni(config, value ":" exe_name)
                            } else {
                                writeIni(config, exe_name)
                            }
                        }
                        updateWhiteList(exe_name)
                        updateCursorMode(config != "cursor_mode_JAB")
                    }
                    g := createGuiOpt()
                    g.AddText(, "要将进程")
                    g.AddText("yp cRed", exe_name)
                    g.AddText("yp", "添加到哪一个光标获取模式中？")
                    if (useWhiteList) {
                        g.AddText("xs cRed", "如果此应用不在白名单中，则会同步添加到白名单中")
                    }

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    for i, v in modeNameList {
                        opt := i = 1 || i = 5 ? "xs" : "yp"
                        if (v = from) {
                            opt .= " Disabled"
                        }
                        _ := g.AddButton(opt " w" bw / 4, v)
                        _._mode := v
                        _.OnEvent("Click", e_mode)
                        e_mode(item, *) {
                            _handle(item._mode)
                        }
                    }
                    if (from != "add") {
                        g.AddButton("xs w" w, "将它移除").OnEvent("Click", e_rm)
                        e_rm(*) {
                            g.Destroy()
                            LV.Delete(RowNumber)
                            v := gc.%from "_title"%.Value
                            gc.%from "_title"%.Value := SubStr(v, 1, InStr(v, " ")) "( " gc.%"LV_" from%.GetCount() " 个 )"
                            try {
                                gc.LV_add.Add(, exe_name, WinGetTitle("ahk_exe " exe_name))
                            }
                            config := "cursor_mode_" from
                            value := readIni(config, "")
                            result := ""
                            for v in StrSplit(value, ":") {
                                if (Trim(v) && v != exe_name) {
                                    result .= ":" v
                                }
                            }
                            writeIni(config, SubStr(result, 2))
                            updateCursorMode(config != "cursor_mode_JAB")
                        }
                    }

                    g.AddButton("xs w" w, "取消操作").OnEvent("Click", e_no)
                    e_no(*) {
                        g.Destroy()
                    }
                    gc.w.subGui := g
                    return g
                }
            }

            g.AddButton("xs w" w / 3, "刷新应用进程列表").OnEvent("Click", e_refresh)
            e_refresh(*) {
                fn_close()
                showGui(deep)
            }

            g.AddButton("yp w" w / 3, "通过输入进程名称手动添加").OnEvent("Click", e_add_by_hand)
            e_add_by_hand(*) {
                addApp("xxx.exe")
                addApp(v) {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    createGui(addGui).Show()
                    addGui(info) {
                        g := createGuiOpt("InputTip - 设置光标获取模式")
                        text := "每次只能添加一个应用进程名称"
                        if (useWhiteList) {
                            text .= "`n如果它不在白名单中，则会同步添加到白名单中"
                        }
                        g.AddText("cRed", text)
                        g.AddText("xs", "应用进程名称: ")
                        gc._exe_name := g.AddEdit("yp", "")
                        gc._exe_name.Value := v
                        g.AddText("xs cGray", "要将这个应用进程添加到哪一个光标获取模式中？")

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        for i, v in modeNameList {
                            opt := i = 1 || i = 5 ? "xs" : "yp"
                            _ := g.AddButton(opt " w" bw / 4, v)
                            _._mode := v
                            _.OnEvent("Click", e_handle)
                        }
                        e_handle(item, *) {
                            to := item._mode
                            exe_name := gc._exe_name.value
                            g.Destroy()
                            if (!RegExMatch(exe_name, "^.+\.\w{3}$") || RegExMatch(exe_name, '[\\/:*?\"<>|]')) {
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

                            config := "cursor_mode_" to
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
                            v := gc.%to "_title"%.Value
                            gc.%to "_title"%.Value := SubStr(v, 1, InStr(v, " ")) "( " gc.%"LV_" to%.GetCount() " 个 )"
                            if (value) {
                                writeIni(config, value ":" exe_name)
                            } else {
                                writeIni(config, exe_name)
                            }
                            updateWhiteList(exe_name)
                            updateCursorMode(config != "cursor_mode_JAB")
                        }
                        gc.w.subGui := g
                        return g
                    }
                }
            }
            if (deep) {
                g.AddButton("yp w" w / 3, "显示更少进程(仅前台窗口)").OnEvent("Click", e_less_window)
                e_less_window(*) {
                    fn_close()
                    showGui("")
                }
            } else {
                g.AddButton("yp w" w / 3, "显示更多进程(后台窗口)").OnEvent("Click", e_more_window)
                e_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }

            gc.LV_add.ModifyCol(1, "AutoHdr")
            gc.LV_add.ModifyCol(2, "AutoHdr")
            gc.LV_add.ModifyCol(3, "AutoHdr")
            tab.UseTab(2)
            g.AddEdit("ReadOnly -VScroll w" w, '1. 如何使用这个管理面板？`n   - 最上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 为了便于操作，白名单中的应用进程也会添加到列表中`n   - 双击列表中任意应用进程，就可以将其添加到下方任意列表中`n   - 如果需要更多的进程，请点击下方的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击下方的「通过输入进程名称手动添加」直接添加进程名称`n   - 下方分别是 InputTip 的多种光标获取模式`n   - 不用在意这些模式是啥，只要记住，哪个能用，就用哪个即可`n      - 如果很想了解相关内容，请查看下方相关链接`n   - 这几个模式列表中的应用进程会使用对应的模式尝试去获取光标位置`n   - 双击列表中任意应用进程，就可以将它移除或者添加到其他列表中`n   - 白名单机制下，选择添加且此应用不在白名单中，则会同步添加到白名单中`n`n2. 什么时候需要去添加？`n  - 当你发现一个应用窗口，无法获取到光标位置，或者有兼容性问题时`n  - 就可以尝试将其添加到下方的各个列表中，看哪个模式是可用的且无兼容性问题的`n  - 如果所有模式都不可用，则表示在此窗口中获取不到光标位置，暂时无法解决`n  - 如果已知都不可用，记得移除这个应用进程`n`n3. JetBrains 系列 IDE`n   - JetBrains 系列 IDE 需要添加到「JAB」列表中`n   - 如果未生效，请检查是否完成「启用 JAB/JetBrains IDE 支持」中的所有操作步骤')
            g.AddLink(, '相关链接: <a href="https://inputtip.pages.dev/FAQ/cursor-mode">关于光标获取模式</a>')
            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
            }
            gc.w.cursorModeGui := g
            return g
        }
    }
}
