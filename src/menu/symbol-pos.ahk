; InputTip

fn_symbol_pos(*) {
    createUniqueGui(symbolPos).Show()
    symbolPos(info) {
        g := createGuiOpt("InputTip - " lang("symbol_pos.title"))
        tab := g.AddTab3("-Wrap", [lang("symbol_pos.tab"), lang("common.about")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, lang("symbol_pos.window_label"))
        g.AddDropDownList("yp AltSubmit Choose" showCursorPos + 1, [lang("symbol_pos.specified_window"), lang("symbol_pos.all_window")]).OnEvent("Change", e_change)
        e_change(item, *) {
            value := item.value - 1
            writeIni("showCursorPos", value)
            global showCursorPos := value
            restartJAB()
        }
        g.AddText("xs", lang("symbol_pos.h_offset"))
        _ := g.AddEdit("yp")
        _.Value := readIni("showCursorPos_x", 0)
        _._config := "showCursorPos_x"
        _.OnEvent("Change", fn_offset_x)
        fn_offset_x(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := returnNumber(item.value)
            global showCursorPos_x := value

            db(item._config, value)
        }
        g.AddText("xs", lang("symbol_pos.v_offset"))
        _ := g.AddEdit("yp")
        _.Value := readIni("showCursorPos_y", -20)
        _._config := "showCursorPos_y"
        _.OnEvent("Change", fn_offset_y)
        fn_offset_y(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := returnNumber(item.value)
            global showCursorPos_y := value

            db(item._config, value)
        }

        _c := g.AddButton("xs w" w, lang("symbol_pos.specify_window_btn"))
        _c.OnEvent("Click", set_app_list)
        set_app_list(*) {
            g.Destroy()
            fn_common({
                title: lang("symbol_pos.specify_window_btn"),
                tab: lang("symbol_pos.tab"),
                config: "ShowNearCursor",
                link: 'Related links: <a href="https://inputtip.abgox.com/faq/show-symbol-near-cursor">Show Symbol Near Cursor</a>'
            }, fn)
            fn() {
                global ShowNearCursor := StrSplit(readIniSection("ShowNearCursor"), "`n")
                restartJAB()
            }
        }
        tab.UseTab(2)
        g.AddEdit("ReadOnly VScroll r7 w" w, lang("about_text.symbol_pos"))
        g.AddLink(, lang("about_text.related_links") '   <a href="https://inputtip.abgox.com/faq/app-compatibility">App Compatibility</a>   <a href="https://inputtip.abgox.com/v1/">v1 Version</a>')
        return g
    }
}

