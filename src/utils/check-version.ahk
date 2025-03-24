; InputTip

/**
 * 比对版本号
 * @param new 新版本号
 * @param old 旧版本号
 * @returns {Number}
 * - new > old : 1
 * - new < old : -1
 * - new = old : 0
 */
compareVersion(new, old) {
    newParts := StrSplit(new, ".")
    oldParts := StrSplit(old, ".")
    for i, part1 in newParts {
        try {
            part2 := oldParts[i]
        } catch {
            part2 := 0
        }
        if (part1 > part2) {
            return 1  ; new > old
        } else if (part1 < part2) {
            return -1  ; new < old
        }
    }
    return 0  ; new = old
}

/**
 * 检查版本更新(异步)
 * @param currentVersion 当前版本号
 * @param callback 版本检查完成后的回调函数
 * @param urls 版本检查 URL 列表
 */
checkVersion(currentVersion, callback, urls := [
    "https://gitee.com/abgox/InputTip/raw/main/src/version.txt",
    "https://inputtip.abgox.com/releases/v2/version.txt",
    "https://github.com/abgox/InputTip/raw/main/src/version.txt"
]) {
    currentVersion := StrReplace(currentVersion, "v", "")
    for v in urls {
        if (check(v)) {
            return
        }
    }
    check(url) {
        static info := {
            version: "",
            url: ""
        }
        if (info.version) {
            callback(info.version, info.url)
            return 1
        }
        try {
            req := ComObject("Msxml2.XMLHTTP")
            req.open("GET", url, true)
            req.onreadystatechange := Ready
            req.send()
            Ready() {
                if (req.readyState != 4)  ; 没有完成.
                    return
                if (req.status == 200) {
                    if (info.version) {
                        return
                    }
                    newVersion := Trim(StrReplace(StrReplace(StrReplace(req.responseText, "`r", ""), "`n", ""), "v", ""))
                    if (newVersion ~= "^[\d\.]+$" && compareVersion(newVersion, currentVersion) > 0) {
                        if (info.version) {
                            return
                        }
                        info.version := newVersion
                        info.url := url
                        try {
                            callback(newVersion, url)
                        }
                    }
                }
            }
        }
    }
}

/**
 * 检查更新并弹出确认框
 */
