defaultModeList := {
    ; 只有使用黑名单机制，这个禁用列表才会生效
    disable: [
        ; 规避任务栏和开始菜单中的显示问题
        "ShellExperienceHost.exe",
        "StartMenuExperienceHost.exe",
        ; WPS 无法使用，Office 可以正常使用
        "wps.exe",
        ; HBuilderX 无法使用
        "HBuilderX.exe",
        ; 微信输入法配置界面
        "wetype_update.exe",
        ; PotPlayer 无法使用，没有什么输入场景，不太影响
        "PotPlayer.exe",
        "PotPlayer64.exe",
        "PotPlayerMini.exe",
        "PotPlayerMini64.exe",
        ;
        "AnLink.exe",
        ;
        "ShareX.exe",
        ;
        "clipdiary-portable.exe",
        ; 微软远程桌面，与 InputTip 冲突，输入时会导致其挂掉
        ; 有的有问题，有的没问题
        ; "mstsc.exe",
    ],
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
    ; MSAA 可能有符号残留
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
    ; 需要调用有兼容性问题的 dll 来更新光标位置的应用列表
    HOOK_DLL: [
        ; 微信
        "WeChat.exe",
    ],
    WPF: [
        ; Windows PowerShell ISE
        "powershell_ise.exe",
    ],
    ACC: [],
    JAB: []
}
modeNameList := [
    "HOOK", "UIA", "GUI_UIA", "MSAA", "HOOK_DLL", "WPF", "ACC", "JAB"
]
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
