; InputTip

; g.SetFont(fontOpt*)
fontOpt := ["s16", "Microsoft YaHei"]

/**
 * - 创建 Gui 对象。
 * - 能够获取窗口最终的坐标和宽高，方便配置控件(如按钮宽度)。
 * - 原理: 通过先执行一次隐藏显示来获取信息，相当于实际会运行两次
 * @param {Func} callback
 * - 回调函数接受形参 `info`
 *    - `info.x`,`info.y`,`info.w`,`info.h`: 最终计算得到的窗口坐标和宽高。
 *    - 当执行隐藏显示时，`info.i` 为 `1`，否则为 `0`
 * @returns {Gui} 返回 Gui 对象
 */
createGui(callback) {
    g := callback({ x: 0, y: 0, w: 0, h: 0, i: 1 })
    g.Show("Hide AutoSize")
    g.GetPos(&x, &y, &w, &h)
    g.Destroy()
    return callback({ x: x, y: y, w: w, h: h, i: 0 })
}

/**
 * 创建一个唯一的 Gui
 * @param {Func} callback
 * - 回调函数接受形参 `info`
 *    - `info.x`,`info.y`,`info.w`,`info.h`: 最终计算得到的窗口坐标和宽高。
 *    - 当执行隐藏显示时，`info.i` 为 `1`，否则为 `0`
 * @param {0|1|2|3} cornerPreference 圆角样式 (1=直角，2=圆角，3=小圆角)
 * @param {1|0} useImmersiveDarkMode 是否使用深色模式
 * @returns {Gui} 返回 Gui 对象
 */
createUniqueGui(callback, cornerPreference := 0, useImmersiveDarkMode := 1) {
    static w := Map()
    g := createGui(callback)
    try {
        if (useImmersiveDarkMode) {
            ; 深色模式标题栏（DWMWA_USE_IMMERSIVE_DARK_MODE = 20）
            ; 让窗口标题栏跟随深色模式，未来可能扩展到子控件
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "Int", 20, "Int*", useImmersiveDarkMode, "Int", 4)
        }
        if (cornerPreference) {
            ; 圆角样式（DWMWA_WINDOW_CORNER_PREFERENCE = 33）
            ;
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "Int", 33, "Int*", cornerPreference, "Int", 4)
        }
        ; 背景材质（DWMWA_SYSTEMBACKDROP_TYPE = 38，仅 Win11 22H2+）
        ; 2=Mica  3=Acrylic  4=Mica Alt
        ; DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "Int", 38, "Int*", 3, "Int", 4)
    }
    g.GetPos(, , &width, &height)
    ; 基本确保唯一性
    id := g.Title "_" width "_" height
    if (w.Has(id)) {
        try {
            w.Get(id).Destroy()
            w.Delete(id)
        }
    }
    w.Set(id, g)
    return g
}

/**
 * @param title Gui 标题
 * @param {Array} fontOption 字体配置(如: ["s12", "Microsoft YaHei"])
 * - 这里为了方便 InputTip 使用，默认值使用了外部的 fontOpt 变量
 * @param {String} guiOption Gui 初始化配置
 * @param {String} prefix 标题前缀
 * @param {1|0} clearFocus 是否清除焦点
 * @returns {Gui} 返回 Gui 对象
 */
createGuiOpt(title, fontOption := fontOpt, guiOption := "", prefix := "InputTip - ", clearFocus := 1) {
    g := Gui(guiOption, prefix title)
    g.SetFont(fontOption*)
    if (clearFocus) {
        g.OnEvent("Size", OnFirstShow)
        OnFirstShow(g, *) {
            g.OnEvent("Size", OnFirstShow, 0)
            SetTimer(() => DllCall("SetFocus", "Ptr", 0), -1)
        }
    }
    return g
}

createMsgGui(Tips, title, btnText, opt := "") {
    tipGui(info) {
        g := createGuiOpt(title)

        for v in Tips {
            g.AddLink(opt, v)
        }

        if (info.i) {
            return g
        }

        btn := g.AddButton("xs w" info.w, btnText)
        btn.Focus()
        btn.OnEvent("Click", (*) => g.Destroy())
        return g
    }
    return createUniqueGui(tipGui)
}

