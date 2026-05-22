; InputTip

isJAB := 0
JAB_PID := ""
JABPath := A_ScriptDir "/InputTip.JAB.JetBrains.ahk"

baseUrl := [
    "https://raw.giteeusercontent.com/abgox/InputTip/raw/main/",
    "https://raw.githubusercontent.com/abgox/InputTip/main/",
    "https://gh-proxy.org/https://raw.githubusercontent.com/abgox/InputTip/main/"
]

#Include "*i manifest.ahk"

#Include gui.ahk
#Include i18n.ahk
#Include ini.ahk
#Include utils.ahk
#Include jab.ahk
#Include var.ahk

if (A_IsCompiled) {
    favicon := A_ScriptFullPath
} else {
    favicon := A_ScriptDir "\temp\icon\default-app.ico"
    if (var.runCodeWithAdmin && !A_IsAdmin) {
        runAsAdmin()
    }
}

#Include "*i runtime.ahk"
#Include "*i ime.ahk"
#Include "*i tray-menu.ahk"
#Include "*i cursor.ahk"
#Include "*i overlay.ahk"
#Include "*i symbol.ahk"
#Include "*i update.ahk"

dirList := [
    "data",
    "data/icon",
    "data/symbol",
    "data/cursor",
    "temp",
    "temp/cursor",
    "temp/symbol",
    "temp/icon",
]

for v in var.stateList
    dirList.Push("temp/cursor/default-" var.stateVal.%v%.colorText)

if !A_IsCompiled
    dirList.Push("data/plugin")

for d in dirList {
    if !DirExist(d)
        DirCreate(d)
}

oldConfigFile := A_ScriptDir "/InputTip.ini"
if FileExist(oldConfigFile) {
    copyDirs := [{
        old: A_ScriptDir "/InputTipCursor",
        new: cursorDir
    }, {
        old: A_ScriptDir "/InputTipSymbol",
        new: symbolDir
    }, {
        old: A_ScriptDir "/InputTipIcon",
        new: iconDir
    }, {
        old: A_ScriptDir "/plugins",
        new: pluginDir
    }]
    for d in copyDirs {
        if DirExist(d.old) {
            try {
                DirCopy(d.old, d.new, 1)
                DirDelete(d.old, 1)
            }
            dd := d.new '/default'
            if DirExist(dd)
                try DirDelete(dd, 1)
        }
    }
    migrateConfig(configFile, oldConfigFile)
    try FileDelete(A_ScriptDir "/InputTip.ini")
}

