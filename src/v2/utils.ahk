config := A_AppData "\InputTip_input_state.ini"

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
sub2 := Menu()
sub2.Add("中文", fn_CN)
sub2.Add("英文", fn_EN)
A_TrayMenu.Add("设置鼠标样式", sub2)
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
verify(dir, folder) {
    if (!dir) {
        MsgBox("没有选择文件夹，鼠标样式修改操作取消。", , "0x40 0x1000")
        return
    }
    hasFile := false
    Loop Files, dir "\*", "" {
        if (A_LoopFileExt = "cur" || A_LoopFileExt = "ani") {
            hasFile := true
            break
        }
    }
    if (!hasFile) {
        MsgBox("你应该选择一个包含鼠标样式文件的文件夹。`n鼠标样式文件: 后缀名为 .cur 或 .ani 的文件", "InputTip.exe - 选择文件夹错误！", "0x10 0x1000")
        return
    }
    dir_name := SubStr(dir, -3)
    if (dir_name = "\EN" || dir_name = "\CN") {
        MsgBox("不能选择 CN 或 EN 文件夹！", , "0x30 0x1000")
        return
    }
    try {
        DirDelete(A_ScriptDir "\InputTipCursor\" folder, 1)
        DirCopy(dir, A_ScriptDir "\InputTipCursor\" folder, 1)
    }
}
fn_CN(*) {
    dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为中文鼠标样式 (不能是 CN 或 EN 文件夹)")
    verify(dir, 'CN')
}
fn_EN(*) {
    dir := FileSelect("D", A_ScriptDir "\InputTipCursor", "选择一个文件夹作为英文鼠标样式 (不能是 CN 或 EN 文件夹)")
    verify(dir, 'EN')
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
    aboutGui.AddText("", "Github 仓库:")
    aboutGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip">Github</a>')
    aboutGui.AddText("xs", "Gitee 仓库:")
    aboutGui.AddLink("yp", '<a href="https://Gitee.com/abgox/InputTip">Gitee</a>')
    aboutGui.AddText("xs", "获取更多已适配的鼠标样式文件:")
    aboutGui.AddLink("yp", '<a href="https://github.com/abgox/InputTip/releases/download/v2.1.0/cursorStyle.zip">链接(Github)</a>')
    aboutGui.AddLink("yp", '<a href="https://gitee.com/abgox/InputTip/releases/download/v2.1.0/cursorStyle.zip">链接(Gitee)</a>')

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
 */
get_input_state() {
    DetectHiddenWindows True
    res := SendMessage(
        0x283,    ; Message : WM_IME_CONTROL
        code,    ; wParam  : IMC_GETCONVERSIONMODE
        0,    ; lParam  ： (NoArgs)
        , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinGetID("A"), "Uint") ; Control ： (Window)
    )
    DetectHiddenWindows False
    return res = CN
}
