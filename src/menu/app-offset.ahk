; InputTip

fn_app_offset(*) {
    tipList := {
        gui: "appOffsetGui",
        config: "app_offset",
        tab: ["设置特殊偏移量", "关于"],
        tip: gui_help_tip,
        list: "特殊偏移量列表",
        color: "cRed",
        about: '1. 简要说明`n   - 这个菜单用来配置应用进程在不同屏幕中的符号显示偏移量`n`n   - 上方是当前系统正在运行的【应用进程列表】`n   - 双击列表中任意一行，就可以将其添加到【特殊偏移量列表】中`n`n   - 下方是【特殊偏移量列表】，可以设置指定应用在不同屏幕下的符号显示偏移量`n   - 双击列表中任意应用进程，会弹出偏移量设置窗口，可以编辑或移除`n`n2. 应用进程列表 —— 进程名称`n   - 应用程序实际运行的进程名称`n   - 如果不清楚是哪个应用的进程，可能需要通过【窗口标题】、【文件路径】来判断`n   - 或者使用第 6 点的技巧`n`n3. 应用进程列表 —— 来源`n   - 【系统】表明这个进程是从系统中获取的，它正在运行`n   - 【白名单】表明这个进程是存在于白名单中的，为了方便操作，被添加到列表中`n`n4. 应用进程列表 —— 窗口标题`n   - 这个应用进程所显示的窗口的标题`n   - 你可能需要通过它来判断这是哪一个应用的进程`n`n5. 应用进程列表 —— 文件路径`n   - 这个应用进程的可执行文件的所在路径`n   - 你可能需要通过它来判断这是哪一个应用的进程`n`n6. 技巧 —— 获取当前窗口的实时的相关进程信息`n   - 你可以使用【托盘菜单】中的【获取当前窗口相关进程信息】`n   - 它会实时获取当前激活的窗口的【进程名称】【窗口标题】【文件路径】`n`n7. 按钮 —— 刷新此界面`n   - 因为列表中显示的是当前正在运行的应用进程`n   - 如果你是先打开这个配置菜单，再打开对应的应用，它不会显示在这里`n   - 你需要重新打开这个配置菜单，或者点击这个按钮进行刷新`n`n8. 按钮 —— 手动添加`n   - 在【应用进程列表】中，可能没有你想要添加的进程，你需要点击这个按钮手动添加`n   - 可以配合第 6 点的技巧，让手动添加更方便`n`n9. 按钮 —— 显示更多进程`n   - 默认情况下，【应用进程列表】中显示的是前台应用进程，就是有窗口的应用进程`n   - 你可以点击它来显示更多的进程，比如后台进程`n`n10. 按钮 —— 显示更少进程`n   - 当你点击【显示更多进程】按钮后，会出现这个按钮`n   - 点击它又会重新显示前台应用进程`n`n11. 按钮 —— 设置不同屏幕下的基础偏移量`n   - 它会弹出一个新的配置界面，用来设置不同屏幕下的基础偏移量`n   - 偏移量的计算方式: 符号偏移量 + 不同屏幕的基础偏移量 + 特殊偏移量`n   - 符号偏移量: 所使用的符号(图片/方块/文本)的偏移量配置`n`n12. 如何设置偏移量？`n   - 当双击任意应用进程后，会弹出偏移量设置窗口`n   - 通过屏幕标识和坐标信息，判断是哪一块屏幕，然后设置对应的偏移量`n   - 偏移量的修改实时生效，你可以立即在对应窗口中看到效果`n   - 如何通过坐标信息判断屏幕？`n      - 假设你有两块屏幕，主屏幕在左边，副屏幕在右边`n      - 那么副屏幕的左上角 X 坐标一定大于或等于主屏幕的右下角 X 坐标',
        link: '相关链接: <a href="https://inputtip.abgox.com/FAQ/app-offset">关于特殊偏移量</a>',
    }

    addClickFn(LV, RowNumber, tipList) {
        handleClick(LV, RowNumber, tipList, "add")
    }
    rmClickFn(LV, RowNumber, tipList) {
        handleClick(LV, RowNumber, tipList, "rm")
    }
    addFn(tipList) {
        addApp("xxx.exe")
        addApp(v) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            createGui(addGui).Show()
            addGui(info) {
                g := createGuiOpt("InputTip - 设置特殊偏移量 - 手动添加")
                text := "每次只能添加一个应用进程名称`n如果它不在白名单中，则会以【进程级】自动添加到白名单中"
                g.AddText("cRed", text)
                g.AddText("Section", "应用进程名称: ")

                if (info.i) {
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                gc._exe_name := g.AddEdit("yp")
                gc._exe_name.Value := v
                g.AddButton("xs w" bw, "添加").OnEvent("Click", e_yes)
                e_yes(*) {
                    exe_name := gc._exe_name.value
                    g.Destroy()
                    if (!RegExMatch(exe_name, "^.*\.\w{3}$") || RegExMatch(exe_name, '[\\/:*?\"<>|]')) {
                        if (gc.w.subGui) {
                            gc.w.subGui.Destroy()
                            gc.w.subGui := ""
                        }
                        createGui(errGui).Show()
                        errGui(info) {
                            g := createGuiOpt("InputTip - 警告")
                            g.AddText("cRed", exe_name)
                            g.AddText("yp", "是一个错误的应用进程名称")
                            g.AddText("xs cRed", '正确的应用进程名称是 xxx.exe 这样的格式`n同时文件名中不能包含这些英文符号 \ / : * ? " < >|')

                            if (info.i) {
                                return g
                            }
                            w := info.w
                            bw := w - g.MarginX * 2

                            y := g.AddButton("xs w" bw, "重新输入")
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
                    isExist := 0
                    for v in app_offset.OwnProps() {
                        if (v = exe_name) {
                            isExist := 1
                            break
                        }
                    }
                    if (isExist) {
                        if (gc.w.subGui) {
                            gc.w.subGui.Destroy()
                            gc.w.subGui := ""
                        }
                        createGui(existGui).Show()
                        existGui(info) {
                            g := createGuiOpt("InputTip - 警告")
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
                    } else {
                        handleClick("", 1, tipList, "input", exe_name)
                    }
                }
                gc.w.subGui := g
                return g
            }
        }
    }

    handleClick(LV, RowNumber, tipList, action, app := "") {
        if (!RowNumber) {
            return
        }
        fn_write_offset() {
            try {
                gc.appOffsetGui_LV_rm_title.Text := "特殊偏移量列表 ( " gc.appOffsetGui_LV_rm.GetCount() " 个 )"
            }
            _app_offset := ""
            for v in app_offset.OwnProps() {
                _info := v "|"
                for s in app_offset.%v%.OwnProps() {
                    _info .= s "/" app_offset.%v%.%s%.x "/" app_offset.%v%.%s%.y "*"
                }
                _app_offset .= ":" SubStr(_info, 1, StrLen(_info) - 1)
            }
            writeIni("app_offset", SubStr(_app_offset, 2))
            restartJAB()
        }

        global app_offset
        screenList := getScreenInfo()
        if (action != "input") {
            app := LV.GetText(RowNumber)
        }
        if (action = "add" || action = "input") {
            isExist := 0
            for v in app_offset.OwnProps() {
                if (v = app) {
                    isExist := 1
                    break
                }
            }
            if (!isExist) {
                gc.appOffsetGui_LV_rm.Add(, app)
                autoHdrLV(gc.appOffsetGui_LV_rm)
            }
            if (action = "add") {
                LV.Delete(RowNumber)
                autoHdrLV(LV)
            }
            app_offset.%app% := {}
            for v in screenList {
                app_offset.%app%.%v.num% := { x: 0, y: 0 }
            }
            SetTimer(timer, -1)
            timer(*) {
                fn_write_offset()
                updateWhiteList(app)
            }
        }

        createUniqueGui(setOffsetGui).Show()
        setOffsetGui(info) {
            g := createGuiOpt("InputTip - 设置 " app " 的特殊偏移量")
            g.AddText(, "正在设置")
            g.AddText("yp cRed", app)
            g.AddText("yp", "的特殊偏移量")
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

                x := 0, y := 0
                try {
                    x := app_offset.%app%.%v.num%.x
                    y := app_offset.%app%.%v.num%.y
                } catch {
                    app_offset.%app%.%v.num% := { x: 0, y: 0 }
                }

                g.AddText("Section", "水平方向的偏移量: ")
                _ := g.AddEdit("yp")
                _.Value := x
                _.__num := v.num
                _.OnEvent("Change", e_change_offset_x)
                e_change_offset_x(item, *) {
                    app_offset.%app%.%item.__num%.x := returnNumber(item.value)
                    fn_write_offset()
                }
                g.AddText("xs", "垂直方向的偏移量: ")
                _ := g.AddEdit("yp")
                _.Value := y
                _.__num := v.num
                _.OnEvent("Change", e_change_offset_y)
                e_change_offset_y(item, *) {
                    app_offset.%app%.%item.__num%.y := returnNumber(item.value)
                    fn_write_offset()
                }
            }

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            tab.UseTab(0)
            if (action = "rm") {
                _ := g.AddButton("Section w" bw, "将它移除")
                _.OnEvent("Click", e_rm)
                e_rm(*) {
                    close()
                    exe_name := LV.GetText(RowNumber)
                    LV.Delete(RowNumber)
                    autoHdrLV(LV)
                    try {
                        gc.%tipList.gui "_LV_add"%.Add(, exe_name, WinGetTitle("ahk_exe " exe_name))
                        autoHdrLV(gc.%tipList.gui "_LV_add"%)
                    }
                    app_offset.DeleteProp(app)
                    fn_write_offset()
                }
            }
            _ := g.AddButton("Section w" bw, "批量设置")
            _._exe_name := app
            _.OnEvent("Click", e_setAll)
            e_setAll(item, *) {
                close()
                createUniqueGui(setAllGui).Show()
                setAllGui(info) {
                    offset := { x: 0, y: 0 }
                    g := createGuiOpt("InputTip - 批量设置 " item._exe_name " 在多个屏幕的特殊偏移量")
                    g.AddText("cRed", "如果偏移量为空，将自动设置为 0")

                    if (info.i) {
                        return g
                    }

                    g.AddText("Section", "水平方向的偏移量: ")
                    _ := g.AddEdit("yp")
                    _.Value := 0
                    _._o := "x"
                    _.OnEvent("Change", e_change_offset)

                    g.AddText("xs", "垂直方向的偏移量: ")
                    _ := g.AddEdit("yp")
                    _.Value := 0
                    _._o := "y"
                    _.OnEvent("Change", e_change_offset)
                    e_change_offset(item, *) {
                        offset.%item._o% := item.value
                    }
                    g.AddText("xs cRed", "所有勾选的屏幕将使用上方的偏移量设置")

                    flag := 0
                    for i, v in screenList {
                        opt := i = 1 ? "xs" : "yp"
                        if (flag = 5) {
                            opt := "xs"
                            flag := 0
                        }
                        _ := g.AddCheckbox(opt " v" v.num, "屏幕 " v.num)
                        _.Value := 1
                        _._v_num := v.num
                        _.OnEvent("Click", e_check)
                        e_check(item, *) {
                            offset.%item._v_num% := item.Value
                        }
                        flag++
                    }
                    g.AddButton("xs w" w, "确认").OnEvent("Click", e_yes)
                    e_yes(item, *) {
                        info := g.Submit()
                        for v in screenList {
                            if (info.%v.num%) {
                                app_offset.%app%.%v.num%.x := returnNumber(offset.x)
                                app_offset.%app%.%v.num%.y := returnNumber(offset.y)
                            }
                        }
                        fn_write_offset()
                    }
                    return g
                }
            }
            g.OnEvent("Close", close)
            close(*) {
                g.Destroy()
            }
            return g
        }
    }

    showGui()
    showGui(deep := 0) {
        createUniqueGui(commonGui).Show()
        commonGui(info) {
            g := createGuiOpt("InputTip - 配置")
            tab := g.AddTab3("-Wrap", tipList.tab)
            tab.UseTab(1)
            g.AddLink("Section cRed", tipList.tip)

            if (info.i) {
                g.AddText(, gui_width_line)
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            tabs := ["进程名称", "来源", "窗口标题", "应用进程文件所在位置"]
            _gui := tipList.gui

            LV_add := gc.%_gui "_LV_add"% := g.AddListView("-LV0x10 -Multi r7 NoSortHdr Sort Grid w" w, tabs)
            LV_add.OnEvent("DoubleClick", e_add_dbClick)
            e_add_dbClick(LV, RowNumber) {
                addClickFn(LV, RowNumber, tipList)
            }
            res := ":"
            for v in app_offset.OwnProps() {
                res .= v ":"
            }
            temp := ":"
            DetectHiddenWindows deep
            LV_add.Opt("-Redraw")
            for v in WinGetList() {
                try {
                    exe_name := ProcessGetName(WinGetPID("ahk_id " v))
                    exe_str := ":" exe_name ":"
                    if (!InStr(temp, exe_str) && !InStr(res, exe_str)) {
                        temp .= exe_name ":"
                        LV_add.Add(, exe_name, "系统", WinGetTitle("ahk_id " v), WinGetProcessPath("ahk_id " v))
                    }
                }
            }

            for v in StrSplit(readIniSection("App-ShowSymbol"), "`n") {
                kv := StrSplit(v, "=", , 2)
                part := StrSplit(kv[2], ":", , 2)
                try {
                    name := part[1]
                    if (!InStr(temp, ":" name ":") && !InStr(res, ":" name ":")) {
                        temp .= name ":"
                        LV_add.Add(, name, "白名单")
                    }
                }
            }

            LV_add.Opt("+Redraw")
            DetectHiddenWindows 1
            autoHdrLV(LV_add)

            gc.%_gui "_LV_rm_title"% := g.AddText("w" w, tipList.list)
            LV_rm := gc.%_gui "_LV_rm"% := g.AddListView("xs -Hdr -LV0x10 -Multi r8 NoSortHdr Sort Grid w" w / 2 " " tipList.color, [tipList.list])
            valueArr := StrSplit(readIni(tipList.config, ""), ":")
            temp := ":"
            LV_rm.Opt("-Redraw")
            for v in valueArr {
                if (Trim(v) && !InStr(temp, ":" v ":")) {
                    LV_rm.Add(, StrSplit(v, "|")[1])
                    temp .= v ":"
                }
            }
            LV_rm.Opt("+Redraw")
            gc.%_gui "_LV_rm_title"%.Text := tipList.list " ( " LV_rm.GetCount() " 个 )"

            autoHdrLV(LV_rm)
            LV_rm.OnEvent("DoubleClick", e_rm_dbClick)
            e_rm_dbClick(LV, RowNumber) {
                rmClickFn(LV, RowNumber, tipList)
            }
            g.AddButton("Section yp w" w / 2, "刷新此界面").OnEvent("Click", e_refresh)
            e_refresh(*) {
                fn_close()
                showGui(deep)
            }
            g.AddButton("xs w" w / 2, "手动添加").OnEvent("Click", e_add_by_hand)
            e_add_by_hand(*) {
                addFn(tipList)
            }
            if (deep) {
                g.AddButton("xs w" w / 2, "显示更少进程").OnEvent("Click", e_less_window)
                e_less_window(*) {
                    fn_close()
                    showGui(0)
                }
            } else {
                g.AddButton("xs w" w / 2, "显示更多进程").OnEvent("Click", e_more_window)
                e_more_window(*) {
                    fn_close()
                    showGui(1)
                }
            }
            g.AddButton("xs w" w / 2, "设置不同屏幕下的基础偏移量").OnEvent("Click", e_clear)
            e_clear(*) {
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
                            app_offset_screen.%item.__num%.x := returnNumber(item.value)
                        }
                        g.AddText("xs", "垂直方向的偏移量: ")
                        _ := g.AddEdit("yp")
                        _.Value := y
                        _.__num := v.num
                        _.OnEvent("Change", e_change_offset_y)
                        e_change_offset_y(item, *) {
                            app_offset_screen.%item.__num%.y := returnNumber(item.value)
                        }
                    }
                    tab.UseTab(0)
                    g.AddText("Section cGray", "如果不知道如何区分屏幕，可查看【设置特殊偏移量】中的【关于】")

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
            autoHdrLV(LV_add)
            tab.UseTab(2)
            g.AddEdit("ReadOnly VScroll r19 w" w, tipList.about)
            if (tipList.link) {
                g.AddLink(, tipList.link)
            }
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
