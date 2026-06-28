; InputTip

e_about(*) {
    showGui(createUniqueGui(aboutGui))
    aboutGui(info) {
        g := createGuiOpt(i18n("about"))

        if info.i {
            g.AddText(, line60)
            return g
        }
        w := info.w
        opt := "xs+20 yp+" uicText.yp

        renderText(g, "desc", "Section Center", "w" w)

        renderGroupBox(g, "about.info", "xs", "h" uicText.h * 1.5 " w" w)
        g.AddLink(opt, i18n("about.version") getLink("inputtip.abgox.com/download", currentVersion))
        g.AddLink(opt, i18n("about.developer") getLink("www.abgox.com", author))

        renderGroupBox(g, "about.status", "xs", "h" (versionType == "zip" ? uicText.h * 2 : uicText.h * 1.5) " w" w)
        g.AddLink(opt, i18n("about.type") getLink("inputtip.abgox.com/docs/zip-vs-exe", versionType))
        privilege := A_IsAdmin ? i18n("about.privilege.admin") : i18n("about.privilege.user")
        g.AddLink(opt, i18n("about.privilege") getLink("inputtip.abgox.com/docs/privilege", privilege))
        if versionType == "zip"
            g.AddLink(opt, i18n("about.runtime") getLink("inputtip.abgox.com/docs/runtime", "AutoHotkey " A_AhkVersion))

        renderGroupBox(g, "about.link", "xs", "h" uicText.h * 2 " w" w)
        g.AddLink(opt, getLink("inputtip.abgox.com"))
        g.AddLink(opt, getLink("github.com/abgox/InputTip"))
        g.AddLink(opt, getLink("gitee.com/abgox/InputTip"))

        g.AddButton("xs w" w, i18n("donate")).OnEvent("Click", (*) => Run("https://www.abgox.com/donate"))

        return g
    }
}
