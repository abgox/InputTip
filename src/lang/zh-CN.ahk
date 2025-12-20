; InputTip - Chinese Language File (zh-CN)

global langStrings_zhCN := {
    ; Application info
    app: {
        name: "InputTip",
        desc: "输入法状态管理工具",
        file_desc: "InputTip - 输入法状态管理工具"
    },
    
    ; State names
    state: {
        CN: "中文状态",
        EN: "英文状态",
        Caps: "大写锁定",
        Run: "运行",
        Pause: "暂停",
        Exit: "退出",
        Running: "运行中",
        Paused: "暂停中"
    },
    
    ; Common terms
    common: {
        about: "关于",
        close: "关闭",
        save: "保存",
        cancel: "取消",
        add: "添加",
        edit: "编辑",
        delete: "删除",
        refresh: "刷新",
        yes: "是",
        no: "否",
        confirm: "确定",
        error: "错误",
        warning: "警告",
        success: "成功",
        process_name: "进程名称",
        window_title: "窗口标题",
        file_path: "文件路径",
        match_scope: "匹配范围",
        match_mode: "匹配模式",
        match_title: "匹配标题",
        create_time: "创建时间",
        process_level: "进程级",
        title_level: "标题级",
        equal: "相等",
        regex: "正则",
        quick_add: "快捷添加",
        manual_add: "手动添加",
        complete_add: "完成添加",
        complete_edit: "完成编辑",
        delete_it: "删除它",
        name: "名称",
        title: "标题",
        path: "路径"
    },
    
    ; GUI common
    gui: {
        help_tip: "你首先应该点击上方的【关于】或相关文档查看此菜单的使用说明",
        click_get: "点击获取",
        stop_get: "停止获取",
        refresh_list: "刷新下拉列表",
        open_dir: "打开目录",
        refresh_page: "刷新此界面",
        show_more: "显示更多进程",
        show_less: "显示更少进程",
        source: "来源",
        system: "系统",
        whitelist: "白名单",
        add_to_whitelist: "是否添加到【符号的白名单】中: ",
        add_to_whitelist_no: "【否】不添加",
        add_to_whitelist_yes: "【是】自动添加",
        add_to_whitelist_tip: "如果选择【是】，且它在白名单中不存在，将以【进程级】自动添加"
    },
    
    ; Tray menu items
    tray: {
        guide: "使用指南",
        guide_title: "InputTip - 使用指南",
        guide_intro: "对于还不熟悉 InputTip 的朋友，这里有几个建议:",
        guide_tip1: '1. 使用前先看看视频教程: <a href="https://www.bilibili.com/video/BV15oYKz5EQ8">InputTip 使用教程 - Bilibili</a>',
        guide_tip2: '2. 可以再看看 <a href="https://inputtip.abgox.com">官网</a>、<a href="https://inputtip.abgox.com/faq">常见问题</a>，源代码仓库 <a href="https://github.com/abgox/InputTip">Github</a>、<a href="https://gitee.com/abgox/InputTip">Gitee</a>',
        guide_tip3: '3. 如果有其他问题，可以在【关于】中找到相关渠道进行反馈',
        startup: "开机自启动",
        admin_mode: "以管理员权限启动",
        create_shortcut: "创建快捷方式到桌面",
        pause_run: "暂停/运行",
        input_method: "输入法相关",
        hotkey_switch: "状态切换快捷键",
        auto_switch: "指定窗口自动切换状态",
        cursor_scheme: "状态提示 - 鼠标方案",
        symbol_scheme: "状态提示 - 符号方案",
        symbol_near_cursor: "在鼠标附近显示符号",
        bw_list: "符号的黑/白名单",
        window_info: "获取窗口信息",
        cursor_mode: "光标获取模式",
        special_offset: "特殊偏移量",
        other_settings: "其他设置",
        about: "关于",
        restart: "重启",
        exit: "退出",
        admin_cancel_tip1: "【管理员权限】无法直接降权至【用户权限】",
        admin_cancel_tip2: "如果想要立即生效，你需要手动退出并重新启动 InputTip",
        set_username: "设置用户名",
        set_username_title: "设置用户名",
        current_username: "当前的用户名: ",
        username_check_tip: "请自行检查，确保用户名无误后，点击右上角的 × 直接关闭此窗口即可",
        username_about: "1. 简要说明`n   - 这个菜单用来设置用户名信息`n   - 如果是域用户，在填写时还需要添加域，参考以下格式`n      - DOMAIN\\Username`n      - Username@domain.com`n   - 如果用户名信息有误，以下功能可能会失效`n      - 【开机自启动】中的 【任务计划程序】`n      - 【其他设置】中的【JAB/JetBrains IDE 支持】",
        window_info_title: "获取窗口信息",
        tip_template_default: "【%appState%】InputTip - 输入法状态管理器",
        key_count_template_default: "%\n%【统计中】启动以来, 有效的按键输入次数: %keyCount%"
    },
    
    ; About dialog
    about: {
        title: "关于项目",
        donate: "赞赏支持",
        reference: "参考项目",
        version: "版本: ",
        developer: "开发者: ",
        app_desc: "InputTip - 输入法状态管理器",
        app_subtitle: "实时指示(鼠标/符号) + 状态切换(窗口触发/快捷键触发)",
        submit_issue: '<a href="https://github.com/abgox/InputTip/issues">在 Github 上提交 Issue</a>',
        join_channel: '<a href="https://pd.qq.com/s/gyers18g6?businessType=5">加入腾讯频道</a>',
        website: '1. 官网: <a href="https://inputtip.abgox.com">inputtip.abgox.com</a>',
        github: '2. Github: <a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>',
        gitee: '3. Gitee: <a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>',
        donate_1: '- <a href="https://inputtip.abgox.com">InputTip</a> 是免费且开源的',
        donate_2: '- 但是开发和维护它需要大量的时间和精力',
        donate_3: '- 如果你喜欢 <a href="https://inputtip.abgox.com">InputTip</a>，请给仓库点个 Star',
        donate_4: '- 或者前往 <a href="https://abgox.com/donate">abgox.com/donate</a> 赞赏支持',
        donate_5: '    - 赞赏时可以留言: 项目名称、意图、想法等',
        donate_6: '    - 它们将会在 <a href="https://abgox.com/donate-list">abgox.com/donate-list</a> 上展示',
        donate_7: '    - 如果你想匿名，请在留言中注明',
        donate_8: '- <a href="https://abgox.com">abgox.com</a> 还有更多可能对你有帮助的信息和项目',
        donate_9: '- 感谢你的支持!',
        ref_1: '- InputTip v1 版本是在光标附近显示一个带文字的方块',
        ref_2: '- InputTip v2 版本默认使用不同颜色的光标样式',
        ref_3: '- 后来借鉴了 RedDot 和 language-indicator 的设计',
        ref_4: '- 简单的实现: 去掉了 v1 方块中的文字，添加了不同的背景颜色'
    },
    
    ; Initialization guide
    init_guide: {
        title: "InputTip - 初始化引导",
        lang_select: "Please select your language / 请选择你的语言",
        cursor_question: "你是否希望 InputTip 使用【鼠标方案】?",
        cursor_desc: "InputTip 会同时使用三套不同的鼠标样式`n然后根据不同输入法状态加载对应的鼠标样式",
        cursor_link: '详情参考【鼠标方案】:  <a href="https://inputtip.abgox.com/v2/#鼠标方案">官网</a>   <a href="https://github.com/abgox/InputTip#鼠标方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#鼠标方案">Gitee</a>',
        cursor_confirm: "你真的确定要使用【鼠标方案】吗？",
        cursor_warning: "如果误点了【是】，恢复鼠标样式需要以下步骤: `n  1. 点击【托盘菜单】中的【状态提示 - 鼠标方案】`n  2. 将【加载鼠标样式】更改为【否】",
        symbol_question: "你是否希望 InputTip 使用【符号方案】?",
        symbol_desc: "InputTip 会尝试获取输入光标位置，在其附近显示符号",
        symbol_link: '详情参考【符号方案】:  <a href="https://inputtip.abgox.com/v2/#符号方案">官网</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>',
        whitelist_desc: "对于【符号方案】，InputTip 使用强制的白名单机制`n只有添加到【符号的白名单】中的应用进程窗口才会尝试显示符号",
        whitelist_link: '详情参考: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">关于符号方案中的名单机制</a>',
        whitelist_suggest: "建议立即添加常用的应用进程窗口到【符号的白名单】中",
        btn_yes: "【是】",
        btn_no: "【否】",
        btn_add_now: "【是】现在去添加",
        btn_add_later: "【否】暂时不添加"
    },
    
    ; Input method settings
    input_method: {
        title: "输入法相关",
        base_config: "基础配置",
        custom: "自定义",
        about_custom: "关于自定义",
        about_switch: "关于切换输入法状态",
        mode_label: "1. 输入法状态的识别模式:",
        mode_custom: " 自定义",
        mode_general: " 通用",
        mode_tip: "建议使用【自定义】，并在上方的【自定义】标签页中进行配置",
        switch_label: "2. 输入法状态的切换方式:",
        switch_dll: " 内部调用 DLL",
        switch_lshift: " 模拟输入 LShift",
        switch_rshift: " 模拟输入 RShift",
        switch_ctrl_space: " 模拟输入 Ctrl+Space",
        switch_tip: "如果想修改这个配置，需要先通过上方的【关于切换输入法状态】标签页了解详情",
        keep_caps_label: "3. 是否保持大写锁定状态:",
        keep_caps_no: "【否】",
        keep_caps_yes: "【是】",
        keep_caps_tip: "启用之后，大写锁定只能通过手动按下 CapsLock 键取消，相关的自动切换将失效",
        timeout_label: "4. 输入法状态的获取超时:",
        default_status: "默认状态: ",
        status_english: " 英文状态",
        status_chinese: " 中文状态",
        add_rule: "添加规则",
        show_realtime: "显示实时的状态码和切换码(双击设置快捷键)",
        stop_realtime: "停止显示实时的状态码和切换码(双击设置快捷键)",
        order: "匹配的顺序",
        status_code_rule: "状态码规则",
        switch_code_rule: "切换码规则",
        ime_status: "输入法状态",
        odd: "奇数",
        even: "偶数",
        specify_number: "指定数字: ",
        specify_pattern: "指定规律: ",
        delete_rule: "删除此条规则"
    },
    
    ; Cursor mode settings
    cursor_mode: {
        title: "光标获取模式",
        app_process_name: "1. 应用进程名称: ",
        cursor_mode_label: "2. 光标获取模式: "
    },
    
    ; Window switch settings
    switch_window: {
        title: "指定窗口自动切换输入法状态",
        chinese_status: "中文状态",
        english_status: "英文状态",
        caps_lock: "大写锁定",
        auto_switch_to: "需要自动切换到",
        window_of: "的应用窗口",
        count: " 个 ",
        process_name: "1. 进程名称: ",
        status_switch: "2. 状态切换: ",
        match_scope: "3. 匹配范围: ",
        match_mode: "4. 匹配模式: ",
        match_title: "5. 匹配标题: ",
        match_mode_tip: "【匹配模式】和【匹配标题】仅在【匹配范围】为【标题级】时有效"
    },
    
    ; Auto exit settings
    auto_exit: {
        title: "指定窗口自动退出",
        auto_exit_tab: "自动退出",
        need_auto: "需要自动",
        inputtip: " InputTip",
        behavior_type: "2. 行为类型: "
    },
    
    ; App offset settings
    app_offset: {
        title: "特殊偏移量",
        list: "特殊偏移量列表",
        base_offset: "设置不同屏幕下的基础偏移量",
        screen: "屏幕 ",
        main_screen: "这是主屏幕(主显示器)，屏幕标识: ",
        sub_screen: "这是副屏幕(副显示器)，屏幕标识: ",
        screen_coords: "屏幕坐标信息(X,Y): 左上角(",
        right_bottom: "),右下角(",
        h_offset: "水平方向的偏移量: ",
        v_offset: "垂直方向的偏移量: ",
        screen_tip: "如果不知道如何区分屏幕，可查看【特殊偏移量】中的【关于】",
        special_offset_col: "特殊偏移量"
    },
    
    ; Symbol position settings
    symbol_pos: {
        title: "设置符号应该显示在鼠标附近的应用",
        tab: "在鼠标附近显示符号",
        window_label: "在鼠标附近显示符号的应用窗口: ",
        specified_window: " 指定窗口",
        all_window: " 所有窗口",
        h_offset: "在鼠标附近显示时的水平偏移量: ",
        v_offset: "在鼠标附近显示时的垂直偏移量: ",
        specify_window_btn: "指定在鼠标附近显示符号的应用窗口"
    },
    
    ; Black/White list settings
    bw_list: {
        title: "设置符号的黑/白名单",
        tab: "符号的黑/白名单",
        white_list: "白名单",
        black_list: "黑名单",
        set_white_list: "设置符号的白名单",
        set_black_list: "设置符号的黑名单"
    },
    
    ; Startup settings
    startup: {
        title: "设置开机自启动",
        tab: "设置开机自启动",
        task_scheduler: "任务计划程序",
        registry: "注册表",
        app_shortcut: "应用快捷方式",
        not_available: " (不可用)",
        admin_tip: "建议使用: 【任务计划程序】 > 【注册表】 > 【应用快捷方式】`n由于权限或系统限制等环境因素，【应用快捷方式】可能无效",
        non_admin_tip: "当前不是以管理员权限启动，【任务计划程序】和【注册表】不可用`n你可以通过点击【托盘菜单】中的【以管理员权限启动】使它们可用",
        cancel_tip: "InputTip 的【开机自启动】已经取消了`n可通过【托盘菜单】=>【开机自启动】再次设置",
        need_admin: "你需要以管理员权限运行来取消【开机自启动】`n设置: 【托盘菜单】=>【以管理员权限启动】"
    },
    
    ; Cursor scheme settings
    cursor_scheme: {
        title: "状态提示 - 鼠标方案",
        tab: "鼠标方案",
        load_cursor: "加载鼠标样式:",
        keep_original: "【否】保持原本的鼠标样式",
        follow_state: "【是】随输入法状态而变化",
        open_cursor_dir: "打开鼠标样式目录",
        download_more: "下载其他鼠标样式",
        reverting: "正在尝试恢复到启动 InputTip 之前的鼠标样式",
        revert_tip1: "可能无法完全恢复，这时就需要重启系统以完全移除动态加载的鼠标样式",
        revert_tip2: "如果你不想重启系统，也可以通过系统设置，重新应用之前的鼠标样式"
    },
    
    ; Other config settings
    other_config: {
        title: "其他设置",
        tab1: "其他设置",
        tab2: "其他设置2",
        check_update: "更新检查",
        auto_exit_btn: "指定窗口自动退出",
        open_dir: "打开软件目录",
        set_username: "设置用户名",
        pause_hotkey: "暂停/运行快捷键",
        jab_support: "JAB/JetBrains IDE 支持 【",
        jab_enabled: "启用",
        jab_disabled: "禁用",
        jab_status: "中】",
        tray_icon: "自定义软件托盘图标",
        running_icon: "运行中: ",
        paused_icon: "暂停中: ",
        open_icon_dir: "打开图标目录",
        font_size: "1. 配置菜单字体大小:",
        poll_interval: "2. 轮询响应间隔时间:",
        key_count: "3. 按键输入次数统计:",
        key_count_no: "【否】关闭",
        key_count_yes: "【是】开启",
        tray_tip_template: "4. 鼠标悬停在【托盘图标】上时的文字模板",
        key_count_template: "5. 按键输入次数统计的文字模板",
        template_tips: '这里有一些模板变量，它们在 4 和 5 中都可用:`n%\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)'
    },
    
    ; Window info dialog
    window_info: {
        title: "获取窗口信息",
        realtime_tip: "实时获取当前聚焦的窗口进程信息: 窗口进程名称 + 窗口标题 + 窗口进程路径"
    },
    
    ; Process list
    process_list: {
        title: "应用进程列表"
    },
    
    ; Messages
    msg: {
        editing_rule: "正在编辑规则",
        adding_rule: "正在添加规则",
        jab_start_failed: "启动 JAB 进程失败!",
        check_powershell: "请检查系统中是否存在 powershell.exe 或 pwsh.exe",
        task_failed: "添加任务计划程序失败!`n请检查系统中是否存在 powershell.exe 或 pwsh.exe",
        reg_failed: "添加注册表失败!",
        need_other_method: "你需要考虑使用其他方式设置开机自启动"
    },
    
    ; Hotkey settings
    hotkey: {
        chinese_status: "中文状态",
        english_status: "英文状态",
        caps_lock: "大写锁定",
        pause_run: "暂停/运行",
        show_code: "显示实时的状态码和切换码"
    },
    
    ; Username settings
    username: {
        title: "设置用户名",
        current: "当前的用户名: ",
        confirm_tip: "请自行检查，确保用户名无误后，点击右上角的 × 直接关闭此窗口即可"
    }
}
