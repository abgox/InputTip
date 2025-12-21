; InputTip

fn_symbol_pos(*) {
    createUniqueGui(symbolPos).Show()
    symbolPos(info) {
        g := createGuiOpt("InputTip - 设置符号应该显示在鼠标附近的应用")
        tab := g.AddTab3("-Wrap", ["在鼠标附近显示符号", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", lang('gui.help_tip'))

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText(, "在鼠标附近显示符号的应用窗口: ")
        g.AddDropDownList("yp AltSubmit Choose" showCursorPos + 1, [" 指定窗口", " 所有窗口"]).OnEvent("Change", e_change)
        e_change(item, *) {
            value := item.value - 1
            writeIni("showCursorPos", value)
            global showCursorPos := value
            restartJAB()
        }
        g.AddText("xs", "在鼠标附近显示时的水平偏移量: ")
        _ := g.AddEdit("yp")
        _.Value := readIni("showCursorPos_x", 0)
        _._config := "showCursorPos_x"
        _.OnEvent("Change", fn_offset_x)
        fn_offset_x(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := returnNumber(item.value)
            global showCursorPos_x := value

            db(item._config, value)
        }
        g.AddText("xs", "在鼠标附近显示时的垂直偏移量: ")
        _ := g.AddEdit("yp")
        _.Value := readIni("showCursorPos_y", -20)
        _._config := "showCursorPos_y"
        _.OnEvent("Change", fn_offset_y)
        fn_offset_y(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := returnNumber(item.value)
            global showCursorPos_y := value

            db(item._config, value)
        }

        _c := g.AddButton("xs w" w, "指定在鼠标附近显示符号的应用窗口")
        _c.OnEvent("Click", set_app_list)
        set_app_list(*) {
            g.Destroy()
            fn_common({
                title: "指定在鼠标附近显示符号的应用窗口",
                tab: "在鼠标附近显示符号的应用窗口",
                config: "ShowNearCursor",
                link: '相关链接: <a href="https://inputtip.abgox.com/faq/show-symbol-near-cursor">在鼠标附近显示符号</a>'
            }, fn)
            fn() {
                global ShowNearCursor := StrSplit(readIniSection("ShowNearCursor"), "`n")
                restartJAB()
            }
        }
        tab.UseTab(2)
        g.AddEdit("ReadOnly VScroll r7 w" w, "1. 简要说明`n   - 在 v1 版本中，通过在鼠标的附近显示符号，没有发现兼容性问题`n   - 而 v2 版本中，部分窗口无法获取到输入光标位置，就可以使用它`n   - 它会让符号显示在鼠标附近，并跟随鼠标移动`n   - 详情参考下方的相关链接`n`n2. 配置项 —— 在鼠标附近显示符号的应用窗口`n   - 【指定窗口】: 还需要通过下方的按钮去指定窗口`n   - 【所有窗口】: 它就实现了 v1 版本中同样的效果`n`n3. 配置项 —— 在鼠标附近显示时的水平/垂直偏移量`n   - 它指的是符号在鼠标附近显示时的偏移量`n   - 注意，符号最终的偏移量为 o1 + o4`n       - o1 指的是符号配置页面中的偏移量`n       - o4 指的是这里的偏移量`n`n4. 按钮 —— 指定在鼠标附近显示符号的应用窗口`n   - 如果你使用了【指定窗口】，就需要使用它`n   - 通过它去指定需要在鼠标附近显示符号的应用窗口`n`n5. 建议`n   - 减小【其他设置】的【轮询响应间隔时间】，保持在 50 毫秒以内`n   - 因为显示在鼠标附近时，符号位置会随鼠标移动实时更新`n   - 如果此值过高，符号位置更新不及时，会出现符号显示卡顿的现象")
        g.AddLink(, '相关链接:   <a href="https://inputtip.abgox.com/faq/app-compatibility">应用窗口兼容情况</a>   <a href="https://inputtip.abgox.com/v1/">v1 版本</a>')
        return g
    }
}
