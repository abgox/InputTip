; InputTip

e_updateCheck(*) {
    showGui(createUniqueGui(checkUpdateGui))
    checkUpdateGui(info) {
        g := createGuiOpt(i18n("updateCheck"))
        g.AddLink("Section", getDocsLink("update-check"))

        if (info.i) {
            return g
        }
        g.w := w := info.w
        g.bw := bw := w - g.MarginX * 2

        renderEditGroup(g, "updateCheckInterval", "Number Limit4")
        renderRadioGroup(g, "silentUpdate", [["yes", 1], ["no", 0]])

        if (A_IsCompiled) {
            g.AddButton("xs w" bw, i18n("checkUpdateNow")).OnEvent("Click", (*) => (g.Destroy(), checkUpdate(1, 1, 1, 0)))
        } else {
            g.AddButton("xs w" bw, i18n("updateNow")).OnEvent("Click", (*) => (g.Destroy(), getRepoCode(0, 0)))
        }
        return g
    }
}

; exe 版本的更新器
updater := A_ScriptDir "/temp/abgox-InputTip-update-version.exe"
logFile := A_ScriptDir "/temp/abgox.InputTip-CHANGELOG.md"
flagFile := A_ScriptDir "/temp/abgox-InputTip-update-version-done.txt"

; 是否有新版本
hasNewVersion(new, old) {
    return new != old
}

/**
 * 检查版本更新(异步)
 * @param currentVersion 当前版本号
 * @param callback 版本检查完成后的回调函数
 * @param urls 版本号 URL 列表
 */
