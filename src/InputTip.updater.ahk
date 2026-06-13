; InputTip

#NoTrayIcon

#Include core\manifest.ahk

;@Ahk2Exe-SetMainIcon temp\icon\default-app.ico
;@AHK2Exe-SetName InputTip.updater
;@Ahk2Exe-SetOrigFilename InputTip.updater
;@AHK2Exe-SetDescription InputTip.updater

#Include core\config.ahk
#Include core\gui.ahk
#Include core\i18n.ahk
#Include core\ini.ahk
#Include core\utils.ahk
#Include core\var.ahk

try TraySetIcon(A_ScriptDir "\temp\icon\default-app.png", , 1)

if A_IsCompiled {
    logFile := A_ScriptDir "\abgox.InputTip-CHANGELOG.md"
} else {
    logFile := A_Temp "\abgox.InputTip-CHANGELOG.md"
}

keyCount := 0
precessId := ""
updater := ""

try keyCount := A_Args[1]
try precessId := A_Args[2]
try updater := A_Args[3]

updater == "getRepoCode" ? getRepoCode() : checkUpdate()

gc.updateGui := 0

SetTimer(() => gc.updateGui ? 0 : ExitApp(), -60000)

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

checkUpdate() {
    if (A_IsCompiled) {
        checkVersion(currentVersion, updateConfirm)
        updateConfirm(newVersion, url) {
            if (gc.updateGui || !hasNewVersion(newVersion, currentVersion)) {
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

                downloadingGui(info, *) {
                    g := createGuiOpt(i18n("updateCheck"), , "AlwaysOnTop Disabled")
                    if (info.i) {
                        g.AddText(, line60)
                        return g
                    }
                    g.AddText("Center w" info.w, i18n("update.downloading"))
                    g.process := g.AddProgress("xm h12 w" info.w, 1)
                    return g
                }
                dlGui := createUniqueGui(downloadingGui)
                showGui(dlGui, "NoActivate")
                SetTimer(() => (dlGui.process.Value < 90 ? dlGui.process.Value += 2 : ""), 500)

                out := updater ".new"
                for v in releases {
                    try {
                        Download(v, out)
                        ; 尝试获取版本号，成功获取则表示下载没有问题
                        done := FileGetVersion(out)
                        break
                    }
                }
                dlGui.Destroy()
                if (done) {
                    try {
                        ProcessClose(precessId)
                        ProcessWaitClose(precessId, 10)
                        FileMove(out, updater, 1)
                        try FileDelete(logFile)
                        Run('"' updater '" ' keyCount, , "Hide")
                        ExitApp()
                    } catch {
                        done := false
                    }
                }
                return done
            }
            try {
                Download(StrReplace(url, "/versions.txt", "/CHANGELOG.md"), logFile)
                showGui(createUniqueGui(updateGui), , 0)
                updateGui(info) {
                    g := createGuiOpt(i18n("updateVersion"))

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
                    g.AddButton("xs w" w, i18n("update.cancel")).OnEvent("Click", (*) => ExitApp())
                    g.OnEvent("Close", (*) => (fn_close(), ExitApp()))
                    fn_close(*) {
                        g.Destroy()
                        gc.updateGui := ""
                    }
                    gc.updateGui := g
                    return g
                }
            }
        }
    } else {
        checkVersion(currentVersion, updatePrompt)
        updatePrompt(newVersion, url) {
            if (gc.updateGui || !hasNewVersion(newVersion, currentVersion)) {
                return
            }
            try {
                Download(StrReplace(url, "/versions.txt", "/CHANGELOG.md"), logFile)
                showGui(createUniqueGui(fn))
                fn(info) {
                    g := createGuiOpt(i18n("updateVersion"), , "AlwaysOnTop")
                    if (info.i) {
                        g.AddText(, line80)
                        return g
                    }
                    g.w := w := info.w
                    g.bw := bw := w - g.MarginX * 2

                    showLog(g)

                    g.AddButton("xs w" w, i18n("update.confirm")).OnEvent("Click", (*) => (fn_close(), getRepoCode()))
                    g.AddButton("xs w" w, i18n("update.cancel")).OnEvent("Click", (*) => ExitApp())
                    g.OnEvent("Close", (*) => (fn_close(), ExitApp()))
                    g.OnEvent("Close", fn_close)
                    fn_close(*) {
                        g.Destroy()
                        gc.updateGui := ""
                    }
                    gc.updateGui := g
                    return g
                }
            }
        }
    }
}

; 下载最新的源代码文件
getRepoCode() {
    ; 是否成功下载 files.ini
    downloadIni := 0
    out := A_ScriptDir "\files.ini"
    try FileDelete(out)
    for u in baseUrl {
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
        done := showDownloadProcessGui(i18n("update.downloading"), StrSplit(IniRead(out, "files"), "`n"), "updateVersion")
        if (done) {
            try FileDelete(logFile)
            Run('"' A_AhkPath '" "' A_ScriptDir '\InputTip.ahk" ' keyCount)
        }
    } else {
        done := 0
    }
    if (!done) {
        showGui(createErrorTipGui(i18n("update.error", 1)))
    }
}

showLog(g) {
    g.SetFont("s14")
    try {
        logContent := FileRead(logFile, "UTF-8")
        g.AddEdit("ReadOnly cGray VScroll r11 w" g.w, SubStr(logContent, InStr(logContent, "#")))
    } catch {
        g.AddText("cGray", i18n("update.logFailed"))
    }
    g.SetFont("s16")
}
