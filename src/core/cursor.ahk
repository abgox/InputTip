; InputTip

for k, v in var.cursorInfo {
    o := ""
    try o := replaceEnvVariables(RegRead("HKEY_CURRENT_USER\Control Panel\Cursors", k))
    if (!o) {
        o := "C:\Windows\Cursors\" v[2]
    }
    if (o) {
        var.cursorInfo[k] := { id: v[1], origin: o }
    }
}

updateCursor()

updateCursor() {
    defaultCursor := Map(
        "default-red", 1,
        "default-blue", 1,
        "default-green", 1,
        "default-yellow", 1,
        "default-purple", 1,
    )

    for state in var.stateList {
        path := "default-" var.stateVal.%state%.colorText
        dir := readIni("cursorPath" state, path)
        var.%"cursorPath" state% := dir
        if (dir) {
            if defaultCursor.Has(dir) {
                loopDir := defaultCursorDir "\" dir
            } else {
                if DirExist(cursorDir "\" dir) {
                    loopDir := cursorDir "\" dir
                } else {
                    var.%"cursorPath" state% := path
                    writeIni("cursorPath" state, path)
                    loopDir := defaultCursorDir "\" path
                }
            }
            Loop Files loopDir "\*.*" {
                n := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4)
                if var.cursorInfo.Has(n)
                    var.cursorInfo[n].%state% := A_LoopFileFullPath
            }
        } else {
            for k, v in var.cursorInfo {
                v.%state% := v.origin
            }
        }
    }
}

loadCursor(state, change := 0) {
    global lastCursor
    if (var.cursorActive) {
        if (state != lastCursor || change) {
            for k, v in var.cursorInfo {
                try {
                    if (v.%state%) {
                        DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%state%, "Ptr"), "Int", v.id)
                    }
                }
            }
            lastCursor := state
        }
    }
}

revertCursor() {
    for k, v in var.cursorInfo {
        try {
            if (v.origin) {
                DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.id)
            }
        }
    }
}

getCursorPath() {
    listMap := Map()
    loopDir(defaultCursorDir, defaultCursorDir)
    loopDir(cursorDir, cursorDir)
    loopDir(path, rootPath) {
        Loop Files path "\*", "DR"
            if A_LoopFileAttrib ~= "D" {
                p := StrReplace(A_LoopFilePath, rootPath "\", "")
                if hasChild(A_LoopFilePath, "D") {
                    loopDir(A_LoopFilePath, rootPath)
                } else {
                    if hasChild(A_LoopFilePath) && !listMap.Has(p)
                        listMap.Set(p, 1)
                }
            }
    }
    list := []
    for state in var.stateList {
        path := "default-" var.stateVal.%state%.colorText
        if listMap.Has(path) {
            list.Push(path)
            listMap.Delete(path)
        }
    }
    for path in listMap
        list.Push(path)

    return list
}


e_cursor(*) {
    showGui(createUniqueGui(cursorStyleGui))
    cursorStyleGui(info) {
        g := createGuiOpt(i18n("cursor"))

        if (info.i) {
            g.AddText(, line80)
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        tab := renderTab(g, [i18n("basicConfig"), i18n("stateStyle"), i18n("stateStyle") 2])
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("tip/cursor"))

        renderRadioGroup(g, "cursorActive", [["yes", 1], ["no", 0]])

        opt := "xs w" bw
        g.AddButton(opt, i18n("cursor.open")).OnEvent("Click", (*) => Run("explorer.exe data\cursor"))
        g.AddButton(opt, i18n("cursor.download")).OnEvent("Click", (*) => Run("https://inputtip.abgox.com/download/extra"))

        list := getCursorPath()
        list.InsertAt(1, "")

        for i, state in var.stateList {
            if (Mod(i - 1, 3) == 0) {
                page := ((i - 1) // 3) + 2
                tab.UseTab(page)
                opt := "Section"
            } else {
                opt := "xs"
            }
            renderDropDownListGroup(g, "state." state, list, "cursorPath" state, opt)
        }
        return g
    }
}
