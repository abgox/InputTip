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
        tab := g.AddTab3("-Wrap", ["基础配置", "自定义", "关于自定义", "关于切换输入法状态"])
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
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "单位：毫秒，默认 500 毫秒`n每次切换输入法状态，InputTip 会从系统获取新的输入法状态`n如果超过了这个时间，则认为获取失败，直接判断为英文状态`n它可能是有时识别不到输入法状态的原因，遇到问题可以尝试调节它")
        g.AddText("xs", "3. 指定内部实现切换输入法状态的方式: ")
        gc.useShift := g.AddDropDownList("yp Choose" useShift + 1, ["内部调用 DLL", "模拟输入 LShift", "模拟输入 RShift"])
        gc.useShift.OnEvent("Change", e_useShift)
        e_useShift(item, *) {
            value := item.value - 1
            writeIni("useShift", value)
            global useShift := value
            restartJAB()
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "如果想修改这个配置，需要先通过上方的「关于切换输入法状态」标签页了解详情")
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

        gc.input_mode_LV := _ := g.AddListView("xs -LV0x10 -Multi r4 NoSortHdr Grid w" w, ["匹配的顺序", "状态码规则", "切换码规则", "输入法状态"])
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

                g.AddText(, "1. 匹配的顺序: ")

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

                g.AddText("xs", "2. 输入法状态: ")
                _ := g.AddDropDownList("yp", ["英文", "中文"])
                _.value := ruleInfo.status + 1
                _.OnEvent("Change", e_changeStatus)
                e_changeStatus(item, *) {
                    v := item.Value
                    ruleInfo.status := v - 1
                }

                g.AddText("xs", "3. 状态码规则: ")
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

                g.addText("xs", "4. 切换码规则: ")
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
        g.AddText("cRed", "使用【自定义】模式之前，务必仔细阅读下方的帮助说明，查看相关链接")
        g.AddEdit("Section r12 ReadOnly w" w, "1. 为什么需要【自定义】模式`n   - InputTip 是通过系统返回的状态码和切换码来判断当前的输入法状态的`n   - 对于多数常用的输入法来说【通用】模式是可以正常识别的`n   - 但是部分输入法会使系统返回的状态码和切换码很特殊，无法统一处理`n   - 在这种情况下，就需要用户通过规则来告诉 InputTip 当前的输入法状态`n`n2. 【自定义】模式的工作机制`n   - InputTip 会从系统获取到当前的状态码和切换码，通过定义的规则列表进行顺序匹配`n   - 每一条规则对应一种输入法状态，如果匹配成功，则判断为此状态`n   - 因此，如果你同时使用多个输入法，可以尝试通过【自定义】模式实现兼容`n`n3. 默认状态`n   -「如果所有规则都不匹配，应该判断为」这个配置项会指定一个默认状态`n   - 如果规则列表中的所有规则都没有匹配成功，就会使用这个默认状态`n`n4. 规则列表`n   - 规则列表就是上方的「自定义」标签页中的表格`n   - 添加规则: 点击「添加规则」按钮，在弹窗中进行规则设置`n   - 修改规则: 双击规则列表中已经存在的任意一条规则，在弹窗中进行规则修改`n   - 删除规则: 双击规则列表中已经存在的任意一条规则，在弹窗中点击「删除此条规则」`n`n5. 规则设置`n   - 点击「显示实时的状态码和切换码」，通过切换输入法状态，查看不同状态下的区别`n   - 当点击「添加规则」按钮后，会出现一个规则设置弹窗`n   - 弹窗中包含 4 个设置: 匹配的顺序、输入法状态、状态码规则、切换码规则`n      - 匹配的顺序：用来指定这一条规则在规则列表中的顺序`n      - 其余 3 个设置会在下方逐个解释`n`n6. 规则设置 —— 输入法状态`n   - 它用来指定这一条规则对应的输入法状态`n   - 当这一条规则匹配成功后，InputTip 就会认为当前输入法状态为这一状态`n`n7. 规则设置 —— 状态码规则、切换码规则`n   - 有两种形式可以选择: 指定数字或指定规律`n   - 这两种形式只能选择其中一种，它们会在下方进行详细解释`n   - 需要注意的是，你可以同时设置状态码规则和切换码规则`n   - 如果同时设置，则表示此条规则需要状态码规则和切换码规则都匹配`n`n8. 规则设置 —— 指定数字`n   - 你可以填入一个或多个数字，只要其中有一个数字匹配成功即可`n   - 如果是多个数字，需要使用 / 连接 (如: 1/3/5)`n   - 如: 你希望当状态码为 1 时匹配到这条规则，在「状态码规则」中填入 1 即可`n   - 如: 你希望当切换码为 1 或 3 时匹配到这条规则，在「切换码规则」中填入 1/3 即可`n`n9. 规则设置 —— 指定规律`n   - 由于部分输入法会使系统返回的状态码和切换码很特殊，呈现某种规律`n   - 比如随机奇数，这种情况无法通过指定数字来表示，因为不可能填入所有的奇数`n   - 对于这种情况，就可以通过指定规律来实现，在下拉列表中选择对应规律即可`n   - 如: 你希望当状态码为随机奇数时匹配到这条规则，选择「使用奇数」即可")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/FAQ/custom-input-mode">自定义模式</a>   <a href="https://inputtip.abgox.com/v2/#输入法兼容情况">输入法兼容情况</a>')

        tab.UseTab(4)
        g.AddEdit("Section r13 ReadOnly w" w, "1. 「指定内部实现切换输入法状态的方式」`n   - InputTip 中的以下功能需要 InputTip 来切换输入法状态`n      -「设置状态切换快捷键」`n      -「指定窗口自动切换状态」`n   - 比如通过「设置状态切换快捷键」设置了 LShift 来切换英文状态`n      - LShift 就是键盘左侧的 Shift 键，以此类推`n      - 当按下 LShift 后，如果当前状态不是英文，就需要 InputTip 自动切换输入法状态`n   - 配置项有 3 个可选值，你需要根据实际情况，选择合适的方式`n      - 模拟输入 LShift`n      - 模拟输入 RShift`n      - 内部调用 DLL`n`n2. 可选值 —— 模拟输入 LShift`n   - 当需要切换输入法状态时，InputTip 会模拟输入一个 LShift 键`n   - 这相当于 InputTip 帮你按了一次键盘左侧的 Shift 键`n   - 只要使用的输入法可以通过左侧的 Shift 键切换输入法状态，就应该使用它`n`n3. 可选值 —— 模拟输入 RShift`n   - 当需要切换输入法状态时，InputTip 会模拟输入一个 RShift 键`n   - 这相当于 InputTip 帮你按了一次键盘右侧的 Shift 键`n   - 只要使用的输入法可以通过右侧的 Shift 键切换输入法状态，就应该使用它`n`n4. 可选值 —— 内部调用 DLL`n   - 当需要切换输入法状态时，InputTip 会直接调用 DLL 接口去设置输入法状态`n   - 这种方式是一种强行设置行为，可能会导致以下问题，不建议使用`n      - 对于部分输入法可能无效`n      - 当需要设置为中文状态时，没有中文状态的键盘(如: 美式键盘)，也会被强行设置`n      - 这会导致基于此的鼠标样式和符号出现暂时的显示错误")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/v2/#输入法兼容情况">输入法兼容情况</a>')
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
