; InputTip

fn_bw_list(*) {
    createUniqueGui(bwListGui).Show()
    bwListGui(info) {
        g := createGuiOpt("InputTip - 设置符号显示的黑/白名单")
        g.AddText("cRed", "白名单机制: 在【白】名单中的应用进程窗口会尝试显示符号`n黑名单机制: 在【黑】名单中的应用进程窗口不会显示符号`n注意: 【白】名单是核心，【黑】名单只是对【白】名单的补充")
        g.AddLink(, '详情参考: <a href="https://inputtip.abgox.com/FAQ/white-list">符号显示方案的白名单机制</a>')

        if (info.i) {
            g.AddText(, gui_help_tip)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

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
