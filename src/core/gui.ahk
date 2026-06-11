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
 * @param {0|1|2|3} cornerPreference 边角样式 (1=直角，2=圆角，3=小圆角)
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
            ; 边角样式（DWMWA_WINDOW_CORNER_PREFERENCE = 33）
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
    g := Gui(guiOption " -DPIScale", prefix title)
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

/**
 * 创建一个提示
 * @param {Array} Tips 显示的提示信息
 * @param {String} tipType Gui 标题
 * @param {"tip"|"warning"|"error"} type 提示的类型
 * @param {"ok"|"cancel"|String} btnTextKey 按钮的文本
 * @param {"cRed"|String} opt 文本控件的选项
 * @returns {Gui} 返回 Gui 对象
 */
createMsgGui(Tips, title, typeKey := "", btnTextKey := "ok", opt := "") {
    tipGui(info) {
        t := i18n(typeKey)
        if title
            t .= " - " title
        g := createGuiOpt(t)

        for v in Tips
            g.AddLink(opt, v)

        if info.i
            return g

        btn := g.AddButton("xs w" info.w, i18n(btnTextKey))
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
    return createMsgGui(Tips, title, "error", "ok", "cRed")
}


/**
 * 显示 Gui
 * @param {gui} g Gui 对象
 * @param {String} options 显示时的选项
 * @param {"fade"} animation 显示动画效果
 * @param {1|0} hideOnTrayMenu 显示托盘菜单时是否隐藏
 * @param {Number} transparency 透明度值
 */
showGui(g, options := "", animation := var.menuAnimation, hideOnTrayMenu := 0, transparency := "") {
    if hideOnTrayMenu
        hideOnTrayGui.Push(g)

    targetAlpha := transparency != "" ? transparency : 255

    try {
        hwnd := g.Hwnd

        switch animation {
            case 1, "fade":
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

            case "slideOverlay":
                try {
                    if HasProp(g, "AnimationTimer") && g.AnimationTimer {
                        SetTimer(g.AnimationTimer, 0)
                        g.AnimationTimer := ""
                    }
                }

                applyTransparency(hwnd, 0)
                try g.Show(options)

                targetCtrl := ""
                for ctrlHwnd, ctrlObj in g {
                    targetCtrl := ctrlObj
                    break
                }

                if (!targetCtrl) {
                    (transparency == "") ? WinSetTransparent("Off", hwnd) : applyTransparency(hwnd, transparency)
                    return
                }

                hMonitor := DllCall("MonitorFromWindow", "Ptr", hwnd, "Int", 2, "Ptr")
                DllCall("Shcore\GetDpiForMonitor", "Ptr", hMonitor, "Int", 0, "UInt*", &dpiX := 0, "UInt*", &dpiY := 0)
                scale := dpiX > 0 ? dpiX / 96 : 1
                offset := Round(15 * scale)

                try {
                    if HasProp(targetCtrl, "origY") {
                        targetCtrl.Move(, targetCtrl.origY)
                    } else {
                        targetCtrl.GetPos(, &cy)
                        targetCtrl.origY := cy
                    }
                    targetCtrl.Move(, targetCtrl.origY + offset)
                    DllCall("user32\UpdateWindow", "Ptr", hwnd)
                } catch {
                    (transparency == "") ? WinSetTransparent("Off", hwnd) : applyTransparency(hwnd, transparency)
                    return
                }

                step := 0
                total := 12

                g.AnimationTimer := overlaySlide
                SetTimer(g.AnimationTimer, 10)

                overlaySlide() {
                    if !WinExist("ahk_id " hwnd) {
                        try SetTimer(g.AnimationTimer, 0)
                        return
                    }

                    try {
                        step++
                        t := step / total

                        easeOutValue := (1 - t) ** 3
                        currentOffset := offset * easeOutValue
                        currentAlpha := Integer(targetAlpha * (t ** 0.5))

                        if (currentOffset > 0.5 && step < total) {
                            try targetCtrl.Move(, targetCtrl.origY + currentOffset)
                            applyTransparency(hwnd, Min(currentAlpha, targetAlpha))
                        } else {
                            try SetTimer(g.AnimationTimer, 0)
                            g.AnimationTimer := ""

                            try targetCtrl.Move(, targetCtrl.origY)
                            (transparency == "") ? WinSetTransparent("Off", hwnd) : applyTransparency(hwnd, transparency)
                        }
                    } catch {
                        try SetTimer(g.AnimationTimer, 0)
                        try g.AnimationTimer := ""
                        try targetCtrl.Move(, targetCtrl.origY)
                        applyTransparency(hwnd, transparency)
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
        out := A_ScriptDir "\" to ".new"
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
