/**
 * 检查版本更新(异步)
 * @param currentVersion 当前版本号
 * @param callback 版本检查完成后的回调函数
 * @param urls 版本检查 URL 列表
 */
checkVersion(currentVersion, callback, urls := [
    "https://inputtip.pages.dev/releases/v2/version.txt",
    "https://gitee.com/abgox/InputTip/raw/main/src/v2/version.txt",
    "https://github.com/abgox/InputTip/raw/main/src/v2/version.txt"
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
                if (newVersion ~= "^[v]?[\d\.]+$" && compareVersion(newVersion, currentVersion) > 0) {
                    if (info.version) {
                        return
                    }
                    info.version := newVersion
                    info.url := url
                    callback(newVersion, url)
                }
            }
        }
    }
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
}

/**
 * 检查更新并弹出确认框
 */
checkUpdate() {
    if (!ignoreUpdate) {
        if (A_IsCompiled) {
            checkVersion(currentVersion, updateConfirm)
            updateConfirm(newVersion, url) {
                createGui(fn).Show()
                fn(x, y, w, h) {
                    g := Gui("AlwaysOnTop", A_ScriptName " - 版本更新")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText(, "InputTip 有版本更新: ")
                    g.AddText("yp cff5050", currentVersion)
                    g.AddText("yp", ">")
                    g.AddText("yp cRed", newVersion)
                    g.AddText("xs", "---------------------------------------------------------")
                    g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.pages.dev/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/v2/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/v2/CHANGELOG.md">Gitee</a>')
                    g.AddText("cRed", "点击确认更新后，会自动下载新版本替代旧版本并重启`n")
                    y := g.AddButton("xs w" bw, "确认更新")
                    y.OnEvent("Click", yes)
                    y.Focus()
                    yes(*) {
                        g.Destroy()
                        releases := [
                            "https://inputtip.pages.dev/releases/v2/InputTip.exe",
                            "https://gitee.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe",
                            "https://github.com/abgox/InputTip/releases/download/v" newVersion "/InputTip.exe"
                        ]
                        done := false
                        for v in releases {
                            try {
                                Download(v, A_AppData "\abgox-InputTip.exe")
                                ; 尝试获取版本号，成功获取则表示下载没有问题
                                done := FileGetVersion(A_AppData "\abgox-InputTip.exe")
                                break
                            }
                        }
                        if (done) {
                            if (enableJetBrainsSupport) {
                                try {
                                    RunWait('taskkill /f /t /im InputTip.JAB.JetBrains.exe', , "Hide")
                                    FileDelete("InputTip.JAB.JetBrains.exe")
                                }
                            }
                            try {
                                Run("powershell -NoProfile -Command $i=1;while (Get-Process | Where-Object { $_.Path -eq '" A_ScriptFullPath "' }) { Start-Sleep -Milliseconds 500;i++;if($i -gt 30){break}};Move-Item -Force '" A_AppData "\abgox-InputTip.exe' '" A_ScriptDir "\" A_ScriptName "';''| Out-File '" A_AppData "\.abgox-InputTip-update-version.txt' -Force;Start-Process '" A_ScriptDir "\" A_ScriptName "'", , "Hide")
                                ExitApp()
                            } catch {
                                done := false
                            }
                        }

                        if (!done) {
                            createGui(fn).Show()
                            fn(x, y, w, h) {
                                g := Gui("AlwaysOnTop")
                                g.SetFont(fz, "微软雅黑")
                                bw := w - g.MarginX * 2
                                g.AddText("cRed", "InputTip 新版本下载错误!")
                                g.AddText("xs cRed", "请手动下载最新版本的 InputTip.exe 文件并替换。")
                                g.AddText(, "--------------------------------------------------")
                                g.AddText("xs", "官网:")
                                g.AddLink("yp", '<a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
                                g.AddText("xs", "Github:")
                                g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
                                g.AddText("xs", "Gitee: :")
                                g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
                                y := g.AddButton("xs w" bw, "我知道了")
                                y.OnEvent("Click", yes)
                                y.Focus()
                                g.OnEvent("Close", yes)
                                yes(*) {
                                    g.Destroy()
                                    try {
                                        FileDelete(A_AppData "\abgox-InputTip.exe")
                                    }
                                }
                                return g
                            }
                        }
                    }
                    g.AddButton("xs w" bw, "忽略更新").OnEvent("Click", no)
                    no(*) {
                        g.Destroy()
                        global ignoreUpdate := 1
                        writeIni("ignoreUpdate", 1)
                        A_TrayMenu.Check("忽略更新")
                        showMsg(["忽略版本更新成功!", "即使有新版本，下次启动时也不会再提示更新。", "如果你在使用过程中有任何问题，首先需要确定是否为最新版本。", "如果更新到最新版本，问题依然存在，请前往 Github 发起一个 issue", "Github 和其他相关地址可以在软件托盘菜单的 「关于」 中找到"], "我知道了")
                    }
                    return g
                }
            }
        } else {
            checkVersion(currentVersion, updatePrompt)
            updatePrompt(newVersion, url) {
                createGui(fn).Show()
                fn(x, y, w, h) {
                    g := Gui("AlwaysOnTop")
                    g.SetFont(fz, "微软雅黑")
                    bw := w - g.MarginX * 2
                    g.AddText(, "- 你正在通过项目源代码启动 InputTip")
                    g.AddText("xs", "- InputTip 有版本更新:")
                    g.AddText("yp cff5050", "v" currentVersion)
                    g.AddText("yp ", ">")
                    g.AddText("yp cRed", "v" newVersion)
                    g.AddText("xs", "- 你应该使用")
                    g.AddText("yp cRed", "git pull")
                    g.AddText("yp", "拉取最新的代码更改，并重启 " A_ScriptName)
                    g.AddText("xs", "---------------------------------------------------------------------")
                    g.AddLink("xs", '项目仓库地址:   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Gitee</a>')
                    g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.pages.dev/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/v2/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/v2/CHANGELOG.md">Gitee</a>')
                    y := g.AddButton("w" bw, "我知道了")
                    y.OnEvent("Click", yes)
                    y.Focus()
                    yes(*) {
                        g.Destroy()
                    }
                    g.AddButton("xs w" bw, "忽略更新").OnEvent("Click", no)
                    no(*) {
                        g.Destroy()
                        global ignoreUpdate := 1
                        writeIni("ignoreUpdate", 1)
                        A_TrayMenu.Check("忽略更新")
                        showMsg(["忽略版本更新成功!", "即使有新版本，下次启动时也不会再提示更新。", "如果你在使用过程中有任何问题，首先需要确定是否为最新版本。", "如果更新到最新版本，问题依然存在，请前往 Github 发起一个 issue", "Github 和其他相关地址可以在软件托盘菜单的 「关于」 中找到"], "我知道了")
                    }
                    return g
                }
            }
        }
    }
}

/**
 * 当更新完成时弹出提示框
 */
checkUpdateDone() {
    if (FileExist(A_AppData "\.abgox-InputTip-update-version.txt")) {
        createGui(fn).Show()
        fn(x, y, w, h) {
            g := Gui("AlwaysOnTop", A_ScriptName " - 版本更新完成")
            g.SetFont(fz, "微软雅黑")
            g.AddText(, "版本更新完成，当前版本: ")
            g.AddText("yp cRed", currentVersion)
            g.AddText("xs", "-------------------------------------------")
            g.AddText("xs", "建议查看更新日志，了解最新变化")
            g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.pages.dev/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/v2/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/v2/CHANGELOG.md">Gitee</a>')
            y := g.AddButton("xs w" w, "我知道了")
            y.OnEvent("Click", yes)
            y.Focus()
            yes(*) {
                g.Destroy()
            }
            return g
        }
        try {
            FileDelete(A_AppData "\.abgox-InputTip-update-version.txt")
        }
    }
}
