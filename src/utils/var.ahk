; InputTip

; ============================================================================
; I18N LANGUAGE MODULE - Inline for compatibility
; ============================================================================

; English language strings
global langStrings := {
    app: {
        name: "InputTip",
        desc: "Input Method Status Manager",
        file_desc: "InputTip - Input Method Status Manager"
    },
    state: {
        CN: "Chinese",
        EN: "English",
        Caps: "Caps Lock",
        Run: "Run",
        Pause: "Pause",
        Exit: "Exit",
        Running: "Running",
        Paused: "Paused",
        cn_status: "Chinese Status",
        en_status: "English Status"
    },
    common: {
        about: "About",
        close: "Close",
        save: "Save",
        cancel: "Cancel",
        add: "Add",
        edit: "Edit",
        delete: "Delete",
        refresh: "Refresh",
        yes: "[Yes]",
        no: "[No]",
        confirm: "OK",
        error: "Error",
        warning: "Warning",
        success: "Success",
        tip_title: "InputTip - Tip",
        i_understand: "I Understand",
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
        odd: "Odd",
        even: "Even",
        items: " items"
    },
    gui: {
        help_tip: "Please first click the [About] tab above to view the usage instructions",
        click_get: "Click to Get",
        stop_get: "Stop Getting",
        refresh_list: "Refresh List",
        open_dir: "Open Directory",
        add_to_whitelist: "Add to [Symbol Whitelist]: ",
        add_to_whitelist_no: "[No] Don't add",
        add_to_whitelist_yes: "[Yes] Auto add",
        add_to_whitelist_tip: "If [Yes] is selected and not in whitelist, it will be added at [Process Level]",
        process_name_label: "1. Process Name: ",
        match_scope_label: "2. Match Scope: ",
        match_scope_tip: "[Match Mode] and [Match Title] only apply when [Match Scope] is [Title Level]",
        match_mode_label: "3. Match Mode: ",
        match_title_label: "4. Match Title: ",
        editing_rule: "Editing Rule",
        adding_rule: "Adding Rule",
        current_name: "Name: ",
        current_title: "Title: ",
        current_path: "Path: ",
        realtime_info: "Real-time focused window process info: Process Name + Window Title + Process Path",
        lv_name: "Process Name",
        lv_source: "Source",
        lv_title: "Window Title",
        lv_path: "File Path",
        source_system: "System",
        source_whitelist: "Whitelist"
    },
    tray: {
        guide: "User Guide",
        guide_title: "InputTip - User Guide",
        guide_intro: "For those new to InputTip, here are some suggestions:",
        guide_tip1: '1. Watch the tutorial video first: <a href="https://www.bilibili.com/video/BV15oYKz5EQ8">InputTip Tutorial - Bilibili</a>',
        guide_tip2: '2. Check out the <a href="https://inputtip.abgox.com">Website</a>, <a href="https://inputtip.abgox.com/faq">FAQ</a>, and source code on <a href="https://github.com/abgox/InputTip">Github</a> or <a href="https://gitee.com/abgox/InputTip">Gitee</a>',
        guide_tip3: "3. If you have other questions, you can find feedback channels in [About]",
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
        keep_caps_tip: "When enabled, Caps Lock can only be turned off by CapsLock key, auto-switching disabled",
        timeout_label: "4. IME status fetch timeout:",
        timeout_tip: "Unit: ms, default 500ms, don't modify unless necessary`nEach switch, InputTip gets new IME status from system`nIf timeout, it defaults to English status",
        custom_first_tip: "First click [About Custom] tab above to view help and learn how to configure",
        default_status: "Default Status: ",
        default_en: " English Status",
        default_cn: " Chinese Status",
        lv_order: "Match Order",
        lv_status_rule: "Status Code Rule",
        lv_conv_rule: "Conversion Code Rule",
        lv_ime_status: "IME Status",
        add_rule: "Add Rule",
        add_rule_title: "Add Rule",
        edit_rule_title: "Edit Rule",
        order_label: "1. Match Order: ",
        ime_status_label: "2. IME Status: ",
        status_code_label: "3. Status Code Rule: ",
        specify_number: "     - Specify number: ",
        specify_pattern: "     - Specify pattern: ",
        conv_code_label: "4. Conversion Code Rule: ",
        delete_rule: "Delete This Rule",
        show_realtime: "Show realtime status/conversion code (double-click to set hotkey)",
        show_realtime_tip: "Show realtime status/conversion code",
        warning_title: "Warning",
        warning_confirm: "Are you sure you want to use ",
        warning_not_recommend: "Not recommended, see [About Switching IME Status] for details",
        custom_mode_warning: "Read the help below carefully before using [Custom] mode, check related links",
        finish_add: "Finish Adding",
        finish_edit: "Finish Editing",
        rule_title: " Rule",
        odd: "Odd",
        even: "Even",
        en_status: "English Status",
        cn_status: "Chinese Status",
        none: "None",
        switch_ctrl_space_tip: "[Simulate Ctrl+Space]",
        switch_dll_tip: "[Internal DLL Call]"
    },
    hotkey: {
        title: "Set Hotkeys",
        tab_single: "Set Single Key",
        tab_combo: "Set Combo Hotkeys",
        tab_manual: "Manual Input Hotkey",
        tip1_1: "1.",
        tip1_2: "Hotkey settings don't take effect immediately, click [OK] below to apply",
        tip2: "2.  LShift is the left Shift key, RShift is the right Shift key, same for other keys",
        tip3: "3.  Using a single key as hotkey won't override its original function, triggers on key release",
        tip4_link: '4.  To remove a hotkey, select [None]. <a href="https://inputtip.abgox.com/faq/single-key-list">Click to view the complete key name list</a>',
        tip_combo2: "2.  Press the hotkey directly to set, use [Manual Input Hotkey] if hotkey is occupied",
        tip_combo3: "3.  Use Backspace or Delete to clear the hotkey",
        tip_combo4: "4.  Check the Win box on the right to add Win modifier key",
        tip_manual2: "2.",
        tip_manual2_red: "Prefer [Set Single Key] or [Set Combo Hotkeys] unless occupied",
        tip_manual3: '3.  This echoes their settings, use them first, then modify here',
        tip_manual4_link: '4.  First see <a href="https://inputtip.abgox.com/faq/enter-shortcuts-manually">How to manually input hotkeys</a>',
        win_key: "Win Key",
        confirm: "OK",
        none: "None"
    },
    cursor_mode: {
        title: "Cursor Detection Mode",
        tab: "Cursor Detection Mode",
        lv_process: "Process Name",
        lv_mode: "Cursor Detection Mode",
        lv_time: "Created",
        process_name_label: "1. Process Name: ",
        mode_label: "2. Cursor Detection Mode: "
    },
    switch_window: {
        title: "Auto Switch IME Status by Window",
        rule_add: " Auto Switch Rule",
        count_suffix: " items )",
        need_switch_to: "Apps to auto-switch to ",
        app_window: " status",
        count_prefix: "( ",
        lv_process: "Process Name",
        lv_scope: "Match Scope",
        lv_mode: "Match Mode",
        lv_title: "Match Title",
        lv_time: "Created",
        quick_add: "Quick Add",
        manual_add: "Manual Add",
        status_switch: "2. Status Switch: ",
        cn_status: "Chinese Status",
        en_status: "English Status",
        caps_status: "Caps Lock",
        complete_add: "Finish Adding",
        complete_edit: "Finish Editing",
        delete_it: "Delete It"
    },
    auto_exit: {
        title: "Auto Exit by Window",
        auto_exit_tab: "Auto Exit",
        rule_label: " Auto Exit Rule",
        action_type_label: "2. Action Type: ",
        action_pause: "Pause",
        action_exit: "Exit",
        need_auto: "Apps to auto "
    },
    app_offset: {
        title: "Special Offset",
        list: "Special Offset List",
        base_offset: "Set Base Offset for Different Screens",
        special_offset_col: "Special Offset",
        base_offset_title: "Set Base Offset for Different Screens",
        base_offset_tip: "- Set base offset for different screens`n- Close this window (click X) for offset to take full effect",
        screen_label: "Screen ",
        h_offset: "Horizontal Offset",
        v_offset: "Vertical Offset",
        screen_info: "Screen Info: ",
        main_screen: "This is the main screen (primary display), Screen ID: ",
        secondary_screen: "This is a secondary screen (secondary display), Screen ID: ",
        screen_coords: "Screen coordinates (X,Y): Top-left, Bottom-right: ",
        h_offset_label: "Horizontal offset: ",
        v_offset_label: "Vertical offset: ",
        screen_distinguish_tip: "If you don't know how to distinguish screens, check [About] in [Special Offset]"
    },
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
    bw_list: {
        title: "Symbol Black/White List",
        tab: "Symbol Black/White List",
        white_list: "Whitelist",
        black_list: "Blacklist",
        set_white_list: "Set Symbol Whitelist",
        set_black_list: "Set Symbol Blacklist",
        about_tip: "- Whitelist is the core of [Symbol Scheme], blacklist is supplementary`n- If you want to use [Symbol Scheme], you must set up the whitelist",
        about_link: '- About [Symbol Scheme]: <a href="https://inputtip.abgox.com/v2/#符号方案">Website</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>`n- About [List Mechanism]: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">Symbol List Mechanism</a>'
    },
    startup: {
        title: "Auto-start Settings",
        tab: "Auto-start Settings",
        not_available: " (N/A)",
        admin_tip: "Recommended: [Task Scheduler] > [Registry] > [App Shortcut]`nDue to permission or system limits, [App Shortcut] may not work",
        cancel_tip: "InputTip [Auto-start] has been cancelled`nSet again via [Tray Menu] => [Auto-start at Boot]",
        need_admin: "Administrator privileges required to cancel [Auto-start]`nSettings: [Tray Menu] => [Run as Administrator]",
        non_admin_tip: "Not running as admin, [Task Scheduler] and [Registry] unavailable`nClick [Run as Administrator] in [Tray Menu] to enable",
        task_scheduler: "Task Scheduler",
        registry: "Registry",
        shortcut: "App Shortcut"
    },
    cursor_scheme: {
        title: "Status Indicator - Cursor Scheme",
        tab: "Cursor Scheme",
        load_cursor: "Load cursor style:",
        keep_original: "[No] Keep original cursor",
        follow_state: "[Yes] Change with IME status",
        open_cursor_dir: "Open Cursor Style Directory",
        download_more: "Download More Cursor Styles",
        reverting: "Trying to restore cursor style to before InputTip started",
        revert_tip1: "May not fully restore, restart system to completely remove dynamically loaded cursors",
        revert_tip2: "If you don't want to restart, reapply previous cursor style through system settings"
    },
    symbol_scheme: {
        title: "Symbol Scheme",
        tab: "Symbol Scheme",
        type_label: "Symbol type:",
        type_none: " [Don't] show symbol",
        type_pic: " Show [Picture] symbol",
        type_block: " Show [Block] symbol",
        type_text: " Show [Text] symbol",
        mode_label: "Symbol display mode:",
        mode_realtime: " Realtime status display",
        mode_switch: " Switch status display",
        delay_label: "Symbol hide delay:",
        hover_hide_label: "Hide on mouse hover:",
        hover_hide_no: "[No] Keep visible when hovering on symbol",
        hover_hide_yes: "[Yes] Hide when hovering on symbol",
        offset_base_label: "Offset reference point:",
        offset_above: " Above input cursor",
        offset_below: " Below input cursor",
        btn_pic: "Picture Symbol",
        btn_block: "Block Symbol",
        btn_text: "Text Symbol",
        using_symbol: "You are starting to use [Symbol Scheme]",
        using_symbol_note: 'Note:`n[Symbol Scheme] uses mandatory whitelist mechanism`nYou need to add app processes via [Symbol Black/White List] in [Tray Menu]`nOnly processes in [Symbol Whitelist] will try to display symbol',
        using_symbol_link: 'See details: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">About Symbol Scheme Whitelist Mechanism</a>',
        symbol_note_title: "Symbol Scheme Notes",
        pic_title: "Symbol Scheme - Picture Symbol",
        block_title: "Symbol Scheme - Block Symbol",
        text_title: "Symbol Scheme - Text Symbol",
        basic_config: "Basic Config",
        isolate_config: "Isolated Config",
        h_offset: "Horizontal Offset",
        v_offset: "Vertical Offset",
        width: "Width",
        height: "Height",
        transparency: "Transparency",
        open_pic_dir: "Open Picture Symbol Dir",
        refresh_dropdown: "Refresh Dropdown List",
        download_more_pic: "Download More Picture Symbols",
        enable_init: "Enable",
        isolate_for: "Isolate Config for: ",
        isolate_btn: "Isolate Config",
        isolate_pic_title: "Isolate Config - Picture Symbol",
        isolate_block_title: "Isolate Config - Block Symbol",
        isolate_text_title: "Isolate Config - Text Symbol",
        color_cn: "Color in Chinese Status",
        color_en: "Color in English Status",
        color_caps: "Color in Caps Lock",
        border_style: "Border Style",
        bg_color: "Background Color",
        text_symbol_label: "Text Symbol",
        font_family: "Font Family",
        font_size: "Font Size",
        font_weight: "Font Weight",
        font_color: "Font Color",
        style_none: "None",
        style_1: "Style 1",
        style_2: "Style 2",
        style_3: "Style 3",
        color_label: "Color",
        v_offset: "Vertical Offset",
        width: "Width",
        height: "Height",
        transparency: "Transparency",
        cn_color: "Chinese status color",
        en_color: "English status color",
        caps_color: "Caps Lock status color",
        border_style: "Border Style: ",
        border_none: "None",
        border_1: "Style 1",
        border_2: "Style 2",
        border_3: "Style 3",
        enable_isolate: "Enable ",
        isolate_suffix: " isolated config: ",
        isolate_config_btn: "Isolated Config",
        open_pic_dir: "Open Picture Symbol Directory",
        download_pic: "Download More Picture Symbols",
        font_family: "Font Family",
        font_color: "Font Color",
        font_size: "Font Size",
        font_weight: "Font Weight",
        text_char: "Text Character",
        bg_color: "Background Color",
        pic_symbol: "Picture Symbol",
        block_symbol: "Block Symbol",
        text_symbol: "Text Symbol",
        isolate_title: " Isolated Config"
    },
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
        poll_interval: "Poll Response Interval (ms):",
        poll_tip: "Affects responsiveness. Lower = more responsive but higher CPU. Default: 50ms",
        custom_tray_icon: "Custom Tray Icon",
        running: "Running: ",
        paused: "Paused: ",
        open_icon_dir: "Open Icon Directory",
        refresh_list: "Refresh List",
        font_size: "Menu Font Size:",
        poll_interval_label: "2. Poll Response Interval:",
        key_count: "3. Key Count Statistics:",
        key_count_off: "[No] Off",
        key_count_on: "[Yes] On",
        tray_tip_template: "4. Tray Icon Hover Text Template",
        key_count_template: "5. Key Count Text Template",
        template_vars: "Template variables available for 4 and 5:`n%\\n% (newline), %keyCount% (key count), %appState% (app status)",
        language: "Language / 语言",
        jab_enabling: "JAB/JetBrains IDE Support [Enabling]",
        jab_disabling: "JAB/JetBrains IDE Support [Disabling]",
        jab_enable_success: "JAB/JetBrains IDE support enabled successfully, you also need to:           ",
        jab_steps: "1. Enable Java Access Bridge (ignore if symbol near cursor not needed)`n2. Click [Cursor Detection Mode] below or in [Tray Menu]`n3. Set JetBrains IDE or other JAB app process cursor mode to [JAB]`n4. Restart InputTip if not working`n5. Restart IDE/JAB app if still not working`n6. Restart system if still not working`n7. Use [Special Offset] for coordinate deviation on secondary screens",
        jab_jdk_tip: "JAB in some JDK/JRE versions is invalid, Microsoft OpenJDK 21 is recommended",
        jab_link: 'Detailed steps:   <a href="https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains">Website</a>   <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Github</a>   <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Gitee</a>',
        btn_cursor_mode: "[Cursor Detection Mode]",
        btn_app_offset: "[Special Offset]",
        lang_changed_cn: "Language changed to Chinese",
        lang_changed_en: "Language changed to English",
        restart_tip_cn: "Please restart InputTip for changes to take full effect",
        restart_tip_en: "Please restart InputTip for changes to take full effect",
        lang_settings: "Language Settings"
    },
    check_update: {
        title: "Check Update",
        checking: "Checking for updates...",
        latest: "You are using the latest version",
        available: "New version available: ",
        download: "Download",
        skip: "Skip This Version",
        remind_later: "Remind Me Later",
        title_version: " Version",
        downloading: "Downloading InputTip new version ",
        downloading_suffix: " ...",
        website: "Website:",
        changelog: "Changelog:",
        silent_ready: "Preparing silent update...",
        silent_wait: "Waiting for system idle...",
        has_update: "InputTip has update: ",
        changelog_fail: "Failed to load changelog, check online:",
        repo_addr: "Repo Address:",
        confirm_update: "Confirm Update",
        cancel_update: "Cancel Update",
        close_check: "Disable Check",
        enable_silent: "Enable Silent",
        download_error: "InputTip Download Error!",
        manual_download: "Please manually download and replace InputTip.exe.",
        close_success: "InputTip - Update Check Disabled",
        check_closed: " Update Check ",
        closed: "Disabled",
        close_tip: "InputTip will not check for updates again unless reset",
        set_way: "Setting: [Tray Menu] => [Check Update]",
        feedback_tip: "If issues persist, check feedback channels in [About]",
        syncing: "Syncing with source repo...",
        download_verify: "Downloading and verifying: ",
        download_ini: "Downloading files.ini...",
        sync_fail: "Sync failed with source repo!",
        check_net: "Please check network or try again.",
        manual_down_tip: "Or download manually from website/repo.",
        completed: "InputTip - Update Completed",
        completed_msg: "InputTip update completed, current version:",
        freq_label: "Update Check Frequency: ",
        auto_silent_label: "Auto Silent Update: ",
        disabled: " Disabled",
        enabled: " Enabled",
        check_now: "Check For Updates Now",
        sync_repo: "Sync With Source Repo",
        check_title: "Update Check",
        about_tab: "About"
    },
    process_list: {
        title: "Running Process List",
        lv_name: "Process Name",
        lv_title: "Window Title",
        lv_path: "File Path",
        source_whitelist: "Whitelist",
        refresh_list: "Refresh List",
        double_click_add: "Double-click any row to add",
        show_more: "Show More Processes",
        show_less: "Show Fewer Processes",
        tab_list: "Process List",
        source_system: "System",
        source_config: "Config",
        about_short: "1. Source: System`n   - All currently running app processes`n`n2. Source: Config`n   - App processes already in config file`n   - If for [Show Symbol], only shows [Show Symbol] config"
    },
    about_text: {
        check_update_menu: "1. Config - Update Check Frequency`n   - How often to check for updates`n   - Unit: Minutes, default 1440 (1 day)`n   - Set to 0 to disable update check`n   - If not 0, checks immediately on InputTip startup`n`n2. Config - Auto Silent Update`n   - If enabled, updates silently during idle time instead of showing popup`n   - Idle time: 3 mins without mouse/keyboard activity`n   - Invalid if [Update Check Frequency] is 0`n`n3. Button - Check For Updates Now`n   - Checks for version update immediately`n   - If no popup and no network error, you have the latest version",
        check_update_menu_sync: "`n`n4. Button - Sync With Source Repo`n   - Downloads latest source code from repo`n   - Downloads regardless of version update",
        symbol_scheme: "1. Config - Symbol Type`n   - To display symbols, you must add apps to [Symbol Whitelist]`n   - Only apps in [Symbol Whitelist] will attempt to display symbols`n   - It tries to get input cursor position first; if failed, no symbol shown`n   - Try [Show Symbol Near Cursor] as fallback for failed cases`n`n2. Config - Symbol Display Mode`n   - Different modes reload and display symbols at different times`n   - [Realtime status display]: On IME status change or cursor position change`n   - [Switch status display]: Only on IME status change`n   - If using [Switch status display], [Hide Delay] should not be 0`n`n3. Config - Symbol Hide Delay`n   - Time before symbol hides when no keyboard/mouse activity`n   - Unit: ms, default 0 (never hide)`n   - Symbol reappears on next keyboard action or left-click`n`n4. Config - Hide on Mouse Hover`n   - Whether to hide symbol when mouse hovers over it`n   - Symbol reappears when cursor position changes`n`n5. Config - Offset Reference Point`n   - Vertical offset reference for symbol near input cursor`n   - Use [Above input cursor] if you want symbol above cursor`n   - This setting doesn't work for JAB/JetBrains IDE; use [Special Offset]`n`n6. Buttons - Picture/Block/Text Symbol`n   - Click to open corresponding symbol config menu",
        symbol_pic_isolate: "1. Config - Offset/Width/Height`n   - Set separate parameters for different states`n   - Horizontal/Vertical Offset: relative to cursor`n   - Width/Height: of the picture symbol`n   - Note: offsets add up together`n`n2. About Isolate Config`n   - Allows different sizes/offsets for Chinese/English/Caps Lock states",
        symbol_block_isolate: "1. Config - Color`n   - Set separate colors for different states`n   - Requires English color name or hex code (no #)`n   - Empty to hide symbol`n`n2. Config - Offset/Width/Height/Transparency`n   - Set parameters for block symbol`n`n3. About Isolate Config`n   - Allows different visual styles for different states",
        symbol_text_isolate: "1. Config - Text`n   - Text to display for different states`n   - Empty to hide`n`n2. Config - Background Color`n   - Background color for text symbol`n`n3. Config - Font/Offset/Transparency`n   - Set font properties and position`n`n4. About Isolate Config`n   - Allows specific text/font/color per state",
        related_links: "Related links: ",
        other_config: "1. Button - Check Update`n   - Opens version update configuration menu`n`n2. Button - JAB/JetBrains IDE Support`n   - If using JetBrains IDE, double-click to enable and follow prompts`n   - InputTip can then get cursor position in JetBrains IDE`n`n3. Button - Open App Directory`n   - Opens the directory where the application is running`n`n4. Button - Set Username`n   - InputTip needs your username for [Auto-start] features`n   - Auto-detected on first run, can be modified via this button`n   - Domain users need to manually add domain prefix`n`n5. Config - Custom Tray Icon`n   - Add png images to icon directory, then select from dropdown`n`n6. Button - Open Icon Directory`n   - Opens icon directory to add your preferred icons`n`n7. Button - Refresh List`n   - Refresh dropdown after adding png images`n`n8. Config - Menu Font Size`n   - Optimize display on different screens (range: 5-30, suggest 12-20)`n`n9. Config - Poll Response Interval`n   - Every x ms, InputTip updates symbol position/status, IME state, cursor`n   - Default: 20ms, suggest under 50ms for stability`n`n10. Config - Key Count Statistics`n   - Track keyboard input count, displayed in templates below`n`n11. Config - Tray Icon Hover Template`n   - Text shown when hovering over tray icon`n   - Variables: %\\n% (newline), %keyCount%, %appState%`n`n12. Config - Key Count Template`n   - Added to hover tip when key count is enabled",
        startup: "1. Overview`n   - This menu sets InputTip auto-start at boot`n   - Choose from three methods below`n   - Note: If app location changes, re-setup required`n`n2. Button - Task Scheduler`n   - Creates task abgox.InputTip.noUAC`n   - Auto-runs InputTip on system startup`n   - Avoids UAC prompt at each startup`n   - May fail after Windows updates, re-setup needed`n`n3. Button - Registry`n   - Adds app path to auto-start registry`n   - Auto-runs InputTip on system startup`n`n4. Button - App Shortcut`n   - Creates shortcut in shell:startup folder`n   - May not work due to permissions or power settings`n`n5. About UAC Prompt`n   - Only [Task Scheduler] avoids UAC prompt directly`n   - For [Registry] or [Shortcut], modify system settings:`n      - Settings => Change UAC settings => Never notify",
        fn_common: "1. Overview`n   - This menu configures matching rules`n   - Below is the rule list`n   - Double-click any row to edit or delete`n   - See button instructions below for adding rules`n`n2. Rule List - Process Name`n   - Actual process name of the window`n`n3. Rule List - Match Scope`n   - [Process Level] or [Title Level]`n   - [Process Level]: Triggers in this process`n   - [Title Level]: Triggers only when in process AND title matches`n`n4. Rule List - Match Mode`n   - Only effective for [Title Level]`n   - [Exact] or [Regex] controls title matching`n   - [Exact]: Title must match exactly`n   - [Regex]: Uses regex pattern matching`n`n5. Rule List - Match Title`n   - Only effective for [Title Level]`n   - Specify a title or regex pattern`n   - Get window info via [Tray Menu] => [Get Window Info]`n`n6. Rule List - Created Time`n   - Creation time of each rule`n`n7. Operations`n   - Double-click any row to edit or delete`n`n8. Button - Quick Add`n   - Shows running process list`n   - Double-click any row to quick add`n`n9. Button - Manual Add`n   - Opens add dialog for manual input",
        switch_window: "1. Overview`n   - This menu sets [Auto Switch IME Status by Window] rules`n   - Above are three tabs: [Chinese Status] [English Status] [Caps Lock]`n   - Below is the rule list`n   - Double-click any row to edit or delete`n   - See button instructions below for adding rules`n`n2. Rule List - Process Name`n   - Actual process name of the window`n`n3. Rule List - Match Scope`n   - [Process Level] or [Title Level] controls switch timing`n   - [Process Level]: Triggers when switching between processes`n   - [Title Level]: Triggers on title change if match succeeds`n`n4. Rule List - Match Mode`n   - Only effective for [Title Level]`n   - [Exact] or [Regex] controls title matching`n   - [Exact]: Title must match exactly`n   - [Regex]: Uses regex pattern matching`n`n5. Rule List - Match Title`n   - Only effective for [Title Level]`n   - Specify title or regex pattern`n   - Get window info via [Tray Menu] => [Get Window Info]`n`n6. Auto Switch Prerequisites`n   - IME must be able to switch when InputTip executes auto-switch`n   - Caps Lock works via simulated CapsLock key, unaffected`n`n   - Example: Microsoft IME only switches when focused on input field`n   - Example: US Keyboard (ENG) only has English and Caps Lock",
        auto_exit: "1. Overview`n   - This menu sets [Auto Exit by Window] rules`n   - Typically used for games to ensure InputTip exits when game starts`n   - Best practice: manually exit InputTip before starting games`n`n   - Below is the rule list`n   - Double-click any row to edit or delete`n   - See button instructions below for adding rules`n`n2. Rule List - Process Name`n   - Actual process name of the window`n`n3. Rule List - Match Scope`n   - [Process Level] or [Title Level] controls trigger timing`n   - [Process Level]: Triggers when switching between processes`n   - [Title Level]: Triggers on title change if match succeeds`n`n4. Rule List - Match Mode`n   - Only effective for [Title Level]`n   - [Exact] or [Regex] controls title matching`n   - [Exact]: Title must match exactly`n   - [Regex]: Uses regex pattern matching`n`n5. Rule List - Match Title`n   - Only effective for [Title Level]`n   - Specify title or regex pattern`n   - Get window info via [Tray Menu] => [Get Window Info]`n`n6. Buttons - Quick Add / Manual Add`n   - Quick Add: Shows running process list`n   - Manual Add: Opens add dialog for manual input",
        cursor_mode: "1. Overview`n   - This menu sets [Cursor Detection Mode] rules`n   - Below is the rule list`n   - Double-click any row to edit or delete`n   - See button instructions below for adding rules`n`n2. Rule List - Process Name`n   - Actual process name of the window`n`n3. Rule List - Cursor Detection Mode`n   - Includes [HOOK] [UIA] [MSAA] [JAB] etc.`n   - Don't worry about what these modes are - use whichever works`n   - For details, see related links below`n`n4. Rule List - Created Time`n   - Creation time of each rule`n`n5. Button - Add Cursor Mode Rule`n   - Add a new rule specifying which mode an app should use`n   - Shows running process list, double-click to quick add`n`n6. Cursor Mode - JAB`n   - Special mode for Java Access Bridge apps like JetBrains IDE`n   - Works with [JAB/JetBrains IDE Support] in [Other Settings]`n   - See [JAB/JetBrains IDE Support] for details",
        process_list: "1. Overview`n   - This menu shows all running [Process List]`n   - List sorted by [Process Name] alphabetically`n   - Double-click any row to add the process`n`n2. Process List - Process Name`n   - Actual process name of the application`n   - If unsure which app, check [Window Title] or [File Path]`n   - Or use the tip in point 6`n`n3. Process List - Source`n   - [System]: Process obtained from system, currently running`n   - [Whitelist]: Process exists in whitelist, added for convenience`n`n4. Process List - Window Title`n   - Title of the window displayed by this process`n   - Use this to identify which app it belongs to`n`n5. Process List - File Path`n   - Path to the executable file of this process`n   - Use this to identify which app it belongs to`n`n6. Tip - Get Current Window Process Info`n   - Use [Get Window Info] in [Tray Menu]`n   - Shows realtime [Process Name] [Window Title] [Process Path]`n`n7. Button - Refresh List`n   - List shows currently running processes`n   - If you open an app after opening this menu, click to refresh`n`n8. Button - Show More Processes`n   - By default, shows foreground processes (with windows)`n   - Click to show more processes including background ones`n`n9. Button - Show Fewer Processes`n   - Appears after clicking [Show More Processes]`n   - Click to show only foreground processes again",
        about_custom: "1. Why [Custom] mode is needed`n   - InputTip determines IME status from system's status code and conversion code`n   - [General] mode works for most common input methods`n   - But some input methods return special status/conversion codes`n   - In such cases, you need rules to tell InputTip the current IME status`n   - This is the most stable way; if familiar, prefer it over [General]`n`n2. How [Custom] mode works`n   - InputTip gets current status/conversion codes and matches them against rules`n   - Each rule corresponds to an IME status; if matched, that status is identified`n   - If no rules match, the default status is used`n   - So if you use multiple input methods, [Custom] mode can help compatibility`n`n3. Config - Default Status`n   - Acts as a fallback`n   - If no rules match, this default status is used`n`n4. Rule List`n   - The table in the [Custom] tab above`n   - Add rule: Click [Add Rule] button, configure in the menu`n   - Edit rule: Double-click any existing rule`n   - Delete rule: Double-click a rule, then click [Delete This Rule]`n`n5. Rule Settings`n   - Click [Show realtime status/conversion code] to see different status values`n   - After clicking [Add Rule], a settings menu appears`n   - Contains 4 settings: Match Order, IME Status, Status Code Rule, Conversion Code Rule`n`n6. Rule Settings - Match Order`n   - Specifies this rule's position in the rule list`n`n7. Rule Settings - IME Status`n   - Specifies the IME status for this rule`n   - When this rule matches, InputTip identifies this as the current status`n`n8. Rule Settings - Status Code Rule / Conversion Code Rule`n   - Two forms: Specify number or Specify pattern`n   - Can only choose one form; explained below`n   - You can set both rules; both must match for the rule to succeed`n`n9. Rule Settings - Specify number`n   - Enter one or more numbers; any match succeeds`n   - Multiple numbers separated by / (e.g., 1/3/5)`n   - Example: To match status code 1, enter 1 in Status Code Rule`n   - Example: To match conversion code 1 or 3, enter 1/3`n`n10. Rule Settings - Specify pattern`n   - Some input methods return codes with patterns (e.g., random odd numbers)`n   - Can't list all odd numbers, so use pattern matching`n   - Select [Odd] or [Even] from the dropdown",
        about_switch: "1. Config - Method to switch IME status`n   - Options: LShift, RShift, Ctrl+Space, or Internal DLL call`n   - Recommended: Use LShift or RShift only`n   - These features require IME status switching:`n      - [Status Switch Hotkeys]`n      - [Auto Switch Status by Window]`n`n2. Option - Simulate LShift`n   - When switching IME status, InputTip simulates pressing LShift`n   - Like InputTip pressing the left Shift key for you`n   - Note: Only works if current context can switch IME with LShift`n`n3. Option - Simulate RShift`n   - Similar to LShift, but simulates the right Shift key`n`n4. Option - Simulate Ctrl+Space`n   - Similar to LShift/RShift, but simulates Ctrl + Space`n   - Don't use if LShift/RShift works`n   - Check for hotkey conflicts; may trigger unexpected Space`n   - Example: Action Center (WiFi/Bluetooth/Sound quick settings)`n   - Opening it may detect window switch and trigger Ctrl+Space, turning off WiFi`n`n5. Option - Internal DLL call`n   - Not recommended unless other options fail`n   - Directly calls system DLL interface to set IME status`n   - Forceful setting may cause issues:`n      - May not work for some input methods`n      - DLL calls may have side effects on input methods`n      - Keyboards without Chinese mode (US Keyboard) will be forced, causing display errors",
        app_offset: "1. Overview`n   - This menu configures [Special Offset List] rules`n   - Below is the rule list`n   - Double-click any row to edit or delete`n   - To add, see button instructions below`n`n2. Rule List - Process Name`n   - Actual process name of the window`n`n3. Rule List - Match Scope`n   - [Process Level] or [Title Level]`n   - [Process Level]: Triggers in this process`n   - [Title Level]: Triggers only when in process AND title matches`n`n4. Rule List - Match Mode`n   - Controls title matching, only effective for [Title Level]`n   - Currently only [Exact] is available for offset`n`n5. Rule List - Match Title`n   - Only effective for [Title Level]`n   - Specify a title or regex pattern`n   - Get window info via [Tray Menu] => [Get Window Info]`n`n6. Rule List - Special Offset`n   - Shows raw offset format: ScreenID/X/Y, separated by |`n   - Example: 1/10/20|2/30/40`n     - Screen 1: horizontal 10, vertical 20`n     - Screen 2: horizontal 30, vertical 40`n`n7. Buttons`n   - [Quick Add]: Shows running process list`n   - [Manual Add]: Opens add dialog with manual input`n   - [Set Base Offset]: Set base offset for different screens",
        cursor_scheme: "1. Config - Load cursor style`n   - Choose a cursor theme directory to load from`n   - Theme must contain compatible cursor files`n`n2. Config - Keep original cursor`n   - Use system default cursor, ignore InputTip cursor features`n`n3. Config - Change with IME status`n   - Cursor style/color changes indicating CN/EN/Caps status`n   - Requires cursor theme to maintain different state files",
        symbol_pos: "1. Overview`n   - In v1, symbols displayed near the cursor had no compatibility issues`n   - In v2, some windows can't get input cursor position, so this feature helps`n   - It shows the symbol near the cursor, following cursor movement`n   - See related links below for details`n`n2. Config - Apps to show symbol near cursor`n   - [Specified windows]: Specify windows using the button below`n   - [All windows]: Same effect as v1 version`n`n3. Config - Horizontal/Vertical offset`n   - Offset for symbol when displayed near cursor`n   - Note: Final offset = o1 + o4`n       - o1: Offset from symbol config page`n       - o4: Offset here`n`n4. Button - Specify apps`n   - If using [Specified windows], use this button`n   - Use it to specify apps that need symbol near cursor`n`n5. Suggestions`n   - Reduce [Polling Interval] in [Other Settings] to under 50ms`n   - Symbol position updates in real-time with cursor movement`n   - High values cause laggy symbol display"
    }
}

