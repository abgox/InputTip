fn_app_offset(*) {
    fn_common({
        gui: "appOffsetGui",
        config: "app_offset",
        tab: ["设置特殊偏移量", "关于"],
        tip: "你首先应该点击上方的「关于」查看具体的操作说明                                         ",
        list: "特殊偏移量列表",
        color: "cRed",
        about: '1. 如何使用这个管理面板？`n   - 最上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 为了便于操作，白名单中的应用进程也会添加到列表中`n   - 双击列表中任意应用进程，就可以将其添加到「特殊偏移量列表」中`n   - 如果需要更多的进程，请点击右下角的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击右下角的「通过输入进程名称手动添加」直接添加进程名称`n`n   - 下方是「特殊偏移量列表」，可以设置指定应用在不同屏幕下的符号显示偏移量`n   - 双击列表中任意应用进程，会弹出偏移量设置窗口，或者点击窗口底部按钮移除它`n`n2. 如何设置偏移量？`n   - 当双击任意应用进程后，会弹出偏移量设置窗口`n   - 通过屏幕标识和坐标信息，判断是哪一块屏幕，然后设置对应的偏移量`n   - 偏移量的修改实时生效，你可以立即在对应窗口中看到效果`n   - 如何通过坐标信息判断屏幕？`n      - 假设你有两块屏幕，主屏幕在左边，副屏幕在右边`n      - 那么副屏幕的左上角 X 坐标一定大于或等于主屏幕的右下角 X 坐标',
        link: '相关链接: <a href="https://inputtip.pages.dev/FAQ/about-app-offset">关于特殊偏移量</a>',
        addConfirm: "",
        addConfirm2: "",
        addConfirm3: "",
        addConfirm4: "如果此应用不在白名单中，则会同步添加到白名单中",
        rmConfirm: "",
        rmConfirm2: "",
        rmConfirm3: "",
    },
    handleFn, addClickFn, rmClickFn, addFn
    )
    handleFn(*) {
        gc.appOffsetGui_LV_rm_title.Text := "特殊偏移量列表 ( " gc.appOffsetGui_LV_rm.GetCount() " 个 )"
        writeIni("app_offset", "")
        global app_offset := {}
        restartJetBrains()
    }

    addClickFn(LV, RowNumber, tipList) {
        handleClick(LV, RowNumber, tipList, "add")
    }
    rmClickFn(LV, RowNumber, tipList) {
        handleClick(LV, RowNumber, tipList, "rm")
    }
    addFn(tipList) {
        _gui := tipList.gui
        addApp("xxx.exe")
        addApp(v) {
            createGui(fn).Show()
            fn(x, y, w, h) {
                if (gc.w.subGui) {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
                g_2 := Gui("AlwaysOnTop", "InputTip - 手动添加进程")
                g_2.SetFont(fz, "微软雅黑")
                bw := w - g_2.MarginX * 2

                ; 需要同步添加到白名单
                if (useWhiteList && tipList.addConfirm4) {
                    g_2.AddText("cRed", tipList.addConfirm4)
                }
                g_2.AddText(, "1. 进程名称应该是")
                g_2.AddText("yp cRed", "xxx.exe")
                g_2.AddText("yp", "这样的格式")
                g_2.AddText("xs", "2. 每一次只能添加一个")
                g_2.AddText("xs", "应用进程名称: ")
                g_2.AddEdit("yp vexe_name", "").Value := v
                g_2.AddButton("xs w" bw, "添加").OnEvent("Click", yes)
                yes(*) {
                    exe_name := g_2.Submit().exe_name
                    if (!RegExMatch(exe_name, "^.+\.\w{3}$") || InStr(exe_name, ":")) {
                        createGui(fn).Show()
                        fn(x, y, w, h) {
                            if (gc.w.subGui) {
                                gc.w.subGui.Destroy()
                                gc.w.subGui := ""
                            }
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
                            gc.w.subGui := g_2
                            return g_2
                        }
                        return
                    }
                    is_exist := 0
                    for v in app_offset.OwnProps() {
                        if (v = exe_name) {
                            is_exist := 1
                            break
                        }
                    }
                    if (is_exist) {
                        createGui(fn1).Show()
                        fn1(x, y, w, h) {
                            if (gc.w.subGui) {
                                gc.w.subGui.Destroy()
                                gc.w.subGui := ""
                            }
                            g_2 := Gui("AlwaysOnTop")
                            g_2.SetFont(fz, "微软雅黑")
                            bw := w - g_2.MarginX * 2
                            g_2.AddText("cRed", exe_name)
                            g_2.AddText("yp", "已经在「特殊偏移量列表」中了，请重新输入")
                            g_2.AddButton("xs w" bw, "重新输入").OnEvent("click", close)
                            close(*) {
                                g_2.Destroy()
                                addApp(exe_name)
                            }
                            gc.w.subGui := g_2
                            return g_2
                        }
                    } else {
                        handleClick("", "", tipList, "input", exe_name)
                    }
                }
                gc.w.subGui := g_2
                return g_2
            }
        }
    }

    handleClick(LV, RowNumber, tipList, action, app := "") {
        if (gc.w.offsetGui) {
            gc.w.offsetGui.Destroy()
            gc.w.offsetGui := ""
        }
        global app_offset
        screenList := getScreenInfo()
        if (action != "input") {
            app := LV.GetText(RowNumber)
        }
        if (action = "add" || action = "input") {
            is_exist := 0
            for v in app_offset.OwnProps() {
                if (v = app) {
                    is_exist := 1
                    break
                }
            }
            if (!is_exist) {
                gc.appOffsetGui_LV_rm.Add(, app)
            }
            if (action = "add") {
                LV.Delete(RowNumber)
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
        offsetGui := Gui("AlwaysOnTop", "InputTip - 设置 " app " 的特殊偏移量")
        offsetGui.SetFont(fz, "微软雅黑")
        offsetGui.AddText(, "正在设置")
        offsetGui.AddText("yp cRed", app)
        offsetGui.AddText("yp", "的特殊偏移量")
        tab := offsetGui.AddTab3("xs -Wrap", ["屏幕1"])
        tab.UseTab(1)
        offsetGui.AddText(, "屏幕坐标信息(X,Y): 左上角(99999, 99999)，右下角(99999, 99999)")
        offsetGui.AddText(, "水平方向的偏移量: ")
        offsetGui.AddEdit("yp")
        offsetGui.Show("Hide")
        offsetGui.GetPos(, , &Gui_width)
        offsetGui.Destroy()

        offsetGui := Gui("AlwaysOnTop", "InputTip - 设置 " app " 的特殊偏移量")
        offsetGui.SetFont(fz, "微软雅黑")
        offsetGui.AddText(, "正在设置")
        offsetGui.AddText("yp cRed", app)
        offsetGui.AddText("yp", "的特殊偏移量")
        pages := []
        for v in screenList {
            pages.push("屏幕 " v.num)
        }
        bw := Gui_width - offsetGui.MarginX * 2
        tab := offsetGui.AddTab3("xs -Wrap w" bw, pages)
        for v in screenList {
            tab.UseTab(v.num)
            if (v.num = v.main) {
                offsetGui.AddText(, "这是主屏幕(主显示器)，屏幕标识: " v.num)
            } else {
                offsetGui.AddText(, "这是副屏幕(副显示器)，屏幕标识: " v.num)
            }

            offsetGui.AddText(, "屏幕坐标信息(X,Y): 左上角(" v.left ", " v.top ")，右下角(" v.right ", " v.bottom ")")

            x := 0, y := 0
            try {
                x := app_offset.%app%.%v.num%.x
                y := app_offset.%app%.%v.num%.y
            } catch {
                app_offset.%app%.%v.num% := { x: 0, y: 0 }
            }

            offsetGui.AddText("Section", "水平方向的偏移量: ")
            _g := offsetGui.AddEdit("voffset_x_" v.num " yp")
            _g.Value := x
            _g.__num := v.num
            _g.OnEvent("Change", fn_change_offset_x)
            fn_change_offset_x(item, *) {
                app_offset.%app%.%item.__num%.x := returnNumber(item.Value)
                fn_write_offset()
            }
            offsetGui.AddText("xs", "垂直方向的偏移量: ")
            _g := offsetGui.AddEdit("voffset_y_" v.num " yp")
            _g.Value := y
            _g.__num := v.num
            _g.OnEvent("Change", fn_change_offset_y)
            fn_change_offset_y(item, *) {
                app_offset.%app%.%item.__num%.y := returnNumber(item.Value)
                fn_write_offset()
            }
        }
        tab.UseTab(0)
        if (action = "rm") {
            _g := offsetGui.AddButton("Section w" bw, "将它移除")
            _g.OnEvent("Click", fn_rm)
            fn_rm(*) {
                close()
                RowText := LV.GetText(RowNumber)
                LV.Delete(RowNumber)
                try {
                    gc.%tipList.gui "_LV_add"%.Add(, RowText, WinGetTitle("ahk_exe " RowText))
                }
                app_offset.DeleteProp(app)
                fn_write_offset()
            }
        }
        offsetGui.OnEvent("Close", close)
        close(*) {
            offsetGui.Destroy()
        }
        gc.w.offsetGui := offsetGui
        offsetGui.Show()

        fn_write_offset() {
            gc.appOffsetGui_LV_rm_title.Text := "特殊偏移量列表 ( " gc.appOffsetGui_LV_rm.GetCount() " 个 )"
            _app_offset := ""
            for v in app_offset.OwnProps() {
                _info := v "|"
                for s in app_offset.%v%.OwnProps() {
                    _info .= s "/" app_offset.%v%.%s%.x "/" app_offset.%v%.%s%.y "*"
                }
                _app_offset .= ":" SubStr(_info, 1, StrLen(_info) - 1)
            }
            writeIni("app_offset", SubStr(_app_offset, 2))
            restartJetBrains()
        }
    }
}