if A_IsCompiled {
    if !FileExist("temp/icon/default-app.png")
        FileInstall("temp/icon/default-app.png", "temp/icon/default-app.png", 1)
    if !FileExist("temp/icon/default-app-paused.png")
        FileInstall("temp/icon/default-app-paused.png", "temp/icon/default-app-paused.png", 1)

    if !FileExist("temp/symbol/default-triangle-red.png")
        FileInstall("temp/symbol/default-triangle-red.png", "temp/symbol/default-triangle-red.png", 1)
    if !FileExist("temp/symbol/default-triangle-blue.png")
        FileInstall("temp/symbol/default-triangle-blue.png", "temp/symbol/default-triangle-blue.png", 1)
    if !FileExist("temp/symbol/default-triangle-green.png")
        FileInstall("temp/symbol/default-triangle-green.png", "temp/symbol/default-triangle-green.png", 1)
    if !FileExist("temp/symbol/default-triangle-yellow.png")
        FileInstall("temp/symbol/default-triangle-yellow.png", "temp/symbol/default-triangle-yellow.png", 1)
    if !FileExist("temp/symbol/default-triangle-purple.png")
        FileInstall("temp/symbol/default-triangle-purple.png", "temp/symbol/default-triangle-purple.png", 1)

    if !FileExist("temp/cursor/default-red/AppStarting.ani")
        FileInstall("temp/cursor/default-red/AppStarting.ani", "temp/cursor/default-red/AppStarting.ani", 1)
    if !FileExist("temp/cursor/default-red/Arrow.cur")
        FileInstall("temp/cursor/default-red/Arrow.cur", "temp/cursor/default-red/Arrow.cur", 1)
    if !FileExist("temp/cursor/default-red/Cross.cur")
        FileInstall("temp/cursor/default-red/Cross.cur", "temp/cursor/default-red/Cross.cur", 1)
    if !FileExist("temp/cursor/default-red/Hand.cur")
        FileInstall("temp/cursor/default-red/Hand.cur", "temp/cursor/default-red/Hand.cur", 1)
    if !FileExist("temp/cursor/default-red/Help.cur")
        FileInstall("temp/cursor/default-red/Help.cur", "temp/cursor/default-red/Help.cur", 1)
    if !FileExist("temp/cursor/default-red/IBeam.cur")
        FileInstall("temp/cursor/default-red/IBeam.cur", "temp/cursor/default-red/IBeam.cur", 1)
    if !FileExist("temp/cursor/default-red/No.cur")
        FileInstall("temp/cursor/default-red/No.cur", "temp/cursor/default-red/No.cur", 1)
    if !FileExist("temp/cursor/default-red/Pen.cur")
        FileInstall("temp/cursor/default-red/Pen.cur", "temp/cursor/default-red/Pen.cur", 1)
    if !FileExist("temp/cursor/default-red/SizeAll.cur")
        FileInstall("temp/cursor/default-red/SizeAll.cur", "temp/cursor/default-red/SizeAll.cur", 1)
    if !FileExist("temp/cursor/default-red/SizeNESW.cur")
        FileInstall("temp/cursor/default-red/SizeNESW.cur", "temp/cursor/default-red/SizeNESW.cur", 1)
    if !FileExist("temp/cursor/default-red/SizeNS.cur")
        FileInstall("temp/cursor/default-red/SizeNS.cur", "temp/cursor/default-red/SizeNS.cur", 1)
    if !FileExist("temp/cursor/default-red/SizeNWSE.cur")
        FileInstall("temp/cursor/default-red/SizeNWSE.cur", "temp/cursor/default-red/SizeNWSE.cur", 1)
    if !FileExist("temp/cursor/default-red/SizeWE.cur")
        FileInstall("temp/cursor/default-red/SizeWE.cur", "temp/cursor/default-red/SizeWE.cur", 1)
    if !FileExist("temp/cursor/default-red/UpArrow.cur")
        FileInstall("temp/cursor/default-red/UpArrow.cur", "temp/cursor/default-red/UpArrow.cur", 1)
    if !FileExist("temp/cursor/default-red/Wait.ani")
        FileInstall("temp/cursor/default-red/Wait.ani", "temp/cursor/default-red/Wait.ani", 1)

    if !FileExist("temp/cursor/default-blue/AppStarting.ani")
        FileInstall("temp/cursor/default-blue/AppStarting.ani", "temp/cursor/default-blue/AppStarting.ani", 1)
    if !FileExist("temp/cursor/default-blue/Arrow.cur")
        FileInstall("temp/cursor/default-blue/Arrow.cur", "temp/cursor/default-blue/Arrow.cur", 1)
    if !FileExist("temp/cursor/default-blue/Cross.cur")
        FileInstall("temp/cursor/default-blue/Cross.cur", "temp/cursor/default-blue/Cross.cur", 1)
    if !FileExist("temp/cursor/default-blue/Hand.cur")
        FileInstall("temp/cursor/default-blue/Hand.cur", "temp/cursor/default-blue/Hand.cur", 1)
    if !FileExist("temp/cursor/default-blue/Help.cur")
        FileInstall("temp/cursor/default-blue/Help.cur", "temp/cursor/default-blue/Help.cur", 1)
    if !FileExist("temp/cursor/default-blue/IBeam.cur")
        FileInstall("temp/cursor/default-blue/IBeam.cur", "temp/cursor/default-blue/IBeam.cur", 1)
    if !FileExist("temp/cursor/default-blue/No.cur")
        FileInstall("temp/cursor/default-blue/No.cur", "temp/cursor/default-blue/No.cur", 1)
    if !FileExist("temp/cursor/default-blue/Pen.cur")
        FileInstall("temp/cursor/default-blue/Pen.cur", "temp/cursor/default-blue/Pen.cur", 1)
    if !FileExist("temp/cursor/default-blue/SizeAll.cur")
        FileInstall("temp/cursor/default-blue/SizeAll.cur", "temp/cursor/default-blue/SizeAll.cur", 1)
    if !FileExist("temp/cursor/default-blue/SizeNESW.cur")
        FileInstall("temp/cursor/default-blue/SizeNESW.cur", "temp/cursor/default-blue/SizeNESW.cur", 1)
    if !FileExist("temp/cursor/default-blue/SizeNS.cur")
        FileInstall("temp/cursor/default-blue/SizeNS.cur", "temp/cursor/default-blue/SizeNS.cur", 1)
    if !FileExist("temp/cursor/default-blue/SizeNWSE.cur")
        FileInstall("temp/cursor/default-blue/SizeNWSE.cur", "temp/cursor/default-blue/SizeNWSE.cur", 1)
    if !FileExist("temp/cursor/default-blue/SizeWE.cur")
        FileInstall("temp/cursor/default-blue/SizeWE.cur", "temp/cursor/default-blue/SizeWE.cur", 1)
    if !FileExist("temp/cursor/default-blue/UpArrow.cur")
        FileInstall("temp/cursor/default-blue/UpArrow.cur", "temp/cursor/default-blue/UpArrow.cur", 1)
    if !FileExist("temp/cursor/default-blue/Wait.ani")
        FileInstall("temp/cursor/default-blue/Wait.ani", "temp/cursor/default-blue/Wait.ani", 1)

    if !FileExist("temp/cursor/default-green/AppStarting.ani")
        FileInstall("temp/cursor/default-green/AppStarting.ani", "temp/cursor/default-green/AppStarting.ani", 1)
    if !FileExist("temp/cursor/default-green/Arrow.cur")
        FileInstall("temp/cursor/default-green/Arrow.cur", "temp/cursor/default-green/Arrow.cur", 1)
    if !FileExist("temp/cursor/default-green/Cross.cur")
        FileInstall("temp/cursor/default-green/Cross.cur", "temp/cursor/default-green/Cross.cur", 1)
    if !FileExist("temp/cursor/default-green/Hand.cur")
        FileInstall("temp/cursor/default-green/Hand.cur", "temp/cursor/default-green/Hand.cur", 1)
    if !FileExist("temp/cursor/default-green/Help.cur")
        FileInstall("temp/cursor/default-green/Help.cur", "temp/cursor/default-green/Help.cur", 1)
    if !FileExist("temp/cursor/default-green/IBeam.cur")
        FileInstall("temp/cursor/default-green/IBeam.cur", "temp/cursor/default-green/IBeam.cur", 1)
    if !FileExist("temp/cursor/default-green/No.cur")
        FileInstall("temp/cursor/default-green/No.cur", "temp/cursor/default-green/No.cur", 1)
    if !FileExist("temp/cursor/default-green/Pen.cur")
        FileInstall("temp/cursor/default-green/Pen.cur", "temp/cursor/default-green/Pen.cur", 1)
    if !FileExist("temp/cursor/default-green/SizeAll.cur")
        FileInstall("temp/cursor/default-green/SizeAll.cur", "temp/cursor/default-green/SizeAll.cur", 1)
    if !FileExist("temp/cursor/default-green/SizeNESW.cur")
        FileInstall("temp/cursor/default-green/SizeNESW.cur", "temp/cursor/default-green/SizeNESW.cur", 1)
    if !FileExist("temp/cursor/default-green/SizeNS.cur")
        FileInstall("temp/cursor/default-green/SizeNS.cur", "temp/cursor/default-green/SizeNS.cur", 1)
    if !FileExist("temp/cursor/default-green/SizeNWSE.cur")
        FileInstall("temp/cursor/default-green/SizeNWSE.cur", "temp/cursor/default-green/SizeNWSE.cur", 1)
    if !FileExist("temp/cursor/default-green/SizeWE.cur")
        FileInstall("temp/cursor/default-green/SizeWE.cur", "temp/cursor/default-green/SizeWE.cur", 1)
    if !FileExist("temp/cursor/default-green/UpArrow.cur")
        FileInstall("temp/cursor/default-green/UpArrow.cur", "temp/cursor/default-green/UpArrow.cur", 1)
    if !FileExist("temp/cursor/default-green/Wait.ani")
        FileInstall("temp/cursor/default-green/Wait.ani", "temp/cursor/default-green/Wait.ani", 1)

    if !FileExist("temp/cursor/default-yellow/AppStarting.ani")
        FileInstall("temp/cursor/default-yellow/AppStarting.ani", "temp/cursor/default-yellow/AppStarting.ani", 1)
    if !FileExist("temp/cursor/default-yellow/Arrow.cur")
        FileInstall("temp/cursor/default-yellow/Arrow.cur", "temp/cursor/default-yellow/Arrow.cur", 1)
    if !FileExist("temp/cursor/default-yellow/Cross.cur")
        FileInstall("temp/cursor/default-yellow/Cross.cur", "temp/cursor/default-yellow/Cross.cur", 1)
    if !FileExist("temp/cursor/default-yellow/Hand.cur")
        FileInstall("temp/cursor/default-yellow/Hand.cur", "temp/cursor/default-yellow/Hand.cur", 1)
    if !FileExist("temp/cursor/default-yellow/Help.cur")
        FileInstall("temp/cursor/default-yellow/Help.cur", "temp/cursor/default-yellow/Help.cur", 1)
    if !FileExist("temp/cursor/default-yellow/IBeam.cur")
        FileInstall("temp/cursor/default-yellow/IBeam.cur", "temp/cursor/default-yellow/IBeam.cur", 1)
    if !FileExist("temp/cursor/default-yellow/No.cur")
        FileInstall("temp/cursor/default-yellow/No.cur", "temp/cursor/default-yellow/No.cur", 1)
    if !FileExist("temp/cursor/default-yellow/Pen.cur")
        FileInstall("temp/cursor/default-yellow/Pen.cur", "temp/cursor/default-yellow/Pen.cur", 1)
    if !FileExist("temp/cursor/default-yellow/SizeAll.cur")
        FileInstall("temp/cursor/default-yellow/SizeAll.cur", "temp/cursor/default-yellow/SizeAll.cur", 1)
    if !FileExist("temp/cursor/default-yellow/SizeNESW.cur")
        FileInstall("temp/cursor/default-yellow/SizeNESW.cur", "temp/cursor/default-yellow/SizeNESW.cur", 1)
    if !FileExist("temp/cursor/default-yellow/SizeNS.cur")
        FileInstall("temp/cursor/default-yellow/SizeNS.cur", "temp/cursor/default-yellow/SizeNS.cur", 1)
    if !FileExist("temp/cursor/default-yellow/SizeNWSE.cur")
        FileInstall("temp/cursor/default-yellow/SizeNWSE.cur", "temp/cursor/default-yellow/SizeNWSE.cur", 1)
    if !FileExist("temp/cursor/default-yellow/SizeWE.cur")
        FileInstall("temp/cursor/default-yellow/SizeWE.cur", "temp/cursor/default-yellow/SizeWE.cur", 1)
    if !FileExist("temp/cursor/default-yellow/UpArrow.cur")
        FileInstall("temp/cursor/default-yellow/UpArrow.cur", "temp/cursor/default-yellow/UpArrow.cur", 1)
    if !FileExist("temp/cursor/default-yellow/Wait.ani")
        FileInstall("temp/cursor/default-yellow/Wait.ani", "temp/cursor/default-yellow/Wait.ani", 1)

    if !FileExist("temp/cursor/default-purple/AppStarting.ani")
        FileInstall("temp/cursor/default-purple/AppStarting.ani", "temp/cursor/default-purple/AppStarting.ani", 1)
    if !FileExist("temp/cursor/default-purple/Arrow.cur")
        FileInstall("temp/cursor/default-purple/Arrow.cur", "temp/cursor/default-purple/Arrow.cur", 1)
    if !FileExist("temp/cursor/default-purple/Cross.cur")
        FileInstall("temp/cursor/default-purple/Cross.cur", "temp/cursor/default-purple/Cross.cur", 1)
    if !FileExist("temp/cursor/default-purple/Hand.cur")
        FileInstall("temp/cursor/default-purple/Hand.cur", "temp/cursor/default-purple/Hand.cur", 1)
    if !FileExist("temp/cursor/default-purple/Help.cur")
        FileInstall("temp/cursor/default-purple/Help.cur", "temp/cursor/default-purple/Help.cur", 1)
    if !FileExist("temp/cursor/default-purple/IBeam.cur")
        FileInstall("temp/cursor/default-purple/IBeam.cur", "temp/cursor/default-purple/IBeam.cur", 1)
    if !FileExist("temp/cursor/default-purple/No.cur")
        FileInstall("temp/cursor/default-purple/No.cur", "temp/cursor/default-purple/No.cur", 1)
    if !FileExist("temp/cursor/default-purple/Pen.cur")
        FileInstall("temp/cursor/default-purple/Pen.cur", "temp/cursor/default-purple/Pen.cur", 1)
    if !FileExist("temp/cursor/default-purple/SizeAll.cur")
        FileInstall("temp/cursor/default-purple/SizeAll.cur", "temp/cursor/default-purple/SizeAll.cur", 1)
    if !FileExist("temp/cursor/default-purple/SizeNESW.cur")
        FileInstall("temp/cursor/default-purple/SizeNESW.cur", "temp/cursor/default-purple/SizeNESW.cur", 1)
    if !FileExist("temp/cursor/default-purple/SizeNS.cur")
        FileInstall("temp/cursor/default-purple/SizeNS.cur", "temp/cursor/default-purple/SizeNS.cur", 1)
    if !FileExist("temp/cursor/default-purple/SizeNWSE.cur")
        FileInstall("temp/cursor/default-purple/SizeNWSE.cur", "temp/cursor/default-purple/SizeNWSE.cur", 1)
    if !FileExist("temp/cursor/default-purple/SizeWE.cur")
        FileInstall("temp/cursor/default-purple/SizeWE.cur", "temp/cursor/default-purple/SizeWE.cur", 1)
    if !FileExist("temp/cursor/default-purple/UpArrow.cur")
        FileInstall("temp/cursor/default-purple/UpArrow.cur", "temp/cursor/default-purple/UpArrow.cur", 1)
    if !FileExist("temp/cursor/default-purple/Wait.ani")
        FileInstall("temp/cursor/default-purple/Wait.ani", "temp/cursor/default-purple/Wait.ani", 1)
} else {
    pluginFile := "data/plugin/InputTip.plugin.ahk"
    if (!FileExist(pluginFile)) {
        FileAppend("; https://inputtip.abgox.com/docs/plugin`n", pluginFile)
    }

    fileList := [
        ; 图标
        "temp/icon/default-app.ico",
        "temp/icon/default-app.png",
        "temp/icon/default-app-paused.png",
        ; 启动脚本
        "../InputTip.bat",
        ; 脚本文件
        "./InputTip.JAB.JetBrains.ahk",
        ; i18n
        "i18n/zh-CN.ahk",
        "i18n/en-US.ahk",
        "core/about.ahk",
        "core/input-method.ahk",
        "core/more-settings.ahk",
        "core/startup.ahk",
        "core/tray-menu.ahk",
        "core/update.ahk",
        "core/config.ahk",
        "core/core.ahk",
        "core/gui.ahk",
        "core/cursor.ahk",
        "core/i18n.ahk",
        "core/ime.ahk",
        "core/ini.ahk",
        "core/jab.ahk",
        "core/manifest.ahk",
        "core/overlay.ahk",
        "core/symbol.ahk",
        "core/runtime.ahk",
        "core/ui.ahk",
        "core/var.ahk",
    ]

    missFileList := []

    for v in fileList {
        if (!FileExist(v)) {
            missFileList.Push("src/" v "=" v)
        }
    }
    styleList := [
        "AppStarting.ani", "Arrow.cur", "Cross.cur", "Hand.cur", "Help.cur", "IBeam.cur", "No.cur", "Pen.cur", "SizeAll.cur", "SizeNESW.cur", "SizeNS.cur", "SizeNWSE.cur", "SizeWE.cur", "UpArrow.cur", "Wait.ani"
    ]
    for state in var.stateList {
        pic := "temp/symbol/default-triangle-" var.stateVal.%state%.colorText ".png"
        if (!FileExist(pic)) {
            missFileList.Push("src/" pic "=" pic)
        }
        for s in styleList {
            p := "temp/cursor/default-" var.stateVal.%state%.colorText "/" s
            if (!FileExist(p)) {
                missFileList.Push("src/" p "=" p)
            }
        }
    }
    if (missFileList.Length) {
        try {
            icon := defaultIconDir "\default-app"
            if (A_IsPaused)
                icon .= "-paused"
            TraySetIcon(icon ".png", , 1)
        }
        done := showDownloadProcessGui("missingFile.downloading", missFileList)
        if (done) {
            Run('"' A_AhkPath '" "' A_ScriptFullPath '" ' 0)
            ExitApp()
        }
    }
}

