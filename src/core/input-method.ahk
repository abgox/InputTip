; InputTip

e_inputMethod(*) {
    showGui(createUniqueGui(inputModeGui))
    inputModeGui(info) {
        g := createGuiOpt(i18n("inputMethod"))
        tab := renderTab(g, i18n("inputMethod.tab", 1))
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("input-method"))

        if (info.i) {
            g.AddText(, isChinese ? line70 : line90)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        renderRadioGroup(g, "inputMethodDetectionMode", [[".custom", "custom"], [".general", "general"]])
        renderRadioGroup(g, "keepCapsLockWhenStateSwitch", [["yes", 1], ["no", 0]])
        renderRadioGroup(g, "keepCapsLockWhenKeyboardSwitch", [["yes", 1], ["no", 0]])
        renderRadioGroup(g, "exportState", [["yes", 1], ["no", 0]])
        g.AddLink("yp", getDocsLink("inputtip-for-vscode", "InputTip for VSCode"))

        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("input-method/state-detection-mode"))

        renderText(g, "inputMethodBaseState", "xs", "")
        renderDropDownList(g, "inputMethodBaseState", ["EN", "CN"], "yp", "w" bw / 2.45)
        g.AddText("yp w20")
        _ := g.AddCheckbox("yp", i18n("inputMethodDetectionMode.showCode"))
        _.Value := var._showStateCode
        _.OnEvent("Click", (ctrl, *) => (
            val := ctrl.Value, var._showStateCode := val, showStateCode(val)
        ))

        columns := [
            i18n("inputMethodDetectionMode.matchOrder"), i18n("inputMethodDetectionMode.stateCodeRule"), i18n("inputMethodDetectionMode.conversionCodeRule"), i18n("inputMethodDetectionMode.imeState")
        ]

        LV := _ := g.AddListView("xs -LV0x10 -Multi r6 NoSortHdr Grid w" bw, columns)
        reloadLV(_)
        _.OnEvent("DoubleClick", (LV, RowNumber, *) => fn_edit(LV, RowNumber))

        _ := g.AddButton("xs w" bw, i18n("addRule"))
        _.LV := LV
        _.OnEvent("Click", (i, *) => fn_edit(i.LV, var.inputMethodDetectionRules.Length + 1, 1))

        fn_edit(LV, RowNumber, add := 0) {
            if !RowNumber
                return

            if (add) {
                state := var.inputMethodBaseState == "CN" ? "EN" : "CN"
                ruleInfo := {
                    stateRule: "",
                    conversionRule: "",
                    state: i18n(state),
                }
                action := i18n("addRule")
            } else {
                rule := var.inputMethodDetectionRules[RowNumber]
                r := StrSplit(rule, ",")
                ruleInfo := {
                    stateRule: r[1],
                    conversionRule: r[2],
                    state: i18n(r[3]),
                }
                action := i18n("editRule")
            }

            showGui(createUniqueGui(editRuleGui))
            editRuleGui(info) {
                g := createGuiOpt(action)

                if (info.i) {
                    g.AddText(, line50)
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                _gc := {
                    stateNum: "",
                    stateRule: "",
                    conversionNum: "",
                    conversionRule: "",
                    order: RowNumber,
                }

                renderGroupBox(g, "inputMethodDetectionMode.matchOrder", "", "h110 w" bw)
                g.AddText("xs+20 yp+50", i18n("inputMethodDetectionMode.matchOrder.specifyOrder"))

                num := 1
                list := []
                while (num <= var.inputMethodDetectionRules.Length + add) {
                    list.Push(" " num)
                    num++
                }
                _ := g.AddDropDownList("yp r9", list)
                _.Value := _gc.order
                _.OnEvent("Change", (i, *) => _gc.order := Trim(i.Value))

                renderGroupBox(g, "inputMethodDetectionMode.imeState", , "h110 w" bw)
                g.AddText("xs+20 yp+50", i18n("inputMethodDetectionMode.imeState.specifyState"))
                _ := g.AddDropDownList("yp Disabled", [i18n("EN"), i18n("CN")])
                _.Text := ruleInfo.state
                ; _.OnEvent("Change", (i, *) => ruleInfo.state := i.Text)

                renderGroupBox(g, "inputMethodDetectionMode.stateCodeRule", , "h170 w" bw)
                g.AddText("xs+20 yp+55", i18n("inputMethodDetectionMode.number"))

                _gc.stateNum := _ := g.AddEdit("yp r1", "")

                if !InStr(ruleInfo.stateRule, "oddNum") && !InStr(ruleInfo.stateRule, "evenNum")
                    _.Value := ruleInfo.stateRule

                _.OnEvent("Change", (i, *) => (ruleInfo.stateRule := i.Value, _gc.stateRule.value := 0))

                g.AddText("xs+20 yp+55", i18n("inputMethodDetectionMode.rule"))
                _gc.stateRule := _ := g.AddDropDownList("yp",
                    [
                        "", i18n("inputMethodDetectionMode.rule.odd"), i18n("inputMethodDetectionMode.rule.even")
                    ]
                )
                switch ruleInfo.stateRule {
                    case "oddNum":
                        _.Value := 2
                    case "evenNum":
                        _.Value := 3
                }
                _.OnEvent("Change", (i, *) => (
                    ruleInfo.stateRule := i.value == 2 ? "oddNum" : i.value == 3 ? "evenNum" : "",
                    _gc.stateNum.value := ""
                ))

                renderGroupBox(g, "inputMethodDetectionMode.conversionCodeRule", , "h170 w" bw)
                g.AddText("xs+20 yp+55", i18n("inputMethodDetectionMode.number"))
                _gc.conversionNum := _ := g.AddEdit("yp r1", "")
                if !InStr(ruleInfo.conversionRule, "oddNum") && !InStr(ruleInfo.conversionRule, "evenNum")
                    _.Value := ruleInfo.conversionRule

                _.OnEvent("Change", (i, *) => (ruleInfo.conversionRule := i.value, _gc.conversionRule.value := 0))

                g.AddText("xs+20 yp+55", i18n("inputMethodDetectionMode.rule"))
                _gc.conversionRule := _ := g.AddDropDownList("yp",
                    [
                        "", i18n("inputMethodDetectionMode.rule.odd"), i18n("inputMethodDetectionMode.rule.even")
                    ]
                )
                switch ruleInfo.conversionRule {
                    case "oddNum":
                        _.Value := 2
                    case "evenNum":
                        _.Value := 3
                }
                _.OnEvent("Change", (i, *) => (
                    ruleInfo.conversionRule := i.value == 2 ? "oddNum" : i.value == 3 ? "evenNum" : "",
                    _gc.conversionNum.value := ""
                ))

                g.AddButton("xs w" bw, i18n("ok")).OnEvent("Click", e_set)
                e_set(*) {
                    g.Destroy()

                    ; 状态码
                    sm := ruleInfo.stateRule
                    ; 转换码
                    cm := ruleInfo.conversionRule
                    ; 输入法状态
                    state := textToState(ruleInfo.state)

                    if (add) {
                        var.inputMethodDetectionRules.InsertAt(_gc.order, sm "," cm "," state)
                    } else {
                        if (_gc.order != RowNumber) {
                            var.inputMethodDetectionRules.RemoveAt(RowNumber)
                            var.inputMethodDetectionRules.InsertAt(_gc.order, sm "," cm "," state)
                        } else {
                            var.inputMethodDetectionRules[RowNumber] := sm "," cm "," state
                        }
                    }
                    changeConfig("inputMethodDetectionRule", arrJoin(var.inputMethodDetectionRules, "|"), , (*) => reloadLV(LV))
                }
                if (!add) {
                    g.AddButton("xs w" bw, i18n("deleteRule")).OnEvent("Click", e_del)
                    e_del(*) {
                        g.Destroy()
                        LV.Delete(RowNumber)
                        autoHdrLV(LV)
                        var.inputMethodDetectionRules.RemoveAt(RowNumber)
                        changeConfig("inputMethodDetectionRule", arrJoin(var.inputMethodDetectionRules, "|"), , (*) => reloadLV(LV))
                    }
                }

                return g
            }
        }

        reloadLV(LV) {
            LV.Delete()
            LV.Opt("-Redraw")

            for i, v in var.inputMethodDetectionRules {
                r := StrSplit(v, ",")
                LV.Add(, i, generateCol(r*)*)
            }
            LV.Opt("+Redraw")
            autoHdrLV(LV)
        }

        /**
         * 生成列信息
         * @param sm 状态码
         * @param cm 转换码
         * @param state 输入法状态
         * @returns {Array} 列信息
         */
        generateCol(sm, cm, state) {
            colList := []
            odd := i18n("inputMethodDetectionMode.rule.odd")
            even := i18n("inputMethodDetectionMode.rule.even")

            colList.Push(sm == "oddNum" ? odd : sm == "evenNum" ? even : sm)
            colList.Push(cm == "oddNum" ? odd : cm == "evenNum" ? even : cm)
            colList.Push(i18n(state))
            return colList
        }

        g.OnEvent("Close", (*) => (g.Destroy(), var._showStateCode := 0, showStateCode(0)))

        return g
    }
}
