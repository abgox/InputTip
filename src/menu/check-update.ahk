; InputTip

fn_check_update(*) {
    if (gc.w.checkUpdateGui) {
        gc.w.checkUpdateGui.Destroy()
        gc.w.checkUpdateGui := ""
    }
    gc.checkUpdateDelay := checkUpdateDelay

    createGui(checkUpdateGui).Show()
    checkUpdateGui(info) {
        g := createGuiOpt("InputTip - 设置更新检查")
        line := "--------------------------------------------------------------------------"
        tab := g.AddTab3("-Wrap", ["设置更新检查", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", "你首先应该点击上方的「关于」或官网查看相关的详细帮助说明")

        if (info.i) {
            g.AddText("cGray", "点击后，如果没有更新弹窗且不是网络问题，则当前是最新版本")
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", line)
        g.AddText(, "1. 每隔多少分钟检查一次版本更新: ")

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
        g.AddText("xs", "2. 是否启用自动静默更新: ")
        _ := g.AddDropDownList("yp", [" 禁用静默更新", " 启用静默更新"])
        _.Value := readIni("silentUpdate", 0) + 1
        _.OnEvent("Change", e_setSilentUpdate)
        e_setSilentUpdate(item, *) {
            value := item.value - 1
            writeIni("silentUpdate", value)
            global silentUpdate := value
        }
        g.AddText("xs", line)
        g.AddButton("xs w" bw, "立即检查版本更新").OnEvent("Click", e_check_update)
        g.AddText("cGray", "点击后，如果没有更新弹窗且不是网络问题，则当前就是最新版本")
        e_check_update(*) {
            g.Destroy()
            checkUpdate(1, 1, 1, 0)
        }
        aboutText := '1. 关于「每隔多少分钟检查一次版本更新」`n   - 单位: 分钟，默认 1440 分钟(1 天)`n   - 避免程序错误，可以设置的最大范围是 0-50000 分钟`n   - 如果为 0，则表示不检查版本更新`n   - 如果不为 0，在 InputTip 启动时，会立即检查一次`n   - 如果大于 50000，则生效的值是 50000`n`n2. 关于「是否启用自动静默更新」`n   - 前提条件:「每隔多少分钟检查一次版本更新」的值不为 0`n   - 启用后，不再弹出更新弹框，而是利用空闲时间自动更新`n   - 空闲时间: 3 分钟内没有鼠标或键盘操作`n`n3. 关于「立即检查版本更新」`n   - 点击这个按钮后，会立即检查一次版本更新`n   - 如果没有更新弹窗且不是网络问题，则表示当前就是最新版本'
        lineN := "10"
        if (!A_IsCompiled) {
            g.AddButton("xs w" bw, "与源代码仓库同步").OnEvent("Click", e_get_update)
            g.AddText("cGray", "点击后，不检查版本，直接从源代码仓库中下载最新的源代码文件")
            e_get_update(*) {
                g.Destroy()
                getRepoCode(0, 0)
            }
            aboutText .= '`n`n4. 关于「与源代码仓库同步」`n   - 点击这个按钮后，会从源代码仓库中下载最新的源代码文件`n   - 不管是否有版本更新，都会下载最新的源代码文件'
            lineN := "13"
        }
        tab.UseTab(2)
        g.AddEdit("ReadOnly w" bw " r" lineN, aboutText)
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/check-update">关于更新检查</a>')
        tab.UseTab(0)
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
