; InputTip

fn_switch_window(*) {
    showGui()
    showGui(deep := 0) {
        createUniqueGui(switchWindowGui).Show()
        switchWindowGui(info) {
            g := createGuiOpt("InputTip - 指定窗口自动切换输入法状态")
            tab := g.AddTab3("-Wrap", ["中文状态", "英文状态", "大写锁定", "关于"])
            tab.UseTab(1)

            if (info.i) {
                g.AddText(, gui_width_line)
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

                        tipGlobal := isGlobal ? "进程级" : "标题级"

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
                    tipGlobal: LV.GetText(RowNumber, 2),
                    tipRegex: LV.GetText(RowNumber, 3),
                    title: LV.GetText(RowNumber, 4),
                    id: LV.GetText(RowNumber, 5)
                }
                createGui(editGui).Show()
                editGui(info) {
                    return fn_edit(LV, RowNumber, from, "edit", itemValue)
                }
            }

            fn_edit(LV, RowNumber, from, action, itemValue) {
                ; 是否自动添加到符号的白名单中
                needAddWhiteList := 1

                if (action == "edit") {
                    actionText := "编辑"
                } else {
                    actionText := "添加"
                }

                label := "正在" actionText "一条自动切换规则"

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                if (action != "edit") {
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

                g.AddText("xs", "2. 状态切换: ")
                _ := g.AddDropDownList("yp w" scaleWidth, ["中文状态", "英文状态", "大写锁定"])
                _.Text := itemValue.status
                _.OnEvent("Change", e_changeState)
                e_changeState(item, *) {
                    v := item.Text
                    itemValue.status := v
                }

                g.AddText("xs", "3. 匹配范围: ")
                _ := g.AddDropDownList("yp w" scaleWidth, ["进程级", "标题级"])
                _.Text := itemValue.tipGlobal
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.tipGlobal := v
                }

                g.AddText("xs cGray", "【匹配模式】和【匹配标题】仅在【匹配范围】为【标题级】时有效")
                g.AddText("xs", "4. 匹配模式: ")
                _ := g.AddDropDownList("yp w" scaleWidth, ["相等", "正则"])
                _.Text := itemValue.tipRegex
                _.OnEvent("Change", e_changeMatch)
                e_changeMatch(item, *) {
                    v := item.Text
                    itemValue.tipRegex := v
                }

                g.AddText("xs", "5. 匹配标题: ")
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
                            IniDelete("InputTip.ini", "App-" from, itemValue.id)
                            LV.Delete(RowNumber)
                            gc.%from "_title"%.Text := "( " gc.%"LV_" from%.GetCount() " 个 )"
                        }
                    } else {
                        isGlobal := itemValue.tipGlobal == "进程级" ? 1 : 0
                        isRegex := itemValue.tipRegex == "正则" ? 1 : 0
                        value := itemValue.exe_name ":" isGlobal ":" isRegex ":" itemValue.title
                        ; 没有进行移动
                        if (itemValue.status == from) {
                            writeIni(itemValue.id, value, "App-" from, "InputTip.ini")
                            LV.Modify(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.id)
                        } else {
                            if (action == "edit") {
                                LV.Delete(RowNumber)
                                gc.%from "_title"%.Text := "( " gc.%"LV_" from%.GetCount() " 个 )"
                            }
                            state := stateTextMap.%itemValue.status%
                            writeIni(itemValue.id, value, "App-" state, "InputTip.ini")
                            gc.%"LV_" state%.Insert(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.id)
                            gc.%state "_title"%.Text := "( " gc.%"LV_" state%.GetCount() " 个 )"
                        }
                        if (needAddWhiteList) {
                            updateWhiteList(itemValue.exe_name)
                        }
                    }
                    try {
                        autoHdrLV(gc.%"LV_" state%)
                    }
                    updateAutoSwitchList()
                }
                return g
            }


            for i, v in ["CN", "EN", "Caps"] {
                g.AddText("Section cRed", gui_help_tip)
                g.AddText("Section", "需要自动切换到")
                g.AddText("yp cRed", stateMap.%v%)
                g.AddText("yp", "的应用窗口")
                gc.%v "_title"% := g.AddText("yp cRed w" bw / 3, "( 0 个 )")

                LV := "LV_" v
                gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["进程名称", "匹配范围", "匹配模式", "匹配标题", "创建时间"])
                addItem(v)
                autoHdrLV(gc.%LV%)
                gc.%LV%.OnEvent("DoubleClick", fn_dbClick)
                gc.%LV%._type := v

                _ := g.AddButton("xs w" w / 2, "快捷添加")
                _._LV := LV
                _._type := v
                _.OnEvent("Click", (item, *) => fn_add(item._LV, item._type))

                _ := g.AddButton("yp w" w / 2, "手动添加")
                _._LV := LV
                _._type := v
                _.OnEvent("Click", fn_add_manually)

                tab.UseTab(i + 1)
            }
            fn_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    status: stateMap.%item._type%,
                    tipGlobal: "进程级",
                    tipRegex: "相等",
                    title: "",
                    id: returnId()
                }
                fn_edit(item._LV, 1, item._type, "add", itemValue).Show()
            }

            fn_add(LV, state) {
                args := {
                    title: "快捷添加",
                    state: state,
                    configName: "",
                    LV: LV
                }
                createProcessListGui(args, addClick, e_add_manually)

                addClick(args) {
                    windowInfo := args.windowInfo
                    LV := args.LV
                    RowNumber := args.RowNumber
                    state := args.parentArgs.state

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        status: stateMap.%state%,
                        tipGlobal: "进程级",
                        tipRegex: "相等",
                        title: windowInfo.title,
                        id: windowInfo.id,
                    }
                    fn_edit(LV, RowNumber, state, "add", itemValue).Show()
                }

                e_add_manually(args) {
                    windowInfo := args.windowInfo
                    LV := args.parentArgs.LV
                    state := args.parentArgs.state

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        status: stateMap.%state%,
                        tipGlobal: "进程级",
                        tipRegex: "相等",
                        title: windowInfo.title,
                        id: windowInfo.id,
                    }
                    fn_edit(LV, 1, state, "add", itemValue).Show()
                }
            }

            g.AddEdit("ReadOnly VScroll r12 w" w, "1. 简要说明`n   - 这个菜单用来设置【指定窗口自动切换状态】的匹配规则`n   - 上方是三个 Tab 标签页: 【中文状态】【英文状态】【大写锁定】`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】，它控制自动切换的时机`n   - 【进程级】: 只有从一个进程切换到另一个进程时，才会触发`n   - 【标题级】: 只要窗口标题发生变化，且匹配成功，就会触发`n`n4. 规则列表 —— 匹配模式`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 【相等】或【正则】，它控制标题匹配的模式`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发自动切换`n   - 【正则】: 使用正则表达式匹配标题，匹配成功则触发自动切换`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式，与【匹配模式】相对应，匹配成功则触发自动切换`n   - 如果不知道当前窗口的相关信息(进程/标题等)，可以通过以下方式获取`n      - 【托盘菜单】=>【获取窗口信息】`n`n6. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n7. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n8. 按钮 —— 快捷添加`n   - 点击它，可以添加一条新的规则`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n9. 按钮 —— 手动添加`n   - 点击它，可以添加一条新的规则`n   - 它会直接弹出添加窗口，你需要手动填写进程名称、标题等信息`n`n10. 自动切换生效需要满足的前提条件`n   - 前提条件: `n       - 当 InputTip 执行自动切换时，此时的输入法可以正常切换状态`n       - 大写锁定除外，因为它是通过模拟输入【CapsLock】按键实现，不受其他影响`n`n   - 以【微软输入法】为例`n   - 和常规输入法不同，只有当聚焦到输入框时，它才能正常切换输入法状态`n   - 但是，当 InputTip 执行自动切换时，可能并没有聚焦到输入框，自动切换就会失效`n`n   - 再以【美式键盘 ENG】为例`n   - 它只有英文状态和大写锁定，所以只有英文状态的和大写锁定的自动切换有效")
            g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/faq/switch-state">指定窗口自动切换状态</a>')

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