checkUpdate(init := 0, once := false, force := 0) {
    if (checkUpdateDelay || force) {
        updateTitle := "InputTip - 有新版本啦，快去体验新版本吧!   "
        if (once) {
            _checkUpdate()
            return
        }
        if (init) {
            checkUpdateTimer()
        }
        SetTimer(checkUpdateTimer, checkUpdateDelay * 1000 * 60)
        checkUpdateTimer() {
            if (!checkUpdateDelay) {
                SetTimer(checkUpdateTimer, 0)
                return
            }
            if (gc.init) {
                return
            }
            _checkUpdate()
        }
        _checkUpdate() {
            if (A_IsCompiled) {
                checkVersion(currentVersion, updateConfirm)
                updateConfirm(newVersion, url) {
                    if (WinExist(updateTitle) || compareVersion(newVersion, currentVersion) <= 0) {
                        return
                    }
                    createGui(updateGui).Show()
                    updateGui(info) {
                        g := createGuiOpt(updateTitle)
                        g.AddText(, "InputTip 有版本更新: ")
                        g.AddText("yp cff5050", currentVersion)
                        g.AddText("yp", ">")
                        g.AddText("yp cRed", newVersion)
                        g.AddText("xs", "---------------------------------------------------------")
                        g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.abgox.com/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')
                        g.AddText("cRed", "点击确认更新后，会自动下载新版本替代旧版本并重启`n")

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        y := g.AddButton("xs w" bw, "确认更新")
                        y.Focus()
                        y.OnEvent("Click", e_yes)
                        e_yes(*) {
                            g.Destroy()
                            releases := [
                                "https://gitee.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe",
                                "https://inputtip.abgox.com/releases/v2/InputTip.exe",
                                "https://github.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe"
                            ]
                            done := false

                            downloading(*) {
                                g := createGuiOpt("InputTip - 版本更新中 " currentVersion " > " newVersion)
                                g.AddText("cRed", "InputTip 新版本 " newVersion " 下载中...")
                                g.AddText(, "--------------------------------------------------")
                                g.AddText("xs", "官网:")
                                g.AddLink("yp", '<a href="https://inputtip.abgox.com">https://inputtip.abgox.com</a>')
                                g.AddText("xs", "Github:")
                                g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
                                g.AddText("xs", "Gitee: :")
                                g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
                                g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.abgox.com/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')
                                g.Show()
                                g.OnEvent("Close", downloading)
                                return g
                            }
                            downloadingGui := downloading()


                            for v in releases {
                                try {
                                    Download(v, A_AppData "/abgox-InputTip-new-version.exe")
                                    ; 尝试获取版本号，成功获取则表示下载没有问题
                                    done := FileGetVersion(A_AppData "/abgox-InputTip-new-version.exe")
                                    break
                                }
                            }

                            downloadingGui.Destroy()

                            if (done) {
                                if (enableJABSupport) {
                                    killJAB(1, A_IsCompiled)
                                }
                                try {
                                    FileInstall("utils/app-update/target/release/app-update.exe", A_AppData "/abgox-InputTip-update-version.exe", 1)
                                    Run(A_AppData "/abgox-InputTip-update-version.exe " '"' A_ScriptName '" "' A_ScriptFullPath '" ' keyCount, , "Hide")
                                    ExitApp()
                                } catch {
                                    done := false
                                }
                            }

                            if (!done) {
                                createGui(errGui).Show()
                                errGui(info) {
                                    g := createGuiOpt("InputTip - 新版本下载错误")
                                    g.AddText("cRed", "InputTip 新版本下载错误!")
                                    g.AddText("xs cRed", "请手动下载最新版本的 InputTip.exe 文件并替换。")
                                    g.AddText(, "--------------------------------------------------")
                                    g.AddText("xs", "官网:")
                                    g.AddLink("yp", '<a href="https://inputtip.abgox.com">https://inputtip.abgox.com</a>')
                                    g.AddText("xs", "Github:")
                                    g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
                                    g.AddText("xs", "Gitee: :")
                                    g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')

                                    if (info.i) {
                                        return g
                                    }
                                    w := info.w
                                    bw := w - g.MarginX * 2

                                    y := g.AddButton("xs w" bw, "我知道了")
                                    y.Focus()
                                    y.OnEvent("Click", yes)
                                    g.OnEvent("Close", yes)
                                    yes(*) {
                                        g.Destroy()
                                        try {
                                            FileDelete(A_AppData "/abgox-InputTip-new-version.exe")
                                        }
                                    }
                                    return g
                                }
                            }
                        }
                        g.AddButton("xs w" bw, "忽略更新").OnEvent("Click", e_no)
                        e_no(*) {
                            g.Destroy()
                            global checkUpdateDelay := 0
                            writeIni("checkUpdateDelay", 0)
                            SetTimer(checkUpdateTimer, 0)

                            createGui(doneGui).Show()
                            doneGui(info) {
                                g := createGuiOpt("InputTip - 忽略更新检查")
                                g.AddText(, "InputTip 的")
                                g.AddText("yp cRed", "版本更新检查")
                                g.AddText("yp", "已忽略")
                                g.AddText("xs", "修改方式:「托盘菜单」=>「设置更新检查」")

                                g.AddText("cGray", "如果你在使用过程中有任何问题，先检查版本是否为最新版本`n如果更新到最新版本，问题依然存在，请前往 Github 新建一个 issue`nGithub 和其他相关地址可以在软件「托盘菜单」的「关于」中找到")

                                if (info.i) {
                                    return g
                                }

                                g.AddButton("w" info.w, "我知道了").OnEvent("Click", yes)
                                yes(*) {
                                    g.Destroy()
                                }
                                return g
                            }
                        }
                        g.OnEvent("Close", e_close)
                        e_close(*) {
                            g.Destroy()
                            checkUpdate()
                        }
                        return g
                    }
                }
            } else {
                checkVersion(currentVersion, updatePrompt)
                updatePrompt(newVersion, url) {
                    if (WinExist(updateTitle) || compareVersion(newVersion, currentVersion) <= 0) {
                        return
                    }
                    createGui(fn).Show()
                    fn(info) {
                        g := createGuiOpt(updateTitle)
                        g.AddText(, "- InputTip 有新版本了:")
                        g.AddText("yp cff5050", "v" currentVersion)
                        g.AddText("yp ", ">")
                        g.AddText("yp cRed", "v" newVersion)
                        g.AddText("xs cGray", "- 你正在使用 zip 版本(项目源代码运行方案)")
                        g.AddText("xs", "--------------------------------------------------------------------------------")
                        g.AddLink("xs", '- 使用 <a href="https://git-scm.com/">git</a>')
                        g.AddText("xs", "   - 可以通过")
                        g.AddText("yp cRed", "git clone")
                        g.AddText("yp", "项目仓库来使用 InputTip")
                        g.AddText("xs", "   - 然后通过")
                        g.AddText("yp cRed", "git pull")
                        g.AddText("yp", "拉取最新的代码更改，最后「托盘菜单」=>「重启」")
                        g.AddLink("xs", '- 不用 <a href="https://git-scm.com/">git</a>')
                        g.AddLink("xs", '   - 可以使用下方的「确认更新」按钮进行更新')
                        g.AddText("xs", "--------------------------------------------------------------------------------")
                        g.AddLink("xs", '项目仓库地址:   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
                        g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.abgox.com/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        g.OnEvent("Close", e_close)
                        e_close(*) {
                            g.Destroy()
                        }
                        y := g.AddButton("w" bw, "确认更新")
                        y.OnEvent("Click", e_yes)
                        e_yes(*) {
                            g.Destroy()
                            getRepoCode(newVersion)
                        }
                        g.AddButton("xs w" bw, "忽略更新").OnEvent("Click", no)
                        no(*) {
                            g.Destroy()
                            global checkUpdateDelay := 0
                            writeIni("checkUpdateDelay", 0)
                            SetTimer(checkUpdateTimer, 0)

                            createGui(doneGui).Show()
                            doneGui(info) {
                                g := createGuiOpt("InputTip - 忽略更新检查")
                                g.AddText(, "InputTip 的")
                                g.AddText("yp cRed", "版本更新检查")
                                g.AddText("yp", "已忽略")
                                g.AddText("xs", "修改方式:「托盘菜单」=>「设置更新检查」")

                                g.AddText("cGray", "如果你在使用过程中有任何问题，先检查版本是否为最新版本`n如果更新到最新版本，问题依然存在，请前往 Github 新建一个 issue`nGithub 和其他相关地址可以在软件「托盘菜单」的「关于」中找到")

                                if (info.i) {
                                    return g
                                }

                                g.AddButton("w" info.w, "我知道了").OnEvent("Click", yes)
                                yes(*) {
                                    g.Destroy()
                                }
                                return g
                            }
                        }
                        return g
                    }
                }
            }
        }
    }
}

getRepoCode(newVersion) {
    done := 1

    try {
        FileDelete("files.ini")
    }
    for u in baseUrl {
        out := "files.ini"
        try {
            Download(u "src/files.ini", out)
            break
        }
    }

    try {
        files := StrSplit(IniRead("files.ini", "files"), "`n")
        tip := ""
        downloading(*) {
            if (newVersion) {
                g := createGuiOpt("InputTip - 版本更新中 " currentVersion " > " newVersion)
                g.AddText("cRed", "InputTip 新版本 " newVersion " 下载中...")
            } else {
                g := createGuiOpt("InputTip - 正在获取最新的源代码...")
            }
            g.AddText(, "正在下载和校验文件: ")
            tip := g.AddText("xs cRed", "                                                            ")

            g.AddText("xs", "------------------------------------------------------------")
            g.AddText("xs", "官网:")
            g.AddLink("yp", '<a href="https://inputtip.abgox.com">https://inputtip.abgox.com</a>')
            g.AddText("xs", "Github:")
            g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
            g.AddText("xs", "Gitee: :")
            g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
            g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.abgox.com/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')
            g.Show()
            g.OnEvent("Close", downloading)
            return g
        }
        downloadingGui := downloading()

        doneFileList := []
        for kv in files {
            p := StrSplit(kv, "=")
            for u in baseUrl {
                tip.Text := p[1]
                out := p[2] ".new"
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
                    Download(u p[1], out)
                    break
                }
            }
            if (FileExist(out)) {
                doneFileList.Push(out)
                if (InStr(out, ".ahk")) {
                    try {
                        if (!InStr(FileOpen(out, "r").ReadLine(), "InputTip")) {
                            done := 0
                            break
                        }
                    } catch {
                        done := 0
                        break
                    }
                }
            } else {
                done := 0
                break
            }
        }

        downloadingGui.Destroy()

        if (done) {
            for v in doneFileList {
                FileMove(v, RegExReplace(v, "\.new$", ""), 1)
            }
            if (newVersion) {
                FileAppend("", A_AppData "/.abgox-InputTip-update-version-done.txt")
            }
            fn_restart()
        }
    } catch {
        done := 0
        try {
            downloadingGui.Destroy()
        }
    }

    if (!done) {
        try {
            for v in doneFileList {
                FileDelete(v)
            }
        }

        createGui(errGui).Show()
        errGui(info) {
            if (newVersion) {
                g := createGuiOpt("InputTip - 新版本下载错误")
                g.AddText("cRed", "InputTip 新版本下载错误!")
            } else {
                g := createGuiOpt("InputTip - 获取失败")
                g.AddText("cRed", "最新的源代码获取失败!")
            }

            g.AddText("cRed", "请手动下载最新版本的 InputTip.Zip 并解压替换。")
            g.AddText(, "--------------------------------------------------")
            g.AddText("xs", "官网:")
            g.AddLink("yp", '<a href="https://inputtip.abgox.com">https://inputtip.abgox.com</a>')
            g.AddText("xs", "Github:")
            g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
            g.AddText("xs", "Gitee: :")
            g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            y := g.AddButton("xs w" bw, "我知道了")
            y.Focus()
            y.OnEvent("Click", yes)
            g.OnEvent("Close", yes)
            yes(*) {
                g.Destroy()
            }
            return g
        }
    }
}