; Chinese language strings (中文)
global langStrings_zhCN := {
    app: {
        name: "InputTip",
        desc: "输入法状态管理器",
        file_desc: "InputTip - 输入法状态管理器"
    },
    state: {
        CN: "中文",
        EN: "英文",
        Caps: "大写锁定",
        Run: "运行",
        Pause: "暂停",
        Exit: "退出",
        Running: "运行中",
        Paused: "已暂停",
        cn_status: "中文状态",
        en_status: "英文状态"
    },
    common: {
        about: "关于",
        close: "关闭",
        save: "保存",
        cancel: "取消",
        add: "添加",
        edit: "编辑",
        delete: "删除",
        refresh: "刷新",
        yes: "【是】",
        no: "【否】",
        confirm: "确定",
        error: "错误",
        warning: "警告",
        success: "成功",
        tip_title: "InputTip - 提示",
        i_understand: "我知道了",
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
        odd: "奇数",
        even: "偶数",
        items: " 个"
    },
    gui: {
        help_tip: "请先点击上方的【关于】标签页，查看本菜单的使用说明",
        click_get: "点击获取",
        stop_get: "停止获取",
        refresh_list: "刷新列表",
        open_dir: "打开目录",
        add_to_whitelist: "是否添加到【符号的白名单】中: ",
        add_to_whitelist_no: "【否】不添加",
        add_to_whitelist_yes: "【是】自动添加",
        add_to_whitelist_tip: "如果选择【是】，且它在白名单中不存在，将以【进程级】自动添加",
        process_name_label: "1. 进程名称: ",
        match_scope_label: "2. 匹配范围: ",
        match_scope_tip: "【匹配模式】和【匹配标题】仅在【匹配范围】为【标题级】时有效",
        match_mode_label: "3. 匹配模式: ",
        match_title_label: "4. 匹配标题: ",
        editing_rule: "正在编辑规则",
        adding_rule: "正在添加规则",
        current_name: "名称: ",
        current_title: "标题: ",
        current_path: "路径: ",
        realtime_info: "实时获取当前聚焦的窗口进程信息: 窗口进程名称 + 窗口标题 + 窗口进程路径",
        lv_name: "进程名称",
        lv_source: "来源",
        lv_title: "窗口标题",
        lv_path: "文件路径",
        source_system: "系统",
        source_whitelist: "白名单"
    },
    tray: {
        guide: "使用指南",
        guide_title: "InputTip - 使用指南",
        guide_intro: "如果你是初次使用 InputTip，以下是一些建议:",
        guide_tip1: '1. 先看看视频教程: <a href="https://www.bilibili.com/video/BV15oYKz5EQ8">InputTip 使用教程 - B站</a>',
        guide_tip2: '2. 查看 <a href="https://inputtip.abgox.com">官网</a>、<a href="https://inputtip.abgox.com/faq">常见问题</a>，以及 <a href="https://github.com/abgox/InputTip">Github</a> 或 <a href="https://gitee.com/abgox/InputTip">Gitee</a> 上的源码',
        guide_tip3: "3. 如果你有其他问题，可以在【关于】中查找反馈渠道",
        startup: "开机自启动",
        admin_mode: "以管理员模式运行",
        create_shortcut: "创建桌面快捷方式",
        pause_run: "暂停/运行",
        input_method: "输入法",
        hotkey_switch: "状态切换快捷键",
        auto_switch: "指定窗口自动切换状态",
        cursor_scheme: "状态指示器 - 鼠标方案",
        symbol_scheme: "状态指示器 - 符号方案",
        symbol_near_cursor: "在鼠标附近显示符号",
        bw_list: "符号的黑/白名单",
        window_info: "获取窗口信息",
        cursor_mode: "光标获取模式",
        special_offset: "特殊偏移量",
        other_settings: "其他设置",
        about: "关于",
        restart: "重启",
        exit: "退出",
        admin_cancel_tip1: "【管理员权限】无法直接降级为【用户权限】",
        admin_cancel_tip2: "如需立即生效，需要手动退出并重启 InputTip",
        set_username: "设置用户名",
        set_username_title: "设置用户名",
        current_username: "当前的用户名: ",
        username_check_tip: "请自行检查，确保用户名无误后，点击右上角的 × 直接关闭此窗口即可",
        username_about: "1. 简要说明`n   - 这个菜单用来设置用户名信息`n   - 如果是域用户，在填写时还需要添加域，参考以下格式`n      - DOMAIN\\Username`n      - Username@domain.com`n   - 如果用户名信息有误，以下功能可能会失效`n      - 【开机自启动】中的 【任务计划程序】`n      - 【其他设置】中的【JAB/JetBrains IDE 支持】",
        window_info_title: "获取窗口信息",
        tip_template_default: "【%appState%】InputTip - 输入法状态管理器",
        key_count_template_default: "%\n%【统计中】启动以来, 有效的按键输入次数: %keyCount%"
    },
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
    cursor_mode: {
        title: "光标获取模式",
        tab: "光标获取模式",
        lv_process: "进程名称",
        lv_mode: "光标获取模式",
        lv_time: "创建时间",
        process_name_label: "1. 应用进程名称: ",
        mode_label: "2. 光标获取模式: "
    },
    app_offset: {
        title: "特殊偏移量",
        list: "特殊偏移量配置列表",
        base_offset: "配置不同屏幕的基础偏移量",
        special_offset_col: "特殊偏移量",
        base_offset_title: "配置不同屏幕的基础偏移量",
        base_offset_tip: "- 配置不同屏幕的基础偏移量`n- 关闭此窗口(点击 X)后偏移量才会完全生效",
        screen_label: "屏幕 ",
        h_offset: "水平偏移量",
        v_offset: "垂直偏移量",
        screen_info: "屏幕信息: ",
        main_screen: "这是主屏幕(主显示器)，屏幕标识: ",
        secondary_screen: "这是副屏幕(副显示器)，屏幕标识: ",
        screen_coords: "屏幕坐标信息(X,Y): 左上角，右下角: ",
        h_offset_label: "水平方向的偏移量: ",
        v_offset_label: "垂直方向的偏移量: ",
        screen_distinguish_tip: "如果不知道如何区分屏幕，可查看【特殊偏移量】中的【关于】"
    },
    input_method: {
        title: "输入法",
        base_config: "基础配置",
        custom: "自定义",
        about_custom: "关于自定义",
        about_switch: "关于切换输入法状态",
        mode_label: "1. 输入法状态识别模式:",
        mode_custom: " 自定义",
        mode_general: " 通用",
        mode_tip: "建议使用【自定义】，并在上方的【自定义】标签页中进行配置",
        switch_label: "2. 实现切换输入法状态的方式:",
        switch_dll: " 内部调用 DLL",
        switch_lshift: " 模拟输入 LShift",
        switch_rshift: " 模拟输入 RShift",
        switch_ctrl_space: " 模拟输入 Ctrl+Space",
        switch_tip: "如需修改此配置，请先查看【关于切换输入法状态】标签页的详细说明",
        keep_caps_label: "3. 保持大写锁定状态:",
        keep_caps_no: "【否】",
        keep_caps_yes: "【是】",
        keep_caps_tip: "启用后，大写锁定只能通过按 CapsLock 键关闭，自动切换将被禁用",
        timeout_label: "4. 输入法状态获取超时:",
        timeout_tip: "单位：毫秒，默认为 500 毫秒，非特殊情况不应该随意修改它`n每次切换输入法状态，InputTip 会从系统获取新的输入法状态`n如果超过了这个时间，则判定获取失败，直接判断为英文状态",
        custom_first_tip: "首先需要点击上方的【关于自定义】标签页，查看帮助说明，了解如何设置",
        default_status: "默认状态: ",
        default_en: " 英文状态",
        default_cn: " 中文状态",
        lv_order: "匹配的顺序",
        lv_status_rule: "状态码规则",
        lv_conv_rule: "切换码规则",
        lv_ime_status: "输入法状态",
        add_rule: "添加规则",
        add_rule_title: "添加规则",
        edit_rule_title: "编辑规则",
        order_label: "1. 匹配的顺序: ",
        ime_status_label: "2. 输入法状态: ",
        status_code_label: "3. 状态码规则: ",
        specify_number: "     - 指定数字: ",
        specify_pattern: "     - 指定规律: ",
        conv_code_label: "4. 切换码规则: ",
        delete_rule: "删除此条规则",
        show_realtime: "显示实时的状态码和切换码(双击设置快捷键)",
        show_realtime_tip: "显示实时的状态码和切换码",
        warning_title: "警告",
        warning_confirm: "确定要使用 ",
        warning_not_recommend: "不建议使用它，参考【关于切换输入法状态】的详细说明",
        custom_mode_warning: "使用【自定义】模式之前，务必仔细阅读下方的帮助说明，查看相关链接",
        finish_add: "完成添加",
        finish_edit: "完成编辑",
        rule_title: " 规则",
        odd: "奇数",
        even: "偶数",
        en_status: "英文状态",
        cn_status: "中文状态",
        none: "无",
        switch_ctrl_space_tip: "【模拟输入 Ctrl+Space】",
        switch_dll_tip: "【内部调用 DLL】"
    },
    hotkey: {
        title: "设置快捷键",
        tab_single: "设置单键",
        tab_combo: "设置组合快捷键",
        tab_manual: "手动输入快捷键",
        tip1_1: "1.",
        tip1_2: "快捷键设置不会实时生效，需要点击下方的【确定】后生效",
        tip2: "2.  LShift 指的是左边的 Shift 键，RShift 指的是右边的 Shift 键，其他按键以此类推",
        tip3: "3.  使用单键作为快捷键不会覆盖原本的按键功能，因为是在按键抬起时才会触发",
        tip4_link: '4.  如果要移除快捷键，请选择【无】。<a href="https://inputtip.abgox.com/faq/single-key-list">点击查看完整的按键名称对应表</a>',
        tip_combo2: "2.  直接按下快捷键即可设置，除非快捷键被占用，需要使用【手动输入快捷键】",
        tip_combo3: "3.  使用 Backspace(退格键) 或 Delete(删除键) 可以清除快捷键",
        tip_combo4: "4.  通过勾选右边的 Win 键来表示快捷键中需要加入 Win 修饰键",
        tip_manual2: "2.",
        tip_manual2_red: "优先使用【设置单键】或【设置组合快捷键】设置，除非因为快捷键占用无法设置",
        tip_manual3: '3.  这里会回显它们的设置，建议先使用它们，然后回到此处适当修改',
        tip_manual4_link: '4.  你需要首先查看 <a href="https://inputtip.abgox.com/faq/enter-shortcuts-manually">如何手动输入快捷键</a>',
        win_key: "Win 键",
        confirm: "确定",
        none: "无"
    },
    symbol_scheme: {
        title: "符号方案",
        tab: "符号方案",
        type_label: "指定符号的类型:",
        type_none: " 【不】显示符号",
        type_pic: " 显示【图片】符号",
        type_block: " 显示【方块】符号",
        type_text: " 显示【文本】符号",
        mode_label: "符号的显示模式:",
        mode_realtime: " 实时状态显示",
        mode_switch: " 切换状态显示",
        delay_label: "符号的延时隐藏:",
        hover_hide_label: "鼠标悬停时隐藏:",
        hover_hide_no: "【否】悬停在符号上时，符号保持显示",
        hover_hide_yes: "【是】悬停在符号上时，符号自动隐藏",
        offset_base_label: "偏移量参考原点:",
        offset_above: " 输入光标上方",
        offset_below: " 输入光标下方",
        btn_pic: "图片符号",
        btn_block: "方块符号",
        btn_text: "文本符号",
        basic_config: "基础配置",
        isolate_config: "独立配置",
        h_offset: "水平偏移量",
        v_offset: "垂直偏移量",
        width: "宽度",
        height: "高度",
        transparency: "透明度",
        open_pic_dir: "打开图片符号目录",
        refresh_dropdown: "刷新下拉列表",
        download_more_pic: "下载其他图片符号",
        enable_init: "是否启用",
        isolate_for: "的独立配置: ",
        isolate_btn: "独立配置",
        isolate_pic_title: "InputTip - 符号方案 - 图片符号",
        isolate_block_title: "InputTip - 符号方案 - 方块符号",
        isolate_text_title: "InputTip - 符号方案 - 文本符号",
        color_cn: "中文状态",
        color_en: "英文状态",
        color_caps: "大写锁定",
        border_style: "边框样式",
        bg_color: "背景颜色",
        text_symbol_label: "文本字符",
        font_family: "字符的字体",
        font_size: "字符的大小",
        font_weight: "字符的粗细",
        font_color: "字符的颜色",
        style_none: "无",
        style_1: "样式1",
        style_2: "样式2",
        style_3: "样式3",
        color_label: "颜色",
        using_symbol: "你正在开始使用【符号方案】了",
        using_symbol_note: '需要注意:`n【符号方案】使用了强制的白名单机制`n你需要使用【托盘菜单】中的【符号的黑/白名单】去添加应用进程`n只有添加到【符号的白名单】中的应用进程窗口才会尝试显示符号',
        using_symbol_link: '详情参考: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">关于符号方案中的名单机制</a>',
        symbol_note_title: "符号方案的注意事项",
        pic_title: "符号方案 - 图片符号",
        block_title: "符号方案 - 方块符号",
        text_title: "符号方案 - 文本符号",
        basic_config: "基础配置",
        isolate_config: "独立配置",
        h_offset: "水平偏移量",
        v_offset: "垂直偏移量",
        width: "宽度",
        height: "高度",
        transparency: "透明度",
        cn_color: "中文状态时的颜色",
        en_color: "英文状态时的颜色",
        caps_color: "大写锁定时的颜色",
        border_style: "边框样式: ",
        border_none: "无",
        border_1: "样式1",
        border_2: "样式2",
        border_3: "样式3",
        enable_isolate: "是否启用",
        isolate_suffix: "的独立配置: ",
        isolate_config_btn: "独立配置",
        open_pic_dir: "打开图片符号目录",
        download_pic: "下载其他图片符号",
        font_family: "字体",
        font_color: "字体颜色",
        font_size: "字体大小",
        font_weight: "字体粗细",
        text_char: "文本字符",
        bg_color: "背景颜色",
        pic_symbol: "图片符号",
        block_symbol: "方块符号",
        text_symbol: "文本符号",
        isolate_title: "独立配置"
    },
    symbol_pos: {
        title: "在鼠标附近显示符号的应用",
        tab: "在鼠标附近显示符号",
        window_label: "哪些窗口需要显示: ",
        specified_window: " 指定的窗口",
        all_window: " 所有的窗口",
        h_offset: "在鼠标附近显示时的水平偏移量: ",
        v_offset: "在鼠标附近显示时的垂直偏移量: ",
        specify_window_btn: "指定哪些应用在鼠标附近显示符号"
    },
    startup: {
        title: "开机自启动设置",
        tab: "开机自启动",
        admin_tip: "推荐: [任务计划程序] > [注册表] > [应用快捷方式]`n由于权限或系统电源计划限制等因素，[应用快捷方式] 可能会无效/不启动",
        not_available: " (需要管理员权限)",
        non_admin_tip: "说明: 灰色按钮需要管理员权限，请以管理员身份运行 InputTip 后再试",
        task_scheduler: "任务计划程序",
        registry: "注册表",
        shortcut: "应用快捷方式",
        cancel_tip: "已取消开机自启动",
        need_admin: "操作失败，请求被拒绝`n需要管理员权限"
    },
    cursor_scheme: {
        title: "状态指示器 - 光标方案",
        tab: "光标方案",
        load_cursor: "加载光标样式: ",
        keep_original: "[否] 保持原有光标",
        follow_state: "[是] 跟随状态切换光标",
        reverting: "正在还原光标...",
        revert_tip1: "还原成功",
        revert_tip2: "如果光标显示异常 (如一直转圈)，请重启电脑",
        open_cursor_dir: "打开光标样式目录",
        download_more: "下载其他光标样式"
    },
    bw_list: {
        title: "符号的黑/白名单",
        tab: "符号的黑/白名单",
        white_list: "符号的白名单",
        black_list: "符号的黑名单",
        set_white_list: "设置符号的白名单",
        set_black_list: "设置符号的黑名单",
        about_tip: "- [符号白名单] 是 [符号方案] 的核心，[符号黑名单] 是辅助`n- 如果你要使用 [符号方案]，必须设置白名单",
        about_link: '- 关于 [符号方案]: <a href="https://inputtip.abgox.com/v2/#符号方案">官网</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>`n- 关于 [名单机制]: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">符号名单机制</a>'
    },
    auto_exit: {
        title: "指定窗口自动退出",
        auto_exit_tab: "自动退出",
        rule_label: " 自动退出规则",
        action_type_label: "2. 行为类型: ",
        action_pause: "暂停",
        action_exit: "退出",
        need_auto: "需要自动 "
    },
    switch_window: {
        title: "指定窗口自动切换状态",
        rule_add: " 自动切换规则",
        count_suffix: " 个）",
        need_switch_to: "需要自动切换到",
        app_window: "的应用窗口",
        count_prefix: "（",
        lv_process: "进程名称",
        lv_scope: "匹配范围",
        lv_mode: "匹配模式",
        lv_title: "匹配标题",
        lv_time: "创建时间",
        quick_add: "快捷添加",
        manual_add: "手动添加",
        status_switch: "2. 状态切换: ",
        cn_status: "中文状态",
        en_status: "英文状态",
        caps_status: "大写锁定",
        complete_add: "完成添加",
        complete_edit: "完成编辑",
        delete_it: "删除它"
    },
    other_config: {
        title: "其他设置",
        tab1: "其他设置",
        tab2: "其他设置2",
        check_update: "更新检查",
        auto_exit_btn: "指定窗口自动退出",
        open_dir: "打开程序目录",
        set_username: "设置用户名",
        pause_hotkey: "暂停/运行快捷键",
        jab_support: "JAB/JetBrains IDE 支持 [",
        jab_enabled: "已启用",
        jab_disabled: "已禁用",
        jab_status: "]",
        custom_tray_icon: "自定义软件托盘图标",
        running: "运行中: ",
        paused: "暂停中: ",
        open_icon_dir: "打开图标目录",
        refresh_list: "刷新下拉列表",
        font_size: "1. 配置菜单字体大小:",
        poll_interval_label: "2. 轮询响应间隔时间:",
        key_count: "3. 按键输入次数统计:",
        key_count_off: "【否】关闭",
        key_count_on: "【是】开启",
        tray_tip_template: "4. 鼠标悬停在【托盘图标】上时的文字模板",
        key_count_template: "5. 按键输入次数统计的文字模板",
        template_vars: "这里有一些模板变量，它们在 4 和 5 中都可用:`n%\\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)",
        language: "语言 / Language",
        jab_enabling: "JAB/JetBrains IDE 支持【启用中】",
        jab_disabling: "JAB/JetBrains IDE 支持【禁用中】",
        jab_enable_success: "已经成功启用了 JAB/JetBrains IDE 支持，你还需要进行以下操作步骤:           ",
        jab_steps: "1. 启用 Java Access Bridge (如果不需要在输入光标处显示符号，忽略此步骤)`n2. 点击下方的或【托盘菜单】中的【光标获取模式】`n3. 设置 JetBrains IDE 或其他 JAB 应用进程的光标获取模式为【JAB】`n4. 如果未生效，请重启 InputTip`n5. 如果仍未生效，请重启正在运行的 JetBrains IDE 或其他 JAB 应用`n6. 如果仍未生效，请重启系统`n7. 有多块屏幕时，副屏幕上可能有坐标偏差，需要通过【特殊偏移量】调整",
        jab_jdk_tip: "部分 JDK/JRE 中的 Java Access Bridge 无效，推荐使用 Microsoft OpenJDK 21",
        jab_link: '详细操作步骤，请查看:   <a href="https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains">官网</a>   <a href="https://github.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Github</a>   <a href="https://gitee.com/abgox/InputTip#如何在-jetbrains-系列-ide-中使用-inputtip">Gitee</a>',
        btn_cursor_mode: "【光标获取模式】",
        btn_app_offset: "【特殊偏移量】",
        lang_changed_cn: "语言已更改为中文",
        lang_changed_en: "Language changed to English",
        restart_tip_cn: "请重启 InputTip 以使更改完全生效",
        restart_tip_en: "Please restart InputTip for changes to take full effect",
        lang_settings: "语言设置"
    },
    check_update: {
        title: "检查更新",
        checking: "正在检查更新...",
        latest: "当前已是最新版本",
        available: "发现新版本: ",
        download: "去下载",
        skip: "跳过此版本",
        remind_later: "以后提醒我",
        title_version: " 版本",
        downloading: "InputTip 新版本 ",
        downloading_suffix: " 下载中...",
        website: "官网:",
        changelog: "版本更新日志:",
        silent_ready: "准备静默更新......",
        silent_wait: "正在等待电脑空闲......",
        has_update: "InputTip 有版本更新: ",
        changelog_fail: "版本日志加载失败，你可以通过以下链接查看在线的版本更新日志",
        repo_addr: "项目仓库地址:",
        confirm_update: "确认更新",
        cancel_update: "取消更新",
        close_check: "关闭更新检查",
        enable_silent: "启用静默更新",
        download_error: "InputTip 新版本下载错误!",
        manual_download: "请手动下载最新版本的 InputTip.exe 文件并替换。",
        close_success: "InputTip - 成功关闭更新检查",
        check_closed: " 版本更新检查 ",
        closed: "已关闭",
        close_tip: "现在 InputTip 不会再检查版本更新，除非重新设置更新检查间隔",
        set_way: "设置方式:【托盘菜单】=>【更新检查】",
        feedback_tip: "如果在使用过程中有任何问题，先检查当前是否为最新版本`n如果更新到最新版本，问题依然存在，可以进行反馈`n【托盘菜单】的【关于】中有源代码仓库、腾讯频道等反馈渠道",
        syncing: "正在与源代码仓库同步...",
        download_verify: "正在下载和校验文件: ",
        download_ini: "正在下载远程仓库的 file.ini 文件...",
        sync_fail: "与源代码仓库同步失败!",
        check_net: "请检查网络连接或稍后重试。",
        manual_down_tip: "也可以前往官网或仓库手动下载。",
        completed: "InputTip - 版本更新完成",
        completed_msg: "InputTip 版本更新完成，当前版本:",
        freq_label: "更新检查频率: ",
        auto_silent_label: "自动静默更新: ",
        disabled: " 禁用",
        enabled: " 启用",
        check_now: "立即检查版本更新",
        sync_repo: "与源代码仓库同步"
    },
    process_list: {
        title: "正在运行的应用进程列表",
        lv_name: "进程名称",
        lv_title: "窗口标题",
        lv_path: "文件路径",
        double_click_add: "双击任意一行即可添加",
        tab_list: "应用进程列表",
        source_system: "系统",
        source_config: "配置",
        about_short: "1. 来源: 系统`n   - 当前系统正在运行的所有应用进程`n`n2. 来源: 配置`n   - 配置文件中已存在的应用进程配置`n   - 如果是【应用显示符号】的配置，则只显示【应用显示符号】的配置",
        source_whitelist: "白名单",
        refresh_list: "刷新列表",
        show_more: "显示更多进程",
        show_less: "显示更少进程"
    },
    about_text: {
        check_update_menu: '1. 配置项 —— 更新检查频率`n   - 设置每隔多长时间检查一次更新`n   - 单位: 分钟，默认 1440 分钟(1 天)`n   - 如果为 0，则表示不检查版本更新`n   - 如果不为 0，在 InputTip 启动时，会立即检查一次`n`n2. 配置项 —— 自动静默更新`n   - 启用后，不再弹出更新弹框，而是利用空闲时间自动更新`n   - 空闲时间: 3 分钟内没有鼠标或键盘操作`n   - 如果【更新检查频率】的值为 0，则此配置项无效`n`n3. 按钮 —— 立即检查版本更新`n   - 点击这个按钮后，会立即检查一次版本更新`n   - 如果没有更新弹窗且不是网络问题，则表示当前就是最新版本`n`n4. 按钮 —— 与源代码仓库同步`n   - 点击这个按钮后，会从源代码仓库中下载最新的源代码文件`n   - 不管是否有版本更新，都会下载最新的源代码文件',
        symbol_scheme: "1. 配置 —— 指定符号的类型`n   - 如果要显示符号，还必须添加【符号的白名单】`n   - 只有在【符号的白名单】中的应用进程，InputTip 才会尝试显示符号`n   - 它会先尝试获取输入光标位置，如果获取失败，则不显示符号`n   - 可以尝试【在鼠标附近显示符号】作为这种失败情况的折中方案`n`n2. 配置 —— 符号的显示模式`n   - 不同的模式，重新加载并显示符号的时机不同，默认使用【实时状态显示】`n   - 【实时状态显示】: 切换输入法状态、输入光标位置变化`n   - 【切换状态显示】: 切换输入法状态`n   - 如果选择了【切换状态显示】，则【符号的延时隐藏】不应该为 0`n`n3. 配置 —— 符号的延时隐藏`n   - 它指的是当无键盘或鼠标左键点击操作时，符号在多久后隐藏`n   - 单位: 毫秒，默认为 0，表示永不隐藏`n   - 当符号隐藏后，下次键盘操作或点击鼠标左键时再次显示`n   - 如果【符号的显示模式】为【切换状态显示】，则键盘操作改为切换输入法状态`n`n4. 配置 —— 鼠标悬停时隐藏`n   - 它指的是当鼠标悬停在符号上时，符号是否需要隐藏`n   - 当符号隐藏后，输入光标位置发生变化时再次显示`n`n5. 配置 —— 偏移量参考原点`n   - 输入光标附近显示的符号的垂直偏移量会基于这个参考原点`n   - 如果你希望符号显示在输入光标的上方，使用【输入光标上方】，并基于此调整偏移量会更好`n   - 这个配置项对 JAB/JetBrains IDE 程序无效，需使用【特殊偏移量】单独处理`n`n6. 按钮 —— 图片符号/方块符号/文本符号`n   - 点击后，打开对应的符号配置菜单",
        symbol_pic_isolate: "1. 配置 —— 水平/垂直偏移量`n   - 它指的是符号在输入光标附近显示时的偏移量`n   - 注意，符号最终的偏移量为 o1 + o2 + o3`n       - o1 指的是这里的偏移量`n       - o2 指的是【特殊偏移量】中的【不同屏幕下的基础偏移量】`n       - o3 指的是【特殊偏移量】中为指定窗口设置的偏移量`n`n2. 配置 —— 宽度/高度`n   - 图片符号的宽度和高度`n`n3. 关于独立配置`n   - 可以给不同状态设置不同的偏移量和宽高",
        symbol_block_isolate: "1. 配置 —— 颜色`n   - 它用来设置不同状态下符号的颜色`n   - 它需要一个常见的颜色英文或 16 进制颜色值，不包含 #`n   - 如果设置为空，则对应状态不显示符号`n`n2. 配置 —— 水平/垂直偏移量`n   - 符号最终的偏移量为 o1 + o2 + o3`n`n3. 配置 —— 宽度/高度/透明度`n`n4. 关于独立配置`n   - 如果你需要在不同状态下时偏移量、宽高等有区别，就可以启用独立配置",
        symbol_text_isolate: "1. 配置 —— 文本字符`n   - 它用来设置不同状态下显示的文本`n   - 如果设置为空，则对应状态不显示符号`n`n2. 配置 —— 背景颜色`n`n3. 配置 —— 字符的字体/大小/粗细`n`n4. 配置 —— 水平/垂直偏移量`n`n5. 配置 —— 字符透明度`n`n6. 关于独立配置`n   - 如果你需要在不同状态下时偏移量、宽高等有区别，就可以启用独立配置",
        related_links: "相关链接: ",
        other_config: "1. 按钮 —— 更新检查`n   - 点击后，会打开版本更新相关的配置菜单`n`n2. 按钮 —— JAB/JetBrains IDE 支持`n   - 如果你正在使用 JetBrains IDE，请双击启用它，并根据窗口提示完成所有步骤`n   - 完成后，InputTip 才能在 JetBrains IDE 中获取到输入光标位置并显示符号`n`n3. 按钮 —— 打开软件目录`n   - 点击后，会自动打开软件所在的运行目录`n`n4. 按钮 —— 设置用户名`n   - InputTip 需要用到你的用户名来确保【开机自启动】等功能正常运行`n   - 首次初始化时会自动获取用户名并保存到配置文件中，之后可通过此按钮修改`n   - 对于域用户，自动获取的用户名缺少域前缀，需要手动添加`n`n5. 配置 —— 自定义软件托盘图标`n   - 只需将 png 图片添加到图片目录中，然后在下拉列表中选择它即可实现自定义`n`n6. 按钮 —— 打开图标目录`n   - 点击它后，会自动打开图标目录，你可以将自己喜欢的图标添加到这里`n   - 然后通过【自定义软件托盘图标】进行设置`n`n7. 按钮 —— 刷新下拉列表`n   - 当你将 png 图片添加到图片目录后，可能需要通过点击它刷新下拉列表`n`n8. 配置 —— 配置菜单字体大小`n   - 可以通过设置字体大小来优化配置菜单在不同屏幕上的显示效果`n   - 取值范围: 5-30，建议 12-20 之间`n`n9. 配置 —— 轮询响应间隔时间`n   - 每隔 x 毫秒，InputTip 就会更新符号的位置/状态、输入法状态、鼠标样式等`n   - 这里的 x 就是轮询响应间隔时间，单位：毫秒，默认为 20`n   - 建议 50 以内，因为轮询间隔越短，依赖轮询的部分功能的稳定性越好`n`n10. 配置 —— 按键输入次数统计`n   - 开启后，InputTip 会记录你的按键输入次数`n   - 然后通过写入下方的文字模板中进行显示`n   - 注意: 只有当上一次按键和当前按键不同时，才会记为一次有效按键`n`n11. 配置 —— 鼠标悬停在【托盘图标】上时的文字模板`n   - 鼠标悬停在【托盘图标】上时，会根据此处设置的文字模板进行显示`n   - 变量: %\\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)`n`n12. 配置 —— 按键输入次数统计的文字模板`n   - 开启【按键输入次数统计】后，此处的文字模板会被添加到鼠标悬停的提示中`n   - 变量: %\\n% (换行)，%keyCount% (按键次数)，%appState% (软件运行状态)",
        startup: "1. 简要说明`n   - 这个菜单用来设置 InputTip 的开机自启动`n   - 你可以从以下三种方式中，选择有效的方式`n   - 需要注意: 如果移动了软件所在位置，需要重新设置才有效`n`n2. 按钮 —— 任务计划程序`n   - 点击它，会创建一个任务计划程序 abgox.InputTip.noUAC`n   - 系统启动后，会通过它自动运行 InputTip`n   - 它可以直接避免每次启动都弹出管理员授权(UAC)窗口`n   - 当系统更新后，可能会失效，需要重新设置`n`n3. 按钮 —— 注册表`n   - 点击它，会将程序路径写入开机自启动的注册表`n   - 系统启动后，会通过它自动运行 InputTip`n`n4. 按钮 —— 应用快捷方式`n   - 点击它，会在 shell:startup 目录下创建一个普通的快捷方式`n   - 系统启动后，会通过它自动运行 InputTip`n   - 注意: 由于权限或系统电源计划限制等因素，它可能无效`n`n5. 关于管理员授权(UAC)窗口`n   - 只有【任务计划程序】能直接避免此窗口弹出`n   - 使用【注册表】或【应用快捷方式】需要修改系统设置`n      - 系统设置 =>【更改用户账户控制设置】=>【从不通知】",
        fn_common: "1. 简要说明`n   - 这个菜单用来配置匹配规则`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】`n   - 【进程级】: 只要在这个进程中时，就会触发`n   - 【标题级】: 只有在这个进程中，且标题匹配成功时，才会触发`n`n4. 规则列表 —— 匹配模式`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 【相等】或【正则】，它控制标题匹配的模式`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发`n   - 【正则】: 使用正则表达式匹配标题，匹配成功才会触发`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式，与【匹配模式】相对应`n   - 如果不知道当前窗口的相关信息(进程/标题等)，可以通过以下方式获取`n      - 【托盘菜单】=>【获取窗口信息】`n`n6. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n7. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n8. 按钮 —— 快捷添加`n   - 点击它，可以添加一条新的规则`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n9. 按钮 —— 手动添加`n   - 点击它，可以添加一条新的规则`n   - 它会直接弹出添加窗口，你需要手动填写进程名称、标题等信息",
        switch_window: "1. 简要说明`n   - 这个菜单用来设置【指定窗口自动切换状态】的匹配规则`n   - 上方是三个 Tab 标签页: 【中文状态】【英文状态】【大写锁定】`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】，它控制自动切换的时机`n   - 【进程级】: 只有从一个进程切换到另一个进程时，才会触发`n   - 【标题级】: 只要窗口标题发生变化，且匹配成功，就会触发`n`n4. 规则列表 —— 匹配模式`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 【相等】或【正则】，它控制标题匹配的模式`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发自动切换`n   - 【正则】: 使用正则表达式匹配标题，匹配成功则触发自动切换`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式，与【匹配模式】相对应，匹配成功则触发自动切换`n   - 如果不知道当前窗口的相关信息(进程/标题等)，可以通过以下方式获取`n      - 【托盘菜单】=>【获取窗口信息】`n`n6. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n7. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n8. 按钮 —— 快捷添加`n   - 点击它，可以添加一条新的规则`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n9. 按钮 —— 手动添加`n   - 点击它，可以添加一条新的规则`n   - 它会直接弹出添加窗口，你需要手动填写进程名称、标题等信息`n`n10. 自动切换生效需要满足的前提条件`n   - 前提条件: `n       - 当 InputTip 执行自动切换时，此时的输入法可以正常切换状态`n       - 大写锁定除外，因为它是通过模拟输入【CapsLock】按键实现，不受其他影响`n`n   - 以【微软输入法】为例`n   - 和常规输入法不同，只有当聚焦到输入框时，它才能正常切换输入法状态`n   - 但是，当 InputTip 执行自动切换时，可能并没有聚焦到输入框，自动切换就会失效`n`n   - 再以【美式键盘 ENG】为例`n   - 它只有英文状态和大写锁定，所以只有英文状态的和大写锁定的自动切换有效",
        auto_exit: "1. 简要说明`n   - 这个菜单用来设置【指定窗口自动退出】的匹配规则`n   - 通常用于指定一些游戏进程，以确保启动游戏时自动退出 InputTip`n   - 请注意，启动游戏前，手动确保退出 InputTip 才是最佳的使用习惯`n`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】，它控制触发时机`n   - 【进程级】: 只有从一个进程切换到另一个进程时，才会触发`n   - 【标题级】: 只要窗口标题发生变化，且匹配成功，就会触发`n`n4. 规则列表 —— 匹配模式`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 【相等】或【正则】，它控制标题匹配的模式`n   - 【相等】: 只有窗口标题和指定的标题完全一致，才会触发`n   - 【正则】: 使用正则表达式匹配标题，匹配成功则触发`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式，与【匹配模式】相对应，匹配成功则触发`n   - 如果不知道当前窗口的相关信息(进程/标题等)，可以通过以下方式获取`n      - 【托盘菜单】=>【获取窗口信息】`n`n6. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n7. 规则列表 —— 操作`n   - 双击列表中的任意一行，进行编辑或删除`n`n8. 按钮 —— 快捷添加`n   - 点击它，可以添加一条新的规则`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n9. 按钮 —— 手动添加`n   - 点击它，可以添加一条新的规则`n   - 它会直接弹出添加窗口，你需要手动填写进程名称、标题等信息",
        cursor_mode: "1. 简要说明`n   - 这个菜单用来设置【光标获取模式】的匹配规则`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 光标获取模式`n   - 包括【HOOK】【UIA】【MSAA】【JAB】等等`n   - 不用在意这些模式是啥，哪个能用，就用哪个即可`n   - 如果想了解详细的相关内容，可以查看下方相关链接`n`n4. 规则列表 —— 创建时间`n   - 它是每条规则的创建时间`n`n5. 按钮 —— 添加应用的光标获取模式`n   - 点击它，可以添加一条新的规则`n   - 这条规则用来指定某个应用进程使用什么光标获取模式`n   - 它会弹出一个新的菜单页面，会显示当前正在运行的【应用进程列表】`n   - 你可以双击【应用进程列表】中的任意一行进行快速添加`n   - 详细的使用说明请参考弹出的菜单页面中的【关于】`n`n6. 光标获取模式 —— JAB`n   - 在所有的光标获取模式中，【JAB】是特殊的`n   - 它仅用于需要使用 Java Access Bridge 的进程，比如 JetBrains IDE`n   - 它需要配合【其他设置】中的【JAB/JetBrains IDE 支持】一起使用`n   - 详情参考【JAB/JetBrains IDE 支持】的使用说明",
        process_list: "1. 简要说明`n   - 这个菜单中显示的是所有正在运行的【应用进程列表】`n   - 整个列表根据【进程名称】的首字母进行排序`n   - 双击列表中的任意一行，即可添加对应的这个应用进程`n`n2. 应用进程列表 —— 进程名称`n   - 应用程序实际运行的进程名称`n   - 如果不清楚是哪个应用的进程，可能需要通过【窗口标题】、【文件路径】来判断`n   - 或者使用第 6 点的技巧`n`n3. 应用进程列表 —— 来源`n   - 【系统】表明这个进程是从系统中获取的，它正在运行`n   - 【白名单】表明这个进程是存在于白名单中的，为了方便操作，被添加到列表中`n`n4. 应用进程列表 —— 窗口标题`n   - 这个应用进程所显示的窗口的标题`n   - 你可能需要通过它来判断这是哪一个应用的进程`n`n5. 应用进程列表 —— 文件路径`n   - 这个应用进程的可执行文件的所在路径`n   - 你可能需要通过它来判断这是哪一个应用的进程`n`n6. 技巧 —— 获取当前窗口的实时的相关进程信息`n   - 你可以使用【托盘菜单】中的【获取窗口信息】`n   - 它会实时获取当前聚焦的窗口的【进程名称】【窗口标题】【进程路径】`n`n7. 按钮 —— 刷新此界面`n   - 因为列表中显示的是当前正在运行的应用进程`n   - 如果你是先打开这个配置菜单，再打开对应的应用，它不会显示在这里`n   - 你需要重新打开这个配置菜单，或者点击这个按钮进行刷新`n`n8. 按钮 —— 显示更多进程`n   - 默认情况下，【应用进程列表】中显示的是前台应用进程，就是有窗口的应用进程`n   - 你可以点击它来显示更多的进程，比如后台进程`n`n9. 按钮 —— 显示更少进程`n   - 当你点击【显示更多进程】按钮后，会出现这个按钮`n   - 点击它又会重新显示前台应用进程",
        about_custom: "1. 为什么需要【自定义】模式`n   - InputTip 是通过系统返回的状态码和切换码来判断当前的输入法状态的`n   - 对于多数常用的输入法来说【通用】模式是可以正常识别的`n   - 但是部分输入法会使系统返回的状态码和切换码很特殊，无法统一处理`n   - 在这种情况下，就需要用户通过规则来告诉 InputTip 当前的输入法状态`n   - 这是最稳定的方式，如果你熟悉了它，就推荐使用它而不是【通用】`n`n2. 【自定义】模式的工作机制`n   - InputTip 会从系统获取到当前的状态码和切换码，通过规则列表进行顺序匹配`n   - 每一条规则对应一种输入法状态，如果匹配成功，则判断为此状态`n   - 如果都没有匹配成功，则使用默认状态`n   - 因此，如果你同时使用多个输入法，可以尝试通过【自定义】模式实现兼容`n`n3. 配置项 —— 默认状态`n   - 它实际上就是用于兜底的`n   - 如果规则列表中的所有规则都没有匹配成功，就会使用这个默认状态`n`n4. 规则列表`n   - 规则列表就是上方的【自定义】标签页中的表格`n   - 添加规则: 点击【添加规则】按钮，在菜单中进行规则设置`n   - 修改规则: 双击规则列表中已经存在的任意一条规则，在菜单中进行规则修改`n   - 删除规则: 双击规则列表中已经存在的任意一条规则，在菜单中点击【删除此条规则】`n`n5. 规则设置`n   - 点击【显示实时的状态码和切换码】，通过切换输入法状态，查看不同状态的区别`n   - 当点击【添加规则】按钮后，会出现一个规则设置菜单`n   - 菜单中包含 4 个设置: 匹配的顺序、输入法状态、状态码规则、切换码规则`n`n6. 规则设置 —— 匹配的顺序`n   - 指定这一条规则在规则列表中的顺序`n`n7. 规则设置 —— 输入法状态`n   - 它用来指定这一条规则对应的输入法状态`n   - 当这一条规则匹配成功后，InputTip 就会判定当前输入法状态为这一状态`n`n8. 规则设置 —— 状态码规则、切换码规则`n   - 有两种形式可以选择: 指定数字或指定规律`n   - 这两种形式只能选择其中一种，它们会在下方进行详细解释`n   - 需要注意的是，你可以同时设置状态码规则和切换码规则`n   - 如果同时设置，则表示此条规则需要状态码规则和切换码规则同时匹配成功`n`n9. 规则设置 —— 指定数字`n   - 你可以填入一个或多个数字，只要其中有一个数字匹配成功即可`n   - 如果是多个数字，需要使用 / 连接 (如: 1/3/5)`n   - 如: 你希望当状态码为 1 时匹配到这条规则，在【状态码规则】中填入 1 即可`n   - 如: 你希望当切换码为 1 或 3 时匹配到这条规则，在【切换码规则】中填入 1/3 即可`n`n10. 规则设置 —— 指定规律`n   - 由于部分输入法会使系统返回的状态码和切换码很特殊，呈现某种规律`n   - 比如随机奇数，这种情况无法通过指定数字来表示，因为不可能填入所有的奇数`n   - 对于这种情况，就可以通过指定规律来实现，在下拉列表中选择对应规律即可`n   - 如: 你希望当状态码为随机奇数时匹配到这条规则，选择【奇数】即可",
        about_switch: "1. 配置项 —— 实现切换输入法状态的方式`n   - 配置项有以下可选值，只建议使用 LShift 或 RShift`n      - 模拟输入 LShift`n      - 模拟输入 RShift`n      - 模拟输入 Ctrl+Space`n      - 内部调用 DLL`n   - 以下功能需要切换输入法状态`n      -【状态切换快捷键】`n      -【指定窗口自动切换状态】`n`n2. 可选值 —— 模拟输入 LShift`n   - 当需要切换输入法状态时，InputTip 会模拟输入 LShift 键`n   - 这相当于 InputTip 帮你按了一次键盘左边的 Shift 键`n   - 注意：状态切换生效的前提是，当前场景中输入法可以使用 LShift 键成功切换状态`n`n3. 可选值 —— 模拟输入 RShift`n   - 和 LShift 类似，只是会模拟输入键盘右边的 Shift 键`n`n4. 可选值 —— 模拟输入 Ctrl+Space`n   - 和 LShift、RShift 类似，只是会模拟输入组合快捷键 Ctrl + Space (空格)`n   - 如果 LShift、RShift 是可用的，就不建议使用它`n   - 如果必须使用它，请自行检查是否存在快捷键冲突，因为它可能触发意外的 Space`n   - 例如，任务栏中有个操作中心，有 WiFi/蓝牙/声音等快捷设置`n   - 点开它时，就可能判定为窗口切换，触发 Ctrl + Space，导致 WiFi 自动关闭`n`n5. 可选值 —— 内部调用 DLL`n   - 不建议使用它，除非是特殊情况，其他几种都无法正常使用`n   - 当需要切换输入法状态时，InputTip 会直接调用系统 DLL 接口去设置输入法状态`n   - 它是一种强制的设置行为，可能会导致以下问题，不建议使用`n      - 对于部分输入法可能无效`n      - DLL 调用行为有概率对输入法本身产生副作用`n      - 当需要设置为中文状态时，没有中文状态的键盘(如: 美式键盘)，也会被强行设置`n          - 这可能会导致基于此的鼠标样式和符号显示错误",
        app_offset: "1. 简要说明`n   - 这个菜单用来设置【特殊偏移量】的匹配规则`n   - 下方是对应的规则列表`n   - 双击列表中的任意一行，进行编辑或删除`n   - 如果需要添加，请查看下方按钮相关的使用说明`n`n2. 规则列表 —— 进程名称`n   - 应用窗口实际的进程名称`n`n3. 规则列表 —— 匹配范围`n   - 【进程级】或【标题级】`n   - 【进程级】: 只要在这个进程中时，就会触发`n   - 【标题级】: 只有在这个进程中，且标题匹配成功时，才会触发`n`n4. 规则列表 —— 匹配模式`n   - 控制标题匹配的模式，只有当匹配范围为【标题级】时，才会生效`n   - 目前只有【相等】模式可用于偏移量`n`n5. 规则列表 —— 匹配标题`n   - 只有当匹配范围为【标题级】时，才会生效`n   - 指定一个标题或者正则表达式`n   - 如果不知道当前窗口的相关信息，可以通过【托盘菜单】=>【获取窗口信息】获取`n`n6. 规则列表 —— 特殊偏移量`n   - 显示原始的偏移量格式: 屏幕ID/水平偏移/垂直偏移，用 | 分隔`n   - 示例: 1/10/20|2/30/40`n     - 屏幕 1: 水平 10, 垂直 20`n     - 屏幕 2: 水平 30, 垂直 40`n`n7. 按钮`n   - [快捷添加]: 显示正在运行的进程列表`n   - [手动添加]: 打开添加窗口进行手动填写`n   - [设置基础偏移量]: 为不同屏幕设置基础偏移量",
        cursor_scheme: "1. 配置 —— 加载光标样式`n   - 选择一个光标主题目录来加载`n   - 主题目录必须包含兼容的光标文件`n`n2. 配置 —— 保持原有光标`n   - 使用系统默认光标，忽略 InputTip 的光标功能`n`n3. 配置 —— 跟随状态切换光标`n   - 光标样式/颜色随输入法状态（中文/英文/大写）变化`n   - 需要光标主题包含不同状态的文件",
        symbol_pos: "1. 简要说明`n   - 在 v1 版本中，在鼠标附近显示符号的功能没有兼容性问题`n   - 在 v2 版本中，部分窗口无法获取输入光标位置，所以增加了此功能`n   - 它会让符号显示在鼠标光标附近，跟随鼠标移动`n   - 详情参考下方的相关链接`n`n2. 配置 —— 哪些窗口需要显示`n   - [指定的窗口]: 通过下方的按钮指定需要显示的窗口`n   - [所有的窗口]: 效果等同于 v1 版本`n`n3. 配置 —— 水平/垂直偏移量`n   - 符号显示在鼠标附近时的偏移量`n   - 注意: 最终偏移量 = o1 + o4`n       - o1: 符号配置页面中的偏移量`n       - o4: 此处的偏移量`n`n4. 按钮 —— 指定应用`n   - 如果选择了 [指定的窗口]，则使用此按钮`n   - 用来指定哪些应用需要使用此功能`n`n5. 建议`n   - 将 [其他设置] 中的 [轮询响应间隔时间] 调低到 50ms 以下`n   - 符号位置会实时跟随鼠标移动`n   - 如果间隔太大，符号显示会有明显的延迟感"
    }
}

