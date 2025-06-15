; InputTip

fn_bw_list(*) {
    createUniqueGui(bwListGui).Show()
    bwListGui(info) {
        g := createGuiOpt("InputTip - 设置符号显示的黑/白名单")
        g.AddText("cRed", "白名单机制: 只有在【白】名单中的应用进程窗口会尝试显示符号`n黑名单机制: 不在【黑】名单中的应用进程窗口都会尝试显示符号")

        g.AddText(, "选择符号显示的名单机制: ")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        gc._bw_list := g.AddDropDownList("yp AltSubmit Choose" useWhiteList + 1, ["使用【黑】名单", "使用【白】名单"])
        gc._bw_list.OnEvent("Change", e_change_list)
        e_change_list(item, *) {
            if (useWhiteList = item.value) {
                createUniqueGui(warningGui).Show()
                warningGui(info) {
                    gc._bw_list.Value := useWhiteList + 1
                    _g := createGuiOpt("InputTip - 警告")
                    _g.AddText(, "确定要使用【黑】名单吗？")
                    _g.AddText("cRed", "和【白】名单相比,【黑】名单存在以下缺点`n1. 对电脑的性能消耗更高`n2. 需要承担未知的可能存在的窗口兼容性代价")
                    _g.AddLink("cGray", '详情请查看 <a href="https://inputtip.abgox.com/FAQ/white-list">为什么建议使用白名单机制</a>')

                    if (info.i) {
                        return _g
                    }
                    w := info.w
                    bw := w - _g.MarginX * 2

                    _g.AddButton("w" bw, "【是】我确定要使用【黑】名单").OnEvent("Click", e_yes)
                    _ := _g.AddButton("w" bw, "【否】不，我只是不小心点到了")
                    _.OnEvent("Click", e_no)
                    _.Focus()
                    e_yes(*) {
                        _g.Destroy()
                        gc._bw_list.Value := 1
                        writeIni("useWhiteList", 0)
                        global useWhiteList := 0
                        restartJAB()
                    }
                    e_no(*) {
                        _g.Destroy()
                    }
                    return _g
                }
            } else {
                value := item.value - 1
                writeIni("useWhiteList", value)
                global useWhiteList := value
                restartJAB()
            }
        }
        _c := g.AddButton("xs w" bw, "设置【白】名单")
        _c.Focus()
        _c.OnEvent("Click", set_white_list)
        set_white_list(*) {
            g.Destroy()
            fn_white_list()
        }
        g.AddButton("xs w" bw, "设置【黑】名单").OnEvent("Click", set_black_list)
        set_black_list(*) {
            g.Destroy()
            fn_common({
                title: "设置符号显示黑名单应用",
                tab: "符号显示黑名单",
                config: "App-HideSymbol",
                link: '相关链接: <a href="https://inputtip.abgox.com/FAQ/white-list">为什么建议使用白名单机制</a>'
            }, fn)
            fn() {
                global app_HideSymbol := StrSplit(readIniSection("App-HideSymbol"), "`n")
                restartJAB()
            }
        }
        return g
    }
}