/**
 * 创建一个错误提示
 * @param {Array} tipList 显示的提示信息
 * @param {String} title Gui 标题
 * @returns {Gui} 返回 Gui 对象
 */
createErrorTipGui(Tips, title := "") {
    t := i18n("error")
    if (title) {
        t .= " - " title
    }
    return createMsgGui(Tips, t, i18n("ok"), "cRed")
}

/**
 * 显示 Gui
 * @param {gui} g Gui 对象
 * @param {String} options 显示时的选项
 * @param {"fade"|"slide"|"scale"} animation 显示动画效果
 * @param {1|0} hideOnTrayMenu 显示托盘菜单时是否隐藏
 * @param {Number} transparency 透明度值
 */
showGui(g, options := "", animation := var.menuAnimation, hideOnTrayMenu := 0, transparency := "") {
    if (hideOnTrayMenu) {
        hideOnTrayGui.Push(g)
    }
    getXY(options, screenW, screenH, origW, origH) {
        x := ""
        y := ""
        if RegExMatch(options, "i)(?<![a-z])x(\d+)", &m) {
            x := Integer(m[1] / dpiScale)
        }
        if RegExMatch(options, "i)(?<![a-z])y(\d+)", &m) {
            y := Integer(m[1] / dpiScale)
        }
        return {
            x: x != "" ? x : Integer((screenW - origW) / 2),
            y: y != "" ? y : Integer((screenH - origH) / 2)
        }
    }

    try {
        hwnd := g.Hwnd
        dpiScale := A_ScreenDPI / 96
        primary := {}
        for v in var.screenList {
            if (v.num == v.main) {
                primary := v
                break
            }
        }
        screenW := Integer((primary.right - primary.left) / dpiScale)
        screenH := Integer((primary.bottom - primary.top) / dpiScale)

        switch animation {
            case 1, "fade":
                targetAlpha := transparency != "" ? transparency : 255
                applyTransparency(hwnd, 0)
                try g.Show(options)
                step := 0
                total := 12
                SetTimer(fade, 8)
                fade() {
                    try {
                        step++
                        t := step / total
                        alpha := Integer(targetAlpha * (t ** 0.5))
                        applyTransparency(hwnd, Min(alpha, targetAlpha))
                        if (step >= total) {
                            SetTimer(fade, 0)
                            if (transparency == "") {
                                WinSetTransparent("Off", hwnd)
                            } else {
                                applyTransparency(hwnd, transparency)
                            }
                        }
                    } catch {
                        SetTimer(fade, 0)
                        applyTransparency(hwnd, transparency)
                    }
                }
            case 2, "slide":
                try g.Show("Hide " options)
                try g.GetPos(, , &origW, &origH)
                pos := getXY(options, screenW, screenH, origW, origH)
                origX := pos.x
                origY := pos.y
                offsetY := 15
                try g.Move(origX, origY + offsetY)
                applyTransparency(hwnd, transparency)
                try g.Show(options)
                step := 0
                total := 20
                SetTimer(slide, 8)
                slide() {
                    try {
                        step++
                        t := step / total
                        eased := 1 - (1 - t) ** 3
                        curY := Integer(origY + offsetY * (1 - eased))
                        try g.Move(origX, curY)
                        if (step >= total) {
                            SetTimer(slide, 0)
                            try g.Move(origX, origY)
                        }
                    } catch {
                        SetTimer(slide, 0)
                        try g.Move(origX, origY)
                    }
                }
            case 3, "scale":
                try g.Show("Hide " options)
                try g.GetPos(, , &origW, &origH)
                pos := getXY(options, screenW, screenH, origW, origH)
                origX := pos.x
                origY := pos.y
                try g.Move(origX, origY)
                applyTransparency(hwnd, transparency)
                try g.Show(options)
                step := 0
                total := 20
                SetTimer(scale, 8)
                scale() {
                    try {
                        step++
                        t := step / total
                        eased := 1 - (1 - t) ** 3
                        w := Integer(origW * (0.9 + 0.1 * eased))
                        h := Integer(origH * (0.9 + 0.1 * eased))
                        x := Integer(origX + (origW - w) / 2)
                        y := Integer(origY + (origH - h) / 2)
                        try g.Move(x, y, w, h)
                        if (step >= total) {
                            SetTimer(scale, 0)
                            try g.Move(origX, origY, origW, origH)
                        }
                    } catch {
                        SetTimer(scale, 0)
                        try g.Move(origX, origY, origW, origH)
                    }
                }
            default:
                applyTransparency(hwnd, transparency)
                try g.Show(options)
        }
    } catch {
        try applyTransparency(g.Hwnd, transparency)
        try g.Show(options)
    }
}

