; InputTip

fn_app_offset(*) {
    args := {
        title: lang("app_offset.title"),
        tab: lang("app_offset.list"),
        config: "App-Offset",
        about: lang("about_text.app_offset"),
        link: lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/app-offset">Special Offset</a>',
    }

    showGui()
    showGui(deep := 0) {
        createUniqueGui(commonGui).Show()
        commonGui(info) {
            g := createGuiOpt("InputTip - " args.title)
            tab := g.AddTab3("-Wrap", [args.tab, lang("common.about")])
            tab.UseTab(1)
            g.AddLink("Section cRed", lang("gui.help_tip"))

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            LV := "LV_" A_Now

            gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, [lang("common.process_name"), lang("common.match_scope"), lang("common.match_mode"), lang("common.match_title"), lang("app_offset.special_offset_col"), lang("common.create_time")])

            gc.%LV%.Opt("-Redraw")
            for v in AppOffset {
                kv := StrSplit(v, "=", , 2)
                part := StrSplit(kv[2], ":", , 5)
                if (part.Length >= 2) {
                    name := part[1]
                    isGlobal := part[2]
                    ; isRegex := ""
                    title := ""
                    offset := ""
                    if (part.Length == 5) {
                        ; isRegex := part[3]
                        offset := part[4]
                        title := part[5]
                    }

                    tipGlobal := isGlobal ? lang("common.process_level") : lang("common.title_level")
                    ; tipRegex := isRegex ? lang("common.regex") : lang("common.equal")
                    tipRegex := lang("common.equal")
                    gc.%LV%.Add(, name, tipGlobal, tipRegex, title, offset, kv[1])
                } else {
                    IniDelete("InputTip.ini", args.config, kv[1])
                }
            }
            gc.%LV%.Opt("+Redraw")
            autoHdrLV(gc.%LV%)

            gc.%LV%.OnEvent("DoubleClick", handleClick)
            gc.%LV%._LV := LV
            gc.%LV%._config := args.config
            _ := g.AddButton("xs w" w, lang("common.quick_add"))
            _.OnEvent("Click", e_add)
            _._LV := LV
            _._config := args.config
            _._parentTitle := args.title
            e_add(item, *) {
                try {
                    fn_add(item._LV, item._config, item._parentTitle)
                } catch {
                    fn_add(item._LV, item._config, "")
                }
            }

            _ := g.AddButton("xs w" w, lang("common.manual_add"))
            _.OnEvent("Click", e_add_manually)
            _._LV := LV
            _._config := args.config

            e_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    tipGlobal: lang("common.process_level"),
                    tipRegex: lang("common.equal"),
                    title: "",
                    id: returnId(),
                    configName: item._config
                }
                fn_edit(gc.%item._LV%, 1, "add", itemValue).Show()
            }

            g.AddButton("xs w" w, lang("app_offset.base_offset")).OnEvent("Click", e_baseOffset)
            e_baseOffset(*) {
                createUniqueGui(offsetScreenGui).Show()
                offsetScreenGui(info) {
                    g := createGuiOpt("InputTip - " lang("app_offset.base_offset_title"))
                    g.AddText("Section cRed", lang("app_offset.base_offset_tip"))
                    pages := []
                    for v in screenList {
                        pages.push(lang("app_offset.screen_label") v.num)
                    }
                    tab := g.AddTab3("xs -Wrap", pages)

                    for v in screenList {
                        tab.UseTab(v.num)
                        if (v.num = v.main) {
                            g.AddText(, lang("app_offset.screen_info") v.num " (Main)")
                        } else {
                            g.AddText(, lang("app_offset.screen_info") v.num)
                        }

                        g.AddText(, "Screen coords (X,Y): Top-left(" v.left ", " v.top "), Bottom-right(" v.right ", " v.bottom ")")

                        try {
                            x := app_offset_screen.%v.num%.x
                            y := app_offset_screen.%v.num%.y
                        } catch {
                            app_offset_screen.%v.num% := { x: 0, y: 0 }
                            x := 0, y := 0
                        }

                        g.AddText("Section", lang("app_offset.h_offset") ": ")
                        _ := g.AddEdit("yp")
                        _.Value := x
                        _.__num := v.num
                        _.OnEvent("Change", e_change_offset_x)
                        e_change_offset_x(item, *) {
                            static db := debounce((config, value) => (
                                writeIni(config, value, "App-Offset-Screen"),
                                updateAppOffset(),
                                restartJAB()
                            ))

                            if (item.value == "") {
                                item.value := 0
                            }

                            value := returnNumber(item.value)
                            app_offset_screen.%item.__num%.x := value
                            db(item.__num, value "/" app_offset_screen.%item.__num%.y)
                        }
                        g.AddText("xs", lang("app_offset.v_offset") ": ")
                        _ := g.AddEdit("yp")
                        _.Value := y
                        _.__num := v.num
                        _.OnEvent("Change", e_change_offset_y)
                        e_change_offset_y(item, *) {
                            static db := debounce((config, value) => (
                                writeIni(config, value, "App-Offset-Screen"),
                                updateAppOffset(),
                                restartJAB()
                            ))

                            if (item.value == "") {
                                item.value := 0
                            }

                            value := returnNumber(item.value)
                            app_offset_screen.%item.__num%.y := value
                            db(item.__num, app_offset_screen.%item.__num%.x "/" value)
                        }
                    }
                    tab.UseTab(0)
                    g.AddText("Section cGray", "See [About] tab in [Special Offset] for more screen info")

                    if (info.i) {
                        return g
                    }

                    g.OnEvent("Close", close)
                    close(*) {
                        g.Destroy()
                        for k, v in app_offset_screen.OwnProps() {
                            writeIni(k, v.x "/" v.y, "App-Offset-Screen")
                        }
                        updateAppOffset()
                        restartJAB()
                    }
                    return g
                }
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
                    tipGlobal: LV.GetText(RowNumber, 2),
                    tipRegex: LV.GetText(RowNumber, 3),
                    title: LV.GetText(RowNumber, 4),
                    offset: LV.GetText(RowNumber, 5),
                    id: LV.GetText(RowNumber, 6),
                    configName: LV._config
                }
                createGui(editGui).Show()
                editGui(info) {
                    return fn_edit(gc.%LV._LV%, RowNumber, "edit", itemValue)
                }
            }

            fn_edit(LV, RowNumber, action, itemValue) {
                ; 是否自动添加到符号的白名单中
                needAddWhiteList := 1

                label := (action == "add" ? lang("gui.adding_rule") : lang("gui.editing_rule"))

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

                scaleWidth := bw / 1.5

                g.AddText(, lang("gui.process_name_label"))
                _ := g.AddEdit("yp w" scaleWidth, "")
                _.Text := itemValue.exe_name
                _.OnEvent("Change", e_changeName)
                e_changeName(item, *) {
                    v := item.Text
                    itemValue.exe_name := v
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
                _ := g.AddDropDownList("Disabled yp w" scaleWidth, [lang("common.equal"), lang("common.regex")])
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

                screenList := getScreenInfo()
                app := itemValue.exe_name

                pages := []
                for v in screenList {
                    pages.push(lang("app_offset.screen_label") v.num)
                }
                tab := g.AddTab3("xs -Wrap w" bw / 1.2, pages)
                key := itemValue.tipGlobal == lang("common.process_level") ? app : app itemValue.title

                try {
                    _ := app_offset.%key%
                } catch {
                    app_offset.%key% := {}
                }

                for v in screenList {
                    tab.UseTab(v.num)
                    if (v.num = v.main) {
                        g.AddText(, lang("app_offset.main_screen") v.num)
                    } else {
                        g.AddText(, lang("app_offset.secondary_screen") v.num)
                    }

                    g.AddText(, lang("app_offset.screen_coords") "(" v.left ", " v.top "), (" v.right ", " v.bottom ")")

                    x := 0, y := 0

                    if (action == "edit") {
                        try {
                            x := app_offset.%key%.%v.num%.x
                            y := app_offset.%key%.%v.num%.y
                        } catch {
                            app_offset.%key%.%v.num% := { x: 0, y: 0 }
                        }
                    } else {
                        app_offset.%key%.%v.num% := { x: 0, y: 0 }
                    }

                    g.AddText("Section", lang("app_offset.h_offset_label"))
                    _ := g.AddEdit("yp")
                    _.Value := x
                    _.__num := v.num
                    _._itemValue := itemValue
                    _.OnEvent("Change", e_change_offset_x)
                    _.OnEvent("LoseFocus", e_change_offset_x)
                    g.AddText("xs", lang("app_offset.v_offset_label"))
                    _ := g.AddEdit("yp")
                    _.Value := y
                    _.__num := v.num
                    _._itemValue := itemValue
                    _.OnEvent("Change", e_change_offset_y)
                    _.OnEvent("LoseFocus", e_change_offset_y)
                }
                e_change_offset_x(item, *) {
                    itemValue := item._itemValue
                    key := itemValue.tipGlobal == lang("common.process_level") ? app : app itemValue.title
                    try {
                        app_offset.%key%.%item.__num%.x := returnNumber(item.value)
                    } catch {
                        return
                    }

                    if (item.Focused) {
                        return
                    }

                    itemValue.offset := ""
                    for v in app_offset.%key%.OwnProps() {
                        itemValue.offset .= "|" v "/" app_offset.%key%.%v%.x "/" app_offset.%key%.%v%.y
                    }
                    itemValue.offset := SubStr(itemValue.offset, 2)
                }
                e_change_offset_y(item, *) {
                    itemValue := item._itemValue
                    key := itemValue.tipGlobal == lang("common.process_level") ? app : app itemValue.title
                    try {
                        app_offset.%key%.%item.__num%.y := returnNumber(item.value)
                    } catch {
                        return
                    }

                    if (item.Focused) {
                        return
                    }

                    itemValue.offset := ""
                    for v in app_offset.%key%.OwnProps() {
                        itemValue.offset .= "|" v "/" app_offset.%key%.%v%.x "/" app_offset.%key%.%v%.y
                    }
                    itemValue.offset := SubStr(itemValue.offset, 2)
                }
                tab.UseTab(0)
                g.AddText("Section cGray", lang("app_offset.screen_distinguish_tip"))

                g.AddButton("Section w" bw / 1.2, (action == "add" ? lang("common.complete_add") : lang("common.complete_edit"))).OnEvent("Click", e_set)
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
                            IniDelete("InputTip.ini", itemValue.configName, itemValue.id)
                            LV.Delete(RowNumber)
                        }
                    } else {
                        isGlobal := itemValue.tipGlobal == lang("common.process_level") ? 1 : 0
                        ; isRegex := itemValue.tipRegex == "正则" ? 1 : 0
                        isRegex := 0
                        try {
                            _ := itemValue.offset
                        } catch {
                            itemValue.offset := ""
                            screenList := getScreenInfo()
                            for v in screenList {
                                itemValue.offset .= "|" v.num "/0/0"
                            }
                            itemValue.offset := SubStr(itemValue.offset, 2)
                        }

                        value := itemValue.exe_name ":" isGlobal ":" isRegex ":" itemValue.offset ":" itemValue.title
                        writeIni(itemValue.id, value, itemValue.configName, "InputTip.ini")

                        if (action == "edit") {
                            LV.Modify(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.offset, itemValue.id)
                        } else {
                            LV.Insert(RowNumber, , itemValue.exe_name, itemValue.tipGlobal, itemValue.tipRegex, itemValue.title, itemValue.offset, itemValue.id)
                        }

                        if (needAddWhiteList) {
                            updateWhiteList(itemValue.exe_name)
                        }
                    }

                    autoHdrLV(LV)

                    updateAppOffset()
                    restartJAB()
                }
                return g
            }

            fn_add(parentLV, configName, parentTitle) {
                args := {
                    title: parentTitle " - " lang("common.quick_add"),
                    configName: configName,
                    LV: parentLV,
                }
                createProcessListGui(args, addClick, e_add_manually)

                addClick(args) {
                    windowInfo := args.windowInfo
                    RowNumber := args.RowNumber

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        tipGlobal: lang("common.process_level"),
                        tipRegex: lang("common.equal"),
                        title: windowInfo.title,
                        id: windowInfo.id,
                        configName: args.parentArgs.configName
                    }
                    fn_edit(gc.%args.parentArgs.LV%, RowNumber, "add", itemValue).Show()
                }

                e_add_manually(args) {
                    windowInfo := args.windowInfo

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        tipGlobal: lang("common.process_level"),
                        tipRegex: lang("common.equal"),
                        title: windowInfo.title,
                        offset: "",
                        id: windowInfo.id,
                        configName: args.parentArgs.configName
                    }
                    fn_edit(gc.%args.parentArgs.LV%, 1, "add", itemValue).Show()
                }
            }
            tab.UseTab(2)
            g.AddEdit("Section r15 w" w, args.about)
            g.AddLink(, args.link)
            return g
        }
    }
}
