; InputTip

fn_about(*) {
    createUniqueGui(aboutGui).Show()
    aboutGui(info) {
        g := createGuiOpt("InputTip - " versionType " 版本 - " (A_IsAdmin ? "以管理员权限启动" : "以当前用户权限启动"))

        g.AddText("Center w" info.w, "InputTip - 一个输入法状态管理工具")
        g.SetFont("s" readIni("gui_font_size", "12") / 1.2)
        g.AddText("Center w" info.w, "实时提示(鼠标样式、符号显示) + 窗口自动切换状态 + 快捷键切换状态")
        g.SetFont(fontOpt*)

        tab := g.AddTab3("-Wrap", ["关于项目", "赞赏支持", "参考项目"])
        tab.UseTab(1)
        g.AddText("Section", '版本号: ')
        g.AddEdit("yp ReadOnly cRed", currentVersion)
        g.AddText("xs", '开发者: ')
        g.AddLink("yp", '<a href="https://abgox.com">abgox</a>')

        if (info.i) {
            g.AddText("xs", "-------------------------------------------------------------------------------")
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := "-------------------------------------------------------------------------------------"

        g.AddText("xs", line)
        ; g.AddLink("xs", 'QQ 群: ')
        ; g.AddEdit("yp ReadOnly", '451860327')
        ; g.AddLink("xs", '<a href="https://qm.qq.com/q/Ch6T7YILza">点击加入【QQ 群】交流反馈</a>')
        g.AddLink("xs", '<a href="https://github.com/abgox/InputTip/issues">点击前往 Github 提交 Issue</a>')
        g.AddLink("xs", '<a href="https://pd.qq.com/s/gyers18g6?businessType=5">点击加入【腾讯频道】交流反馈</a>')

        g.AddText("xs", line)
        g.AddLink("xs", '1. 官网: <a href="https://inputtip.abgox.com">inputtip.abgox.com</a>')
        g.AddLink("xs", '2. Github: <a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>')
        g.AddLink("xs", '3. Gitee: <a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>')
        tab.UseTab(2)
        g.AddLink("Section", '- <a href="https://inputtip.abgox.com">InputTip</a> 作为一个开源项目，是免费使用的')
        g.AddLink("xs", '- 但它的开发和维护工作，消耗了我的许多时间与精力')
        g.AddLink("xs", '- 如果你喜欢 <a href="https://inputtip.abgox.com">InputTip</a>，请为它的项目仓库点亮一个 Star')
        g.AddLink("xs", '- 或者前往 <a href="https://abgox.com/donate">abgox.com/donate</a> 进行赞赏以支持我的付出')

        g.AddLink("xs", '    - 建议赞赏时进行必要的留言: 赞赏的项目、目的、想法等内容')
        g.AddLink("xs", '    - 它们会显示在 <a href="https://abgox.com/donate-list">abgox.com/donate-list</a> 这个赞赏名单中')
        g.AddLink("xs", '    - 如果不想显示在其中，也可以留言说明，会进行匿名处理')
        g.AddLink("xs", '- <a href="https://abgox.com">abgox.com</a> 还有更多信息、其他项目等等，或许它们刚好也能帮助到你')
        g.AddLink("xs", '- 总之，非常感谢你的支持，能够通过软件的方式相遇，何尝不是一种缘分')
        tab.UseTab(3)
        g.AddLink("Section", '1. <a href="https://github.com/aardio/ImTip">ImTip - aardio</a>')
        g.AddLink("xs", '2. <a href="https://github.com/flyinclouds/KBLAutoSwitch">KBLAutoSwitch - flyinclouds</a>')
        g.AddLink("xs", '3. <a href="https://github.com/Tebayaki/AutoHotkeyScripts">AutoHotkeyScripts - Tebayaki</a>')
        g.AddLink("xs", '4. <a href="https://github.com/Autumn-one/RedDot">RedDot - Autumn-one</a>')
        g.AddLink("xs", '5. <a href="https://github.com/yakunins/language-indicator">language-indicator - yakunins</a>')
        g.AddText("xs", '- InputTip v1 是在鼠标附近显示带文字的方块符号')
        g.AddText("xs", '- InputTip v2 默认通过不同颜色的鼠标样式来区分')
        g.AddText("xs", '- 后来参照了 RedDot 和 language-indicator 的设计')
        g.AddText("xs", '- 因为实现简单直接: 去掉 v1 中方块符号的文字，加上不同的背景颜色')

        tab.UseTab(0)
        btn := g.AddButton("Section w" w, "关闭")
        btn.OnEvent("Click", e_close)
        e_close(*) {
            g.Destroy()
        }
        return g
    }
}