showHotKeyGui(keyConfigList, label := "") {
    showGui(createUniqueGui(hotKeyGui))
    hotKeyGui(info) {
        g := createGuiOpt(label)

        if (info.i) {
            g.AddText(, keyConfigList[1].tip)
            g.AddDropDownList("yp r9", [])
            g.AddCheckbox("yp", i18n("hotkey.win"))
            return g
        }
        w := info.w

        tab := renderTab(g, [i18n("hotkey.single"), i18n("hotkey.combine"), i18n("hotkey.manual")], "w" w)
        loseFocusOnTab(tab)
        tab.UseTab(1)
        g.AddLink("Section", getDocsLink("switch/hotkey"))

        keyList := []
        keyList.Push([i18n("none"), "Esc", "Shift", "LShift", "RShift", "Ctrl", "LCtrl", "RCtrl", "Alt", "LAlt", "RAlt"]*)
        keyList.Push(["MButton", "LButton", "RButton"]*)
        keyList.Push(["Space", "Tab", "Enter", "Backspace", "Delete", "Insert", "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right"]*)

        i := 0
        while (i <= 9) {
            keyList.Push("Numpad" i)
            i++
        }
        keyList.Push(["NumpadDot", "NumLock", "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter"]*)

        i := 1
        while (i <= 24) {
            keyList.Push("F" i)
            i++
        }

        for v in keyConfigList {
            g.SetFont("Bold")
            g.AddText("xs", v.tip)
            g.SetFont("Norm")
            _ := gc.%v.config% := g.AddDropDownList("yp r9", keyList)
            _._config := v.config
            _._with := v.config "_win"
            _.OnEvent("Change", e_changeHotkey)

            config := readIni(v.config, "")
            if (config ~= "^~\w+\sUp$") {
                try {
                    _.Text := Trim(StrReplace(StrReplace(config, "~", ""), "Up", ""))
                    if (!_.Value) {
                        _.Value := 1
                    }
                } catch {
                    _.Text := i18n("none")
                }
            } else {
                _.Text := i18n("none")
            }
        }
        e_changeHotkey(item, *) {
            ; 同步修改到【设置组合快捷键】和【手动输入快捷键】
            if (item.Text == i18n("none")) {
                key := ""
            } else {
                key := "~" item.Text " Up"
            }
            gc.%item._config "2"%.Value := ""
            gc.%item._config "3"%.Value := key
            gc.%item._with%.Value := 0
        }
        tab.UseTab(2)
        g.AddLink("Section", getDocsLink("switch/hotkey"))

        for v in keyConfigList {
            g.SetFont("Bold")
            g.AddText("xs", v.tip)
            g.SetFont("Norm")
            value := readIni(v.config, "")
            _ := gc.%v.config "2"% := g.AddHotkey("yp", StrReplace(value, "#", ""))
            _._config := v.config
            _._with := v.config "_win"
            _.OnEvent("Change", e_changeHotkey1)
            gc.%_._with% := g.AddCheckbox("yp", i18n("hotkey.win"))
            gc.%_._with%._config := v.config
            gc.%_._with%.OnEvent("Click", e_winKey)
            gc.%_._with%.Value := InStr(value, "#") ? 1 : 0
        }
        e_changeHotkey1(item, *) {
            ; 同步修改到【设置单键】和【手动输入快捷键】
            gc.%item._config%.Text := i18n("none")
            v := item.value
            if (gc.%item._with%.Value) {
                v := "#" v
            }
            gc.%item._config "3"%.Value := v
        }
        e_winKey(item, *) {
            ; 同步修改到【设置单键】和【手动输入快捷键】
            gc.%item._config%.Text := i18n("none")
            v := gc.%item._config "2"%.Value
            gc.%item._config "3"%.Value := item.value ? "#" v : v
        }
        tab.UseTab(3)
        g.AddLink("Section", getDocsLink("switch/hotkey"))

        for v in keyConfigList {
            g.SetFont("Bold")
            g.AddText("xs", v.tip)
            g.SetFont("Norm")
            _ := gc.%v.config "3"% := g.AddEdit("yp")
            _._config := v.config
            _._with := v.config "_win"
            _.Value := readIni(v.config, "")
            _.OnEvent("Change", e_changeHotkey2)
        }
        e_changeHotkey2(item, *) {
            gc.%item._with%.Value := InStr(item.value, "#") ? 1 : 0
            ; 当输入的快捷键符合单键时，同步修改
            if (item.value ~= "^~\w+\sUp$") {
                try {
                    gc.%item._config%.Text := Trim(StrReplace(StrReplace(item.value, "~", ""), "Up", ""))
                } catch {
                    gc.%item._config%.Text := i18n("none")
                }
                gc.%item._config "2"%.Value := ""
            } else {
                gc.%item._config%.Text := i18n("none")
                ; 当输入的快捷键符合组合快捷键时，同步修改
                try {
                    gc.%item._config "2"%.Value := StrReplace(item.value, "#", "")
                } catch {
                    gc.%item._config "2"%.Value := ""
                }
            }
        }
        tab.UseTab(0)
        g.AddButton("Section w" w, i18n("ok")).OnEvent("Click", e_yes)
        e_yes(*) {
            for v in keyConfigList {
                key := gc.%v.config "3"%.Value
                changeConfig(v.config, key)
            }
            g.Destroy()
            fn_restart()
        }
        return g
    }
}

