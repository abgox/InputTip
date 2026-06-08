; InputTip

readIni(key, default, section := "Settings", path := configFile) {
    static sentinel := "##__NOT_FOUND__##"
    raw := IniRead(path, section, key, sentinel)
    return raw == sentinel ? default : normalizeConfig(key, raw)
}

writeIni(key, value, section := "Settings", path := configFile) {
    try IniWrite("`"" value "`"", path, section, key)
}

writeIniDebounced(key, value, callback := "", section := "Settings", path := configFile) {
    static debouncedMap := Map()
    mapKey := section "." key
    if !debouncedMap.Has(mapKey) {
        debouncedMap[mapKey] := debounce(
            (k, v, s, p, cb := "") => (
                writeIni(k, v, s, p),
                cb ? cb(k, v, s) : 0
            ), 500)
    }
    debouncedMap[mapKey](key, value, section, path, callback)
}
