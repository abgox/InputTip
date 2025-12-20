; InputTip

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
    check(1)
    check(index) {
        if (index > urls.Length) {
            return
        }
        url := urls[index]
        try {
            req := ComObject("Msxml2.XMLHTTP")
            req.open("GET", url, true)
            req.onreadystatechange := Ready
            req.send()
            Ready() {
                if (req.readyState != 4) {
                    return
                }
                if (req.status == 200) {
                    newVersion := Trim(StrReplace(StrReplace(StrReplace(req.responseText, "`r", ""), "`n", ""), "v", ""))
                    if (newVersion ~= "^[\d\.]+$") {
                        if (compareVersion(newVersion, currentVersion) > 0) {
                            try {
                                callback(newVersion, url)
                            }
                        }
                        return
                    }
                }
                check(index + 1)
            }
        }
    }
}

/**
 * 检查更新并弹出确认框
 */
checkUpdate(init := 0, once := 0, force := 0, silent := silentUpdate) {
    if (checkUpdateDelay || force) {
        updateTitle := "InputTip - " versionType lang("check_update.title_version")
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
            static needSilentTip := 1
            if (A_IsCompiled) {
                checkVersion(currentVersion, updateConfirm)
                updateConfirm(newVersion, url) {
                    if (gc.w.updateGui || compareVersion(newVersion, currentVersion) <= 0) {
                        return
                    }

                    /**
                     * 下载并替换新版本
                     * @returns {1 | 0} 是否完成
                     */
                    updateNewVersion() {
                        releases := [
                            "https://gitee.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe",
                            "https://github.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe"
                        ]
                        done := false

                        downloading(*) {
                            g := createGuiOpt("InputTip - " currentVersion " > " newVersion)
                            g.AddText("cRed", lang("check_update.downloading") newVersion lang("check_update.downloading_suffix"))
                            g.AddText(, "--------------------------------------------------")
                            g.AddText("xs", lang("check_update.website"))
                            g.AddLink("yp", '<a href="https://inputtip.abgox.com">inputtip.abgox.com</a>')
                            g.AddText("xs", "Github:")
                            g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>')
                            g.AddText("xs", "Gitee: :")
                            g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>')
                            g.AddLink("xs", lang("check_update.changelog") '   <a href="https://inputtip.abgox.com/v2/changelog">' StrReplace(lang("check_update.website"), ":", "") '</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')
                            if (!silent) {
                                g.Show()
                            }
                            g.OnEvent("Close", downloading)
                            return g
                        }
                        downloadingGui := downloading()

                        for v in releases {
                            try {
                                out := A_ScriptDir "/InputTipSymbol/default/abgox-InputTip-new-version.exe"
                                Download(v, out)
                                ; 尝试获取版本号，成功获取则表示下载没有问题
                                done := compareVersion(FileGetVersion(out), currentVersion) > 0
                                break
                            }
                        }
                        downloadingGui.Destroy()

                        if (done) {
                            if (enableJABSupport) {
                                killJAB(1)
                            }
                            try {
                                FileInstall("utils/app-update/target/release/app-update.exe", A_ScriptDir "/InputTipSymbol/default/abgox-InputTip-update-version.exe", 1)
                                writeIni("clickUpdate", !silent)
                                Run(A_ScriptDir "/InputTipSymbol/default/abgox-InputTip-update-version.exe " '"' A_ScriptName '" "' A_ScriptFullPath '" ' keyCount, , "Hide")
                                ExitApp()
                            } catch {
                                done := false
                            }
                        }
                        return done
                    }

                    if (silent) {
                        if (needSilentTip) {
                            needSilentTip := 0
                            A_TrayMenu.Insert(lang("tray.startup"), lang("check_update.silent_ready"), _do)
                            A_TrayMenu.Insert(lang("tray.startup"), lang("check_update.silent_wait"), _do)
                            _do(*) {
                            }
                            A_TrayMenu.Insert(lang("tray.startup"))
                            SetTimer(updateNewVersionTimer, 10000)
                            updateNewVersionTimer() {
                                ; 3 分钟内没有鼠标和键盘操作，视为电脑休闲时间，则自动更新
                                if (A_TimeIdle > 1000 * 60 * 3) {
                                    updateNewVersion()
                                    SetTimer(, 0)
                                }
                            }
                        }
                        return
                    }

                    downloadLog := 0
                    tempLog := A_Temp "\abgox.InputTip-CHANGELOG.md"
                    try {
                        Download(StrReplace(url, '/version.txt', '/CHANGELOG.md'), tempLog)
                        downloadLog := 1
                    }

                    createGui(updateGui).Show()
                    updateGui(info) {
                        g := createGuiOpt(updateTitle)
                        g.AddText(, lang("check_update.has_update"))
                        g.AddText("yp cff5050", currentVersion)
                        g.AddText("yp", ">")
                        g.AddText("yp cRed", newVersion)
                        g.AddText("xs", gui_width_line).Focus()

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        if (downloadLog) {
                            logContent := FileRead(tempLog, "UTF-8")
                            g.AddEdit("xs ReadOnly cGray VScroll r9 w" w, SubStr(logContent, InStr(logContent, "#")))
                        } else {
                            g.AddText("xs cGray", "版本日志加载失败，你可以通过以下链接查看在线的版本更新日志")
                        }

                        g.AddLink("xs", lang("check_update.repo_addr") '   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
                        g.AddLink("xs", lang("check_update.changelog") '   <a href="https://inputtip.abgox.com/v2/changelog">' StrReplace(lang("check_update.website"), ":", "") '</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')

                        g.AddButton("xs w" bw / 2, lang("check_update.confirm_update")).OnEvent("Click", e_yes)
                        e_yes(*) {
                            fn_close()
                            if (!updateNewVersion()) {
                                createGui(errGui).Show()
                                errGui(info) {
                                    g := createGuiOpt("InputTip - " lang("common.error"))
                                    g.AddText("cRed", lang("check_update.download_error"))
                                    g.AddText("xs cRed", lang("check_update.manual_download"))
                                    g.AddText(, "--------------------------------------------------")
                                    g.AddText("xs", lang("check_update.website"))
                                    g.AddLink("yp", '<a href="https://inputtip.abgox.com">inputtip.abgox.com</a>')
                                    g.AddText("xs", "Github:")
                                    g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>')
                                    g.AddText("xs", "Gitee: :")
                                    g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>')

                                    if (info.i) {
                                        return g
                                    }
                                    w := info.w
                                    bw := w - g.MarginX * 2

                                    g.AddButton("xs w" bw, lang("common.i_understand")).OnEvent("Click", yes)
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
                        g.AddButton("yp w" bw / 2, lang("check_update.cancel_update")).OnEvent("Click", fn_close)
                        g.AddButton("xs w" bw / 2, lang("check_update.close_check")).OnEvent("Click", e_no)
                        g.AddButton("yp w" bw / 2, lang("check_update.enable_silent")).OnEvent("Click", e_silent)
                        e_no(*) {
                            fn_close()
                            SetTimer(checkUpdateTimer, 0)
                            ignoreUpdateTip()
                        }
                        e_silent(*) {
                            fn_close()
                            writeIni("silentUpdate", 1)
                            global silentUpdate := 1
                        }
                        g.OnEvent("Close", fn_close)
                        fn_close(*) {
                            g.Destroy()
                            gc.w.updateGui := ""
                        }
                        gc.w.updateGui := g
                        return g
                    }
                }
            } else {
                checkVersion(currentVersion, updatePrompt, [
                    "https://gitee.com/abgox/InputTip/raw/main/src/version-zip.txt",
                    "https://inputtip.abgox.com/releases/v2/version-zip.txt",
                    "https://github.com/abgox/InputTip/raw/main/src/version-zip.txt"
                ])
                updatePrompt(newVersion, url) {
                    if (gc.w.updateGui || compareVersion(newVersion, currentVersion) <= 0) {
                        return
                    }
                    if (silent) {
                        A_TrayMenu.Insert(lang("tray.startup"), lang("check_update.silent_ready"), _do)
                        A_TrayMenu.Insert(lang("tray.startup"), lang("check_update.silent_wait"), _do)
                        _do(*) {
                        }
                        A_TrayMenu.Insert(lang("tray.startup"))
                        SetTimer(updateNewVersionTimer, 10000)
                        updateNewVersionTimer() {
                            ; 3 分钟内没有鼠标和键盘操作，视为电脑休闲时间，则自动更新
                            if (A_TimeIdle > 1000 * 60 * 3) {
                                getRepoCode(newVersion, silent)
                                SetTimer(, 0)
                            }
                        }
                        return
                    }

                    downloadLog := 0
                    tempLog := A_Temp "\abgox.InputTip-CHANGELOG.md"
                    try {
                        Download(StrReplace(url, '/version-zip.txt', '/CHANGELOG.md'), tempLog)
                        downloadLog := 1
                    }
                    createGui(fn).Show()
                    fn(info) {
                        g := createGuiOpt(updateTitle)
                        g.AddText(, lang("check_update.has_update"))
                        g.AddText("yp cff5050", "v" currentVersion)
                        g.AddText("yp ", ">")
                        g.AddText("yp cRed", "v" newVersion)
                        g.AddText("xs", gui_width_line).Focus()

                        if (info.i) {
                            return g
                        }
                        w := info.w
                        bw := w - g.MarginX * 2

                        if (downloadLog) {
                            logContent := FileRead(tempLog, "UTF-8")
                            g.AddEdit("xs ReadOnly cGray VScroll r9 w" w, SubStr(logContent, InStr(logContent, "#")))
                        } else {
                            g.AddText("xs cGray", "版本日志加载失败，你可以通过以下链接查看在线的版本更新日志")
                        }

                        g.AddLink("xs", lang("check_update.repo_addr") '   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
                        g.AddLink("xs", lang("check_update.changelog") '   <a href="https://inputtip.abgox.com/v2/changelog">' StrReplace(lang("check_update.website"), ":", "") '</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')

                        g.AddButton("w" w / 2, lang("check_update.confirm_update")).OnEvent("Click", e_yes)
                        e_yes(*) {
                            fn_close()
                            getRepoCode(newVersion, 0)
                        }
                        g.AddButton("yp w" w / 2, lang("check_update.cancel_update")).OnEvent("Click", fn_close)
                        g.AddButton("xs w" w / 2, lang("check_update.close_check")).OnEvent("Click", e_no)
                        g.AddButton("yp w" w / 2, lang("check_update.enable_silent")).OnEvent("Click", e_silent)
                        e_no(*) {
                            fn_close()
                            SetTimer(checkUpdateTimer, 0)
                            ignoreUpdateTip()
                        }
                        e_silent(*) {
                            fn_close()
                            writeIni("silentUpdate", 1)
                            global silentUpdate := 1
                        }
                        g.OnEvent("Close", fn_close)
                        fn_close(*) {
                            g.Destroy()
                            gc.w.updateGui := ""
                        }
                        gc.w.updateGui := g
                        return g
                    }
                }
            }
        }
    }
}


; 忽略更新的弹窗提示
ignoreUpdateTip() {
    global checkUpdateDelay := 0
    writeIni("checkUpdateDelay", 0)

    createGui(doneGui).Show()
    doneGui(info) {
        g := createGuiOpt(lang("check_update.close_success"))
        g.AddText(, "InputTip " lang("check_update.check_closed"))
        g.AddText("yp cRed", lang("check_update.check_closed"))
        g.AddText("yp", lang("check_update.closed"))
        g.AddText("xs", lang("check_update.close_tip"))
        g.AddText("xs", lang("check_update.set_way"))

        g.AddText("cGray", lang("check_update.feedback_tip"))

        if (info.i) {
            return g
        }

        w := info.w
        bw := w - g.MarginX * 2

        g.AddButton("w" bw, lang("common.i_understand")).OnEvent("Click", yes)
        yes(*) {
            g.Destroy()
        }
        return g
    }
}

; 下载最新的源代码文件
getRepoCode(newVersion, silent := silentUpdate) {
    done := 1
    ; 是否成功下载 files.ini
    downloadIni := 0

    try {
        FileDelete("files.ini")
    }
    downloadingGui := downloading(0)
    for u in baseUrl {
        out := "files.ini"
        try {
            Download(u "src/files.ini", out)
            downloadIni := 1
            Sleep(1000)
            break
        }
    }
    downloading(downloadCodeFile := 1, *) {
        if (newVersion) {
            g := createGuiOpt("InputTip - " newVersion lang("check_update.downloading_suffix"))
            g.AddText("cRed", lang("check_update.downloading") newVersion lang("check_update.downloading_suffix"))
        } else {
            g := createGuiOpt("InputTip - " lang("check_update.syncing"))
        }
        if (downloadCodeFile) {
            g.AddText(, lang("check_update.download_verify"))
            tip := g.AddText("xs cRed", "                                                            ")
        } else {
            g.AddText("cRed", lang("check_update.download_ini"))
        }

        g.AddText("xs", "------------------------------------------------------------")
        g.AddText("xs", lang("check_update.website"))
        g.AddLink("yp", '<a href="https://inputtip.abgox.com">inputtip.abgox.com</a>')
        g.AddText("xs", "Github:")
        g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>')
        g.AddText("xs", "Gitee: :")
        g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>')
        g.AddLink("xs", lang("check_update.changelog") '   <a href="https://inputtip.abgox.com/v2/changelog">' StrReplace(lang("check_update.website"), ":", "") '</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')
        if (!silent) {
            g.Show()
        }
        g.OnEvent("Close", downloading)
        return g
    }

    downloadingGui.Destroy()

    if (downloadIni) {
        try {
            files := StrSplit(IniRead("files.ini", "files"), "`n")
            tip := ""
            downloadingGui := downloading()

            doneFileList := []
            fileCount := files.Length
            for i, kv in files {
                p := StrSplit(kv, "=")
                for u in baseUrl {
                    tip.Text := i '/' fileCount " : " p[1]
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
                    FileAppend(newVersion, A_ScriptDir "/InputTipSymbol/default/abgox-InputTip-update-version-done.txt")
                    writeIni("clickUpdate", !silent)
                }
                fn_restart()
            }
        } catch {
            done := 0
            try {
                downloadingGui.Destroy()
            }
        }
    } else {
        done := 0
    }

    if (!done) {
        try {
            for v in doneFileList {
                FileDelete(v)
            }
        }

        if (silent) {
            return
        }
        createGui(errGui).Show()
        errGui(info) {
            if (newVersion) {
                g := createGuiOpt("InputTip - " lang("check_update.download_error"))
                g.AddText("cRed", lang("check_update.download_error"))
            } else {
                g := createGuiOpt("InputTip - " lang("check_update.sync_fail"))
                g.AddText("cRed", lang("check_update.sync_fail"))
            }

            g.AddText("cRed", lang("check_update.check_net"))
            g.AddText("cRed", lang("check_update.manual_down_tip"))
            g.AddText(, "--------------------------------------------------")
            g.AddText("xs", lang("check_update.website"))
            g.AddLink("yp", '<a href="https://inputtip.abgox.com">inputtip.abgox.com</a>')
            g.AddText("xs", "Github:")
            g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>')
            g.AddText("xs", "Gitee: :")
            g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>')

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddButton("xs w" bw, lang("common.i_understand")).OnEvent("Click", (*) => g.Destroy())
            return g
        }
    }
}


/**
 * 当更新完成时弹出提示框，并进行配置更新
 */
checkUpdateDone() {
    oldVersion := readIni(versionKey, currentVersion, "UserInfo")
    flagFile := A_AppData "/.abgox-InputTip-update-version-done.txt"
    flagFile2 := A_ScriptDir "/InputTipSymbol/default/abgox-InputTip-update-version-done.txt"
    if (compareVersion(currentVersion, oldVersion) > 0 || FileExist(flagFile) || FileExist(flagFile2)) {

        writeIni("init", 1, "Installer")

        if (InStr(SubStr(readIni("iconRunning", "InputTipIcon\default\app.png"), 1, 15), "InputTipSymbol\")) {
            writeIni("iconRunning", "InputTipIcon\default\app.png")
            global iconRunning := "InputTipIcon\default\app.png"
        }

        if (InStr(SubStr(readIni("iconPaused", "InputTipIcon\default\app-paused.png"), 1, 15), "InputTipSymbol\")) {
            writeIni("iconPaused", "InputTipIcon\default\app-paused.png")
            global iconPaused := "InputTipIcon\default\app-paused.png"
        }


        for v in ["CN", "EN", "Caps"] {
            try {
                _ := StrSplit(IniRead("InputTip.ini", "Config-v2", "app_" v), ":")
                for value in _ {
                    if (Trim(value)) {
                        id := returnId()
                        IniWrite(value ":1", "InputTip.ini", "App-" v, id)
                        Sleep(5)
                    }
                }
                IniDelete("InputTip.ini", "Config-v2", "app_" v)
            }
        }

        list := [{
            old: "showCursorPosList",
            new: "ShowNearCursor"
        }, {
            old: "app_hide_state",
            new: "App-HideSymbol"
        }, {
            old: "app_show_state",
            new: "App-ShowSymbol"
        }]

        for v in list {
            try {
                _ := StrSplit(IniRead("InputTip.ini", "Config-v2", v.old), ":")
                for value in _ {
                    if (Trim(value)) {
                        id := returnId()
                        IniWrite(value ":1", "InputTip.ini", v.new, id)
                        Sleep(5)
                    }
                }
                IniDelete("InputTip.ini", "Config-v2", v.old)
            }
        }

        try {
            IniRead("InputTip.ini", "App-Offset")
        } catch {
            try {
                for value in StrSplit(IniRead("InputTip.ini", "Config-v2", "app_offset"), ":") {
                    if (Trim(value)) {
                        id := returnId()
                        IniWrite(StrReplace(StrReplace(value, "|", ":1:0:"), "*", "|") ":", "InputTip.ini", "App-Offset", id)
                        Sleep(5)
                    }
                }
            }
        }

        for v in modeNameList {
            try {
                _ := StrSplit(IniRead("InputTip.ini", "Config-v2", "cursor_mode_" v), ":")
                for value in _ {
                    if (Trim(value)) {
                        id := returnId()
                        IniWrite(value ":" v, "InputTip.ini", "InputCursorMode", id)
                        Sleep(5)
                    }
                }
                IniDelete("InputTip.ini", "Config-v2", "cursor_mode_" v)
            }
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
                    writeIni("evenStatusMode", 0, "InputMethod")
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

        modeRules := []
        for v in ["statusMode", "conversionMode"] {
            try {
                _ := IniRead("InputTip.ini", "InputMethod", v)
                modeRules.Push(StrReplace(RegExReplace(_, "(^:)|(:$)", ""), ":", "/"))
                IniDelete("InputTip.ini", "InputMethod", v)
            }
        }
        for i, v in ["evenStatusMode", "evenConversionMode"] {
            try {
                _ := IniRead("InputTip.ini", "InputMethod", v)
                if (_ != "") {
                    modeRules[i] := _ ? "evenNum" : "oddNum"
                }
                IniDelete("InputTip.ini", "InputMethod", v)
            }
        }
        if (modeRules.Length) {
            baseStatus := readIni("baseStatus", 0, "InputMethod")
            modeRules.Push(baseStatus)
            writeIni("baseStatus", !baseStatus, "InputMethod")
            try {
                IniDelete("InputTip.ini", "InputMethod", "baseStatus")
            }
            writeIni("modeRule", arrJoin(modeRules, "*"), "InputMethod")
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

        ; 配置项更名(old => new)
        replaceConfig := [
            ["JetBrains_list", "cursor_mode_JAB"],
            ["enableJetBrainsSupport", "enableJABSupport"],
            ["useShift", "switchStatus"],
            ["picDir", "symbolPaths"]
        ]
        for v in replaceConfig {
            try {
                _ := IniRead("InputTip.ini", "Config-v2", v[1])
                writeIni(v[2], _)
                IniDelete("InputTip.ini", "Config-v2", v[1])
            }
        }

        global switchStatus := readIni("switchStatus", 1)

        if (silentUpdate && !readIni("clickUpdate", 0)) {
            SetTimer(handlePostUpdate, -500)
            return
        }

        handlePostUpdate() {
            for v in [flagFile, flagFile2, A_AppData "/abgox-InputTip-update-version.exe", A_ScriptDir "/InputTipSymbol/default/abgox-InputTip-update-version.exe"] {
                try {
                    FileDelete(v)
                }
            }
            writeIni(versionKey, currentVersion, "UserInfo")
            writeIni("clickUpdate", 0)
        }

        createGui(doneGui).Show()
        doneGui(info) {
            g := Gui("AlwaysOnTop", lang("check_update.completed"))
            g.SetFont("s14", "Microsoft YaHei")
            g.AddText(, lang("check_update.completed_msg"))
            g.AddText("yp cRed", currentVersion)
            g.AddText("xs", gui_width_line).Focus()

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            try {
                logContent := FileRead(A_Temp "\abgox.InputTip-CHANGELOG.md", "UTF-8")
                g.AddEdit("xs ReadOnly cGray VScroll r9 w" bw, SubStr(logContent, InStr(logContent, "#")))
            } catch {
                g.AddText("xs cGray", lang("check_update.changelog_fail"))
            }
            g.AddLink("xs", lang("check_update.repo_addr") '   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
            g.AddLink("xs", lang("check_update.changelog") '   <a href="https://inputtip.abgox.com/v2/changelog">' StrReplace(lang("check_update.website"), ":", "") '</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')

            g.AddButton("xs w" bw, lang("common.i_understand")).OnEvent("Click", yes)
            g.OnEvent("Close", yes)
            yes(*) {
                g.Destroy()
                handlePostUpdate()
                fn_restart()
            }
            return g
        }
    }
}
