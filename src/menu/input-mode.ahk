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
        global statusMode, conversionMode, mode

        statusMode := readIni("statusMode", "", "InputMethod")
        conversionMode := readIni("conversionMode", "", "InputMethod")
        mode := readIni("mode", 1, "InputMethod")

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

                    g := createGuiOpt()
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
        g.AddText("Section", "优先级顺序: 切换码规则(4) > 切换码数字(3) > 状态码规则(2) > 状态码数字(1)")
        g.AddText("xs cGray", "输入框中有值的或规则有勾选的，取其中优先级最高的生效`n如果都没有设置或勾选，则自动变回【通用】模式，反之变为【自定义】模式")

        g.AddText("Section", "以哪一种状态作为判断依据: ")
        g.AddDropDownList("yp Choose" baseStatus + 1, [" 英文状态", " 中文状态"]).OnEvent("Change", e_changeBaseStatus)
        e_changeBaseStatus(item, *) {
            value := item.Value - 1
            writeIni("baseStatus", value, "InputMethod")
            global baseStatus := value
            for v in gc.statusText {
                v.value := Trim(item.text)
            }
        }
        gc.statusText := []
        g.AddText("xs", "1.")
        gc.statusText.push(g.AddText("yp cRed", stateMap.%baseStatus%))
        g.AddText("yp", "的状态码数字: ")
        gc.statusMode := g.AddEdit("yp", "")
        gc.statusMode.Value := Trim(StrReplace(statusMode, ":", " "))
        gc.statusMode.OnEvent("Change", e_statusMode)
        e_statusMode(item, *) {
            if (Trim(item.value) = "") {
                writeIni("statusMode", "", "InputMethod")
                statusMode := ""
            } else {
                value := ":"
                for v in StrSplit(item.value, " ") {
                    value .= v ":"
                }
                writeIni("statusMode", value, "InputMethod")
                statusMode := value
            }
            checkModeChange()
        }
        checkModeChange() {
            if (gc.statusMode.Value = "" && gc.conversionMode.Value = "" && evenStatusMode = "" && evenConversionMode = "") {
                gc.mode.Value := gc.modeList[2]
                if (mode != 1) {
                    writeIni("mode", 1, "InputMethod")
                    global mode := 1
                }
            } else {
                gc.mode.Value := gc.modeList[1]
                if (mode != 0) {
                    writeIni("mode", 0, "InputMethod")
                    global mode := 0
                }
            }
            restartJAB()
        }

        handle_mode(value, config, checkbox, default) {
            if (value) {
                gc.%checkbox%.value := 0
                writeIni(config, default, "InputMethod")
            } else {
                if (!gc.%checkbox%.value) {
                    writeIni(config, "", "InputMethod")
                }
            }
            global evenStatusMode := readIni("evenStatusMode", "", "InputMethod")
            global evenConversionMode := readIni("evenConversionMode", "", "InputMethod")
            checkModeChange()
        }

        g.AddText("xs", "2.")
        gc.statusText.push(g.AddText("yp cRed", stateMap.%baseStatus%))
        g.AddText("yp", "的状态码规则: ")
        gc.oddStatusMode := g.AddCheckbox("yp", "使用奇数")
        if (evenStatusMode != "") {
            gc.oddStatusMode.Value := !evenStatusMode
        }
        gc.oddStatusMode.OnEvent("Click", e_oddStatusMode)
        e_oddStatusMode(item, *) {
            handle_mode(item.value, "evenStatusMode", "evenStatusMode", 0)
        }
        gc.evenStatusMode := g.AddCheckbox("yp", "使用偶数")
        if (evenStatusMode != "") {
            gc.evenStatusMode.Value := evenStatusMode
        }
        gc.evenStatusMode.OnEvent("Click", e_evenStatusMode)
        e_evenStatusMode(item, *) {
            handle_mode(item.value, "evenStatusMode", "oddStatusMode", 1)
        }

        g.AddText("xs", "3.")
        gc.statusText.push(g.AddText("yp cRed", stateMap.%baseStatus%))
        g.AddText("yp", "的切换码数字: ")
        gc.conversionMode := g.AddEdit("yp")
        gc.conversionMode.Value := Trim(StrReplace(conversionMode, ":", " "))
        gc.conversionMode.OnEvent("Change", e_conversionMode)
        e_conversionMode(item, *) {
            if (Trim(item.value) = "") {
                writeIni("conversionMode", "", "InputMethod")
                conversionMode := ""
            } else {
                value := ":"
                for v in StrSplit(item.value, " ") {
                    value .= v ":"
                }
                writeIni("conversionMode", value, "InputMethod")
                conversionMode := value
            }
            checkModeChange()
        }

        g.AddText("xs", "4.")
        gc.statusText.push(g.AddText("yp cRed", stateMap.%baseStatus%))
        g.AddText("yp", "的切换码规则: ")
        gc.oddConversionMode := g.AddCheckbox("yp", "使用奇数")
        if (evenConversionMode != "") {
            gc.oddConversionMode.Value := !evenConversionMode
        }
        gc.oddConversionMode.OnEvent("Click", e_oddConversionMode)
        e_oddConversionMode(item, *) {
            handle_mode(item.value, "evenConversionMode", "evenConversionMode", 0)
        }
        gc.evenConversionMode := g.AddCheckbox("yp", "使用偶数")
        if (evenConversionMode != "") {
            gc.evenConversionMode.Value := evenConversionMode
        }
        gc.evenConversionMode.OnEvent("Click", e_evenConversionMode)
        e_evenConversionMode(item, *) {
            handle_mode(item.value, "evenConversionMode", "oddConversionMode", 1)
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
        g.AddText("cRed", "下方以讯飞，小狼毫(rime)，手心，小鹤音形，ENG(美式键盘)这几种输入法进行举例说明`n你需要完整阅读整个帮助说明，看完之后，你自然就知道应该如何设置了")
        g.AddEdit("Section r12 ReadOnly w" w, "1. 如何进行设置？(选择英文状态作为判断依据)`n   - 首先以【讯飞输入法】为例`n   - 点击按钮「显示实时的状态码和切换码」，它会在光标处显示状态码和切换码`n   - 来回切换输入法的中英文状态观察它们的变化`n   - 会发现切换码始终为 1，而状态码在英文时为 1，中文时为 2`n   - 于是，在状态码数字的输入框中填入 1，就可以正常识别状态了`n   - 这里更推荐勾选状态码规则中的「使用奇数」，它包含 1，且范围更大`n   - 再比如【小狼毫(rime)输入法】，按照同样的操作流程，你会发现很大的不同`n   - 它的状态码始终为 1，而切换码在英文时是随机的偶数，中文时是随机的奇数`n   - 于是，勾选切换码规则中的「使用偶数」后，就可以正常识别状态了`n   - 当然，不要盲目的使用规则扩大范围，比如【手心输入法】就不能这样做`n   - 当使用【手心输入法】按照同样的流程操作时，你会发现又有不同`n   - 它的状态码始终为 1，而切换码在英文时为 1，中文时为 1025`n   - 于是，在切换码数字的输入框中填入 1，就可以正常识别状态了`n   - 但是，这里就不能勾选「使用奇数」，因为中文时的 1025 也是奇数`n`n2. 关于配置项「以哪一种状态作为判断依据」`n   - 需要根据实际情况选择合适的值`n   - 上方的这几个例子，是围绕英文状态来设置的`n   - 如果你需要围绕中文状态来设置，你就需要选择中文状态`n   - 以【小鹤音形输入法】为例`n   - 它的状态码始终为 1，而切换码在英文时为 257，中文时为 1025`n   - 因此，将 257 填入切换码即可`n   - 但是如果你同时使用多个输入法，比如它和【ENG 美式键盘】`n   - 而【ENG 美式键盘】的切换码为 1，这就没有办法兼顾这两个输入法`n   - 这时，就可以换个思路，选择以中文状态为判断依据`n   - 将 1025 填入切换码后，【小鹤音形输入法】能正常识别`n   - 切换到【ENG 美式键盘】时，由于切换码不等于 1025，也会识别成英文状态`n`n3. 什么是优先级顺序？`n   - 优先级顺序: 切换码规则(4) > 切换码数字(3) > 状态码规则(2) > 状态码数字(1)`n   - 假如你使用了切换码规则，勾选了「使用偶数」`n   - 那么切换码数字，状态码规则，状态码数字即使有勾选或填入了值，也不会生效`n   - 因为切换码规则优先级更高，InputTip 就直接使用它去判断了`n`n4. 关于「状态码数字」和「切换码数字」`n   - 在它们的输入框中，可以填入许多个数字，如果遇到以下情况就可以这样做`n   - 假如你发现状态码都是 1，区分不了状态，无法使用`n   - 而切换码在英文时不唯一，有时为 0，有时为 3，但中文时没有 0 或 3`n   - 这种情况下，有奇数也有偶数，使用规则也无法区分`n   - 就可以直接在切换码数字的输入框中填入它们，以空格分割它们即可")
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
