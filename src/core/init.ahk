; InputTip

isJAB := 0
JAB_PID := ""
JABPath := A_ScriptDir "/InputTip.JAB.JetBrains.ahk"
updaterPID := "abgox.InputTip.updater.exe"
oldConfigFile := A_ScriptDir "/InputTip.ini"

#Include manifest.ahk

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

for v in ["CN", "EN", "Caps", "JP", "KR"]
    dirList.Push("temp/cursor/default-" stateVal.%v%.colorText)

if !A_IsCompiled
    dirList.Push("data/plugin")

for d in dirList {
    if !DirExist(d)
        DirCreate(d)
}

if FileExist(oldConfigFile)
    migrateConfig1(configFile, oldConfigFile)

migrateConfig2()

#Include gui.ahk
#Include i18n.ahk
#Include ini.ahk
#Include utils.ahk
#Include jab.ahk
#Include var.ahk

#Include "*i runtime.ahk"
#Include "*i ime.ahk"
#Include "*i tray-menu.ahk"
#Include "*i cursor.ahk"
#Include "*i overlay.ahk"
#Include "*i symbol.ahk"
#Include "*i border.ahk"

migrateAsset()

if A_IsCompiled {
    if !FileExist(A_Temp "/abgox.InputTip.updater.exe") || currentVersion != FileGetVersion(A_Temp "/abgox.InputTip.updater.exe")
        FileInstall("InputTip.updater.exe", A_Temp "/abgox.InputTip.updater.exe", 1)

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
    if !FileExist(pluginFile)
        FileAppend("; https://inputtip.abgox.com/docs/plugin`n", pluginFile)

    try {
        if !FileExist(runtime2) || FileGetVersion(runtime2) != FileGetVersion(runtime)
            FileCopy(runtime, runtime2, 1)
    }

    fileList := [
        ; 图标
        "temp/icon/default-app.ico",
        "temp/icon/default-app.png",
        "temp/icon/default-app-paused.png",
        ; 启动脚本
        "../InputTip.bat",
        ; 脚本文件
        "InputTip.JAB.JetBrains.ahk",
        "InputTip.updater.ahk",
        ; i18n
        "core/i18n/en-US.ahk",
        "core/i18n/zh-CN.ahk",
        "core/about.ahk",
        "core/border.ahk",
        "core/config.ahk",
        "core/core.ahk",
        "core/cursor.ahk",
        "core/gui.ahk",
        "core/i18n.ahk",
        "core/ime.ahk",
        "core/ini.ahk",
        "core/init.ahk",
        "core/input-method.ahk",
        "core/jab.ahk",
        "core/manifest.ahk",
        "core/more-settings.ahk",
        "core/overlay.ahk",
        "core/runtime.ahk",
        "core/startup.ahk",
        "core/symbol.ahk",
        "core/tray-menu.ahk",
        "core/ui.ahk",
        "core/utils.ahk",
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
    for state in stateList {
        pic := "temp/symbol/default-triangle-" stateVal.%state%.colorText ".png"
        if (!FileExist(pic)) {
            missFileList.Push("src/" pic "=" pic)
        }
        for s in styleList {
            p := "temp/cursor/default-" stateVal.%state%.colorText "/" s
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
            Run('"' runtime2 '" "' A_ScriptFullPath '" ' 0)
            ExitApp()
        }
    }
}

checkIni() {
    try {
        oldVersion := IniRead(configFile, "Settings", "version-" versionType)
        if currentVersion != oldVersion
            writeIni("version-" versionType, currentVersion)
    } catch {
        showGui(createUniqueGui(cursorGuideGui))
        cursorGuideGui(info) {
            g := createGuiOpt(i18n("init.title"))
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
                try IniDelete(configFile, "Settings", "version-" versionType)
                ExitApp()
            }
            return g
        }

        showOverlayGuide() {
            showGui(createUniqueGui(overlayGuideGui))
            overlayGuideGui(info) {
                g := Gui("-DPIScale", "InputTip - " i18n("init.title"))
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
                        IniDelete(configFile, "Settings", "version-" versionType)
                    }
                    ExitApp()
                }
                return g
            }
        }

        showDonateGui() {
            showGui(createUniqueGui(donateGui))
            donateGui(info) {
                g := Gui("-DPIScale", "InputTip - " i18n("init.title"))
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
                g.OnEvent("Close", (*) => (g.Destroy(), writeIni("version-" versionType, currentVersion)))
                return g
            }
        }
    }
}