; Current language setting (read from INI, default to English)
; Only initialize if not already set (e.g., by init guide's language selection)
if (!IsSet(currentLang)) {
    global currentLang := readIni("language", "en-US")
}

/**
 * Get translated string by key
 * @param {String} key - The translation key in dot notation (e.g., "tray.guide")
 * @param {String} fallback - Optional fallback text if key not found
 * @returns {String} The translated string
 */
lang(key, fallback := "") {
    global langStrings, langStrings_zhCN, currentLang
    
    ; Select the appropriate language object
    if (currentLang = "zh-CN") {
        langObj := langStrings_zhCN
    } else {
        langObj := langStrings
    }
    
    ; Parse the dot notation key and traverse the object
    parts := StrSplit(key, ".")
    result := langObj
    
    for part in parts {
        try {
            result := result.%part%
        } catch {
            ; Fallback to English if key not found in Chinese
            if (currentLang = "zh-CN") {
                result := langStrings
                for p in parts {
                    try {
                        result := result.%p%
                    } catch {
                        return fallback ? fallback : key
                    }
                }
                return result
            }
            return fallback ? fallback : key
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
    global trayTipTemplate, keyCountTemplate
    writeIni("language", langCode)
    ; Refresh tray tip template with new language
    trayTipTemplate := lang("tray.tip_template_default")
    keyCountTemplate := lang("tray.key_count_template_default")
    ; Update the actual tray icon tooltip
    try {
        updateTip()
    }
    ; Rebuild tray menu with new language
    try {
        makeTrayMenu()
    }
}

/**
 * Get the current language code
 * @returns {String} The current language code
 */
getLang() {
    global currentLang
    return currentLang
}

; ============================================================================
; END I18N LANGUAGE MODULE
; ============================================================================

filename := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4)
fileLnk := filename ".lnk"
fileDesc := lang("app.file_desc")
JAB_PID := ""

setTrayIcon(readIni("iconRunning", "InputTipIcon\default\app.png"))

try {
    keyCount := A_Args[1]
    if (!IsNumber(keyCount)) {
        keyCount := 0
    }
} catch {
    keyCount := 0
}

gc := {
    init: 0,
    timer: 0,
    timer2: 0,
    tab: 0,
    ; 记录窗口 Gui，同一个 Gui 只允许存在一个
    w: {
        updateGui: "",
        subGui: ""
    }
}

userName := readIni("userName", A_UserName, "UserInfo")

; 输入法模式
mode := readIni("mode", 1, "InputMethod")

; 更新检查时间间隔，默认是 1440 分钟，即 24 小时
checkUpdateDelay := readIni("checkUpdateDelay", 1440)

; 是否静默自动更新
silentUpdate := readIni("silentUpdate", 0)

; 当运行源代码时，是否直接以管理员权限运行
runCodeWithAdmin := readIni("runCodeWithAdmin", 0)

; 光标获取模式
modeList := {}

; 默认输入法状态(1: 中文, 0: 英文)
; 在自定义模式下，如果所有规则都不匹配，则返回此默认状态
baseStatus := readIni("baseStatus", 0, "InputMethod")

; 自定义模式下定义的模式规则
modeRule := readIni("modeRule", "", "InputMethod")
modeRules := StrSplit(modeRule, ":")

; 获取输入法状态的超时时间
checkTimeout := readIni("checkTimeout", 500, "InputMethod")

; 内部实现切换输入法状态的方式
switchStatus := readIni("switchStatus", 1)
switchStatusList := ["{LShift}", "{RShift}", "{Ctrl Down}{Space Down}{Ctrl Up}{Space Up}"]

; 是否改变鼠标样式
changeCursor := readIni("changeCursor", 0)

/*
符号类型
    1: 图片符号
    2: 方块符号
    3: 文本符号
*/
symbolType := readIni("symbolType", 1)
; 符号的垂直偏移量的参考原点
symbolOffsetBase := readIni("symbolOffsetBase", 1)

; 是否在所有窗口中，符号都显示在鼠标附近
showCursorPos := readIni("showCursorPos", 0)
; 需要将符号显示在鼠标附近的窗口列表
ShowNearCursor := StrSplit(readIniSection("ShowNearCursor"), "`n")
; 符号显示在鼠标附近时的特殊偏移量 x
showCursorPos_x := readIni("showCursorPos_x", 0)
; 符号显示在鼠标附近时的特殊偏移量 y
showCursorPos_y := readIni("showCursorPos_y", 30)

; 当鼠标悬停在符号上时，符号是否需要隐藏
hoverHide := readIni("hoverHide", 1)

; 在多少毫秒后隐藏符号，0 表示永不隐藏
hideSymbolDelay := readIni("hideSymbolDelay", 0)

; 符号的显示模式
symbolShowMode := readIni("symbolShowMode", 1)

; 是否保持大写锁定状态
keepCapsLock := readIni("keepCapsLock", 0)

; 轮询响应间隔
delay := readIni("delay", 20)

; 托盘菜单图标
iconRunning := readIni("iconRunning", "InputTipIcon\default\app.png")
iconPaused := readIni("iconPaused", "InputTipIcon\default\app-paused.png")

; 开机自启动
isStartUp := readIni("isStartUp", 0)

; 启用 JAB/JetBrains 支持
enableJABSupport := readIni("enableJABSupport", 0)

; 快捷键: 切换到中文
hotkey_CN := readIni('hotkey_CN', '')
; 快捷键: 切换到英文
hotkey_EN := readIni('hotkey_EN', '')
; 快捷键: 切换到大写锁定
hotkey_Caps := readIni('hotkey_Caps', '')
; 快捷键: 软件启停
hotkey_Pause := readIni('hotkey_Pause', '')
; 快捷键: 实时显示状态码和切换码
hotkey_ShowCode := readIni('hotkey_ShowCode', '')

getStateName(key) {
    if (key = "CN" || key = 1) 
        return lang("state.CN")
    if (key = "EN" || key = 0) 
        return lang("state.EN")
    if (key = "Caps") 
        return lang("state.Caps")
    if (key = "Run") 
        return lang("state.Run")
    if (key = "Pause") 
        return lang("state.Pause")
    if (key = "Exit") 
        return lang("state.Exit")
    return key
}
stateTextMap := Map(
    "Chinese", "CN",
    "中文状态", "CN",
    "English", "EN",
    "英文状态", "EN",
    "Caps Lock", "Caps",
    "大写锁定", "Caps",
    "Run", "Run",
    "运行", "Run",
    "Pause", "Pause",
    "暂停", "Pause",
    "Exit", "Exit",
    "退出", "Exit"
)

left := 0, top := 0, right := 0, bottom := 0
lastWindow := "", lastSymbol := "", lastCursor := ""

needHide := 0

exe_name := ""
exe_title := ""
exe_str := ":" exe_name ":"

leaveDelay := delay + 500

isWait := 0

; 配置菜单默认的宽度参考线
gui_width_line := "------------------------------------------------------------------------------------"



canShowSymbol := 0

screenList := getScreenInfo()

; 鼠标样式相关信息
cursorInfo := [{
    ; 普通选择
    type: "ARROW", value: "32512", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 文本选择/文本输入
    type: "IBEAM", value: "32513", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 繁忙
    type: "WAIT", value: "32514", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 精度选择
    type: "CROSS", value: "32515", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 备用选择
    type: "UPARROW", value: "32516", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 对角线调整大小 1  左上 => 右下
    type: "SIZENWSE", value: "32642", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 对角线调整大小 2  左下 => 右上
    type: "SIZENESW", value: "32643", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 水平调整大小
    type: "SIZEWE", value: "32644", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 垂直调整大小
    type: "SIZENS", value: "32645", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 移动
    type: "SIZEALL", value: "32646", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 无法(禁用)
    type: "NO", value: "32648", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 链接选择
    type: "HAND", value: "32649", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 在后台工作
    type: "APPSTARTING", value: "32650", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 帮助选择
    type: "HELP", value: "32651", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 位置选择
    type: "PIN", value: "32671", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 人员选择
    type: "PERSON", value: "32672", origin: "", CN: "", EN: "", Caps: ""
}, {
    ; 手写
    type: "PEN", value: "32631", origin: "", CN: "", EN: "", Caps: ""
}]

for v in cursorInfo {
    if (v.type = "CROSS") {
        value := "Crosshair"
    } else if (v.type = "PEN") {
        value := "NWPen"
    } else {
        value := v.type
    }
    try {
        v.origin := replaceEnvVariables(RegRead("HKEY_CURRENT_USER\Control Panel\Cursors", value))
    }
}

app_HideSymbol := StrSplit(readIniSection("App-HideSymbol"), "`n")
app_ShowSymbol := StrSplit(readIniSection("App-ShowSymbol"), "`n")
app_AutoExit := StrSplit(readIniSection("App-Auto-Exit"), "`n")
updateAutoSwitchList()

updateAppOffset()
updateCursorMode()
updateCursor()
updateSymbol()

; 更新鼠标样式
updateCursor() {
    global CN_cursor, EN_cursor, Caps_cursor, cursorInfo

    restartJAB()

    _ := {}

    colorMap := Map(
        "CN", "red",
        "EN", "blue",
        "Caps", "green",
    )

    for state in ["CN", "EN", "Caps"] {
        dir := readIni(state "_cursor", "InputTipCursor\default\oreo-" colorMap[state])
        if (!DirExist(dir)) {
            writeIni(state "_cursor", "InputTipCursor\default\oreo-" colorMap[state])
            dir := "InputTipCursor\default\oreo-" colorMap[state]
        }
        _.%state% := dir

        Loop Files dir "\*.*" {
            n := SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName) - 4)
            for v in cursorInfo {
                if (v.type = n) {
                    v.%state% := A_LoopFileFullPath
                }
            }
        }
    }

    CN_cursor := _.CN
    EN_cursor := _.EN
    Caps_cursor := _.Caps
}
; 加载鼠标样式
loadCursor(state, change := 0) {
    global lastCursor
    if (changeCursor) {
        if (state != lastCursor || change) {
            for v in cursorInfo {
                if (v.%state%) {
                    DllCall("SetSystemCursor", "Ptr", DllCall("LoadCursorFromFile", "Str", v.%state%, "Ptr"), "Int", v.value)
                }
            }
            lastCursor := state
        }
    }
}
; 重载鼠标样式
reloadCursor() {
    if (changeCursor) {
        if (GetKeyState("CapsLock", "T")) {
            loadCursor("Caps", 1)
        } else {
            if (isCN()) {
                loadCursor("CN", 1)
            } else {
                loadCursor("EN", 1)
            }
        }
    }
}


