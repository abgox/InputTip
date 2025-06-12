; InputTip

fn_symbol_pos(*) {
    createUniqueGui(symbolPos).Show()
    symbolPos(info) {
        g := createGuiOpt("InputTip - 设置符号的显示位置")
        g.AddLink("cRed", '在 InputTip 的 v1 版本中，通过在鼠标附近显示符号，没有发现兼容性问题`n而 v2 中，部分窗口始终无法获取到光标位置，因此决定在 v2 中添加此特性`n详情请查看:   <a href="https://inputtip.abgox.com/FAQ/support-app-list">应用窗口兼容情况</a>')
        g.AddLink("cGray", '- 选择【在任意应用窗口中】，这样就实现了 v1 版本中同样的效果`n- 选择【仅指定应用窗口】，则还需要点击下方的按钮去添加应用进程`n- 建议减小【更改配置】中的【每多少毫秒更新符号的显示位置和状态】')
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
                gui: "setShowPosGui",
                config: "showCursorPosList",
                tab: ["设置符号显示在鼠标附近的应用", "关于"],
                tip: "你首先应该点击上方的【关于】查看具体的操作说明                                                  ",
                list: "符号显示在鼠标附近的应用列表",
                color: "cRed",
                about: '1. 如何使用这个配置菜单？`n`n   - 上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 为了便于操作，白名单中的应用进程也会添加到列表中`n   - 双击列表中任意应用进程，就可以将其添加到【符号显示在鼠标附近的应用列表】中`n   - 如果需要更多的进程，请点击右下角的【显示更多进程】以显示后台和隐藏进程`n   - 也可以点击右下角的【手动添加】直接添加进程名称`n`n   - 下方是【符号显示在鼠标附近的应用列表】`n   - 双击列表中任意应用进程，就可以将它移除`n`n2. 为什么要添加这个列表？`n   - 因为在少数应用中始终无法获取到输入光标位置，从而无法实现在输入光标附近显示符号`n   - 而 v1 版本中，在鼠标附近显示符号的方案，在这种情况下也算是一种折中的解决方案`n`n3. 如何快速添加应用进程？`n`n   - 每次双击应用进程后，会弹出操作窗口，需要选择添加/移除或取消`n   - 如果你确定当前操作不需要取消，可以在操作窗口弹出后，按下空格键快速确认',
                link: '相关链接: <a href="https://inputtip.abgox.com/FAQ/symbol-show-pos">关于符号显示位置</a>',
                addConfirm: "是否要将",
                addConfirm2: "添加到【符号显示在鼠标附近的应用列表】中？",
                addConfirm3: "添加后，在此应用窗口中时，符号会显示在鼠标附近",
                rmConfirm: "是否要将",
                rmConfirm2: "从【符号显示在鼠标附近的应用列表】中移除？",
                rmConfirm3: "移除后，在此应用窗口中时，符号会显示在输入光标附近",
            },
                fn
            )
            fn(value) {
                global showCursorPosList := ":" value ":"
                gc.setShowPosGui_LV_rm_title.Text := "符号显示在鼠标附近的应用列表 ( " gc.setShowPosGui_LV_rm.GetCount() " 个 )"
                restartJAB()
            }
        }
        return g
    }
}
