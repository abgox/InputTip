/**
 * 获取当前输入法中英文状态
 * @returns {number} 1:英文;1026/其他数字:中文;0:获取失败
 */
get_input_state() {
    try {
        DetectHiddenWindows True
        res := SendMessage(
            0x283,    ; Message : WM_IME_CONTROL
            0x001,    ; wParam  : IMC_GETCONVERSIONMODE
            0,    ; lParam  ： (NoArgs)
            , "ahk_id " DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinGetID("A"), "Uint") ; Control ： (Window)
        )
        DetectHiddenWindows False
        return res + 1
    } catch {
        return 0
    }
}
