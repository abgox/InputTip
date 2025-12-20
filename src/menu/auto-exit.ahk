; InputTip

fn_auto_exit(*) {
    showGui()
    showGui(deep := 0) {
        createUniqueGui(autoExitGui).Show()
        autoExitGui(info) {
            g := createGuiOpt("InputTip - " lang("auto_exit.title"))
            tab := g.AddTab3("-Wrap", [lang("auto_exit.auto_exit_tab"), lang("common.about")])
            tab.UseTab(1)

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            addItem(state) {
                gc.%"LV_" state%.Opt("-Redraw")
                valueArr := StrSplit(readIniSection("App-Auto-" state), "`n")
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

                        tipGlobal := isGlobal ? lang("common.process_level") : lang("common.title_level")

                        tipRegex := isRegex ? lang("common.regex") : lang("common.equal")
                        gc.%"LV_" state%.Add(, name, tipGlobal, tipRegex, title, kv[1])
                    } else {
                        IniDelete("InputTip.ini", "App-Auto-" state, kv[1])
                    }
                }
                gc.%"LV_" state%.Opt("+Redraw")
                gc.%state "_title"%.Text := lang("switch_window.count_prefix") gc.%"LV_" state%.GetCount() lang("switch_window.count_suffix")
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
                    status: getStateName(from),
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
                if (action == "edit") {
                    actionText := lang("common.edit")
                } else {
                    actionText := lang("common.add")
                }

                label := (action == "add" ? lang("gui.adding_rule") : lang("gui.editing_rule")) " - " getStateName(from) lang("auto_exit.rule_label")

                g := createGuiOpt("InputTip - " label)

                if (info.i) {
                    g.AddText(, gui_width_line)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                scaleWidth := bw / 1.5
                g.AddText(, lang("gui.process_name_label"))
                _ := g.AddEdit("yp w" scaleWidth, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
                }

                g.AddText("xs", lang("auto_exit.action_type_label"))
                _ := g.AddDropDownList("yp Disabled w" scaleWidth, [lang("auto_exit.action_pause"), lang("auto_exit.action_exit")])
                _.Text := itemValue.status
                _.OnEvent("Change", e_changeState)
                e_changeState(item, *) {
                    v := item.Text
                    itemValue.status := v
                }

                g.AddText("xs", lang("gui.match_scope_label"))
                _ := g.AddDropDownList("yp w" scaleWidth, [lang("common.process_level"), lang("common.title_level")])
                _.Text := itemValue.tipGlobal
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.tipGlobal := v
                }

                g.AddText("xs cGray", lang("gui.match_scope_tip"))
                g.AddText("xs", lang("gui.match_mode_label"))
                _ := g.AddDropDownList("yp w" scaleWidth, [lang("common.equal"), lang("common.regex")])
                _.Text := itemValue.tipRegex
                _.OnEvent("Change", e_changeMatch)
                e_changeMatch(item, *) {
                    v := item.Text
                    itemValue.tipRegex := v
                }

                g.AddText("xs", lang("gui.match_title_label"))
                _ := g.AddEdit("yp w" scaleWidth)
                _.Text := itemValue.title
                _.OnEvent("Change", e_changeTitle)
                e_changeTitle(item, *) {
                    v := item.Text
                    itemValue.title := v
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
                            IniDelete("InputTip.ini", "App-Auto-" from, itemValue.id)
                            LV.Delete(RowNumber)
                            gc.%from "_title"%.Text := lang("switch_window.count_prefix") gc.%"LV_" from%.GetCount() lang("switch_window.count_suffix")
                        }
                    } else {
                        isGlobal := itemValue.tipGlobal == lang("common.process_level") ? 1 : 0
                        isRegex := itemValue.tipRegex == lang("common.regex") ? 1 : 0
                        value := itemValue.exe_name ":" isGlobal ":" isRegex ":" itemValue.title
                        ; 没有进行移动
                        if (itemValue.status == from) {
                            writeIni(itemValue.id, value, "App-Auto-" from, "InputTip.ini")
                            LV.Modify(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.id)
                        } else {
                            try {
                                IniDelete("InputTip.ini", "App-Auto-" from, itemValue.id)
                                LV.Delete(RowNumber)
                                gc.%from "_title"%.Text := lang("switch_window.count_prefix") gc.%"LV_" from%.GetCount() lang("switch_window.count_suffix")
                            }
                            state := stateTextMap[itemValue.status]
                            writeIni(itemValue.id, value, "App-Auto-" state, "InputTip.ini")
                            gc.%"LV_" state%.Insert(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.id)
                            gc.%state "_title"%.Text := lang("switch_window.count_prefix") gc.%"LV_" state%.GetCount() lang("switch_window.count_suffix")
                        }
                    }
                    try {
                        autoHdrLV(gc.%"LV_" state%)
                    }
                    global app_AutoExit := StrSplit(readIniSection("App-Auto-Exit"), "`n")
                }
                return g
            }

            for i, v in ["Exit"] {
                g.AddText("Section cRed", lang("gui.help_tip"))
                g.AddText("Section", lang("auto_exit.need_auto") " " getStateName(v) " InputTip ")
                g.AddText("yp", lang("switch_window.app_window"))
                gc.%v "_title"% := g.AddText("yp cRed w" bw / 3, lang("switch_window.count_prefix") "0" lang("switch_window.count_suffix"))

                LV := "LV_" v
                gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, [lang("switch_window.lv_process"), lang("switch_window.lv_scope"), lang("switch_window.lv_mode"), lang("switch_window.lv_title"), lang("switch_window.lv_time")])
                addItem(v)
                autoHdrLV(gc.%LV%)
                gc.%LV%.OnEvent("DoubleClick", fn_dbClick)
                gc.%LV%._type := v

                _ := g.AddButton("xs w" w / 2, lang("common.quick_add"))
                _._LV := LV
                _._type := v
                _.OnEvent("Click", (item, *) => (fn_add(item._LV, item._type)))

                _ := g.AddButton("yp w" w / 2, lang("common.manual_add"))
                _._LV := LV
                _._type := v
                _.OnEvent("Click", fn_add_manually)

                tab.UseTab(i + 1)
            }
            fn_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    status: getStateName(item._type),
                    tipGlobal: lang("common.process_level"),
                    tipRegex: lang("common.equal"),
                    title: "",
                    id: returnId()
                }
                fn_edit(item._LV, 1, item._type, "add", itemValue).Show()
            }

            fn_add(LV, state) {
                args := {
                    title: lang("common.quick_add"),
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
                        status: getStateName(state),
                        tipGlobal: lang("common.process_level"),
                        tipRegex: lang("common.equal"),
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
                        status: getStateName(state),
                        tipGlobal: lang("common.process_level"),
                        tipRegex: lang("common.equal"),
                        title: windowInfo.title,
                        id: windowInfo.id,
                    }
                    fn_edit(LV, 1, state, "add", itemValue).Show()
                }
            }

            g.AddEdit("ReadOnly VScroll r12 w" w, lang("about_text.auto_exit"))
            g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/about-virus">Games may detect InputTip as virus/cheat</a>')

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
