#SingleInstance Force
;SetBatchLines, -1
#Include BTTv1.ahk
;样式1：用于正则工具完成情况提示
OwnzztooltipStyle1 := {Border:1
	, Rounded:2
	, Margin:8
	, BorderColorLinearGradientStart:0xff3881a7   ;0xffb7407c
	, BorderColorLinearGradientEnd:0xff3881a7
	, BorderColorLinearGradientAngle:45
	, BorderColorLinearGradientMode:6
	, FontSize:16
	, TextColor:0xFFFFFFFF    ;0xffd9d9db
	, BackgroundColor:0xFF000000  ;0xff26293a
	, FontStyle:"Regular"}

;样式2：用于正则工具控件功能提示
OwnzztooltipStyle2 := {Border:1
	, Rounded:8
	, TextColor:0xfff4f4f4
	, BackgroundColor:0xaa3e3d45
	, FontSize:14}

Style99 :=  {Border:20                                      ; If omitted, 1 will be used. Range 0-20.
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

Text=
(
使用模板可以轻松创建自己的风格。
欢迎分享，带张截图！！！
Use template to easily create your own style.
Please share your custom style and include a screenshot.
It will help a lot of people.
BTTv1测试效率_LibA
)

Del::
	{
		SetTimer runV1, 10
		Return
	}

runV1:
	{
		btt(Text,,,,OwnzztooltipStyle1,{Transparent:180,DistanceBetweenMouseXAndToolTip:-100,DistanceBetweenMouseYAndToolTip:-20})
		;SetTimer OwnzztooltipEnd ,-3000
	}

	OwnzztooltipEnd()
	{
		btt()
		;ExitApp
	}
