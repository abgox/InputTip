; InputTip

fn_ohter_config(*) {
    createUniqueGui(ohterConfigGui).Show()
    ohterConfigGui(info) {
        g := createGuiOpt("InputTip - " lang("other_config.title"))
        tab := g.AddTab3("-Wrap", [lang("other_config.tab1"), lang("other_config.tab2"), lang("common.about")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "-------"
        g.AddText("xs", line)

        g.AddButton("xs w" bw / 2, lang("other_config.check_update")).OnEvent("Click", fn_check_update)
        g.AddButton("yp w" bw / 2, lang("other_config.auto_exit_btn")).OnEvent("Click", fn_auto_exit)
        g.AddButton("xs w" bw / 2, lang("other_config.open_dir")).OnEvent("Click", (*) => (Run("explorer.exe /select," A_ScriptFullPath)))
        g.AddButton("yp w" bw / 2, lang("other_config.set_username")).OnEvent("Click", (*) => (fn_update_user(userName)))
        g.AddButton("xs w" bw / 2, lang("other_config.pause_hotkey")).OnEvent("Click", (*) => (
            setHotKeyGui([{
                config: "hotkey_Pause",
                tip: lang("tray.pause_run")
            }], lang("other_config.pause_hotkey"))
        ))
        g.AddButton("yp w" bw / 2, lang("other_config.jab_support") (enableJABSupport ? lang("other_config.jab_enabled") : lang("other_config.jab_disabled")) lang("other_config.jab_status")).OnEvent("Click", e_enableJABSupport)
        e_enableJABSupport(item, *) {
            global enableJABSupport := !enableJABSupport

            if (enableJABSupport) {
                if (runJAB()) {
                    return
                }
                writeIni("enableJABSupport", enableJABSupport)
                item.Text := lang("other_config.jab_enabling")
                createUniqueGui(JABGui).Show()
                JABGui(info) {
                    g := createGuiOpt("InputTip - 启用 JAB/JetBrains IDE 支持")
                    g.AddText(, lang("other_config.jab_enable_success"))

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    g.AddEdit("xs -VScroll ReadOnly cGray w" w, lang("other_config.jab_steps"))
                    g.AddText("cRed", lang("other_config.jab_jdk_tip")).Focus()
                    g.AddLink(, lang("other_config.jab_link"))
                    g.AddButton("xs w" w, lang("other_config.btn_cursor_mode")).OnEvent("Click", fn_cursor_mode)
                    g.AddButton("xs w" w, lang("other_config.btn_app_offset")).OnEvent("Click", fn_app_offset)
                    y := g.AddButton("xs w" w, lang("common.i_understand"))
                    y.OnEvent("Click", e_close)
                    e_close(*) {
                        g.Destroy()
                    }
                    return g
                }
            } else {
                item.Text := lang("other_config.jab_disabling")
                SetTimer(killAppTimer, -1)
                killAppTimer() {
                    try {
                        killJAB(1, A_IsCompiled || A_IsAdmin)
                        writeIni("enableJABSupport", enableJABSupport)
                    }
                }
            }
        }

        g.AddText("xs", line)

        g.AddText("xs", lang("other_config.custom_tray_icon"))
        iconList := StrSplit(iconPaths, ":")
        g.AddText("xs cRed", lang("other_config.running")).GetPos(, , &_w)
        _ := g.AddDropDownList("yp r9 w" bw - _w, iconList)
        _.Text := iconRunning
        _.OnEvent("Change", e_iconRunning)
        e_iconRunning(item, *) {
            value := item.Text
            global iconRunning := value
            writeIni("iconRunning", value)
            if (!A_IsPaused) {
                setTrayIcon(value)
            }
        }
        g.AddText("xs cRed", lang("other_config.paused"))
        _ := g.AddDropDownList("yp r9 w" bw - _w, iconList)
        _.Text := iconPaused
        _.OnEvent("Change", e_iconPaused)
        e_iconPaused(item, *) {
            value := item.Text
            global iconPaused := value
            writeIni("iconPaused", value)
            if (A_IsPaused) {
                setTrayIcon(value)
            }
        }
        g.AddButton("xs w" bw / 2, lang("other_config.open_icon_dir")).OnEvent("Click", (*) => (Run("explorer.exe InputTipIcon")))
        g.AddButton("yp w" bw / 2, lang("other_config.refresh_list")).OnEvent("Click", (*) => (
            getPathList(),
            fn_ohter_config()
        ))

        tab.UseTab(2)
        g.AddText("Section cRed", lang("gui.help_tip"))
        g.AddText("xs", line)

        g.AddText("Section", lang("other_config.language") ": ")
        langOptions := ["English (en-US)", "中文 (zh-CN)"]
        _ := g.AddDropDownList("yp w" bw / 2, langOptions)
        _.Value := getLang() = "zh-CN" ? 2 : 1
        _.OnEvent("Change", e_change_lang)
        e_change_lang(item, *) {
            langCode := item.value = 2 ? "zh-CN" : "en-US"
            setLang(langCode)
            createTipGui([{
                opt: "",
                text: langCode = "zh-CN" ? lang("other_config.lang_changed_cn") : lang("other_config.lang_changed_en")
            }, {
                opt: "cRed",
                text: langCode = "zh-CN" ? lang("other_config.restart_tip_cn") : lang("other_config.restart_tip_en")
            }], "InputTip - " lang("other_config.lang_settings")).Show()
        }

        g.AddText("Section xs", "1. " lang("other_config.tab1") " - Font Size:")
        _ := g.AddEdit("yp Number Limit2")
        _.Value := readIni("gui_font_size", "12")
        _.OnEvent("Change", e_change_gui_fs)
        e_change_gui_fs(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := item.value
            if (value = "" || value < 5 || value > 30) {
                return
            }
            global fontOpt := ["s" value, "Microsoft YaHei"]

            db("gui_font_size", value)
        }

        g.AddText("xs", lang("other_config.poll_interval_label"))
        _ := g.AddEdit("yp Number Limit2")
        _.Value := delay
        _.OnEvent("Change", e_delay)
        e_delay(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value),
                restartJAB()
            ))

            value := item.value
            if (value = "") {
                return
            }
            value += value <= 0
            if (value > 100) {
                value := 100
            }
            global delay := value

            db("delay", value)
        }

        g.AddText("Section xs", lang("other_config.key_count"))
        _ := g.AddDropDownList("yp AltSubmit", [lang("other_config.key_count_off"), lang("other_config.key_count_on")])
        _.Value := enableKeyCount + 1
        _.OnEvent("Change", fn_keyCount)
        fn_keyCount(item, *) {
            value := item.value - 1
            global enableKeyCount := value
            writeIni("enableKeyCount", value)
            updateTip()
        }

        g.AddText("Section xs", lang("other_config.tray_tip_template"))
        _ := g.AddEdit("w" bw)
        _.Value := trayTipTemplate
        _.OnEvent("Change", e_trayTemplate)
        e_trayTemplate(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := item.value
            global trayTipTemplate := value
            updateTip(A_IsPaused)

            db("trayTipTemplate", value)
        }
        g.AddText("Section xs", lang("other_config.key_count_template"))
        _ := g.AddEdit("w" bw)
        _.Value := keyCountTemplate
        _.OnEvent("Change", e_countTemplate)
        e_countTemplate(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))
            value := item.value
            global keyCountTemplate := value
            updateTip(A_IsPaused)

            db("keyCountTemplate", value)
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" bw, lang("other_config.template_vars"))
        tab.UseTab(3)
        g.AddEdit("Section r15 ReadOnly w" bw, lang("about_text.other_config"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains">JetBrains IDE</a>')

        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            gc.tab := 0
            gc.timer := 0
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        return g
    }
}
