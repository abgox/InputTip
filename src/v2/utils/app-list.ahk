; TODO: 后续可以考虑做一个网络同步
; 默认使用这些应用列表，如果远程有更改，用远程覆盖本地

; 只有使用黑名单机制，这个禁用列表才会生效
disable_list := [
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
]

Wpf_list := [
    ; Windows PowerShell ISE
    "powershell_ise.exe",
]

UIA_list := [
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
]

; MSAA 可能有符号残留
MSAA_list := [
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
]

Gui_UIA_list := [
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
]
; 需要调用有兼容性问题的 dll 来更新光标位置的应用列表
Hook_list_with_dll := [
    ; 微信
    "WeChat.exe",
]


appList := {
    disable: ":" arrJoin(disable_list, ":") ":",
    wpf: ":" arrJoin(Wpf_list, ":") ":",
    UIA: ":" arrJoin(UIA_list, ":") ":",
    MSAA: ":" arrJoin(MSAA_list, ":") ":",
    GUI_UIA: ":" arrJoin(Gui_UIA_list, ":") ":",
    Hook_with_dll: ":" arrJoin(Hook_list_with_dll, ":") ":"
}

; ACC_list := ":explorer.exe:ApplicationFrameHost.exe:"
