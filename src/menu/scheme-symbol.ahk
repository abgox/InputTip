; InputTip

fn_scheme_symbol(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - " lang("tray.symbol_scheme"))
        tab := g.AddTab3("-Wrap", [lang("tray.symbol_scheme"), lang("common.about")])
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

        g.addText("xs", lang("symbol_scheme.type_label"))
        g.AddDropDownList("yp AltSubmit Choose" symbolType + 1 " w" bw / 2, [lang("symbol_scheme.type_none"), lang("symbol_scheme.type_pic"), lang("symbol_scheme.type_block"), lang("symbol_scheme.type_text")]).OnEvent("Change", e_symbol_type)
        e_symbol_type(item, *) {
            static last := symbolType + 1
            writeIni("symbolType", item.value - 1)
            global symbolType := item.value - 1
            global lastWindow := ""
            global lastSymbol := ""
            updateSymbol()
            reloadSymbol()

            if (item.value != 1 && last == 1) {
                createTipGui([{
                    opt: "",
                    text: lang("symbol_scheme.using_symbol")
                }, {
                    opt: "cRed",
                    text: lang("symbol_scheme.using_symbol_note"),
                }, {
                    opt: "",
                    text: lang("symbol_scheme.using_symbol_link")
                }], "InputTip - " lang("symbol_scheme.symbol_note_title")).Show()
            } else {
                if (symbolType) {
                    gc._focusSymbol.Focus()
                }
            }
            last := item.value
        }

        g.AddText("yp w20")
        gc._focusSymbol := g.AddEdit("yp w1")
        gc._focusSymbol.OnEvent("Focus", fn_clear)
        gc._focusSymbol.OnEvent("LoseFocus", fn_clear)

        g.AddText("xs", line)

        g.addText("xs", lang("symbol_scheme.mode_label"))
        g.AddDropDownList("yp AltSubmit Choose" symbolShowMode " w" bw / 2, [lang("symbol_scheme.mode_realtime"), lang("symbol_scheme.mode_switch")]).OnEvent("Change", e_symbol_mode)
        e_symbol_mode(item, *) {
            value := item.value
            global symbolShowMode := value
            writeIni("symbolShowMode", value)
        }

        g.AddText("xs", lang("symbol_scheme.delay_label"))
        _ := g.AddEdit("yp Number w" bw / 2)
        _.Value := hideSymbolDelay
        _.OnEvent("Change", e_hideSymbolDelay)
        e_hideSymbolDelay(item, *) {
            static db := debounce((config, value) => (
                updateDelay(),
                writeIni(config, value),
                restartJAB()
            ))

            value := item.value
            if (value = "") {
                return
            }
            if (value != 0 && value < 150) {
                value := 150
            }
            global hideSymbolDelay := value

            db("hideSymbolDelay", value)
        }

        g.addText("xs", lang("symbol_scheme.hover_hide_label"))
        g.AddDropDownList("yp AltSubmit Choose" hoverHide + 1 " w" bw / 2, [lang("symbol_scheme.hover_hide_no"), lang("symbol_scheme.hover_hide_yes")]).OnEvent("Change", e_symbol_hover_hide)
        e_symbol_hover_hide(item, *) {
            global hoverHide := item.value - 1
            writeIni("hoverHide", hoverHide)
        }

        g.AddText("xs", line)

        g.AddText("xs", lang("symbol_scheme.offset_base_label"))
        g.AddDropDownList("yp AltSubmit Choose" symbolOffsetBase + 1 " w" bw / 2, [lang("symbol_scheme.offset_above"), lang("symbol_scheme.offset_below")]).OnEvent("Change", e_offset_base)
        e_offset_base(item, *) {
            writeIni("symbolOffsetBase", item.value - 1)
            global symbolOffsetBase := item.value - 1
            updateSymbol()
            reloadSymbol()
            gc._focusSymbol.Focus()
        }

        g.AddText("xs", line)

        _w := bw / 3 - g.MarginX / 3
        g.AddButton("xs w" _w, lang("symbol_scheme.btn_pic")).OnEvent("Click", fn_symbol_pic)
        g.AddButton("yp w" _w, lang("symbol_scheme.btn_block")).OnEvent("Click", fn_symbol_block)
        g.AddButton("yp w" _w, lang("symbol_scheme.btn_text")).OnEvent("Click", fn_symbol_text)


        tab.UseTab(2)
        g.AddEdit("ReadOnly r16 w" bw, lang("about_text.symbol_scheme"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://github.com/abgox/InputTip/issues/145">Github Issue 145</a>')
        return g
    }
}

fn_symbol_pic(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - " lang("symbol_scheme.isolate_pic_title"))
        tab := g.AddTab3("-Wrap", [lang("symbol_scheme.basic_config"), lang("symbol_scheme.isolate_config"), lang("common.about")])
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

        symbolPicConfig := [{
            config: "pic_offset_x",
            textOpt: "Section xs",
            editOpt: "",
            tip: lang("symbol_scheme.h_offset")
        }, {
            config: "pic_offset_y",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.v_offset")
        }, {
            config: "pic_symbol_width",
            textOpt: "yp",
            editOpt: "Number",
            tip: lang("symbol_scheme.width")
        }, {
            config: "pic_symbol_height",
            textOpt: "yp",
            editOpt: "Number",
            tip: lang("symbol_scheme.height")
        }]
        for i, v in symbolPicConfig {
            g.AddText(v.textOpt, v.tip)
            _ := g.AddEdit("yp " v.editOpt " w" bw / 8)
            _._config := v.config
            _.Value := symbolConfig.%v.config%
            _.OnEvent("Change", e_pic_config)
        }

        e_pic_config(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value),
                restartJAB()
            ))

            value := returnNumber(item.value)
            updateSymbol(item._config, value)
            reloadSymbol()

            db(item._config, value)
        }

        picList := StrSplit(symbolPaths, ":")
        if (picList.Length = 0) {
            picList := getPicList("InputTipSymbol", ":InputTipSymbol\default\triangle-red.png:InputTipSymbol\default\triangle-blue.png:InputTipSymbol\default\triangle-green.png:")
        }
        picList.InsertAt(1, '')

        g.AddText("xs", line)
        createGuiOpt("").AddText(, lang("state.CN")).GetPos(, , &__w)
        gc._focusSymbolPic := g.AddEdit("yp w1")
        gc._focusSymbolPic.OnEvent("Focus", fn_clear)
        gc._focusSymbolPic.OnEvent("LoseFocus", fn_clear)

        for v in ["CN", "EN", "Caps"] {
            g.AddText("xs", getStateName(v) ":")
            _ := g.AddDropDownList("yp r9 w" bw - __w - g.MarginX, picList)
            _._config := v "_pic"
            _.OnEvent("Change", e_pic_path)
            try {
                _.Text := symbolConfig.%v "_pic"%
            } catch {
                _.Text := ""
            }
        }

        e_pic_path(item, *) {
            writeIni(item._config, item.Text)
            updateSymbol()
            reloadSymbol()
            if (symbolType = 1) {
                gc._focusSymbolPic.Focus()
            }
        }

        _w := bw / 3 - g.MarginX / 3
        g.AddButton("xs w" _w, lang("symbol_scheme.open_pic_dir")).OnEvent("Click", (*) => (Run("explorer.exe InputTipSymbol")))
        g.AddButton("yp w" _w, lang("symbol_scheme.refresh_dropdown")).OnEvent("Click", (*) => (
            getPathList(),
            fn_symbol_pic()
        ))
        g.AddButton("yp w" _w, lang("symbol_scheme.download_more_pic")).OnEvent("Click", (*) => (Run("https://inputtip.abgox.com/download/extra")))

        tab.UseTab(2)

        g.AddText("Section", lang("symbol_scheme.enable_init"))
        g.AddText("yp cRed", lang("symbol_scheme.btn_pic"))
        g.AddText("yp", lang("symbol_scheme.isolate_for"))
        _ := g.AddDropDownList("yp AltSubmit", [lang("common.no"), lang("common.yes")])
        _.Value := symbolConfig.enableIsolateConfigPic + 1
        _._config := "enableIsolateConfigPic"
        _.OnEvent("Change", fn_setIsolateConfig)

        g.AddText("xs", line)
        for state in ["CN", "EN", "Caps"] {
            g.AddText("xs cRed", getStateName(state))
            g.AddText("yp", ":")
            for v in symbolPicConfig {
                config := v.config state
                g.AddText(v.textOpt, v.tip)
                _g := g.AddEdit("yp " v.editOpt " w" bw / 8)
                _g.Value := symbolConfig.%config%
                _g._config := config
                _g._type := "enableIsolateConfigPic"
                _g.OnEvent("Change", fn_writeIsolateConfig)
            }
        }

        tab.UseTab(3)
        g.AddEdit("ReadOnly r11 w" bw, lang("about_text.symbol_pic_isolate"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/zh-CN/faq/symbol-picture">Picture Symbol</a>')
        return g
    }
}

