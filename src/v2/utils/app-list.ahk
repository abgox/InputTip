; 内部的默认模式应用列表，优先级最低，会被通过「设置光标获取模式」设置的配置覆盖
defaultModeList := {
    HOOK: [],
    UIA: [
        ; Word
        "WINWORD.EXE",
        ; 终端
        "WindowsTerminal.exe",
        "wt.exe",
        ; 一个文件管理器
        "OneCommander.exe",
        ; 有道词典
        "YoudaoDict.exe",
        ;
        "Mempad.exe",
        ; 任务管理器
        "Taskmgr.exe",
    ],
    ; 先后调用 GUI 和 UIA
    GUI_UIA: [
        ; PowerPoint(PPT)
        "POWERPNT.EXE",
        ;
        "Notepad++.exe",
        ; 火狐浏览器
        "firefox.exe",
        ; Visual Studio
        "devenv.exe",
        ; 腾讯会议
        "WeMeetApp.exe",
        ; 微信
        "Weixin.exe",
    ],
    MSAA: [
        ; Excel
        "EXCEL.EXE",
        ; 钉钉
        "DingTalk.exe",
        ; 记事本
        "Notepad.exe",
        "Notepad3.exe",
        ; 快速启动
        "Quicker.exe",
        ;
        "skylark.exe",
        ; 字幕编辑器
        "aegisub32.exe",
        "aegisub64.exe",
        "aegisub.exe",
        ; 图片文字识别
        "PandaOCR.exe",
        "PandaOCR.Pro.exe",
        ; 音速启动
        "VStart6.exe",
        ; Tim
        "TIM.exe",
        ; PowerToys 快速启动器
        "PowerToys.PowerLauncher.exe",
        ; 邮箱
        "Foxmail.exe",
    ],
    ; 需要调用有兼容性问题(32位)的 dll
    HOOK_DLL: [
        ; 微信
        "WeChat.exe",
    ],
    WPF: [
        ; Windows PowerShell ISE
        "powershell_ise.exe",
    ],
    ACC: [],
    ; 需要使用 Java Access Bridge
    JAB: []
}

modeNameList := ["HOOK", "UIA", "GUI_UIA", "MSAA", "HOOK_DLL", "WPF", "ACC", "JAB"]
modeListMap := {
    HOOK: 1,
    UIA: 2,
    GUI_UIA: 3,
    MSAA: 4,
    HOOK_DLL: 5,
    WPF: 6,
    ACC: 7,
    JAB: 8
}
