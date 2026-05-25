; InputTip

readIni(key, default, section := "Settings", path := configFile) {
    static sentinel := "##__NOT_FOUND__##"
    raw := IniRead(path, section, key, sentinel)
    return raw == sentinel ? default : normalizeConfig(key, raw)
}

writeIni(key, value, section := "Settings", path := configFile) {
    try IniWrite(value, path, section, key)
}

readIniSection(section, default := "", path := configFile) {
    return IniRead(path, section, , default)
}

writeIniDebounced(key, value, callback := "", section := "Settings", path := configFile) {
    _writeIniDebounced(key, value, section, path, callback)
}

_writeIniDebounced := debounce(
    (key, value, section, path, callback := "") => (
        writeIni(key, value, section, path),
        callback ? callback(key, value, section) : 0
    ), 1000)
