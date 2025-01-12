fn_input_mode(*) {
    createGui(fn).Show()
    fn(x, y, w, h) {
        global statusModeEN, conversionModeEN, mode, checkTimeout, gc

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
        g := Gui("AlwaysOnTop", "InputTip - 设置输入法模式")
        g.SetFont(fz, "微软雅黑")
        bw := w - g.MarginX * 2

        gc.imList := ["1. 自定义", "2. 通用模式", "3. 讯飞输入法", "4. 手心输入法"]
        statusModeEN := readIni("statusModeEN", "", "InputMethod")
        conversionModeEN := readIni("conversionModeEN", "", "InputMethod")
        mode := readIni("mode", 1, "InputMethod")

        tab := g.AddTab3("-Wrap", ["基础配置", "自定义"])
        tab.UseTab(1)
        g.AddText("Section cRed", "- 一般情况，使用「通用模式」，如果是讯飞或手心输入法，则选择对应模式。`n- 当修改了输入法模式之后，如果已经打开的窗口不生效，需要重新打开。`n- 如果需要自定义，请前往「自定义」页面配置。")
        g.AddText(, "1. 当前输入法模式: ")
        gc.mode := g.AddDropDownList("yp AltSubmit vmode", gc.imList)
        gc.mode.OnEvent("Change", fn_change_mode)
        fn_change_mode(item, *) {
            if (item.Value = 1) {
                createGui(fn).Show()
                fn(x, y, w, h) {
                    if (gc.w.customModeGui) {
                        gc.w.customModeGui.Destroy()
                        gc.w.customModeGui := ""
                    }
                    gc.mode.Value := mode + 1
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText("cRed", "请前往「自定义」配置页面中设置，此处无法直接修改")
                    g.AddText("cRed", "在配置页面的左上角，「基础配置」的右侧")
                    y := g.AddButton("w" bw, "我知道了")
                    y.OnEvent("Click", yes)
                    y.Focus()
                    g.OnEvent("Close", yes)
                    yes(*) {
                        g.Destroy()
                    }
                    gc.w.customModeGui := g
                    return g
                }
            } else {
                switch (item.Value) {
                    case 2:
                    {
                        writeIni("statusModeEN", "", "InputMethod")
                        writeIni("conversionModeEN", "", "InputMethod")
                        gc.statusModeEN.Value := ""
                        gc.conversionModeEN.Value := ""
                        statusModeEN := ""
                        conversionModeEN := ""
                    }
                    case 3:
                    {
                        ; 讯飞输入法
                        ; 中文时状态码为 2
                        ; 英文时状态码为 1
                        ; 切换码无规律不唯一
                        writeIni("statusModeEN", ":1:", "InputMethod")
                        writeIni("conversionModeEN", "", "InputMethod")
                        gc.statusModeEN.Value := "1"
                        gc.conversionModeEN.Value := ""
                        statusModeEN := ":1:"
                        conversionModeEN := ""
                    }
                    case 4:
                    {
                        ; 手心输入法:
                        ; 中文时切换码为 1025
                        ; 英文时切换码为 1
                        ; 状态码一直为 1
                        writeIni("statusModeEN", "", "InputMethod")
                        writeIni("conversionModeEN", ":1:", "InputMethod")
                        gc.statusModeEN.Value := ""
                        gc.conversionModeEN.Value := "1"
                        statusModeEN := ""
                        conversionModeEN := ":1:"
                    }
                }
                writeIni("mode", gc.mode.Value - 1, "InputMethod")
                mode := readIni("mode", gc.mode.Value - 1, "InputMethod")
                restartJetBrains()
            }
        }
        gc.mode.Value := mode + 1
        g.AddText("xs", "2. 设置获取输入法状态的超时时间: ")
        timeout := g.AddEdit("yp Number Limit5 vcheckTimeout", "")
        timeout.OnEvent("Change", fn_change_timeout)
        fn_change_timeout(item, *) {
            if (item.value != "") {
                writeIni("checkTimeout", item.value, "InputMethod")
                checkTimeout := item.value
                restartJetBrains()
            }
        }
        timeout.Value := checkTimeout
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "单位：毫秒，默认 500 毫秒。`n每次切换输入法状态，InputTip 会从系统获取新的输入法状态。`n如果超过了这个时间，则认为获取失败，直接显示英文状态。`n它可能是有时识别不到输入法状态的原因，可以尝试调节它。")
        g.AddText("xs", "3. Shift 按键是否可以切换输入法状态")
        gc.useShift := g.AddDropDownList("yp vuseShift Choose" useShift + 1, ["【否】(慎重选择)", "【是】"])
        gc.useShift.OnEvent("Change", fn_change_useShift)
        fn_change_useShift(item, *) {
            if (useShift = item.Value) {
                createGui(fn).Show()
                fn(x, y, w, h) {
                    if (gc.w.shiftSwitchGui) {
                        gc.w.shiftSwitchGui.Destroy()
                        gc.w.shiftSwitchGui := ""
                    }
                    gc.useShift.Value := useShift + 1
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText("cRed", "确定要使用【否】吗？")
                    g.AddText("cRed", "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择【否】。`n如果选择【否】，在美式键盘或部分特殊输入法中，可能会导致状态提示间歇性错误。")
                    g.AddText("cRed", "更建议不要使用【否】，而是启用 Shift 切换状态，这也是几乎所有输入法的默认设置。")
                    g.AddButton("w" bw, "我确定要使用【否】").OnEvent("Click", yes)
                    g.AddButton("w" bw, "不，我只是误点了").OnEvent("Click", no)
                    g.OnEvent("Close", no)
                    yes(*) {
                        g.Destroy()
                        gc.useShift.Value := 1
                        writeIni("useShift", 0)
                        global useShift := 0
                    }
                    no(*) {
                        g.Destroy()
                    }
                    gc.w.shiftSwitchGui := g
                    return g
                }
            } else {
                value := item.Value - 1
                writeIni("useShift", value)
                global useShift := value
                restartJetBrains()
            }
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" w, "除非你的输入法自定义了切换状态的按键，且禁用了 Shift 切换，才需要选择【否】。`n如果选择【否】，在美式键盘或部分特殊输入法中，可能会导致状态提示间歇性错误。")
        tab.UseTab(2)
        g.AddText("Section", "1.")
        g.AddText("yp cRed", "英文状态")
        g.AddText("yp", "时应该返回的")
        g.AddText("yp cRed", "状态码")
        g.AddText("yp", ": ")
        gc.statusModeEN := g.AddEdit("yp vstatusMode w" 100, "")
        gc.statusModeEN.Value := Trim(StrReplace(statusModeEN, ":", " "))
        gc.statusModeEN.OnEvent("Change", fn_change_statusModeEN)
        fn_change_statusModeEN(item, *) {
            if (Trim(item.Value) = "") {
                if (conversionModeEN = "") {
                    ; 如果状态码和切换码都为空，则恢复到通用模式
                    writeIni("mode", 1, "InputMethod")
                    mode := 1
                    gc.mode.Value := 2
                }
                writeIni("statusModeEN", "", "InputMethod")
                statusModeEN := ""
            } else {
                if (mode != 0) {
                    writeIni("mode", 0, "InputMethod")
                    mode := 0
                    gc.mode.Value := 1
                }
                value := ":"
                for v in StrSplit(item.value, " ") {
                    value .= v ":"
                }
                writeIni("statusModeEN", value, "InputMethod")
                statusModeEN := value
            }
            restartJetBrains()
        }
        g.AddText("xs", "2.")
        g.AddText("yp cRed", "英文状态")
        g.AddText("yp", "时应该返回的")
        g.AddText("yp cRed", "切换码")
        g.AddText("yp", ": ")
        gc.conversionModeEN := g.AddEdit("yp vconversionMode w" 100, "")
        gc.conversionModeEN.Value := Trim(StrReplace(conversionModeEN, ":", " "))
        gc.conversionModeEN.OnEvent("Change", fn_change_conversionModeEN)
        fn_change_conversionModeEN(item, *) {
            if (Trim(item.Value) = "") {
                if (statusModeEN = "") {
                    ; 如果状态码和切换码都为空，则恢复到通用模式
                    writeIni("mode", 1, "InputMethod")
                    mode := 1
                    gc.mode.Value := 2
                }
                writeIni("conversionModeEN", "", "InputMethod")
                conversionModeEN := ""
            } else {
                if (mode != 0) {
                    writeIni("mode", 0, "InputMethod")
                    mode := 0
                    gc.mode.Value := 1
                }
                value := ":"
                for v in StrSplit(item.value, " ") {
                    value .= v ":"
                }
                writeIni("conversionModeEN", value, "InputMethod")
                conversionModeEN := value
            }
            restartJetBrains()
        }
        gc.status_btn := g.AddButton("xs w" bw, "显示实时的状态码和切换码")
        gc.status_btn.OnEvent("Click", showStatus)
        showStatus(*) {
            if (gc.timer) {
                gc.timer := 0
                gc.status_btn.Text := "显示实时的状态码和切换码"
                return
            }

            gc.timer := 1
            gc.status_btn.Text := "关闭实时的状态码和切换码"

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
        g.AddEdit("xs r10 ReadOnly cGray w" w, "1. 当点击按钮「显示实时的状态码和切换码」之后，在鼠标位置会实时显示当前的状态码和切换码。`n2. 你需要来回切换输入法中英文状态进行观察，如果不同状态时的值是唯一的，就将它填入对应的输入框中。`n3. 英文状态时的状态码和切换码在不同窗口可能不同，但只要是唯一的，就应该被填写，多个就用空格分割。`n`n举个例子: `n假如当你切换到英文后，状态码显示 0，切换码显示 1025。`n切换到中文后，状态码显示 1，切换码显示 1025。`n换到另一个窗口后又发现，英文时状态码显示 3，切换码显示 1025，中文时状态码显示 4，切换码显示 1025。`n可以发现，英文的状态码 0 和 3 是唯一的，没有在中文状态时出现，因此当状态码是它们时，可以确定当前一定是英文状态，像这样的就应该将它们填入状态码输入框中，用空格分割，即 0 3`n而切换码相反，中英文状态时都为 1025，没有办法通过 1025 去判断当前是中文还是英文，就不填切换码，保持切换码为空。")

        g.OnEvent("Close", fn_close)
        fn_close(*) {
            g.Destroy()
            gc.timer := 0
        }
        gc.w.inputModeGui := g
        return g
    }
}
