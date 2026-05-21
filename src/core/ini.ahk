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
        writeIniSection(default, section, path)
        return default
    }
}

writeIniSection(value, section, path := configFile) {
    try IniWrite(value, path, section)
}
