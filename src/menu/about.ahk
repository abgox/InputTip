; InputTip

fn_about(*) {
    if (gc.w.aboutGui) {
        gc.w.aboutGui.Destroy()
        gc.w.aboutGui := ""
    }
    createGui(aboutGui).Show()
    aboutGui(info) {
        g := createGuiOpt("InputTip - " (A_IsCompiled ? "exe 版本" : "zip 版本") " - " (A_IsAdmin ? "以管理员权限启动" : "以当前用户权限启动"))

        g.AddText("Center w" info.w, "InputTip - 一个输入法状态管理工具")
        g.SetFont("s" readIni("gui_font_size", "12") / 1.2)
        g.AddText("Center w" info.w, "实时提示(鼠标样式、符号显示) + 窗口自动切换状态 + 快捷键切换状态")
        g.SetFont(fontOpt*)

        tab := g.AddTab3("-Wrap", ["关于项目", "赞赏支持", "参考项目", "其他项目"])
        tab.UseTab(1)
        g.AddText("Section", '版本号: ')
        g.AddEdit("yp ReadOnly cRed", currentVersion)
        g.AddText("xs", '开发者: ')
        g.AddLink("yp", '<a href="https://me.abgox.com">abgox</a>')
        g.AddText("xs", 'QQ 号: ')
        g.AddEdit("yp ReadOnly", '1151676611')
        g.AddLink("xs", 'QQ 群: ')
        g.AddEdit("yp ReadOnly", '451860327')
        g.AddLink("xs", '<a href="http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=ZfHFP_gIMyY6kZvqRmJhrsMlvnLDjLf6&authKey=lXo50SvLgudu%2BettInNZdb2OXGjs%2BxsoqsKIB88Vcq%2FjMb9uEW5thwU5Nm85KNX4&noverify=0&group_code=451860327">点击加入【QQ 群】交流反馈</a>')
        g.AddLink("yp", '<a href="https://pd.qq.com/s/gyers18g6?businessType=5">点击加入【腾讯频道】交流反馈</a>')

        if (info.i) {
            g.AddText("xs", "-------------------------------------------------------------------------------")
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2

        g.AddText("xs", "-------------------------------------------------------------------------------------")
        g.AddLink("xs", '1. 官网: <a href="https://inputtip.abgox.com">https://inputtip.abgox.com</a>')
        g.AddLink("xs", '2. Github: <a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
        g.AddLink("xs", '3. Gitee: <a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
        tab.UseTab(2)
        g.AddLink("Section", '- <a href="https://support-me.abgox.com/">赞赏我</a>、<a href="https://ko-fi.com/W7W817R6Z3">ko-fi.com</a> 、微信支付宝赞赏支持')
        g.AddLink("xs", '- 建议附上你的留言并标明 InputTip，它们将显示在 <a href="https://inputtip.abgox.com/sponsor">赞赏名单</a> 中')
        g.AddText("xs", "- 非常感谢你赞赏支持我的工作，希望 InputTip 能真正带给你帮助！")
        g.AddPicture("h-1 w" w / 5 * 3, "InputTipSymbol/default/offer.png")
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
        g.AddLink("Section cRed w" bw, '关于我的其他项目，可以通过访问 <a href="https://me.abgox.com/">我的主页</a>、<a href="https://github.com/abgox">Github</a>、<a href="https://gitee.com/abgox">Gitee</a> 等方式了解')
        g.SetFont("s" readIni("gui_font_size", "12") / 1.1)
        g.AddLink("Section w" bw, '1. <a href="https://pscompletions.abgox.com/">PSCompletions</a> (<a href="https://github.com/abgox/PSCompletions">Github</a> | <a href="https://gitee.com/abgox/PSCompletions">Gitee</a>) : 一个 PowerShell 补全模块，它能让你在 PowerShell 中更简单、更方便地使用命令补全。')
        g.AddLink("Section w" bw, '2. filename-lint (<a href="https://github.com/abgox/filename-lint">Github</a> | <a href="https://gitee.com/abgox/filename-lint">Gitee</a>) : 一个 vscode 扩展插件，用于统一文件及文件夹的命名规范。')
        g.AddLink("Section w" bw, '3. abyss (<a href="https://github.com/abgox/abyss">Github</a> | <a href="https://gitee.com/abgox/abyss">Gitee</a>) : 一个 scoop bucket 软件仓库，它具备更完善的 persist，优化的 Link 方案、进程终止功能和本地化输出(中文/英文)。')
        g.AddLink("Section w" bw, '4. scoop-install (<a href="https://github.com/abgox/scoop-install">Github</a> | <a href="https://gitee.com/abgox/scoop-install">Gitee</a>) : 一个 PowerShell 脚本，它允许你添加 Scoop 配置，在 Scoop 安装应用时使用替换后的 url 而不是原始的 url。')
        g.AddLink("Section w" bw, '5. ...')

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
