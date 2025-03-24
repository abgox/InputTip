; InputTip

fn_check_update(*) {
    if (gc.w.checkUpdateGui) {
        gc.w.checkUpdateGui.Destroy()
        gc.w.checkUpdateGui := ""
    }
    gc.checkUpdateDelay := checkUpdateDelay

    createGui(checkUpdateGui).Show()
    checkUpdateGui(info) {
        g := createGuiOpt("InputTip - 设置更新检查的间隔时间")
        g.AddText("cGray", "1. 单位: 分钟，默认 1440 分钟(1 天)`n2. 避免程序错误，可以设置的最大范围是 0-50000 分钟`n3. 如果为 0，则表示不检查版本更新`n4. 如果不为 0，在 InputTip 启动时，会立即检查一次`n5. 如果大于 50000，则生效的值是 50000")
        g.AddText(, "每隔多少分钟检查一次更新: ")

        if (info.i) {
            return g
        }

        _ := g.AddEdit("yp Number Limit5")
        _.Value := readIni("checkUpdateDelay", 1440)
        _.Focus()
        _.OnEvent("Change", e_setIntervalTime)
        e_setIntervalTime(item, *) {
            value := item.value
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
        g.AddButton("xs w" info.w, "立即检查更新").OnEvent("Click", e_check_update)
        g.AddText("cGray", "点击后，如果没有更新弹窗且不是网络问题，则当前是最新版本")
        e_check_update(*) {
            g.Destroy()
            checkUpdate(1, 1, 1)
        }
        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            if (gc.checkUpdateDelay = 0 && checkUpdateDelay != 0) {
                checkUpdate(1, 1)
            }
        }
        gc.w.checkUpdateGui := g
        return g
    }
}
