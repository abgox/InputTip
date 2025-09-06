; InputTip

baseUrl := ["https://gitee.com/abgox/InputTip/raw/main/", "https://github.com/abgox/InputTip/raw/main/"]

dirList := ["plugins", "InputTipSymbol", "InputTipSymbol/default", "InputTipCursor", "InputTipCursor/default", "InputTipCursor/default/CN", "InputTipCursor/default/EN", "InputTipCursor/default/Caps"]

for d in dirList {
    if (!DirExist(d)) {
        DirCreate(d)
    }
}

if (A_IsCompiled) {
    if (!FileExist("InputTipSymbol/default/CN.png")) {
        FileInstall("InputTipSymbol/default/CN.png", "InputTipSymbol/default/CN.png", 1)
    }
    if (!FileExist("InputTipSymbol/default/EN.png")) {
        FileInstall("InputTipSymbol/default/EN.png", "InputTipSymbol/default/EN.png", 1)
    }
    if (!FileExist("InputTipSymbol/default/Caps.png")) {
        FileInstall("InputTipSymbol/default/Caps.png", "InputTipSymbol/default/Caps.png", 1)
    }
    if (!FileExist("InputTipSymbol/default/favicon.png")) {
        FileInstall("InputTipSymbol/default/favicon.png", "InputTipSymbol/default/favicon.png", 1)
    }
    if (!FileExist("InputTipSymbol/default/favicon-pause.png")) {
        FileInstall("InputTipSymbol/default/favicon-pause.png", "InputTipSymbol/default/favicon-pause.png", 1)
    }

    if (!FileExist("InputTipCursor/default/CN/AppStarting.ani")) {
        FileInstall("InputTipCursor/default/CN/AppStarting.ani", "InputTipCursor/default/CN/AppStarting.ani", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/Arrow.cur")) {
        FileInstall("InputTipCursor/default/CN/Arrow.cur", "InputTipCursor/default/CN/Arrow.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/Cross.cur")) {
        FileInstall("InputTipCursor/default/CN/Cross.cur", "InputTipCursor/default/CN/Cross.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/Hand.cur")) {
        FileInstall("InputTipCursor/default/CN/Hand.cur", "InputTipCursor/default/CN/Hand.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/Help.cur")) {
        FileInstall("InputTipCursor/default/CN/Help.cur", "InputTipCursor/default/CN/Help.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/IBeam.cur")) {
        FileInstall("InputTipCursor/default/CN/IBeam.cur", "InputTipCursor/default/CN/IBeam.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/No.cur")) {
        FileInstall("InputTipCursor/default/CN/No.cur", "InputTipCursor/default/CN/No.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/Pen.cur")) {
        FileInstall("InputTipCursor/default/CN/Pen.cur", "InputTipCursor/default/CN/Pen.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/SizeAll.cur")) {
        FileInstall("InputTipCursor/default/CN/SizeAll.cur", "InputTipCursor/default/CN/SizeAll.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/SizeNESW.cur")) {
        FileInstall("InputTipCursor/default/CN/SizeNESW.cur", "InputTipCursor/default/CN/SizeNESW.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/SizeNS.cur")) {
        FileInstall("InputTipCursor/default/CN/SizeNS.cur", "InputTipCursor/default/CN/SizeNS.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/SizeNWSE.cur")) {
        FileInstall("InputTipCursor/default/CN/SizeNWSE.cur", "InputTipCursor/default/CN/SizeNWSE.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/SizeWE.cur")) {
        FileInstall("InputTipCursor/default/CN/SizeWE.cur", "InputTipCursor/default/CN/SizeWE.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/UpArrow.cur")) {
        FileInstall("InputTipCursor/default/CN/UpArrow.cur", "InputTipCursor/default/CN/UpArrow.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/CN/Wait.ani")) {
        FileInstall("InputTipCursor/default/CN/Wait.ani", "InputTipCursor/default/CN/Wait.ani", 1)
    }

    if (!FileExist("InputTipCursor/default/EN/AppStarting.ani")) {
        FileInstall("InputTipCursor/default/EN/AppStarting.ani", "InputTipCursor/default/EN/AppStarting.ani", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/Arrow.cur")) {
        FileInstall("InputTipCursor/default/EN/Arrow.cur", "InputTipCursor/default/EN/Arrow.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/Cross.cur")) {
        FileInstall("InputTipCursor/default/EN/Cross.cur", "InputTipCursor/default/EN/Cross.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/Hand.cur")) {
        FileInstall("InputTipCursor/default/EN/Hand.cur", "InputTipCursor/default/EN/Hand.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/Help.cur")) {
        FileInstall("InputTipCursor/default/EN/Help.cur", "InputTipCursor/default/EN/Help.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/IBeam.cur")) {
        FileInstall("InputTipCursor/default/EN/IBeam.cur", "InputTipCursor/default/EN/IBeam.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/No.cur")) {
        FileInstall("InputTipCursor/default/EN/No.cur", "InputTipCursor/default/EN/No.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/Pen.cur")) {
        FileInstall("InputTipCursor/default/EN/Pen.cur", "InputTipCursor/default/EN/Pen.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/SizeAll.cur")) {
        FileInstall("InputTipCursor/default/EN/SizeAll.cur", "InputTipCursor/default/EN/SizeAll.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/SizeNESW.cur")) {
        FileInstall("InputTipCursor/default/EN/SizeNESW.cur", "InputTipCursor/default/EN/SizeNESW.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/SizeNS.cur")) {
        FileInstall("InputTipCursor/default/EN/SizeNS.cur", "InputTipCursor/default/EN/SizeNS.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/SizeNWSE.cur")) {
        FileInstall("InputTipCursor/default/EN/SizeNWSE.cur", "InputTipCursor/default/EN/SizeNWSE.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/SizeWE.cur")) {
        FileInstall("InputTipCursor/default/EN/SizeWE.cur", "InputTipCursor/default/EN/SizeWE.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/UpArrow.cur")) {
        FileInstall("InputTipCursor/default/EN/UpArrow.cur", "InputTipCursor/default/EN/UpArrow.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/EN/Wait.ani")) {
        FileInstall("InputTipCursor/default/EN/Wait.ani", "InputTipCursor/default/EN/Wait.ani", 1)
    }

    if (!FileExist("InputTipCursor/default/Caps/AppStarting.ani")) {
        FileInstall("InputTipCursor/default/Caps/AppStarting.ani", "InputTipCursor/default/Caps/AppStarting.ani", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/Arrow.cur")) {
        FileInstall("InputTipCursor/default/Caps/Arrow.cur", "InputTipCursor/default/Caps/Arrow.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/Cross.cur")) {
        FileInstall("InputTipCursor/default/Caps/Cross.cur", "InputTipCursor/default/Caps/Cross.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/Hand.cur")) {
        FileInstall("InputTipCursor/default/Caps/Hand.cur", "InputTipCursor/default/Caps/Hand.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/Help.cur")) {
        FileInstall("InputTipCursor/default/Caps/Help.cur", "InputTipCursor/default/Caps/Help.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/IBeam.cur")) {
        FileInstall("InputTipCursor/default/Caps/IBeam.cur", "InputTipCursor/default/Caps/IBeam.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/No.cur")) {
        FileInstall("InputTipCursor/default/Caps/No.cur", "InputTipCursor/default/Caps/No.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/Pen.cur")) {
        FileInstall("InputTipCursor/default/Caps/Pen.cur", "InputTipCursor/default/Caps/Pen.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/SizeAll.cur")) {
        FileInstall("InputTipCursor/default/Caps/SizeAll.cur", "InputTipCursor/default/Caps/SizeAll.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/SizeNESW.cur")) {
        FileInstall("InputTipCursor/default/Caps/SizeNESW.cur", "InputTipCursor/default/Caps/SizeNESW.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/SizeNS.cur")) {
        FileInstall("InputTipCursor/default/Caps/SizeNS.cur", "InputTipCursor/default/Caps/SizeNS.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/SizeNWSE.cur")) {
        FileInstall("InputTipCursor/default/Caps/SizeNWSE.cur", "InputTipCursor/default/Caps/SizeNWSE.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/SizeWE.cur")) {
        FileInstall("InputTipCursor/default/Caps/SizeWE.cur", "InputTipCursor/default/Caps/SizeWE.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/UpArrow.cur")) {
        FileInstall("InputTipCursor/default/Caps/UpArrow.cur", "InputTipCursor/default/Caps/UpArrow.cur", 1)
    }
    if (!FileExist("InputTipCursor/default/Caps/Wait.ani")) {
        FileInstall("InputTipCursor/default/Caps/Wait.ani", "InputTipCursor/default/Caps/Wait.ani", 1)
    }
} else {
    fileList := [
        ; 图片
        "InputTipSymbol/default/CN.png",
        "InputTipSymbol/default/EN.png",
        "InputTipSymbol/default/Caps.png",
        "InputTipSymbol/default/favicon.png",
        "InputTipSymbol/default/favicon-pause.png",
        "img/favicon.ico",
        ; 启动脚本
        "../InputTip.bat",
        ; 脚本文件
        "./InputTip.JAB.JetBrains.ahk",
        "plugins/InputTip.plugin.ahk",
        "utils/options.ahk",
        "utils/tools.ahk",
        "utils/create-gui.ahk",
        "utils/ini.ahk",
        "utils/IME.ahk",
        "utils/app-list.ahk",
        "utils/hotkey-gui.ahk",
        "utils/var.ahk",
        "utils/check-version.ahk",
        "utils/show.ahk",
        "menu/tray-menu.ahk",
        "menu/startup.ahk",
        "menu/check-update.ahk",
        "menu/input-method.ahk",
        "menu/cursor-mode.ahk",
        "menu/bw-list.ahk",
        "menu/symbol-pos.ahk",
        "menu/app-offset.ahk",
        "menu/switch-window.ahk",
        "menu/about.ahk",
        "menu/scheme-cursor.ahk",
        "menu/scheme-symbol.ahk",
        "menu/other-config.ahk",
    ]

    missFileList := []

    for v in fileList {
        if (!FileExist(v)) {
            missFileList.Push(v)
        }
    }
    styleList := [
        "AppStarting.ani", "Arrow.cur", "Cross.cur", "Hand.cur", "Help.cur", "IBeam.cur", "No.cur", "Pen.cur", "SizeAll.cur", "SizeNESW.cur", "SizeNS.cur", "SizeNWSE.cur", "SizeWE.cur", "UpArrow.cur", "Wait.ani"
    ]
    for v in ["CN", "EN", "Caps"] {
        for s in styleList {
            p := "InputTipCursor/default/" v "/" s
            if (!FileExist(p)) {
                missFileList.Push(p)
            }
        }
    }
    if (missFileList.Length) {
        try {
            icon := A_IsPaused ? "InputTipSymbol\default\favicon-pause.png" : "InputTipSymbol\default\favicon.png"
            TraySetIcon(icon, , 1)
        }

        downloading(*) {
            g := Gui(, "InputTip - 正在处理文件丢失...")
            g.SetFont("s14", "Microsoft YaHei")
            g.AddText(, "正在下载丢失的文件: ")
            g.tip := g.AddText("xs cRed", "------------------------------------------------------------")

            g.AddText("xs", "------------------------------------------------------------")
            g.AddText("xs", "官网:")
            g.AddLink("yp", '<a href="https://inputtip.abgox.com">inputtip.abgox.com</a>')
            g.AddText("xs", "Github:")
            g.AddLink("yp", '<a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>')
            g.AddText("xs", "Gitee: :")
            g.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>')
            g.AddLink("xs", '版本更新日志:   <a href="https://inputtip.abgox.com/v2/changelog">官网</a>   <a href="https://github.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Github</a>   <a href="https://gitee.com/abgox/InputTip/blob/main/src/CHANGELOG.md">Gitee</a>')
            g.Show()
            g.OnEvent("Close", downloading)
            return g
        }
        downloadingGui := downloading()

        done := 1
        fileCount := missFileList.Length
        for i, f in missFileList {
            for u in baseUrl {
                downloadingGui.tip.Text := i '/' fileCount " : " f
                dir := RegExReplace(f, "/[^/]*$", "")
                try {
                    if (!DirExist(dir)) {
                        DirCreate(dir)
                    }
                    Download(u "src/" f, f)
                    break
                }
            }

            if (FileExist(f)) {
                if (InStr(f, ".ahk") || InStr(f, ".bat")) {
                    try {
                        if (!InStr(FileOpen(f, "r").ReadLine(), "InputTip")) {
                            done := 0
                            FileDelete(f)
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
            Run('"' A_AhkPath '" "' A_ScriptFullPath '" ' 0)
            ExitApp()
        } else {
            g := Gui(, "InputTip - 正在处理文件丢失...")
            g.SetFont("s14", "Microsoft YaHei")
            g.AddText("cRed", "可能因为网络等其他原因，文件没有正常恢复，请手动处理")
            g.AddLink("cGray", '你可以前往 <a href="https://inputtip.abgox.com">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Github</a> 手动下载')
            g.Show("Hide")
            g.GetPos(, , &_w)

            g := Gui(, "InputTip - 正在处理文件丢失...")
            g.SetFont("s12", "Microsoft YaHei")
            g.AddText("cRed", "可能因为网络等其他原因，文件没有正常恢复，请手动处理")
            g.AddLink("cGray", '你可以前往 <a href="https://inputtip.abgox.com">官网</a>   <a href="https://github.com/abgox/InputTip">Github</a>   <a href="https://gitee.com/abgox/InputTip">Github</a> 手动下载')
            g.AddButton("xs w" _w, "我知道了").OnEvent("Click", (*) => ExitApp())
            g.Show()

            while (1) {
                Sleep(5000)
            }
        }
    }
}


/**
 * 检查文件是否存在，如果不存在，从远程获取
 * @param urlPath 基于 baseUrl 的相对路径
 * @param filePath 文件路径
 */
ensureFile(urlPath, filePath) {
    if (FileExist(filePath)) {
        return
    }
    done := 0
    for u in baseUrl {
        dir := RegExReplace(filePath, "/[^/]*$", "")
        try {
            if (!DirExist(dir)) {
                DirCreate(dir)
            }
            Download(u urlPath, filePath)
            done := 1
            break
        }
    }
}

/**
 * - 检查配置文件
 * - 当配置文件不存在(无法读取 Installer 中的 init 配置项)时，进入初始化引导
 */
checkIni() {
    try {
        IniRead("InputTip.ini", "Installer", "init")
    } catch {
        gc.init := 1

        writeIni("init", 1, "Installer")

        fz := "s14"
        createGui(confirmGui).Show()
        confirmGui(info) {
            g := Gui(, "InputTip - 初始化引导")
            g.SetFont(fz, "Microsoft YaHei")
            g.AddText(, "你是否希望 InputTip 使用【鼠标方案】?")
            g.AddText("xs cRed", "InputTip 会同时使用三套不同的鼠标样式`n然后根据不同输入法状态加载对应的鼠标样式")
            g.AddLink(, '详情参考【鼠标方案】:  <a href="https://inputtip.abgox.com/v2/#鼠标方案">官网</a>   <a href="https://github.com/abgox/InputTip#鼠标方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#鼠标方案">Gitee</a>').Focus()

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddButton("xs cRed w" bw, "【是】").OnEvent("Click", e_yes)
            e_yes(*) {
                g.Destroy()
                createGui(yesGui).Show()
                yesGui(info) {
                    g := Gui()
                    g.SetFont(fz, "Microsoft YaHei")
                    g.AddText(, "你真的确定要使用【鼠标方案】吗？")
                    g.AddText("cRed", "如果误点了【是】，恢复鼠标样式需要以下步骤: `n  1. 点击【托盘菜单】中的【状态提示 - 鼠标方案】`n  2. 将【加载鼠标样式】更改为【否】")
                    g.AddLink(, '详情参考【鼠标方案】:  <a href="https://inputtip.abgox.com/v2/#鼠标方案">官网</a>   <a href="https://github.com/abgox/InputTip#鼠标方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#鼠标方案">Gitee</a>')

                    if (info.i) {
                        return g
                    }
                    w := info.w
                    bw := w - g.MarginX * 2

                    g.AddButton("xs cRed w" bw, "【是】").OnEvent("Click", e_yes)
                    e_yes(*) {
                        g.Destroy()
                        writeIni("changeCursor", 1)
                        global changeCursor := 1
                        showSymbol()
                    }
                    g.AddButton("w" bw, "【否】").OnEvent("Click", e_no)
                    e_no(*) {
                        g.Destroy()
                        writeIni("changeCursor", 0)
                        global changeCursor := 0
                        showSymbol()
                    }
                    return g
                }
            }
            _ := g.AddButton("w" bw, "【否】")
            _.OnEvent("Click", e_no)
            e_no(*) {
                g.Destroy()
                writeIni("changeCursor", 0)
                global changeCursor := 0
                showSymbol()
            }
            g.OnEvent("Close", e_exit)
            e_exit(*) {
                try {
                    IniDelete("InputTip.ini", "Installer", "init")
                }
                ExitApp()
            }
            return g
        }
        showSymbol() {
            createGui(confirmGui).Show()
            confirmGui(info) {
                g := Gui(, "InputTip - 初始化引导")
                g.SetFont(fz, "Microsoft YaHei")
                g.AddText(, "你是否希望 InputTip 使用【符号方案】?")
                g.AddText("xs cRed", "InputTip 会尝试获取输入光标位置，在其附近显示符号")
                g.AddLink(, '详情参考【符号方案】:  <a href="https://inputtip.abgox.com/v2/#符号方案">官网</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>')

                if (info.i) {
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                g.AddButton("xs cRed w" bw, "【是】").OnEvent("Click", e_yes)
                e_yes(*) {
                    g.Destroy()
                    writeIni("symbolType", 1)
                    global symbolType := 1
                    initWhiteList()
                }
                _ := g.AddButton("w" bw, "【否】")
                _.OnEvent("Click", e_no)
                e_no(*) {
                    g.Destroy()
                    writeIni("symbolType", 0)
                    global symbolType := 0
                }
                g.OnEvent("Close", e_exit)
                e_exit(*) {
                    try {
                        IniDelete("InputTip.ini", "Installer", "init")
                    }
                    ExitApp()
                }
                return g
            }
        }

        initWhiteList() {
            createGui(listTipGui).Show()
            listTipGui(info) {
                g := Gui(, "InputTip - 初始化引导")
                g.SetFont(fz, "Microsoft YaHei")
                g.AddText("cRed", "对于【符号方案】，InputTip 使用强制的白名单机制`n只有添加到【符号的白名单】中的应用进程窗口才会尝试显示符号")
                g.AddLink(, '详情参考: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">关于符号方案中的名单机制</a>')
                g.AddText(, "建议立即添加常用的应用进程窗口到【符号的白名单】中")

                if (info.i) {
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                _c := g.AddButton("w" bw, "【是】现在去添加")
                _c.OnEvent("Click", add_white_list)
                add_white_list(*) {
                    close()
                    fn_white_list()
                }
                _ := g.AddButton("w" bw, "【否】暂时不添加")
                _.OnEvent("Click", close)
                close(*) {
                    g.Destroy()
                    gc.init := 0
                    checkUpdate(1, 1)
                }
                return g
            }
        }
    }
}
