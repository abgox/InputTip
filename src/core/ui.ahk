; InputTip

/**
 * 渲染控件 GroupBox
 * @param {Gui} g
 * @param {String} labelKey 文本 (i18n key)
 * @param {"xs"|"yp"} layout 布局配置
 * @param {String} options 额外选项
 */
renderGroupBox(g, labelKey, layout := "xs", options := "") {
    g.SetFont("Bold")
    g.AddGroupBox(layout " " options, i18n(labelKey))
    g.SetFont("Norm")
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
    g.AddText(layout " " options, i18n(textKey))
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
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Value))
}

/**
 * 渲染控件 Edit (GroupBox)
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {"Number"|"Number Limit2"|String} options 编辑框的额外选项
 */
renderEditGroup(g, key, options) {
    renderGroupBox(g, key, "xs", "h80 w" g.bw)
    renderEdit(g, key, "xs+20 yp+35", "w" g.bw - 40 " " options)
}

/**
 * 渲染控件 Edit (Label)
 * @param {Gui} g
 * @param {String} editKey 编辑框绑定的 key
 * @param {String} editOptions 编辑框的额外选项
 * @param {String} labelKey 标签的 i18n key
 * @param {String} textLayout 标签的布局配置
 */
renderEditLabel(g, editKey, editOptions, labelKey := editKey, textLayout := "xs+20 yp+35") {
    renderText(g, labelKey, textLayout, "")
    renderEdit(g, editKey, "yp", editOptions)
}

/**
 * 渲染控件 DropDownList
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {Array} list 选项数组 (i18n key)
 * @param {"xs+20 yp+35"|"yp"|"xs"} layout 布局配置
 * @param {String} options 额外选项
 */
renderDropDownList(g, key, list, layout := "xs+20 yp+35", options := "", callback := "") {
    _list := []
    for v in list
        _list.Push(i18n(v))
    _ := g.AddDropDownList(layout " AltSubmit r9 " options, _list)
    val := var.%key%
    if (IsNumber(val)) {
        try _.Value := val + 1
        _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Value - 1, , callback))
    } else {
        try _.Text := val
        _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Text, , callback))
    }
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
    renderGroupBox(g, groupLabelKey, groupLayout, "h80 w" g.bw)
    renderDropDownList(g, listLabelKey, list, "xs+20 yp+35", "w" g.bw - 40 " " listOptions)
}

/**
 * 渲染单个单选按钮
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} textKey 按钮文本 (i18n key)
 * @param {String|Number} value 选中时写入的值
 * @param {"xs+20 yp+35"|"yp"} layout 布局配置
 * @param {Func} dbClickEvent 双击事件回调
 */
renderRadio(g, key, textKey, value, layout, dbClickEvent := "") {
    isChecked := (var.%key% == value ? "Checked" : "")
    labelText := (SubStr(textKey, 1, 1) == ".") ? i18n(key textKey) : i18n(textKey)
    _ := g.AddRadio(layout " " isChecked, labelText)
    _.val := value
    _.OnEvent("Click", (ctrl, *) => changeConfig(key, ctrl.val))
    if (dbClickEvent) {
        _.OnEvent("DoubleClick", dbClickEvent)
    }
}

/**
 * 渲染一组单选按钮
 * @param {Gui} g Gui 对象
 * @param {String} key 绑定控件的 key
 * @param {Array} radios 单选按钮列表 (i18n key)
 */
renderRadioGroup(g, key, radios) {
    renderGroupBox(g, key, "xs", "h70 w" g.bw)
    for i, k in radios {
        layout := i == 1 ? "xs+20 yp+35" : "yp"
        cb := k.Length == 3 ? k[3] : ""
        renderRadio(g, key, k[1], k[2], layout, cb)
    }
}

/**
 * 批量渲染多个单选按钮组
 * @param {Gui} g Gui 对象
 * @param {Array} list 单选按钮组列表
 */
renderRadioGroupList(g, list) {
    for v in list {
        renderRadioGroup(g, v[1], v[2])
    }
}

/**
 * 渲染颜色选择器
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} labelKey 标签的 i18n key
 */
renderColorPicker(g, key, labelKey := key) {
    w := " w" (g.bw / 6)
    ctrlKey := key A_Now
    _ := g.AddText("yp", i18n(labelKey))
    _.ctrl := ctrlKey
    _.key := key
    _.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    var.%ctrlKey% := pickerCtrl := g.AddText("yp " w)
    pickerCtrl.Text := var.%key%
    pickerCtrl.ctrl := ctrlKey
    pickerCtrl.key := key
    pickerCtrl.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    _changeColor(color, cKey, oKey) {
        if (!color)
            return
        try {
            var.%cKey%.Value := color
            changeConfig(oKey, color)
            var.%oKey% := color
        }
    }
}
