/**
 * 显示信息
 * @param {Array} msgList 字符串数组，每一项都会生成一个 Text 控件，控件之间有较大间距，如果不希望有间距，应该使用换行符拼接成一个字符串
 * @example
 * showMsg(["Hello`nWorld", "test"])
 */
showMsg(msgList) {
    g := Gui("AlwaysOnTop OwnDialogs")
    g.SetFont("s12", "微软雅黑")
    g.MarginX := 0
    g.AddLink("yp", "")
    for item in msgList {
        g.AddLink("xs", item)
    }
    g.Show("Hide")
    g.GetPos(, , &Gui_width)
    g.Destroy()

    g := Gui("AlwaysOnTop OwnDialogs")
    g.SetFont("s12", "微软雅黑")
    for item in msgList {
        g.AddLink("w" Gui_width, item)
    }
    y := g.AddButton("w" Gui_width, "确定")
    y.OnEvent("Click", fn_close)
    y.Focus()
    fn_close(*) {
        g.Destroy()
    }
    g.Show()
}
