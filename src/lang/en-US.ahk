; InputTip

langStrings.Set('en-US', Map(
    'yes', 'Yes',
    'no', 'No',
    'close', 'Close',
    'i_see', 'I see',
    'app_desc', 'Input Method Status Manager',
    'app_sub_desc', 'Real-time indicator (Cursor/Symbol) + Status switch (Window/Hotkey triggered)',
    ; state
    'state.CN', 'Chinese Status',
    'state.EN', 'English Status',
    'state.Caps', 'CapsLock Status',
    'state.Run', 'Run',
    'state.Pause', 'Pause',
    'state.Exit', 'Exit',
    'state.Running', 'Running',
    'state.Paused', 'Paused',
    ; init_guide
    'init_guide.title', 'Initialization Guide',
    'init_guide.cursor', [
        'Do you want InputTip to use【Cursor Scheme】?',
        'InputTip will use three different cursor styles.`nIt will load the corresponding cursor style based on IME status.',
        'Learn more:  <a href="https://inputtip.abgox.com/v2/#鼠标方案">Website</a>   <a href="https://github.com/abgox/InputTip#鼠标方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#鼠标方案">Gitee</a>',
    ],
    'init_guide.symbol', [
        'Do you want InputTip to use【Symbol Scheme】?',
        'InputTip will try to get the cursor position and display symbols near it.',
        'Learn more:  <a href="https://inputtip.abgox.com/v2/#符号方案">Website</a>   <a href="https://github.com/abgox/InputTip#符号方案">Github</a>   <a href="https://gitee.com/abgox/InputTip#符号方案">Gitee</a>',
    ],
    'init_guide.whitelist', [
        'For【Symbol Scheme】, InputTip uses a force whitelist mechanism.`nOnly apps in the【Symbol Whitelist】will try to display symbols.',
        'Learn more: <a href="https://inputtip.abgox.com/faq/symbol-list-mechanism">关于符号方案中的名单机制</a>',
        'Add commonly used apps to the【Symbol Whitelist】now!',
    ],
    'init_guide.add_now', '【Yes】Add Now',
    'init_guide.add_later', '【No】Add Later',
    ; tray
    'tray.tip_template', '【%appState%】InputTip - Input Method Status Manager',
    'tray.keyCount_template', '%\n%【Counting】Key inputs since startup: %keyCount%',
    ; gui
    'gui.help_tip', 'Click on [About] at the top or related documents to view the usage for this menu.',
    ; other_config
    'other_config.language', 'Language / 语言',
    'other_config.lang_settings', 'Language Settings',
    'other_config.lang_changed', 'Language changed, it will take effect after restart.`nWhen closing this window, InputTip will automatically restart.',
))
