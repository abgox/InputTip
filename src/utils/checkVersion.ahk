/**
 * 检查版本更新
 * @param currentVersion 当前版本号
 * @param {"v1" | "v2"} whichVersion 哪一个版本(v1/v2)
 */
checkVersion(currentVersion, whichVersion) {
    try {
        req := ComObject("Msxml2.XMLHTTP")
        ; 异步请求
        req.open("GET", "https://inputtip.pages.dev/releases/" whichVersion "/version.txt", true)
        req.onreadystatechange := Ready
        req.send()
        Ready() {
            if (req.readyState != 4) {
                ; 请求未完成
                return
            }
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
                return 0  ; new == old
            }
            newVersion := StrReplace(StrReplace(StrReplace(req.responseText, "`r", ""), "`n", ""), "v", "")
            if (req.status == 200 && compareVersion(newVersion, currentVersion) > 0) {
                TipGui := Gui("AlwaysOnTop OwnDialogs")
                TipGui.SetFont("s12", "微软雅黑")
                TipGui.AddLink("", '<a href="https://inputtip.pages.dev/' whichVersion '/changelog">https://inputtip.pages.dev/' whichVersion '/changelog</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md">https://github.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md">https://gitee.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md</a>')
                TipGui.Show("Hide")
                TipGui.GetPos(, , &Gui_width)
                TipGui.Destroy()

                TipGui := Gui("AlwaysOnTop OwnDialogs", A_ScriptName " - 版本更新")
                TipGui.SetFont("s12", "微软雅黑")
                TipGui.AddText(, "InputTip " whichVersion " 有新版本了!")
                TipGui.AddText(, currentVersion " => " newVersion)
                TipGui.AddText(, "从以下任意地址获取版本更新日志:")
                TipGui.AddLink("xs", '<a href="https://inputtip.pages.dev/' whichVersion '/changelog">https://inputtip.pages.dev/' whichVersion '/changelog</a>`n<a href="https://github.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md">https://github.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md</a>`n<a href="https://gitee.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md">https://gitee.com/abgox/InputTip/blob/main/src/' whichVersion '/CHANGELOG.md</a>')
                TipGui.AddText("xs", "--------------------------------------------------------------------------------------")
                TipGui.AddText("xs", "是否更新到最新版本?`n只需要确认更新，会自动下载新版本替代旧版本并重启")
                TipGui.AddButton("xs w" Gui_width, "确认更新").OnEvent("Click", yes)
                yes(*) {
                    TipGui.Destroy()
                    try {
                        Download("https://inputtip.pages.dev/releases/" whichVersion "/InputTip.exe", A_AppData "\abgox-InputTip.exe")
                        Run("powershell -NoProfile -Command Start-Sleep -Seconds 3;Move-Item -Force '" A_AppData "\abgox-InputTip.exe' '" A_ScriptDir "\" A_ScriptName "';Start-Process '" A_ScriptDir "\" A_ScriptName "'", , "Hide")
                        ExitApp()
                    } catch {
                        errGui := Gui("AlwaysOnTop OwnDialogs")
                        errGui.SetFont("s12", "微软雅黑")
                        errGui.AddText(, "InputTip " whichVersion " 新版本下载错误!")
                        errGui.AddText("xs", "手动前往官网下载最新版本!")
                        errGui.AddText(, "----------------------")
                        errGui.AddText("xs", "官网:")
                        errGui.AddLink("yp", '<a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
                        errGui.AddText("xs", "Github:")
                        errGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
                        errGui.AddText("xs", "Gitee: :")
                        errGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')
                        errGui.Show()
                    }
                }
                TipGui.AddButton("xs w" Gui_width, "忽略更新").OnEvent("Click", no)
                no(*) {
                    TipGui.Destroy()
                    global ignoreUpdate := 1
                    writeIni("ignoreUpdate", 1)
                    A_TrayMenu.Check("忽略更新")
                    showMsg(["忽略版本更新成功!","即使有新版本下次启动时也不会再提示更新!","如果你在使用过程中有任何问题，你需要确定当前是否为最新版本!","如果更新到最新版本，问题依然存在，请前往 Github 发起一个 issue","Github 和其他相关地址可以在软件托盘菜单的 `"关于`" 中找到"])
                }
                TipGui.Show()
            }
        }
    }
}
