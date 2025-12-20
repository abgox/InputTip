; InputTip

fn_scheme_cursor(*) {
    createUniqueGui(cursorStyleGui).Show()
    cursorStyleGui(info) {
        g := createGuiOpt("InputTip - " lang("cursor_scheme.title"))
        tab := g.AddTab3("-Wrap", [lang("cursor_scheme.tab"), lang("common.about")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "------"

        g.AddText("xs", line)

        g.AddText("xs", lang("cursor_scheme.load_cursor"))
        _ := g.AddDropDownList("w" bw / 2 " yp AltSubmit Choose" changeCursor + 1, [lang("cursor_scheme.keep_original"), lang("cursor_scheme.follow_state")])
        _.OnEvent("Change", e_change_cursor)
        e_change_cursor(item, *) {
            static last := changeCursor + 1
            if (last = item.value) {
                return
            }
            last := item.value

            if (item.value = 1) {
                writeIni("changeCursor", 0)
                global changeCursor := 0
                revertCursor(cursorInfo)
                createTipGui([{
                    opt: "",
                    text: lang("cursor_scheme.reverting")
                }, {
                    opt: "cRed",
                    text: lang("cursor_scheme.revert_tip1"),
                }, {
                    opt: "cGray",
                    text: lang("cursor_scheme.revert_tip2")
                }], "InputTip - " lang("cursor_scheme.tab")).Show()
            } else {
                writeIni("changeCursor", 1)
                global changeCursor := 1
                reloadCursor()
            }
            restartJAB()
        }

        g.AddText("xs", line)
        createGuiOpt("").AddText(, lang("state.CN")).GetPos(, , &__w)
        dirList := StrSplit(cursorDir, ":")
        if (dirList.Length = 0) {
            dirList := getCursorDir()
        }
        for i, v in ["CN", "EN", "Caps"] {
            g.AddText("xs", getStateName(v) ":")
            _ := g.AddDropDownList("yp r9 w" bw - __w - g.MarginX, dirList)
            _._config := v "_cursor"
            _.OnEvent("Change", e_cursor_dir)
            try {
                _.Text := %v "_cursor"%
            } catch {
                _.Text := ""
            }
        }
        e_cursor_dir(item, *) {
            writeIni(item._config, item.Text)
            updateCursor()
            reloadCursor()
        }

        _w := bw / 3 - g.MarginX / 3
        g.AddButton("xs w" _w, lang("cursor_scheme.open_cursor_dir")).OnEvent("Click", (*) => (Run("explorer.exe InputTipCursor")))
        g.AddButton("yp w" _w, lang("gui.refresh_list")).OnEvent("Click", (*) => (
            getPathList()
            fn_scheme_cursor()
        ))
        g.AddButton("yp w" _w, lang("cursor_scheme.download_more")).OnEvent("Click", (*) => (Run("https://inputtip.abgox.com/download/extra")))

        tab.UseTab(2)
        g.AddEdit("ReadOnly r11 w" bw, lang("about_text.cursor_scheme"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/custom-cursor-style">Custom Cursor Style</a>')
        return g
    }
}

