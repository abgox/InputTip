fn_config(*) {
    if (gc.w.configGui) {
        gc.w.configGui.Destroy()
        gc.w.configGui := ""

        try {
            gc.w.subGui.Destroy()
            gc.w.subGui := ""
        }
    }
    line := "-----------------------------------------------------------------------------------------------"
    configGui := Gui("AlwaysOnTop")
    configGui.SetFont(fz, "微软雅黑")
    configGui.AddText(, line)
    configGui.Show("Hide")
    configGui.GetPos(, , &Gui_width)
    configGui.Destroy()

    configGui := Gui("AlwaysOnTop", "InputTip - 更改配置")
    configGui.SetFont(fz, "微软雅黑")
    ; tab := configGui.AddTab3("-Wrap 0x100", ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号", "配色网站"])
    tab := configGui.AddTab3("-Wrap", ["显示形式", "鼠标样式", "图片符号", "方块符号", "文本符号", "其他杂项", "配色网站"])
    tab.UseTab(1)

    configGui.AddText("Section cRed", "在更改配置前，你应该首先阅读一下相关的说明文档")
    configGui.AddLink("xs", '<a href="https://inputtip.pages.dev/v2/">官网</a>')
    configGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">Github</a>')
    configGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">Gitee</a>')
    configGui.AddLink("yp", '<a href="https://inputtip.pages.dev/FAQ/">一些常见的使用问题</a>')

    configGui.AddText("xs cRed", "所有的配置项的更改会实时生效，你可以立即看到最新效果")
    configGui.AddText("xs", line)
    configGui.AddText("xs", "1. 要不要同步修改鼠标样式: ")
    _g := configGui.AddDropDownList("w" Gui_width / 1.6 " yp AltSubmit Choose" changeCursor + 1, ["【否】不要修改鼠标样式，保持原本的鼠标样式", "【是】需要修改鼠标样式，随输入法状态而变化"])
    _g.OnEvent("Change", fn_change_cursor)
    _g.Focus()
    fn_change_cursor(item, *) {
        static last := changeCursor + 1
        if (last = item.Value) {
            return
        }
        last := item.Value

        if (item.Value = 1) {
            writeIni("changeCursor", 0)
            global changeCursor := 0
            for v in cursorInfo {
                if (v.origin) {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
                }
            }

            createGui(fn).Show()
            fn(x, y, w, h) {
                if (gc.w.subGui) {
                    gc.w.subGui.Destroy()
                    gc.w.subGui := ""
                }
                g := Gui("AlwaysOnTop")
                g.SetFont(fz, "微软雅黑")
                bw := w - g.MarginX * 2
                g.AddText(, "正在尝试恢复到使用 InputTip 之前的鼠标样式")
                g.AddText("cRed", "可能无法完全恢复，你需要进行以下额外步骤或者重启系统:`n1. 进入「系统设置」=>「蓝牙和其他设备」=>「鼠标」=>「其他鼠标设置」`n2. 先更改为另一个鼠标样式方案，再改回你之前使用的方案")
                y := g.AddButton("w" bw, "我知道了")
                y.OnEvent("Click", yes)
                y.Focus()
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

    configGui.addText("xs", "2. 在输入光标附近显示什么类型的符号: ")
    configGui.AddDropDownList("yp AltSubmit Choose" symbolType + 1, ["不显示符号", "显示图片符号", "显示方块符号", "显示文本符号"]).OnEvent("Change", fn_symbol_type)
    fn_symbol_type(item, *) {
        writeIni("symbolType", item.Value - 1)
        global symbolType := item.Value - 1
        hideSymbol()
        updateSymbol()
        reloadSymbol()
    }
    configGui.AddText("xs", "3. 无键盘和鼠标左键点击操作时，符号在多少")
    configGui.AddText("yp cRed", "毫秒")
    configGui.AddText("yp", "后隐藏:")
    _g := configGui.AddEdit("yp Number")
    _g.Value := HideSymbolDelay
    _g.OnEvent("Change", fn_hide_symbol_delay)
    fn_hide_symbol_delay(item, *) {
        value := item.Value
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
    configGui.AddEdit("xs ReadOnly cGray -VScroll w" Gui_width, "单位: 毫秒，默认为 0 毫秒，表示不隐藏符号。`n当不为 0 时，此值不能小于 150，若小于 150，则使用 150。建议 500 以上。`n符号隐藏后，下次键盘操作或点击鼠标左键会再次显示符号")
    configGui.AddText("xs", "4. 每多少")
    configGui.AddText("yp cRed", "毫秒")
    configGui.AddText("yp", "后更新符号的显示位置和状态:")
    _g := configGui.AddEdit("yp Number Limit3")
    _g.Value := delay
    _g.OnEvent("Change", fn_delay)
    fn_delay(item, *) {
        value := item.Value
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
    ; configGui.AddUpDown("Range1-500", delay)
    configGui.AddEdit("xs ReadOnly cGray -VScroll w" Gui_width, "单位：毫秒，默认为 50 毫秒。一般使用 1-100 之间的值。`n此值的范围是 1-500，如果超出范围则无效，会取最近的可用值。`n值越小，响应越快，性能消耗越大，根据电脑性能适当调整")

    tab.UseTab(2)
    configGui.AddText(, "你可以点击以下任意网址获取设置鼠标样式文件夹的相关说明:")
    configGui.AddLink(, '<a href="https://inputtip.pages.dev/v2/#自定义鼠标样式">官网</a>   <a href="https://github.com/abgox/InputTip#自定义鼠标样式">Github</a>   <a href="https://gitee.com/abgox/InputTip#自定义鼠标样式">Gitee</a>`n' line)
    configGui.AddText("cRed", "如果列表中显示的鼠标样式文件夹路径不是最新的，请重新打开这个配置界面")
    typeList := [{
        label: "中文状态",
        type: "CN",
    }, {
        label: "英文状态",
        type: "EN",
    }, {
        label: "大写锁定",
        type: "Caps",
    }]

    dirList := StrSplit(cursorDir, ":")
    if (dirList.Length = 0) {
        dirList := getCursorDir()
    }

    configGui.AddText("Section", "选择不同状态下的鼠标样式文件夹目录路径: ")
    for i, v in typeList {
        configGui.AddText("xs", i ".")
        configGui.AddText("yp cRed", v.label)
        configGui.AddText("yp", "鼠标样式: ")
        _g := configGui.AddDropDownList("xs r9 w" Gui_width " v" v.type "_cursor", dirList)
        _g.OnEvent("Change", fn_cursor_dir)
        fn_cursor_dir(item, *) {
            if (item.Text = "") {
                return
            }
            writeIni(item.Name, item.Text)
            switch (item.Name) {
                case "CN_cursor":
                {
                    global CN_cursor := item.Text
                }
                case "EN_cursor":
                {
                    global EN_cursor := item.Text
                }
                case "Caps_cursor":
                {
                    global Caps_cursor := item.Text
                }
            }
            updateCursor()
            reloadCursor()
        }
        try {
            _g.Text := %v.type "_cursor"%
        } catch {
            _g.Text := ""
        }
    }
    configGui.AddButton("xs w" Gui_width, "下载鼠标样式扩展包").OnEvent("Click", fn_cursor_package)
    fn_cursor_package(*) {
        if (gc.w.subGui) {
            gc.w.subGui.Destroy()
            gc.w.subGui := ""
        }
        dlGui := Gui("AlwaysOnTop", "下载鼠标样式扩展包")
        dlGui.SetFont(fz, "微软雅黑")
        dlGui.AddText("Center h30", "从以下任意可用地址中下载鼠标样式扩展包:")
        dlGui.AddLink("xs", '<a href="https://inputtip.pages.dev/download/extra">https://inputtip.pages.dev/download/extra</a>')
        dlGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/releases/tag/extra">https://github.com/abgox/InputTip/releases/tag/extra</a>')
        dlGui.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/releases/tag/extra">https://gitee.com/abgox/InputTip/releases/tag/extra</a>')
        dlGui.AddText(, "其中的鼠标样式已经完成适配，解压到 InputTipCursor 目录中即可使用")
        dlGui.Show()
        gc.w.subGui := dlGui
    }
    tab.UseTab(3)
    configGui.AddLink("Section", '点击下方链接查看图片符号的详情说明: <a href="https://inputtip.pages.dev/v2/#图片符号">官网</a>   <a href="https://github.com/abgox/InputTip#图片符号">Github</a>   <a href="https://gitee.com/abgox/InputTip#图片符号">Gitee</a>' "`n" line)

    symbolPicConfig := [{
        config: "pic_offset_x",
        options: "xs",
        opts: "",
        tip: "图片符号的水平偏移量"
    }, {
        config: "pic_symbol_width",
        options: "yp",
        opts: "Number",
        tip: "图片符号的宽度"
    }, {
        config: "pic_offset_y",
        options: "xs",
        opts: "",
        tip: "图片符号的垂直偏移量"
    }, {
        config: "pic_symbol_height",
        options: "yp",
        opts: "Number",
        tip: "图片符号的高度"
    }]
    for v in symbolPicConfig {
        configGui.AddText(v.options, v.tip ": ")
        _g := configGui.AddEdit("v" v.config " yp " v.opts)
        _g.Value := readIni(v.config, 0)
        _g.OnEvent("Change", fn_pic_config)

        fn_pic_config(item, *) {
            value := returnNumber(item.Value)
            writeIni(item.Name, value)
            switch (item.Name) {
                case "pic_offset_x":
                {
                    global pic_offset_x := value
                    restartJetBrains()
                }
                case "pic_offset_y":
                {
                    global pic_offset_y := value
                    restartJetBrains()
                }
                case "pic_symbol_width":
                {
                    global pic_symbol_width := value
                    hideSymbol()
                    updateSymbol()
                    reloadSymbol()
                }
                case "pic_symbol_height":
                {
                    global pic_symbol_height := value
                    hideSymbol()
                    updateSymbol()
                    reloadSymbol()
                }
            }
        }
    }

    dirList := StrSplit(picDir, ":")
    if (dirList.Length = 0) {
        dirList := getPicDir()
    }

    configGui.AddText("xs Section cRed", "如果列表中显示的图片符号路径不是最新的，请重新打开这个配置界面")
    configGui.AddText(, "选择或输入不同状态下的图片符号的图片路径(只能是 .png 图片或设置为空): ")
    for i, v in typeList {
        configGui.AddText("xs", i ".")
        configGui.AddText("yp cRed", v.label)
        configGui.AddText("yp", "图片符号: ")
        _g := configGui.AddDropDownList("xs r9 w" Gui_width " v" v.type "_pic", dirList)
        _g.OnEvent("Change", fn_pic_path)
        fn_pic_path(item, *) {
            writeIni(item.Name, item.Text)
            switch (item.Name) {
                case "CN_pic":
                {
                    global CN_pic := item.Text
                }
                case "EN_pic":
                {
                    global EN_pic := item.Text
                }
                case "Caps_pic":
                {
                    global Caps_pic := item.Text
                }
            }
            hideSymbol()
            updateSymbol()
            reloadSymbol()
        }

        try {
            _g.Text := readIni(v.type "_pic", "")
        } catch {
            _g.Text := ""
        }
    }

    configGui.AddButton("xs w" Gui_width, "下载图片符号扩展包").OnEvent("Click", fn_pic_package)
    fn_pic_package(*) {
        if (gc.w.subGui) {
            gc.w.subGui.Destroy()
            gc.w.subGui := ""
        }
        dlGui := Gui("AlwaysOnTop", "下载图片符号扩展包")
        dlGui.SetFont(fz, "微软雅黑")
        dlGui.AddText("Center h30", "从以下任意可用地址中下载图片符号扩展包:")
        dlGui.AddLink("xs", '<a href="https://inputtip.pages.dev/download/extra">https://inputtip.pages.dev/download/extra</a>')
        dlGui.AddLink("xs", '<a href="https://github.com/abgox/InputTip/releases/tag/extra">https://github.com/abgox/InputTip/releases/tag/extra</a>')
        dlGui.AddLink("xs", '<a href="https://gitee.com/abgox/InputTip/releases/tag/extra">https://gitee.com/abgox/InputTip/releases/tag/extra</a>')
        dlGui.AddText(, "将其中的图片解压到 InputTipSymbol 目录中即可使用")
        dlGui.Show()
        gc.w.subGui := dlGui
    }

    tab.UseTab(4)
    symbolBlockColorConfig := [{
        config: "CN_color",
        options: "",
        tip: "中文状态时方块符号的颜色",
        colors: ["red", "#FF5555", "#F44336", "#D23600", "#FF1D23", "#D40D12", "#C30F0E", "#5C0002", "#450003"]
    }, {
        config: "EN_color",
        options: "",
        tip: "英文状态时方块符号的颜色",
        colors: ["blue", "#528BFF", "#0EEAFF", "#59D8E6", "#2962FF", "#1B76FF", "#2C1DFF", "#1C3FFD", "#1510F0"]
    }, {
        config: "Caps_color",
        options: "",
        tip: "大写锁定时方块符号的颜色",
        colors: ["green", "#4E9A06", "#96ED89", "#66BB6A", "#8BC34A", "#45BF55", "#43A047", "#2E7D32", "#33691E"]
    }]
    symbolBlockConfig := [{
        config: "transparent",
        options: "Number Limit3",
        tip: "方块符号的透明度"
    }, {
        config: "offset_x",
        options: "",
        tip: "方块符号的水平偏移量"
    }, {
        config: "offset_y",
        options: "",
        tip: "方块符号的垂直偏移量"
    }, {
        config: "symbol_height",
        options: "Number",
        tip: "方块符号的高度"
    }, {
        config: "symbol_width",
        options: "Number",
        tip: "方块符号的宽度"
    }]
    configGui.AddText("Section", "不同状态时方块符号的颜色可以设置为空，表示不显示对应的方块符号`n" line)
    for v in symbolBlockColorConfig {
        configGui.AddText("xs", v.tip ": ")
        _g := configGui.AddComboBox("v" v.config " yp " v.options, v.colors)
        _g.OnEvent("Change", fn_color_config)
        fn_color_config(item, *) {
            value := item.Text
            writeIni(item.Name, value)
            switch (item.Name) {
                case "CN_color":
                {
                    global CN_color := value
                }
                case "EN_color":
                {
                    global EN_color := value
                }
                case "Caps_color":
                {
                    global Caps_color := value
                }
            }
            hideSymbol()
            updateSymbol()
            reloadSymbol()
        }
        _g.Text := readIni(v.config, "red")
    }
    for v in symbolBlockConfig {
        configGui.AddText("xs", v.tip ": ")
        if (v.config = "transparent") {
            _g := configGui.AddEdit("v" v.config " yp " v.options)
            _g.Value := readIni(v.config, 1)
            _g.OnEvent("Change", fn_trans_config)
            fn_trans_config(item, *) {
                value := item.Text
                if (value = "") {
                    return
                }
                if (value > 255) {
                    value := 255
                }
                writeIni(item.Name, value)
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }
        } else {
            _g := configGui.AddEdit("v" v.config " yp " v.options)
            _g.Value := readIni(v.config, 1)
            _g.OnEvent("Change", fn_block_config)
            fn_block_config(item, *) {
                value := returnNumber(item.Text)
                writeIni(item.Name, value)
                switch (item.Name) {
                    case "transparent":
                    {
                        global transparent := value
                    }
                    case "offset_x":
                    {
                        global offset_x := value
                    }
                    case "offset_y":
                    {
                        global offset_y := value
                    }
                    case "symbol_height":
                    {
                        global symbol_height := value
                    }
                    case "symbol_width":
                    {
                        global symbol_width := value
                    }
                }
                hideSymbol()
                updateSymbol()
                reloadSymbol()
            }
        }
    }
    symbolStyle := ["无", "样式1", "样式2", "样式3"]
    configGui.AddText("xs", "边框样式: ")
    _g := configGui.AddDropDownList("yp AltSubmit vborder_type", symbolStyle)
    _g.OnEvent("Change", fn_border_config)
    fn_border_config(item, *) {
        value := item.Value
        writeIni("border_type", value - 1)
        global border_type := value - 1
        hideSymbol()
        updateSymbol()
        reloadSymbol()
    }
    _g.Value := readIni("border_type", "") + 1
    tab.UseTab(5)
    symbolCharConfig := [{
        config: "font_family",
        options: "",
        tip: "文本字符的字体"
    }, {
        config: "font_size",
        options: "Number",
        tip: "文本字符的大小"
    }, {
        config: "font_weight",
        options: "Number",
        tip: "文本字符的粗细"
    }, {
        config: "font_color",
        options: "",
        tip: "文本字符的颜色"
    }, {
        config: "CN_Text",
        options: "",
        tip: "中文状态时显示的文本字符"
    }, {
        config: "EN_Text",
        options: "",
        tip: "英文状态时显示的文本字符"
    }, {
        config: "Caps_Text",
        options: "",
        tip: "大写锁定时显示的文本字符"
    }]
    configGui.AddText("Section cRed", "1. 符号偏移量、透明度、边框样式以及不同状态下的背景颜色由方块符号中的相关配置决定")
    configGui.AddText("xs", "2. 不同状态时显示的文本字符可以设置为空，表示不显示对应的文本字符")
    configGui.AddText("xs", "3. 当方块符号中的背景颜色设置为空时，对应的文本字符也不显示`n" line)
    for v in symbolCharConfig {
        configGui.AddText("xs", v.tip ": ")
        _g := configGui.AddEdit("v" v.config " yp " v.options)
        _g.Value := %v.config%
        _g.OnEvent("Change", fn_char_config)

        fn_char_config(item, *) {
            value := item.Text
            switch (item.Name) {
                case "font_family":
                {
                    global font_family := value
                }
                case "font_size":
                {
                    if (value = "") {
                        return
                    }
                    global font_size := value
                }
                case "font_weight":
                {
                    if (value = "") {
                        return
                    }
                    global font_weight := value
                }
                case "font_color":
                {
                    global font_color := value
                }
                case "CN_Text":
                {
                    global CN_Text := value
                }
                case "EN_Text":
                {
                    global EN_Text := value
                }
                case "Caps_Text":
                {
                    global Caps_Text := value
                }
            }
            writeIni(item.Name, value)
            hideSymbol()
            updateSymbol()
            reloadSymbol()
        }
    }
    tab.UseTab(6)
    configGui.AddText("Section", "1. 所有配置菜单的字体大小: ")
    _g := configGui.AddEdit("yp Number Limit2")
    _g.Value := readIni("gui_font_size", "12")
    _g.OnEvent("Change", fn_change_gui_fs)
    fn_change_gui_fs(item, *) {
        if (item.Value = "" || item.Value < 5 || item.Value > 30) {
            return
        }
        writeIni("gui_font_size", item.Value)
        global fz := "s" item.Value
    }
    configGui.AddEdit("xs ReadOnly cGray -VScroll w" Gui_width, "取值范围: 5-30，超出范围的值无效，建议 12-20。`n如果觉得配置菜单的字体太大或太小，可以适当调整这个值，重新打开配置菜单即可。")

    configGui.AddText("xs", "2. 点击下方按钮，实时显示当前激活的窗口进程信息")
    configGui.AddText("yp", " ").GetPos(, , &__w)
    gc._window_info := configGui.AddButton("xs w" Gui_width, "获取窗口进程信息")
    gc._window_info.OnEvent("Click", fn_window_info)
    configGui.AddText("xs cRed", "名称: ").GetPos(, , &_w)
    _width := Gui_width - _w - configGui.MarginX + __w
    gc.app_name := configGui.AddEdit("yp ReadOnly -VScroll w" _width)
    configGui.AddText("xs cRed", "标题: ").GetPos(, , &_w)
    gc.app_title := configGui.AddEdit("yp ReadOnly -VScroll w" _width)
    configGui.AddText("xs cRed", "路径: ").GetPos(, , &_w)
    gc.app_path := configGui.AddEdit("yp ReadOnly -VScroll w" _width)
    fn_window_info(*) {
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
    tab.UseTab(7)
    configGui.AddText(, "1. 对于颜色相关的配置，建议使用 16 进制的颜色值`n2. 不过由于没有调色板，可能并不好设置`n3. 建议使用以下配色网站(也可以自己去找)，找到喜欢的颜色，复制 16 进制值`n4. 显示的颜色以最终渲染的颜色效果为准")
    configGui.AddLink(, '<a href="https://colorhunt.co">https://colorhunt.co</a>')
    configGui.AddLink(, '<a href="https://materialui.co/colors">https://materialui.co/colors</a>')
    configGui.AddLink(, '<a href="https://color.adobe.com/zh/create/color-wheel">https://color.adobe.com/zh/create/color-wheel</a>')
    configGui.AddLink(, '<a href="https://colordesigner.io/color-palette-builder">https://colordesigner.io/color-palette-builder</a>')

    configGui.OnEvent("Close", fn_close)
    fn_close(*) {
        configGui.Destroy()
        gc.timer := 0
    }
    gc.w.configGui := configGui
    configGui.Show()
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
