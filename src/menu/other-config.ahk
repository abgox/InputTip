; InputTip

fn_ohter_config(*) {
    createUniqueGui(ohterConfigGui).Show()
    ohterConfigGui(info) {
        g := createGuiOpt("InputTip - 其他设置")
        tab := g.AddTab3("-Wrap", ["其他设置", "其他设置2", "关于"])
        tab.UseTab(1)
        g.AddText("Section cRed", gui_help_tip)

        if (info.i) {
            g.AddText(, gui_width_line)
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := gui_width_line "-------"
        g.AddText("xs", line)

        g.AddButton("xs w" bw / 2, "更新检查").OnEvent("Click", fn_check_update)
        g.AddButton("yp w" bw / 2, "JAB/JetBrains IDE 支持 【" (enableJABSupport ? "启用" : "禁用") "中】").OnEvent("Click", e_enableJABSupport)
        e_enableJABSupport(item, *) {
            global enableJABSupport := !enableJABSupport
            writeIni("enableJABSupport", enableJABSupport)

            if (enableJABSupport) {
                item.Text := "JAB/JetBrains IDE 支持【启用中】"
                if (runJAB()) {
                    return
                }
                createUniqueGui(JABGui).Show()
                JABGui(info) {
                    g := createGuiOpt("InputTip - 启用 JAB/JetBrains IDE 支持")
                    g.AddText(, "已经成功启用了 JAB/JetBrains IDE 支持，你还需要进行以下操作步骤:           ")

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    g.AddEdit("xs -VScroll ReadOnly cGray w" w, "1. 启用 Java Access Bridge (如果不需要在输入光标处显示符号，忽略此步骤)`n2. 点击下方的或【托盘菜单】中的【光标获取模式】`n3. 设置 JetBrains IDE 或其他 JAB 应用进程的光标获取模式为【JAB】`n4. 如果未生效，请重启 InputTip`n5. 如果仍未生效，请重启正在运行的 JetBrains IDE 或其他 JAB 应用`n6. 如果仍未生效，请重启系统`n7. 有多块屏幕时，副屏幕上可能有坐标偏差，需要通过【特殊偏移量】调整")
                    g.AddText("cRed", "部分 JDK/JRE 中的 Java Access Bridge 无效，推荐使用 Microsoft OpenJDK 21").Focus()
                    g.AddLink(, '详细操作步骤，请查看:   <a href="https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains">官网</a>   <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Github</a>   <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Gitee</a>')
                    g.AddButton("xs w" w, "【光标获取模式】").OnEvent("Click", fn_cursor_mode)
                    g.AddButton("xs w" w, "【特殊偏移量】").OnEvent("Click", fn_app_offset)
                    y := g.AddButton("xs w" w, "我知道了")
                    y.OnEvent("Click", e_close)
                    e_close(*) {
                        g.Destroy()
                    }
                    return g
                }
            } else {
                item.Text := "JAB/JetBrains IDE 支持【禁用中】"
                SetTimer(killAppTimer, -1)
                killAppTimer() {
                    try {
                        killJAB(1, A_IsCompiled || A_IsAdmin)
                    }
                }
            }
        }
        g.AddButton("xs w" bw / 2, "打开软件目录").OnEvent("Click", (*) => (Run("explorer.exe /select," A_ScriptFullPath)))
        g.AddButton("yp w" bw / 2, "设置用户信息").OnEvent("Click", (*) => (fn_update_user(userName)))

        g.AddText("xs", line)

        g.AddText("xs", "自定义软件托盘图标")
        g.AddText("xs cGray", '注意: 图片文件需要放在 InputTipSymbol 目录下，它和图片符号共用一个父目录')
        iconList := StrSplit(iconPaths, ":")
        iconList.RemoveAt(1)
        g.AddText("xs cRed", "运行中: ").GetPos(, , &_w)
        _ := g.AddDropDownList("yp r9 w" bw - _w, iconList)
        _.Text := iconRunning
        _.OnEvent("Change", e_iconRunning)
        e_iconRunning(item, *) {
            value := item.Text
            global iconRunning := value
            writeIni("iconRunning", value)
            if (!A_IsPaused) {
                setTrayIcon(value)
            }
        }
        g.AddText("xs cRed", "暂停中: ")
        _ := g.AddDropDownList("yp r9 w" bw - _w, iconList)
        _.Text := iconPaused
        _.OnEvent("Change", e_iconPaused)
        e_iconPaused(item, *) {
            value := item.Text
            global iconPaused := value
            writeIni("iconPaused", value)
            if (A_IsPaused) {
                setTrayIcon(value)
            }
        }
        g.AddButton("xs w" bw / 2, "打开图片目录").OnEvent("Click", (*) => (Run("explorer.exe InputTipSymbol")))
        g.AddButton("yp w" bw / 2, "刷新下拉列表").OnEvent("Click", (*) => (
            getPathList(),
            fn_ohter_config()
        ))

        tab.UseTab(2)
        g.AddText("Section cRed", gui_help_tip)
        g.AddText("xs", line)

        g.AddText("Section", "1. 配置菜单字体大小:")
        _ := g.AddEdit("yp Number Limit2")
        _.Value := readIni("gui_font_size", "12")
        _.OnEvent("Change", e_change_gui_fs)
        e_change_gui_fs(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := item.value
            if (value = "" || value < 5 || value > 30) {
                return
            }
            global fontOpt := ["s" value, "Microsoft YaHei"]

            db("gui_font_size", value)
        }

        g.AddText("xs", "2. 轮询响应间隔时间:")
        _ := g.AddEdit("yp Number Limit2")
        _.Value := delay
        _.OnEvent("Change", e_delay)
        e_delay(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value),
                restartJAB()
            ))

            value := item.value
            if (value = "") {
                return
            }
            value += value <= 0
            if (value > 100) {
                value := 100
            }
            global delay := value

            db("delay", value)
        }

        g.AddText("Section xs", "3. 按键输入次数统计:")
        _ := g.AddDropDownList("yp AltSubmit", ["【否】关闭", "【是】开启"])
        _.Value := enableKeyCount + 1
        _.OnEvent("Change", fn_keyCount)
        fn_keyCount(item, *) {
            value := item.value - 1
            global enableKeyCount := value
            writeIni("enableKeyCount", value)
            updateTip()
        }

        g.AddText("Section xs", "4. 鼠标悬停在【托盘图标】上时的文字模板")
        _ := g.AddEdit("w" bw)
        _.Value := trayTipTemplate
        _.OnEvent("Change", e_trayTemplate)
        e_trayTemplate(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))

            value := item.value
            global trayTipTemplate := value
            updateTip(A_IsPaused)

            db("trayTipTemplate", value)
        }
        g.AddText("Section xs", "5. 按键输入次数统计的文字模板")
        _ := g.AddEdit("w" bw)
        _.Value := keyCountTemplate
        _.OnEvent("Change", e_countTemplate)
        e_countTemplate(item, *) {
            static db := debounce((config, value) => (
                writeIni(config, value)
            ))
            value := item.value
            global keyCountTemplate := value
            updateTip(A_IsPaused)

            db("keyCountTemplate", value)
        }
        g.AddEdit("xs ReadOnly cGray -VScroll w" bw, '模板变量: %\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)')
        tab.UseTab(3)
        g.AddEdit("Section r15 ReadOnly w" w, "1. 按钮 —— 更新检查`n   - 点击后，会打开版本更新相关的配置菜单`n`n2. 按钮 —— JAB/JetBrains IDE 支持`n   - 如果你正在使用 JetBrains IDE，请双击启用它，并根据窗口提示完成所有步骤`n   - 完成后，InputTip 才能在 JetBrains IDE 中正确获取到输入光标位置并显示符号`n`n3. 按钮 —— 打开软件目录`n   - 点击后，会自动打开软件所在的运行目录`n`n4. 按钮 —— 设置用户信息`n   - InputTip 需要用到你的用户名来确保【开机自启动】等功能正常运行`n   - 首次初始化时会自动获取用户名并保存到配置文件中，之后可通过此按钮修改`n   - 对于域用户，自动获取的用户名缺少域前缀，需要手动添加`n`n5. 配置 —— 自定义软件托盘图标`n   - 只需要将 png 图片添加到图片目录中，然后在下拉列表中选择它即可实现自定义`n`n6. 按钮 —— 打开图片目录`n   - 点击它后，会自动打开图片目录，便于你完成【自定义软件托盘图标】`n`n7. 按钮 —— 刷新下拉列表`n   - 当你将 png 图片添加到图片目录后，可能需要通过点击它刷新下拉列表`n`n8. 配置 —— 配置菜单字体大小`n   - 可以通过设置字体大小来优化配置菜单在不同屏幕上的显示效果`n   - 取值范围: 5-30，建议 12-20 之间`n`n9. 配置 —— 轮询响应间隔时间`n   - 每隔 x 毫秒，InputTip 就会更新一次符号的位置/状态、输入法状态、鼠标样式等`n   - 这里的 x 就是轮询响应间隔时间，单位：毫秒，默认为 20`n   - 建议 20 以内，因为轮询间隔越短，部分功能的稳定性越好`n`n10. 配置 —— 按键输入次数统计`n   - 开启后，InputTip 会记录你的按键输入次数`n   - 然后通过写入下方的文字模板中进行显示`n   - 注意: 只有当上一次按键和当前按键不同时，才会记为一次有效按键`n`n11. 配置 —— 鼠标悬停在【托盘图标】上时的文字模板`n   - 当鼠标悬停在【托盘图标】上时，会根据此处设置的文字模板进行显示`n   - 模板变量: %\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)`n`n12. 配置 —— 按键输入次数统计的文字模板`n   - 当开启了【按键输入次数统计】后，此处的文字模板会被添加到鼠标悬停的提示中`n   - 模板变量: %\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)")
        g.AddLink(, '相关链接: <a href="https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains">在 JetBrains 系列 IDE 中使用 InputTip</a>')

        g.OnEvent("Close", e_close)
        e_close(*) {
            g.Destroy()
            gc.tab := 0
            gc.timer := 0
            try {
                gc.w.subGui.Destroy()
                gc.w.subGui := ""
            }
        }
        return g
    }
}
