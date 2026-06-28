; InputTip

langStrings := Map()

#Include "*i i18n\zh-CN.ahk"
#Include "*i i18n\en-US.ahk"

langCN := Map(
    "7804", "zh",
    "0004", "zh-Hans",
    "0804", "zh-CN",
    "1004", "zh-SG",
    "7C04", "zh-Hant",
    "0C04", "zh-HK",
    "1404", "zh-MO",
    "0404", "zh-TW"
)
systemLang := langCN.Has(A_Language) ? "zh-CN" : "en-US"

currentLang := readIni("language", systemLang)

isChinese := currentLang == "zh-CN"

/**
 * 获取 i18n 文本
 * @param {String} key
 * @param {1|0} raw 是否返回原始值
 * - `0` 自动解包：数组返回 pad 值（第 2 项），无 pad 则返回第 1 项
 * - `1` 返回原始值
 * @returns {String|Array}
 */
i18n(key, raw := 0) {
    langMap := langStrings.Has(currentLang) ? langStrings.Get(currentLang) : langStrings.Get("zh-CN")
    val := langMap.Has(key) ? langMap.Get(key) : langStrings.Get("zh-CN").Get(key, key)
    if raw
        return val
    if IsObject(val)
        return val.Length >= 2 ? val[2] : val[1]
    return val
}