updateAppOffset()
updateScreenOffset()
updateCursorMode()

updateAppOffset() {
    for v in var.windowSymbolOffset {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 5)
        if (part.Length >= 2) {
            name := part[1]
            isGlobal := part[2]
            isRegex := ""
            title := ""
            offset := ""
            if (part.Length == 5) {
                isRegex := part[3]
                offset := part[4]
                title := part[5]
            }
            key := isGlobal ? name : name title
            var.windowSymbolOffsetVal.%key% := {}
            for v in StrSplit(offset, "|") {
                if (v) {
                    p := StrSplit(v, "/")
                    try {
                        var.windowSymbolOffsetVal.%key%.%p[1]% := { x: p[2], y: p[3] }
                    } catch {
                        var.windowSymbolOffsetVal.%key%.%p[1]% := { x: 0, y: 0 }
                    }
                }
            }
        }
    }
}

updateScreenOffset() {
    for v in var.screenSymbolOffset {
        kv := StrSplit(v, "=")
        part := StrSplit(kv[2], "/")
        try {
            var.screenSymbolOffsetVal.%kv[1]% := { x: part[1], y: part[2] }
        } catch {
            var.screenSymbolOffsetVal.%kv[1]% := { x: 0, y: 0 }
        }
    }
}

updateCursorMode() {
    modeList := {}
    for v in var.modeNameList {
        modeList.%v% := Map()
    }
    for v in var.WindowSymbolCursorCapture {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(RegExReplace(kv[2], ":$", ""), ":", , 2)
        try modeList.%part[2]%.Set(part[1], 1)
    }
    var.modeList := modeList
}

