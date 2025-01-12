fn_switch_key(*) {
    if (gc.w.switchKeyGui) {
        gc.w.switchKeyGui.Destroy()
        gc.w.switchKeyGui := ""
    }
    line := "----------------------------------------------------------------------------------------"
    hotkeyGui := Gui("AlwaysOnTop")
    hotkeyGui.SetFont(fz, "微软雅黑")
    hotkeyGui.AddText(, line)
    hotkeyGui.Show("Hide")
    hotkeyGui.GetPos(, , &Gui_width)
    hotkeyGui.Destroy()

    hotkeyGui := Gui("AlwaysOnTop", "InputTip - 设置强制切换输入法状态的快捷键")
    hotkeyGui.SetFont(fz, "微软雅黑")

    bw := Gui_width - hotkeyGui.MarginX * 2

    tab := hotkeyGui.AddTab3("-Wrap", ["设置单键", "设置组合快捷键", "手动输入快捷键"])
    tab.UseTab(1)
    hotkeyGui.AddText("Section", "1.  LShift 指的是左边的 Shift 键，RShift 指的是右边的 Shift 键，以此类推")
    hotkeyGui.AddText("xs", "2.  单键不会覆盖原本的按键功能，因为在设置的单键抬起时才会触发强制切换")
    hotkeyGui.AddText("xs", "3.  如果要移除快捷键，请选择「无」`n" line)

    singleHotKeyList := [{
        tip: "中文状态",
        config: "single_hotkey_CN",
    }, {
        tip: "英文状态",
        config: "single_hotkey_EN",
    }, {
        tip: "大写锁定",
        config: "single_hotkey_Caps",
    }]
    for v in singleHotKeyList {
        hotkeyGui.AddText("xs", "强制切换到")
        hotkeyGui.AddText("yp cRed", v.tip)
        hotkeyGui.AddText("yp", ":")
        gc.%v.config% := hotkeyGui.AddDropDownList("yp v" v.config, ["无", "LShift", "RShift", "LCtrl", "RCtrl", "LAlt", "RAlt", "Esc"])
        gc.%v.config%.OnEvent("Change", fn_change_hotkey)
        fn_change_hotkey(item, *) {
            static last := ""
            if (last = item.Value) {
                return
            }
            last := item.Value

            ; 同步修改到「设置组合快捷键」和「手动输入快捷键」
            if (item.Text = "无") {
                key := ""
            } else {
                key := "~" item.Text " Up"
            }
            type := SubStr(item.Name, 15)
            gc.%"hotkey_" type%.Value := ""
            gc.%"hotkey_" type "2"%.Value := key
            gc.%"win_" type%.Value := 0
        }

        config := readIni(StrReplace(v.config, "single_", " "), "")

        if (config ~= "^~\w+\sUp$") {
            try {
                gc.%v.config%.Text := Trim(StrReplace(StrReplace(config, "~", ""), "Up", ""))
                if (!gc.%v.config%.Value) {
                    gc.%v.config%.Value := 1
                }
            } catch {
                gc.%v.config%.Text := "无"
            }
        } else {
            gc.%v.config%.Text := "无"
        }
    }
    hotkeyGui.AddButton("xs w" bw, "确定").OnEvent("Click", confirm)
    confirm(*) {
        for v in singleHotKeyList {
            value := hotkeyGui.Submit().%v.config%
            if (value = "无") {
                key := ""
            } else {
                key := "~" value " Up"
            }
            writeIni(StrReplace(v.config, "single_", " "), key)
        }
        fn_restart()
    }
    tab.UseTab(2)
    hotkeyGui.AddText("Section", "1.  直接按下快捷键即可设置，除非快捷键被占用，需要使用「手动输入快捷键」")
    hotkeyGui.AddText("xs", "2.  使用 Backspace(退格键) 或 Delete(删除键) 可以清除快捷键")
    hotkeyGui.AddText("xs", "3.  通过勾选右边的 Win 键来表示快捷键中需要加入 Win 修饰键`n" line)

    configList := [{
        config: "hotkey_CN",
        options: "",
        tip: "中文状态",
        with: "win_CN",
    }, {
        config: "hotkey_EN",
        options: "",
        tip: "英文状态",
        with: "win_EN",
    }, {
        config: "hotkey_Caps",
        options: "",
        tip: "大写锁定",
        with: "win_Caps",
    }]

    for v in configList {
        hotkeyGui.AddText("xs", "强制切换到")
        hotkeyGui.AddText("yp cRed", v.tip)
        hotkeyGui.AddText("yp", ":")
        value := readIni(v.config, '')
        gc.%v.config% := hotkeyGui.AddHotkey("yp v" v.config, StrReplace(value, "#", ""))

        gc.%v.config%.OnEvent("Change", fn_change_hotkey1)
        fn_change_hotkey1(item, *) {
            ; 同步修改到「设置单键」和「手动输入快捷键」
            gc.%"single_" item.Name%.Text := "无"
            v := item.Value
            if (gc.%"win_" SubStr(item.Name, 8)%.Value) {
                v := "#" v
            }
            gc.%item.Name "2"%.Value := v
        }
        gc.%v.with% := hotkeyGui.AddCheckbox("yp v" v.with, "Win 键")
        gc.%v.with%.OnEvent("Click", fn_win_key)
        fn_win_key(item, *) {
            ; 同步修改到「设置单键」和「手动输入快捷键」
            type := SubStr(item.Name, 5)
            gc.%"single_hotkey_" type%.Text := "无"

            v := gc.%"hotkey_" type%.Value
            if (item.Value) {
                gc.%"hotkey_" type "2"%.Value := "#" v
            } else {
                gc.%"hotkey_" type "2"%.Value := v
            }
        }
        gc.%v.with%.Value := InStr(value, "#") ? 1 : 0
    }
    hotkeyGui.AddButton("xs w" bw, "确定").OnEvent("Click", yes)
    yes(*) {
        for v in configList {
            if (hotkeyGui.Submit().%v.with%) {
                key := "#" hotkeyGui.Submit().%v.config%
            } else {
                key := hotkeyGui.Submit().%v.config%
            }
            writeIni(v.config, key)
        }
        fn_restart()
    }
    tab.UseTab(3)
    hotkeyGui.AddLink("Section", "1.")
    hotkeyGui.AddLink("yp cRed", "优先使用「设置单键」或「设置组合快捷键」设置，除非因为快捷键占用无法设置")
    hotkeyGui.AddLink("xs", '2.  你需要首先查看 <a href="https://inputtip.pages.dev/FAQ/enter-shortcuts-manually">如何手动输入快捷键</a>')
    hotkeyGui.AddLink("xs", '3.  建议先使用「设置单键」或「设置组合快捷键」，然后回到此处适当修改`n' line)
    for v in configList {
        hotkeyGui.AddText("xs", "强制切换到")
        hotkeyGui.AddText("yp cRed", v.tip)
        hotkeyGui.AddText("yp", ":")
        gc.%v.config "2"% := hotkeyGui.AddEdit("yp v" v.config "2")
        gc.%v.config "2"%.Value := readIni(v.config, '')
        gc.%v.config "2"%.OnEvent("Change", fn_change_hotkey2)
        fn_change_hotkey2(item, *) {
            type := StrReplace(SubStr(item.Name, 8), "2", "")
            gc.%"win_" type%.Value := InStr(item.Value, "#") ? 1 : 0

            ; 当输入的快捷键符合单键时，同步修改
            if (item.Value ~= "^~\w+\sUp$") {
                try {
                    gc.%"single_hotkey_" type%.Text := Trim(StrReplace(StrReplace(item.Value, "~", ""), "Up", ""))
                } catch {
                    gc.%"single_hotkey_" type%.Text := "无"
                }
                gc.%"hotkey_" type%.Value := ""
            } else {
                gc.%"single_hotkey_" type%.Text := "无"
                ; 当输入的快捷键符合组合快捷键时，同步修改
                try {
                    gc.%"hotkey_" type%.Value := StrReplace(item.Value, "#", "")
                } catch {
                    gc.%"hotkey_" type%.Value := ""
                }
            }
        }
    }
    hotkeyGui.AddButton("xs w" bw, "确定").OnEvent("Click", yes2)
    yes2(*) {
        for v in configList {
            key := hotkeyGui.Submit().%v.config "2"%
            writeIni(v.config, key)
        }
        fn_restart()
    }

    hotkeyGui.OnEvent("Close", fn_close)
    fn_close(*) {
        hotkeyGui.Destroy()
    }
    gc.w.switchKeyGui := hotkeyGui
    hotkeyGui.Show()
}
