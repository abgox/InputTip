fn_pause_key(*) {
    if (gc.w.pauseHotkeyGui) {
        gc.w.pauseHotkeyGui.Destroy()
        gc.w.pauseHotkeyGui := ""
    }
    line := "------------------------------------------------------------------------------------"
    createGui(pauseKeyGui).Show()
    pauseKeyGui(info) {
        g := createGuiOpt("InputTip - 设置暂停/运行快捷键的快捷键")
        tab := g.AddTab3("-Wrap", ["设置组合快捷键", "手动输入快捷键"])
        tab.UseTab(1)
        g.AddText("Section", "1.")
        g.AddText("yp cRed", "快捷键设置不会实时生效，需要点击「确定」后生效")
        g.AddText("xs", "2.  直接按下快捷键即可设置，除非快捷键被占用，需要使用「手动输入快捷键」")
        g.AddText("xs", "3.  使用 Backspace(退格键) 或 Delete(删除键) 可以清除快捷键")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", "4.  通过勾选右边的 Win 键来表示快捷键中需要加入 Win 修饰键`n" line)
        g.AddText("xs", "设置")
        g.AddText("yp cRed", "暂停/运行")
        g.AddText("yp", "的快捷键: ")

        value := readIni('hotkey_Pause', '')
        gc.hotkey_Pause := g.AddHotkey("yp", StrReplace(value, "#", ""))
        gc.hotkey_Pause.OnEvent("Change", e_change_hotkey)
        e_change_hotkey(item, *) {
            ; 同步修改到「手动输入快捷键」
            v := item.value
            if (gc.win.Value) {
                v := "#" v
            }
            gc.hotkey_Pause2.Value := v
        }
        gc.win := g.AddCheckbox("yp", "Win 键")
        gc.win.OnEvent("Click", e_win_key)
        e_win_key(item, *) {
            ; 同步修改到「手动输入快捷键」
            v := gc.hotkey_Pause.Value
            if (item.value) {
                gc.hotkey_Pause2.Value := "#" v
            } else {
                gc.hotkey_Pause2.Value := v
            }
        }
        gc.win.Value := InStr(value, "#") ? 1 : 0

        tab.UseTab(2)
        g.AddText("Section", "1.")
        g.AddText("yp cRed", "快捷键设置不会实时生效，需要点击「确定」后生效")
        g.AddText("xs", "2.")
        g.AddText("yp cRed", "优先使用「设置组合快捷键」进行设置，除非因为快捷键占用无法设置")
        g.AddText("xs", '3.  这里会回显它的设置，建议先使用它，然后回到此处适当修改')
        g.AddLink("xs", '4.  你需要首先查看 <a href="https://inputtip.pages.dev/FAQ/enter-shortcuts-manually">如何手动输入快捷键</a>`n' line)

        g.AddText("xs", "设置")
        g.AddText("yp cRed", "暂停/运行")
        g.AddText("yp", "的快捷键: ")
        value := readIni('hotkey_Pause', '')

        gc.hotkey_Pause2 := g.AddEdit("yp")
        gc.hotkey_Pause2.Value := readIni("hotkey_Pause", '')
        gc.hotkey_Pause2.OnEvent("Change", e_change_hotkey2)
        e_change_hotkey2(item, *) {
            gc.win.Value := InStr(item.value, "#") ? 1 : 0
            if (item.value ~= "^~\w+\sUp$") {
                gc.hotkey_Pause.Value := ""
            } else {
                ; 当输入的快捷键符合组合快捷键时，同步修改
                try {
                    gc.hotkey_Pause.Value := StrReplace(item.value, "#", "")
                } catch {
                    gc.hotkey_Pause.Value := ""
                }
            }
        }
        tab.UseTab(0)

        g.AddButton("Section w" bw, "确定").OnEvent("Click", e_yes)
        e_yes(*) {
            value := gc.hotkey_Pause.value
            if (gc.win.Value) {
                key := "#" value
            } else {
                key := value
            }
            writeIni("hotkey_Pause", key)
            fn_restart()
        }

        gc.w.pauseHotkeyGui := g
        return g
    }
}
