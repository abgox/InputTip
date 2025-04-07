; InputTip

fn_input_mode(*) {
    if (gc.w.inputModeGui) {
        gc.w.inputModeGui.Destroy()
        gc.w.inputModeGui := ""
        try {
            gc.w.customModeGui.Destroy()
            gc.w.customModeGui := ""
        }
        try {
            gc.w.shiftSwitchGui.Destroy()
            gc.w.shiftSwitchGui := ""
        }
    }
    createGui(inputModeGui).Show()
    inputModeGui(info) {
        global mode := readIni("mode", 1, "InputMethod")

        g := createGuiOpt("InputTip - 设置输入法模式")
        gc.modeList := ["【自定义】", "【通用】"]
        tab := g.AddTab3("-Wrap", ["基础配置", "自定义", "关于自定义"])
        tab.UseTab(1)
        g.AddText("Section cRed", "如果【通用】模式不可用，需要点击上方的「自定义」标签页去配置【自定义】模式")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, "1. 当前使用的输入法模式:")
        gc.mode := g.AddText("yp cRed w" w / 2)
        gc.mode.Value := gc.modeList[mode + 1]
        g.AddEdit("xs ReadOnly cGray w" w, "输入法模式只有【通用】和【自定义】，这里显示的模式会根据实际的配置情况自动变化")
        g.AddText("xs", "2. 设置获取输入法状态的超时时间: ")
        timeout := g.AddEdit("yp Number Limit5")
        timeout.Focus()
        timeout.OnEvent("Change", e_setTimeout)
        e_setTimeout(item, *) {
            value := item.value
            if (value = "") {
                return
            }
            writeIni("checkTimeout", value, "InputMethod")
            global checkTimeout := value
            restartJAB()
        }
        timeout.Value := checkTimeout
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "单位：毫秒，默认 500 毫秒`n每次切换输入法状态，InputTip 会从系统获取新的输入法状态`n如果超过了这个时间，则认为获取失败，直接显示英文状态`n它可能是有时识别不到输入法状态的原因，遇到问题可以尝试调节它")
        g.AddText("xs", "3. Shift 键是否可以正常切换输入法状态: ")
        gc.useShift := g.AddDropDownList("yp Choose" useShift + 1, ["【否】(慎重选择)", "【是】"])
        gc.useShift.OnEvent("Change", e_useShift)
        e_useShift(item, *) {
            if (useShift = item.value) {
                if (gc.w.shiftSwitchGui) {
                    gc.w.shiftSwitchGui.Destroy()
                    gc.w.shiftSwitchGui := ""
                }
                createGui(warningGui).Show()
                warningGui(info) {
                    gc.useShift.Value := useShift + 1

                    g := createGuiOpt("InputTip - 警告")
                    g.AddText(, "确定要使用【否】吗？")
                    g.AddText("cRed", "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择【否】`n如果选择【否】，在美式键盘(ENG)或部分特殊输入法中，可能会导致状态提示间歇性错误")
                    g.AddText("cRed", "建议不要使用【否】，而是启用 Shift 切换状态，这也是几乎所有输入法的默认设置")

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    g.AddButton("w" bw, "我确定要使用【否】").OnEvent("Click", e_yes)
                    g.AddButton("w" bw, "我只是不小心点错了").OnEvent("Click", e_no)
                    e_yes(*) {
                        g.Destroy()
                        gc.useShift.Value := 1
                        writeIni("useShift", 0)
                        global useShift := 0
                    }
                    e_no(*) {
                        g.Destroy()
                    }
                    gc.w.shiftSwitchGui := g
                    return g
                }
            } else {
                value := item.value - 1
                writeIni("useShift", value)
                global useShift := value
                restartJAB()
            }
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择【否】`n如果选择【否】，在美式键盘(ENG)或部分特殊输入法中，可能会导致状态提示间歇性错误")
        tab.UseTab(2)

        g.AddText("Section ReadOnly cRed -VScroll w" w, "首先需要点击上方的「关于自定义」标签页，查看帮助说明，了解如何设置")
        g.AddText("xs cGray", "如果添加了至少一条规则，则自动变为【自定义】模式，反之变回【通用】模式")

        g.AddText("Section", "如果所有规则都不匹配，应该判断为: ")
        g.AddDropDownList("yp Choose" baseStatus + 1, [" 英文状态", " 中文状态"]).OnEvent("Change", e_changeBaseStatus)
        e_changeBaseStatus(item, *) {
            value := item.Value - 1
            writeIni("baseStatus", value, "InputMethod")
            global baseStatus := value
        }

        gc.input_mode_LV := _ := g.AddListView("xs -LV0x10 -Multi r5 NoSortHdr Grid w" w, ["顺序", "状态码规则", "切换码规则", "输入法状态"])
        fn_reloading_LV(_)

        _.OnEvent("DoubleClick", e_edit)
        e_edit(LV, RowNumber) {
            fn_edit(LV, RowNumber)
        }

        g.AddButton("xs w" w, "添加规则").OnEvent("Click", e_addRule)
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
                typeText := "添加"
            } else {
                rule := modeRules[RowNumber]
                r := StrSplit(rule, "*")

                ruleInfo := {
                    statusRule: r[1],
                    conversionRule: r[2],
                    status: r[3],
                }
                typeText := "编辑"
            }

            createGui(editRuleGui).Show()
            editRuleGui(info) {
                g := createGuiOpt("InputTip - " typeText "规则")

                _gc := {
                    statusNum: "",
                    statusRule: "",
                    conversionNum: "",
                    conversionRule: "",
                    order: RowNumber,
                }

                g.AddText(, "1. 顺序: ")

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

                g.AddText("xs", "2. 状态码规则: ")
                g.AddText("xs", "     - 指定数字: ")

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

                g.AddText("xs", "     - 指定规律: ")

                _gc.statusRule := _ := g.AddDropDownList("yp", ["", "使用奇数", "使用偶数"])
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

                g.addText("xs", "3. 切换码规则: ")
                g.AddText("xs", "     - 指定数字: ")
                _gc.conversionNum := _ := g.AddEdit("yp", "")
                if (!InStr(ruleInfo.conversionRule, "oddNum") && !InStr(ruleInfo.conversionRule, "evenNum")) {
                    _.Value := ruleInfo.conversionRule
                }
                _.OnEvent("Change", e_conversionMode)
                e_conversionMode(item, *) {
                    ruleInfo.conversionRule := item.value
                    _gc.conversionRule.value := 0
                }

                g.AddText("xs", "     - 指定规律: ")
                _gc.conversionRule := _ := g.AddDropDownList("yp", ["", "使用奇数", "使用偶数"])
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

                g.AddText("xs", "4. 输入法状态: ")
                _ := g.AddDropDownList("yp", ["英文", "中文"])
                _.value := ruleInfo.status + 1
                _.OnEvent("Change", e_changeStatus)
                e_changeStatus(item, *) {
                    v := item.Value
                    ruleInfo.status := v - 1
                }

                g.AddButton("xs w" bw, "完成" typeText).OnEvent("Click", e_set)
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
                    if (modeRules.Length) {
                        global mode := 0
                        writeIni("mode", 0, "InputMethod")
                        gc.mode.Value := gc.modeList[1]
                    }

                    fn_reloading_LV(LV)
                }
                if (!add) {
                    g.AddButton("xs w" bw, "删除此条规则").OnEvent("Click", e_del)
                    e_del(*) {
                        g.Destroy()
                        LV.Delete(RowNumber)
                        autoHdrLV(LV)
                        modeRules.RemoveAt(RowNumber)
                        if (!modeRules.Length) {
                            global mode := 1
                            writeIni("mode", 1, "InputMethod")
                            gc.mode.Value := gc.modeList[2]
                        }
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
            colList.Push(sm == "oddNum" ? "奇数" : sm == "evenNum" ? "偶数" : sm)
            colList.Push(cm == "oddNum" ? "奇数" : cm == "evenNum" ? "偶数" : cm)
            colList.Push(status ? "中文" : "英文")
            return colList
        }

        gc.status_btn := g.AddButton("xs w" w, "显示实时的状态码和切换码")
        gc.status_btn.OnEvent("Click", e_showStatus)
        e_showStatus(*) {
            if (gc.timer) {
                gc.timer := 0
                gc.status_btn.Text := "显示实时的状态码和切换码"
                return
            }

            gc.timer := 1
            gc.status_btn.Text := "停止显示实时的状态码和切换码"

            SetTimer(statusTimer, 25)
            statusTimer() {
                if (!gc.timer) {
                    ToolTip()
                    SetTimer(, 0)
                    return
                }

                info := IME.CheckInputMode()
                ToolTip("状态码: " info.statusMode "`n切换码: " info.conversionMode)
            }
        }
        tab.UseTab(3)
        g.AddText("cRed", "下方以讯飞，小狼毫(rime)，手心这几种输入法进行举例说明`n你需要完整阅读整个帮助说明，看完之后，就知道需要如何设置了")
        g.AddEdit("Section r12 ReadOnly w" w, "1. 【自定义】模式的核心逻辑`n   - 通过系统返回的状态码和切换码，通过规则匹配，告诉 InputTip 当前是什么状态`n   - 通过「添加规则」按钮添加，只要有一条规则存在，就会自动变为【自定义】模式`n   - 双击规则列表中的任意一条规则，可以进行修改`n   - 规则会按照顺序匹配，如果匹配成功，将判断输入法为对应状态`n   - 因此，如果你同时使用多个输入法，可以尝试通过【自定义】模式实现兼容`n2. 如何进行设置？`n   - 下方示例中，「如果所有规则都不匹配，应该判断为」这个配置选择 「英文状态」`n   - 首先以【讯飞输入法】为例`n   - 点击「显示实时的状态码和切换码」按钮，会在鼠标光标处显示状态码和切换码`n   - 来回切换输入法的中英文状态观察它们的变化`n   - 会发现切换码始终为 1，而状态码在英文时为 1，中文时为 2`n   - 因此，可以添加一条规则，状态码规则中指定数字 2，输入法状态选择中文`n   - 当状态码为 2 时，就会匹配到这条规则，于是 InputTip 会判断当前输入法状态为中文`n   - 再比如【小狼毫(rime)输入法】，按照同样的操作流程，你会发现很大的不同`n   - 它的状态码始终为 1，而切换码在英文时是随机的偶数，中文时是随机的奇数`n   - 因此，在切换码规则中直接指定规律「使用奇数」即可`n   - 当然，不要盲目的使用指定规律扩大范围，比如【手心输入法】就不能这样做`n   - 当使用【手心输入法】按照同样的流程操作时`n   - 它的状态码始终为 1，而切换码在英文时为 1，中文时为 1025`n   - 因此，在切换码规则中指定数字 1025 即可`n   - 但是，这里就不能指定规律「使用奇数」，因为英文时的 1 也是奇数`n3. 关于状态码规则和切换码规则`n   - 你可以同时设置状态码和切换码的规则`n   - 比如: 我希望匹配状态码为 1，切换码为 2，将它们分别填入两者的指定数字中即可`n4. 关于指定数字`n   - 如果你希望规则可以匹配多个数字，在指定数字中，用 / 分割即可`n   - 假如你希望状态码不管是 1 还是 2 都应该匹配成功，直接指定数字 1/2 即可")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/custom-input-mode">自定义模式</a>')
        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            gc.timer := 0
            try {
                gc.w.customModeGui.Destroy()
                gc.w.customModeGui := ""
            }
            try {
                gc.w.shiftSwitchGui.Destroy()
                gc.w.shiftSwitchGui := ""
            }
        }
        gc.w.inputModeGui := g
        return g
    }
}