showDownloadProcessGui(labelKey, downloadList, titleKey := labelKey) {
    tipGui(info) {
        g := createGuiOpt(i18n(titleKey), , "AlwaysOnTop")
        if (info.i) {
            g.AddText(, line60)
            return g
        }
        g.AddText(, i18n(labelKey))
        g.process := g.AddProgress("xm h9 w" info.w, 1)
        g.tip := g.AddText("xs cGray w" info.w)
        ; WinSetStyle(-0x80000, g.Hwnd)
        hMenu := DllCall("GetSystemMenu", "Ptr", g.Hwnd, "Int", 0)
        DllCall("DeleteMenu", "Ptr", hMenu, "UInt", 0xF060, "UInt", 0)
        return g
    }
    downloadingGui := createUniqueGui(tipGui)
    fileCount := downloadList.Length
    downloadingGui.tip.Text := 1 "/" fileCount " : "
    showGui(downloadingGui)
    Sleep(500)
    done := 1
    doneFileList := []
    for i, kv in downloadList {
        part := StrSplit(kv, "=")
        from := part[1]
        to := part[2]
        out := to ".new"
        success := 0
        for u in baseUrl {
            downloadingGui.process.Value := i / fileCount * 100
            downloadingGui.tip.Text := i "/" fileCount " : " to
            if (InStr(out, "/")) {
                dir := RegExReplace(out, "/[^/]*$", "")
            } else {
                dir := ""
            }
            try {
                if (dir) {
                    if (!DirExist(dir)) {
                        DirCreate(dir)
                    }
                }
                Download(pathToUrl(u "/" from), out)
                if (FileExist(out)) {
                    if (InStr(out, ".ahk") || InStr(out, ".bat")) {
                        try success := InStr(FileOpen(out, "r").ReadLine(), "InputTip")
                    } else {
                        success := 1
                    }
                    if (success) {
                        doneFileList.Push(out)
                        break
                    }
                }
            }
        }
        if (!success) {
            done := 0
            break
        }
    }
    downloadingGui.Destroy()
    if (done) {
        backupList := []
        replaceOk := 1
        for v in doneFileList {
            target := RegExReplace(v, "\.new$", "")
            backup := target ".bak"
            try {
                if FileExist(target) {
                    FileCopy(target, backup, 1)
                    backupList.Push([target, backup])
                }
                FileMove(v, target, 1)
            } catch {
                replaceOk := 0
                break
            }
        }
        if (replaceOk) {
            for item in backupList {
                backup := item[2]
                try FileDelete(backup)
            }
        } else {
            for item in backupList {
                target := item[1]
                backup := item[2]
                try FileMove(backup, target, 1)
            }
        }
    } else {
        for v in doneFileList
            try FileDelete(v)
    }
    return done
}
