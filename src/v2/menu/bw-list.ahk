fn_bw_list(*) {
    createGui(fn).Show()
    fn(x, y, w, h) {
        if (gc.w.bwListGui) {
            gc.w.bwListGui.Destroy()
            gc.w.bwListGui := ""
        }
        g := Gui("AlwaysOnTop", "InputTip - 设置符号显示的黑/白名单")
        g.SetFont(fz, "微软雅黑")
        bw := w - g.MarginX * 2

        g.AddText("cRed", "白名单机制 : 只有在「白」名单中的应用进程窗口会显示符号`n黑名单机制 : 只有不在「黑」名单中的应用进程窗口会显示符号")
        g.AddLink("cGray", '如果你正在使用 <a href="https://inputtip.pages.dev/FAQ/about-white-list">白名单机制</a>，InputTip 提供了同步添加机制`n当使用以下配置菜单时，添加的应用进程会同步添加到「白」名单中`n「设置光标获取模式」「设置特殊偏移量」「指定窗口自动切换状态」')
        g.AddText(, "选择符号显示的名单机制: ")
        gc._bw_list := g.AddDropDownList("yp AltSubmit vuseWhiteList Choose" useWhiteList + 1, ["使用「黑」名单", "使用「白」名单"])
        gc._bw_list.OnEvent("Change", fn_change_list)
        fn_change_list(item, *) {
            if (useWhiteList = item.Value) {
                createGui(fn).Show()
                fn(x, y, w, h) {
                    if (gc.w.subGui) {
                        gc.w.subGui.Destroy()
                        gc.w.subGui := ""
                    }
                    gc._bw_list.Value := useWhiteList + 1
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText("cRed", "确定要使用「黑」名单吗？")
                    g.AddText("cRed", "这是不建议的，更建议继续使用「白」名单`n因为「黑」名单机制下，你需要承担未知的可能存在的窗口兼容性代价")
                    g.AddButton("w" bw, "【是】我确定要使用「黑」名单").OnEvent("Click", yes)
                    g.AddButton("w" bw, "【否】不，我只是不小心点到了").OnEvent("Click", no)
                    g.OnEvent("Close", no)
                    yes(*) {
                        g.Destroy()
                        gc._bw_list.Value := 1
                        writeIni("useWhiteList", 0)
                        global useWhiteList := 0
                    }
                    no(*) {
                        g.Destroy()
                    }
                    gc.w.subGui := g
                    return g
                }
            } else {
                value := item.Value - 1
                writeIni("useWhiteList", value)
                global useWhiteList := value
                restartJetBrains()
            }
        }
        g.AddEdit("xs Disabled", "如果使用「黑」名单，你需要承担未知的可能存在的窗口兼容性代价")
        _c := g.AddButton("xs w" bw, "设置「白」名单")
        _c.OnEvent("Click", set_white_list)
        _c.Focus()
        set_white_list(*) {
            fn_close()
            fn_white_list()
        }
        g.AddButton("xs w" bw, "设置「黑」名单").OnEvent("Click", set_black_list)
        set_black_list(*) {
            fn_close()
            fn_common({
                gui: "blackListGui",
                config: "app_hide_state",
                tab: ["设置黑名单", "关于"],
                tip: "你首先应该点击上方的「关于」查看具体的操作说明                                    ",
                list: "符号显示黑名单",
                color: "cRed",
                about: '1. 如何使用这个管理面板？`n   - 最上方的列表页显示的是当前系统正在运行的应用进程(仅前台窗口)`n   - 为了便于操作，白名单中的应用进程也会添加到列表中`n   - 双击列表中任意应用进程，就可以将其添加到「符号显示黑名单」中`n   - 如果需要更多的进程，请点击右下角的「显示更多进程」以显示后台和隐藏进程`n   - 也可以点击右下角的「通过输入进程名称手动添加」直接添加进程名称`n   - 下方是「符号显示黑名单」应用进程列表，如果使用黑名单机制，它将生效`n   - 双击列表中任意应用进程，就可以将它移除`n`n   - 黑名单机制: 只有不在黑名单中的应用进程窗口才会显示符号`n   - 使用黑名单，可能会有一些特殊窗口的兼容性问题`n   - 建议使用白名单机制，最好少用黑名单机制`n`n2. 如何快速添加应用进程？`n   - 每次双击应用进程后，会弹出操作窗口，需要选择添加/移除或取消`n   - 如果你确定当前操作不需要取消，可以在操作窗口弹出后，按下空格键快速确认',
                link: '相关链接: <a href="https://inputtip.pages.dev/FAQ/about-white-list">白名单机制</a>',
                addConfirm: "是否要将",
                addConfirm2: "添加到「符号显示黑名单」中？",
                addConfirm3: "添加后，黑名单机制下，在此应用窗口中时，不会显示符号",
                addConfirm4: "",
                rmConfirm: "是否要将",
                rmConfirm2: "从「符号显示黑名单」中移除？",
                rmConfirm3: "移除后，黑名单机制下，在此应用窗口中时，会显示符号",
            },
            fn
            )
            fn(value) {
                global app_hide_state := ":" value ":"
                gc.blackListGui_LV_rm_title.Text := "符号显示黑名单 ( " gc.blackListGui_LV_rm.GetCount() " 个 )"
                restartJetBrains()
            }
        }
        g.OnEvent("Close", fn_close)
        fn_close(*) {
            g.Destroy()
        }
        gc.w.bwListGui := g
        return g
    }
}
