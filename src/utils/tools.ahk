; InputTip

/**
 * 防抖函数
 * @param {Func} fn 要执行的函数
 * @param {Number} delay 延迟时间(ms)
 * @returns {Func} 函数
 */
debounce(fn, delay := 1000) {
    params := []
    timerFunc := (*) => fn.Call(params*)

    return (args*) => (
        params := args,
        SetTimer(timerFunc, 0),
        SetTimer(timerFunc, -delay)
    )
}

/**
 * 将数组转换成字符串，并用指定分隔符连接
 * @param {Array} arr 数组
 * @param {String} separator 分隔符
 * @returns {String} 连接后的字符串
 */
arrJoin(arr, separator := ",") {
    res := ""
    for i, v in arr {
        res .= i = arr.Length ? v : v separator
    }
    return res
}

/**
 * 检查是否存在子目录
 * @param {String} path 目录路径
 * @returns 是否存在子目录
 */
hasChildDir(path) {
    Loop Files path "\*", "D" {
        return A_Index
    }
}

/**
 * 鼠标是否悬停在指定窗口上
 * @param WinTitle  窗口标题
 * @returns 是否悬停在窗口上
 */
isMouseOver(WinTitle) {
    try {
        MouseGetPos(, , &Win)
        return WinExist(WinTitle " ahk_id " Win)
    }
    return 0
}

/**
 * 替换环境变量中的变量
 * @param {String} str 环境变量
 * @returns {String} 替换后的字符串
 */
replaceEnvVariables(str) {
    while RegExMatch(str, "%\w+%", &match) {
        env := match[]
        envValue := EnvGet(StrReplace(env, "%", ""))
        str := StrReplace(str, env, envValue)
    }
    return str
}

/**
 * 获取到屏幕信息
 * @returns {Array} 一个数组 [{num:1,left:0,top:0,right:0,bottom:0}]
 */
getScreenInfo() {
    list := []
    MonitorCount := MonitorGetCount()
    MonitorPrimary := MonitorGetPrimary()
    Loop MonitorCount
    {
        MonitorGet A_Index, &L, &T, &R, &B
        MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB
        list.Push({
            main: MonitorPrimary,
            count: MonitorCount,
            num: A_Index,
            left: L,
            top: T,
            right: R,
            bottom: B
        })
    }
    return list
}

/**
 * 激活的窗口在哪个屏幕
 */
isWhichScreen(screenList) {
    try {
        WinGetClientPos(&x, &y, &w, &h, "A")

        ; 窗口的中心坐标
        cx := x + w / 2
        cy := y + h / 2
    } catch {
        return { main: 0, count: 0, num: 0, left: 0, top: 0, right: 0, bottom: 0 }
    }

    for v in screenList {
        if (cx >= v.left && cx <= v.right && cy >= v.top && cy <= v.bottom) {
            return v
        }
    }
}

; 从字符串中提取出数字，支持负数和小数
returnNumber(value) {
    if (value = "" || !(value ~= "\d")) {
        return 0
    }
    RegExMatch(value, "(-?\d+\.?\d*)", &numbers)
    return numbers[1]
}

/**
 * 比对版本号
 * @param new 新版本号
 * @param old 旧版本号
 * @returns {1 | -1 | 0}
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

; 设置托盘图标
setTrayIcon(path) {
    if isJAB
        return

    try {
        TraySetIcon(path, , 1)
    } catch {
        if (A_IsPaused) {
            path := "InputTipSymbol\default\app-paused.png"
            global iconPaused := path
            writeIni("iconPaused", path)
        } else {
            path := "InputTipSymbol\default\app.png"
            global iconRunning := path
            writeIni("iconRunning", path)
        }
        TraySetIcon(path, , 1)
    }
}

; 返回当前的时间，作为唯一标识符
returnId() {
    return FormatTime(A_Now, "yyyy-MM-dd-HH:mm:ss") "." A_MSec
}

; 还原鼠标样式
revertCursor(cursorInfo) {
    try {
        for v in cursorInfo {
            if (v.origin) {
                DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.origin, "Ptr"), "Int", v.value)
            } else {
                ; 如果没有获取到原始的工形光标样式文件，则直接加载一个默认的样式
                if (v.type == "IBEAM") {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", "C:\Windows\Cursors\beam_m.cur", "Ptr"), "Int", v.value)
                }
            }
        }
    }
}
