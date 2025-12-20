; InputTip

fn_input_mode(*) {
    createUniqueGui(inputModeGui).Show()
    inputModeGui(info) {
        global mode := readIni("mode", 1, "InputMethod")

        g := createGuiOpt("InputTip - " lang("input_method.title"))
        gc.modeList := [lang("input_method.mode_custom"), lang("input_method.mode_general")]
        tab := g.AddTab3("-Wrap", [lang("input_method.base_config"), lang("input_method.custom"), lang("input_method.about_custom"), lang("input_method.about_switch")])
        tab.UseTab(1)
        g.AddText("Section cRed", lang("gui.help_tip"))

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "----------"

        g.AddText("xs", line)

        g.AddText("xs", lang("input_method.mode_label"))
        g.AddDropDownList("yp Choose" mode + 1, [lang("input_method.mode_custom"), lang("input_method.mode_general")]).OnEvent("Change", e_changeMode)
        e_changeMode(item, *) {
            value := item.value - 1
            global mode := value
            writeIni("mode", value, "InputMethod")
        }
        g.AddText("xs cGray", lang("input_method.mode_tip"))
        g.AddText("xs", lang("input_method.switch_label"))
        gc.switchStatus := g.AddDropDownList("yp Choose" switchStatus + 1, [lang("input_method.switch_dll"), lang("input_method.switch_lshift"), lang("input_method.switch_rshift"), lang("input_method.switch_ctrl_space")])
        gc.switchStatus.OnEvent("Change", e_switchStatus)
        e_switchStatus(item, *) {
            value := item.value - 1
            if (value == 0 || value == 3) {
                configValue := value ? lang("input_method.switch_ctrl_space_tip") : lang("input_method.switch_dll_tip")
                createUniqueGui(warningGui).Show()
                warningGui(info) {
                    gc.switchStatus.Value := switchStatus + 1
                    _g := createGuiOpt("InputTip - " lang("input_method.warning_title"))
                    _g.AddText(, lang("input_method.warning_confirm") configValue)
                    _g.AddText("cRed", lang("input_method.warning_not_recommend"))

                    if (info.i) {
                        return _g
                    }
                    w := info.w
                    bw := w - _g.MarginX * 2

                    _g.AddButton("w" bw, lang("common.yes")).OnEvent("Click", e_yes)
                    _ := _g.AddButton("w" bw, lang("common.no"))
                    _.OnEvent("Click", e_no)
                    e_yes(*) {
                        _g.Destroy()
                        gc.switchStatus.Value := value + 1
                        writeIni("switchStatus", value)
                        global switchStatus := value
                        restartJAB()
                    }
                    e_no(*) {
                        _g.Destroy()
                    }
                    return _g
                }
            }
            else {
                writeIni("switchStatus", value)
                global switchStatus := value
                restartJAB()
            }
        }
        g.AddText("xs cGray", lang("input_method.switch_tip"))
        g.AddText("xs", lang("input_method.keep_caps_label"))
        g.AddDropDownList("yp Choose" keepCapsLock + 1, [lang("input_method.keep_caps_no"), lang("input_method.keep_caps_yes")]).OnEvent("Change", e_changeKeepCapsLock)
        e_changeKeepCapsLock(item, *) {
            value := item.value - 1
            global keepCapsLock := value
            writeIni("keepCapsLock", value)
        }
        g.AddText("xs cGray", lang("input_method.keep_caps_tip"))
        g.AddText("xs", lang("input_method.timeout_label"))
        _ := g.AddEdit("yp Number Limit5")
        _.Focus()
        _.OnEvent("Change", e_setTimeout)
        _.Value := checkTimeout
        e_setTimeout(item, *) {
            static db := debounce((value) => (
                writeIni("checkTimeout", value, "InputMethod"),
                restartJAB()
            ))

            value := item.value

            if value == ""
                return

            if value < 100
                value := 100

            global checkTimeout := value

            db(value)
        }
        g.AddText("xs cGray", lang("input_method.timeout_tip"))
        tab.UseTab(2)

        g.AddText("Section ReadOnly cRed -VScroll w" w, lang("input_method.custom_first_tip"))
        g.AddText("xs", line)

        g.AddText("Section", lang("input_method.default_status"))
        g.AddDropDownList("yp Choose" baseStatus + 1, [lang("input_method.default_en"), lang("input_method.default_cn")]).OnEvent("Change", e_changeBaseStatus)
        e_changeBaseStatus(item, *) {
            value := item.Value - 1
            writeIni("baseStatus", value, "InputMethod")
            global baseStatus := value
        }

        gc.input_mode_LV := _ := g.AddListView("xs -LV0x10 -Multi r6 NoSortHdr Grid w" w, [lang("input_method.lv_order"), lang("input_method.lv_status_rule"), lang("input_method.lv_conv_rule"), lang("input_method.lv_ime_status")])
        fn_reloading_LV(_)

        _.OnEvent("DoubleClick", e_edit)
        e_edit(LV, RowNumber) {
            fn_edit(LV, RowNumber)
        }

        g.AddButton("xs w" w, lang("input_method.add_rule")).OnEvent("Click", e_addRule)
        e_addRule(*) {
            fn_edit(gc.input_mode_LV, modeRules.Length + 1, 1)
        }

        fn_edit(LV, RowNumber, add := 0) {
            if (!RowNumber) {
                return
            }
            if (add) {
                ruleInfo := {
                    statusRule: "",
                    conversionRule: "",
                    status: !baseStatus,
                }
                typeText := lang("input_method.add_rule_title")
            } else {
                rule := modeRules[RowNumber]
                r := StrSplit(rule, "*")

                ruleInfo := {
                    statusRule: r[1],
                    conversionRule: r[2],
                    status: r[3],
                }
                typeText := lang("input_method.edit_rule_title")
            }

            createUniqueGui(editRuleGui).Show()
            editRuleGui(info) {
                g := createGuiOpt("InputTip - " typeText)

                _gc := {
                    statusNum: "",
                    statusRule: "",
                    conversionNum: "",
                    conversionRule: "",
                    order: RowNumber,
                }

                g.AddText(, lang("input_method.order_label"))

                num := 1
                list := []
                while (num <= modeRules.Length + add) {
                    list.Push(" " num)
                    num++
                }
                _ := g.AddDropDownList("yp r9", list)
                _.Value := _gc.order
                _.OnEvent("Change", e_changeOrder)
                e_changeOrder(item, *) {
                    _gc.order := Trim(item.Value)
                }

                g.AddText("xs", lang("input_method.ime_status_label"))
                _ := g.AddDropDownList("yp", [lang("input_method.en_status"), lang("input_method.cn_status")])
                _.value := ruleInfo.status + 1
                _.OnEvent("Change", e_changeStatus)
                e_changeStatus(item, *) {
                    v := item.Value
                    ruleInfo.status := v - 1
                }

                g.AddText("xs", lang("input_method.status_code_label"))
                g.AddText("xs", lang("input_method.specify_number"))

                _gc.statusNum := _ := g.AddEdit("yp", "")

                if (info.i) {
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                if (!InStr(ruleInfo.statusRule, "oddNum") && !InStr(ruleInfo.statusRule, "evenNum")) {
                    _.Value := ruleInfo.statusRule
                }
                _.OnEvent("Change", e_statusMode)
                e_statusMode(item, *) {
                    ruleInfo.statusRule := item.value
                    _gc.statusRule.value := 0
                }

                g.AddText("xs", lang("input_method.specify_pattern"))

                _gc.statusRule := _ := g.AddDropDownList("yp", ["", lang("input_method.odd"), lang("input_method.even")])
                if (ruleInfo.statusRule == "oddNum") {
                    _.Value := 2
                } else if (ruleInfo.statusRule == "evenNum") {
                    _.Value := 3
                }
                _.OnEvent("Change", e_statusRule)
                e_statusRule(item, *) {
                    v := item.Value
                    if (v == 2) {
                        ruleInfo.statusRule := "oddNum"
                    } else if (v == 3) {
                        ruleInfo.statusRule := "evenNum"
                    } else {
                        ruleInfo.statusRule := ""
                    }
                    _gc.statusNum.value := ""
                }

                g.addText("xs", lang("input_method.conv_code_label"))
                g.AddText("xs", lang("input_method.specify_number"))
                _gc.conversionNum := _ := g.AddEdit("yp", "")
                if (!InStr(ruleInfo.conversionRule, "oddNum") && !InStr(ruleInfo.conversionRule, "evenNum")) {
                    _.Value := ruleInfo.conversionRule
                }
                _.OnEvent("Change", e_conversionMode)
                e_conversionMode(item, *) {
                    ruleInfo.conversionRule := item.value
                    _gc.conversionRule.value := 0
                }

                g.AddText("xs", lang("input_method.specify_pattern"))
                _gc.conversionRule := _ := g.AddDropDownList("yp", ["", lang("input_method.odd"), lang("input_method.even")])
                if (ruleInfo.conversionRule == "oddNum") {
                    _.Value := 2
                } else if (ruleInfo.conversionRule == "evenNum") {
                    _.Value := 3
                }
                _.OnEvent("Change", e_conversionRule)
                e_conversionRule(item, *) {
                    v := item.Value
                    if (v == 2) {
                        ruleInfo.conversionRule := "oddNum"
                    } else if (v == 3) {
                        ruleInfo.conversionRule := "evenNum"
                    } else {
                        ruleInfo.conversionRule := ""
                    }
                    _gc.conversionNum.value := ""
                }

                g.AddButton("xs w" bw, (add ? lang("input_method.finish_add") : lang("input_method.finish_edit"))).OnEvent("Click", e_set)
                e_set(*) {
                    g.Destroy()

                    ; 状态码
                    sm := ruleInfo.statusRule
                    ; 切换码
                    cm := ruleInfo.conversionRule
                    ; 输入法状态
                    status := ruleInfo.status

                    if (add) {
                        modeRules.InsertAt(_gc.order, sm "*" cm "*" status)
                    } else {
                        if (_gc.order != RowNumber) {
                            modeRules.RemoveAt(RowNumber)
                            modeRules.InsertAt(_gc.order, sm "*" cm "*" status)
                        } else {
                            modeRules[RowNumber] := sm "*" cm "*" status
                        }
                    }

                    global modeRule := arrJoin(modeRules, ":")
                    writeIni("modeRule", modeRule, "InputMethod")
                    fn_reloading_LV(LV)
                }
                if (!add) {
                    g.AddButton("xs w" bw, lang("input_method.delete_rule")).OnEvent("Click", e_del)
                    e_del(*) {
                        g.Destroy()
                        LV.Delete(RowNumber)
                        autoHdrLV(LV)
                        modeRules.RemoveAt(RowNumber)
                        global modeRule := arrJoin(modeRules, ":")
                        writeIni("modeRule", modeRule, "InputMethod")
                        fn_reloading_LV(LV)
                    }
                }

                return g
            }
        }

        fn_reloading_LV(LV) {
            LV.Delete()
            LV.Opt("-Redraw")

            for i, v in modeRules {
                r := StrSplit(v, "*")
                LV.Add(, i, generateCol(r*)*)
            }
            LV.Opt("+Redraw")
            autoHdrLV(LV)
        }

        /**
         * 生成列信息
         * @param sm 状态码
         * @param cm 切换码
         * @param status 输入法状态
         * @returns {Array} 列信息
         */
        generateCol(sm, cm, status) {
            colList := []
            colList.Push(sm == "oddNum" ? lang("input_method.odd") : sm == "evenNum" ? lang("input_method.even") : sm)
            colList.Push(cm == "oddNum" ? lang("input_method.odd") : cm == "evenNum" ? lang("input_method.even") : cm)
            colList.Push(status ? lang("input_method.cn_status") : lang("input_method.en_status"))
            return colList
        }

        gc.status_btn := g.AddButton("xs w" w, lang("input_method.show_realtime"))
        gc.status_btn.OnEvent("Click", showCode)
        gc.status_btn.OnEvent("DoubleClick", showCodeHotkey)
        showCodeHotkey(*) {
            gc.status_btn.Text := lang("input_method.show_realtime")
            gc.timer := 0

            setHotKeyGui([{
                config: "hotkey_ShowCode",
                tip: lang("input_method.show_realtime_tip")
            }], lang("input_method.show_realtime_tip"))
        }

        tab.UseTab(3)
        g.AddText("cRed", lang("input_method.custom_mode_warning"))
        g.AddEdit("Section r14 ReadOnly w" w, lang("about_text.about_custom"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/faq/custom-input-mode">Custom Mode</a>   <a href="https://inputtip.abgox.com/v2/#ime-compatibility">IME Compatibility</a>')

        tab.UseTab(4)
        g.AddEdit("Section r15 ReadOnly w" w, lang("about_text.about_switch"))
        g.AddLink(, lang("about_text.related_links") '<a href="https://inputtip.abgox.com/v2/#ime-compatibility">IME Compatibility</a>')
        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            gc.timer := 0
        }
        return g
    }
}
