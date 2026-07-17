; InputTip

renderText(g, textKey, options := "xs") {
    return g.AddText(options, i18n(textKey))
}
renderBoldText(g, labelKey, options := "xs") {
    g.SetFont("Bold")
    _ := renderText(g, labelKey, options)
    g.SetFont("Norm")
    return _
}

renderTab(g, pages, options := "") {
    return g.AddTab3("-Wrap +0x100 +0x8 " options, pages)
}

renderEdit(g, key, options := "") {
    _ := g.AddEdit("r1 " options)
    _.Value := var.%key%
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Value, 1))
    return _
}
renderEditGroup(g, key, options) {
    _ := renderBoldText(g, key)
    __ := renderEdit(g, key, "w" g.bw " " options)
    return { group: _, edit: __ }
}
renderEditLabel(g, editKey, editOptions, labelKey := editKey, textOptions := "xs") {
    _ := renderText(g, labelKey, textOptions)
    __ := renderEdit(g, editKey, "yp " editOptions)
    return { text: _, edit: __ }
}

renderDDL(g, key, list, options := "xs") {
    valMap := Map()
    _list := []
    for v in list
        val := i18n(v), _list.Push(val), valMap.Set(val, v)
    _ := g.AddDropDownList("r9 " options, _list)
    val := var.%key%
    try _.Text := i18n(val)
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, valMap.Get(ctrl.text, ctrl.text)))
    SuppressControlWheel(_.Hwnd)
    return _
}
renderDDLGroup(g, groupLabelKey, list, listLabelKey := groupLabelKey, groupOptions := "xs", listOptions := "") {
    _ := renderBoldText(g, groupLabelKey, groupOptions)
    __ := renderDDL(g, listLabelKey, list, "xs w" g.bw " " listOptions)
    return { group: _, dropDownList: __ }
}

renderRadio(g, key, textKey, value, options, callback := (key, value, *) => changeConfig(key, value)) {
    isChecked := var.%key% == value ? "Checked" : ""
    labelText := SubStr(textKey, 1, 1) == "." ? i18n(key textKey) : i18n(textKey)
    _ := g.AddRadio(options " " isChecked, labelText)
    _.OnEvent("Click", callback.Bind(key, value))
    return _
}
renderRadioGroup(g, key, radios) {
    _ := renderBoldText(g, key, "xs")
    radiosList := []
    for i, k in radios {
        layout := i == 1 ? "xs" : "yp"
        param := [g, key, k[1], k[2], layout]
        if k.Length == 3
            param.Push(k[3])
        radiosList.Push(renderRadio(param*))
    }
    return { group: _, radios: radiosList }
}

renderColorPicker(g, key, labelKey := key, options := "yp") {
    ctrlKey := key A_Now
    _ := renderText(g, labelKey, options)
    _.ctrl := ctrlKey
    _.key := key
    _.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    _.OnEvent("ContextMenu", (ctrl, *) => _clearColor(ctrl.ctrl, ctrl.key))
    var.%ctrlKey% := pickerCtrl := g.AddText("yp", " CCCCCC ")
    pickerCtrl.Value := StrReplace(var.%key%, "0x", "")
    pickerCtrl.ctrl := ctrlKey
    pickerCtrl.key := key
    pickerCtrl.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    _changeColor(color, cKey, oKey) {
        if color == ""
            return
        try {
            var.%cKey%.Value := StrReplace(color, "0x", "") " "
            changeConfig(oKey, color)
        }
    }
    _clearColor(cKey, oKey) {
        var.%cKey%.Value := ""
        changeConfig(oKey, "")
    }

    return { text: _, picker: pickerCtrl }
}

ComboBoxSubclass(hwnd, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
    if uMsg == 0x20A ; WM_MOUSEWHEEL
        return 0
    return DllCall("comctl32\DefSubclassProc", "ptr", hwnd, "uint", uMsg, "uptr", wParam, "uptr", lParam, "uptr")
}

SuppressControlWheel(hwnd) {
    static wheelProc := CallbackCreate(ComboBoxSubclass, "F", 6)
    DllCall("comctl32\SetWindowSubclass", "ptr", hwnd, "ptr", wheelProc, "uptr", 1, "uptr", 0)
}

disableCtrl(ctrlList, disable := 1) {
    state := disable ? "+Disabled" : "-Disabled"
    for v in ctrlList
        try v.Opt(state)
}
