; InputTip

fn_cursor_mode(*) {
    showGui()
    showGui(deep := 0) {
        createUniqueGui(modeGui).Show()
        modeGui(info) {
            g := createGuiOpt("InputTip - 光标获取模式")
            tab := g.AddTab3("-Wrap", ["光标获取模式", "关于"])
            tab.UseTab(1)
            g.AddText("Section cRed", gui_help_tip)

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2


            LV := "LV_" A_Now
            gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["进程名称", "光标获取模式", "创建时间"])

            gc.%LV%.Opt("-Redraw")
            valueArr := StrSplit(readIniSection("InputCursorMode"), "`n")
            for v in valueArr {
                kv := StrSplit(v, "=", , 2)
                part := StrSplit(kv[2], ":", , 4)
                try {
                    name := part[1]
                    mode := part[2]
                    gc.%LV%.Add(, name, mode, kv[1])
                }
            }
            gc.%LV%.Opt("+Redraw")
            autoHdrLV(gc.%LV%)


            gc.%LV%.OnEvent("DoubleClick", handleClick)
            gc.%LV%._LV := LV
            _ := g.AddButton("xs w" w / 2, "快捷添加")
            _.OnEvent("Click", e_add)
            _._LV := LV
            e_add(item, *) {
                fn_add(item._LV)
            }

            _ := g.AddButton("yp w" w / 2, "手动添加")
            _.OnEvent("Click", e_add_manually)
            _._LV := LV
            e_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    mode: "HOOK",
                    id: returnId()
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
                    mode: LV.GetText(RowNumber, 2),
                    id: LV.GetText(RowNumber, 3)
                }
                createGui(editGui).Show()
                editGui(info) {
                    return fn_edit(gc.%LV._LV%, RowNumber, "edit", itemValue)
                }
            }

            fn_edit(LV, RowNumber, action, itemValue) {
                ; 是否自动添加到符号显示白名单中
                needAddWhiteList := 1

                if (action == "edit") {
                    actionText := "编辑"
                } else {
                    actionText := "添加"
                }

                label := "正在" actionText "应用的光标获取模式"

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                if (action != "edit") {
                    g.AddText("cRed", "是否添加到【符号显示白名单】中: ")
                    _ := g.AddDropDownList("yp", ["【否】不添加", "【是】自动添加"])
                    _.Value := needAddWhiteList + 1
                    _.OnEvent("Change", e_change)
                    e_change(item, *) {
                        needAddWhiteList := item.value - 1
                    }
                    g.AddText("xs cGray", "如果选择【是】，且它在白名单中不存在，将以【进程级】自动添加")
                }

                scaleWidth := bw / 1.6

                g.AddText(, "1. 应用进程名称: ")
                _ := g.AddEdit("yp w" scaleWidth, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
                }

                g.AddText("xs", "2. 光标获取模式: ")
                _ := g.AddDropDownList("yp w" scaleWidth, modeNameList)
                _.Text := itemValue.mode
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.mode := v
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
                            IniDelete("InputTip.ini", "InputCursorMode", itemValue.id)
                            LV.Delete(RowNumber)
                        }
                    } else {
                        value := itemValue.exe_name ":" itemValue.mode
                        ; 没有进行移动
                        writeIni(itemValue.id, value, "InputCursorMode", "InputTip.ini")
                        if (action == "edit") {
                            LV.Modify(RowNumber, , itemValue.exe_name, itemValue.mode, itemValue.id)
                        } else {
                            LV.Insert(RowNumber, , itemValue.exe_name, itemValue.mode, itemValue.id)
                        }

                        if (needAddWhiteList) {
                            updateWhiteList(itemValue.exe_name)
                        }
                    }

                    autoHdrLV(LV)

                    updateCursorMode()
                }
                return g
            }

            fn_add(parentLV) {
                args := {
                    title: "快捷添加",
                    configName: "",
                    LV: parentLV,
                }
                createProcessListGui(args, addClick, e_add_manually)

                addClick(args) {
                    windowInfo := args.windowInfo
                    RowNumber := args.RowNumber

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        mode: "HOOK",
                        id: windowInfo.id
                    }
                    fn_edit(gc.%args.parentArgs.LV%, RowNumber, "add", itemValue).Show()
                }

                e_add_manually(args) {
                    windowInfo := args.windowInfo

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        mode: "HOOK",
                        id: windowInfo.id
                    }
                    fn_edit(gc.%args.parentArgs.LV%, 1, "add", itemValue).Show()
                }
            }
            tab.UseTab(2)
            g.AddEdit("ReadOnly VScroll r11 w" w, "1. 简要说明`n   - 这个菜单用来设置【光标获取模式】的匹配规则`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 光标获取模式`n   - 包括【HOOK】【UIA】【MSAA】【JAB】等等`n   - 不用在意这些模式是啥，哪个能用，就用哪个即可`n   - 如果想了解详细的相关内容，可以查看下方相关链接`n`n4. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n5. 按钮 —— 添加应用的光标获取模式`n   - 点击它，可以添加一条新的规则`n   - 这条规则用来指定某个应用进程使用什么光标获取模式`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n6. 光标获取模式 —— JAB`n   - 在所有的光标获取模式中，【JAB】是特殊的`n   - 它仅用于需要使用 Java Access Bridge 的进程，比如 JetBrains IDE`n   - 它需要配合【托盘菜单】中的【启用 JAB/JetBrains IDE 支持】一起使用`n   - 详情参考【启用 JAB/JetBrains IDE 支持】的使用说明")
            g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/cursor-mode">关于光标获取模式</a>   <a href="https://inputtip.abgox.com/FAQ/use-inputtip-in-jetbrains">如何在 JetBrains 系列 IDE 中使用 InputTip</a>')
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
