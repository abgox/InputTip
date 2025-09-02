; InputTip

fn_scheme_symbol(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - 符号方案")
        tab := g.AddTab3("-Wrap", ["符号方案", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "------"

        g.AddText("xs", line)

        g.addText("xs", "指定符号的类型:")
        g.AddDropDownList("yp AltSubmit Choose" symbolType + 1 " w" bw / 2, [" 【不】显示符号", " 显示【图片】符号", " 显示【方块】符号", " 显示【文本】符号"]).OnEvent("Change", e_symbol_type)
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
                    text: "你正在开始使用【符号方案】了"
                }, {
                    opt: "cRed",
                    text: '需要注意:`n【符号方案】使用了强制的白名单机制`n你需要使用【托盘菜单】中的【符号的黑/白名单】去添加应用进程`n只有添加到【符号的白名单】中的应用进程窗口才会尝试显示符号',
                }, {
                    opt: "",
                    text: '详情参考: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">关于符号方案中的名单机制</a>'
                }], "InputTip - 符号方案的注意事项").Show()
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

        g.addText("xs", "符号的显示模式:")
        g.AddDropDownList("yp AltSubmit Choose" symbolShowMode " w" bw / 2, [" 实时状态显示", " 切换状态显示"]).OnEvent("Change", e_symbol_mode)
        e_symbol_mode(item, *) {
            value := item.value
            global symbolShowMode := value
            writeIni("symbolShowMode", value)
        }

        g.AddText("xs", "符号的延时隐藏:")
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

        g.addText("xs", "鼠标悬停时隐藏:")
        g.AddDropDownList("yp AltSubmit Choose" hoverHide + 1 " w" bw / 2, ["【否】悬停在符号上时，符号保持显示", "【是】悬停在符号上时，符号自动隐藏"]).OnEvent("Change", e_symbol_hover_hide)
        e_symbol_hover_hide(item, *) {
            global hoverHide := item.value - 1
            writeIni("hoverHide", hoverHide)
        }

        g.AddText("xs", line)

        g.AddText("xs", "偏移量参考原点:")
        g.AddDropDownList("yp AltSubmit Choose" symbolOffsetBase + 1 " w" bw / 2, [" 输入光标上方", " 输入光标下方"]).OnEvent("Change", e_offset_base)
        e_offset_base(item, *) {
            writeIni("symbolOffsetBase", item.value - 1)
            global symbolOffsetBase := item.value - 1
            updateSymbol()
            reloadSymbol()
            gc._focusSymbol.Focus()
        }

        g.AddText("xs", line)

        _w := bw / 3 - g.MarginX / 3
        g.AddButton("xs w" _w, "图片符号").OnEvent("Click", fn_symbol_pic)
        g.AddButton("yp w" _w, "方块符号").OnEvent("Click", fn_symbol_block)
        g.AddButton("yp w" _w, "文本符号").OnEvent("Click", fn_symbol_text)


        tab.UseTab(2)
        g.AddEdit("ReadOnly r16 w" bw, "1. 配置 —— 指定符号的类型`n   - 如果要显示符号，还必须添加【符号的白名单】`n   - 只有在【符号的白名单】中的应用进程，InputTip 才会尝试显示符号`n   - 它会先尝试获取输入光标位置，如果获取失败，则不显示符号`n   - 可以尝试【在鼠标附近显示符号】作为这种失败情况的折中方案`n`n2. 配置 —— 符号的显示模式`n   - 不同的模式，重新加载并显示符号的时机不同，默认使用【实时状态显示】`n   - 【实时状态显示】: 切换输入法状态、输入光标位置变化`n   - 【切换状态显示】: 切换输入法状态`n   - 如果选择了【切换状态显示】，则【符号的延时隐藏】不应该为 0`n`n3. 配置 —— 符号的延时隐藏`n   - 它指的是当无键盘或鼠标左键点击操作时，符号在多久后隐藏`n   - 单位: 毫秒，默认为 0，表示永不隐藏`n   - 当符号隐藏后，下次键盘操作或点击鼠标左键时再次显示`n   - 如果【符号的显示模式】为【切换状态显示】，则键盘操作改为切换输入法状态`n`n4. 配置 —— 鼠标悬停时隐藏`n   - 它指的是当鼠标悬停在符号上时，符号是否需要隐藏`n   - 当符号隐藏后，输入光标位置发生变化时再次显示`n`n5. 配置 —— 偏移量参考原点`n   - 输入光标附近显示的符号的垂直偏移量会基于这个参考原点`n   - 如果你希望符号显示在文字的下方时，使用【输入光标下方】会更好`n   - 否则，请保持默认的【输入光标上方】`n   - 这个配置项对 JAB/JetBrains IDE 程序无效，需使用【特殊偏移量】单独处理`n`n6. 按钮 —— 图片符号/方块符号/文本符号`n   - 点击后，打开对应的符号配置菜单")
        g.AddLink(, '相关链接: <a href="https://github.com/abgox/InputTip/issues/145">Github Issue 145</a>')
        return g
    }
}