migrateAsset() {
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
        try FileDelete(A_ScriptDir "/InputTip.ini")
    }
}

migrateConfig1(newFile, oldFile) {
    colorMap := Map(
        "ffffff", "0xFFFFFF"
    )
    for v in stateList {
        colorMap.Set(stateVal.%v%.colorText, stateVal.%v%.color)
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
        ["caretSymbolType", "symbolType"],
        ["caretSymbolOriginY", "symbolOffsetBase", , , Map(
            0, "above",
            1, "below",
        )],
        ["caretSymbolHideDelay", "hideSymbolDelay"],
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
    for v in migrateConfigList
        _migrateConfig(v*)
}

migrateConfig2() {
    renameList := [
        ["symbolType", "caretSymbolType"],
        ["symbolTextFont", "caretSymbolTextFont"],
        ["symbolTextEdgeStyle", "caretSymbolTextEdgeStyle"],
        ["symbolTextWeight", "caretSymbolTextWeight"],
        ["symbolTextTransparent", "caretSymbolTextTransparent"],
        ["symbolShapeEdgeStyle", "caretSymbolShapeEdgeStyle"],
        ["symbolTextCornerPreference", "caretSymbolTextCornerPreference"],
        ["symbolShapeCornerPreference", "caretSymbolShapeCornerPreference"],
        ["symbolOffsetBaseY", "caretSymbolOriginY"],
        ["symbolHideDelay", "caretSymbolHideDelay"],
        ["symbolNearCursorActive", "cursorSymbolType"],
        ["borderShowOnMaxScreenTop", "borderShowOnMaximizedTop"],
        ["borderShowOnMaxScreenBottom", "borderShowOnMaximizedBottom"],
        ["borderShowOnMaxScreenLeft", "borderShowOnMaximizedLeft"],
        ["borderShowOnMaxScreenRight", "borderShowOnMaximizedRight"],
    ]

    _list := [
        ["SymbolPicturePath", ""],
        ["SymbolPictureOffsetX", -40],
        ["SymbolPictureOffsetY", -5],
        ["SymbolPictureWidth", 15],
        ["SymbolPictureHeight", 15],
        ["SymbolShapeColor", ""],
        ["SymbolShapeOffsetX", 0],
        ["SymbolShapeOffsetY", 10],
        ["SymbolShapeWidth", 9],
        ["SymbolShapeHeight", 9],
        ["SymbolShapeTransparent", 255],
        ["SymbolTextContent", ""],
        ["SymbolTextBgColor", ""],
        ["SymbolTextColor", "0xFFFFFF"],
        ["SymbolTextSize", 16],
        ["SymbolTextOffsetX", 0],
        ["SymbolTextOffsetY", 0],
    ]

    for v in ["CN", "EN", "Caps", "JP", "KR"]
        for i in _list
            renameList.Push([i[1] v, "caret" i[1] v, i[2]])

    for v in renameList {
        param := [v[1], v[2]]
        if v.Length == 3
            param.Push(v[3])
        renameConfigKey(param*)
    }

    _list := [
        ["overlayTextSize", 16],
        ["overlayTextWeight", 700],
        ["overlayTransparent", 255],
    ]

    for v in [["SymbolTextFont", "Microsoft YaHei"], ["SymbolTextWeight", 700], ["SymbolTextTransparent", 255]]
        _list.Push(["caret" v[1], v[2]]), _list.Push(["cursor" v[1], v[2]])

    for v in _list {
        if val := IniRead(configFile, "Settings", v[1], "") {
            if val != v[2] {
                for _v in stateList
                    IniWrite(val, configFile, "Settings", v[1] _v)
            }
            try IniDelete(configFile, "Settings", v[1])
        }
    }

    if val := IniRead(configFile, "Settings", "symbolNearCursorWindow", "") {
        IniWrite(val == "all" ? "blacklist" : "whitelist", configFile, "Settings", "cursorSymbolShowMode")
        try IniDelete(configFile, "Settings", "symbolNearCursorWindow")
    }


    sectionList := [
        "Window.AutoSwitch.CN",
        "Window.AutoSwitch.EN",
        "Window.AutoSwitch.Caps",
        "Window.Overlay.Show",
        "Window.Overlay.Hide",
        "Window.Symbol.Show",
        "Window.Symbol.Hide",
        "Window.Symbol.Offset",
        "Window.Symbol.CursorCapture",
        "Window.Symbol.NearCursor",
        "Window.AutoPause",
        "Window.AutoExit",
        "Window.IgnoreStateSwitch",
        "Screen.Symbol.Offset"
    ]

    for v in sectionList {
        val := IniRead(configFile, v, , "")
        if !val {
            try IniDelete(configFile, v)
            continue
        }
        switch v {
            case "Window.Symbol.Offset":
                for kv in StrSplit(val, "`n") {
                    part := StrSplit(kv, "=", , 2)
                    key := part[1]
                    value := part[2]

                    valuePart := StrSplit(value, ":", , 5)
                    process := valuePart[1]

                    if process {
                        IniWrite(process, configFile, "Window.CaretSymbol.Rule." key, "process")
                    } else {
                        continue
                    }
                    matchRange := valuePart[2]
                    if matchRange == 0 {
                        conditionVal := valuePart[3] == 1 ? "titleRegex" : "titleEqual"
                        IniWrite(conditionVal, configFile, "Window.CaretSymbol.Rule." key, "condition")
                    }
                    offset := valuePart[4]
                    if offset != "" {
                        IniWrite(offset, configFile, "Window.CaretSymbol.Rule." key, "offset")
                        IniWrite("offset", configFile, "Window.CaretSymbol.Rule." key, "trigger")
                    }
                    try {
                        title := valuePart[5]
                        if title != ""
                            IniWrite(title, configFile, "Window.CaretSymbol.Rule." key, "title")
                    }
                }
            case "Screen.Symbol.Offset":
                offsetList := []
                for kv in StrSplit(val, "`n") {
                    part := StrSplit(kv, "=", , 2)
                    screen := part[1]
                    offset := part[2]
                    offsetList.Push(screen "/" offset)
                }
                if offsets := arrJoin(offsetList, "|") {
                    IniWrite(offsets, configFile, "Settings", "caretSymbolScreenOffset")
                }
            case "Window.Symbol.CursorCapture":
                for kv in StrSplit(val, "`n") {
                    part := StrSplit(kv, "=", , 2)
                    key := part[1]
                    value := part[2]

                    valuePart := StrSplit(value, ":", , 2)
                    process := valuePart[1]

                    if process {
                        IniWrite(process, configFile, "Window.CaretSymbol.Rule." key, "process")
                    } else {
                        continue
                    }
                    captureMode := valuePart[2]
                    if captureMode {
                        captureMode := captureMode == "GUI_UIA" ? "GUI>UIA" : captureMode
                        IniWrite(captureMode, configFile, "Window.CaretSymbol.Rule." key, "capture")
                        IniWrite("capture", configFile, "Window.CaretSymbol.Rule." key, "trigger")
                    }
                }
            default:
                if InStr(v, "Symbol") {
                    section := "Window.CaretSymbol.Rule."
                } else if InStr(v, "Overlay") {
                    section := "Window.Overlay.Rule."
                } else if v == "Window.Symbol.NearCursor" {
                    section := "Window.CursorSymbol.Rule."
                } else {
                    section := "Window.Rule."
                }
                for kv in StrSplit(val, "`n") {
                    part := StrSplit(kv, "=", , 2)
                    key := part[1]
                    value := part[2]

                    valuePart := StrSplit(value, ":", , 4)
                    process := valuePart[1]

                    if process {
                        IniWrite(process, configFile, section key, "process")
                    } else {
                        continue
                    }
                    matchRange := valuePart[2]
                    if matchRange == 0 {
                        conditionVal := valuePart[3] == 1 ? "titleRegex" : "titleEqual"
                        IniWrite(conditionVal, configFile, section key, "condition")
                    }
                    try {
                        title := valuePart[4]
                        if title != ""
                            IniWrite(title, configFile, section key, "title")
                    }

                    if InStr(v, ".Show") || v == "Window.Symbol.NearCursor" {
                        IniWrite("show", configFile, section key, "trigger")
                    } else if InStr(v, ".Hide") {
                        IniWrite("hide", configFile, section key, "trigger")
                    } else {
                        switch inputMethodSwitchState := IniRead(configFile, "Settings", "inputMethodSwitchState", "") {
                            case "{RShift}":
                                switchMethod := "RShift"
                            case "{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}":
                                switchMethod := "CtrlSpace"
                            case "ime":
                                switchMethod := "IME"
                            default:
                                switchMethod := "LShift"
                                if inputMethodSwitchState
                                    try IniDelete(configFile, "Settings", "inputMethodSwitchState")
                        }
                        switch v {
                            case "Window.AutoSwitch.CN":
                                IniWrite("switchStateCN-" switchMethod, configFile, section key, "trigger")
                            case "Window.AutoSwitch.EN":
                                IniWrite("switchStateEN-" switchMethod, configFile, section key, "trigger")
                            case "Window.AutoSwitch.Caps":
                                IniWrite("switchStateCaps-CapsLock", configFile, section key, "trigger")
                            case "Window.AutoPause":
                                IniWrite("pause", configFile, section key, "trigger")
                            case "Window.AutoExit":
                                IniWrite("exit", configFile, section key, "trigger")
                            case "Window.IgnoreStateSwitch":
                                IniWrite("ignoreStateSwitch", configFile, section key, "trigger")
                            default:
                        }
                    }
                }
        }

        try IniDelete(configFile, v)
    }
    migrateHotkey("hotkeyCN", "switchStateCN-LShift")
    migrateHotkey("hotkeyEN", "switchStateEN-LShift")
    migrateHotkey("hotkeyCaps", "switchStateCaps-CapsLock")
    migrateHotkey("hotkeyPause", "pause")
    migrateHotkey("hotkeyShowCode", "showStateCode")

    migrateHotkey(key, trigger) {
        if val := IniRead(configFile, "Settings", key, "") {
            id := FormatTime(A_Now, "yyyy-MM-dd") "." Format("{:05x}", Random(0, 1048575))
            IniWrite(val, configFile, "Hotkey.Rule." id, "hotkey")
            IniWrite(trigger, configFile, "Hotkey.Rule." id, "trigger")
        }
        try IniDelete(configFile, "Settings", key)
    }

    for v in [
        ["overlayShowOnWindowChange", "overlayReshowOnTitleChange"],
        ["overlayShowOnProcessChange", "overlayReshowOnProcessChange"]
    ] {
        if val := IniRead(configFile, "Settings", v[1], 0) {
            IniWrite(val, configFile, "Settings", v[2])
            try IniDelete(configFile, "Settings", v[1])
        }
    }
    val := IniRead(configFile, "Settings", "inputMethodBaseState", "")
    if IsNumber(val)
        IniWrite(val ? "CN" : "EN", configFile, "Settings", "inputMethodBaseState")

    val := IniRead(configFile, "Settings", "inputMethodDetectionRule", "")
    if val && !InStr(val, ",") {
        newVal := []
        for rule in StrSplit(val, ":") {
            part := StrSplit(rule, "*")
            newVal.Push(part[1] "," part[2] "," (part[3] ? "CN" : "EN"))
        }
        newVal := arrJoin(newVal, "|")
        IniWrite(newVal, configFile, "Settings", "inputMethodDetectionRule")
    }
}

renameConfigKey(old, new, default?, section := "Settings") {
    static sentinel := "##__NOT_FOUND__##"
    val := IniRead(configFile, section, old, sentinel)
    if val == sentinel
        return
    if IsSet(default) && val == default {
        try IniDelete(configFile, section, old)
        return
    }
    try {
        IniWrite(val, configFile, section, new)
        IniDelete(configFile, section, old)
    }
}