; 更新符号相关数据
updateSymbol(configName := "", configValue := "") {
    global symbolGui, symbolConfig

    hideSymbol()

    if (configName) {
        for state in ["", "CN", "EN", "Caps"] {
            symbolConfig.%configName state% := configValue
        }
    } else {
        restartJAB()

        ; 存放不同状态下的符号
        symbolGui := {
            EN: "",
            CN: "",
            Caps: ""
        }
        symbolConfig := {
            ; 启用独立配置
            enableIsolateConfigPic: readIni("enableIsolateConfigPic", 0),
            enableIsolateConfigBlock: readIni("enableIsolateConfigBlock", 0),
            enableIsolateConfigText: readIni("enableIsolateConfigText", 0),
        }

        info := {
            ; CN
            CN_color: "red",
            CN_Text: "中",
            textSymbol_CN_color: "red",
            ; EN
            EN_color: "blue",
            EN_Text: "英",
            textSymbol_EN_color: "blue",
            ; Caps
            Caps_color: "green",
            Caps_Text: "大",
            textSymbol_Caps_color: "green",
        }

        for state in ["", "CN", "EN", "Caps"] {
            ; * 图片符号相关配置
            ; 文件路径
            if (state) {
                symbolConfig.%state "_pic"% := readIni(state "_pic", "InputTipSymbol\default\triangle-" info.%state "_color"% ".png")
            }
            ; 偏移量
            _ := "pic_offset_x" state
            symbolConfig.%_% := readIni(_, -27)
            _ := "pic_offset_y" state
            symbolConfig.%_% := readIni(_, 0)
            ; 宽高
            _ := "pic_symbol_width" state
            symbolConfig.%_% := readIni(_, 15)
            _ := "pic_symbol_height" state
            symbolConfig.%_% := readIni(_, 15)

            ; * 方块符号相关配置
            ; 背景颜色
            if (state) {
                _ := state "_color"
                symbolConfig.%_% := StrReplace(readIni(_, info.%_%), '#', '')
            }
            ; 偏移量
            _ := "offset_x" state
            symbolConfig.%_% := readIni(_, 0)
            _ := "offset_y" state
            symbolConfig.%_% := readIni(_, 10)
            ; 透明度
            _ := "transparent" state
            symbolConfig.%_% := readIni(_, 222)
            ; 宽高
            _ := "symbol_width" state
            symbolConfig.%_% := readIni(_, 9)
            _ := "symbol_height" state
            symbolConfig.%_% := readIni(_, 9)
            ; 边框样式: 0(无边框),1(样式1),2(样式2),3(样式3)
            _ := "border_type" state
            symbolConfig.%_% := readIni(_, 1)

            ; * 文本符号相关配置
            ; 文本字符
            if (state) {
                _ := state "_Text"
                symbolConfig.%_% := readIni(_, info.%_%)
            }
            ; 背景颜色
            if (state) {
                _ := "textSymbol_" state "_color"
                symbolConfig.%_% := StrReplace(readIni(_, info.%_%), '#', '')
            }
            ; 字体
            _ := "font_family" state
            symbolConfig.%_% := readIni(_, 'Microsoft YaHei')
            ; 大小
            _ := "font_size" state
            symbolConfig.%_% := readIni(_, 12)
            ; 粗细
            _ := "font_weight" state
            symbolConfig.%_% := readIni(_, 600)
            ; 颜色
            _ := "font_color" state
            symbolConfig.%_% := StrReplace(readIni(_, 'ffffff'), '#', '')
            ; 偏移量
            _ := "textSymbol_offset_x" state
            symbolConfig.%_% := readIni(_, 0)
            _ := "textSymbol_offset_y" state
            symbolConfig.%_% := readIni(_, 10)
            ; 透明度
            _ := "textSymbol_transparent" state
            symbolConfig.%_% := readIni(_, 222)
            ; 边框样式: 0(无边框),1(样式1),2(样式2),3(样式3)
            _ := "textSymbol_border_type" state
            symbolConfig.%_% := readIni(_, 1)
        }
    }

    switch symbolType {
        case 1:
            ; 图片字符
            for state in ["CN", "EN", "Caps"] {
                pic_path := symbolConfig.%state "_pic"%
                if (pic_path) {
                    _ := symbolGui.%state% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    _.BackColor := "000000"
                    WinSetTransColor("000000", _)

                    if (symbolConfig.enableIsolateConfigPic) {
                        w := symbolConfig.%"pic_symbol_width" state%
                        h := symbolConfig.%"pic_symbol_height" state%
                    } else {
                        w := symbolConfig.pic_symbol_width
                        h := symbolConfig.pic_symbol_height
                    }
                    try {
                        _.AddPicture("w" w " h" h, pic_path)
                    }
                } else {
                    symbolGui.%state% := ""
                }
            }
        case 2:
            ; 方块符号
            for state in ["CN", "EN", "Caps"] {
                if (symbolConfig.%state "_color"%) {
                    _ := symbolGui.%state% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    __ := symbolConfig.enableIsolateConfigBlock

                    t := __ ? symbolConfig.%"transparent" state% : symbolConfig.transparent
                    WinSetTransparent(t)

                    try {
                        _.BackColor := symbolConfig.%state "_color"%
                    }

                    bt := __ ? symbolConfig.%"border_type" state% : symbolConfig.border_type
                    _.Opt("-LastFound")
                    switch bt {
                        case 1: _.Opt("+e0x00000001")
                        case 2: _.Opt("+e0x00000200")
                        case 3: _.Opt("+e0x00020000")
                    }
                } else {
                    symbolGui.%state% := ""
                }
            }
        case 3:
            ; 文本符号
            for state in ["CN", "EN", "Caps"] {
                if (symbolConfig.%state "_Text"%) {
                    _ := symbolGui.%state% := Gui("-Caption AlwaysOnTop ToolWindow LastFound", "abgox-InputTip-Symbol-Window")
                    __ := symbolConfig.enableIsolateConfigText

                    _.MarginX := 0, _.MarginY := 0

                    ff := __ ? symbolConfig.%"font_family" state% : symbolConfig.font_family
                    fz := __ ? symbolConfig.%"font_size" state% : symbolConfig.font_size
                    fc := __ ? symbolConfig.%"font_color" state% : symbolConfig.font_color
                    fw := __ ? symbolConfig.%"font_weight" state% : symbolConfig.font_weight
                    try {
                        _.SetFont('s' fz ' c' fc ' w' fw, ff)
                    }

                    _.AddText(, symbolConfig.%state "_Text"%)

                    t := __ ? symbolConfig.%"textSymbol_transparent" state% : symbolConfig.textSymbol_transparent
                    WinSetTransparent(t)

                    try {
                        _.BackColor := symbolConfig.%"textSymbol_" state "_color"%
                    }

                    bt := __ ? symbolConfig.%"textSymbol_border_type" state% : symbolConfig.textSymbol_border_type
                    switch bt {
                        case 1: _.Opt("-LastFound +e0x00000001")
                        case 2: _.Opt("-LastFound +e0x00000200")
                        case 3: _.Opt("-LastFound +e0x00020000")
                        default: _.Opt("-LastFound")
                    }
                } else {
                    symbolGui.%state% := ""
                }
            }
    }
}
; 加载符号
loadSymbol(state, left, top, right, bottom, isShowCursorPos := 0) {
    global lastSymbol, isOverSymbol
    static old_left := 0, old_top := 0

    if (!isShowCursorPos) {
        if (left = old_left && top = old_top) {
            if (state = lastSymbol || isOverSymbol) {
                return
            }
        } else {
            isOverSymbol := 0
        }
    }
    old_top := top
    old_left := left

    if (!symbolType || !canShowSymbol) {
        hideSymbol()
        return
    }
    showConfig := "NA "
    ; JAB 程序通过 GetCaretPosFromJAB 获取到的 W 和 H 非常不稳定
    ; 还是继续使用 top，根据实际情况再调整特殊偏移量
    if (InStr(modeList.JAB, exe_str)) {
        offsetY := top + bottom
    } else {
        offsetY := symbolOffsetBase ? bottom : top
    }
    if (symbolType = 1) {
        if (symbolConfig.enableIsolateConfigPic) {
            x := symbolConfig.%"pic_offset_x" state%
            y := symbolConfig.%"pic_offset_y" state%
        } else {
            x := symbolConfig.pic_offset_x
            y := symbolConfig.pic_offset_y
        }
        if (isShowCursorPos) {
            x += showCursorPos_x
            y += showCursorPos_y
        }
        showConfig .= "x" left + x " y" y + offsetY
    } else if (symbolType = 2) {
        if (symbolConfig.enableIsolateConfigBlock) {
            w := symbolConfig.%"symbol_width" state%
            h := symbolConfig.%"symbol_height" state%
            x := symbolConfig.%"offset_x" state%
            y := symbolConfig.%"offset_y" state%
        } else {
            w := symbolConfig.symbol_width
            h := symbolConfig.symbol_height
            x := symbolConfig.offset_x
            y := symbolConfig.offset_y
        }

        if (isShowCursorPos) {
            x += showCursorPos_x
            y += showCursorPos_y
        }
        showConfig .= "w" w "h" h "x" left + x " y" y + offsetY
    } else if (symbolType = 3) {
        if (symbolConfig.enableIsolateConfigText) {
            x := symbolConfig.%"textSymbol_offset_x" state%
            y := symbolConfig.%"textSymbol_offset_y" state%
        } else {
            x := symbolConfig.textSymbol_offset_x
            y := symbolConfig.textSymbol_offset_y
        }

        if (isShowCursorPos) {
            x += showCursorPos_x
            y += showCursorPos_y
        }
        showConfig .= "x" left + x " y" y + offsetY
    }
    if (lastSymbol != state) {
        hideSymbol()
    }

    if (symbolGui.%state%) {
        symbolGui.%state%.Show(showConfig)
    }

    lastSymbol := state
}
; 重载符号
reloadSymbol() {
    if (symbolType) {
        canShowSymbol := returnCanShowSymbol(&left, &top, &right, &bottom)
        if (GetKeyState("CapsLock", "T")) {
            type := "Caps"
        } else {
            if (isCN()) {
                type := "CN"
            } else {
                type := "EN"
            }
        }
        if (canShowSymbol) {
            loadSymbol(type, left, top, right, bottom)
        }
    }
}
; 隐藏符号
hideSymbol() {
    for state in ["CN", "EN", "Caps"] {
        try {
            symbolGui.%state%.Hide()
        }
    }
    global lastSymbol := ""
}

