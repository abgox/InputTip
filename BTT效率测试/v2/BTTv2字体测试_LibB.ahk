;原作者: telppa
;原作者GitHub: https://github.com/telppa/BeautifulToolTip.git
;V2版本协作者: liuyi91
;V2版本协作者GitHub: https://github.com/liuyi91/ahkv2lib-.git
;V2版本协助者: thqby
;V2版本协助者GitHub: https://github.com/thqby/
#Requires AutoHotkey v2.0
#SingleInstance Force
;SetBatchLines -1
#Include BTTv2.ahk ;这里手动引入BeautifulToolTipV2(BTTv2.ahk)文件

global onOff := 0
global index := 1

测试字体样式是否能使用变量:= 70
字体样式群() ;开始运行一次 () 里面的内容

;MsgBox "测试是否运行到这里？"

字体样式群() {
global OwnzztooltipStyle1 := {Border:0
  , TextColorLinearGradientStart:0xffF3AE00        ; ARGB
  , TextColorLinearGradientEnd:0xffF4CFC9          ; ARGB
  , TextColorLinearGradientAngle:90  
  , TextColorLinearGradientMode:2
  , FontSize:测试字体样式是否能使用变量
  ;, FontRender:5
  , TextColor:0xffF3AE00    ;0xffd9d9db
  , BackgroundColor:0x00000000  ;0xff26293a
  , FontStyle:"Bold"
  }

global OwnzztooltipStyle2 := {Border:0
    ; , TextColorLinearGradientStart:0xffF4CFC9        ; ARGB
    ; , TextColorLinearGradientEnd:0xffe4e5e6          ; ARGB
    ; , TextColorLinearGradientAngle:90  
    ; , TextColorLinearGradientMode:2
    , FontSize:70
    ;, FontRender:5
    , TextColor:0xffF3AE00    ;0xffd9d9db
    , BackgroundColor:0x00000000  ;0xff26293a
    , FontStyle:"Bold"
    }

    ;MsgBox "载入完毕"

global OwnzztooltipStyle3 := {Border:0
      ; , TextColorLinearGradientStart:0xffF3AE00        ; ARGB
      ; , TextColorLinearGradientEnd:0xffe4e5e6          ; ARGB
      ; , TextColorLinearGradientAngle:90  
      ; , TextColorLinearGradientMode:2
      , FontSize:70
      ;, FontRender:5
      , TextColor:0xffF3AE00    ;0xffd9d9db
      , BackgroundColor:0x00000000  ;0xff26293a
      , FontStyle:"Bold"
      }
    }
      

btttxt:="㊥ⒺⒶ"
chars := StrSplit(btttxt)

;Ins::
  {
    global onOff := !onOff
    if (onOff = 1)
      SetTimer runV2, 1000
    if (onOff = 0) {
      SetTimer runV2, 0
      OwnzztooltipEnd()
    }
    Return
  }

  runV2()
  {
    global chars, index, OwnzztooltipStyle1, 测试字体样式是否能使用变量
    显示字符 := chars[index] ;这里只是方便为了展示, 或许写死比较好
    字体样式 := "OwnzztooltipStyle" . index ;这个字体样式不能使用变量(出现报错)，所以只能写死
    测试字体样式是否能使用变量:= Random(25, 70) ;这个变量需要在第一行声明global
    字体样式群() ;这里只是为了刷新一下字体样式

    ToolTip "btttxt: " btttxt "`n显示字符: " 显示字符 "`nindex: " index "`n字体样式: " 字体样式 "`n字体大小:=" 测试字体样式是否能使用变量

    ; 最后的两个参数DistanceBetweenMouseXAndToolTip 是相对于鼠标的坐标, 运用于InputTip 可能不需要(删除即可)
    btt(显示字符,,,,OwnzztooltipStyle1,{Transparent:210,DistanceBetweenMouseXAndToolTip:20,DistanceBetweenMouseYAndToolTip:-100}) ;btt的主要函数, 透明度(Transparent 0 - 255)

    index++ 
    if (index > chars.Length) { 
      index := 1
    }
  }

  OwnzztooltipEnd()
  {
    btt()
    ;ExitApp
  }