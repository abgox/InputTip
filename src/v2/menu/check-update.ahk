fn_check_update(*) {
    createGui(fn).Show()
    fn(x, y, w, h) {
        if (gc.w.checkUpdateGui) {
            gc.w.checkUpdateGui.Destroy()
            gc.w.checkUpdateGui := ""
        }
        gc.checkUpdateDelay := checkUpdateDelay
        g := Gui("AlwaysOnTop", "InputTip - 设置更新检测")
        g.SetFont(fz, "微软雅黑")
        g.AddEdit("ReadOnly cRed -VScroll w" w - g.MarginX * 2, "- 单位: 分钟，默认 1440 分钟(1 天)`n- 避免程序错误，可以设置的最大范围是 0-50000 分钟`n- 如果为 0，则表示不检测版本更新`n- 如果不为 0，在 InputTip 启动后，会立即检测一次`n- 如果大于 50000，则会直接使用 50000`n")
        g.AddText(, "每隔多少分钟检测一次更新: ")
        _c := g.AddEdit("yp Number Limit5 vcheckUpdateDelay")
        _c.Value := readIni("checkUpdateDelay", 1440)
        _c.OnEvent("Change", fn_change_delay)
        _c.Focus()
        g.AddText()
        fn_change_delay(item, *) {
            value := item.Value
            if (value != "") {
                if (value > 50000) {
                    value := 50000
                }
                writeIni("checkUpdateDelay", value)
                global checkUpdateDelay := value
                if (checkUpdateDelay) {
                    checkUpdate()
                }
            }
        }
        g.OnEvent("Close", close)
        close(*) {
            g.Destroy()
            if (gc.checkUpdateDelay = 0 && checkUpdateDelay != 0) {
                checkUpdate(1)
            }
        }
        gc.w.checkUpdateGui := g
        return g
    }
}
