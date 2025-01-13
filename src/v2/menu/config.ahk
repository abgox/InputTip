fn_config(*) {
    if (gc.w.configGui) {
        gc.w.configGui.Destroy()
        gc.w.configGui := ""
        try {
            gc.w.subGui.Destroy()
            gc.w.subGui := ""
        }
    }
    line := "-------------------------------------------------------------------------------------------------------------"
    createGui(changeConfigGui).Show()
    changeConfigGui(info) {
        g := createGuiOpt("InputTip - 更改配置")
        ; tab := g.AddTab3("-Wrap 0x100", ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号"])
        tab := g.AddTab3("-Wrap", ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号", "其他杂项"])
        tab.UseTab(1)
        g.AddLink("Section cRed", '你首先应该查看相关的说明文档: <a href="https://inputtip.pages.dev/v2/">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>   <a href="https://inputtip.pages.dev/FAQ/">一些常见的使用问题</a>')
        g.AddText("xs", line)
        g.AddText("xs cGray", "所有的配置项修改会实时生效，可以立即看到最新效果，但是更改时不要太快`n比如需要输入值的配置项，输入过快可能因为响应稍慢导致最新修改丢失，需要放缓输入速度`n")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", "1. 要不要同步修改鼠标样式: ")
        _ := g.AddDropDownList("w" bw / 2 " yp AltSubmit Choose" changeCursor + 1, ["【否】不要修改鼠标样式，保持原本的鼠标样式", "【是】需要修改鼠标样式，随输入法状态而变化"])
        g.AddText("xs cGray", "推荐设置为【是】，它与符号一起配合使用才是最完美的输入法状态提示方案")
        _.Focus()
        _.OnEvent("Change", e_change_cursor)
        e_change_cursor(item, *) {
            static last := changeCursor + 1
            if (last = item.value) {
                return
            }
            last := item.value

            if (item.value = 1) {
                writeIni("changeCursor", 0)
                global changeCursor := 0
                for v in cursorInfo {
                    if (v.origin) {
                        DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
                    }
                }

                if (gc.w.subGui) {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
                createGui(doingGui).Show()
                doingGui(info) {
                    g := createGuiOpt()
                    g.AddText(, "正在尝试恢复到使用 InputTip 之前的鼠标样式")
                    g.AddText("cRed", "可能无法完全恢复，你需要进行以下额外步骤或者重启系统:`n1. 进入「系统设置」=>「蓝牙和其他设备」=>「鼠标」=>「其他鼠标设置」`n2. 先更改为另一个鼠标样式方案，再改回你之前使用的方案")

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    y := g.AddButton("w" bw, "我知道了")
                    y.Focus()
                    y.OnEvent("Click", yes)
                    yes(*) {
                        g.Destroy()
                    }
                    gc.w.subGui := g
                    return g
                }
            } else {
                writeIni("changeCursor", 1)
                global changeCursor := 1
                reloadCursor()
            }
            restartJetBrains()
        }

        g.addText("xs", "2. 在输入光标附近显示什么类型的符号: ")
        g.AddDropDownList("yp AltSubmit Choose" symbolType + 1 " w" bw / 3, ["【不】显示符号", "显示【图片】符号", "显示【方块】符号", "显示【文本】符号"]).OnEvent("Change", e_symbol_type)
        e_symbol_type(item, *) {
            writeIni("symbolType", item.value - 1)
            global symbolType := item.value - 1
            hideSymbol()
            updateSymbol()
            reloadSymbol()
            gc._focusSymbol.Focus()
        }
        g.AddText("yp w20")
        gc._focusSymbol := g.AddEdit("yp w1")
        gc._focusSymbol.OnEvent("Focus", fn_clear)
        gc._focusSymbol.OnEvent("LoseFocus", fn_clear)
        fn_clear(item, *) {
            item.value := ""
        }
        g.AddText("xs cGray", "鼠标悬浮在符号上时，符号会隐藏，下次键盘操作或光标位置变化时再次显示")
        g.AddText("xs", "3. 无键盘和鼠标左键点击操作时，符号在多少")
        g.AddText("yp cRed", "毫秒")
        g.AddText("yp", "后隐藏:")
        _ := g.AddEdit("yp Number")
        _.Value := HideSymbolDelay
        _.OnEvent("Change", e_hideSymbolDelay)
        e_hideSymbolDelay(item, *) {
            value := item.value
            if (value = "") {
                return
            }
            if (value != 0 && value < 150) {
                value := 150
            }
            writeIni("HideSymbolDelay", value)
            global HideSymbolDelay := value
            updateDelay()
            restartJetBrains()
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" bw, "单位: 毫秒，默认为 0 毫秒，表示不隐藏符号。`n当不为 0 时，此值不能小于 150，若小于 150，则使用 150。建议 500 以上。`n符号隐藏后，下次键盘操作或点击鼠标左键会再次显示符号")
        g.AddText("xs", "4. 每多少")
        g.AddText("yp cRed", "毫秒")
        g.AddText("yp", "后更新符号的显示位置和状态:")
        _ := g.AddEdit("yp Number Limit3")
        _.Value := delay
        _.OnEvent("Change", e_delay)
        e_delay(item, *) {
            value := item.value
            if (value = "") {
                return
            }
            value += value <= 0
            if (value > 500) {
                value := 500
            }
            writeIni("delay", value)
            global delay := value
            restartJetBrains()
        }

        ; g.AddUpDown("Range1-500", delay)
        g.AddEdit("xs ReadOnly cGray -VScroll w" bw, "单位：毫秒，默认为 50 毫秒。一般使用 1-100 之间的值。`n此值的范围是 1-500，如果超出范围则无效，会取最近的可用值。`n值越小，响应越快，性能消耗越大，根据电脑性能适当调整")

        tab.UseTab(2)
        g.AddText("Section", "你应该首先查看")
        g.AddText("yp cRed", "鼠标样式")
        g.AddLink("yp", '的相关说明: <a href="https://inputtip.pages.dev/FAQ/cursor-style">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
        g.AddText("xs", line)
        g.AddText("xs Section cGray", "可以点击「下载鼠标样式扩展包」去下载已经适配的鼠标样式")
        g.AddText("cRed", "如果列表中显示的鼠标样式文件夹路径不是最新的，请重新打开这个配置界面")
        dirList := StrSplit(cursorDir, ":")
        if (dirList.Length = 0) {
            dirList := getCursorDir()
        }
        g.AddText("Section", "选择鼠标样式文件夹路径，InputTip 会使用其中的鼠标样式文件，根据不同输入法状态加载对应的鼠标样式")
        for i, v in ["CN", "EN", "Caps"] {
            g.AddText("xs", i ".")
            g.AddText("yp cRed", stateMap.%v%)
            _ := g.AddDropDownList("xs r9 w" bw, dirList)
            _._config := v "_cursor"
            _.OnEvent("Change", e_cursor_dir)
            e_cursor_dir(item, *) {
                writeIni(item._config, item.Text)
                updateCursor()
                reloadCursor()
            }
            try {
                _.Text := %v "_cursor"%
            } catch {
                _.Text := ""
            }
        }
        g.AddButton("xs w" bw, "下载鼠标样式扩展包").OnEvent("Click", e_cursor_package)
        e_cursor_package(*) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            g := createGuiOpt("下载鼠标样式扩展包")
            g.AddText("Center h30", "从以下任意可用地址中下载鼠标样式扩展包:")
            g.AddLink("xs", '<a href="https://inputtip.pages.dev/download/extra">https://inputtip.pages.dev/download/extra</a>')
            g.AddLink("xs", '<a href="https://github.com/abgox/InputTip/releases/tag/extra">https://github.com/abgox/InputTip/releases/tag/extra</a>')
            g.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/releases/tag/extra">https://gitee.com/abgox/InputTip/releases/tag/extra</a>')
            g.AddText(, "其中的鼠标样式已经完成适配，解压到 InputTipCursor 目录中即可使用")
            g.Show()
            gc.w.subGui := g
        }

        tab.UseTab(3)
        g.AddText("Section", "你应该首先查看")
        g.AddText("yp cRed", "图片符号")
        g.AddLink("yp", '的相关说明: <a href="https://inputtip.pages.dev/FAQ/symbol-picture">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
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
        for v in symbolPicConfig {
            g.AddText(v.textOpt, v.tip ": ")
            _ := g.AddEdit("yp " v.editOpt " w" bw / 8)
            _._config := v.config
            _.Value := readIni(v.config, 0)
            _.OnEvent("Change", e_pic_config)
            e_pic_config(item, *) {
                writeIni(item._config, returnNumber(item.value))
                hideSymbol()
                updateSymbol()
                reloadSymbol()
                restartJetBrains()
            }
        }
        ; todo
        g.AddText("xs", "是否启用")
        g.AddText("yp cRed", "图片符号")
        g.AddText("yp", "的独立配置: ")
        g.AddDropDownList("yp AltSubmit w" bw / 2, ["【否】禁用独立配置，则上方的统一配置生效", "【是】启用独立配置，则上方的统一配置无效"])
        g.AddButton("xs w" bw, "设置图片符号在不同状态下的独立配置").OnEvent("Click", e_picIsolateConfig)
        e_picIsolateConfig(*) {

        }

        dirList := StrSplit(picDir, ":")
        if (dirList.Length = 0) {
            dirList := getPicDir()
        }
        g.AddText("xs Section cRed", "如果列表中显示的图片符号路径不是最新的，请重新打开这个配置界面")
        g.AddText(, "选择图片符号的文件路径: ")
        for i, v in ["CN", "EN", "Caps"] {
            __ := g.AddText("xs", i ".")
            _ := g.AddText("yp cRed", stateMap.%v%)
            if (i = 1) {
                __.GetPos(, , &_w1)
                _.GetPos(, , &_w2)
                g.AddText("yp w" w / 2 - (_w1 + g.MarginX * 2 + _w2) - g.MarginX / 2)
                gc._focusSymbolPic := g.AddEdit("yp w1")
                gc._focusSymbolPic.OnEvent("Focus", fn_clear)
                gc._focusSymbolPic.OnEvent("LoseFocus", fn_clear)
            }

            _ := g.AddDropDownList("xs r9 w" bw, dirList)
            _._config := v "_pic"
            _.OnEvent("Change", e_pic_path)
            e_pic_path(item, *) {
                writeIni(item._config, item.Text)
                hideSymbol()
                updateSymbol()
                reloadSymbol()
                if (symbolType = 1) {
                    gc._focusSymbolPic.Focus()
                }
            }

            try {
                _.Text := readIni(v "_pic", "")
            } catch {
                _.Text := ""
            }
        }
        g.AddButton("xs w" bw, "下载图片符号扩展包").OnEvent("Click", e_pic_package)
        e_pic_package(*) {
            if (gc.w.subGui) {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
            g := createGuiOpt("下载图片符号扩展包")
            g.AddText("Center h30", "从以下任意可用地址中下载图片符号扩展包:")
            g.AddLink("xs", '<a href="https://inputtip.pages.dev/download/extra">https://inputtip.pages.dev/download/extra</a>')
            g.AddLink("xs", '<a href="https://github.com/abgox/InputTip/releases/tag/extra">https://github.com/abgox/InputTip/releases/tag/extra</a>')
            g.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/releases/tag/extra">https://gitee.com/abgox/InputTip/releases/tag/extra</a>')
            g.AddText(, "将其中的图片解压到 InputTipSymbol 目录中即可使用")
            g.Show()
            gc.w.subGui := g
        }

        tab.UseTab(4)
        symbolBlockColorConfig := [{
            config: "CN_color",
            editOpt: "",
            tip: "中文状态时方块符号的颜色",
            colors: ["red", "#FF5555", "#F44336", "#D23600", "#FF1D23", "#D40D12", "#C30F0E", "#5C0002", "#450003"]
        }, {
            config: "EN_color",
            editOpt: "",
            tip: "英文状态时方块符号的颜色",
            colors: ["blue", "#528BFF", "#0EEAFF", "#59D8E6", "#2962FF", "#1B76FF", "#2C1DFF", "#1C3FFD", "#1510F0"]
        }, {
            config: "Caps_color",
            editOpt: "",
            tip: "大写锁定时方块符号的颜色",
            colors: ["green", "#4E9A06", "#96ED89", "#66BB6A", "#8BC34A", "#45BF55", "#43A047", "#2E7D32", "#33691E"]
        }]
        symbolBlockConfig := [{
            config: "transparent",
            editOpt: "Number Limit3",
            tip: "方块符号的方块透明度"
        }, {
            config: "offset_x",
            editOpt: "",
            tip: "方块符号的水平偏移量"
        }, {
            config: "offset_y",
            editOpt: "",
            tip: "方块符号的垂直偏移量"
        }, {
            config: "symbol_height",
            editOpt: "Number",
            tip: "方块符号的高度"
        }, {
            config: "symbol_width",
            editOpt: "Number",
            tip: "方块符号的宽度"
        }]
        g.AddText("Section", "1. 你应该首先查看")
        g.AddText("yp cRed", "方块符号")
        g.AddLink("yp", '的相关说明: <a href="https://inputtip.pages.dev/FAQ/symbol-block">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
        g.AddLink("xs", '2. 颜色设置为空，表示不显示对应的方块符号。 <a href="https://inputtip.pages.dev/FAQ/color-config">关于颜色配置</a>')
        g.AddText("xs", line)
        for v in symbolBlockColorConfig {
            g.AddText("xs", v.tip ": ")
            _ := g.AddComboBox("yp " v.editOpt, v.colors)
            _._config := v.config
            _.Text := readIni(v.config, "red")
            _.OnEvent("Change", e_color_config)
            e_color_config(item, *) {
                writeIni(item._config, item.Text)
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }
        }
        for v in symbolBlockConfig {
            g.AddText("xs", v.tip ": ")
            _ := g.AddEdit("yp " v.editOpt)
            _._config := v.config
            _.Value := readIni(v.config, 1)
            _.OnEvent("Change", e_block_config)
            e_block_config(item, *) {
                value := item.value
                if (item._config = "transparent") {
                    if (value = "") {
                        return
                    }
                    if (value > 255) {
                        value := 255
                    }
                }
                writeIni(item._config, returnNumber(value))
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }
        }
        symbolStyle := ["无", "样式1", "样式2", "样式3"]
        g.AddText("xs", "方块符号的边框样式: ")
        _ := g.AddDropDownList("yp AltSubmit", symbolStyle)
        _.Value := readIni("border_type", "") + 1
        _.OnEvent("Change", e_border_config)
        e_border_config(item, *) {
            writeIni("border_type", item.value - 1)
            hideSymbol()
            updateSymbol()
            reloadSymbol()
            if (symbolType = 2) {
                gc._focusBlock.Focus()
            }
        }
        g.AddText("yp w20")
        gc._focusBlock := g.AddEdit("yp w1")
        gc._focusBlock.OnEvent("Focus", fn_clear)
        gc._focusBlock.OnEvent("LoseFocus", fn_clear)

        ; todo
        g.AddText("xs", "是否启用")
        g.AddText("yp cRed", "方块符号")
        g.AddText("yp", "的独立配置: ")
        g.AddDropDownList("yp AltSubmit w" bw / 2, ["【否】禁用独立配置，则上方的统一配置生效", "【是】启用独立配置，则上方的统一配置无效"])
        g.AddButton("xs w" bw, "设置方块符号在不同状态下的独立配置").OnEvent("Click", e_blockIsolateConfig)
        e_blockIsolateConfig(*) {

        }
        tab.UseTab(5)
        g.AddText("Section", "1. 你应该首先查看")
        g.AddText("yp cRed", "文本符号")
        g.AddLink("yp", '的相关说明: <a href="https://inputtip.pages.dev/FAQ/symbol-text">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
        g.AddLink("xs", '2. 文本字符可以设置为空，表示不显示对应的文本字符。 <a href="https://inputtip.pages.dev/FAQ/color-config">关于颜色配置</a>')
        g.AddText("xs", line)
        symbolTextConfig := [{
            config: "CN_Text",
            textOpt: "xs",
            editOpt: "",
            tip: "中文状态时的文本字符"
        }, {
            config: "textSymbol_CN_color",
            textOpt: "yp",
            editOpt: "",
            tip: "中文状态时的背景颜色"
        }, {
            config: "EN_Text",
            textOpt: "xs",
            editOpt: "",
            tip: "英文状态时的文本字符"
        }, {
            config: "textSymbol_EN_color",
            textOpt: "yp",
            editOpt: "",
            tip: "英文状态时的背景颜色"
        }, {
            config: "Caps_Text",
            textOpt: "xs",
            editOpt: "",
            tip: "大写锁定时的文本字符"
        }, {
            config: "textSymbol_Caps_color",
            textOpt: "yp",
            editOpt: "",
            tip: "大写锁定时的背景颜色"
        }, {
            config: "font_family",
            textOpt: "xs",
            editOpt: "",
            tip: "文本符号的字符的字体"
        }, {
            config: "font_size",
            textOpt: "yp",
            editOpt: "Number",
            tip: "文本符号的字符的大小"
        }, {
            config: "font_weight",
            textOpt: "xs",
            editOpt: "Number",
            tip: "文本符号的字符的粗细"
        }, {
            config: "font_color",
            textOpt: "yp",
            editOpt: "",
            tip: "文本符号的字符的颜色"
        }, {
            config: "textSymbol_offset_x",
            textOpt: "xs",
            editOpt: "",
            tip: "文本符号的水平偏移量"
        }, {
            config: "textSymbol_offset_y",
            textOpt: "yp",
            editOpt: "",
            tip: "文本符号的垂直偏移量"
        }, {
            config: "textSymbol_transparent",
            textOpt: "xs",
            editOpt: "Number Limit3",
            tip: "文本符号的字符透明度"
        }]
        for v in symbolTextConfig {
            g.AddText(v.textOpt, v.tip ": ")
            _ := g.AddEdit("yp " v.editOpt)
            _._config := v.config
            _.Value := %v.config%
            _.OnEvent("Change", e_text_config)
        }
        e_text_config(item, *) {
            value := item.value
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
            writeIni(item._config, value)
            hideSymbol()
            updateSymbol()
            reloadSymbol()
        }
        symbolStyle := ["无", "样式1", "样式2", "样式3"]
        g.AddText("xs", "文本符号的边框样式: ")
        _ := g.AddDropDownList("yp AltSubmit", symbolStyle)
        _.Value := readIni("textSymbol_border_type", "") + 1
        _.OnEvent("Change", en_border_config2)
        en_border_config2(item, *) {
            writeIni("textSymbol_border_type", item.value - 1)
            hideSymbol()
            updateSymbol()
            reloadSymbol()
            if (symbolType = 3) {
                gc._focusText.Focus()
            }
        }

        g.AddText("yp w20")
        gc._focusText := g.AddEdit("yp w1")
        gc._focusText.OnEvent("Focus", fn_clear)
        gc._focusText.OnEvent("LoseFocus", fn_clear)
        g.AddText()
        ; todo
        g.AddText("xs", "是否启用")
        g.AddText("yp cRed", "文本符号")
        g.AddText("yp", "的独立配置: ")
        g.AddDropDownList("yp AltSubmit w" bw / 2, ["【否】禁用独立配置，则上方的统一配置生效", "【是】启用独立配置，则上方的统一配置无效"])
        g.AddButton("xs w" bw, "设置文本符号在不同状态下的独立配置").OnEvent("Click", e_textIsolateConfig)
        e_textIsolateConfig(*) {

        }
        tab.UseTab(6)
        g.AddText("Section", "1. 所有配置菜单的字体大小: ")
        _ := g.AddEdit("yp Number Limit2")
        _.Value := readIni("gui_font_size", "12")
        _.OnEvent("Change", e_change_gui_fs)
        e_change_gui_fs(item, *) {
            value := item.value
            if (value = "" || value < 5 || value > 30) {
                return
            }
            writeIni("gui_font_size", value)
            global fontOpt := ["s" value, "微软雅黑"]
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" bw, "取值范围: 5-30，超出范围的值无效，建议 12-20。`n如果觉得配置菜单的字体太大或太小，可以适当调整这个值，重新打开配置菜单即可。")
        g.AddText("xs", "2. 点击下方按钮，实时显示当前激活的窗口进程信息")
        g.AddText("yp", " ").GetPos(, , &__w)
        gc._window_info := g.AddButton("xs w" bw, "获取窗口进程信息")
        gc._window_info.OnEvent("Click", e_window_info)
        g.AddText("xs cRed", "名称: ").GetPos(, , &_w)
        _width := bw - _w - g.MarginX + __w
        gc.app_name := g.AddEdit("yp ReadOnly -VScroll w" _width)
        g.AddText("xs cRed", "标题: ").GetPos(, , &_w)
        gc.app_title := g.AddEdit("yp ReadOnly -VScroll w" _width)
        g.AddText("xs cRed", "路径: ").GetPos(, , &_w)
        gc.app_path := g.AddEdit("yp ReadOnly -VScroll w" _width)
        e_window_info(*) {
            if (gc.timer) {
                gc.timer := 0
                gc._window_info.Text := "获取窗口进程信息"
                return
            }

            gc.timer := 1
            gc._window_info.Text := "停止获取"

            SetTimer(statusTimer, 25)
            statusTimer() {
                static first := "", last := ""

                if (!gc.timer) {
                    SetTimer(, 0)
                    first := ""
                    last := ""
                    return
                }

                try {
                    if (!first) {
                        name := WinGetProcessName("A")
                        title := WinGetTitle("A")
                        path := WinGetProcessPath("A")
                        gc.app_name.Value := name
                        gc.app_title.Value := title
                        gc.app_path.Value := path
                        first := name title path
                    }

                    name := WinGetProcessName("A")
                    title := WinGetTitle("A")
                    path := WinGetProcessPath("A")
                    info := name title path
                    if (info = last || info = first) {
                        return
                    }
                    gc.app_name.Value := name
                    gc.app_title.Value := title
                    gc.app_path.Value := path
                    last := info
                }
            }
        }
        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            gc.timer := 0
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        gc.w.configGui := g
        return g
    }
    SetTimer(getDirTimer, -1)
    getDirTimer() {
        _cursorDir := arrJoin(getCursorDir(), ":")
        _picDir := arrJoin(getPicDir(), ":")
        if (cursorDir != _cursorDir) {
            global cursorDir := _cursorDir
            writeIni("cursorDir", _cursorDir)
        }
        if (picDir != _picDir) {
            global picDir := _picDir
            writeIni("picDir", _picDir)
        }
    }
}