; 更新自动切换列表
updateAutoSwitchList() {
    global
    ; 应用列表: 自动切换到中文
    app_CN := StrSplit(readIniSection("App-CN"), "`n")
    ; 应用列表: 自动切换到英文
    app_EN := StrSplit(readIniSection("App-EN"), "`n")
    ; 应用列表: 自动切换到大写锁定
    app_Caps := StrSplit(readIniSection("App-Caps"), "`n")
}

/**
 * 将进程以【进程级】添加到白名单中
 * @param app 要添加的进程名称
 */
updateWhiteList(app) {
    exist := 0

    for v in StrSplit(readIniSection("App-ShowSymbol"), "`n") {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 3)
        try {
            if (part[1] == app) {
                isGlobal := part[2]
                if (isGlobal) {
                    exist := 1
                    return
                } else {
                    continue
                }
            }
        }
    }
    if (!exist) {
        id := returnId()
        writeIni(id, app ":1", "App-ShowSymbol")

        global app_ShowSymbol := StrSplit(readIniSection("App-ShowSymbol"), "`n")
    }
}

updateAppOffset() {
    global app_offset := {}
    global app_offset_screen := {}
    global AppOffsetScreen := StrSplit(readIniSection("App-Offset-Screen"), "`n")
    global AppOffset := StrSplit(readIniSection("App-Offset"), "`n")

    restartJAB()

    for v in AppOffset {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 5)
        if (part.Length >= 2) {
            name := part[1]
            isGlobal := part[2]
            isRegex := ""
            title := ""
            offset := ""
            if (part.Length == 5) {
                isRegex := part[3]
                offset := part[4]
                title := part[5]
            }

            tipGlobal := isGlobal ? "进程级" : "标题级"
            tipRegex := isRegex ? "正则" : "相等"
            key := isGlobal ? name : name title
            app_offset.%key% := {}

            for v in StrSplit(offset, "|") {
                if (v) {
                    p := StrSplit(v, "/")
                    try {
                        app_offset.%key%.%p[1]% := { x: p[2], y: p[3] }
                    } catch {
                        app_offset.%key%.%p[1]% := { x: 0, y: 0 }
                    }
                }

            }
        }
    }
    for v in AppOffsetScreen {
        kv := StrSplit(v, "=")
        part := StrSplit(kv[2], "/")
        app_offset_screen.%kv[1]% := { x: part[1], y: part[2] }
    }
}
updateCursorMode() {
    global modeList
    restartJAB()

    modeList := {
        HOOK: ":" arrJoin(defaultModeList.HOOK, ":") ":",
        UIA: ":" arrJoin(defaultModeList.UIA, ":") ":",
        GUI_UIA: ":" arrJoin(defaultModeList.Gui_UIA, ":") ":",
        MSAA: ":" arrJoin(defaultModeList.MSAA, ":") ":",
        HOOK_DLL: ":" arrJoin(defaultModeList.HOOK_DLL, ":") ":",
        WPF: ":" arrJoin(defaultModeList.WPF, ":") ":",
        ACC: ":" arrJoin(defaultModeList.ACC, ":") ":",
        JAB: ":" arrJoin(defaultModeList.JAB, ":") ":"
    }

    InputCursorMode := StrSplit(readIniSection("InputCursorMode"), "`n")

    for v in InputCursorMode {
        kv := StrSplit(v, "=", , 2)
        part := StrSplit(kv[2], ":", , 2)

        try {
            name := part[1]
            for value in modeNameList {
                if (InStr(modeList.%value%, ":" name ":")) {
                    modeList.%value% := StrReplace(modeList.%value%, ":" name ":", ":")
                }
            }
            modeList.%part[2]% .= name ":"
        }
    }
}