checkIni() {
    try {
        IniRead(configFile, "Settings", "init")
        checkUpdateDone()
    } catch {
        gc.init := 1
        showGui(createUniqueGui(cursorGuideGui))
        cursorGuideGui(info) {
            g := Gui(, "InputTip - " i18n("init.title"))
            g.SetFont(fontOpt*)
            for i, v in i18n("init.cursor", 1) {
                if (i == 1) {
                    g.AddLink(, v)
                } else {
                    g.AddText("xs cRed", v).Focus()
                }
            }

            if (info.i) {
                return g
            }
            w := info.w
            bw := w - g.MarginX * 2

            g.AddButton("xs w" bw, i18n("yes")).OnEvent("Click", e_yes)
            e_yes(*) {
                g.Destroy()
                changeConfig("cursorActive", 1)
                showOverlayGuide()
            }
            g.AddButton("w" bw, i18n("no")).OnEvent("Click", e_no)
            e_no(*) {
                g.Destroy()
                changeConfig("cursorActive", 0)
                showOverlayGuide()
            }
            g.OnEvent("Close", e_exit)
            e_exit(*) {
                try IniDelete(configFile, "Settings", "init")
                ExitApp()
            }
            return g
        }

        showOverlayGuide() {
            showGui(createUniqueGui(overlayGuideGui))
            overlayGuideGui(info) {
                g := Gui(, "InputTip - " i18n("init.title"))
                g.SetFont(fontOpt*)
                for i, v in i18n("init.overlay", 1) {
                    if (i == 1) {
                        g.AddLink(, v)
                    } else {
                        g.AddText("xs cRed", v).Focus()
                    }
                }

                if (info.i) {
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                g.AddButton("xs cRed w" bw, i18n("yes")).OnEvent("Click", e_yes)
                e_yes(*) {
                    g.Destroy()
                    changeConfig("overlayActive", 1)
                    showDonateGui()
                }
                _ := g.AddButton("w" bw, i18n("no"))
                _.OnEvent("Click", e_no)
                e_no(*) {
                    g.Destroy()
                    changeConfig("overlayActive", 0)
                    showDonateGui()
                }
                g.OnEvent("Close", e_exit)
                e_exit(*) {
                    try {
                        IniDelete(configFile, "Settings", "init")
                    }
                    ExitApp()
                }
                return g
            }
        }

        showDonateGui() {
            showGui(createUniqueGui(donateGui))
            donateGui(info) {
                g := Gui(, "InputTip - " i18n("init.title"))
                g.SetFont(fontOpt*)
                for i, v in i18n("init.donate", 1) {
                    if (i <= 2) {
                        g.AddLink(, v)
                    } else {
                        g.AddText("xs cRed", v).Focus()
                    }
                }

                if (info.i) {
                    return g
                }
                w := info.w
                bw := w - g.MarginX * 2

                g.AddButton("xs cRed w" bw, i18n("goToRepo")).OnEvent("Click", (*) => Run("https://github.com/abgox/InputTip"))
                g.AddButton("w" bw, i18n("goToDonate")).OnEvent("Click", (*) => Run("https://www.abgox.com/donate"))
                g.OnEvent("Close", (*) => (g.Destroy(), done()))
                return g
            }
        }
        done() {
            writeIni("init", A_Now, "Settings")
            writeIni(versionKey, currentVersion)
        }
    }
}

migrateConfig(newFile, oldFile) {
    colorMap := Map(
        "ffffff", "0xFFFFFF"
    )
    for v in var.stateList {
        colorMap.Set(var.stateVal.%v%.colorText, var.stateVal.%v%.color)
    }
    _migrateConfig(newKey := "", oldKey := "", newSection := "Settings", oldSection := "Config-v2", valueMap := Map()) {
        if (newKey) {
            try {
                oldVal := IniRead(oldFile, oldSection, oldKey)
                switch oldKey {
                    case "iconRunning", "iconPaused":
                        newVal := StrReplace(oldVal, "InputTipIcon\default", "default-")
                        newVal := StrReplace(newVal, "InputTipIcon\", "data\icon\")
                    case "CN_cursor", "EN_cursor", "Caps_cursor":
                        newVal := StrReplace(oldVal, "InputTipCursor\default\oreo-", "default-")
                        newVal := StrReplace(newVal, "InputTipCursor\", "data\cursor\")
                    case "CN_pic", "EN_pic", "Caps_pic":
                        newVal := StrReplace(oldVal, "InputTipSymbol\default\triangle-", "default-triangle-")
                        newVal := StrReplace(newVal, "InputTipSymbol\", "data\symbol\")
                    default:
                        if (valueMap.Count) {
                            newVal := valueMap.Get(oldVal)
                        } else {
                            newVal := oldVal
                        }
                }
                if InStr(oldKey, "color") && colorMap.Has(oldVal)
                    newVal := colorMap.Get(oldVal)

                IniWrite(newVal, newFile, newSection, newKey)
            }
        } else {
            try {
                oldVal := IniRead(oldFile, oldSection)
                if (valueMap.Count) {
                    newVal := valueMap.Get(oldVal)
                } else {
                    newVal := oldVal
                }
                IniWrite(newVal, newFile, newSection)
            }
        }
    }

    migrateConfigList := [
        ["updateCheckInterval", "checkUpdateDelay"],
        ["silentUpdate", "silentUpdate"],
        ["runCodeWithAdmin", "runCodeWithAdmin"],
        ["pollInterval", "delay"],
        ["launchAtStartup", "isStartup"],
        ["symbolJABActive", "enableJABSupport"],
        ["enableKeyStats", "enableKeyCount"],
        ["iconRunning", "iconRunning"],
        ["iconPaused", "iconPaused"],
        ["trayTipTemplate", "trayTipTemplate"],
        ["keyStatsTemplate", "keyCountTemplate"],
        ; InputMethod
        ["inputMethodDetectionMode", "mode", , "InputMethod", Map(
            1, "general",
            0, "custom"
        )],
        ["inputMethodDetectionRule", "modeRule", , "InputMethod"],
        ["inputMethodBaseState", "baseStatus", , "InputMethod"],
        ["keepCapsLockWhenStateSwitch", "keepCapsLock"],
        ["exportState", "exportState"],
        ["inputMethodSwitchState", "switchStatus", , , Map(
            0, "ime",
            1, "{LShift}",
            2, "{RShift}",
            3, "{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}"
        )],
        ; HotKey
        ["hotkeyCN", "hotkey_CN"],
        ["hotkeyEN", "hotkey_EN"],
        ["hotkeyCaps", "hotkey_Caps"],
        ["hotkeyShowCode", "hotkey_ShowCode"],
        ["installSource", "from", , "Installer"],
        ; Cursor
        ["cursorActive", "changeCursor"],
        ; Symbol
        ["symbolType", "symbolType"],
        ["symbolOffsetBaseY", "symbolOffsetBase", , , Map(
            0, "above",
            1, "below",
        )],
        ["symbolHideDelay", "hideSymbolDelay"],
        ["symbolNearCursorWindow", "showCursorPos"],
        ["symbolNearCursorOffsetX", "showCursorPos_x"],
        ["symbolNearCursorOffsetY", "showCursorPos_y"],
        ; Other
        [, , "Window.Symbol.NearCursor", "ShowNearCursor"],
        [, , "Window.Symbol.Show", "App-ShowSymbol"],
        [, , "Window.Symbol.Hide", "App-HideSymbol"],
        [, , "Window.Symbol.CursorCapture", "InputCursorMode"],
        [, , "Screen.Symbol.Offset", "App-Offset-Screen"],
        [, , "Window.Symbol.Offset", "App-Offset"],
        [, , "Window.AutoExit", "App-Auto-Exit"],
        [, , "Window.IgnoreStateSwitch", "App-IgnoreHotKey"],
    ]

    for v in ["CN", "EN", "Caps"] {
        migrateConfigList.Push([, , "Window.AutoSwitch." v, "App-" v])
        migrateConfigList.Push(["cursorPath" v, v "_cursor"])
        migrateConfigList.Push(["symbolPicturePath" v, v "_pic"])
        migrateConfigList.Push(["symbolShapeColor" v, v "_color"])
        migrateConfigList.Push(["symbolTextContent" v, v "_Text"])
        items := {
            Pic: [
                ["symbolPictureOffsetX", "pic_offset_x"],
                ["symbolPictureOffsetY", "pic_offset_y"],
                ["symbolPictureWidth", "pic_symbol_width"],
                ["symbolPictureHeight", "pic_symbol_height"]
            ],
            Block: [
                ["symbolShapeOffsetX", "offset_x"],
                ["symbolShapeOffsetY", "offset_y"],
                ["symbolShapeWidth", "symbol_width"],
                ["symbolShapeHeight", "symbol_height"],
                ["symbolShapeTransparent", "transparent"],
                ["symbolShapeEdgeStyle", "border_type"]
            ],
            Text: [
                ["symbolTextOffsetX", "textSymbol_offset_x"],
                ["symbolTextOffsetY", "textSymbol_offset_y"],
                ["symbolTextFont", "font_family"],
                ["symbolTextSize", "font_size"],
                ["symbolTextWeight", "font_weight"],
                ["symbolTextColor", "font_color"],
                ["symbolTextBgColor", "textSymbol_CN_color"],
                ["symbolTextTransparent", "textSymbol_transparent"],
                ["symbolTextEdgeStyle", "textSymbol_border_type"]
            ]
        }
        for t in ["Pic", "Block", "Text"] {
            isolate := 0
            try isolate := IniRead(oldFile, "Config-v2", "enableIsolateConfig" t)
            for i in items.%t% {
                if isolate
                    i[1] := i[1] v
                migrateConfigList.Push(i)
            }
        }
        migrateConfigList.Push(["symbolTextBgColor" v, "textSymbol_" v "_color"])
    }
    for v in migrateConfigList {
        _migrateConfig(v*)
    }
}
