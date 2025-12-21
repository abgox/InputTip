; InputTip

langStrings := Map()
langList := [
    ['zh-CN', '简体中文 (zh-CN)'],
    ['en-US', 'English (en-US)'],
]

#Include "*i ../lang/zh-CN.ahk"
#Include "*i ../lang/en-US.ahk"


currentLang := readIni("language", langList[1][1])

/**
 * 获取翻译后的文本
 * @param {String} key
 * @returns {String}
 */
lang(key) {
    if (langStrings.Has(currentLang)) {
        langMap := langStrings.Get(currentLang)
        if (langMap.Has(key)) {
            return langMap.Get(key)
        }
    }
    return langStrings.Get('zh-CN').Get(key)
}

/**
 * 设置当前语言
 * @param {String} langCode - 语言代码(如: zh-CN)
 */
setLang(langCode) {
    global currentLang := langCode
    writeIni("language", langCode)
}