; 重启 JAB 程序
restartJAB() {
    static done := 1

    if isJAB
        return

    if (done && enableJABSupport) {
        SetTimer(restartAppTimer, -1)
        restartAppTimer() {
            done := 0
            killJAB(1)
            if (A_IsAdmin) {
                try {
                    Run('schtasks /run /tn "abgox.InputTip.JAB.JetBrains"', , "Hide")
                }
            } else {
                global JAB_PID
                Run('"' A_AhkPath '" "' A_ScriptDir '\InputTip.JAB.JetBrains.ahk"', , "Hide", &JAB_PID)
            }
            done := 1
        }
    }
}

/**
 * 停止 JAB 进程
 * @param {1 | 0} wait 等待停止进程
 * @param {1 | 0} delete 停止进程后，是否需要删除相关任务计划程序
 */
killJAB(wait := 1, delete := 0) {
    if (A_IsAdmin) {
        cmd := 'schtasks /End /tn "abgox.InputTip.JAB.JetBrains"'
        try {
            wait ? RunWait(cmd, , "Hide") : Run(cmd, , "Hide")
        }
        if (delete) {
            try {
                Run('schtasks /delete /tn "abgox.InputTip.JAB.JetBrains" /f', , "Hide")
            }
        }
    } else {
        ProcessClose(JAB_PID)
    }
}


