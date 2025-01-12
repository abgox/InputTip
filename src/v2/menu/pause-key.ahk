fn_pause_key(*) {
    if (gc.w.pauseHotkeyGui) {
        gc.w.pauseHotkeyGui.Destroy()
        gc.w.pauseHotkeyGui := ""
    }
    line := "---------------------------------------------------------------------------------"
    hotkeyGui := Gui("AlwaysOnTop")
    hotkeyGui.SetFont(fz, "微软雅黑")
    hotkeyGui.AddText(, line)
    hotkeyGui.Show("Hide")
    hotkeyGui.GetPos(, , &Gui_width)
    hotkeyGui.Destroy()

    hotkeyGui := Gui("AlwaysOnTop", "InputTip - 设置暂停/运行快捷键的快捷键")
    hotkeyGui.SetFont(fz, "微软雅黑")

    bw := Gui_width - hotkeyGui.MarginX * 2

    tab := hotkeyGui.AddTab3("-Wrap", ["设置组合快捷键", "手动输入快捷键"])
    tab.UseTab(1)
    hotkeyGui.AddText("Section", "1.  直接按下快捷键即可设置，除非快捷键被占用，则使用「手动输入快捷键」")
    hotkeyGui.AddText("xs", "2.  使用 Backspace(退格键) 或 Delete(删除键) 可以清除快捷键")
    hotkeyGui.AddText("xs", "3.  通过勾选右侧的 Win 键来表示快捷键中需要加入 Win 修饰键`n" line)

    hotkeyGui.AddText("xs", "设置")
    hotkeyGui.AddText("yp cRed", "暂停/运行")
    hotkeyGui.AddText("yp", "的快捷键: ")
    value := readIni('hotkey_Pause', '')
    gc.hotkey_Pause := hotkeyGui.AddHotkey("yp vhotkey_Pause", StrReplace(value, "#", ""))

    gc.hotkey_Pause.OnEvent("Change", fn_change_hotkey1)
    fn_change_hotkey1(item, *) {
        ; 同步修改到「手动输入快捷键」
        v := item.Value
        if (gc.win.Value) {
            v := "#" v
        }
        gc.%item.Name "2"%.Value := v
    }
    gc.win := hotkeyGui.AddCheckbox("yp vwin", "Win 键")
    gc.win.OnEvent("Click", fn_win_key)
    fn_win_key(item, *) {
        ; 同步修改到「手动输入快捷键」
        v := gc.hotkey_Pause.Value
        if (item.Value) {
            gc.hotkey_Pause2.Value := "#" v
        } else {
            gc.hotkey_Pause2.Value := v
        }
    }

    gc.win.Value := InStr(value, "#") ? 1 : 0
    hotkeyGui.AddButton("xs w" bw, "确定").OnEvent("Click", yes)
    yes(*) {
        if (hotkeyGui.Submit().win) {
            key := "#" hotkeyGui.Submit().hotkey_Pause
        } else {
            key := hotkeyGui.Submit().hotkey_Pause
        }
        writeIni("hotkey_Pause", key)
        fn_restart()
    }
    tab.UseTab(2)
    hotkeyGui.AddLink("Section", "1.")
    hotkeyGui.AddLink("yp cRed", "优先使用「设置组合快捷键」进行设置，除非因为快捷键占用无法设置")
    hotkeyGui.AddLink("xs", '2.  你需要首先查看 <a href="https://inputtip.pages.dev/FAQ/enter-shortcuts-manually">如何手动输入快捷键</a>')
    hotkeyGui.AddLink("xs", '3.  建议先使用「设置组合快捷键」，然后回到此处适当修改`n' line)
    hotkeyGui.AddText("xs", "设置")
    hotkeyGui.AddText("yp cRed", "暂停/运行")
    hotkeyGui.AddText("yp", "的快捷键: ")
    value := readIni('hotkey_Pause', '')
    gc.hotkey_Pause2 := hotkeyGui.AddEdit("yp w300 vhotkey_Pause2", readIni("hotkey_Pause", ''))
    gc.hotkey_Pause2.OnEvent("Change", fn_change_hotkey2)
    fn_change_hotkey2(item, *) {
        gc.win.Value := InStr(item.Value, "#") ? 1 : 0
        if (item.Value ~= "^~\w+\sUp$") {
            gc.hotkey_Pause.Value := ""
        } else {
            ; 当输入的快捷键符合组合快捷键时，同步修改
            try {
                gc.hotkey_Pause.Value := StrReplace(item.Value, "#", "")
            } catch {
                gc.hotkey_Pause.Value := ""
            }
        }
    }
    hotkeyGui.AddButton("xs w" bw, "确定").OnEvent("Click", yes2)
    yes2(*) {
        if (hotkeyGui.Submit().win) {
            key := "#" hotkeyGui.Submit().hotkey_Pause2
        } else {
            key := hotkeyGui.Submit().hotkey_Pause2
        }
        writeIni("hotkey_Pause", key)
        fn_restart()
    }
    hotkeyGui.OnEvent("Close", fn_close)
    fn_close(*) {
        hotkeyGui.Destroy()
    }
    gc.w.pauseHotkeyGui := hotkeyGui
    hotkeyGui.Show()
}
