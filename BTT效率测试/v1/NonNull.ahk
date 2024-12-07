; 变量为空，则使用默认值。变量不为空，则使用变量值。
; 同时可以检查变量是否超出最大最小范围。
; 注意，默认值不受最大最小范围的限制。
; 也就是说
; 当变量值为""，默认值为8，范围为2-5，此时变量值会是8。
; 当变量值为10，默认值为8，范围为2-5，此时变量值会是5。
NonNull(ByRef var, DefaultValue, MinValue:="", MaxValue:="")		; 237ms
{
	var:= var="" ? DefaultValue : MinValue="" ? (MaxValue="" ? var : Min(var, MaxValue)) : (MaxValue!="" ? Max(Min(var, MaxValue), MinValue) : Max(var, MinValue))
}

; 与 NonNull 一致，区别是通过 return 返回值，而不是 ByRef。
NonNull_Ret(var, DefaultValue, MinValue:="", MaxValue:="")			; 237ms
{
	return, var="" ? DefaultValue : MinValue="" ? (MaxValue="" ? var : Min(var, MaxValue)) : (MaxValue!="" ? Max(Min(var, MaxValue), MinValue) : Max(var, MinValue))
	/*
	; 下面的 if 版本与上面的三元版本是等价的
	; 只是16w次循环的速度是 270ms，慢了13%
	if (var="")
		return, DefaultValue													; 变量为空，则返回默认值
	else
	{
		if (MinValue="")
		{
			if (MaxValue="")
				return, var																; 变量有值，且不检查最大最小范围，则直接返回变量值
			else
				return, Min(var, MaxValue)								; 变量有值，且只检查最大值，则返回不大于最大值的变量值
		}
		else
		{
			if (MaxValue!="")
				; 三元的写法不会更快
				return, Max(Min(var, MaxValue), MinValue)	; 变量有值，且检查最大最小范围，则返回最大最小范围内的变量值
			else
				return, Max(var, MinValue)								; 变量有值，且只检查最小值，则返回不小于最小值的变量值
		}
	}
	*/
}

/* 单元测试
计时()
loop,1000
{
	gosub, UnitTest1
	gosub, UnitTest2
}
计时()

; ByRef 版本的测试
UnitTest1:
	v:=""
	NonNull(v, 8, 2, 10)
	if v!=8
		MsgBox, wrong
	v:=""
	NonNull(v, 8, "", "")
	if v!=8
		MsgBox, wrong
	v:=""
	NonNull(v, 8, 2, "")
	if v!=8
		MsgBox, wrong
	v:=""
	NonNull(v, 8, "", 10)
	if v!=8
		MsgBox, wrong

	v:=5
	NonNull(v, 8, 2, 10)
	if v!=5
		MsgBox, wrong
	v:=5
	NonNull(v, 8, "", "")
	if v!=5
		MsgBox, wrong
	v:=5
	NonNull(v, 8, 2, "")
	if v!=5
		MsgBox, wrong
	v:=5
	NonNull(v, 8, "", 10)
	if v!=5
		MsgBox, wrong

	v:=15
	NonNull(v, 8, 2, 10)
	if v!=10
		MsgBox, wrong
	v:=15
	NonNull(v, 8, "", "")
	if v!=15
		MsgBox, wrong
	v:=15
	NonNull(v, 8, 2, "")
	if v!=15
		MsgBox, wrong
	v:=15
	NonNull(v, 8, "", 10)
	if v!=10
		MsgBox, wrong

	v:=1
	NonNull(v, 8, 2, 10)
	if v!=2
		MsgBox, wrong
	v:=1
	NonNull(v, 8, "", "")
	if v!=1
		MsgBox, wrong
	v:=1
	NonNull(v, 8, 2, "")
	if v!=2
		MsgBox, wrong
	v:=1
	NonNull(v, 8, "", 10)
	if v!=1
		MsgBox, wrong
return

; return 版本的测试
UnitTest2:
	v:=""
	if NonNull_Ret(v, 8, 2, 10)!=8
		MsgBox, wrong
	v:=""
	if NonNull_Ret(v, 8, "", "")!=8
		MsgBox, wrong
	v:=""
	if NonNull_Ret(v, 8, 2, "")!=8
		MsgBox, wrong
	v:=""
	if NonNull_Ret(v, 8, "", 10)!=8
		MsgBox, wrong

	v:=5
	if NonNull_Ret(v, 8, 2, 10)!=5
		MsgBox, wrong
	v:=5
	if NonNull_Ret(v, 8, "", "")!=5
		MsgBox, wrong
	v:=5
	if NonNull_Ret(v, 8, 2, "")!=5
		MsgBox, wrong
	v:=5
	if NonNull_Ret(v, 8, "", 10)!=5
		MsgBox, wrong

	v:=15
	if NonNull_Ret(v, 8, 2, 10)!=10
		MsgBox, wrong
	v:=15
	if NonNull_Ret(v, 8, "", "")!=15
		MsgBox, wrong
	v:=15
	if NonNull_Ret(v, 8, 2, "")!=15
		MsgBox, wrong
	v:=15
	if NonNull_Ret(v, 8, "", 10)!=10
		MsgBox, wrong

	v:=1
	if NonNull_Ret(v, 8, 2, 10)!=2
		MsgBox, wrong
	v:=1
	if NonNull_Ret(v, 8, "", "")!=1
		MsgBox, wrong
	v:=1
	if NonNull_Ret(v, 8, 2, "")!=2
		MsgBox, wrong
	v:=1
	if NonNull_Ret(v, 8, "", 10)!=1
		MsgBox, wrong
return
*/