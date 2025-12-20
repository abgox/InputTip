; InputTip

fn_bw_list(*) {
    createUniqueGui(bwListGui).Show()
    bwListGui(info) {
        g := createGuiOpt("InputTip - " lang("bw_list.title"))

        tab := g.AddTab3("-Wrap", [lang("bw_list.tab"), lang("common.about")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))


        if (info.i) {
            g.AddText(, lang("gui.help_tip"))
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, "-------------------------------------------------------------------------")

        _c := g.AddButton("xs w" bw, lang("bw_list.white_list"))
        _c.OnEvent("Click", set_white_list)
        set_white_list(*) {
            g.Destroy()
            fn_white_list()
        }
        g.AddButton("xs w" bw, lang("bw_list.black_list")).OnEvent("Click", set_black_list)
        set_black_list(*) {
            g.Destroy()
            fn_common({
                title: lang("bw_list.set_black_list"),
                tab: lang("bw_list.black_list"),
                config: "App-HideSymbol",
                link: 'Related links: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">Symbol List Mechanism</a>'
            }, fn)
            fn() {
                global app_HideSymbol := StrSplit(readIniSection("App-HideSymbol"), "`n")
                restartJAB()
            }
        }

        tab.UseTab(2)
        g.AddText("Section cRed", lang("bw_list.about_tip")).Focus()
        g.AddLink("Section", lang("bw_list.about_link"))
        return g
    }
}

