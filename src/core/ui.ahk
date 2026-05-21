; InputTip

/**
 * 加粗字体
 * @param {Gui} g
 * @param {Func} callback
 */
renderBold(g, callback) {
    g.SetFont("Bold")
    callback()
    g.SetFont("Norm")
}

/**
 * 渲染控件 Text
 * @param {Gui} g
 * @param {String} textKey 文本 (i18n key)
 * @param {String} options 控件的 Options
 */
renderGroupBox(g, textKey, options) {
    renderBold(g, () => g.AddGroupBox(options, i18n(textKey)))
}

/**
 * 渲染控件 Text
 * @param {Gui} g
 * @param {String} textKey 文本 (i18n key)
 * @param {String} options 控件的 Options
 */
renderText(g, textKey, options) {
    g.AddText(options, i18n(textKey))
}

/**
 * 渲染控件 Edit
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} options 控件的 Options
 * @param {String} defaultOptions 常用的选择，但某些特殊情况可能也需要覆盖
 */
renderEdit(g, key, editOpt := "", defaultOptions := "r1 yp") {
    _ := g.AddEdit(defaultOptions " " editOpt)
    _.Value := var.%key%
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Value))
}

/**
 * 渲染控件 DropDownList
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {Array} dropDownList 原始选项数组 (i18n key)
 * @param {String} options 控件的 Options
 */
renderDropDownList(g, key, dropDownList, options) {
    list := []
    for v in dropDownList
        list.Push(i18n(v))

    _ := g.AddDropDownList("r9 " options, list)
    val := var.%key%
    if (IsNumber(val)) {
        try _.Value := val + 1
        _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Value - 1))
    } else {
        try _.Text := val
        _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Text))
    }
}

/**
 * 渲染控件 Radio
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} textKey 文本 (i18n key)
 * @param {Array} value 选中后应该写入的值
 * @param {String} options 控件的 Options
 * @param {Func} dbClickEvent 双击事件
 */
renderRadio(g, key, textKey, value, options, dbClickEvent := "") {
    isChecked := (var.%key% == value ? "Checked" : "")
    labelText := (SubStr(textKey, 1, 1) == ".") ? i18n(key textKey) : i18n(textKey)
    _ := g.AddRadio(options " " isChecked, labelText)
    _.val := value
    _.OnEvent("Click", (ctrl, *) => changeConfig(key, ctrl.val))
    if (dbClickEvent) {
        _.OnEvent("DoubleClick", dbClickEvent)
    }
}

/**
 * 渲染一组单选按钮
 * @param {Gui} g Gui 对象
 * @param {String} key 配置项 key，用于绑定当前选中的值
 * @param {Array} radios 单选按钮列表
 */
renderRadioGroup(g, key, radios) {
    renderGroupBox(g, key, "xs h70 w" g.bw)
    for i, k in radios {
        opt := i == 1 ? "xs+20 yp+30" : "yp"
        cb := k.Length == 3 ? k[3] : ""
        renderRadio(g, key, k[1], k[2], opt, cb)
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
 * 渲染一个用于选择系统字体的组合框下拉菜单
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} groupOpt 组合框的 Options
 * @param {String} ctrlOpt 额外追加给下拉菜单控件的 Options
 */
renderFontGroup(g, key) {
    renderGroupBox(g, key, "xs h70 w" g.bw)
    _ := g.AddDropDownList("xs+20 yp+30 AltSubmit r9 w" (g.bw - 40), fontList)
    try _.Text := var.%key%
    _.OnEvent("Change", (ctrl, *) => changeConfig(key, ctrl.Text))
}

/**
 * 渲染一个简易的颜色选择控件（通过点击文本触发外部拾色器）
 * @param {Gui} g
 * @param {String} key 绑定控件的 key
 * @param {String} state 状态
 */
renderColorPicker(g, key, state) {
    w := " w" (g.bw / 6)
    colorKey := key state
    ctrlKey := colorKey A_Now
    _ := g.AddText("yp", i18n(key))
    _.ctrl := ctrlKey
    _.key := colorKey
    _.OnEvent("Click", (ctrl, *) => _changeColor(pickColor(ctrl.hwnd, ctrl.key), ctrl.ctrl, ctrl.key))
    var.%ctrlKey% := pickerCtrl := g.AddText("yp " w)
    pickerCtrl.Text := var.%colorKey%
    pickerCtrl.ctrl := ctrlKey
    pickerCtrl.key := colorKey
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
