; InputTip

fn_check_update(*) {
    gc.checkUpdateDelay := checkUpdateDelay

    createUniqueGui(checkUpdateGui).Show()
    checkUpdateGui(info) {
        g := createGuiOpt("InputTip - 更新检查")
        line := "-------------------------------------------------------------------------"
        tab := g.AddTab3("-Wrap", ["更新检查", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", line)
        g.AddText(, "更新检查频率: ")

        _ := g.AddEdit("yp Number Limit5 vcheckUpdateDelay")
        _.Value := readIni("checkUpdateDelay", 1440)
        _.OnEvent("Change", e_setIntervalTime)
        e_setIntervalTime(item, *) {
            value := item.value
            if (value != "") {
                if (value > 50000) {
                    value := 50000
                }
                global checkUpdateDelay := value
            }
        }
        g.AddText("xs", "自动静默更新: ")
        _ := g.AddDropDownList("yp AltSubmit vsilentUpdate", [" 禁用", " 启用"])
        _.Value := readIni("silentUpdate", 0) + 1
        _.OnEvent("Change", e_setSilentUpdate)
        e_setSilentUpdate(item, *) {
            global silentUpdate := item.value - 1
        }
        g.AddText("xs", line)
        g.AddButton("xs w" bw, "立即检查版本更新").OnEvent("Click", e_check_update)
        e_check_update(*) {
            g.Destroy()
            checkUpdate(1, 1, 1, 0)
        }
        aboutText := '1. 配置项 —— 更新检查频率`n   - 设置每隔多长时间检查一次更新`n   - 单位: 分钟，默认 1440 分钟(1 天)`n   - 如果为 0，则表示不检查版本更新`n   - 如果不为 0，在 InputTip 启动时，会立即检查一次`n`n2. 配置项 —— 自动静默更新`n   - 启用后，不再弹出更新弹框，而是利用空闲时间自动更新`n   - 空闲时间: 3 分钟内没有鼠标或键盘操作`n   - 如果【更新检查频率】的值为 0，则此配置项无效`n`n3. 按钮 —— 立即检查版本更新`n   - 点击这个按钮后，会立即检查一次版本更新`n   - 如果没有更新弹窗且不是网络问题，则表示当前就是最新版本'
        lineN := "7"
        if (!A_IsCompiled) {
            g.AddButton("xs w" bw, "与源代码仓库同步").OnEvent("Click", e_get_update)
            e_get_update(*) {
                g.Destroy()
                getRepoCode(0, 0)
            }
            aboutText .= '`n`n4. 按钮 —— 与源代码仓库同步`n   - 点击这个按钮后，会从源代码仓库中下载最新的源代码文件`n   - 不管是否有版本更新，都会下载最新的源代码文件'
            lineN := "10"
        }
        tab.UseTab(2)
        g.AddEdit("ReadOnly w" bw " r" lineN, aboutText)
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/faq/check-update">更新检查</a>')
        tab.UseTab(0)
        g.OnEvent("Close", e_close)
        e_close(*) {
            data := g.Submit()
            writeIni("checkUpdateDelay", data.checkUpdateDelay)
            writeIni("silentUpdate", data.silentUpdate - 1)

            if (gc.checkUpdateDelay = 0 && checkUpdateDelay != 0) {
                checkUpdate(1, 1)
            }
        }
        return g
    }
}