/**
 * 当更新完成时弹出提示框
 */
checkUpdateDone() {
    if (FileExist(A_AppData "/.abgox-InputTip-update-version-done.txt")) {
        modeRules := []
        try {
            _ := IniRead("InputTip.ini", "InputMethod", "statusMode")
            modeRules.Push(StrReplace(RegExReplace(_, "(^:)|(:$)", ""), ":", "/"))
            IniDelete("InputTip.ini", "InputMethod", "statusMode")
        }
        try {
            _ := IniRead("InputTip.ini", "InputMethod", "conversionMode")
            modeRules.Push(StrReplace(RegExReplace(_, "(^:)|(:$)", ""), ":", "/"))
            IniDelete("InputTip.ini", "InputMethod", "conversionMode")
        }
        try {
            _ := IniRead("InputTip.ini", "InputMethod", "evenStatusMode")
            if (_ != "") {
                modeRules[1] := _ ? "evenNum" : "oddNum"
            }
            IniDelete("InputTip.ini", "InputMethod", "evenStatusMode")
        }
        try {
            _ := IniRead("InputTip.ini", "InputMethod", "evenConversionMode")
            if (_ != "") {
                modeRules[2] := _ ? "evenNum" : "oddNum"
            }
            IniDelete("InputTip.ini", "InputMethod", "evenConversionMode")
        }
        if (modeRules.Length) {
            baseStatus := readIni("baseStatus", 0, "InputMethod")
            modeRules.Push(baseStatus)
            writeIni("baseStatus", !baseStatus, "InputMethod")
            writeIni("modeRule", arrJoin(modeRules, "*"), "InputMethod")
        }
        try {
            _ := IniRead("InputTip.ini", "Config-v2", "JetBrains_list")
            writeIni("cursor_mode_JAB", _)
            IniDelete("InputTip.ini", "Config-v2", "JetBrains_list")
        }
        try {
            _ := IniRead("InputTip.ini", "Config-v2", "enableJetBrainsSupport")
            writeIni("enableJABSupport", _)
            IniDelete("InputTip.ini", "Config-v2", "enableJetBrainsSupport")
        }
        try {
            ignoreUpdate := IniRead("InputTip.ini", "Config-v2", "ignoreUpdate")
            _ := ignoreUpdate ? 0 : 1440
            writeIni("checkUpdateDelay", _)
            IniDelete("InputTip.ini", "Config-v2", "ignoreUpdate")
        }

        try {
            _ := IniRead("InputTip.ini", "InputMethod", "statusModeEN")
            writeIni("statusMode", _, "InputMethod")
            writeIni("conversionMode", readIni("conversionModeEN", "", "InputMethod"), "InputMethod")
            writeIni("evenStatusMode", readIni("evenStatusModeEN", "", "InputMethod"), "InputMethod")
            writeIni("evenConversionMode", readIni("evenConversionModeEN", "", "InputMethod"), "InputMethod")
            IniDelete("InputTip.ini", "InputMethod", "statusModeEN")
            IniDelete("InputTip.ini", "InputMethod", "conversionModeEN")
            IniDelete("InputTip.ini", "InputMethod", "evenStatusModeEN")
            IniDelete("InputTip.ini", "InputMethod", "evenConversionModeEN")
        } catch {
            mode := readIni("mode", 1, "InputMethod")
            switch mode {
                case 2:
                    writeIni("mode", 1, "InputMethod")
                case 3:
                    ; 讯飞输入法
                    writeIni("evenStatusMode", "0", "InputMethod")
                    writeIni("mode", 0, "InputMethod")
                case 4:
                    ; 手心输入法
                    writeIni("conversionMode", ":1:", "InputMethod")
                    writeIni("mode", 0, "InputMethod")
            }
            border_type := readIni('border_type', 1)
            if (border_type = 4) {
                writeIni('border_type', 0)
            }
        }

        try {
            IniRead("InputTip.ini", "Config-v2", "textSymbol_CN_color")
        } catch {
            writeIni("textSymbol_CN_color", readIni("CN_color", "red"))
            writeIni("textSymbol_EN_color", readIni("EN_color", "blue"))
            writeIni("textSymbol_Caps_color", readIni("Caps_color", "green"))
            writeIni("textSymbol_transparent", readIni('transparent', 222))
            writeIni("textSymbol_offset_x", readIni('offset_x', 10))
            writeIni("textSymbol_offset_y", readIni('offset_y', -30))
            writeIni("textSymbol_border_type", readIni('border_type', 1))
        }

        createGui(doneGui).Show()
        doneGui(info) {
            g := Gui("AlwaysOnTop", "InputTip - 版本更新完成")
            g.SetFont("s14", "Microsoft YaHei")
            g.AddText(, "版本更新完成，当前版本: ")
            g.AddText("yp cRed", currentVersion)
            g.AddText("xs", "-------------------------------------------")
            g.AddText("xs", "建议查看更新日志，了解最新变化")
            g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.abgox.com/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            y := g.AddButton("xs w" bw, "我知道了")
            y.Focus()
            y.OnEvent("Click", yes)
            yes(*) {
                g.Destroy()
            }
            return g
        }
        try {
            FileDelete(A_AppData "/.abgox-InputTip-update-version-done.txt")
        }
        try {
            FileDelete(A_AppData "/abgox-InputTip-update-version.exe")
        }
    }
}
