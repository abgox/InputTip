/*
https://github.com/telppa/BeautifulToolTip

If you want to add your own style to the built-in style, you can add it directly in btt().

version:
2021.10.03

changelog:
2021.10.03
  改变 Include 方式，降低库冲突的可能性。
2021.09.29
  支持设置 TabStops 。
  除 GDIP 库外所有函数内置到 Class 中，降低库冲突的可能性。
2021.04.30
  修复 Win7 下不能运行的 bug 。（2021.04.20 引起）
2021.04.20
  支持根据显示器 DPI 缩放比例自动缩放，与 ToolTip 特性保持一致。
  支持直接使用未安装的本地字体。
  Options 增加 JustCalculateSize 参数，可在不绘制内容的前提下直接返回尺寸。
2021.03.07
  增加 4 种渐变模式。
2021.03.05
  删除渐变方向参数。
  增加渐变角度参数，支持 360° 渐变。
  增加渐变模式参数，支持 4 种模式。
2021.03.03
  文本色支持渐变。
  增加 Style8 。
  增加 3 个渐变方向。
2021.03.02
  细边框色支持渐变。
  增加 Style7 。
  增加 2 个渐变方向。
2021.03.01
  BTT 的总在最上级别现在跟 ToolTip 一样高了。
  解决 BTT 被不明原因置底导致误以为没显示的问题。
  增加 Style6 。
  文字显示更加居中。
2021.02.22
  增加返回值。
  Options 增加 Transparent 参数，可直接设置整体透明度。

todo:
指定高宽
文字可获取
降低内存消耗
阴影
ANSI版本的支持
文字太多导致没有显示完全的情况下给予明显提示（例如闪烁）

优势:
*高性能         是内置 ToolTip 2-1000 倍性能（文本越大性能对比越大，多数普通应用场景2-5倍性能）
*高兼容         兼容内置 ToolTip 的一切，包括语法、WhichToolTip、A_CoordModeToolTip、自动换行等等
*简单易用       一行代码即使用 无需手动创建释放资源
*多套内置风格   可通过模板快速实现自定义风格
*可自定义风格   细边框（颜色、大小） 圆角 边距 文字（颜色、字体、字号、渲染方式、样式） 背景色 所有颜色支持360°渐变与透明
*可自定义参数   贴附目标句柄 坐标模式 整体透明度 文本框永不被遮挡 跟随鼠标距离 不绘制内容直接返回尺寸
*不闪烁不乱跳
*多显示器支持
*缩放显示支持
*跟随鼠标不出界
*可贴附指定目标
*/
btt(Text:="", X:="", Y:="", WhichToolTip:="", BulitInStyleOrStyles:="", BulitInOptionOrOptions:="")
{
  static BTT
       ; You can customize your own style.
       ; All supported parameters are listed below. All parameters can be omitted.
       ; Please share your custom style and include a screenshot. It will help a lot of people.
       ; Attention:
       ; Color => ARGB => Alpha Red Green Blue => 0x ff aa bb cc => 0xffaabbcc
       , Style99 :=  {Border:20                                      ; If omitted, 1 will be used. Range 0-20.
                    , Rounded:30                                     ; If omitted, 3 will be used. Range 0-30.
                    , Margin:30                                      ; If omitted, 5 will be used. Range 0-30.
                    , TabStops:[50, 80, 100]                         ; If omitted, [50] will be used. This value must be an array.
                    , BorderColor:0xffaabbcc                         ; ARGB
                    , BorderColorLinearGradientStart:0xff16a085      ; ARGB
                    , BorderColorLinearGradientEnd:0xfff4d03f        ; ARGB
                    , BorderColorLinearGradientAngle:45              ; Mode=8 Angle 0(L to R) 90(U to D) 180(R to L) 270(D to U)
                    , BorderColorLinearGradientMode:1                ; Mode=4 Angle 0(L to R) 90(D to U), Range 1-8.
                    , TextColor:0xff112233                           ; ARGB
                    , TextColorLinearGradientStart:0xff00416a        ; ARGB
                    , TextColorLinearGradientEnd:0xffe4e5e6          ; ARGB
                    , TextColorLinearGradientAngle:90                ; Mode=8 Angle 0(L to R) 90(U to D) 180(R to L) 270(D to U)
                    , TextColorLinearGradientMode:1                  ; Mode=4 Angle 0(L to R) 90(D to U), Range 1-8.
                    , BackgroundColor:0xff778899                     ; ARGB
                    , BackgroundColorLinearGradientStart:0xff8DA5D3  ; ARGB
                    , BackgroundColorLinearGradientEnd:0xffF4CFC9    ; ARGB
                    , BackgroundColorLinearGradientAngle:135         ; Mode=8 Angle 0(L to R) 90(U to D) 180(R to L) 270(D to U)
                    , BackgroundColorLinearGradientMode:1            ; Mode=4 Angle 0(L to R) 90(D to U), Range 1-8.
                    , Font:"Font Name"                               ; If omitted, ToolTip's Font will be used. Can specify the font file path.
                    , FontSize:20                                    ; If omitted, 12 will be used.
                    , FontRender:5                                   ; If omitted, 5 will be used. Range 0-5.
                    , FontStyle:"Regular Bold Italic BoldItalic Underline Strikeout"}

       , Option99 := {TargetHWND:""                                  ; If omitted, active window will be used.
                    , CoordMode:"Screen Relative Window Client"      ; If omitted, A_CoordModeToolTip will be used.
                    , Transparent:""                                 ; If omitted, 255 will be used.
                    , MouseNeverCoverToolTip:""                      ; If omitted, 1 will be used.
                    , DistanceBetweenMouseXAndToolTip:""             ; If omitted, 16 will be used. This value can be negative.
                    , DistanceBetweenMouseYAndToolTip:""             ; If omitted, 16 will be used. This value can be negative.
                    , JustCalculateSize:""}                          ; Set to 1, no content will be displayed, just calculate size and return.

       , Style1 := {TextColor:0xffeef8f6
                  , BackgroundColor:0xff1b8dff
                  , FontSize:14}

       , Style2 := {Border:1
                  , Rounded:8
                  , TextColor:0xfff4f4f4
                  , BackgroundColor:0xaa3e3d45
                  , FontSize:14}

       , Style3 := {Border:2
                  , Rounded:0
                  , TextColor:0xffF15839
                  , BackgroundColor:0xffFCEDE6
                  , FontSize:14}

       , Style4 := {Border:10
                  , Rounded:20
                  , BorderColor:0xff604a78
                  , TextColor:0xffF3AE00
                  , BackgroundColor:0xff6A537F
                  , FontSize:20
                  , FontStyle:"Bold Italic"}

       , Style5 := {Border:0
                  , Rounded:5
                  , TextColor:0xffeeeeee
                  , BackgroundColorLinearGradientStart:0xff134E5E
                  , BackgroundColorLinearGradientEnd:0xff326f69
                  , BackgroundColorLinearGradientAngle:0
                  , BackgroundColorLinearGradientMode:1}

       , Style6 := {Border:2
                  , Rounded:5
                  , TextColor:0xffCAE682
                  , BackgroundColor:0xff434343
                  , FontSize:14}

       , Style7 := {Border:20
                  , Rounded:30
                  , Margin:30
                  , BorderColor:0xffaabbcc
                  , TextColor:0xff112233
                  , BackgroundColorLinearGradientStart:0xffF4CFC9
                  , BackgroundColorLinearGradientEnd:0xff8DA5D3
                  , BackgroundColorLinearGradientAngle:0
                  , BackgroundColorLinearGradientMode:1
                  , FontStyle:"BoldItalic"}

       , Style8 := {Border:3
                  , Rounded:30
                  , Margin:30
                  , BorderColorLinearGradientStart:0xffb7407c
                  , BorderColorLinearGradientEnd:0xff3881a7
                  , BorderColorLinearGradientAngle:45
                  , BorderColorLinearGradientMode:1
                  , TextColor:0xffd9d9db
                  , BackgroundColor:0xff26293a}

  ; 直接在 static 中初始化 BTT 会报错，所以只能这样写
  if (BTT="")
    BTT := new BeautifulToolTip()

  return, BTT.ToolTip(Text, X, Y, WhichToolTip
                    ; 如果 Style 是一个内置预设的名称，则使用对应内置预设的值，否则使用 Styles 本身的值。 Options 同理。
                    , %BulitInStyleOrStyles%=""   ? BulitInStyleOrStyles   : %BulitInStyleOrStyles%
                    , %BulitInOptionOrOptions%="" ? BulitInOptionOrOptions : %BulitInOptionOrOptions%)
}

