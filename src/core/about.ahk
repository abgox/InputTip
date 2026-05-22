; InputTip

e_about(*) {
    showGui(createUniqueGui(aboutGui))
    aboutGui(info) {
        g := createGuiOpt(i18n("about"))

        if (info.i) {
            g.AddText(, line60)
            return g
        }
        w := info.w

        renderText(g, "desc", "Section Center", "w" w)

        opt := "xs+20 yp+40"

        renderGroupBox(g, "about.info", "xs", "h120 w" w)
        g.AddLink(opt, i18n("about.version") getLink("inputtip.abgox.com/download", currentVersion))
        g.AddLink(opt, i18n("about.developer") getLink("www.abgox.com", "abgox"))

        renderGroupBox(g, "about.status", "xs", "h120 w" w)
        g.AddLink(opt, i18n("about.type") getLink("inputtip.abgox.com/docs/zip-vs-exe", versionType))
        privilege := A_IsAdmin ? i18n("about.privilege.admin") : i18n("about.privilege.user")
        g.AddLink(opt, i18n("about.privilege") getLink("inputtip.abgox.com/docs/privilege", privilege))

        renderGroupBox(g, "about.link", "xs", "h160 w" w)
        g.AddLink(opt, getLink("inputtip.abgox.com"))
        g.AddLink(opt, getLink("github.com/abgox/InputTip"))
        g.AddLink(opt, getLink("gitee.com/abgox/InputTip"))

        g.AddButton("xs w" w, i18n("donate")).OnEvent("Click", (*) => Run("https://www.abgox.com/donate"))

        return g
    }
}