fn_symbol_block(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - " lang("symbol_scheme.isolate_block_title"))
        tab := g.AddTab3("-Wrap", [lang("symbol_scheme.basic_config"), lang("symbol_scheme.isolate_config"), lang("common.about")])
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

        symbolBlockColorConfig := [{
            config: "CN_color",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.color_cn"),
            colors: ["red", "FF5555", "F44336", "D23600", "FF1D23", "D40D12", "C30F0E", "5C0002", "450003"]
        }, {
            config: "EN_color",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.color_en"),
            colors: ["blue", "528BFF", "0EEAFF", "59D8E6", "2962FF", "1B76FF", "2C1DFF", "1C3FFD", "1510F0"]
        }, {
            config: "Caps_color",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.color_caps"),
            colors: ["green", "4E9A06", "96ED89", "66BB6A", "8BC34A", "45BF55", "43A047", "2E7D32", "33691E"]
        }]
        symbolBlockConfig := [{
            config: "offset_x",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.h_offset")
        }, {
            config: "symbol_width",
            textOpt: "yp",
            editOpt: "Number",
            tip: lang("symbol_scheme.width")
        }, {
            config: "transparent",
            textOpt: "yp",
            editOpt: "Number Limit3",
            tip: lang("symbol_scheme.transparency")
        }, {
            config: "offset_y",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.v_offset")
        }, {
            config: "symbol_height",
            textOpt: "yp",
            editOpt: "Number",
            tip: lang("symbol_scheme.height")
        }]

        for v in symbolBlockColorConfig {
            g.AddText(v.textOpt, v.tip)
            _ := g.AddComboBox("yp " v.editOpt, v.colors)
            _._config := v.config
            _.Text := symbolConfig.%v.config%
            _.OnEvent("Change", e_color_config)
        }
        e_color_config(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value),
                restartJAB()
            ))

            value := item.Text
            updateSymbol(item._config, value)
            reloadSymbol()

            db(item._config, value)
        }

        g.AddText("xs", line)
        for v in symbolBlockConfig {
            g.AddText(v.textOpt, v.tip)
            _ := g.AddEdit("yp " v.editOpt " w" bw / 6)
            _._config := v.config
            _.Value := symbolConfig.%v.config%
            _.OnEvent("Change", e_block_config)
        }
        e_block_config(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value),
                restartJAB()
            ))

            value := returnNumber(item.value)
            if (item._config = "transparent") {
                if (value = "") {
                    return
                }
                if (value > 255) {
                    value := 255
                }
            }
            updateSymbol(item._config, value)
            reloadSymbol()

            db(item._config, value)
        }

        symbolStyle := [lang("symbol_scheme.style_none"), lang("symbol_scheme.style_1"), lang("symbol_scheme.style_2"), lang("symbol_scheme.style_3")]
        g.AddText("yp", lang("symbol_scheme.border_style"))
        _ := g.AddDropDownList("yp AltSubmit w" bw / 6, symbolStyle)
        _.Value := symbolConfig.border_type + 1
        _._config := "border_type"
        _.OnEvent("Change", fn_border_config)
        g.AddText("yp w20")
        _._focus := g.AddEdit("yp w1")
        _._focus.OnEvent("Focus", fn_clear)
        _._focus.OnEvent("LoseFocus", fn_clear)

        tab.UseTab(2)
        g.AddText("Section cRed", lang("gui.help_tip"))
        g.AddText("xs", line)

        g.AddText("xs", lang("symbol_scheme.enable_init"))
        g.AddText("yp cRed", lang("symbol_scheme.btn_block"))
        g.AddText("yp", lang("symbol_scheme.isolate_for"))
        _ := g.AddDropDownList("yp AltSubmit", [lang("common.no"), lang("common.yes")])
        _.Value := symbolConfig.enableIsolateConfigBlock + 1
        _._config := "enableIsolateConfigBlock"
        _.OnEvent("Change", fn_setIsolateConfig)
        g.AddButton("xs w" bw, lang("symbol_scheme.isolate_btn")).OnEvent("Click", e_blockIsolateConfig)
        e_blockIsolateConfig(*) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            createGui(blockConfigGui).Show()
            blockConfigGui(info) {
                g := createGuiOpt("InputTip - " lang("symbol_scheme.isolate_block_title"))
                g.AddText("cRed", lang("symbol_scheme.btn_block"))
                g.AddText("yp", lang("symbol_scheme.isolate_for"))
                g.AddText("xs", "-----------------------------------------------")

                if (info.i) {
                    return g
                }

                configList := [{
                    config: "offset_x",
                    textOpt: "xs",
                    editOpt: "",
                    tip: lang("symbol_scheme.h_offset")
                }, {
                    config: "offset_y",
                    textOpt: "xs",
                    editOpt: "",
                    tip: lang("symbol_scheme.v_offset")
                }, {
                    config: "symbol_width",
                    textOpt: "xs",
                    editOpt: "Number",
                    tip: lang("symbol_scheme.width")
                }, {
                    config: "symbol_height",
                    textOpt: "xs",
                    editOpt: "Number",
                    tip: lang("symbol_scheme.height")
                }, {
                    config: "transparent",
                    textOpt: "xs",
                    editOpt: "Number Limit3",
                    tip: lang("symbol_scheme.transparency")
                }]

                tab := g.AddTab3("-Wrap", [lang("state.CN"), lang("state.EN"), lang("state.Caps")])
                for i, state in ["CN", "EN", "Caps"] {
                    tab.UseTab(i)
                    g.AddText("Section cRed", getStateName(state))
                    g.AddText("yp", lang("symbol_scheme.isolate_suffix"))

                    ; 颜色
                    config := state "_color"
                    g.AddText("xs", lang("symbol_scheme.color_label"))
                    _g := g.AddEdit("yp")
                    _g.Value := symbolConfig.%config%
                    _g._config := config
                    _g._type := "enableIsolateConfigBlock"
                    _g.OnEvent("Change", fn_writeIsolateConfig)

                    for v in configList {
                        config := v.config state
                        g.AddText(v.textOpt, v.tip)
                        _g := g.AddEdit("yp " v.editOpt)
                        _g.Value := symbolConfig.%config%
                        _g._config := config
                        _g._type := "enableIsolateConfigBlock"
                        _g.OnEvent("Change", fn_writeIsolateConfig)
                    }
                    config := "border_type" state
                    g.AddText("xs", lang("symbol_scheme.border_style"))
                    _ := g.AddDropDownList("yp AltSubmit", symbolStyle)
                    _.Value := symbolConfig.%config% +1
                    _._config := config
                    _.OnEvent("Change", fn_border_config)
                    g.AddText("yp w20")
                    _._focus := g.AddEdit("yp w1")
                    _._focus.OnEvent("Focus", fn_clear)
                    _._focus.OnEvent("LoseFocus", fn_clear)
                }
                g.AddText()
                gc.w.subGui := g
                return g
            }
        }

        tab.UseTab(3)
        g.AddEdit("ReadOnly r10 w" bw, lang("about_text.symbol_block_isolate"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/zh-CN/faq/symbol-block">Block Symbol</a>   <a href="https://inputtip.abgox.com/faq/color-config">Color Config</a>')
        return g
    }
}

