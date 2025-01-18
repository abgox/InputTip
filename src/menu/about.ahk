fn_about(*) {
    if (gc.w.aboutGui) {
        gc.w.aboutGui.Destroy()
        gc.w.aboutGui := ""
    }
    createGui(aboutGui).Show()
    aboutGui(info) {
        g := createGuiOpt("InputTip - v" currentVersion)

        g.AddText("Center w" info.w, "InputTip - 一个输入法状态实时提示工具")
        tab := g.AddTab3("-Wrap", ["关于项目", "赞赏支持", "参考项目", "其他项目"])
        tab.UseTab(1)
        g.AddText("Section", '当前版本: ')
        g.AddEdit("yp ReadOnly cRed", currentVersion)
        g.AddText("xs", '开发人员: ')
        g.AddEdit("yp ReadOnly", 'abgox')
        g.AddText("xs", 'QQ 账号: ')
        g.AddEdit("yp ReadOnly", '1151676611')
        g.AddLink("xs", 'QQ 反馈交流群( <a href="http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=ZfHFP_gIMyY6kZvqRmJhrsMlvnLDjLf6&authKey=lXo50SvLgudu%2BettInNZdb2OXGjs%2BxsoqsKIB88Vcq%2FjMb9uEW5thwU5Nm85KNX4&noverify=0&group_code=451860327">点击添加</a> ): ')
        g.AddEdit("yp ReadOnly", '451860327')

        if (info.i) {
            g.AddText("xs", "-------------------------------------------------------------------------------")
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", "-------------------------------------------------------------------------------------")
        g.AddLink("xs", '1. 官网: <a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
        g.AddLink("xs", '2. Github: <a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        g.AddLink("xs", '3. Gitee: <a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
        tab.UseTab(2)
        g.AddLink("Section", '- 通过 <a href="https://ko-fi.com/W7W817R6Z3">ko-fi.com</a> 赞赏支持')
        g.AddText("xs", '- 通过微信和支付宝赞赏支持')
        g.AddPicture("h-1 w" w / 4 * 3, "InputTipSymbol\default\offer.png")
        tab.UseTab(3)
        g.AddLink("Section", '1. <a href="https://github.com/aardio/ImTip">ImTip - aardio</a>')
        g.AddLink("xs", '2. <a href="https://github.com/flyinclouds/KBLAutoSwitch">KBLAutoSwitch - flyinclouds</a>')
        g.AddLink("xs", '3. <a href="https://github.com/Tebayaki/AutoHotkeyScripts">AutoHotkeyScripts - Tebayaki</a>')
        g.AddLink("xs", '4. <a href="https://github.com/Autumn-one/RedDot">RedDot - Autumn-one</a>')
        g.AddLink("xs", '5. <a href="https://github.com/yakunins/language-indicator">language-indicator - yakunins</a>')
        g.AddText("xs", '- InputTip v1 是在鼠标附近显示带文字的方块符号')
        g.AddText("xs", '- InputTip v2 默认通过不同颜色的鼠标样式来区分')
        g.AddText("xs", '- 后来参照了 RedDot 和 language-indicator 的设计')
        g.AddText("xs", '- 因为实现很简单，就是去掉 v1 中方块符号的文字，加上不同的背景颜色')

        tab.UseTab(4)
        g.AddLink("Section w" bw, '1. <a href="https://pscompletions.pages.dev/">PSCompletions</a> : 一个 PowerShell 补全模块，它能让你在 PowerShell 中更简单、更方便地使用命令补全。')
        g.AddLink("Section w" bw, '2. ...')

        tab.UseTab(0)
        btn := g.AddButton("Section w" w, "关闭")
        btn.Focus()
        btn.OnEvent("Click", e_close)
        e_close(*) {
            g.Destroy()
        }
        gc.w.aboutGui := g
        return g
    }
}
