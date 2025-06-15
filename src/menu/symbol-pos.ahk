; InputTip

fn_symbol_pos(*) {
    createUniqueGui(symbolPos).Show()
    symbolPos(info) {
        g := createGuiOpt("InputTip - 设置符号应该显示在鼠标附近的应用")
        g.AddLink("cRed", '在 v1 版本中，通过在鼠标附近显示符号，没有发现兼容性问题`n而 v2 版本中，部分窗口始终无法获取到光标位置，可以使用它`n详情参考:   <a href="https://inputtip.abgox.com/FAQ/support-app-list">应用窗口兼容情况</a>')
        g.AddLink("cGray", '- 选择【在任意应用窗口中】，这样就实现了 <a href="https://inputtip.abgox.com/v1/">v1 版本</a> 中同样的效果`n- 选择【仅指定应用窗口】，则还需要点击下方的按钮去添加应用进程`n- 建议减小【更改配置】中的【每多少毫秒更新符号的显示位置和状态】')
        g.AddText(, "哪些应用窗口中的符号需要显示在鼠标附近: ")

        if (info.i) {
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddDropDownList("yp AltSubmit Choose" showCursorPos + 1, [" 仅指定应用窗口", " 在任意应用窗口中"]).OnEvent("Change", e_change)
        e_change(item, *) {
            value := item.value - 1
            writeIni("showCursorPos", value)
            global showCursorPos := value
            restartJAB()
        }
        g.AddText("xs", "符号显示在鼠标附近时的水平偏移量: ")
        _ := g.AddEdit("yp")
        _.Value := readIni("showCursorPos_x", 0)
        _._config := "showCursorPos_x"
        _.OnEvent("Change", fn_offset)
        g.AddText("xs", "符号显示在鼠标附近时的垂直偏移量: ")
        _ := g.AddEdit("yp")
        _.Value := readIni("showCursorPos_y", -20)
        _._config := "showCursorPos_y"
        _.OnEvent("Change", fn_offset)
        fn_offset(item, *) {
            writeIni(item._config, returnNumber(item.value))
            global showCursorPos_x := readIni("showCursorPos_x", 0)
            global showCursorPos_y := readIni("showCursorPos_y", -20)
        }

        _c := g.AddButton("xs w" bw, "设置符号显示在鼠标附近的应用")
        _c.Focus()
        _c.OnEvent("Click", set_app_list)
        set_app_list(*) {
            g.Destroy()
            fn_common({
                title: "设置符号显示在鼠标附近的应用",
                tab: "设置符号显示在鼠标附近",
                config: "ShowNearCursor",
                link: '相关链接: <a href="https://inputtip.abgox.com/FAQ/symbol-show-pos">关于符号显示位置</a>'
            }, fn)
            fn() {
                global ShowNearCursor := StrSplit(readIniSection("ShowNearCursor"), "`n")
                restartJAB()
            }
        }
        return g
    }
}
