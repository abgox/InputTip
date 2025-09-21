; InputTip

try {
    gui_font_size := IniRead("InputTip.ini", "Config-v2", "gui_font_size")
} catch {
    try {
        IniWrite("12", "InputTip.ini", "Config-v2", "gui_font_size")
    }
    gui_font_size := "12"
}

; g.SetFont(fontOpt*)
fontOpt := ["s" gui_font_size, "Microsoft YaHei"]


/**
 * - 创建 Gui 对象。
 * - 能够获取窗口最终的坐标和宽高，方便配置控件(如按钮宽度)。
 * - 原理: 通过先执行一次隐藏显示来获取信息，相当于实际会运行两次
 * @param {Func} callback
 * - 回调函数接受形参 `info`
 *    - `info.x`,`info.y`,`info.w`,`info.h`: 最终计算得到的窗口坐标和宽高。
 *    - 当执行隐藏显示时，`info.i` 为 `1`，否则为 `0`
 * @returns {Gui} 返回 Gui 对象
 * @example
 * createGui(helloGui).Show()
 * helloGui(info) {
 *     g := createGuiOpt("")
 *     g.AddText(, "xxxxxxxxxxxxxxxxxxx")
 *     ; 第一次隐藏显示，可以通过它在合适的地方直接返回，减少多余的执行
 *     if (info.i) {
 *         return g
 *     }
 *     w := info.w
 *     bw := w - g.MarginX * 2
 *     ; 其他控件...
 *     g.AddButton("w" bw, "确定")
 *     return g
 * }
 */
createGui(callback) {
    g := callback({ x: 0, y: 0, w: 0, h: 0, i: 1 })
    g.Show("Hide")
    g.GetPos(&x, &y, &w, &h)
    g.Destroy()
    return callback({ x: x, y: y, w: w, h: h, i: 0 })
}

/**
 * 创建一个唯一的 Gui
 * @param {Func} callback
 * - 回调函数接受形参 `info`
 *    - `info.x`,`info.y`,`info.w`,`info.h`: 最终计算得到的窗口坐标和宽高。
 *    - 当执行隐藏显示时，`info.i` 为 `1`，否则为 `0`
 * @returns {Gui} 返回 Gui 对象
 * @example
 * createUniqueGui(helloGui).Show()
 * helloGui(info) {
 *     g := createGuiOpt("")
 *     g.AddText(, "xxxxxxxxxxxxxxxxxxx")
 *     ; 第一次隐藏显示，可以通过它在合适的地方直接返回，减少多余的执行
 *     if (info.i) {
 *         return g
 *     }
 *     w := info.w
 *     bw := w - g.MarginX * 2
 *     ; 其他控件...
 *     g.AddButton("w" bw, "确定")
 *     return g
 * }
 */
createUniqueGui(callback) {
    static w := Map()
    g := createGui(callback)
    g.GetPos(, , &width, &height)
    ; 基本确保唯一性
    id := g.Title "_" width "_" height
    if (w.Has(id)) {
        try {
            w.Get(id).Destroy()
            w.Delete(id)
        }
    }
    w.Set(id, g)
    return g
}

/**
 * @param title Gui 标题
 * @param {Array} fontOption 字体配置(如: ["s12", "Microsoft YaHei"])
 * - 这里为了方便 InputTip 使用，默认值使用了外部的 fontOpt 变量
 * @param {String} guiOption Gui 初始化配置
 * @returns {Gui} 返回 Gui 对象
 */
createGuiOpt(title, fontOption := fontOpt, guiOption := "") {
    g := Gui(guiOption, title)
    g.SetFont(fontOption*)
    return g
}


/**
 * 创建一个提示 Gui
 * @param {Array} Tips 显示的提示信息
 * @param {String} title Gui 标题
 * @param {String} btnText 按钮文本
 * @returns {Gui} 返回 Gui 对象
 */
createTipGui(Tips, title := "InputTip - 提示", btnText := "我知道了") {
    tipGui(info) {
        g := createGuiOpt(title)

        for v in Tips {
            g.AddLink(v.opt, v.text)
        }

        if (info.i) {
            return g
        }

        btn := g.AddButton("xs w" info.w, btnText)
        btn.Focus()
        btn.OnEvent("Click", (*) => g.Destroy())
        return g
    }
    return createUniqueGui(tipGui)
}
