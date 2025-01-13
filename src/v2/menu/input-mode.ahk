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
        global statusModeEN, conversionModeEN, mode

        statusModeEN := readIni("statusModeEN", "", "InputMethod")
        conversionModeEN := readIni("conversionModeEN", "", "InputMethod")
        mode := readIni("mode", 1, "InputMethod")

        g := createGuiOpt("InputTip - 设置输入法模式")
        gc.modeList := ["【自定义】", "【通用】"]
        tab := g.AddTab3("-Wrap", ["基础配置", "自定义", "关于自定义"])
        tab.UseTab(1)
        g.AddText("Section cRed", "如果【通用】模式不可用，需要前往「自定义」标签页去配置【自定义】模式")
        g.AddText(, "1. 当前使用的输入法模式:")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        gc.mode := g.AddText("yp cRed w" w / 2)
        gc.mode.Value := gc.modeList[mode + 1]
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
            restartJetBrains()
        }
        timeout.Value := checkTimeout
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "单位：毫秒，默认 500 毫秒。`n每次切换输入法状态，InputTip 会从系统获取新的输入法状态。`n如果超过了这个时间，则认为获取失败，直接显示英文状态。`n它可能是有时识别不到输入法状态的原因，遇到问题可以尝试调节它。")
        g.AddText("xs", "3. Shift 按键是否可以正常切换输入法状态")
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
                    g.AddText("cRed", "确定要使用【否】吗？")
                    g.AddText("cRed", "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择【否】。`n如果选择【否】，在美式键盘或部分特殊输入法中，可能会导致状态提示间歇性错误。")
                    g.AddText("cRed", "建议不要使用【否】，而是启用 Shift 切换状态，这也是几乎所有输入法的默认设置。")

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    g.AddButton("w" bw, "我确定要使用【否】").OnEvent("Click", e_yes)
                    g.AddButton("w" bw, "不，我只是误点了").OnEvent("Click", e_no)
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
                restartJetBrains()
            }
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择【否】。`n如果选择【否】，在美式键盘或部分特殊输入法中，可能会导致状态提示间歇性错误。")
        tab.UseTab(2)

        g.AddText("Section ReadOnly cRed -VScroll w" w, "首先需要点击上方的「关于自定义」标签页，查看帮助说明，了解如何设置")
        g.AddText("Section", "优先级顺序: 切换码规则(4) > 切换码数字(3) > 状态码规则(2) > 状态码数字(1)")
        g.AddText("xs cGray", "输入框中有值的或规则有勾选的，取其中优先级最高的生效`n如果都没有设置或勾选，则自动变回【通用】模式，反之变为【自定义】模式")

        g.AddText("Section", "1.")
        g.AddText("yp cRed", "英文状态")
        g.AddText("yp", "的状态码数字: ")
        gc.statusModeEN := g.AddEdit("yp", "")
        gc.statusModeEN.Value := Trim(StrReplace(statusModeEN, ":", " "))
        gc.statusModeEN.OnEvent("Change", e_statusModeEN)
        e_statusModeEN(item, *) {
            if (Trim(item.value) = "") {
                writeIni("statusModeEN", "", "InputMethod")
                statusModeEN := ""
            } else {
                value := ":"
                for v in StrSplit(item.value, " ") {
                    value .= v ":"
                }
                writeIni("statusModeEN", value, "InputMethod")
                statusModeEN := value
            }
            checkModeChange()
            restartJetBrains()
        }
        checkModeChange() {
            if (gc.statusModeEN.Value = "" && gc.conversionModeEN.Value = "" && evenStatusModeEN = "" && evenConversionModeEN = "") {
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
            global evenStatusModeEN := readIni("evenStatusModeEN", "", "InputMethod")
            global evenConversionModeEN := readIni("evenConversionModeEN", "", "InputMethod")
            checkModeChange()
            restartJetBrains()
        }

        g.AddText("xs", "2.")
        g.AddText("yp cRed", "英文状态")
        g.AddText("yp", "的状态码规则: ")
        gc.oddStatusMode := g.AddCheckbox("yp", "使用奇数")
        if (evenStatusModeEN != "") {
            gc.oddStatusMode.Value := !evenStatusModeEN
        }
        gc.oddStatusMode.OnEvent("Click", e_oddStatusMode)
        e_oddStatusMode(item, *) {
            handle_mode(item.value, "evenStatusModeEN", "evenStatusMode", 0)
        }
        gc.evenStatusMode := g.AddCheckbox("yp", "使用偶数")
        if (evenStatusModeEN != "") {
            gc.evenStatusMode.Value := evenStatusModeEN
        }
        gc.evenStatusMode.OnEvent("Click", e_evenStatusMode)
        e_evenStatusMode(item, *) {
            handle_mode(item.value, "evenStatusModeEN", "oddStatusMode", 1)
        }

        g.AddText("xs", "3.")
        g.AddText("yp cRed", "英文状态")
        g.AddText("yp", "的切换码数字: ")
        gc.conversionModeEN := g.AddEdit("yp")
        gc.conversionModeEN.Value := Trim(StrReplace(conversionModeEN, ":", " "))
        gc.conversionModeEN.OnEvent("Change", e_conversionModeEN)
        e_conversionModeEN(item, *) {
            if (Trim(item.value) = "") {
                writeIni("conversionModeEN", "", "InputMethod")
                conversionModeEN := ""
            } else {
                value := ":"
                for v in StrSplit(item.value, " ") {
                    value .= v ":"
                }
                writeIni("conversionModeEN", value, "InputMethod")
                conversionModeEN := value
            }
            checkModeChange()
            restartJetBrains()
        }

        g.AddText("xs", "4.")
        g.AddText("yp cRed", "英文状态")
        g.AddText("yp", "的切换码规则: ")
        gc.oddConversionMode := g.AddCheckbox("yp", "使用奇数")
        if (evenConversionModeEN != "") {
            gc.oddConversionMode.Value := !evenConversionModeEN
        }
        gc.oddConversionMode.OnEvent("Click", e_oddConversionMode)
        e_oddConversionMode(item, *) {
            handle_mode(item.value, "evenConversionModeEN", "evenConversionMode", 0)
        }
        gc.evenConversionMode := g.AddCheckbox("yp", "使用偶数")
        if (evenConversionModeEN != "") {
            gc.evenConversionMode.Value := evenConversionModeEN
        }
        gc.evenConversionMode.OnEvent("Click", e_evenConversionMode)
        e_evenConversionMode(item, *) {
            handle_mode(item.value, "evenConversionModeEN", "oddConversionMode", 1)
        }

        gc.status_btn := g.AddButton("xs w" w, "【显示】实时的状态码和切换码")
        gc.status_btn.OnEvent("Click", e_showStatus)
        e_showStatus(*) {
            if (gc.timer) {
                gc.timer := 0
                gc.status_btn.Text := "【显示】实时的状态码和切换码"
                return
            }

            gc.timer := 1
            gc.status_btn.Text := "【关闭】实时的状态码和切换码"

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
        g.AddEdit("Section r12 ReadOnly w" w, "如何配置【自定义】模式？以讯飞输入法为例:`n1. 点击按钮「显示实时的状态码和切换码」，它会在光标处显示状态码和切换码。`n2. 来回切换输入法的中英文状态观察它们的变化。`n3. 会发现切换码始终为 1，而状态码在英文时为 1，中文时为 2。`n4. 于是，在状态码数字的输入框中填入 1，就会发现已经生效了。`n5. 这里更推荐勾选状态码规则中的「使用奇数」，它包含 1，且范围更大。`n6. 再比如小狼毫(rime)输入法，按照同样的操作流程，你会发现很大的不同。`n7. 它的状态码始终为 1，而切换码在英文时是随机的偶数，中文时是随机的奇数。`n8. 于是，勾选切换码规则中的「使用偶数」后，就会发现已经生效了。`n9. 当然，不要盲目的使用规则扩大范围，比如手心输入法就不能这样做。`n10. 当使用手心输入法按照同样的流程操作时，你会发现又有不同。`n11. 手心输入法的状态码始终为 1，而切换码在英文时为 1，中文时为 1025。`n12. 于是，在状态码数字的输入框中填入 1，就会发现已经生效了。`n13. 但是，这里就不能勾选「使用奇数」，因为中文时的 1025 也是奇数。`n14. 【自定义】模式是靠唯一的值去区分状态，勾选「使用奇数」就无法区分了。`n`n什么是优先级顺序？`n1. 优先级顺序: 切换码规则(4) > 切换码数字(3) > 状态码规则(2) > 状态码数字(1)`n2. 对于【自定义】模式来说，生效的是优先级最高的配置项。`n3. 比如: 你使用了切换码规则，则切换码数字/状态码规则/状态码数字即使有值，也无效。`n`n在数字输入框中，是可以填入许多个的:`n1. 有可能你会遇到这样的情况。`n2. 你发现状态码在英文时不唯一，有时为 0，有时为 3，在中文时为 1。`n3. 这种情况，一个奇数，一个偶数，也无法使用规则。`n4. 你可以直接在状态码数字的输入框中填入它们，以空格分割即可。")
        g.AddLink(, '相关链接: <a href="https://inputtip.pages.dev/FAQ/custom-input-mode">自定义模式</a>')
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
