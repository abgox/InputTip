; InputTip

fn_bw_list(*) {
    createUniqueGui(bwListGui).Show()
    bwListGui(info) {
        g := createGuiOpt("InputTip - 设置符号的黑/白名单")

        tab := g.AddTab3("-Wrap", ["符号的黑/白名单", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)


        if (info.i) {
            g.AddText(, gui_help_tip)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, "-------------------------------------------------------------------------")

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
                title: "设置符号的黑名单",
                tab: "符号的黑名单",
                config: "App-HideSymbol",
                link: '相关链接: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">符号的名单机制</a>'
            }, fn)
            fn() {
                global app_HideSymbol := StrSplit(readIniSection("App-HideSymbol"), "`n")
                restartJAB()
            }
        }

        tab.UseTab(2)
        g.AddText("Section cRed", "- 白名单是【符号方案】的核心，黑名单仅作为它的补充`n- 如果你想要使用【符号方案】，就必须设置白名单").Focus()
        g.AddLink("Section", '- 关于【符号方案】，请参考:  <a href="https://inputtip.abgox.com/v2/#符号方案">官网</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>`n- 关于【黑白名单机制】，请参考:  <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">符号的名单机制</a>')
        return g
    }
}