checkVersion(currentVersion, callback) {
    check(1)
    check(index) {
        if (index > baseUrl.Length)
            return
        url := baseUrl[index] "/src/versions.txt"
        try {
            req := ComObject("Msxml2.XMLHTTP")
            req.open("GET", url, true)
            req.onreadystatechange := Ready
            req.send()
            Ready() {
                if req.readyState != 4
                    return
                if (req.status == 200) {
                    if RegExMatch(req.responseText, "i)" (A_IsCompiled ? "exe" : "zip") "\s*=\s*v?([\d.]+)", &m) {
                        newVersion := Trim(m[1])
                        if (newVersion ~= "^[\d\.]+$") {
                            if hasNewVersion(newVersion, currentVersion)
                                try callback(newVersion, url)
                            return
                        }
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
checkUpdate(init := 0, once := 0, force := 0, silent := var.silentUpdate) {
    if (var.updateCheckInterval || force) {
        updateTitle := i18n("updateVersion")
        if (once) {
            _checkUpdate()
            return
        }
        if (init) {
            checkUpdateTimer()
        }
        SetTimer(checkUpdateTimer, var.updateCheckInterval * 1000 * 60)
        checkUpdateTimer() {
            if (!var.updateCheckInterval) {
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
                    if (gc.w.updateGui || !hasNewVersion(newVersion, currentVersion)) {
                        return
                    }

                    /**
                     * 下载并替换新版本
                     * @returns {1|0} 是否完成
                     */
                    updateNewVersion() {
                        releases := [
                            "https://gitee.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe",
                            "https://github.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe",
                            "https://gh-proxy.org/https://github.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe"
                        ]
                        done := false

                        downloading(*) {
                            g := createGuiOpt(i18n("updateCheck"))
                            g.AddText("cRed", i18n("update.downloading"))
                            g.AddText(, "--------------------------------------------------")
                            g.AddLink("xs", getLink("inputtip.abgox.com"))
                            g.AddLink("xs", getLink("github.com/abgox/InputTip"))
                            g.AddLink("xs", getLink("gitee.com/abgox/InputTip"))
                            if (!silent) {
                                g.Show()
                            }
                            g.OnEvent("Close", downloading)
                            return g
                        }
                        downloadingGui := downloading()

                        for v in releases {
                            try {
                                out := A_ScriptDir "/temp/abgox-InputTip-new-version.exe"
                                Download(v, out)
                                ; 尝试获取版本号，成功获取则表示下载没有问题
                                done := FileGetVersion(out)
                                break
                            }
                        }
                        downloadingGui.Destroy()

                        if (done) {
                            if (var.symbolJABActive) {
                                killJAB(1)
                            }
                            try {
                                FileInstall("core/app-update/target/release/app-update.exe", updater, 1)
                                Run('"' updater '" "' A_ScriptName '" "' A_ScriptFullPath '" ' keyCount, , "Hide")
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

                    try {
                        Download(StrReplace(url, "/versions.txt", "/CHANGELOG.md"), logFile)
                        showGui(createUniqueGui(updateGui))
                        updateGui(info) {
                            g := createGuiOpt(updateTitle)

                            if (info.i) {
                                g.AddText(, line80)
                                return g
                            }
                            g.w := w := info.w
                            g.bw := bw := w - g.MarginX * 2

                            showLog(g)

                            g.AddButton("xs w" w, i18n("update.confirm")).OnEvent("Click", e_yes)
                            e_yes(*) {
                                fn_close()
                                if (!updateNewVersion()) {
                                    showGui(createErrorTipGui(i18n("update.error", 1)))
                                }
                            }
                            g.AddButton("xs w" w, i18n("update.cancel")).OnEvent("Click", fn_close)
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
            } else {
                checkVersion(currentVersion, updatePrompt)
                updatePrompt(newVersion, url) {
                    if (gc.w.updateGui || !hasNewVersion(newVersion, currentVersion)) {
                        return
                    }
                    if (silent) {
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
                    try {
                        Download(StrReplace(url, "/versions.txt", "/CHANGELOG.md"), logFile)
                        showGui(createUniqueGui(fn))
                        fn(info) {
                            g := createGuiOpt(updateTitle)
                            if (info.i) {
                                g.AddText(, line80)
                                return g
                            }
                            g.w := w := info.w
                            g.bw := bw := w - g.MarginX * 2

                            showLog(g)

                            g.AddButton("xs w" w, i18n("update.confirm")).OnEvent("Click", (*) => (fn_close(), getRepoCode(newVersion, 0)))
                            g.AddButton("xs w" w, i18n("update.cancel")).OnEvent("Click", fn_close)
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
}

; 下载最新的源代码文件
getRepoCode(newVersion, silent := var.silentUpdate) {
    ; 是否成功下载 files.ini
    downloadIni := 0
    try FileDelete("files.ini")
    for u in baseUrl {
        out := "files.ini"
        try {
            Download(u "src/files.ini", out)
            try {
                if (InStr(FileOpen(out, "r").ReadLine(), "InputTip")) {
                    downloadIni := 1
                    break
                }
            }
        }
    }
    if (downloadIni) {
        done := showDownloadProcessGui(i18n("update.downloading"), StrSplit(IniRead("files.ini", "files"), "`n"), "updateVersion")
        if (done) {
            if (newVersion) {
                FileAppend(newVersion, flagFile)
            }
            fn_restart()
        }
    } else {
        done := 0
    }
    if (!done) {
        if (silent) {
            return
        }
        showGui(createErrorTipGui(i18n("update.error", 1)))
    }
}

/**
 * 当更新完成时弹出提示框，并进行配置更新
 */
checkUpdateDone() {
    if (FileExist(flagFile)) {
        SetTimer(handlePostUpdate, -500)
        handlePostUpdate() {
            for v in [flagFile, updater, logFile] {
                try FileDelete(v)
            }
            writeIni(versionKey, currentVersion)
        }
    }
}

showLog(g) {
    try {
        logContent := FileRead(logFile, "UTF-8")
        g.AddEdit("ReadOnly cGray VScroll r11 w" g.w, SubStr(logContent, InStr(logContent, "#")))
    } catch {
        g.AddText("cGray", i18n("update.logFailed"))
    }
}
