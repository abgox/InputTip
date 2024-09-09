config := "InputTip.ini"

ini(key, default) {
    try {
        return IniRead(config, "InputMethod", key)
    } catch {
        IniWrite(default, config, "InputMethod", key)
        return default
    }
}

code := ini("code", "0x005"), CN := ini("CN", "1"), HKEY_startup := "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
A_TrayMenu.Delete()
A_TrayMenu.Add("开机自启动", fn_startup)
subMap := {
    ; 无法使用：小鹤、小狼毫(rime)、手心输入法、谷歌输入法、2345王牌输入法
    默认: ["0x005", "1"], ; 搜狗、百度、QQ、微信、微软、冰凌五笔
    讯飞输入法: ["0x005", "2"]
}
sub := Menu()
sub.Add("默认", fn)
sub.Add("讯飞输入法", fn)
A_TrayMenu.Add("设置输入法", sub)
A_TrayMenu.Add()
A_TrayMenu.Add("关于", about)
A_TrayMenu.Add("重启", fn_restart)
A_TrayMenu.Add("退出", fn_exit)
try {
    select := ini("select", "默认")
    sub.Check(select)
} catch {
    IniWrite("默认", config, "InputMethod", "select")
    select := "默认"
    sub.Check(select)
}
try {
    path_exe := RegRead(HKEY_startup, A_ScriptName)
    if (path_exe = A_ScriptFullPath) {
        A_TrayMenu.Check("开机自启动")
    }
}
fn_startup(item, *) {
    try {
        path_exe := RegRead(HKEY_startup, A_ScriptName)
        if (path_exe != A_ScriptFullPath) {
            RegWrite(A_ScriptFullPath, "REG_SZ", HKEY_startup, A_ScriptName)
        } else {
            RegDelete(HKEY_startup, A_ScriptName)
        }
    } catch {
        RegWrite(A_ScriptFullPath, "REG_SZ", HKEY_startup, A_ScriptName)
    }
    A_TrayMenu.ToggleCheck(item)
}
about(*) {
    aboutGui := Gui("AlwaysOnTop +OwnDialogs")
    aboutGui.SetFont("q4 s12 w600", "微软雅黑")
    aboutGui.AddText("Center h30", "InputTip - 根据输入法中英文状态切换鼠标样式的小工具")
    aboutGui.Show("Hide")
    aboutGui.GetPos(, , &Gui_width)
    aboutGui.Destroy()

    aboutGui := Gui("AlwaysOnTop +OwnDialogs")
    aboutGui.SetFont("q4 s12 w600", "微软雅黑")
    aboutGui.AddText("Center h30 w" Gui_width, "InputTip - 根据输入法中英文状态切换鼠标样式的小工具")
    aboutGui.AddText("xs", "获取更多信息，你应该查看 : ")
    aboutGui.AddText("xs", "官网:")
    aboutGui.AddLink("yp", '<a href="https://inputtip.pages.dev">https://inputtip.pages.dev</a>')
    aboutGui.AddText("xs", "Github:")
    aboutGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">https://github.com/abgox/InputTip</a>')
    aboutGui.AddText("xs", "Gitee: :")
    aboutGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip">https://gitee.com/abgox/InputTip</a>')

    aboutGui.AddButton("xs w" Gui_width, "关闭").OnEvent("Click", close)
    aboutGui.OnEvent("Escape", close)
    aboutGui.Show()

    close(*) {
        aboutGui.Destroy()
    }

}
fn_restart(*) {
    Run(A_ScriptFullPath)
}
fn_exit(*) {
    ExitApp()
}
fn(item, *) {
    do(k, v) {
        try {
            old_v := IniRead(config, "InputMethod", k)
            if (old_v != v) {
                IniWrite(v, config, "InputMethod", k)
            }
        } catch {
            IniWrite(v, config, "InputMethod", k)
        }
    }
    do("select", item)
    do("code", subMap.%item%[1])
    do("CN", subMap.%item%[2])
    Run(A_ScriptFullPath)
}

/**
 * 获取当前输入法中英文状态
 * @returns {number} 1:中文 0:英文
 * CN=1, EN=0   微信输入法,微软拼音，搜狗输入法,QQ输入法,冰凌五笔,
 * CN=2, EN=1   讯飞输入法
 * CN=EN=1(无法区分) 百度输入法，手心输入法，谷歌输入法，2345王牌输入法，小鹤音形,小狼毫(rime)
 */
getInputState() {
    res := SendMessage(
        0x283,    ; Message : WM_IME_CONTROL
        code,    ; wParam  : IMC_GETCONVERSIONMODE
        0,    ; lParam  ： (NoArgs)
        , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinGetID("A"), "Uint") ; Control ： (Window)
    )
    return res = CN
}
