; InputTip

runAsAdmin() {
    try {
        Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '" ' keyCount)
    } catch {
        showGui(createErrorTipGui(i18n("runCodeWithAdmin.error", 1), i18n("runCodeWithAdmin")))
        changeConfig("runCodeWithAdmin", 0)
    }
}

setTrayIcon(path, isPaused := A_IsPaused) {
    if isJAB
        return

    runningIcon := "default-app.png"
    pausedIcon := "default-app-paused.png"
    default := Map(
        runningIcon, 1,
        pausedIcon, 1
    )
    if default.Has(path) {
        path := defaultIconDir "\" path
    } else {
        path := iconDir "\" path
    }
    try {
        TraySetIcon(path, , 1)
    } catch {
        if (isPaused) {
            changeConfig("iconPaused", pausedIcon, 1)
            path := pausedIcon
        } else {
            changeConfig("iconRunning", runningIcon, 1)
            path := runningIcon
        }
        TraySetIcon(defaultIconDir "\" path, , 1)
    }
}

createShortcut(dir) {
    if InStr(dir, A_Desktop) {
        fileLnk := A_Desktop "\" appname
    } else if InStr(dir, A_Startup) {
        fileLnk := A_Startup "\" appid
    } else {
        fileLnk := dir "\" appid
    }
    fileLnk .= ".lnk"
    if (var.launchAtStartup == 1) {
        FileCreateShortcut("C:\WINDOWS\system32\schtasks.exe", fileLnk, , "/run /tn `"" taskNameNoUAC "`"", i18n("desc"), favicon, , , 7)
    } else {
        if (A_IsCompiled) {
            FileCreateShortcut(A_ScriptFullPath, fileLnk, , , i18n("desc"), favicon, , , 7)
        } else {
            FileCreateShortcut(A_AhkPath, fileLnk, , "`"" A_ScriptFullPath "`"", i18n("desc"), favicon, , , 7)
        }
    }
}

updateTrayTip(flag := "") {
    if (var.enableKeyStats) {
        if (flag != "") {
            tip := StrReplace(var.trayTipTemplate var.keyStatsTemplate, "%appState%", flag ? i18n("state.Paused") : i18n("state.Running"))
            tip := StrReplace(tip, "%keyCount%", keyCount)
            tip := StrReplace(tip, "%\n%", "`n")
            A_IconTip := tip
            return
        }
        SetTimer(countTimer, 50)
        countTimer() {
            static last := ""
            global keyCount
            if (!var.enableKeyStats) {
                SetTimer(, 0)
                last := ""
                return
            }
            if (A_PriorKey != last) {
                keyCount++
                last := A_PriorKey
                tip := StrReplace(var.trayTipTemplate var.keyStatsTemplate, "%appState%", A_IsPaused ? i18n("state.Paused") : i18n("state.Running"))
                tip := StrReplace(tip, "%keyCount%", keyCount)
                tip := StrReplace(tip, "%\n%", "`n")
                A_IconTip := tip
            }
        }
    } else {
        s := flag != "" ? flag : A_IsPaused
        tip := StrReplace(var.trayTipTemplate, "%appState%", s ? i18n("state.Paused") : i18n("state.Running"))
        tip := StrReplace(tip, "%\n%", "`n")
        A_IconTip := tip
    }
}


getPicList(picDir, defaultList := []) {
    listMap := Map()
    Loop Files picDir "\*", "R" {
        p := StrReplace(A_LoopFilePath, picDir "\", "")
        if A_LoopFileExt == "png" && !listMap.Has(A_LoopFilePath)
            listMap.Set(p, 1)
    }
    list := defaultList
    for path in listMap
        list.Push(path)
    return list
}

pickColor(hwnd, colorKey) {
    color := var.%colorKey%
    if (!InStr(color, "0x")) {
        color := "0xffffff"
    }
    result := colorDialog(color, hwnd, , true)
    if (result != -1) {
        return result
    }
    return ""
}

/**
 * 颜色选择器
 * @param {Number} Color 起始颜色，格式 0xRRGGBB
 * @param {Number} hwnd 父窗口句柄
 * @param {Array} &colorObj 自定义颜色数组（最多16个），可保存用户自定义颜色
 * @param {Boolean} disp true=完整面板 / false=基础面板
 * @link https://www.autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/
 */
colorDialog(Color := 0, hwnd := 0, &custColors?, disp := false) {
    Static p := A_PtrSize
    disp := disp ? 0x3 : 0x1

    if !IsSet(custColors) || !IsObject(custColors)
        custColors := []

    if (custColors.Length > 16)
        throw Error("Too many custom colors. The maximum allowed values is 16.")

    loop (16 - custColors.Length)
        custColors.Push(0)

    CUSTOM := Buffer(16 * 4, 0)
    CHOOSECOLOR := Buffer((p == 4) ? 36 : 72, 0)

    loop 16 {
        NumPut("UInt", RGB_BGR(custColors[A_Index]), CUSTOM, (A_Index - 1) * 4)
    }

    NumPut("UInt", CHOOSECOLOR.Size, CHOOSECOLOR, 0)  ; lStructSize
    NumPut("UPtr", hwnd, CHOOSECOLOR, p)  ; hwndOwner
    NumPut("UInt", RGB_BGR(Color), CHOOSECOLOR, 3 * p)  ; rgbResult
    NumPut("UPtr", CUSTOM.Ptr, CHOOSECOLOR, 4 * p)  ; lpCustColors
    NumPut("UInt", disp, CHOOSECOLOR, 5 * p)  ; Flags

    if !DllCall("comdlg32\ChooseColor", "UPtr", CHOOSECOLOR.Ptr, "UInt")
        return -1

    custColors := []
    loop 16 {
        custColors.InsertAt(A_Index, RGB_BGR(NumGet(CUSTOM, (A_Index - 1) * 4, "UInt")))
    }

    Color := NumGet(CHOOSECOLOR, 3 * p, "UInt")
    return Format("0x{:06X}", RGB_BGR(Color))

    RGB_BGR(c) {
        return ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }
}
