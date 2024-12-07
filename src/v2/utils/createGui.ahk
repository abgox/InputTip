/**
 * 用于创建 Gui 对象，并获取窗口的位置和大小，用于控件配置宽度大小
 * @param fn 一个函数
 * 
 * 在这个函数中正常创建 Gui 即可，它能接受到四个参数(x/y/w/h)，分别表示窗口的位置和大小。
 * 
 * 这里获取到的 w 和 h 是不带有 MarginX 和 MarginY 的，所以需要加上这两个值才能得到真实的窗口大小。
 * 
 * 不能在这个函数中使用 Show() 方法显示，应该在返回的 Gui 对象中使用。
 * @param tempFn 一个函数
 * 
 * 这个函数会创建一个临时的 Gui，用来获取窗口的位置和大小，一般使用默认值就足够了，如果需要修改字体配置等，可以传入一个类似的新函数
 * @returns 返回 Gui 对象
 */
createGui(fn, tempFn := _createGuiTempFn
) {
    list := []
    for v in fn(0, 0, 0, 0) {
        list.Push({ type: v.Type, text: v.Text })
    }
    info := tempFn(list)
    return fn(info.x, info.y, info.w, info.h)
}

_createGuiTempFn(list) {
    g := Gui("AlwaysOnTop +OwnDialogs")
    g.SetFont("s12", "微软雅黑")
    for v in list {
        g.Add(v.Type, , v.text)
    }
    g.Show("Hide")
    g.GetPos(&x, &y, &w, &h)
    g.Destroy()
    return { x: x, y: y, w: w, h: h }
}