Class BeautifulToolTip
{
  ; 以下这些是类中静态变量。末尾带数字1的，表明最多存在1-20这样的变体。例如 _BTT1 就有 _BTT1 ... _BTT20 共20个类似变量。
  ; pToken, Monitors, ToolTipFontName, DIBWidth, DIBHeight
  ; MouseNeverCoverToolTip, DistanceBetweenMouseXAndToolTip, DistanceBetweenMouseYAndToolTip 
  ; hBTT1（GUI句柄）, hbm1, hdc1, obm1, G1
  ; SavedText1, SavedOptions1, SavedX1, SavedY1, SavedW1, SavedH1, SavedCoordMode1, SavedTargetHWND1
  static DebugMode:=0

  __New()
  {
    if (!this.pToken)
    {
      ; 加速
      SavedBatchLines:=A_BatchLines
      SetBatchLines, -1

      ; 多实例启动 gdi+ 。避免有些人修改内部代码时与他自己的 gdi+ 冲突。
      this.pToken := Gdip_Startup(1)
      if (!this.pToken)
      {
        MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
        ExitApp
      }

      ; 多显示器支持
      this.Monitors := MDMF_Enum()
      ; 获取多显示器各自 DPI 缩放比例
      for hMonitor, v in this.Monitors.Clone()
      {
        if (hMonitor="TotalCount" or hMonitor="Primary")
          continue
        ; https://github.com/Ixiko/AHK-libs-and-classes-collection/blob/e421acb801867edb659a54b7473e6e617f2b267b/libs/g-n/Monitor.ahk
        ; ahk 源码里 A_ScreenDPI 就是只获取了 dpiX ，所以这里保持一致
        osv := StrSplit(A_OSVersion, ".")               ; https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/content/wdm/ns-wdm-_osversioninfoexw
        if (osv[1] < 6 || (osv[1] == 6 && osv[2] < 3))  ; WIN_8- 。Win7 必须用这种方式，否则会出错
        {
          hDC  := DllCall("Gdi32.dll\CreateDC", "Str", hMonitor.name, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
          dpiX := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", hDC, "Int", 88) ; LOGPIXELSX = 88
          DllCall("Gdi32.dll\DeleteDC", "Ptr", hDC)
        }
        else
          DllCall("Shcore.dll\GetDpiForMonitor", "Ptr", hMonitor, "Int", Type, "UIntP", dpiX, "UIntP", dpiY, "UInt")
        this.Monitors[hMonitor].DPIScale := this.NonNull_Ret(dpiX, A_ScreenDPI)/96
      }

      ; 获取整个桌面的分辨率，即使跨显示器
      SysGet, VirtualWidth, 78
      SysGet, VirtualHeight, 79
      this.DIBWidth  := VirtualWidth
      this.DIBHeight := VirtualHeight

      ; 获取 ToolTip 的默认字体
      this.ToolTipFontName := this.Fnt_GetTooltipFontName()

      ; create 20 guis for gdi+
      ; 最多20个 ToolTip ，与原版对应。
      loop, 20
      {
        ; _BTT1（GUI 名称） 与 _hBTT1（GUI 句柄） 都是临时变量，后者被储存了。
        Gui, _BTT%A_Index%: +E0x80000 -Caption +ToolWindow +LastFound +AlwaysOnTop +Hwnd_hBTT%A_Index%
        Gui, _BTT%A_Index%: Show, NA

          this["hBTT" A_Index] := _hBTT%A_Index%
        , this["hbm" A_Index]  := CreateDIBSection(this.DIBWidth, this.DIBHeight)
        , this["hdc" A_Index]  := CreateCompatibleDC()
        , this["obm" A_Index]  := SelectObject(this["hdc" A_Index], this["hbm" A_Index])
        , this["G" A_Index]    := Gdip_GraphicsFromHDC(this["hdc" A_Index])
        , Gdip_SetSmoothingMode(this["G" A_Index], 4)
        , Gdip_SetPixelOffsetMode(this["G" A_Index], 2)  ; 此参数是画出完美圆角矩形的关键
      }
      SetBatchLines, %SavedBatchLines%
    }
    else
      return
  }

  ; new 后得到的变量在销毁后会自动跳这里来运行，因此很适合做自动资源回收。
  __Delete()
  {
    loop, 20
    {
        Gdip_DeleteGraphics(this["G" A_Index])
      , SelectObject(this["hdc" A_Index], this["obm" A_Index])
      , DeleteObject(this["hbm" A_Index])
      , DeleteDC(this["hdc" A_Index])
    }
    Gdip_Shutdown(this.pToken)
  }

  ; 参数默认全部为空只是为了让清空 ToolTip 的语法简洁而已。
  ToolTip(Text:="", X:="", Y:="", WhichToolTip:="", Styles:="", Options:="")
  {
    ; 给出 WhichToolTip 的默认值1，并限制 WhichToolTip 的范围为 1-20
    this.NonNull(WhichToolTip, 1, 1, 20)
    ; 检查并解析 Styles 与 Options 。无论不传参、部分传参、完全传参，此函数均能正确返回所需参数。
    O:=this._CheckStylesAndOptions(Styles, Options)

    ; 判断显示内容是否发生变化。由于前面给了 Options 一个默认值，所以首次进来时下面的 O.Options!=SavedOptions 是必然成立的。
    FirstCallOrNeedToUpdate:=(Text       != this["SavedText" WhichToolTip] 
                           or O.Checksum != this["SavedOptions" WhichToolTip])

    if (Text="")
    {
      ; 清空 ToolTip
      Gdip_GraphicsClear(this["G" WhichToolTip])
      UpdateLayeredWindow(this["hBTT" WhichToolTip], this["hdc" WhichToolTip])
      ; 清空变量
        this["SavedText" WhichToolTip]        := ""
      , this["SavedOptions" WhichToolTip]     := ""
      , this["SavedX" WhichToolTip]           := ""
      , this["SavedY" WhichToolTip]           := ""
      , this["SavedW" WhichToolTip]           := ""
      , this["SavedH" WhichToolTip]           := ""
      , this["SavedTargetHWND" WhichToolTip]  := ""
      , this["SavedCoordMode" WhichToolTip]   := ""
      , this["SavedTransparent" WhichToolTip] := ""

      return
    }
    else if (FirstCallOrNeedToUpdate)  ; First Call or NeedToUpdate
    {
      ; 加速
      SavedBatchLines:=A_BatchLines
      SetBatchLines, -1

      ; 获取目标尺寸，用于计算文本大小时加上宽高限制，否则目标为屏幕时，可能计算出超宽超高的大小，导致无法显示。
        TargetSize:=this._CalculateDisplayPosition(X, Y, "", "", O, GetTargetSize:=1)
      ; 使得 文字区域+边距+细边框 不会超过目标宽度。
      , MaxTextWidth:=TargetSize.W - O.Margin*2 - O.Border*2
      ; 使得 文字区域+边距+细边框 不会超过目标高度的90%。
      ; 之所以高度限制90%是因为两个原因，1是留出一些上下的空白，避免占满全屏，鼠标点不了其它地方，难以退出。
      ; 2是在计算文字区域时，即使已经给出了宽高度限制，且因为自动换行的原因，宽度的返回值通常在范围内，但高度的返回值偶尔还是会超过1行，所以提前留个余量。
      , MaxTextHeight:=(TargetSize.H*90)//100 - O.Margin*2 - O.Border*2
      ; 为 _TextToGraphics 计算区域提供高宽限制。
      , O.Width:=MaxTextWidth, O.Height:=MaxTextHeight
      ; 计算文字显示区域 TextArea = x|y|width|height|chars|lines
      , TextArea:=StrSplit(this._TextToGraphics(this["G" WhichToolTip], Text, O, Measure:=1), "|")
      ; 这里务必向上取整。
      ; 向上的原因是，例如 1.2 如果四舍五入为 1，那么最右边的字符可能会显示不全。
      ; 取整的原因是，不取整无法画出完美的圆角矩形。
      ; 当使用 AutoTrim 选项，即自动将超出范围的文字显示为 “...” 时，此时返回的宽高度值是不包含 “...” 的。
      ; 所以加上 “...” 的宽高度后，仍然可能超限。故需要再次检查并限制。
      ; 一旦宽高度超过了限制（CreateDIBSection() 时创建的大小），会导致 UpdateLayeredWindow() 画不出图像来。
      , TextWidth:=Min(Ceil(TextArea[3]), MaxTextWidth)
      , TextHeight:=Min(Ceil(TextArea[4]), MaxTextHeight)

      , RectWidth:=TextWidth+O.Margin*2                                   ; 文本+边距。
      , RectHeight:=TextHeight+O.Margin*2
      , RectWithBorderWidth:=RectWidth+O.Border*2                         ; 文本+边距+细边框。
      , RectWithBorderHeight:=RectHeight+O.Border*2
      ; 圆角超过矩形宽或高的一半时，会画出畸形的圆，所以这里验证并限制一下。
      , R:=(O.Rounded>Min(RectWidth, RectHeight)//2) ? Min(RectWidth, RectHeight)//2 : O.Rounded

      if (O.JustCalculateSize!=1)
      {
        ; 画之前务必清空画布，否则会出现异常。
        Gdip_GraphicsClear(this["G" WhichToolTip])

        ; 准备细边框画刷
        if (O.BCLGA!="" and O.BCLGM and O.BCLGS and O.BCLGE)                    ; 渐变画刷 画细边框
          pBrushBorder := this._CreateLinearGrBrush(O.BCLGA, O.BCLGM, O.BCLGS, O.BCLGE
                                                  , 0, 0, RectWithBorderWidth, RectWithBorderHeight)
        else
          pBrushBorder := Gdip_BrushCreateSolid(O.BorderColor)                  ; 纯色画刷 画细边框

        if (O.Border>0)
          switch, R
          {
            ; 圆角为0则使用矩形画。不单独处理，会画出显示异常的图案。
            case, "0": Gdip_FillRectangle(this["G" WhichToolTip]                ; 矩形细边框
            , pBrushBorder, 0, 0, RectWithBorderWidth, RectWithBorderHeight)
            Default  : Gdip_FillRoundedRectanglePath(this["G" WhichToolTip]     ; 圆角细边框
            , pBrushBorder, 0, 0, RectWithBorderWidth, RectWithBorderHeight, R)
          }

        ; 准备文本框画刷
        if (O.BGCLGA!="" and O.BGCLGM and O.BGCLGS and O.BGCLGE)                ; 渐变画刷 画文本框
          pBrushBackground := this._CreateLinearGrBrush(O.BGCLGA, O.BGCLGM, O.BGCLGS, O.BGCLGE
                                                      , O.Border, O.Border, RectWidth, RectHeight)
        else
          pBrushBackground := Gdip_BrushCreateSolid(O.BackgroundColor)          ; 纯色画刷 画文本框

        switch, R
        {
          case, "0": Gdip_FillRectangle(this["G" WhichToolTip]                  ; 矩形文本框
          , pBrushBackground, O.Border, O.Border, RectWidth, RectHeight)
          Default  : Gdip_FillRoundedRectanglePath(this["G" WhichToolTip]       ; 圆角文本框
          , pBrushBackground, O.Border, O.Border, RectWidth, RectHeight
          , (R>O.Border) ? R-O.Border : R)                                      ; 确保内外圆弧看起来同心
        }

        ; 清理画刷
        Gdip_DeleteBrush(pBrushBorder)
        Gdip_DeleteBrush(pBrushBackground)

        ; 计算居中显示坐标。由于 TextArea 返回的文字范围右边有很多空白，所以这里的居中坐标并不精确。
        O.X:=O.Border+O.Margin, O.Y:=O.Border+O.Margin, O.Width:=TextWidth, O.Height:=TextHeight

        ; 如果显示区域过小，文字无法完全显示，则将待显示文本最后4个字符替换为4个英文省略号，表示显示不完全。
        ; 虽然有 GdipSetStringFormatTrimming 函数可以设置末尾显示省略号，但它偶尔需要增加额外的宽度才能显示出来。
        ; 由于难以判断是否需要增加额外宽度，以及需要增加多少等等问题，所以直接用这种方式自己实现省略号的显示。
        ; 之所以选择替换最后4个字符，是因为一般替换掉最后2个字符，才能确保至少一个省略号显示出来。
        ; 为了应对意外情况，以及让省略号更加明显一点，所以选择替换最后4个。
        ; 原始的 Text 需要用于显示前的比对，所以不能改原始值，必须用 TempText 。
        if (TextArea[5]<StrLen(Text))
          TempText:=TextArea[5]>4 ? SubStr(Text, 1 ,TextArea[5]-4) "…………" : SubStr(Text, 1 ,1) "…………"
        else
          TempText:=Text

        ; 写字到框上。这个函数使用 O 中的 X,Y 去调整文字的位置。
        this._TextToGraphics(this["G" WhichToolTip], TempText, O)

        ; 调试用，可显示计算得到的文字范围。
        if (this.DebugMode)
        {
          pBrush := Gdip_BrushCreateSolid(0x20ff0000)
          Gdip_FillRectangle(this["G" WhichToolTip], pBrush, O.Border+O.Margin, O.Border+O.Margin, TextWidth, TextHeight)
          Gdip_DeleteBrush(pBrush)
        }

        ; 返回文本框不超出目标范围（比如屏幕范围）的最佳坐标。
        this._CalculateDisplayPosition(X, Y, RectWithBorderWidth, RectWithBorderHeight, O)

        ; 显示
        UpdateLayeredWindow(this["hBTT" WhichToolTip], this["hdc" WhichToolTip]
                          , X, Y, RectWithBorderWidth, RectWithBorderHeight, O.Transparent)

        ; 因为 BTT 总会在使用一段时间后，被不明原因的置底，导致显示内容被其它窗口遮挡，以为没有正常显示，所以这里提升Z序到最上面！
        ; 已测试过，此方法效率极高，远超 WinSet, Top 命令。
        ; hWndInsertAfter
        ;   HWND_TOPMOST:=-1
        ; uFlags
        ;   SWP_NOSIZE:=0x0001
        ;   SWP_NOMOVE:=0x0002
        ;   SWP_NOREDRAW:=0x0008
        ;   SWP_NOACTIVATE:=0x0010
        ;   SWP_NOOWNERZORDER:=0x0200
        ;   SWP_NOSENDCHANGING:=0x0400
        ;   SWP_DEFERERASE:=0x2000
        ;   SWP_ASYNCWINDOWPOS:=0x4000
        DllCall("SetWindowPos", "ptr", this["hBTT" WhichToolTip], "ptr", -1, "int", 0, "int", 0, "int", 0, "int", 0, "uint", 26139)
      }

      ; 保存参数值，以便之后比对参数值是否改变
        this["SavedText" WhichToolTip]        := Text
      , this["SavedOptions" WhichToolTip]     := O.Checksum
      , this["SavedX" WhichToolTip]           := X   ; 这里的 X,Y 是经过 _CalculateDisplayPosition() 计算后的新 X,Y
      , this["SavedY" WhichToolTip]           := Y
      , this["SavedW" WhichToolTip]           := RectWithBorderWidth
      , this["SavedH" WhichToolTip]           := RectWithBorderHeight
      , this["SavedTargetHWND" WhichToolTip]  := O.TargetHWND
      , this["SavedCoordMode" WhichToolTip]   := O.CoordMode
      , this["SavedTransparent" WhichToolTip] := O.Transparent

      SetBatchLines, %SavedBatchLines%
    }
    ; x,y 任意一个跟随鼠标位置 或 使用窗口或客户区模式（窗口大小可能发生改变或者窗口发生移动）
    ; 或 目标窗口发生变化 或 坐标模式发生变化
    ; 或 整体透明度发生变化 这5种情况可能需要移动位置，需要进行坐标计算。
    else if ((X="" or Y="") or O.CoordMode!="Screen"
          or O.TargetHWND!=this.SavedTargetHWND or O.CoordMode!=this.SavedCoordMode
          or O.Transparent!=this.SavedTransparent)
    {
      ; 返回文本框不超出目标范围（比如屏幕范围）的最佳坐标。
      this._CalculateDisplayPosition(X, Y, this["SavedW" WhichToolTip], this["SavedH" WhichToolTip], O)
      ; 判断文本框 显示位置
      ; 或 显示透明度 是否发生改变
      if (X!=this["SavedX" WhichToolTip] or Y!=this["SavedY" WhichToolTip]
      or  O.Transparent!=this.SavedTransparent)
      {
        ; 显示
        UpdateLayeredWindow(this["hBTT" WhichToolTip], this["hdc" WhichToolTip]
                          , X, Y, this["SavedW" WhichToolTip], this["SavedH" WhichToolTip], O.Transparent)

        ; 保存新的位置
          this["SavedX" WhichToolTip]           := X
        , this["SavedY" WhichToolTip]           := Y
        , this["SavedTargetHWND" WhichToolTip]  := O.TargetHWND
        , this["SavedCoordMode" WhichToolTip]   := O.CoordMode
        , this["SavedTransparent" WhichToolTip] := O.Transparent
      }
    }

    ret:={Hwnd : this["hBTT" WhichToolTip]
        , X    : X
        , Y    : Y
        , W    : this["SavedW" WhichToolTip]
        , H    : this["SavedH" WhichToolTip]}
    return, ret
  }

  ; 为了统一参数的传输，以及特殊模式的设置，修改了 gdip 库的 Gdip_TextToGraphics() 函数。
  _TextToGraphics(pGraphics, Text, Options, Measure:=0)
  {
    static Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"

    ; 设置字体样式
    Style := 0
    for eachStyle, valStyle in StrSplit(Styles, "|")
    {
      if InStr(Options.FontStyle, valStyle)
        Style |= (valStyle != "StrikeOut") ? (A_Index-1) : 8
    }

    if (FileExist(Options.Font))  ; 加载未安装的本地字体
    {
      hFontCollection := Gdip_NewPrivateFontCollection()
      hFontFamily := Gdip_CreateFontFamilyFromFile(Options.Font, hFontCollection)
    }
    if !hFontFamily               ; 加载已安装的字体
      hFontFamily := Gdip_FontFamilyCreate(Options.Font)
    if !hFontFamily               ; 加载默认字体
      hFontFamily := Gdip_FontFamilyCreateGeneric(1)
    ; 根据 DPI 缩放比例自动调整字号
    hFont := Gdip_FontCreate(hFontFamily, Options.FontSize * Options.DPIScale, Style, Unit:=0)

    ; 设置文字格式化样式，LineLimit = 0x00002000 只显示完整的行。
    ; 比如最后一行，因为布局高度有限，只能显示出一半，此时就会让它完全不显示。
    ; 直接使用 Gdip_StringFormatGetGeneric(1) 包含 LineLimit 设置，同时可以实现左右空白区域最小化。
    ; 但这样有个副作用，那就是无法精确的设置文本框的宽度了，同时最右边文字的间距会被压缩。
    ; 例如指定宽度800，可能返回的宽度是793，因为右边没有用空白补上。
    ; 好处是右边几乎没有空白区域，左边也没有，所以接近完美的实现文字居中了。
    ; hStringFormat := Gdip_StringFormatCreate(0x00002000)
    ; if !hStringFormat
      hStringFormat := Gdip_StringFormatGetGeneric(1)

    ; 准备文本画刷
    if (Options.TCLGA!="" and Options.TCLGM and Options.TCLGS and Options.TCLGE
        and Options.Width and Options.Height)             ; 渐变画刷
    {
      pBrush := this._CreateLinearGrBrush(Options.TCLGA, Options.TCLGM, Options.TCLGS, Options.TCLGE
                                        , this.NonNull_Ret(Options.X, 0), this.NonNull_Ret(Options.Y, 0)
                                        , Options.Width, Options.Height)
    }
    else
      pBrush := Gdip_BrushCreateSolid(Options.TextColor)  ; 纯色画刷

    ; 检查参数是否齐全
    if !(hFontFamily && hFont && hStringFormat && pBrush && pGraphics)
    {
      E := !pGraphics ? -2 : !hFontFamily ? -3 : !hFont ? -4 : !hStringFormat ? -5 : !pBrush ? -6 : 0
      if pBrush
        Gdip_DeleteBrush(pBrush)
      if hStringFormat
        Gdip_DeleteStringFormat(hStringFormat)
      if hFont
        Gdip_DeleteFont(hFont)
      if hFontFamily
        Gdip_DeleteFontFamily(hFontFamily)
      if hFontCollection
        Gdip_DeletePrivateFontCollection(hFontCollection)
      return E
    }

    TabStops := []
    for k, v in Options.TabStops
      TabStops.Push(v * Options.DPIScale)
    Gdip_SetStringFormatTabStops(hStringFormat, TabStops)                      ; 设置 TabStops
    Gdip_SetStringFormatAlign(hStringFormat, Align:=0)                         ; 设置左对齐
    Gdip_SetTextRenderingHint(pGraphics, Options.FontRender)                   ; 设置渲染模式
    CreateRectF(RC
              , this.NonNull_Ret(Options.X, 0)                                 ; x,y 需要至少为0
              , this.NonNull_Ret(Options.Y, 0)
              , Options.Width, Options.Height)                                 ; 宽高可以为空
    returnRC := Gdip_MeasureString(pGraphics, Text, hFont, hStringFormat, RC)  ; 计算大小

    if !Measure
      _E := Gdip_DrawString(pGraphics, Text, hFont, hStringFormat, pBrush, RC)

    Gdip_DeleteBrush(pBrush)
    Gdip_DeleteFont(hFont)
    Gdip_DeleteStringFormat(hStringFormat)
    Gdip_DeleteFontFamily(hFontFamily)
    if hFontCollection
      Gdip_DeletePrivateFontCollection(hFontCollection)
    return _E ? _E : returnRC
  }

  _CreateLinearGrBrush(Angle, Mode, StartColor, EndColor, x, y, w, h)
  {
    ; Mode=8 Angle 0=左到右 90=上到下 180=右到左 270=下到上
    ; Mode=3 Angle 0=左到右 90=近似上到下
    ; Mode=4 Angle 0=左到右 90=下到上
    switch, Mode
    {
      case, 1,3,5,7:pBrush:=Gdip_CreateLinearGrBrush(x, y, x+w, y, StartColor, EndColor)
      case, 2,4,6,8:pBrush:=Gdip_CreateLinearGrBrush(x, y+h//2, x+w, y+h//2, StartColor, EndColor)
    }
    switch, Mode
    {
      case, 1,2: Gdip_RotateLinearGrBrushTransform(pBrush, Angle, 0)  ; 性能比模式3、4高10倍左右
      case, 3,4: Gdip_RotateLinearGrBrushTransform(pBrush, Angle, 1)
      case, 5,6: Gdip_RotateLinearGrBrushAtCenter(pBrush, Angle, 0)
      case, 7,8: Gdip_RotateLinearGrBrushAtCenter(pBrush, Angle, 1)   ; 可绕中心旋转
    }
    return, pBrush
  }

  ; 此函数确保传入空值或者错误值均可返回正确值。
  _CheckStylesAndOptions(Styles, Options)
  {
      O := {}
    , O.Border          := this.NonNull_Ret(Styles.Border         , 1                   , 0 , 20)  ; 细边框    默认1 0-20
    , O.Rounded         := this.NonNull_Ret(Styles.Rounded        , 3                   , 0 , 30)  ; 圆角      默认3 0-30
    , O.Margin          := this.NonNull_Ret(Styles.Margin         , 5                   , 0 , 30)  ; 边距      默认5 0-30
    , O.TabStops        := this.NonNull_Ret(Styles.TabStops       , [50]                , "", "")  ; 制表符宽  默认[50]
    , O.TextColor       := this.NonNull_Ret(Styles.TextColor      , 0xff575757          , "", "")  ; 文本色    默认0xff575757
    , O.BackgroundColor := this.NonNull_Ret(Styles.BackgroundColor, 0xffffffff          , "", "")  ; 背景色    默认0xffffffff
    , O.Font            := this.NonNull_Ret(Styles.Font           , this.ToolTipFontName, "", "")  ; 字体      默认与 ToolTip 一致
    , O.FontSize        := this.NonNull_Ret(Styles.FontSize       , 12                  , "", "")  ; 字号      默认12
    , O.FontRender      := this.NonNull_Ret(Styles.FontRender     , 5                   , 0 , 5 )  ; 渲染模式  默认5 0-5
    , O.FontStyle       := Styles.FontStyle                                                        ; 字体样式  默认无

    ; 名字太长，建个缩写副本。
    , O.BCLGS  := Styles.BorderColorLinearGradientStart                                            ; 细边框渐变色    默认无
    , O.BCLGE  := Styles.BorderColorLinearGradientEnd                                              ; 细边框渐变色    默认无
    , O.BCLGA  := Styles.BorderColorLinearGradientAngle                                            ; 细边框渐变角度  默认无
    , O.BCLGM  := this.NonNull_Ret(Styles.BorderColorLinearGradientMode, "", 1, 8)                 ; 细边框渐变模式  默认无 1-8

    ; 名字太长，建个缩写副本。
    , O.TCLGS  := Styles.TextColorLinearGradientStart                                              ; 文本渐变色      默认无
    , O.TCLGE  := Styles.TextColorLinearGradientEnd                                                ; 文本渐变色      默认无
    , O.TCLGA  := Styles.TextColorLinearGradientAngle                                              ; 文本渐变角度    默认无
    , O.TCLGM  := this.NonNull_Ret(Styles.TextColorLinearGradientMode, "", 1, 8)                   ; 文本渐变模式    默认无 1-8

    ; 名字太长，建个缩写副本。
    , O.BGCLGS := Styles.BackgroundColorLinearGradientStart                                        ; 背景渐变色      默认无
    , O.BGCLGE := Styles.BackgroundColorLinearGradientEnd                                          ; 背景渐变色      默认无
    , O.BGCLGA := Styles.BackgroundColorLinearGradientAngle                                        ; 背景渐变角度    默认无
    , O.BGCLGM := this.NonNull_Ret(Styles.BackgroundColorLinearGradientMode, "", 1, 8)             ; 背景渐变模式    默认无 1-8

    ; a:=0xaabbccdd 下面是运算规则
    ; a>>16    = 0xaabb
    ; a>>24    = 0xaa
    ; a&0xffff = 0xccdd
    ; a&0xff   = 0xdd
    ; 0x88<<16 = 0x880000
    ; 0x880000+0xbbcc = 0x88bbcc
    , BlendedColor2 := (O.TCLGS and O.TCLGE and O.TCLGD) ? O.TCLGS : O.TextColor                   ; 使用文本渐变色替换文本色用于混合
    , BlendedColor  := ((O.BackgroundColor>>24)<<24) + (BlendedColor2&0xffffff)                    ; 混合色    背景色的透明度与文本色混合
    , O.BorderColor := this.NonNull_Ret(Styles.BorderColor , BlendedColor      , "", "")           ; 细边框色  默认混合色

    , O.TargetHWND  := this.NonNull_Ret(Options.TargetHWND , WinExist("A")     , "", "")           ; 目标句柄    默认活动窗口
    , O.CoordMode   := this.NonNull_Ret(Options.CoordMode  , A_CoordModeToolTip, "", "")           ; 坐标模式    默认与 ToolTip 一致
    , O.Transparent := this.NonNull_Ret(Options.Transparent, 255               , 0 , 255)          ; 整体透明度  默认255
    , O.MouseNeverCoverToolTip          := this.NonNull_Ret(Options.MouseNeverCoverToolTip         , 1 , 0 , 1 )   ; 鼠标永不遮挡文本框
    , O.DistanceBetweenMouseXAndToolTip := this.NonNull_Ret(Options.DistanceBetweenMouseXAndToolTip, 16, "", "")   ; 鼠标与文本框的X距离
    , O.DistanceBetweenMouseYAndToolTip := this.NonNull_Ret(Options.DistanceBetweenMouseYAndToolTip, 16, "", "")   ; 鼠标与文本框的Y距离
    , O.JustCalculateSize               := Options.JustCalculateSize                                               ; 仅计算显示尺寸并返回

    ; 难以比对两个对象是否一致，所以造一个变量比对。
    ; 这里的校验因素，必须是那些改变后会使画面内容也产生变化的因素。
    ; 所以没有 TargetHWND 和 CoordMode 和 Transparent ，因为这三个因素只影响位置。
    for k, v in O.TabStops
      TabStops .= v ","
    O.Checksum := O.Border          "|" O.Rounded  "|" O.Margin     "|" TabStops    "|"
                . O.BorderColor     "|" O.BCLGS    "|" O.BCLGE      "|" O.BCLGA     "|" O.BCLGM  "|"
                . O.TextColor       "|" O.TCLGS    "|" O.TCLGE      "|" O.TCLGA     "|" O.TCLGM  "|"
                . O.BackgroundColor "|" O.BGCLGS   "|" O.BGCLGE     "|" O.BGCLGA    "|" O.BGCLGM "|"
                . O.Font            "|" O.FontSize "|" O.FontRender "|" O.FontStyle
    return, O
  }

  ; 此函数确保文本框显示位置不会超出目标范围。
  ; 使用 ByRef X, ByRef Y 返回不超限的位置。
  _CalculateDisplayPosition(ByRef X, ByRef Y, W, H, Options, GetTargetSize:=0)
  {
      VarSetCapacity(Point, 8, 0)
    ; 获取鼠标位置
    , DllCall("GetCursorPos", "Ptr", &Point)
    , MouseX := NumGet(Point, 0, "Int"), MouseY := NumGet(Point, 4, "Int")

    ; x,y 即 ToolTip 显示的位置。
    ; x,y 同时为空表明完全跟随鼠标。
    ; x,y 单个为空表明只跟随鼠标横向或纵向移动。
    ; x,y 都有值，则说明被钉在屏幕或窗口或客户区的某个位置。
    ; MouseX,MouseY 是鼠标的屏幕坐标。
    ; DisplayX,DisplayY 是 x,y 经过转换后的屏幕坐标。
    ; 以下过程 x,y 不发生变化， DisplayX,DisplayY 储存转换好的屏幕坐标。
    ; 不要尝试合并分支 (X="" and Y="") 与 (A_CoordModeToolTip = "Screen")。
    ; 因为存在把坐标模式设为 Window 或 Client 但又同时不给出 x,y 的情况！！！！！！
    if (X="" and Y="")
    { ; 没有给出 x,y 则使用鼠标坐标
        DisplayX     := MouseX
      , DisplayY     := MouseY
      ; 根据坐标判断在第几个屏幕里，并获得对应屏幕边界。
      ; 使用 MONITOR_DEFAULTTONEAREST 设置，可以在给出的点不在任何显示器内时，返回距离最近的显示器。
      ; 这样可以修正使用 1920,1080 这种错误的坐标，导致返回空值，导致画图失败的问题。
      ; 为什么 1920,1080 是错误的呢？因为 1920 是宽度，而坐标起点是0，所以最右边坐标值是 1919，最下面是 1079。
      , hMonitor     := MDMF_FromPoint(DisplayX, DisplayY, MONITOR_DEFAULTTONEAREST:=2)
      , TargetLeft   := this.Monitors[hMonitor].Left
      , TargetTop    := this.Monitors[hMonitor].Top
      , TargetRight  := this.Monitors[hMonitor].Right
      , TargetBottom := this.Monitors[hMonitor].Bottom
      , TargetWidth  := TargetRight-TargetLeft
      , TargetHeight := TargetBottom-TargetTop
      ; 将对应屏幕的 DPIScale 存入 Options 中。
      , Options.DPIScale := this.Monitors[hMonitor].DPIScale
    }
      ; 已给出 x和y 或x 或y，都会走到下面3个分支去。
    else if (Options.CoordMode  = "Window" or Options.CoordMode  = "Relative")
    { ; 已给出 x或y 且使用窗口坐标
        WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " Options.TargetHWND

        XInScreen    := WinX+X
      , YInScreen    := WinY+Y
      , TargetLeft   := WinX
      , TargetTop    := WinY
      , TargetWidth  := WinW
      , TargetHeight := WinH
      , TargetRight  := TargetLeft+TargetWidth
      , TargetBottom := TargetTop+TargetHeight
      , DisplayX     := (X="") ? MouseX : XInScreen
      , DisplayY     := (Y="") ? MouseY : YInScreen
      , hMonitor     := MDMF_FromPoint(DisplayX, DisplayY, MONITOR_DEFAULTTONEAREST:=2)
      , Options.DPIScale := this.Monitors[hMonitor].DPIScale
    }
    else if (Options.CoordMode  = "Client")
    { ; 已给出 x或y 且使用客户区坐标
        VarSetCapacity(ClientArea, 16, 0)
      , DllCall("GetClientRect", "Ptr", Options.TargetHWND, "Ptr", &ClientArea)
      , DllCall("ClientToScreen", "Ptr", Options.TargetHWND, "Ptr", &ClientArea)
      , ClientX      := NumGet(ClientArea, 0, "Int")
      , ClientY      := NumGet(ClientArea, 4, "Int")
      , ClientW      := NumGet(ClientArea, 8, "Int")
      , ClientH      := NumGet(ClientArea, 12, "Int")

        XInScreen    := ClientX+X
      , YInScreen    := ClientY+Y
      , TargetLeft   := ClientX
      , TargetTop    := ClientY
      , TargetWidth  := ClientW
      , TargetHeight := ClientH
      , TargetRight  := TargetLeft+TargetWidth
      , TargetBottom := TargetTop+TargetHeight
      , DisplayX     := (X="") ? MouseX : XInScreen
      , DisplayY     := (Y="") ? MouseY : YInScreen
      , hMonitor     := MDMF_FromPoint(DisplayX, DisplayY, MONITOR_DEFAULTTONEAREST:=2)
      , Options.DPIScale := this.Monitors[hMonitor].DPIScale
    }
    else ; 这里必然 A_CoordModeToolTip = "Screen"
    { ; 已给出 x或y 且使用屏幕坐标
        DisplayX     := (X="") ? MouseX : X
      , DisplayY     := (Y="") ? MouseY : Y
      , hMonitor     := MDMF_FromPoint(DisplayX, DisplayY, MONITOR_DEFAULTTONEAREST:=2)
      , TargetLeft   := this.Monitors[hMonitor].Left
      , TargetTop    := this.Monitors[hMonitor].Top
      , TargetRight  := this.Monitors[hMonitor].Right
      , TargetBottom := this.Monitors[hMonitor].Bottom
      , TargetWidth  := TargetRight-TargetLeft
      , TargetHeight := TargetBottom-TargetTop
      , Options.DPIScale := this.Monitors[hMonitor].DPIScale
    }

    if (GetTargetSize=1)
    {
        TargetSize   := []
      , TargetSize.X := TargetLeft
      , TargetSize.Y := TargetTop
      ; 一个窗口，有各种各样的方式可以让自己的高宽超过屏幕高宽。
      ; 例如最大化的时候，看起来刚好填满了屏幕，应该是1920*1080，但实际获取会发现是1936*1096。
      ; 还可以通过拖动窗口边缘调整大小的方式，让它变1924*1084。
      ; 还可以直接在创建窗口的时候，指定一个数值，例如3000*3000。
      ; 由于设计的时候， DIB 最大就是多个屏幕大小的总和。
      ; 当造出一个超过屏幕大小总和的窗口，又使用了 A_CoordModeToolTip = "Window" 之类的参数，同时待显示文本单行又超级长。
      ; 此时 (显示宽高 = 窗口宽高) > DIB宽高，会导致 UpdateLayeredWindow() 显示失败。
      ; 所以这里做一下限制。
      , TargetSize.W := Min(TargetWidth, this.DIBWidth)
      , TargetSize.H := Min(TargetHeight, this.DIBHeight)
      return, TargetSize
    }

      DPIScale := Options.DPIScale
    ; 为跟随鼠标显示的文本框增加一个距离，避免鼠标和文本框挤一起发生遮挡。
    ; 因为前面需要用到原始的 DisplayX 和 DisplayY 进行计算，所以在这里才增加距离。
    , DisplayX := (X="") ? DisplayX+Options.DistanceBetweenMouseXAndToolTip*DPIScale : DisplayX
    , DisplayY := (Y="") ? DisplayY+Options.DistanceBetweenMouseYAndToolTip*DPIScale : DisplayY

    ; 处理目标边缘（右和下）的情况，让文本框可以贴边显示，不会超出目标外。
    , DisplayX := (DisplayX+W>=TargetRight)  ? TargetRight-W  : DisplayX
    , DisplayY := (DisplayY+H>=TargetBottom) ? TargetBottom-H : DisplayY
    ; 处理目标边缘（左和上）的情况，让文本框可以贴边显示，不会超出目标外。
    ; 不建议合并代码，理解会变得困难。
    , DisplayX := (DisplayX<TargetLeft) ? TargetLeft : DisplayX
    , DisplayY := (DisplayY<TargetTop)  ? TargetTop  : DisplayY

    ; 处理鼠标遮挡文本框的情况（即鼠标跑到文本框坐标范围内了）。这里要做测试的话，需要测试5种情况。
    ; X跟随 Y跟随。
    ; X跟随 Y固定。0和1919都要测
    ; Y跟随 X固定。0和1079都要测
    ; X固定 Y固定。此种情况文本框可被鼠标遮挡，无需测试。
    if  (Options.MouseNeverCoverToolTip=1
    and (X="" or Y="")
    and MouseX>=DisplayX and MouseY>=DisplayY and MouseX<=DisplayX+W and MouseY<=DisplayY+H)
    {
      ; MouseY-H-16 是往上弹，应对在左下角和右下角的情况。
      ; MouseY+H+16 是往下弹，应对在右上角和左上角的情况。
      ; 这里不要去用 Abs(Options.DistanceBetweenMouseYAndToolTip) 替代 16。因为当前者很大时，显示效果不好。
      ; 优先往上弹，如果不超限，则上弹。如果超限则往下弹，下弹超限，则不弹。
      DisplayY := MouseY-H-16>=TargetTop ? MouseY-H-16 : MouseY+H+16<=TargetBottom ? MouseY+16 : DisplayY
    }

    ; 使用 ByRef 变量特性返回计算得到的 X和Y
    X := DisplayX , Y := DisplayY
  }
  
  ; https://autohotkey.com/boards/viewtopic.php?f=6&t=4379
  ; jballi's Fnt Library
  Fnt_GetTooltipFontName()
  {
    static LF_FACESIZE:=32  ;-- In TCHARS
    return StrGet(this.Fnt_GetNonClientMetrics()+(A_IsUnicode ? 316:220)+28,LF_FACESIZE)
  }

  Fnt_GetNonClientMetrics()
  {
    static Dummy15105062
      ,SPI_GETNONCLIENTMETRICS:=0x29
      ,NONCLIENTMETRICS

    ;-- Set the size of NONCLIENTMETRICS structure
    cbSize:=A_IsUnicode ? 500:340
    if (((GV:=DllCall("GetVersion"))&0xFF . "." . GV>>8&0xFF)>=6.0)  ;-- Vista+
      cbSize+=4

    ;-- Create and initialize NONCLIENTMETRICS structure
    VarSetCapacity(NONCLIENTMETRICS,cbSize,0)
    NumPut(cbSize,NONCLIENTMETRICS,0,"UInt")

    ;-- Get nonclient metrics parameter
    if !DllCall("SystemParametersInfo"
      ,"UInt",SPI_GETNONCLIENTMETRICS
      ,"UInt",cbSize
      ,"Ptr",&NONCLIENTMETRICS
      ,"UInt",0)
      return false

    ;-- Return to sender
    return &NONCLIENTMETRICS
  }
  
  #IncludeAgain %A_LineFile%\..\NonNull.ahk
}

#Include %A_LineFile%\..\Gdip_All.ahk