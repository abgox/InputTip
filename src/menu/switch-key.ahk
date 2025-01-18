fn_switch_key(*) {
    if (gc.w.switchKeyGui) {
        gc.w.switchKeyGui.Destroy()
        gc.w.switchKeyGui := ""
    }
    line := "--------------------------------------------------------------------------------------------"
    createGui(keyGui).Show()
    keyGui(info) {
        g := createGuiOpt("InputTip - 设置强制切换输入法状态的快捷键")
        tab := g.AddTab3("-Wrap", ["设置单键", "设置组合快捷键", "手动输入快捷键"])
        tab.UseTab(1)
        g.AddText("Section", "1.")
        g.AddText("yp cRed", "快捷键设置不会实时生效，需要点击「确定」后生效")
        g.AddText("xs", "2.  LShift 指的是左边的 Shift 键，RShift 指的是右边的 Shift 键，其他按键以此类推")
        g.AddText("xs", "3.  使用单键不会覆盖原本的按键功能，因为是在单键抬起时才会触发强制切换")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddLink("xs", "4.  如果要移除快捷键，请选择「无」")
        g.AddLink("xs", '5.  <a href="https://inputtip.pages.dev/FAQ/single-key-list">点击查看完整的按键名称对应表</a>`n' line)
        keyConfigList := [{
            config: "hotkey_CN",
            tip: "中文状态",
            with: "win_CN",
        }, {
            config: "hotkey_EN",
            tip: "英文状态",
            with: "win_EN",
        }, {
            config: "hotkey_Caps",
            tip: "大写锁定",
            with: "win_Caps",
        }]


        keyList := []
        keyList.Push(["无", "Esc", "Shift", "LShift", "RShift", "Ctrl", "LCtrl", "RCtrl", "Alt", "LAlt", "RAlt"]*)
        keyList.Push(["MButton", "LButton", "RButton"]*)
        keyList.Push(["Space", "Tab", "Enter", "Backspace", "Delete", "Insert", "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right"]*)

        i := 0
        while (i <= 9) {
            keyList.Push("Numpad" i)
            i++
        }
        keyList.Push(["NumpadDot", "NumLock", "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter"]*)

        i := 1
        while (i <= 24) {
            keyList.Push("F" i)
            i++
        }

        for v in keyConfigList {
            g.AddText("xs", "强制切换到")
            g.AddText("yp cRed", v.tip)
            g.AddText("yp", ":")

            _ := gc.%v.config% := g.AddDropDownList("yp r9", keyList)
            _._config := v.config
            _._with := v.with
            _.OnEvent("Change", e_change_hotkey)

            config := readIni(v.config, "")
            if (config ~= "^~\w+\sUp$") {
                try {
                    _.Text := Trim(StrReplace(StrReplace(config, "~", ""), "Up", ""))
                    if (!_.Value) {
                        _.Value := 1
                    }
                } catch {
                    _.Text := "无"
                }
            } else {
                _.Text := "无"
            }
        }
        e_change_hotkey(item, *) {
            static last := ""
            if (last = item.value) {
                return
            }
            last := item.value

            ; 同步修改到「设置组合快捷键」和「手动输入快捷键」
            if (item.Text = "无") {
                key := ""
            } else {
                key := "~" item.Text " Up"
            }
            gc.%item._config "2"%.Value := ""
            gc.%item._config "3"%.Value := key
            gc.%item._with%.Value := 0
        }
        tab.UseTab(2)
        g.AddText("Section", "1.")
        g.AddText("yp cRed", "快捷键设置不会实时生效，需要点击「确定」后生效")
        g.AddText("xs", "2.  直接按下快捷键即可设置，除非快捷键被占用，需要使用「手动输入快捷键」")
        g.AddText("xs", "3.  使用 Backspace(退格键) 或 Delete(删除键) 可以清除快捷键")
        g.AddText("xs", "4.  通过勾选右边的 Win 键来表示快捷键中需要加入 Win 修饰键`n" line)

        for v in keyConfigList {
            g.AddText("xs", "强制切换到")
            g.AddText("yp cRed", v.tip)
            g.AddText("yp", ":")
            value := readIni(v.config, '')
            _ := gc.%v.config "2"% := g.AddHotkey("yp", StrReplace(value, "#", ""))
            _._config := v.config
            _._with := v.with
            _.OnEvent("Change", e_change_hotkey1)
            gc.%v.with% := g.AddCheckbox("yp", "Win 键")
            gc.%v.with%._config := v.config
            gc.%v.with%.OnEvent("Click", e_win_key)
            gc.%v.with%.Value := InStr(value, "#") ? 1 : 0
        }
        e_change_hotkey1(item, *) {
            ; 同步修改到「设置单键」和「手动输入快捷键」
            gc.%item._config%.Text := "无"
            v := item.value
            if (gc.%item._with%.Value) {
                v := "#" v
            }
            gc.%item._config "3"%.Value := v
        }
        e_win_key(item, *) {
            ; 同步修改到「设置单键」和「手动输入快捷键」
            gc.%item._config%.Text := "无"
            v := gc.%item._config "2"%.Value
            gc.%item._config "3"%.Value := item.value ? "#" v : v
        }
        tab.UseTab(3)
        g.AddText("Section", "1.")
        g.AddText("yp cRed", "快捷键设置不会实时生效，需要点击「确定」后生效")
        g.AddText("xs", "2.")
        g.AddText("yp cRed", "优先使用「设置单键」或「设置组合快捷键」设置，除非因为快捷键占用无法设置")
        g.AddText("xs", '3.  这里会回显它们的设置，建议先使用它们，然后回到此处适当修改')
        g.AddLink("xs", '3.  你需要首先查看 <a href="https://inputtip.pages.dev/FAQ/enter-shortcuts-manually">如何手动输入快捷键</a>`n' line)
        for v in keyConfigList {
            g.AddText("xs", "强制切换到")
            g.AddText("yp cRed", v.tip)
            g.AddText("yp", ":")
            _ := gc.%v.config "3"% := g.AddEdit("yp")
            _._config := v.config
            _._with := v.with
            _.Value := readIni(v.config, '')
            _.OnEvent("Change", e_change_hotkey2)
        }
        e_change_hotkey2(item, *) {
            gc.%item._with%.Value := InStr(item.value, "#") ? 1 : 0
            ; 当输入的快捷键符合单键时，同步修改
            if (item.value ~= "^~\w+\sUp$") {
                try {
                    gc.%item._config%.Text := Trim(StrReplace(StrReplace(item.value, "~", ""), "Up", ""))
                } catch {
                    gc.%item._config%.Text := "无"
                }
                gc.%item._config "2"%.Value := ""
            } else {
                gc.%item._config%.Text := "无"
                ; 当输入的快捷键符合组合快捷键时，同步修改
                try {
                    gc.%item._config "2"%.Value := StrReplace(item.value, "#", "")
                } catch {
                    gc.%item._config "2"%.Value := ""
                }
            }
        }
        tab.UseTab(0)
        g.AddButton("Section w" w, "确定").OnEvent("Click", e_yes)
        e_yes(*) {
            for v in keyConfigList {
                key := gc.%v.config "3"%.Value
                writeIni(v.config, key)
            }
            fn_restart()
        }
        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
        }
        gc.w.switchKeyGui := g
        return g
    }
}
