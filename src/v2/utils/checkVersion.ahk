/**
 * 检查版本更新
 * @param currentVersion 当前版本号
 * @param {"v1" | "v2"} whichVersion 哪一个版本(v1/v2)
 * @param do 版本检查完成后的回调函数
 */
checkVersion(currentVersion, whichVersion, do) {
    try {
        req := ComObject("Msxml2.XMLHTTP")
        ; 异步请求
        req.open("GET", "https://inputtip.pages.dev/releases/" whichVersion "/version.txt", true)
        req.onreadystatechange := Ready
        req.send()
        Ready() {
            if (req.readyState != 4) {
                ; 请求未完成
                return
            }
            compareVersion(new, old) {
                newParts := StrSplit(new, ".")
                oldParts := StrSplit(old, ".")
                for i, part1 in newParts {
                    try {
                        part2 := oldParts[i]
                    } catch {
                        part2 := 0
                    }
                    if (part1 > part2) {
                        return 1  ; new > old
                    } else if (part1 < part2) {
                        return -1  ; new < old
                    }
                }
                return 0  ; new == old
            }
            newVersion := StrReplace(StrReplace(StrReplace(req.responseText, "`r", ""), "`n", ""), "v", "")
            if (req.status == 200 && compareVersion(newVersion, currentVersion) > 0) {
                do(whichVersion,newVersion, currentVersion)
            }
        }
    }
}
