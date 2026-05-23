; InputTip

/**
 * 启动 JAB 进程
 * @returns {1|0} 是否存在错误
 */
runJAB() {
    if isJAB
        return
    if (A_IsCompiled) {
        try {
            if (hasNewVersion(currentVersion, FileGetVersion("InputTip.JAB.JetBrains.exe"))) {
                FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
            }
        } catch {
            try FileInstall("InputTip.JAB.JetBrains.exe", "InputTip.JAB.JetBrains.exe", 1)
        }
        try {
            done := createScheduleTask(A_ScriptDir "\InputTip.JAB.JetBrains.exe", taskNameJAB, , "Limited", 1)
            if (!done) {
                showGui(createErrorTipGui(i18n("symbolJAB.error", 1), i18n("symbolJAB")))
                changeConfig("symbolJABActive", 0, 1)
                return 1
            }
            runScheduleTask(taskNameJAB)
        }
    } else if (A_IsAdmin) {
        try {
            done := createScheduleTask(A_AhkPath, taskNameJAB, [JABPath], "Limited", 1)
            if (!done) {
                showGui(createErrorTipGui(i18n("symbolJAB.error", 1), i18n("symbolJAB")))
                changeConfig("symbolJABActive", 0, 1)
                return 1
            }
            runScheduleTask(taskNameJAB)
        }
    } else {
        global JAB_PID
        Run('"' A_AhkPath '" "' JABPath '"', , "Hide", &JAB_PID)
    }
    return 0
}

; 重启 JAB 程序
restartJAB() {
    static done := 1

    if isJAB
        return

    if (done && var.symbolJABActive) {
        SetTimer(restartAppTimer, -1)
        restartAppTimer() {
            done := 0
            killJAB(1)
            if (A_IsAdmin) {
                runScheduleTask(taskNameJAB)
            } else {
                global JAB_PID
                Run('"' A_AhkPath '" "' JABPath '"', , "Hide", &JAB_PID)
            }
            done := 1
        }
    }
}

/**
 * 停止 JAB 进程
 * @param {1|0} wait 等待停止进程
 * @param {1|0} delete 停止进程后，是否需要删除相关任务计划程序
 */
killJAB(wait := 1, delete := 0) {
    if (A_IsAdmin) {
        cmd := "schtasks /End /tn `"" taskNameJAB "`""
        try wait ? RunWait(cmd, , "Hide") : Run(cmd, , "Hide")
        if (delete) {
            try Run("schtasks /delete /tn `"" taskNameJAB "`" /f", , "Hide")
        }
    } else {
        ProcessClose(JAB_PID)
    }
}
