/**
 * 读取配置文件
 * @param {String}key 配置文件中的键名
 * @param default 默认值
 * @param {"InputMethod" | "Config-v2"} section 配置文件中的分区名
 * @param {String} path 配置文件的路径
 * @returns {String} 配置文件中的值
 */
readIni(key, default, section := "Config-v2", path := "InputTip.ini") {
    try {
        return IniRead(path, section, key)
    } catch {
        IniWrite('"' default '"', path, section, key)
        return default
    }
}
/**
 * 写入配置文件
 * @param key 配置文件中的键名
 * @param value  要写入的值
 * @param {"InputMethod" | "Config-v2"} section 配置文件中的分区名
 * @param {String} path 配置文件的路径
 */
writeIni(key, value, section := "Config-v2", path := "InputTip.ini") {
    IniWrite('"' value '"', path, section, key)
}
