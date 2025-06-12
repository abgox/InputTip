; InputTip

fn_switch_window(*) {
    showGui()
    showGui(deep := "") {
        createUniqueGui(switchWindowGui).Show()
        switchWindowGui(info) {
            g := createGuiOpt("InputTip - 设置指定窗口状态自动切换")
            tab := g.AddTab3("-Wrap", ["中文状态", "英文状态", "大写锁定", "关于"])
            tab.UseTab(1)

            if (info.i) {
                g.AddText("Section cRed", "你首先应该点击上方的「关于」查看具体的操作说明                                              ")
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            addItem(state) {
                gc.%"LV_" state%.Opt("-Redraw")
                valueArr := StrSplit(readIniSection("App-" state), "`n")
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

                        tipGlobal := isGlobal ? "窗口级" : "标题级"

                        tipRegex := isRegex ? "正则" : "相等"
                        gc.%"LV_" state%.Add(, name, tipGlobal, tipRegex, title, kv[1])
                    } else {
                        IniDelete("InputTip.ini", "App-" state, kv[1])
                    }
                }
                gc.%"LV_" state%.Opt("+Redraw")
                gc.%state "_title"%.Text := "( " gc.%"LV_" state%.GetCount() " 个 )"
                autoHdrLV(gc.%"LV_" state%)
            }

            fn_dbClick(LV, RowNumber) {
                handleClick(LV, RowNumber, LV._type)
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

                itemValue := {
                    exe_name: LV.GetText(RowNumber, 1),
                    status: stateMap.%from%,
                    isGlobal: LV.GetText(RowNumber, 2),
                    isRegex: LV.GetText(RowNumber, 3),
                    title: LV.GetText(RowNumber, 4),
                    id: LV.GetText(RowNumber, 5)
                }
                createGui(editGui).Show()
                editGui(info) {
                    return fn_edit(LV, RowNumber, from, itemValue)
                }
            }

            fn_edit(LV, RowNumber, from, itemValue) {
                _gc := {
                    exe_name: "",
                    statusNum: "",
                    isGlobal: "",
                    isRegex: "",
                    title: ""
                }

                label := from == "addManual" ? "添加" : "编辑"

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, "------------------------------------------------------")
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                g.AddText(, "1. 进程名称: ")
                _ := g.AddEdit("yp w" bw / 1.5, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
                }

                g.AddText("xs", "2. 状态切换: ")
                _ := g.AddDropDownList("yp w" bw / 1.5, ["中文状态", "英文状态", "大写锁定"])
                _.Text := itemValue.status
                _.OnEvent("Change", e_changeState)
                e_changeState(item, *) {
                    v := item.Text
                    itemValue.status := v
                }

                g.AddText("xs", "3. 匹配范围: ")
                _ := g.AddDropDownList("yp w" bw / 1.5, ["窗口级", "标题级"])
                _.Text := itemValue.isGlobal
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.isGlobal := v
                }

                g.AddText("xs cGray", "【匹配模式】和【匹配标题】仅在【匹配范围】为【标题级】时有效")
                g.AddText("xs", "4. 匹配模式: ")
                _ := g.AddDropDownList("yp w" bw / 1.5, ["相等", "正则"])
                _.Text := itemValue.isRegex
                _.OnEvent("Change", e_changeMatch)
                e_changeMatch(item, *) {
                    v := item.Text
                    itemValue.isRegex := v
                }

                g.AddText("xs", "5. 匹配标题: ")
                _ := g.AddEdit("yp w" bw / 1.5)
                _.Text := itemValue.title
                _.OnEvent("Change", e_changeTitle)
                e_changeTitle(item, *) {
                    v := item.Text
                    itemValue.title := v
                }
                g.AddButton("xs w" bw / 1.2, "完成" label).OnEvent("Click", e_set)
                e_set(*) {
                    fn_set()
                }
                if (from != "addManual") {
                    g.AddButton("xs w" bw / 1.2, "删除它").OnEvent("Click", e_delete)
                    e_delete(*) {
                        fn_set(1)
                    }
                }

                fn_set(delete := 0) {
                    g.Destroy()

                    try {
                        IniDelete("InputTip.ini", "App-" from, itemValue.id)
                    }

                    if (delete) {
                        LV.Delete(RowNumber)
                        gc.%from "_title"%.Text := "( " gc.%"LV_" from%.GetCount() " 个 )"
                    } else {
                        isGlobal := itemValue.isGlobal == "窗口级" ? 1 : 0
                        isRegex := itemValue.isRegex == "正则" ? 1 : 0
                        value := itemValue.exe_name ":" isGlobal ":" isRegex ":" itemValue.title
                        ; 没有进行移动
                        if (itemValue.status == from) {
                            writeIni(itemValue.id, value, "App-" from, "InputTip.ini")
                            LV.Modify(RowNumber, , itemValue.exe_name, itemValue.isGlobal, itemValue.isRegex, itemValue.title, itemValue.id)
                        } else {
                            if (from != "addManual") {
                                LV.Delete(RowNumber)
                                gc.%from "_title"%.Text := "( " gc.%"LV_" from%.GetCount() " 个 )"
                            }
                            state := stateTextMap.%itemValue.status%
                            writeIni(itemValue.id, value, "App-" state, "InputTip.ini")
                            gc.%"LV_" state%.Insert(RowNumber, , itemValue.exe_name, itemValue.isGlobal, itemValue.isRegex, itemValue.title, itemValue.id)
                            gc.%state "_title"%.Text := "( " gc.%"LV_" state%.GetCount() " 个 )"
                        }
                        updateWhiteList(itemValue.exe_name)
                    }

                    autoHdrLV(LV)

                    ; 应用列表: 自动切换到中文
                    global app_CN := StrSplit(readIniSection("App-CN"), "`n")
                    ; 应用列表: 自动切换到英文
                    global app_EN := StrSplit(readIniSection("App-EN"), "`n")
                    ; 应用列表: 自动切换到大写锁定
                    global app_Caps := StrSplit(readIniSection("App-Caps"), "`n")
                }
                return g
            }


            for i, v in ["CN", "EN", "Caps"] {
                g.AddText("Section cRed", "你首先应该点击上方的「关于」查看具体的操作说明                                              ")
                g.AddText("Section", "需要自动切换到")
                g.AddText("yp cRed", stateMap.%v%)
                g.AddText("yp", "的应用窗口")
                gc.%v "_title"% := g.AddText("yp cRed w" bw / 3, "( 0 个 )")


                if (symbolType = 3) {
                    c := symbolConfig.%"textSymbol_" v "_color"% ? "c" StrReplace(symbolConfig.%"textSymbol_" v "_color"%, "#") : ""
                } else {
                    c := symbolConfig.%v "_color"% ? "c" StrReplace(symbolConfig.%v "_color"%, "#") : ""
                }
                LV := "LV_" v
                try {
                    gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w " " c, ["进程名称", "匹配范围", "匹配模式", "匹配标题", "唯一标识符"])
                } catch {
                    gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["进程名称", "匹配范围", "匹配模式", "匹配标题", "唯一标识符"])
                }
                addItem(v)
                autoHdrLV(gc.%LV%)
                gc.%LV%.OnEvent("DoubleClick", fn_dbClick)
                gc.%LV%._type := v

                _ := g.AddButton("xs w" w, "添加一条自动切换规则")
                _.OnEvent("Click", e_add)
                _._LV := LV
                _._type := v
                e_add(item, *) {
                    fn_add(item._LV, item._type)
                }

                tab.UseTab(i + 1)
            }
            fn_add(LV, state) {
                createUniqueGui(addGui).Show()
                addGui(info) {
                    showGui(deep := 0) {
                        g := createGuiOpt("InputTip - 添加一条自动切换规则")
                        g.AddText("Section cRed", "- 点击下方任意一行进行添加，或者点击「显示更多进程」`n- 如果没有你需要的，可以点击「手动添加」")
                        gc.LV_add := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" bw, ["应用进程列表", "窗口标题", "应用进程文件所在位置"])

                        gc.LV_add.OnEvent("DoubleClick", e_click_add)
                        e_click_add(LV, RowNumber, *) {
                            itemValue := {
                                exe_name: LV.GetText(RowNumber, 1),
                                status: stateMap.%state%,
                                isGlobal: "窗口级",
                                isRegex: "相等",
                                title: LV.GetText(RowNumber, 2),
                                id: FormatTime(A_Now, "yyyy-MM-dd-HH:mm:ss") "." A_MSec
                            }
                            g.Destroy()
                            fn_edit(LV, RowNumber, "addManual", itemValue).Show()
                        }

                        gc.LV_add._type := "add"

                        res := ":"
                        DetectHiddenWindows deep
                        gc.LV_add.Opt("-Redraw")
                        for v in WinGetList() {
                            try {
                                exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                                if (!InStr(res, ":" exe_name ":")) {
                                    res .= exe_name ":"
                                    gc.LV_add.Add(, exe_name, WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                                }
                            }
                        }
                        for v in StrSplit(readIni("app_show_state", ''), ":") {
                            if (!InStr(res, ":" v ":")) {
                                res .= exe_name ":"
                                try {
                                    gc.LV_add.Add(, v, WinGetTitle("ahk_exe " v), WinGetProcessPath("ahk_exe " v))
                                } catch {
                                    gc.LV_add.Add(, v)
                                }
                            }
                        }
                        gc.LV_add.Opt("+Redraw")
                        DetectHiddenWindows 1
                        autoHdrLV(gc.LV_add)
                        g.AddButton("Section w" bw / 3, "刷新此界面").OnEvent("Click", e_fresh)
                        e_fresh(*) {
                            g.Destroy()
                            showGui(deep).Show()
                        }

                        g.AddButton("yp w" bw / 3, "手动添加").OnEvent("Click", e_add_manually)

                        e_add_manually(*) {
                            itemValue := {
                                exe_name: "",
                                status: stateMap.%state%,
                                isGlobal: "窗口级",
                                isRegex: "相等",
                                title: "",
                                id: FormatTime(A_Now, "yyyy-MM-dd-HH:mm:ss") "." A_MSec
                            }
                            g.Destroy()
                            fn_edit(gc.%LV%, 1, "addManual", itemValue).Show()
                        }

                        if (deep) {
                            g.AddButton("yp w" bw / 3, "显示更少进程(仅前台窗口)").OnEvent("Click", e_less_window)
                            e_less_window(*) {
                                g.Destroy()
                                showGui(0).Show()
                            }
                        } else {
                            g.AddButton("yp w" bw / 3, "显示更多进程(后台窗口)").OnEvent("Click", e_more_window)
                            e_more_window(*) {
                                g.Destroy()
                                showGui(1).Show()
                            }
                        }

                        return g
                    }
                    return showGui()
                }
            }

            ; autoHdrLV(gc.LV_add)
            g.AddEdit("ReadOnly VScroll r12 w" w, "1. 简要说明`n   - 这个菜单用来设置【指定窗口自动切换状态】的匹配规则`n   - 上方是三个 Tab 标签页: 【中文状态】【英文状态】【大写锁定】`n   - 下方是对应的规则列表`n`n2. 规则列表 —— 进程名称`n   - 窗口实际的应用进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【窗口级】或【标题级】，它控制自动切换的时机`n   - 【窗口级】: 只有从其他窗口切换到此窗口时，才会触发`n   - 【标题级】: 只要窗口标题发生变化，且匹配成功，就会触发`n`n4. 规则列表 —— 匹配模式`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 【相等】或【正则】，它控制标题匹配的模式`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发自动切换`n   - 【正则】: 使用正则表达式匹配标题，匹配成功则触发自动切换`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式`n   - 它会根据匹配模式进行匹配，匹配成功则触发自动切换`n`n6. 规则列表 —— 唯一标识符`n   - 自动生成的标识符，它是每条规则的创建时间`n   - 没有实际的操作意义，请忽略它`n`n7. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n8. 按钮 —— 添加一条自动切换规则`n   - 点击它，可以添加一条新的自动切换规则`n   - 白名单机制下，如果此应用不在白名单中，则会同步添加到白名单中`n`n9. 需要特别注意:`n   - 自动切换生效的前提是当前选择的输入法可以切换状态`n   - 以【美式键盘 ENG】为例`n   - 它只有英文状态和大写锁定，所以只有英文状态的和大写锁定的自动切换有效")
            g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/switch-state">关于指定窗口自动切换状态</a>')

            g.OnEvent("Close", fn_close)
            fn_close(*) {
                g.Destroy()
                try {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
            }
            return g
        }
    }
}
