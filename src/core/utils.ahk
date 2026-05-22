; InputTip

/**
 * 防抖函数
 * @param {Func} fn 要执行的函数
 * @param {Number} delay 延迟时间(ms)
 * @returns {Func} 函数
 */
debounce(fn, delay := 1000) {
    state := { params: [], timer: 0 }
    return (args*) => (
        state.params := args,
        state.timer ? SetTimer(state.timer, 0) : 0,
        state.timer := SetTimer((*) => fn.Call(state.params*), -delay)
    )
}

arrJoin(arr, separator := "") {
    res := ""
    for i, v in arr {
        res .= i == arr.Length ? v : v separator
    }
    return res
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

; 从字符串中提取出数字，支持负数和小数
returnNumber(value) {
    if (value == "" || !(value ~= "\d")) {
        return 0
    }
    RegExMatch(value, "(-?\d+\.?\d*)", &numbers)
    return numbers[1]
}

; 返回当前的时间，作为唯一标识符
returnTime() {
    return FormatTime(A_Now, "yyyy-MM-dd-HH:mm:ss") "." A_MSec
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
