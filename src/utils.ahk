config := A_AppData "\InputTip_input_state.ini"

ini(key, default) {
    try {
        return IniRead(config, "InputMethod", key)
    } catch {
        IniWrite(default, config, "InputMethod", key)
        return default
    }
}

code := ini("code", "0x005")
CN := ini("CN", "1")

A_TrayMenu.Delete()
sub := Menu()
subMap := {
    ; 无法使用：小鹤、小狼毫(rime)、手心输入法、谷歌输入法、2345王牌输入法
    默认: ["0x005", "1"], ; 搜狗、百度、QQ、微信、微软、冰凌五笔
    讯飞输入法: ["0x005", "2"]
}
sub.Add("默认", fn)
sub.Add("讯飞输入法", fn)
A_TrayMenu.Add("设置输入法", sub)
A_TrayMenu.Add()
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
fn_restart(*) {
    Run(A_ScriptFullPath)
}
fn_exit(*) {
    ExitApp()
}
fn(ItemName, *) {
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
    do("select", ItemName)
    do("code", subMap.%ItemName%[1])
    do("CN", subMap.%ItemName%[2])
    Run(A_ScriptFullPath)
}

/**
 * 获取当前输入法中英文状态
 * @returns {number} 1:中文 0:英文 null:获取失败
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
