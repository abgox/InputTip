; InputTip

/**
 * 设置快捷键
 * @param keyConfigList 配置项
 * @param label 窗口标题
 * @example
 * setHotKeyGui([{
 * config: "hotkey_Pause", ; 要写入的配置项
 * tip: "暂停/运行" ; 快捷键功能描述
 * }], "软件暂停/运行")
 */
setHotKeyGui(keyConfigList, label := "") {
    createUniqueGui(hotKeyGui).Show()
    hotKeyGui(info) {
        g := createGuiOpt("InputTip - " lang("hotkey.title") (label ? " —— " label : ""))
        tab := g.AddTab3("-Wrap", [lang("hotkey.tab_single"), lang("hotkey.tab_combo"), lang("hotkey.tab_manual")])
        tab.UseTab(1)
        g.AddText("Section", lang("hotkey.tip1_1"))
        g.AddText("yp cRed", lang("hotkey.tip1_2"))
        g.AddText("xs", lang("hotkey.tip2"))
        g.AddText("xs", lang("hotkey.tip3"))

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        line := gui_width_line "--"

        g.AddLink("xs", lang("hotkey.tip4_link") '`n' line)

        keyList := []
        keyList.Push([lang("hotkey.none"), "Esc", "Shift", "LShift", "RShift", "Ctrl", "LCtrl", "RCtrl", "Alt", "LAlt", "RAlt"]*)
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
            g.AddText("xs", v.tip ":")

            _ := gc.%v.config% := g.AddDropDownList("yp r9", keyList)
            _._config := v.config
            _._with := v.config "_win"
            _.OnEvent("Change", e_change_hotkey)

            config := readIni(v.config, "")
            if (config ~= "^~\w+\sUp$") {
                try {
                    _.Text := Trim(StrReplace(StrReplace(config, "~", ""), "Up", ""))
                    if (!_.Value) {
                        _.Value := 1
                    }
                } catch {
                    _.Text := lang("hotkey.none")
                }
            } else {
                _.Text := lang("hotkey.none")
            }
        }
        e_change_hotkey(item, *) {
            ; 同步修改到【设置组合快捷键】和【手动输入快捷键】
            if (item.Text = lang("hotkey.none")) {
                key := ""
            } else {
                key := "~" item.Text " Up"
            }
            gc.%item._config "2"%.Value := ""
            gc.%item._config "3"%.Value := key
            gc.%item._with%.Value := 0
        }
        tab.UseTab(2)
        g.AddText("Section", lang("hotkey.tip1_1"))
        g.AddText("yp cRed", lang("hotkey.tip1_2"))
        g.AddText("xs", lang("hotkey.tip_combo2"))
        g.AddText("xs", lang("hotkey.tip_combo3"))
        g.AddText("xs", lang("hotkey.tip_combo4") '`n' line)

        for v in keyConfigList {
            g.AddText("xs", v.tip ":")
            value := readIni(v.config, '')
            _ := gc.%v.config "2"% := g.AddHotkey("yp", StrReplace(value, "#", ""))
            _._config := v.config
            _._with := v.config "_win"
            _.OnEvent("Change", e_change_hotkey1)
            gc.%_._with% := g.AddCheckbox("yp", lang("hotkey.win_key"))
            gc.%_._with%._config := v.config
            gc.%_._with%.OnEvent("Click", e_win_key)
            gc.%_._with%.Value := InStr(value, "#") ? 1 : 0
        }
        e_change_hotkey1(item, *) {
            ; 同步修改到【设置单键】和【手动输入快捷键】
            gc.%item._config%.Text := lang("hotkey.none")
            v := item.value
            if (gc.%item._with%.Value) {
                v := "#" v
            }
            gc.%item._config "3"%.Value := v
        }
        e_win_key(item, *) {
            ; 同步修改到【设置单键】和【手动输入快捷键】
            gc.%item._config%.Text := lang("hotkey.none")
            v := gc.%item._config "2"%.Value
            gc.%item._config "3"%.Value := item.value ? "#" v : v
        }
        tab.UseTab(3)
        g.AddText("Section", lang("hotkey.tip1_1"))
        g.AddText("yp cRed", lang("hotkey.tip1_2"))
        g.AddText("xs", lang("hotkey.tip_manual2"))
        g.AddText("yp cRed", lang("hotkey.tip_manual2_red"))
        g.AddText("xs", lang("hotkey.tip_manual3"))
        g.AddLink("xs", lang("hotkey.tip_manual4_link") '`n' line)
        for v in keyConfigList {
            g.AddText("xs", v.tip ":")
            _ := gc.%v.config "3"% := g.AddEdit("yp")
            _._config := v.config
            _._with := v.config "_win"
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
                    gc.%item._config%.Text := lang("hotkey.none")
                }
                gc.%item._config "2"%.Value := ""
            } else {
                gc.%item._config%.Text := lang("hotkey.none")
                ; 当输入的快捷键符合组合快捷键时，同步修改
                try {
                    gc.%item._config "2"%.Value := StrReplace(item.value, "#", "")
                } catch {
                    gc.%item._config "2"%.Value := ""
                }
            }
        }
        tab.UseTab(0)
        g.AddButton("Section w" bw, lang("hotkey.confirm")).OnEvent("Click", e_yes)
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
        return g
    }
}
