; InputTip

/**
 * 防抖函数
 * @param {Func} fn 要执行的函数
 * @param {Number} delay 延迟时间(ms)
 * @returns {Func} 函数
 */
debounce(fn, delay := 1000) {
    state := { params: [], timer: 0 }
    callback := (*) => fn.Call(state.params*)
    return (args*) => (
        state.params := args,
        state.timer ? SetTimer(callback, 0) : 0,
        state.timer := 1,
        SetTimer(callback, -delay)
    )
}

arrJoin(arr, separator := "", filterEmpty := 0) {
    res := ""
    for i, v in arr {
        if filterEmpty && v == ""
            continue
        res .= res == "" ? v : separator v
    }
    return res
}

indexOfArr(arr, val) {
    for i, v in arr {
        if v == val
            return i
    }
    return 0
}

pathToUrl(path) {
    return StrReplace(path, "\", "/")
}

/**
 * 检查指定目录下是否存在子项
 * @param {String} path 要检查的目录路径
 * @param {"F"|"D"} type Loop Files 的模式标志
 * @returns {1|0}
 */
hasChild(path, type := "F") {
    Loop Files path "\*", type
        return A_Index
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

; 从 Map 中通过 value 获取 key
MapKeyOf(map, value) {
    for k, v in map {
        if v = value
            return k
    }
    return ""
}

safeRegexMatch(Haystack, NeedleRegEx) {
    try {
        return RegExMatch(Haystack, NeedleRegEx)
    } catch {
        return 0
    }
}

; 从字符串中提取出数字，支持负数和小数
returnNumber(value) {
    if (value == "" || !(value ~= "\d")) {
        return 0
    }
    RegExMatch(value, "(-?\d+\.?\d*)", &numbers)
    return Number(numbers[1])
}

returnMaxTimerNumber(num) {
    if !IsNumber(num)
        return 0
    return Min(num, 4294967295)
}


; 将 RGB 转换为 Windows 底层认识的 BGR (COLORREF) 格式
RGBtoBGR(rgb) {
    ; 输入示例: 0xFF2600
    r := (rgb >> 16) & 0xFF
    g := (rgb >> 8) & 0xFF
    b := rgb & 0xFF
    return (b << 16) | (g << 8) | r
}

; 让 Tab 控件对 Link 失去默认聚焦
loseFocusOnTab(tab) {
    try tab.OnEvent("Change", (ctrl, *) => ControlFocus(ctrl.Hwnd, ctrl.Gui.Hwnd))
}

applyTransparency(hwnd, transparency := "Off") {
    if transparency == ''
        return
    try WinSetTransparent(transparency, hwnd)
}

/**
 * 创建/更新任务计划程序
 * @param {String} path 要执行的应用程序
 * @param {String} taskName 任务计划名称
 * @param {Array} args 运行参数
 * @param {"Highest"|"Limited"} runLevel 运行级别
 * @param {1|0} isWait 是否等待完成
 * @param {1|0} needStartUp 是否需要开机启动
 * @returns {1|0} 是否创建成功
 */
createScheduleTask(path, taskName, args := [], runLevel := "Highest", isWait := 0, needStartUp := 0, *) {
    if (A_IsAdmin) {
        cmd := '$action = New-ScheduledTaskAction -Execute "' path '" '
        if (args.Length) {
            cmd .= "-Argument '"
            for v in args {
                cmd .= '"' v '" '
            }
            cmd .= "'"
        }
        cmd .= '`n$principal = New-ScheduledTaskPrincipal -GroupId BUILTIN\Users -RunLevel ' runLevel '`n$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)`n'
        if (needStartUp) {
            cmd .= '$trigger = New-ScheduledTaskTrigger -AtLogOn`n$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings -Trigger $trigger'
        } else {
            cmd .= '$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings'
        }
        cmd .= '`nRegister-ScheduledTask -TaskName "' taskName '" -InputObject $task -Force'

        ps1_path := A_Temp "\abgox.InputTip.createScheduleTask.ps1"

        if (FileExist(ps1_path)) {
            try {
                FileDelete(ps1_path)
            } catch {
                return 0
            }
        }

        try {
            FileAppend(cmd, ps1_path)
            c := 'powershell -NoProfile -ExecutionPolicy Bypass -File "' ps1_path '"'
            isWait ? RunWait(c, , "Hide") : Run(c, , "Hide")
            return 1
        }
    }
    return 0
}

runScheduleTask(taskName) {
    try Run("schtasks /run /tn `"" taskName "`"", , "Hide")
}


getWinPhysicalRect(hwnd := 0) {
    rc := Buffer(16, 0)
    if !hwnd
        hwnd := WinExist("A")
    DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc)
    x := NumGet(rc, 0, "Int")
    y := NumGet(rc, 4, "Int")
    w := NumGet(rc, 8, "Int") - x
    h := NumGet(rc, 12, "Int") - y
    return { x: x, y: y, w: w, h: h }
}

; 获取屏幕的DPI缩放比
getMonitorScale(screen) {
    pt := Buffer(8, 0)
    NumPut("Int", (screen.left + screen.right) // 2, pt, 0)
    NumPut("Int", (screen.top + screen.bottom) // 2, pt, 4)
    hMonitor := DllCall("MonitorFromPoint", "Ptr", pt, "Int", 2, "Ptr")
    DllCall("Shcore\GetDpiForMonitor", "Ptr", hMonitor, "Int", 0, "UInt*", &dpiX := 0, "UInt*", &dpiY := 0)
    return dpiX / 96
}

; 逻辑像素转物理像素
toPhysical(value, scale) {
    return Round(value * scale)
}

; 用物理坐标定位并显示Gui窗口
setGuiPhysicalPos(hwnd, x, y, w := -1, h := -1) {
    flags := 0x10 | 0x40  ; SWP_NOACTIVATE | SWP_SHOWWINDOW
    if w == -1 || h == -1
        flags |= 0x01  ; SWP_NOSIZE，不改变尺寸
    DllCall("SetWindowPos",
        "Ptr", hwnd,
        "Ptr", -1,
        "Int", Round(x),
        "Int", Round(y),
        "Int", Round(w),
        "Int", Round(h),
        "UInt", flags)
}


isLocked() {
    if ProcessExist("LogonUI.exe")
        return 1
    hDesktop := DllCall("OpenInputDesktop", "UInt", 0, "Int", 0, "UInt", 0x0001)
    if hDesktop == 0
        return 1
    DllCall("CloseDesktop", "Ptr", hDesktop)
    return 0
}
