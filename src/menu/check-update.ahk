; InputTip

fn_check_update(*) {
    gc.checkUpdateDelay := checkUpdateDelay

    createUniqueGui(checkUpdateGui).Show()
    checkUpdateGui(info) {
        g := createGuiOpt("InputTip - " lang("check_update.title"))
        line := "-------------------------------------------------------------------------"
        tab := g.AddTab3("-Wrap", [lang("check_update.tab_check"), lang("common.about")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", line)
        g.AddText(, lang("check_update.freq_label"))

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
        g.AddText("xs", lang("check_update.auto_silent_label"))
        _ := g.AddDropDownList("yp AltSubmit vsilentUpdate", [lang("check_update.disabled"), lang("check_update.enabled")])
        _.Value := readIni("silentUpdate", 0) + 1
        _.OnEvent("Change", e_setSilentUpdate)
        e_setSilentUpdate(item, *) {
            global silentUpdate := item.value - 1
        }
        g.AddText("xs", line)
        g.AddButton("xs w" bw, lang("check_update.check_now")).OnEvent("Click", e_check_update)
        e_check_update(*) {
            g.Destroy()
            checkUpdate(1, 1, 1, 0)
        }
        aboutText := lang("about_text.check_update_menu")
        lineN := "7"
        if (!A_IsCompiled) {
            g.AddButton("xs w" bw, lang("check_update.sync_repo")).OnEvent("Click", e_get_update)
            e_get_update(*) {
                g.Destroy()
                getRepoCode(0, 0)
            }
            aboutText .= "`n`n" lang("about_text.check_update_menu_sync")
            lineN := "10"
        }
        tab.UseTab(2)
        g.AddEdit("ReadOnly w" bw " r" lineN, aboutText)
        g.AddLink(, lang("check_update.link") '<a href="https://inputtip.abgox.com/faq/check-update">' lang("check_update.tab_check") '</a>')
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
