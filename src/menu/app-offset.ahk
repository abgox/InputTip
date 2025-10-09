; InputTip

fn_app_offset(*) {
    args := {
        title: "特殊偏移量",
        tab: "特殊偏移量列表",
        config: "App-Offset",
        about: '1. 简要说明`n   - 这个菜单用来配置【特殊偏移量列表】的匹配规则`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】`n   - 【进程级】: 只要在这个进程中时，就会触发`n   - 【标题级】: 只有在这个进程中，且标题匹配成功时，才会触发`n`n4. 规则列表 —— 匹配模式`n   - 它控制标题匹配的模式，只有当匹配范围为【标题级】时，才会生效`n   - 目前在【特殊偏移量】中只能使用【相等】`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发`n   - 【正则】: 使用正则表达式匹配标题，匹配成功则触发自动切换`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式，与【匹配模式】相对应`n   - 如果不知道当前窗口的相关信息(进程/标题等)，可以通过以下方式获取`n      - 【托盘菜单】=>【获取窗口信息】`n`n6.  规则列表 —— 特殊偏移量`n   - 这里显示的是特殊偏移量的原始字符串格式: 屏幕标识/X/Y，并以 | 分割`n   - 举个例子: 1/10/20|2/30/40`n     - 在屏幕 1 中，水平偏移 10，垂直偏移 20`n     - 在屏幕 2 中，水平偏移 30，垂直偏移 40`n   - 你也不需要纠结这个格式，因为当你双击进行编辑时，会通过配置菜单来设置它`n`n   - 需要特别注意:`n     - 如果是 JAB 程序的【特殊偏移量】设置，需要保存修改后才会生效`n     - 保存操作：点击【完成添加】【完成编辑】或其他相关按钮`n`n7. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n8. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n9. 按钮 —— 快捷添加`n   - 点击它，可以添加一条新的规则`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n10. 按钮 —— 手动添加`n   - 点击它，可以添加一条新的规则`n   - 它会直接弹出添加窗口，你需要手动填写进程名称、标题、偏移量等信息`n`n11. 按钮 —— 设置不同屏幕下的基础偏移量`n   - 它会弹出一个新的配置界面，用来设置不同屏幕下的基础偏移量`n   - 偏移量的计算方式: 符号偏移量 + 不同屏幕的基础偏移量 + 特殊偏移量`n   - 符号偏移量: 所使用的符号(图片/方块/文本)的偏移量配置`n`n12. 如何设置偏移量？`n   - 当双击任意应用进程后，会弹出偏移量设置窗口`n   - 通过屏幕标识和坐标信息，判断是哪一块屏幕，然后设置对应的偏移量`n   - 如何通过坐标信息判断屏幕？`n      - 假设你有两块屏幕，主屏幕在左边，副屏幕在右边`n      - 那么副屏幕的左上角 X 坐标一定大于或等于主屏幕的右下角 X 坐标',
        link: '相关链接: <a href="https://inputtip.abgox.com/faq/app-offset">特殊偏移量</a>',
    }

    showGui()
    showGui(deep := 0) {
        createUniqueGui(commonGui).Show()
        commonGui(info) {
            g := createGuiOpt("InputTip - " args.title)
            tab := g.AddTab3("-Wrap", [args.tab, "关于"])
            tab.UseTab(1)
            g.AddLink("Section cRed", gui_help_tip)

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            LV := "LV_" A_Now

            gc.%LV% := g.AddListView("xs -LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, ["进程名称", "匹配范围", "匹配模式", "匹配标题", "特殊偏移量", "创建时间"])

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

                    tipGlobal := isGlobal ? "进程级" : "标题级"
                    ; tipRegex := isRegex ? "正则" : "相等"
                    tipRegex := "相等"
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
            _ := g.AddButton("xs w" w, "快捷添加")
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

            _ := g.AddButton("xs w" w, "手动添加")
            _.OnEvent("Click", e_add_manually)
            _._LV := LV
            _._config := args.config

            e_add_manually(item, *) {
                itemValue := {
                    exe_name: "",
                    tipGlobal: "进程级",
                    tipRegex: "相等",
                    title: "",
                    id: returnId(),
                    configName: item._config
                }
                fn_edit(gc.%item._LV%, 1, "add", itemValue).Show()
            }

            g.AddButton("xs w" w, "设置不同屏幕下的基础偏移量").OnEvent("Click", e_baseOffset)
            e_baseOffset(*) {
                createUniqueGui(offsetScreenGui).Show()
                offsetScreenGui(info) {
                    g := createGuiOpt("InputTip - 设置不同屏幕下的基础偏移量")
                    g.AddText("Section cRed", "- 设置不同屏幕下的基础偏移量`n- 点击右上角的 x 关闭此窗口后，基础偏移量才会完全生效")
                    pages := []
                    for v in screenList {
                        pages.push("屏幕 " v.num)
                    }
                    tab := g.AddTab3("xs -Wrap", pages)

                    for v in screenList {
                        tab.UseTab(v.num)
                        if (v.num = v.main) {
                            g.AddText(, "这是主屏幕(主显示器)，屏幕标识: " v.num)
                        } else {
                            g.AddText(, "这是副屏幕(副显示器)，屏幕标识: " v.num)
                        }

                        g.AddText(, "屏幕坐标信息(X,Y): 左上角(" v.left ", " v.top ")，右下角(" v.right ", " v.bottom ")")

                        try {
                            x := app_offset_screen.%v.num%.x
                            y := app_offset_screen.%v.num%.y
                        } catch {
                            app_offset_screen.%v.num% := { x: 0, y: 0 }
                            x := 0, y := 0
                        }

                        g.AddText("Section", "水平方向的偏移量: ")
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
                        g.AddText("xs", "垂直方向的偏移量: ")
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
                    g.AddText("Section cGray", "如果不知道如何区分屏幕，可查看【特殊偏移量】中的【关于】")

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

                if (action == "edit") {
                    actionText := "编辑"
                } else {
                    actionText := "添加"
                }

                label := "正在" actionText "规则"

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

                g.AddText("xs", "2. 匹配范围: ")
                _ := g.AddDropDownList("yp w" scaleWidth, ["进程级", "标题级"])
                _.Text := itemValue.tipGlobal
                _.OnEvent("Change", e_changeLevel)
                e_changeLevel(item, *) {
                    v := item.Text
                    itemValue.tipGlobal := v
                }

                g.AddText("xs cGray", "【匹配模式】和【匹配标题】仅在【匹配范围】为【标题级】时有效")
                g.AddText("xs", "3. 匹配模式: ")
                _ := g.AddDropDownList("Disabled yp w" scaleWidth, ["相等", "正则"])
                _.Text := itemValue.tipRegex
                _.OnEvent("Change", e_changeMatch)
                e_changeMatch(item, *) {
                    v := item.Text
                    itemValue.tipRegex := v
                }

                g.AddText("xs", "4. 匹配标题: ")
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
                    pages.push("屏幕 " v.num)
                }
                tab := g.AddTab3("xs -Wrap w" bw / 1.2, pages)
                key := itemValue.tipGlobal == "进程级" ? app : app itemValue.title

                try {
                    _ := app_offset.%key%
                } catch {
                    app_offset.%key% := {}
                }

                for v in screenList {
                    tab.UseTab(v.num)
                    if (v.num = v.main) {
                        g.AddText(, "这是主屏幕(主显示器)，屏幕标识: " v.num)
                    } else {
                        g.AddText(, "这是副屏幕(副显示器)，屏幕标识: " v.num)
                    }

                    g.AddText(, "屏幕坐标信息(X,Y): 左上角(" v.left ", " v.top ")，右下角(" v.right ", " v.bottom ")")

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

                    g.AddText("Section", "水平方向的偏移量: ")
                    _ := g.AddEdit("yp")
                    _.Value := x
                    _.__num := v.num
                    _._itemValue := itemValue
                    _.OnEvent("Change", e_change_offset_x)
                    _.OnEvent("LoseFocus", e_change_offset_x)
                    g.AddText("xs", "垂直方向的偏移量: ")
                    _ := g.AddEdit("yp")
                    _.Value := y
                    _.__num := v.num
                    _._itemValue := itemValue
                    _.OnEvent("Change", e_change_offset_y)
                    _.OnEvent("LoseFocus", e_change_offset_y)
                }
                e_change_offset_x(item, *) {
                    itemValue := item._itemValue
                    key := itemValue.tipGlobal == "进程级" ? app : app itemValue.title
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
                    key := itemValue.tipGlobal == "进程级" ? app : app itemValue.title
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
                g.AddText("Section cGray", "如果不知道如何区分屏幕，可查看【特殊偏移量】中的【关于】")

                g.AddButton("Section w" bw / 1.2, "完成" actionText).OnEvent("Click", e_set)
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
                            IniDelete("InputTip.ini", itemValue.configName, itemValue.id)
                            LV.Delete(RowNumber)
                        }
                    } else {
                        isGlobal := itemValue.tipGlobal == "进程级" ? 1 : 0
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
                    title: parentTitle " - 快捷添加",
                    configName: configName,
                    LV: parentLV,
                }
                createProcessListGui(args, addClick, e_add_manually)

                addClick(args) {
                    windowInfo := args.windowInfo
                    RowNumber := args.RowNumber

                    itemValue := {
                        exe_name: windowInfo.exe_name,
                        tipGlobal: "进程级",
                        tipRegex: "相等",
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
                        tipGlobal: "进程级",
                        tipRegex: "相等",
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
