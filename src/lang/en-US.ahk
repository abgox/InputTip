; InputTip - English Language File (en-US)

global langStrings_enUS := {
    ; Application info
    app: {
        name: "InputTip",
        desc: "Input Method Status Manager",
        file_desc: "InputTip - Input Method Status Manager"
    },
    
    ; State names
    state: {
        CN: "Chinese",
        EN: "English",
        Caps: "Caps Lock",
        Run: "Run",
        Pause: "Pause",
        Exit: "Exit",
        Running: "Running",
        Paused: "Paused"
    },
    
    ; Common terms
    common: {
        about: "About",
        close: "Close",
        save: "Save",
        cancel: "Cancel",
        add: "Add",
        edit: "Edit",
        delete: "Delete",
        refresh: "Refresh",
        yes: "Yes",
        no: "No",
        confirm: "OK",
        error: "Error",
        warning: "Warning",
        success: "Success",
        process_name: "Process Name",
        window_title: "Window Title",
        file_path: "File Path",
        match_scope: "Match Scope",
        match_mode: "Match Mode",
        match_title: "Match Title",
        create_time: "Created",
        process_level: "Process Level",
        title_level: "Title Level",
        equal: "Exact",
        regex: "Regex",
        quick_add: "Quick Add",
        manual_add: "Manual Add",
        complete_add: "Finish Adding",
        complete_edit: "Finish Editing",
        delete_it: "Delete It",
        name: "Name",
        title: "Title",
        path: "Path"
    },
    
    ; GUI common
    gui: {
        help_tip: "Please first click the [About] tab above to view the usage instructions for this menu",
        click_get: "Click to Get",
        stop_get: "Stop Getting",
        refresh_list: "Refresh List",
        open_dir: "Open Directory",
        refresh_page: "Refresh This Page",
        show_more: "Show More Processes",
        show_less: "Show Fewer Processes",
        source: "Source",
        system: "System",
        whitelist: "Whitelist",
        add_to_whitelist: "Add to [Symbol Whitelist]: ",
        add_to_whitelist_no: "[No] Don't add",
        add_to_whitelist_yes: "[Yes] Auto add",
        add_to_whitelist_tip: "If [Yes] is selected and it doesn't exist in the whitelist, it will be added at [Process Level]"
    },
    
    ; Tray menu items
    tray: {
        guide: "User Guide",
        guide_title: "InputTip - User Guide",
        guide_intro: "For those new to InputTip, here are some suggestions:",
        guide_tip1: '1. Watch the tutorial video first: <a href="https://www.bilibili.com/video/BV15oYKz5EQ8">InputTip Tutorial - Bilibili</a>',
        guide_tip2: '2. Check out the <a href="https://inputtip.abgox.com">Website</a>, <a href="https://inputtip.abgox.com/faq">FAQ</a>, and source code on <a href="https://github.com/abgox/InputTip">Github</a> or <a href="https://gitee.com/abgox/InputTip">Gitee</a>',
        guide_tip3: '3. If you have other questions, you can find feedback channels in [About]',
        startup: "Auto-start at Boot",
        admin_mode: "Run as Administrator",
        create_shortcut: "Create Desktop Shortcut",
        pause_run: "Pause/Run",
        input_method: "Input Method",
        hotkey_switch: "Status Switch Hotkeys",
        auto_switch: "Auto Switch Status by Window",
        cursor_scheme: "Status Indicator - Cursor Scheme",
        symbol_scheme: "Status Indicator - Symbol Scheme",
        symbol_near_cursor: "Show Symbol Near Cursor",
        bw_list: "Symbol Black/White List",
        window_info: "Get Window Info",
        cursor_mode: "Cursor Detection Mode",
        special_offset: "Special Offset",
        other_settings: "Other Settings",
        about: "About",
        restart: "Restart",
        exit: "Exit",
        admin_cancel_tip1: "[Administrator privileges] cannot be directly demoted to [User privileges]",
        admin_cancel_tip2: "To take effect immediately, you need to manually exit and restart InputTip",
        set_username: "Set Username",
        set_username_title: "Set Username",
        current_username: "Current username: ",
        username_check_tip: "Please verify the username is correct, then click X in the top right to close",
        username_about: "1. Overview`n   - This menu sets the username`n   - For domain users, add the domain, e.g.:`n      - DOMAIN\\Username`n      - Username@domain.com`n   - If username is wrong, these features may fail:`n      - [Auto-start] via [Task Scheduler]`n      - [JAB/JetBrains IDE Support] in [Other Settings]",
        window_info_title: "Get Window Info",
        tip_template_default: "[%appState%] InputTip - Input Method Status Manager",
        key_count_template_default: "%\n%[Counting] Since startup, valid key presses: %keyCount%"
    },
    
    ; About dialog
    about: {
        title: "About Project",
        donate: "Support",
        reference: "References",
        version: "Version: ",
        developer: "Developer: ",
        app_desc: "InputTip - An Input Method Status Manager",
        app_subtitle: "Real-time indicator (Cursor/Symbol) + Status switch (Window/Hotkey triggered)",
        submit_issue: '<a href="https://github.com/abgox/InputTip/issues">Submit Issue on Github</a>',
        join_channel: '<a href="https://pd.qq.com/s/gyers18g6?businessType=5">Join Tencent Channel</a>',
        website: '1. Website: <a href="https://inputtip.abgox.com">inputtip.abgox.com</a>',
        github: '2. Github: <a href="https://github.com/abgox/InputTip">github.com/abgox/InputTip</a>',
        gitee: '3. Gitee: <a href="https://gitee.com/abgox/InputTip">gitee.com/abgox/InputTip</a>',
        donate_1: '- <a href="https://inputtip.abgox.com">InputTip</a> is free and open source',
        donate_2: '- But developing and maintaining it takes a lot of time and effort',
        donate_3: '- If you like <a href="https://inputtip.abgox.com">InputTip</a>, please star the repository',
        donate_4: '- Or donate at <a href="https://abgox.com/donate">abgox.com/donate</a> to support my work',
        donate_5: '    - Consider leaving a message: project name, purpose, thoughts, etc.',
        donate_6: '    - They will be shown on <a href="https://abgox.com/donate-list">abgox.com/donate-list</a>',
        donate_7: '    - If you prefer to stay anonymous, please mention it in the message',
        donate_8: '- <a href="https://abgox.com">abgox.com</a> has more info and other projects that might help you',
        donate_9: '- Thank you for your support!',
        ref_1: '- InputTip v1 shows a block symbol with text near the cursor',
        ref_2: '- InputTip v2 uses different colored cursor styles by default',
        ref_3: '- Later adopted design from RedDot and language-indicator',
        ref_4: '- Simple implementation: removed text from v1 block, added different background colors'
    },
    
    ; Initialization guide
    init_guide: {
        title: "InputTip - Initialization Guide",
        lang_select: "Please select your language / 请选择你的语言",
        cursor_question: "Do you want InputTip to use [Cursor Scheme]?",
        cursor_desc: "InputTip will use three different cursor styles`nand load the corresponding cursor style based on IME status",
        cursor_link: 'Learn more about [Cursor Scheme]:  <a href="https://inputtip.abgox.com/v2/#鼠标方案">Website</a>   <a href="https://github.com/abgox/InputTip#鼠标方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#鼠标方案">Gitee</a>',
        cursor_confirm: "Are you sure you want to use [Cursor Scheme]?",
        cursor_warning: "If you clicked [Yes] by mistake, restore cursor style via: `n  1. Click [Cursor Scheme] in [Tray Menu]`n  2. Change [Load cursor style] to [No]",
        symbol_question: "Do you want InputTip to use [Symbol Scheme]?",
        symbol_desc: "InputTip will try to get input cursor position and display a symbol near it",
        symbol_link: 'Learn more about [Symbol Scheme]:  <a href="https://inputtip.abgox.com/v2/#符号方案">Website</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>',
        whitelist_desc: "For [Symbol Scheme], InputTip uses a mandatory whitelist mechanism`nOnly app windows added to [Symbol Whitelist] will attempt to display symbols",
        whitelist_link: 'Learn more: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">About Symbol Whitelist Mechanism</a>',
        whitelist_suggest: "It is recommended to add your commonly used apps to [Symbol Whitelist] now",
        btn_yes: "[Yes]",
        btn_no: "[No]",
        btn_add_now: "[Yes] Add now",
        btn_add_later: "[No] Add later"
    },
    
    ; Input method settings
    input_method: {
        title: "Input Method",
        base_config: "Basic Config",
        custom: "Custom",
        about_custom: "About Custom",
        about_switch: "About Switching IME Status",
        mode_label: "1. IME status recognition mode:",
        mode_custom: " Custom",
        mode_general: " General",
        mode_tip: "Recommended to use [Custom] and configure in the [Custom] tab above",
        switch_label: "2. Method to switch IME status:",
        switch_dll: " Internal DLL call",
        switch_lshift: " Simulate LShift",
        switch_rshift: " Simulate RShift",
        switch_ctrl_space: " Simulate Ctrl+Space",
        switch_tip: "To modify this config, first check the [About Switching IME Status] tab for details",
        keep_caps_label: "3. Keep Caps Lock state:",
        keep_caps_no: "[No]",
        keep_caps_yes: "[Yes]",
        keep_caps_tip: "When enabled, Caps Lock can only be turned off by pressing CapsLock key, auto-switching will be disabled",
        timeout_label: "4. IME status fetch timeout:",
        default_status: "Default status: ",
        status_english: " English",
        status_chinese: " Chinese",
        add_rule: "Add Rule",
        show_realtime: "Show real-time status/switch codes (double-click to set hotkey)",
        stop_realtime: "Stop showing real-time status/switch codes (double-click to set hotkey)",
        order: "Order",
        status_code_rule: "Status Code Rule",
        switch_code_rule: "Switch Code Rule",
        ime_status: "IME Status",
        odd: "Odd",
        even: "Even",
        specify_number: "Specify number: ",
        specify_pattern: "Specify pattern: ",
        delete_rule: "Delete This Rule"
    },
    
    ; Cursor mode settings
    cursor_mode: {
        title: "Cursor Detection Mode",
        app_process_name: "1. App process name: ",
        cursor_mode_label: "2. Cursor detection mode: "
    },
    
    ; Window switch settings
    switch_window: {
        title: "Auto Switch IME Status by Window",
        chinese_status: "Chinese",
        english_status: "English",
        caps_lock: "Caps Lock",
        auto_switch_to: "Auto switch to",
        window_of: "for apps",
        count: " items ",
        process_name: "1. Process name: ",
        status_switch: "2. Status switch: ",
        match_scope: "3. Match scope: ",
        match_mode: "4. Match mode: ",
        match_title: "5. Match title: ",
        match_mode_tip: "[Match Mode] and [Match Title] only effective when [Match Scope] is [Title Level]"
    },
    
    ; Auto exit settings
    auto_exit: {
        title: "Auto Exit by Window",
        auto_exit_tab: "Auto Exit",
        need_auto: "Auto",
        inputtip: " InputTip",
        behavior_type: "2. Behavior type: "
    },
    
    ; App offset settings
    app_offset: {
        title: "Special Offset",
        list: "Special Offset List",
        base_offset: "Set Base Offset for Different Screens",
        screen: "Screen ",
        main_screen: "This is the main screen (primary monitor), Screen ID: ",
        sub_screen: "This is a secondary screen (secondary monitor), Screen ID: ",
        screen_coords: "Screen coordinates (X,Y): Top-left (",
        right_bottom: "), Bottom-right (",
        h_offset: "Horizontal offset: ",
        v_offset: "Vertical offset: ",
        screen_tip: "If unsure how to identify screens, check [About] in [Special Offset]",
        special_offset_col: "Special Offset"
    },
    
    ; Symbol position settings
    symbol_pos: {
        title: "Apps to Show Symbol Near Cursor",
        tab: "Show Symbol Near Cursor",
        window_label: "Show symbol near cursor for: ",
        specified_window: " Specified windows",
        all_window: " All windows",
        h_offset: "Horizontal offset when showing near cursor: ",
        v_offset: "Vertical offset when showing near cursor: ",
        specify_window_btn: "Specify apps to show symbol near cursor"
    },
    
    ; Black/White list settings
    bw_list: {
        title: "Symbol Black/White List",
        tab: "Symbol Black/White List",
        white_list: "Whitelist",
        black_list: "Blacklist",
        set_white_list: "Set Symbol Whitelist",
        set_black_list: "Set Symbol Blacklist"
    },
    
    ; Startup settings
    startup: {
        title: "Auto-start Settings",
        tab: "Auto-start Settings",
        task_scheduler: "Task Scheduler",
        registry: "Registry",
        app_shortcut: "App Shortcut",
        not_available: " (N/A)",
        admin_tip: "Recommended: [Task Scheduler] > [Registry] > [App Shortcut]`nDue to permission or system limitations, [App Shortcut] may not work",
        non_admin_tip: "Not running as administrator, [Task Scheduler] and [Registry] unavailable`nClick [Run as Administrator] in tray menu to enable them",
        cancel_tip: "InputTip [Auto-start] has been cancelled`nYou can set it again via [Tray Menu] => [Auto-start at Boot]",
        need_admin: "Administrator privileges required to cancel [Auto-start]`nSettings: [Tray Menu] => [Run as Administrator]"
    },
    
    ; Cursor scheme settings
    cursor_scheme: {
        title: "Status Indicator - Cursor Scheme",
        tab: "Cursor Scheme",
        load_cursor: "Load cursor style:",
        keep_original: "[No] Keep original cursor",
        follow_state: "[Yes] Change with IME status",
        open_cursor_dir: "Open Cursor Style Directory",
        download_more: "Download More Cursor Styles",
        reverting: "Trying to restore cursor style to before InputTip started",
        revert_tip1: "May not fully restore, restart system to completely remove dynamically loaded cursor styles",
        revert_tip2: "If you don't want to restart, you can reapply previous cursor style through system settings"
    },
    
    ; Other config settings
    other_config: {
        title: "Other Settings",
        tab1: "Other Settings",
        tab2: "Other Settings 2",
        check_update: "Check Update",
        auto_exit_btn: "Auto Exit by Window",
        open_dir: "Open App Directory",
        set_username: "Set Username",
        pause_hotkey: "Pause/Run Hotkey",
        jab_support: "JAB/JetBrains IDE Support [",
        jab_enabled: "Enabled",
        jab_disabled: "Disabled",
        jab_status: "]",
        tray_icon: "Custom Tray Icon",
        running_icon: "Running: ",
        paused_icon: "Paused: ",
        open_icon_dir: "Open Icon Directory",
        font_size: "1. Menu font size:",
        poll_interval: "2. Polling interval (ms):",
        key_count: "3. Key input count:",
        key_count_no: "[No] Disabled",
        key_count_yes: "[Yes] Enabled",
        tray_tip_template: "4. Tooltip template when hovering over tray icon",
        key_count_template: "5. Key count template",
        template_tips: 'Template variables available for 4 and 5:`n%\n% (newline), %keyCount% (key count), %appState% (app status)'
    },
    
    ; Window info dialog
    window_info: {
        title: "Get Window Info",
        realtime_tip: "Real-time info of focused window: Process name + Window title + Process path"
    },
    
    ; Process list
    process_list: {
        title: "Process List"
    },
    
    ; Messages
    msg: {
        editing_rule: "Editing rule",
        adding_rule: "Adding rule",
        jab_start_failed: "Failed to start JAB process!",
        check_powershell: "Please check if powershell.exe or pwsh.exe exists in the system",
        task_failed: "Failed to add task schedule!`nPlease check if powershell.exe or pwsh.exe exists",
        reg_failed: "Failed to add registry entry!",
        need_other_method: "You need to use another method to set auto-start"
    },
    
    ; Hotkey settings
    hotkey: {
        chinese_status: "Chinese",
        english_status: "English",
        caps_lock: "Caps Lock",
        pause_run: "Pause/Run",
        show_code: "Show real-time status/switch codes"
    },
    
    ; Username settings
    username: {
        title: "Set Username",
        current: "Current username: ",
        confirm_tip: "Please verify the username is correct, then click the X button to close this window"
    }
}
