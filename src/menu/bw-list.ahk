; InputTip

fn_bw_list(*) {
    createUniqueGui(bwListGui).Show()
    bwListGui(info) {
        g := createGuiOpt("InputTip - 设置符号显示的黑/白名单")

        g.AddText("Section cRed", "- 白名单是【符号显示方案】的核心，黑名单仅作为它的补充`n- 如果你想要使用【符号显示方案】，就必须设置白名单")
        g.AddLink("Section", '- 关于【符号显示方案】，请参考:  <a href="https://inputtip.abgox.com/v2/#符号显示方案">官网</a>   <a href="https://github.com/abgox/InputTip#符号显示方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号显示方案">Gitee</a>`n- 关于【黑白名单机制】，请参考:  <a href="https://inputtip.abgox.com/FAQ/white-list">符号显示方案的白名单机制</a>')

        if (info.i) {
            g.AddText(, gui_help_tip)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        _c := g.AddButton("xs w" bw, "白名单")
        _c.OnEvent("Click", set_white_list)
        set_white_list(*) {
            g.Destroy()
            fn_white_list()
        }
        g.AddButton("xs w" bw, "黑名单").OnEvent("Click", set_black_list)
        set_black_list(*) {
            g.Destroy()
            fn_common({
                title: "设置符号显示黑名单应用",
                tab: "符号显示黑名单",
                config: "App-HideSymbol",
                link: '相关链接: <a href="https://inputtip.abgox.com/FAQ/white-list">符号显示方案的白名单机制</a>'
            }, fn)
            fn() {
                global app_HideSymbol := StrSplit(readIniSection("App-HideSymbol"), "`n")
                restartJAB()
            }
        }
        return g
    }
}
