; InputTip - Language Module
; Provides internationalization (i18n) support

; Load language files
#Include "*i ../lang/zh-CN.ahk"
#Include "*i ../lang/en-US.ahk"

; Current language setting
global currentLang := readIni("language", "en-US")

/**
 * Get translated string by key
 * @param {String} key - The translation key in dot notation (e.g., "tray.guide")
 * @param {String} fallback - Optional fallback text if key not found
 * @returns {String} The translated string
 */
lang(key, fallback := "") {
    global currentLang, langStrings_zhCN, langStrings_enUS
    
    ; Select the appropriate language object
    if (currentLang = "zh-CN") {
        langObj := langStrings_zhCN
    } else {
        langObj := langStrings_enUS
    }
    
    ; Parse the dot notation key and traverse the object
    parts := StrSplit(key, ".")
    result := langObj
    
    for part in parts {
        try {
            result := result.%part%
        } catch {
            ; Key not found, try fallback to Chinese
            result := langStrings_zhCN
            for p in parts {
                try {
                    result := result.%p%
                } catch {
                    return fallback ? fallback : key
                }
            }
            return result
        }
    }
    
    return result
}

/**
 * Set the current language
 * @param {String} langCode - Language code ("en-US" or "zh-CN")
 */
setLang(langCode) {
    global currentLang := langCode
    writeIni("language", langCode)
}

/**
 * Get the current language code
 * @returns {String} The current language code
 */
getLang() {
    global currentLang
    return currentLang
}