/**
 * 创建/更新任务计划程序
 * @param {String} path 要执行的应用程序
 * @param {String} taskName 任务计划名称
 * @param {Array} args 运行参数
 * @param {Highest | Limited} runLevel 运行级别
 * @param {1 | 0} isWait 是否等待完成
 * @param {1 | 0} needStartUp 是否需要开机启动
 * @returns {1 | 0} 是否创建成功
 */
createScheduleTask(path, taskName, args := [], runLevel := "Highest", isWait := 0, needStartUp := 0, *) {
    if (A_IsAdmin) {
        cmd := '-NoProfile -Command $action = New-ScheduledTaskAction -Execute "`'\"' path '\"`'" '
        if (args.Length) {
            cmd .= '-Argument ' "'"
            for v in args {
                cmd .= '\"' v '\" '
            }
            cmd .= "'"
        }
        cmd .= ';$principal = New-ScheduledTaskPrincipal -UserId "' userName '" -RunLevel ' runLevel ';$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -ExecutionTimeLimit 10 -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1);'
        if (needStartUp) {
            cmd .= '$trigger = New-ScheduledTaskTrigger -AtLogOn;$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings -Trigger $trigger;'
        } else {
            cmd .= '$task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings;'
        }
        cmd .= 'Register-ScheduledTask -TaskName ' taskName ' -InputObject $task -Force;'
        try {
            isWait ? RunWait('powershell ' cmd, , "Hide") : Run('powershell ' cmd, , "Hide")
            return 1
        } catch {
            try {
                isWait ? RunWait('pwsh ' cmd, , "Hide") : Run('pwsh ' cmd, , "Hide")
                return 1
            } catch {
                return 0
            }
        }
    }
    return 0
}
