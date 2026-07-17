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

        renderText(g, "desc", "Section Center w" w)

        renderBoldText(g, "about.info")
        g.AddLink(, i18n("about.version") getLink("inputtip.abgox.com/download", currentVersion))
        g.AddLink(, i18n("about.developer") getLink("www.abgox.com", author))

        renderBoldText(g, "about.status")
        g.AddLink(, i18n("about.type") getLink("inputtip.abgox.com/docs/zip-vs-exe", versionType))
        privilege := A_IsAdmin ? i18n("about.privilege.admin") : i18n("about.privilege.user")
        g.AddLink(, i18n("about.privilege") getLink("inputtip.abgox.com/docs/privilege", privilege))
        if versionType == "zip"
            g.AddLink(, i18n("about.runtime") getLink("inputtip.abgox.com/docs/runtime", "AutoHotkey " A_AhkVersion))

        renderBoldText(g, "about.link")
        g.AddLink(, getLink("inputtip.abgox.com"))
        g.AddLink(, getLink("github.com/abgox/InputTip"))
        g.AddLink(, getLink("gitee.com/abgox/InputTip"))

        g.AddButton("xs w" w, i18n("donate")).OnEvent("Click", (*) => Run("https://www.abgox.com/donate"))

        return g
    }
}