fn_symbol_pic(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - 符号方案 - 图片符号")
        tab := g.AddTab3("-Wrap", ["基础配置", "独立配置", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)


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
            tip: "水平偏移量"
        }, {
            config: "pic_offset_y",
            textOpt: "yp",
            editOpt: "",
            tip: "垂直偏移量"
        }, {
            config: "pic_symbol_width",
            textOpt: "yp",
            editOpt: "Number",
            tip: "宽度"
        }, {
            config: "pic_symbol_height",
            textOpt: "yp",
            editOpt: "Number",
            tip: "高度"
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
            picList := getPicList()
        }

        g.AddText("xs", line)
        createGuiOpt("").AddText(, "中文状态").GetPos(, , &__w)
        gc._focusSymbolPic := g.AddEdit("yp w1")
        gc._focusSymbolPic.OnEvent("Focus", fn_clear)
        gc._focusSymbolPic.OnEvent("LoseFocus", fn_clear)

        for v in ["CN", "EN", "Caps"] {
            g.AddText("xs", stateMap.%v% ":")
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
        g.AddButton("xs w" _w, "打开图片符号目录").OnEvent("Click", (*) => (Run("explorer.exe InputTipSymbol")))
        g.AddButton("yp w" _w, "刷新下拉列表").OnEvent("Click", (*) => (
            getPathList(),
            fn_symbol_pic()
        ))
        g.AddButton("yp w" _w, "下载其他图片符号").OnEvent("Click", (*) => (Run("https://inputtip.abgox.com/download/extra")))

        tab.UseTab(2)

        g.AddText("Section", "是否启用")
        g.AddText("yp cRed", "图片符号")
        g.AddText("yp", "的以下独立配置: ")
        _ := g.AddDropDownList("yp AltSubmit", ["【否】", "【是】"])
        _.Value := symbolConfig.enableIsolateConfigPic + 1
        _._config := "enableIsolateConfigPic"
        _.OnEvent("Change", fn_setIsolateConfig)

        g.AddText("xs", line)
        for state in ["CN", "EN", "Caps"] {
            g.AddText("xs cRed", stateMap.%state%)
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
        g.AddEdit("ReadOnly r11 w" bw, "1. 配置 —— 水平/垂直偏移量`n   - 它指的是符号在输入光标附近显示时的偏移量`n   - 注意，符号最终的偏移量为 o1 + o2 + o3`n       - o1 指的是这里的偏移量`n       - o2 指的是【特殊偏移量】中的【不同屏幕下的基础偏移量】`n       - o3 指的是【特殊偏移量】中为指定窗口设置的偏移量`n`n2. 配置 —— 宽度/高度`n   - 图片符号的宽度和高度`n`n3. 配置 —— 中文状态/英文状态/大写锁定`n   - 通过下拉列表为不同状态指定图片符号`n   - 如果选择第一个空白路径，则对应状态不显示符号`n   - InputTip 会根据当前输入法状态切换图片符号`n`n4. 按钮 —— 打开图片符号目录`n   - 点击它，会自动打开存放图片符号的目录`n   - 在这个目录下添加 png 图片后，会显示在下拉列表中`n`n5. 按钮 —— 刷新下拉列表`n   - 当存放图片符号的目录有变动，可能需要点击它去刷新下拉列表`n`n6. 按钮 —— 下载其他图片符号`n   - 点击它，前往官网查看其他的图片符号`n   - 下载后，放入图片符号目录中即可使用`n`n7. 关于独立配置`n   - 可以给不同状态设置不同的偏移量和宽高")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/zh-CN/faq/symbol-picture">图片符号</a>')
        return g
    }
}

fn_symbol_block(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - 符号方案 - 方块符号")
        tab := g.AddTab3("-Wrap", ["基础配置", "独立配置", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)


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
            tip: "中文状态时的颜色",
            colors: ["red", "FF5555", "F44336", "D23600", "FF1D23", "D40D12", "C30F0E", "5C0002", "450003"]
        }, {
            config: "EN_color",
            textOpt: "xs",
            editOpt: "",
            tip: "英文状态时的颜色",
            colors: ["blue", "528BFF", "0EEAFF", "59D8E6", "2962FF", "1B76FF", "2C1DFF", "1C3FFD", "1510F0"]
        }, {
            config: "Caps_color",
            textOpt: "xs",
            editOpt: "",
            tip: "大写锁定时的颜色",
            colors: ["green", "4E9A06", "96ED89", "66BB6A", "8BC34A", "45BF55", "43A047", "2E7D32", "33691E"]
        }]
        symbolBlockConfig := [{
            config: "offset_x",
            textOpt: "xs",
            editOpt: "",
            tip: "水平偏移量"
        }, {
            config: "symbol_width",
            textOpt: "yp",
            editOpt: "Number",
            tip: "宽度"
        }, {
            config: "transparent",
            textOpt: "yp",
            editOpt: "Number Limit3",
            tip: "透明度"
        }, {
            config: "offset_y",
            textOpt: "xs",
            editOpt: "",
            tip: "垂直偏移量"
        }, {
            config: "symbol_height",
            textOpt: "yp",
            editOpt: "Number",
            tip: "高度"
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

        symbolStyle := ["无", "样式1", "样式2", "样式3"]
        g.AddText("yp", "边框样式: ")
        _ := g.AddDropDownList("yp AltSubmit w" bw / 6, symbolStyle)
        _.Value := symbolConfig.border_type + 1
        _._config := "border_type"
        _.OnEvent("Change", fn_border_config)
        g.AddText("yp w20")
        _._focus := g.AddEdit("yp w1")
        _._focus.OnEvent("Focus", fn_clear)
        _._focus.OnEvent("LoseFocus", fn_clear)

        tab.UseTab(2)
        g.AddText("Section cRed", gui_help_tip)
        g.AddText("xs", line)

        g.AddText("xs", "是否启用")
        g.AddText("yp cRed", "方块符号")
        g.AddText("yp", "的独立配置: ")
        _ := g.AddDropDownList("yp AltSubmit", ["【否】", "【是】"])
        _.Value := symbolConfig.enableIsolateConfigBlock + 1
        _._config := "enableIsolateConfigBlock"
        _.OnEvent("Change", fn_setIsolateConfig)
        g.AddButton("xs w" bw, "独立配置").OnEvent("Click", e_blockIsolateConfig)
        e_blockIsolateConfig(*) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            createGui(blockConfigGui).Show()
            blockConfigGui(info) {
                g := createGuiOpt("InputTip - 设置方块符号的独立配置")
                g.AddText("cRed", "方块符号")
                g.AddText("yp", "的独立配置")
                g.AddText("xs", "-----------------------------------------------")

                if (info.i) {
                    return g
                }

                configList := [{
                    config: "offset_x",
                    textOpt: "xs",
                    editOpt: "",
                    tip: "水平偏移量"
                }, {
                    config: "offset_y",
                    textOpt: "xs",
                    editOpt: "",
                    tip: "垂直偏移量"
                }, {
                    config: "symbol_width",
                    textOpt: "xs",
                    editOpt: "Number",
                    tip: "宽度"
                }, {
                    config: "symbol_height",
                    textOpt: "xs",
                    editOpt: "Number",
                    tip: "高度"
                }, {
                    config: "transparent",
                    textOpt: "xs",
                    editOpt: "Number Limit3",
                    tip: "透明度"
                }]

                tab := g.AddTab3("-Wrap", ["中文状态", "英文状态", "大写锁定"])
                for i, state in ["CN", "EN", "Caps"] {
                    tab.UseTab(i)
                    g.AddText("Section cRed", stateMap.%state%)
                    g.AddText("yp", "时的独立配置:`n")

                    ; 颜色
                    config := state "_color"
                    g.AddText("xs", "颜色")
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
                    g.AddText("xs", "边框样式: ")
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
        g.AddEdit("ReadOnly r10 w" bw, "1. 配置 —— 中文状态/英文状态/大写锁定的颜色`n   - 它用来设置不同状态下符号的颜色`n   - 它需要一个常见的颜色英文或 16 进制颜色值，不包含 #`n   - 如果设置为空，则对应状态不显示符号`n`n2. 配置 —— 水平/垂直偏移量`n   - 它指的是符号在输入光标附近显示时的偏移量`n   - 注意，符号最终的偏移量为 o1 + o2 + o3`n       - o1 指的是这里的偏移量`n       - o2 指的是【特殊偏移量】中的【不同屏幕下的基础偏移量】`n       - o3 指的是【特殊偏移量】中为指定窗口设置的偏移量`n`n3. 配置 —— 宽度/高度`n`n4. 配置 —— 透明度`n`n5. 配置 —— 边框样式`n`n6. 关于独立配置`n   - 如果你需要在不同状态下时偏移量、宽高等有区别`n   - 就可以启用独立配置，然后通过【独立配置】按钮进行设置")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/zh-CN/faq/symbol-block">方块符号</a>   <a href="https://inputtip.abgox.com/faq/color-config">颜色配置</a>')
        return g
    }
}

fn_symbol_text(*) {
    createUniqueGui(symbolStyleGui).Show()
    symbolStyleGui(info) {
        g := createGuiOpt("InputTip - 符号方案 - 文本符号")
        tab := g.AddTab3("-Wrap", ["基础配置", "独立配置", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)

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
            tip: "中文状态"
        }, {
            config: "EN_Text",
            textOpt: "yp",
            editOpt: "",
            tip: "英文状态"
        }, {
            config: "Caps_Text",
            textOpt: "yp",
            editOpt: "",
            tip: "大写锁定"
        }]
        symbolConfigBgColor := [{
            config: "textSymbol_CN_color",
            textOpt: "yp",
            editOpt: "",
            tip: "中文状态"
        }, {
            config: "textSymbol_EN_color",
            textOpt: "yp",
            editOpt: "",
            tip: "英文状态"
        }, {
            config: "textSymbol_Caps_color",
            textOpt: "yp",
            editOpt: "",
            tip: "大写锁定"
        }]

        symbolTextConfig := [{
            config: "font_family",
            textOpt: "xs",
            editOpt: "",
            tip: "字符的字体"
        }, {
            config: "font_color",
            textOpt: "yp",
            editOpt: "",
            tip: "字符的颜色"
        }, {
            config: "textSymbol_offset_x",
            textOpt: "xs",
            editOpt: "",
            tip: "水平偏移量"
        }, {
            config: "textSymbol_offset_y",
            textOpt: "yp",
            editOpt: "",
            tip: "垂直偏移量"
        }, {
            config: "textSymbol_transparent",
            textOpt: "yp",
            editOpt: "Number Limit3",
            tip: "字符透明度"
        }, {
            config: "font_size",
            textOpt: "xs",
            editOpt: "Number",
            tip: "字符的大小"
        }, {
            config: "font_weight",
            textOpt: "yp",
            editOpt: "Number",
            tip: "字符的粗细"
        }]

        g.AddText("xs cRed", "文本字符 ")

        for v in symbolConfigChar {
            g.AddText(v.textOpt, v.tip)
            _ := g.AddEdit("yp " v.editOpt " w" bw / 8)
            _._config := v.config
            _.Text := symbolConfig.%v.config%
            _.OnEvent("Change", e_text_config)
        }

        g.AddText("xs cRed", "背景颜色 ")

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

        symbolStyle := ["无", "样式1", "样式2", "样式3"]
        g.AddText("yp", "边框样式")
        _ := g.AddDropDownList("yp AltSubmit w" bw / 6, symbolStyle)
        _.Value := symbolConfig.textSymbol_border_type + 1
        _._config := "textSymbol_border_type"
        _.OnEvent("Change", fn_border_config)
        g.AddText("yp w20")
        _._focus := g.AddEdit("yp w1")
        _._focus.OnEvent("Focus", fn_clear)
        _._focus.OnEvent("LoseFocus", fn_clear)

        tab.UseTab(2)
        g.AddText("Section cRed", gui_help_tip)
        g.AddText("xs", line)

        g.AddText("xs", "是否启用")
        g.AddText("yp cRed", "文本符号")
        g.AddText("yp", "的独立配置: ")
        _ := g.AddDropDownList("yp AltSubmit w" bw / 2, ["【否】", "【是】"])
        _.Value := symbolConfig.enableIsolateConfigText + 1
        _.OnEvent("Change", fn_setIsolateConfig)
        _._config := "enableIsolateConfigText"
        g.AddButton("xs w" bw, "独立配置").OnEvent("Click", e_textIsolateConfig)
        e_textIsolateConfig(*) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            createGui(blockConfigGui).Show()
            blockConfigGui(info) {
                g := createGuiOpt("InputTip - 设置文本符号的独立配置")
                g.AddText("cRed", "文本符号")
                g.AddText("yp", "的独立配置")
                g.AddText("xs", "----------------------------------------------------")

                if (info.i) {
                    return g
                }

                configList := [{
                    config: "font_family",
                    textOpt: "xs",
                    editOpt: "",
                    tip: "字符的字体"
                }, {
                    config: "font_size",
                    textOpt: "xs",
                    editOpt: "Number",
                    tip: "字符的大小"
                }, {
                    config: "font_weight",
                    textOpt: "xs",
                    editOpt: "",
                    tip: "字符的粗细"
                }, {
                    config: "font_color",
                    textOpt: "xs",
                    editOpt: "",
                    tip: "字符的颜色"
                }, {
                    config: "textSymbol_offset_x",
                    textOpt: "xs",
                    editOpt: "",
                    tip: "水平偏移量"
                }, {
                    config: "textSymbol_offset_y",
                    textOpt: "xs",
                    editOpt: "Number Limit3",
                    tip: "垂直偏移量"
                }, {
                    config: "textSymbol_transparent",
                    textOpt: "xs",
                    editOpt: "Number Limit3",
                    tip: "字符透明度"
                }]

                tab := g.AddTab3("-Wrap", ["中文状态", "英文状态", "大写锁定"])
                for i, state in ["CN", "EN", "Caps"] {
                    tab.UseTab(i)
                    g.AddText("Section cRed", stateMap.%state%)
                    g.AddText("yp", "时的独立配置:`n")


                    ; 文本字符
                    config := state "_Text"
                    g.AddText("xs", "文本字符")
                    _g := g.AddEdit("yp")
                    _g.Text := symbolConfig.%config%
                    _g._config := config
                    _g._type := "enableIsolateConfigText"
                    _g.OnEvent("Change", fn_writeIsolateConfig)

                    ; 背景颜色
                    config := "textSymbol_" state "_color"
                    g.AddText("xs", "背景颜色")
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
                    g.AddText("xs", "边框样式: ")
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
        g.AddEdit("ReadOnly r11 w" bw, "1. 配置 —— 中文状态/英文状态/大写锁定的文本字符`n   - 它用来设置不同状态下显示的文本`n   - 如果设置为空，则对应状态不显示符号`n`n2. 配置 —— 中文状态/英文状态/大写锁定的背景颜色`n`n3. 配置 —— 字符的字体`n   - 它用来设置显示的文本的字体`n   - 它有一些注意事项，通过下方相关链接查看`n`n4. 配置 —— 水平/垂直偏移量`n   - 它指的是符号在输入光标附近显示时的偏移量`n   - 注意，符号最终的偏移量为 o1 + o2 + o3`n       - o1 指的是这里的偏移量`n       - o2 指的是【特殊偏移量】中的【不同屏幕下的基础偏移量】`n       - o3 指的是【特殊偏移量】中为指定窗口设置的偏移量`n`n5. 配置 —— 字符透明度`n`n6. 配置 —— 字符的大小`n`n7. 配置 —— 字符的粗细`n`n8. 配置 —— 边框样式`n`n9. 关于独立配置`n   - 如果你需要在不同状态下时偏移量、宽高、大小等有区别`n   - 就可以启用独立配置，然后通过【独立配置】按钮进行设置")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/zh-CN/faq/symbol-text">文本符号</a>   <a href="https://inputtip.abgox.com/faq/color-config">颜色配置</a>   <a href="https://inputtip.abgox.com/zh-CN/faq/font-config">字体配置</a>')
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
