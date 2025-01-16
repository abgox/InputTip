fn_app_offset(*) {
    fn_common({
        gui: "appOffsetGui",
        config: "app_offset",
        tab: ["设置特殊偏移量", "关于"],
        tip: "你首先应该点击上方的「关于」查看具体的操作说明                                         ",
        list: "特殊偏移量列表",
        color: "cRed",
        about: '1. 如何使用这个管理面板？`n`n   - 上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 为了便于操作，白名单中的应用进程也会添加到列表中`n   - 双击列表中任意应用进程，就可以将其添加到「特殊偏移量列表」中`n   - 如果需要更多的进程，请点击右下角的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击右下角的「通过输入进程名称手动添加」直接添加进程名称`n`n   - 下方是「特殊偏移量列表」，可以设置指定应用在不同屏幕下的符号显示偏移量`n   - 双击列表中任意应用进程，会弹出偏移量设置窗口，或者点击窗口底部按钮移除它`n`n2. 如何设置偏移量？`n`n   - 当双击任意应用进程后，会弹出偏移量设置窗口`n   - 通过屏幕标识和坐标信息，判断是哪一块屏幕，然后设置对应的偏移量`n   - 偏移量的修改实时生效，你可以立即在对应窗口中看到效果`n   - 如何通过坐标信息判断屏幕？`n      - 假设你有两块屏幕，主屏幕在左边，副屏幕在右边`n      - 那么副屏幕的左上角 X 坐标一定大于或等于主屏幕的右下角 X 坐标',
        link: '相关链接: <a href="https://inputtip.pages.dev/FAQ/app-offset">关于特殊偏移量</a>',
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
        restartJAB()
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
                g := createGuiOpt("InputTip - 设置特殊偏移量")
                text := "每次只能添加一个应用进程名称"
                if (useWhiteList) {
                    text .= "`n如果它还不在白名单中，则会同步添加到白名单中"
                }
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
                    } else {
                        handleClick("", "", tipList, "input", exe_name)
                    }
                }
                gc.w.subGui := g
                return g
            }
        }
    }

    handleClick(LV, RowNumber, tipList, action, app := "") {
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

        if (gc.w.offsetGui) {
            gc.w.offsetGui.Destroy()
            gc.w.offsetGui := ""
        }
        createGui(setOffsetGui).Show()
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
                    try {
                        gc.%tipList.gui "_LV_add"%.Add(, exe_name, WinGetTitle("ahk_exe " exe_name))
                    }
                    app_offset.DeleteProp(app)
                    fn_write_offset()
                }
            }
            g.OnEvent("Close", close)
            close(*) {
                g.Destroy()
            }
            gc.w.offsetGui := g
            return g
        }
    }
}
