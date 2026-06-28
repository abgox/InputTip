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

/**
 * 从 Array 或 Map 中通过 value 获取 key/index
 * @param {Array|Map} obj
 * @returns {String} 没有找到 key/index 则返回空字符串
 */
keyOf(obj, value) {
    for k, v in obj {
        if v == value
            return k
    }
    return ""
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

safeRegexMatch(Haystack, NeedleRegEx) {
    try {
        return RegExMatch(Haystack, NeedleRegEx)
    } catch {
        return 0
    }
}

; 从字符串中提取出数字，支持负数和小数
returnNumber(value) {
    if value == "" || !(value ~= "\d")
        return 0
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

applyTransparency(hwnd, transparency) {
    if transparency == ""
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
    if A_IsAdmin {
        cmd := '$action = New-ScheduledTaskAction -Execute "' path '" '
        if args.Length {
            cmd .= "-Argument '"
            for v in args {
                cmd .= '"' v '" '
            }
            cmd .= "'"
        }
        cmd .= '`n$principal = New-ScheduledTaskPrincipal -GroupId BUILTIN\Users -RunLevel ' runLevel '`n$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)`n'
        cmd .= needStartUp ? '$trigger = New-ScheduledTaskTrigger -AtLogOn`n$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings -Trigger $trigger' : '$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings'
        cmd .= '`nRegister-ScheduledTask -TaskName "' taskName '" -InputObject $task -Force'

        if FileExist(ps1_path := A_Temp "\abgox.InputTip.createScheduleTask.ps1") {
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

getFocusedHwnd(hwnd := 0) {
    x64 := A_PtrSize == 8
    guiThreadInfo := Buffer(x64 ? 72 : 48)
    try {
        NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
            if hwnd := NumGet(guiThreadInfo, x64 ? 48 : 28, "ptr") {
                return hwnd
            }
            hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
        }
    }
    return hwnd
}

getWinPhysicalRect(hwnd := WinExist("A")) {
    rc := Buffer(16, 0)
    if !DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rc, "UInt", 16) {
        x := NumGet(rc, 0, "Int")
        y := NumGet(rc, 4, "Int")
        w := NumGet(rc, 8, "Int") - x
        h := NumGet(rc, 12, "Int") - y
        return { x: x, y: y, w: w, h: h }
    }

    DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc)
    x := NumGet(rc, 0, "Int")
    y := NumGet(rc, 4, "Int")
    w := NumGet(rc, 8, "Int") - x
    h := NumGet(rc, 12, "Int") - y
    return { x: x, y: y, w: w, h: h }
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

isFullscreen(hwnd) {
    if !hwnd || (WinGetStyle(hwnd) & 0x00C00000)
        return false
    try {
        WinGetPos(&winX, &winY, &winW, &winH, hwnd)
        scr := isWhichScreen(hwnd)
        if scr {
            scrW := scr.right - scr.left
            scrH := scr.bottom - scr.top
            return (winW >= scrW * 0.98 && winH >= scrH * 0.98)
        }
    }
    return false
}
