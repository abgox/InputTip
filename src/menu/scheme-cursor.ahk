; InputTip

fn_scheme_cursor(*) {
    createUniqueGui(cursorStyleGui).Show()
    cursorStyleGui(info) {
        g := createGuiOpt("InputTip - 状态提示 - 鼠标方案")
        tab := g.AddTab3("-Wrap", ["鼠标方案", "关于"])
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

        g.AddText("xs", "加载鼠标样式:")
        _ := g.AddDropDownList("w" bw / 2 " yp AltSubmit Choose" changeCursor + 1, ["【否】保持原本的鼠标样式", "【是】随输入法状态而变化"])
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
                revertCursor(cursorInfo)
                createTipGui([{
                    opt: "",
                    text: "正在尝试恢复到启动 InputTip 之前的鼠标样式"
                }, {
                    opt: "cRed",
                    text: "可能无法完全恢复，这时就需要重启系统以完全移除动态加载的鼠标样式",
                }, {
                    opt: "cGray",
                    text: "如果你不想重启系统，也可以通过系统设置，重新应用之前的鼠标样式"
                }], "InputTip - 尝试恢复鼠标样式").Show()
            } else {
                writeIni("changeCursor", 1)
                global changeCursor := 1
                reloadCursor()
            }
            restartJAB()
        }

        g.AddText("xs", line)
        createGuiOpt("").AddText(, "中文状态").GetPos(, , &__w)
        dirList := StrSplit(cursorDir, ":")
        if (dirList.Length = 0) {
            dirList := getCursorDir()
        }
        for i, v in ["CN", "EN", "Caps"] {
            g.AddText("xs", stateMap.%v% ":")
            _ := g.AddDropDownList("yp r9 w" bw - __w - g.MarginX, dirList)
            _._config := v "_cursor"
            _.OnEvent("Change", e_cursor_dir)
            try {
                _.Text := %v "_cursor"%
            } catch {
                _.Text := ""
            }
        }
        e_cursor_dir(item, *) {
            writeIni(item._config, item.Text)
            updateCursor()
            reloadCursor()
        }

        _w := bw / 3 - g.MarginX / 3
        g.AddButton("xs w" _w, "打开鼠标样式目录").OnEvent("Click", (*) => (Run("explorer.exe InputTipCursor")))
        g.AddButton("yp w" _w, "刷新下拉列表").OnEvent("Click", (*) => (
            getPathList()
            fn_scheme_cursor()
        ))
        g.AddButton("yp w" _w, "下载其他鼠标样式").OnEvent("Click", (*) => (Run("https://inputtip.abgox.com/download/extra")))

        tab.UseTab(2)
        g.AddEdit("ReadOnly r11 w" bw, "1. 配置 —— 加载鼠标样式`n   - 根据不同的输入法状态加载下方选择的对应的鼠标样式`n`n2. 配置 —— 中文状态/英文状态/大写锁定`n   - 通过下拉列表为不同状态指定鼠标样式`n   - InputTip 会根据当前输入法状态切换鼠标样式`n`n3. 按钮 —— 打开鼠标样式目录`n   - 点击它，会自动打开存放鼠标样式的目录`n   - 在这个目录下添加鼠标样式文件夹后，会显示在下拉列表中`n`n4. 按钮 —— 刷新下拉列表`n   - 当修改了鼠标样式目录，可能需要点击它去刷新下拉列表`n`n5. 按钮 —— 下载其他鼠标样式`n   - 点击它，前往官网查看已经适配的其他鼠标样式`n   - 下载后，解压到鼠标样式目录下即可使用")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/faq/custom-cursor-style">自定义鼠标样式</a>')
        return g
    }
}