fn_symbol_text(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - " lang("symbol_scheme.isolate_text_title"))
        tab := g.AddTab3("-Wrap", [lang("symbol_scheme.basic_config"), lang("symbol_scheme.isolate_config"), lang("common.about")])
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

        symbolConfigChar := [{
            config: "CN_Text",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.color_cn")
        }, {
            config: "EN_Text",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.color_en")
        }, {
            config: "Caps_Text",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.color_caps")
        }]
        symbolConfigBgColor := [{
            config: "textSymbol_CN_color",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.color_cn")
        }, {
            config: "textSymbol_EN_color",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.color_en")
        }, {
            config: "textSymbol_Caps_color",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.color_caps")
        }]

        symbolTextConfig := [{
            config: "font_family",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.font_family")
        }, {
            config: "font_color",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.font_color")
        }, {
            config: "textSymbol_offset_x",
            textOpt: "xs",
            editOpt: "",
            tip: lang("symbol_scheme.h_offset")
        }, {
            config: "textSymbol_offset_y",
            textOpt: "yp",
            editOpt: "",
            tip: lang("symbol_scheme.v_offset")
        }, {
            config: "textSymbol_transparent",
            textOpt: "yp",
            editOpt: "Number Limit3",
            tip: lang("symbol_scheme.transparency")
        }, {
            config: "font_size",
            textOpt: "xs",
            editOpt: "Number",
            tip: lang("symbol_scheme.font_size")
        }, {
            config: "font_weight",
            textOpt: "yp",
            editOpt: "Number",
            tip: lang("symbol_scheme.font_weight")
        }]

        g.AddText("xs cRed", lang("symbol_scheme.text_symbol_label"))

        for v in symbolConfigChar {
            g.AddText(v.textOpt, v.tip)
            _ := g.AddEdit("yp " v.editOpt " w" bw / 8)
            _._config := v.config
            _.Text := symbolConfig.%v.config%
            _.OnEvent("Change", e_text_config)
        }

        g.AddText("xs cRed", lang("symbol_scheme.bg_color"))

        for v in symbolConfigBgColor {
            g.AddText(v.textOpt, v.tip)
            _ := g.AddEdit("yp " v.editOpt " w" bw / 8)
            _._config := v.config
            _.Text := symbolConfig.%v.config%
            _.OnEvent("Change", e_text_config)
        }

        g.AddText("xs", line)

        for i, v in symbolTextConfig {
            g.AddText(v.textOpt, v.tip)
            if (v.config = "font_family") {
                _ := g.AddComboBox("yp AltSubmit r9" v.editOpt, fontList)
            } else {
                if (i > 2) {
                    _ := g.AddEdit("yp " v.editOpt " w" bw / 8)
                } else {
                    _ := g.AddEdit("yp " v.editOpt)
                }
            }
            _._config := v.config
            _.Text := symbolConfig.%v.config%
            _.OnEvent("Change", e_text_config)
        }
        e_text_config(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value),
                restartJAB()
            ))

            value := item.Text
            if (item._config = "textSymbol_transparent") {
                if (value = "") {
                    return
                }
                if (value > 255) {
                    value := 255
                }
            } else if (item._config = "textSymbol_offset_x" || item._config = "textSymbol_offset_y") {
                value := returnNumber(value)
            }
            updateSymbol(item._config, value)
            reloadSymbol()
            db(item._config, value)
        }

        symbolStyle := [lang("symbol_scheme.style_none"), lang("symbol_scheme.style_1"), lang("symbol_scheme.style_2"), lang("symbol_scheme.style_3")]
        g.AddText("yp", lang("symbol_scheme.border_style"))
        _ := g.AddDropDownList("yp AltSubmit w" bw / 6, symbolStyle)
        _.Value := symbolConfig.textSymbol_border_type + 1
        _._config := "textSymbol_border_type"
        _.OnEvent("Change", fn_border_config)
        g.AddText("yp w20")
        _._focus := g.AddEdit("yp w1")
        _._focus.OnEvent("Focus", fn_clear)
        _._focus.OnEvent("LoseFocus", fn_clear)

        tab.UseTab(2)
        g.AddText("Section cRed", lang("gui.help_tip"))
        g.AddText("xs", line)

        g.AddText("xs", lang("symbol_scheme.enable_init"))
        g.AddText("yp cRed", lang("symbol_scheme.btn_text"))
        g.AddText("yp", lang("symbol_scheme.isolate_for"))
        _ := g.AddDropDownList("yp AltSubmit w" bw / 2, [lang("common.no"), lang("common.yes")])
        _.Value := symbolConfig.enableIsolateConfigText + 1
        _.OnEvent("Change", fn_setIsolateConfig)
        _._config := "enableIsolateConfigText"
        g.AddButton("xs w" bw, lang("symbol_scheme.isolate_btn")).OnEvent("Click", e_textIsolateConfig)
        e_textIsolateConfig(*) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            createGui(blockConfigGui).Show()
            blockConfigGui(info) {
                g := createGuiOpt("InputTip - " lang("symbol_scheme.isolate_text_title"))
                g.AddText("cRed", lang("symbol_scheme.btn_text"))
                g.AddText("yp", lang("symbol_scheme.isolate_for"))
                g.AddText("xs", "----------------------------------------------------")

                if (info.i) {
                    return g
                }

                configList := [{
                    config: "font_family",
                    textOpt: "xs",
                    editOpt: "",
                    tip: lang("symbol_scheme.font_family")
                }, {
                    config: "font_size",
                    textOpt: "xs",
                    editOpt: "Number",
                    tip: lang("symbol_scheme.font_size")
                }, {
                    config: "font_weight",
                    textOpt: "xs",
                    editOpt: "",
                    tip: lang("symbol_scheme.font_weight")
                }, {
                    config: "font_color",
                    textOpt: "xs",
                    editOpt: "",
                    tip: lang("symbol_scheme.font_color")
                }, {
                    config: "textSymbol_offset_x",
                    textOpt: "xs",
                    editOpt: "",
                    tip: lang("symbol_scheme.h_offset")
                }, {
                    config: "textSymbol_offset_y",
                    textOpt: "xs",
                    editOpt: "Number Limit3",
                    tip: lang("symbol_scheme.v_offset")
                }, {
                    config: "textSymbol_transparent",
                    textOpt: "xs",
                    editOpt: "Number Limit3",
                    tip: lang("symbol_scheme.transparency")
                }]

                tab := g.AddTab3("-Wrap", [lang("state.CN"), lang("state.EN"), lang("state.Caps")])
                for i, state in ["CN", "EN", "Caps"] {
                    tab.UseTab(i)
                    g.AddText("Section cRed", getStateName(state))
                    g.AddText("yp", lang("symbol_scheme.isolate_suffix"))

                    ; 文本字符
                    config := state "_Text"
                    g.AddText("xs", lang("symbol_scheme.text_symbol_label"))
                    _g := g.AddEdit("yp")
                    _g.Text := symbolConfig.%config%
                    _g._config := config
                    _g._type := "enableIsolateConfigText"
                    _g.OnEvent("Change", fn_writeIsolateConfig)

                    ; 背景颜色
                    config := "textSymbol_" state "_color"
                    g.AddText("xs", lang("symbol_scheme.bg_color"))
                    _g := g.AddEdit("yp")
                    _g.Text := symbolConfig.%config%
                    _g._config := config
                    _g._type := "enableIsolateConfigText"
                    _g.OnEvent("Change", fn_writeIsolateConfig)


                    for v in configList {
                        config := v.config state
                        g.AddText(v.textOpt, v.tip)

                        if (v.config = "font_family") {
                            _g := g.AddComboBox("yp AltSubmit r9 " v.editOpt, fontList)
                        } else {
                            _g := g.AddEdit("yp " v.editOpt)
                        }
                        _g.Text := symbolConfig.%config%
                        _g._config := config
                        _g._type := "enableIsolateConfigText"
                        _g.OnEvent("Change", fn_writeIsolateConfig)
                    }
                    config := "textSymbol_border_type" state
                    g.AddText("xs", lang("symbol_scheme.border_style"))
                    _ := g.AddDropDownList("yp AltSubmit", symbolStyle)
                    _.Value := symbolConfig.%config% +1
                    _._config := config
                    _.OnEvent("Change", fn_border_config)
                    g.AddText("yp w20")
                    _._focus := g.AddEdit("yp w1")
                    _._focus.OnEvent("Focus", fn_clear)
                    _._focus.OnEvent("LoseFocus", fn_clear)
                }
                g.AddText()
                gc.w.subGui := g
                return g
            }
        }

        tab.UseTab(3)
        g.AddEdit("ReadOnly r11 w" bw, lang("about_text.symbol_text_isolate"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/zh-CN/faq/symbol-text">Text Symbol</a>   <a href="https://inputtip.abgox.com/faq/color-config">Color Config</a>   <a href="https://inputtip.abgox.com/zh-CN/faq/font-config">Font Config</a>')
        return g
    }
}

fn_clear(item, *) {
    item.value := ""
}

fn_border_config(item, *) {
    writeIni(item._config, item.value - 1)
    updateSymbol()
    reloadSymbol()
    if (symbolType) {
        item._focus.Focus()
    }
}

fn_setIsolateConfig(item, *) {
    writeIni(item._config, item.value - 1)
    updateSymbol()
    reloadSymbol()
}


fn_writeIsolateConfig(item, *) {
    static db := debounce((config, value) => (
        writeIni(config, value),
        restartJAB()
    ))

    value := RegExMatch(item._config, "color|font|Text") ? item.Text : returnNumber(item.Text)
    db(item._config, value)

    if (symbolType && symbolConfig.%item._type%) {
        updateSymbol(item._config, value)
        reloadSymbol()
    }
}
