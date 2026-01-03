; InputTip

langStrings.Set('zh-CN', Map(
    'yes', '是',
    'no', '否',
    'close', '关闭',
    'i_see', '我知道了',
    'app_desc', '输入法状态管理工具',
    'app_sub_desc', '实时提示(鼠标/符号) + 状态切换(窗口触发/快捷键触发)',
    ; state
    'state.CN', '中文状态',
    'state.EN', '英文状态',
    'state.Caps', '大写锁定',
    'state.Run', '运行',
    'state.Pause', '暂停',
    'state.Exit', '退出',
    'state.Running', '运行中',
    'state.Paused', '已暂停',
    ; init_guide
    'init_guide.title', '初始化引导',
    'init_guide.cursor', [
        '你是否希望 InputTip 使用【鼠标方案】?',
        'InputTip 会同时使用三套不同的鼠标样式`n然后根据不同输入法状态加载对应的鼠标样式',
        '详情参考【鼠标方案】:  <a href="https://inputtip.abgox.com/v2/#鼠标方案">官网</a>   <a href="https://github.com/abgox/InputTip#鼠标方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#鼠标方案">Gitee</a>',
    ],
    'init_guide.symbol', [
        '你是否希望 InputTip 使用【符号方案】?',
        'InputTip 会尝试获取输入光标位置，在其附近显示符号',
        '详情参考【符号方案】:  <a href="https://inputtip.abgox.com/v2/#符号方案">官网</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>',
    ],
    'init_guide.whitelist', [
        '对于【符号方案】，InputTip 使用强制的白名单机制`n只有添加到【符号的白名单】中的应用进程窗口才会尝试显示符号',
        '详情参考: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">关于符号方案中的名单机制</a>',
        '建议立即添加常用的应用进程窗口到【符号的白名单】中',
    ],
    'init_guide.add_now', '【是】现在去添加',
    'init_guide.add_later', '【否】暂时不添加',
    ; tray
    'tray.tip_template', '【%appState%】InputTip - 输入法状态管理工具',
    'tray.keyCount_template', '%\n%【统计中】启动以来, 有效的按键输入次数: %keyCount%',
    ; gui
    'gui.help_tip', '你首先应该点击上方的【关于】或相关文档查看此菜单的使用说明',
    ; other_config
    'other_config.language', '语言 / Language',
    'other_config.lang_settings', '语言设置',
    'other_config.lang_changed', '语言已更改，它将在重启后生效`n当关闭这个窗口时，InputTip 会自动重启',
))
