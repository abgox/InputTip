; InputTip

fn_about(*) {
    createUniqueGui(aboutGui).Show()
    aboutGui(info) {
        g := createGuiOpt("InputTip - " versionType " - " (A_IsAdmin ? lang("tray.admin_mode") : ""))

        g.AddText("Center w" info.w, lang("about.app_desc"))
        g.SetFont("s" readIni("gui_font_size", "12") / 1.2)
        g.AddText("Center w" info.w, lang("about.app_subtitle"))
        g.SetFont(fontOpt*)

        tab := g.AddTab3("-Wrap", [lang("about.title"), lang("about.donate"), lang("about.reference")])
        tab.UseTab(1)
        g.AddText("Section", lang("about.version"))
        g.AddEdit("yp ReadOnly cRed", currentVersion)
        g.AddText("xs", lang("about.developer"))
        g.AddLink("yp", '<a href="https://abgox.com">abgox</a>')

        if (info.i) {
            g.AddText("xs", "-------------------------------------------------------------------------------")
            return g
        }
        w := info.w
        bw := w - g.MarginX * 2
        line := "-------------------------------------------------------------------------------------"

        g.AddText("xs", line)
        ; g.AddLink("xs", 'QQ Group: ')
        ; g.AddEdit("yp ReadOnly", '451860327')
        ; g.AddLink("xs", '<a href="https://qm.qq.com/q/Ch6T7YILza">Join QQ Group</a>')
        g.AddLink("xs", lang("about.submit_issue"))
        g.AddLink("xs", lang("about.join_channel"))

        g.AddText("xs", line)
        g.AddLink("xs", lang("about.website"))
        g.AddLink("xs", lang("about.github"))
        g.AddLink("xs", lang("about.gitee"))
        tab.UseTab(2)
        g.AddLink("Section", lang("about.donate_1"))
        g.AddLink("xs", lang("about.donate_2"))
        g.AddLink("xs", lang("about.donate_3"))
        g.AddLink("xs", lang("about.donate_4"))

        g.AddLink("xs", lang("about.donate_5"))
        g.AddLink("xs", lang("about.donate_6"))
        g.AddLink("xs", lang("about.donate_7"))
        g.AddLink("xs", lang("about.donate_8"))
        g.AddLink("xs", lang("about.donate_9"))
        tab.UseTab(3)
        g.AddLink("Section", '1. <a href="https://github.com/aardio/ImTip">ImTip - aardio</a>')
        g.AddLink("xs", '2. <a href="https://github.com/flyinclouds/KBLAutoSwitch">KBLAutoSwitch - flyinclouds</a>')
        g.AddLink("xs", '3. <a href="https://github.com/Tebayaki/AutoHotkeyScripts">AutoHotkeyScripts - Tebayaki</a>')
        g.AddLink("xs", '4. <a href="https://github.com/Autumn-one/RedDot">RedDot - Autumn-one</a>')
        g.AddLink("xs", '5. <a href="https://github.com/yakunins/language-indicator">language-indicator - yakunins</a>')
        g.AddText("xs", lang("about.ref_1"))
        g.AddText("xs", lang("about.ref_2"))
        g.AddText("xs", lang("about.ref_3"))
        g.AddText("xs", lang("about.ref_4"))

        tab.UseTab(0)
        btn := g.AddButton("Section w" w, lang("common.close"))
        btn.OnEvent("Click", e_close)
        e_close(*) {
            g.Destroy()
        }
        return g
    }
}

