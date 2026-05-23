; InputTip

readIni(key, default, section := "Settings", path := configFile) {
    try {
        return normalizeConfig(key, IniRead(path, section, key))
    } catch {
        writeIni(key, default, section, path)
        return default
    }
}

writeIni(key, value, section := "Settings", path := configFile) {
    try IniWrite(value, path, section, key)
}

readIniSection(section, default := "", path := configFile) {
    try {
        return IniRead(path, section)
    } catch {
        try IniWrite(default, path, section)
        return default
    }
}

writeIniDebounced(key, value, callback := "", section := "Settings", path := configFile) {
    _writeIniDebounced(key, value, section, path, callback)
}

_writeIniDebounced := debounce(
    (key, value, section, path, callback := "") => (
        writeIni(key, value, section, path),
        callback ? callback(key, value, section) : 0
    ), 1000)
