; InputTip

updateUIC() {
    global
    static ui := Map(
        12, { text: { h: 80, yp: 35 }, edit: { h: 110, yp: 45 }, ddl: { h: 100, yp: 45 } },
        14, { text: { h: 100, yp: 45 }, edit: { h: 110, yp: 45 }, ddl: { h: 110, yp: 50 } },
        16, { text: { h: 120, yp: 55 }, edit: { h: 130, yp: 55 }, ddl: { h: 130, yp: 60 } }, ; base
        18, { text: { h: 140, yp: 65 }, edit: { h: 150, yp: 65 }, ddl: { h: 150, yp: 70 } },
        20, { text: { h: 160, yp: 75 }, edit: { h: 170, yp: 75 }, ddl: { h: 170, yp: 80 } }
    )
    uicText := ui.Get(var.menuFontSize).text
    uicEdit := ui.Get(var.menuFontSize).edit
    uicDDL := ui.Get(var.menuFontSize).ddl
}

/**
 * 渲染控件 GroupBox
 * @param {Gui} g
 * @param {String} labelKey 文本 (i18n key)
 * @param {"xs"|"yp"} layout 布局配置
 * @param {String} options 额外选项
 */
renderGroupBox(g, labelKey, layout := "xs", options := "") {
    g.SetFont("Bold")
    _ := g.AddGroupBox(layout " " options, i18n(labelKey))
    g.SetFont("Norm")
    return _
}

/**
 * 渲染控件 Tab
 * @param {Gui} g
 * @param {Array} pages tab 页面
 * @param {String} options 额外选项
 */
renderTab(g, pages, options := "") {
    return g.AddTab3("-Wrap +0x100 +0x8 " options, pages)
}

/**
 * 渲染控件 Text
 * @param {Gui} g
 * @param {String} textKey 文本 (i18n key)
 * @param {"xs"|"yp"} layout 布局配置
 * @param {String} options 额外选项
 */
renderText(g, textKey, layout, options) {
    return g.AddText(layout " " options, i18n(textKey))
}

/**
 * 渲染控件 Edit
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {"xs"|"yp"} layout 布局配置
 * @param {String} options 额外选项
 */
renderEdit(g, key, layout := "yp", options := "") {
    _ := g.AddEdit("r1 " layout " " options)
    _.Value := var.%key%
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Value, 1))
    return _
}

/**
 * 渲染控件 Edit (GroupBox)
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {"Number"|"Number Limit2"|String} options 编辑框的额外选项
 */
renderEditGroup(g, key, options) {
    _ := renderGroupBox(g, key, "xs", "h" uicEdit.h " w" g.bw)
    __ := renderEdit(g, key, "xs+20 yp+" uicEdit.yp, "w" g.bw - 40 " " options)
    return { group: _, edit: __ }
}

/**
 * 渲染控件 Edit (Label)
 * @param {Gui} g
 * @param {String} editKey 编辑框绑定的 key
 * @param {String} editOptions 编辑框的额外选项
 * @param {String} labelKey 标签的 i18n key
 * @param {String} textLayout 标签的布局配置
 */
renderEditLabel(g, editKey, editOptions, labelKey := editKey, textLayout := "xs+20 yp+" uicEdit.yp) {
    _ := renderText(g, labelKey, textLayout, "")
    __ := renderEdit(g, editKey, "yp", editOptions)
    return { text: _, edit: __ }
}

/**
 * 渲染控件 DropDownList
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {Array} list 选项数组 (i18n key)
 * @param {"xs+20 yp+60"|"yp"|"xs"} layout 布局配置
 * @param {String} options 额外选项
 */
renderDropDownList(g, key, list, layout := "xs+20 yp+" uicDDL.yp, options := "") {
    valMap := Map()
    _list := []
    for v in list
        val := i18n(v), _list.Push(val), valMap.Set(val, v)
    _ := g.AddDropDownList(layout " r9 " options, _list)
    val := var.%key%
    try _.Text := i18n(val)
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, valMap.Get(ctrl.text, ctrl.text)))
    SuppressControlWheel(_.Hwnd)
    return _
}

/**
 * 渲染控件 DropDownList (GroupBox)
 * @param {Gui} g
 * @param {String} groupLabelKey 组标签的 i18n key
 * @param {Array} list 选项数组 (i18n key)
 * @param {String} listLabelKey 列表标签的 i18n key
 * @param {"xs"|"section"} groupLayout 组标签的布局
 * @param {String} listOptions 列表的额外选项
 */
renderDropDownListGroup(g, groupLabelKey, list, listLabelKey := groupLabelKey, groupLayout := "xs", listOptions := "") {
    _ := renderGroupBox(g, groupLabelKey, groupLayout, "h" uicDDL.h " w" g.bw)
    __ := renderDropDownList(g, listLabelKey, list, "xs+20 yp+" uicDDL.yp, "w" g.bw - 40 " " listOptions)
    return { group: _, dropDownList: __ }
}

/**
 * 渲染单个单选按钮
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} textKey 按钮文本 (i18n key)
 * @param {String|Number} value 选中时写入的值
 * @param {"xs+20 yp+50"|"yp"} layout 布局配置
 * @param {Func} callback 点击按钮后的回调
 */
renderRadio(g, key, textKey, value, layout, callback := (key, value, *) => changeConfig(key, value)) {
    isChecked := (var.%key% == value ? "Checked" : "")
    labelText := (SubStr(textKey, 1, 1) == ".") ? i18n(key textKey) : i18n(textKey)
    _ := g.AddRadio(layout " " isChecked, labelText)
    _.OnEvent("Click", callback.Bind(key, value))
    return _
}

/**
 * 渲染一组单选按钮
 * @param {Gui} g Gui 对象
 * @param {String} key 绑定控件的 key
 * @param {Array} radios 单选按钮列表 (i18n key)
 */
renderRadioGroup(g, key, radios) {
    _ := renderGroupBox(g, key, "xs", "h" uicText.h " w" g.bw)
    radiosList := []
    for i, k in radios {
        layout := i == 1 ? "xs+20 yp+" uicText.yp : "yp"
        param := [g, key, k[1], k[2], layout]
        if k.Length == 3
            param.Push(k[3])
        radiosList.Push(renderRadio(param*))
    }
    return { group: _, radios: radiosList }
}

/**
 * 批量渲染多个单选按钮组
 * @param {Gui} g Gui 对象
 * @param {Array} list 单选按钮组列表
 */
renderRadioGroupList(g, list) {
    for v in list
        renderRadioGroup(g, v[1], v[2])
}

/**
 * 渲染颜色选择器
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} labelKey 标签的 i18n key
 * @param {"yp"|"xs+20 yp+50"|String} layout
 */
renderColorPicker(g, key, labelKey := key, layout := "yp") {
    ctrlKey := key A_Now
    _ := g.AddText(layout, i18n(labelKey))
    _.ctrl := ctrlKey
    _.key := key
    _.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    _.OnEvent("ContextMenu", (ctrl, *) => _clearColor(ctrl.ctrl, ctrl.key))
    var.%ctrlKey% := pickerCtrl := g.AddText("yp", StrReplace(var.%key%, "0x", " ") " ")
    pickerCtrl.ctrl := ctrlKey
    pickerCtrl.key := key
    pickerCtrl.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    _changeColor(color, cKey, oKey) {
        if !color
            return
        try {
            var.%cKey%.Value := StrReplace(color, "0x", " ") " "
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
