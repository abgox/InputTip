; InputTip

fn_cursor_mode(*) {
    showGui()
    showGui(deep := 0) {
        createUniqueGui(modeGui).Show()
        modeGui(info) {
            g := createGuiOpt("InputTip - " lang("cursor_mode.title"))
            tab := g.AddTab3("-Wrap", [lang("cursor_mode.title"), lang("common.about")])
            tab.UseTab(1)
            g.AddText("Section cRed", lang("gui.help_tip"))

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2


            LV := "LV_" A_Now
            gc.%LV% := g.AddListView("xs -LV0x10 -Multi r9 NoSortHdr Sort Grid w" w, [lang("common.process_name"), lang("cursor_mode.title"), lang("common.create_time")])

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
            _ := g.AddButton("xs w" w / 2, lang("common.quick_add"))
            _.OnEvent("Click", e_add)
            _._LV := LV
            e_add(item, *) {
                fn_add(item._LV)
            }

            _ := g.AddButton("yp w" w / 2, lang("common.manual_add"))
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
                ; 是否自动添加到符号的白名单中
                needAddWhiteList := 1

                if (action == "edit") {
                    actionText := lang("common.edit")
                } else {
                    actionText := lang("common.add")
                }

                label := (action == "add" ? lang("gui.adding_rule") : lang("gui.editing_rule")) " - " lang("cursor_mode.title")

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                if (action != "edit") {
                    g.AddText("cRed", lang("gui.add_to_whitelist"))
                    _ := g.AddDropDownList("yp", [lang("gui.add_to_whitelist_no"), lang("gui.add_to_whitelist_yes")])
                    _.Value := needAddWhiteList + 1
                    _.OnEvent("Change", e_change)
                    e_change(item, *) {
                        needAddWhiteList := item.value - 1
                    }
                    g.AddText("xs cGray", lang("gui.add_to_whitelist_tip"))
                }

                scaleWidth := bw / 1.6

                g.AddText(, lang("cursor_mode.process_name_label"))
                _ := g.AddEdit("yp w" scaleWidth, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
                }

                g.AddText("xs", lang("cursor_mode.mode_label"))
                _ := g.AddDropDownList("yp w" scaleWidth, modeNameList)
                _.Text := itemValue.mode
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.mode := v
                }

                g.AddButton("xs w" bw / 1.2, (action == "add" ? lang("common.complete_add") : lang("common.complete_edit"))).OnEvent("Click", e_set)
                e_set(*) {
                    fn_set(action, 0)
                }
                if (action == "edit") {
                    g.AddButton("xs w" bw / 1.2, lang("common.delete_it")).OnEvent("Click", e_delete)
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
                    title: lang("common.quick_add"),
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
            g.AddEdit("ReadOnly VScroll r13 w" w, lang("about_text.cursor_mode"))
            g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/cursor-mode">Cursor Detection Mode</a>   <a href="https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains">Using InputTip in JetBrains IDE</a>')
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
