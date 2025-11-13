# CLAUDE.md - AI Assistant Guide for InputTip

## Project Overview

**InputTip** is a Windows input method status management tool written in AutoHotkey v2. It provides real-time visual indicators (mouse cursor schemes and symbol schemes) and automatic status switching based on window context or hotkeys.

### Key Features
- **Input method status indication**
  - Mouse cursor scheme: Different cursor styles for different input states
  - Symbol scheme: Display symbols near the input cursor or mouse
- **Automatic status switching** when changing windows
- **Hotkey-based status switching**
- **Extensive configuration** through tray menu
- **Plugin system** for custom functionality

### Project Links
- Website: https://inputtip.abgox.com
- GitHub: https://github.com/abgox/InputTip
- Gitee: https://gitee.com/abgox/InputTip
- Bilibili Video: https://www.bilibili.com/video/BV15oYKz5EQ8

## Technology Stack

- **Primary Language**: AutoHotkey v2 (AHK v2)
- **Platform**: Windows 10+ (Win10 and above)
- **Runtime**: Includes bundled AutoHotkey64.exe in `src/AutoHotkey/`
- **Distribution**: Two versions
  - **zip version** (recommended): Source code with batch launcher
  - **exe version**: Compiled single executable

## Repository Structure

```
InputTip/
├── .github/
│   └── workflows/
│       └── publish-to-winget.yml    # Automated WinGet package publishing
├── .vscode/                          # VSCode configuration
├── scripts/
│   ├── create-winget-manifest.ps1   # WinGet manifest generator
│   └── handle-cursor-style.ps1      # Cursor style processing
├── src/                              # Main source directory
│   ├── AutoHotkey/
│   │   └── AutoHotkey64.exe         # Bundled AHK v2 runtime
│   ├── menu/                         # Menu configuration modules
│   │   ├── about.ahk
│   │   ├── app-offset.ahk
│   │   ├── bw-list.ahk              # Black/white list management
│   │   ├── check-update.ahk
│   │   ├── cursor-mode.ahk
│   │   ├── input-method.ahk
│   │   ├── other-config.ahk
│   │   ├── scheme-cursor.ahk
│   │   ├── scheme-symbol.ahk
│   │   ├── startup.ahk
│   │   ├── switch-window.ahk
│   │   └── symbol-pos.ahk
│   ├── utils/                        # Utility functions
│   │   ├── app-list.ahk
│   │   ├── check-version.ahk
│   │   ├── create-gui.ahk
│   │   ├── hotkey-gui.ahk
│   │   ├── IME.ahk                  # Input method engine
│   │   ├── ini.ahk                  # INI file operations
│   │   ├── show.ahk
│   │   ├── tools.ahk
│   │   ├── var.ahk                  # Global variables
│   │   └── verify-file.ahk
│   ├── plugins/
│   │   └── InputTip.plugin.ahk      # User custom plugin entry
│   ├── InputTipCursor/               # Cursor style assets
│   │   └── default/
│   │       ├── oreo-red/            # Chinese state cursors
│   │       ├── oreo-blue/           # English state cursors
│   │       └── oreo-green/          # Caps lock state cursors
│   ├── InputTipSymbol/               # Symbol assets
│   │   └── default/
│   │       ├── triangle-red.png     # Chinese state symbol
│   │       ├── triangle-blue.png    # English state symbol
│   │       └── triangle-green.png   # Caps lock state symbol
│   ├── InputTipIcon/                 # Application icons
│   │   └── default/
│   ├── InputTip.ahk                  # Main entry point
│   ├── InputTip.JAB.JetBrains.ahk   # JetBrains IDE support via JAB
│   ├── CHANGELOG.md                  # Detailed version history
│   ├── files.ini                     # File URL mapping for updates
│   ├── version.txt                   # Current version (exe)
│   └── version-zip.txt               # Current version (zip)
├── InputTip.bat                      # Launcher for zip version
├── LICENSE                           # MIT License
├── README.md                         # Main documentation (Chinese)
└── .gitignore
```

## Key Files and Their Roles

### Entry Points
- **`InputTip.bat`**: Launches AutoHotkey runtime with the main script
  ```batch
  start "InputTip" /min "%~dp0\src\AutoHotkey\AutoHotkey64.exe" "%~dp0\src\InputTip.ahk"
  ```
- **`src/InputTip.ahk`**: Main application entry point
  - Initializes global variables
  - Loads all modules via `#Include` directives
  - Sets up hotkeys and timers
  - Manages application lifecycle

### Core Modules
- **`src/utils/var.ahk`**: Global variable definitions
  - Configuration settings
  - Application state
  - GUI references
- **`src/utils/IME.ahk`**: Input method engine interactions
  - Status detection
  - Status switching logic
- **`src/utils/tools.ahk`**: Utility functions
  - Common operations
  - Helper functions
- **`src/utils/create-gui.ahk`**: GUI creation utilities
  - Configuration dialogs
  - Status indicators

### Menu System
All files in `src/menu/` correspond to different configuration sections:
- **`tray-menu.ahk`**: Main tray menu structure
- **`scheme-cursor.ahk`**: Mouse cursor scheme configuration
- **`scheme-symbol.ahk`**: Symbol scheme configuration
- **`input-method.ahk`**: Input method mode selection
- **`bw-list.ahk`**: Black/white list for symbol display
- **`switch-window.ahk`**: Per-window automatic switching rules

### Configuration
- **`src/InputTip.ini`**: User configuration file (created at runtime)
  - NOT tracked in git
  - Contains all user settings
  - Managed through tray menu only

### Version Management
- **`src/version.txt`**: Version number for exe distribution
- **`src/version-zip.txt`**: Version number for zip distribution
- **`src/CHANGELOG.md`**: Detailed changelog in Chinese

## Code Conventions

### AutoHotkey v2 Specifics
1. **Include Guards**: Use `#Include "*i"` for optional includes
   ```ahk
   #Include "*i utils/options.ahk"
   ```

2. **Variable Naming**:
   - `camelCase` for local variables: `userName`, `keyCount`
   - `PascalCase` for functions: `ReadIni()`, `CreateGui()`
   - Global variables declared in `var.ahk`

3. **Configuration Management**:
   - Use `readIni()` and `writeIni()` functions exclusively
   - Never manually edit INI files in code
   - All configs stored in sections: `[InputMethod]`, `[UserInfo]`, etc.

4. **GUI Management**:
   - Store GUI references in `gc.w` object to prevent duplicates
   - Use `createTipGui()` for notification dialogs
   - Configuration windows created via `createGui()` with options array

5. **Hotkey Registration**:
   - Check if hotkey is defined before registering
   - Use try-catch for hotkey registration
   ```ahk
   if (hotkey_CN) {
       try {
           Hotkey(hotkey_CN, switch_CN)
       }
   }
   ```

### File Organization
- **One responsibility per file**: Each menu file handles one configuration area
- **Utilities are modular**: Small, focused utility functions
- **No circular dependencies**: Use `var.ahk` for shared state

### Comments
- File headers: `;` followed by project name
- Section comments for major blocks
- Inline comments for complex logic
- Chinese comments are prevalent (project is Chinese-focused)

## Development Workflows

### Local Development (zip version)
1. Modify source files in `src/`
2. Run `InputTip.bat` to test changes
3. Configuration persists in `src/InputTip.ini`

### Testing Different Scenarios
1. **Input Method Compatibility**: Test with various IMEs
   - WeChat IME, Sogou, QQ, Baidu, Microsoft Pinyin, etc.
   - Custom mode requires rule configuration
2. **Application Compatibility**: Test symbol positioning
   - Some apps require JAB support (JetBrains IDEs)
   - Some apps don't support cursor position retrieval
3. **Multi-monitor**: Test offset handling on secondary displays

### Debugging
- **Show status codes**: Use hotkey to display IME status codes
- **Cursor position**: Use offset preview to debug positioning
- **JAB support**: Requires `jabswitch -enable` for JetBrains IDEs

## Build and Release Process

### Version Update
1. Update version in:
   - `src/version.txt` (for exe version)
   - `src/version-zip.txt` (for zip version)
2. Update `src/CHANGELOG.md` with changes

### Release Types
- **Manual Release**: Create GitHub release with assets
  - `InputTip.exe` (compiled version)
  - `InputTip.zip` (source code zip)
- **Automated Workflow**: `.github/workflows/publish-to-winget.yml`
  - Triggers on release publication
  - Creates PR to WinGet repository
  - Uses `scripts/create-winget-manifest.ps1`

### Compilation (exe version)
- Use AHK2Exe compiler with directives in `InputTip.ahk`:
  ```ahk
  ;@AHK2Exe-SetName InputTip
  ;@Ahk2Exe-SetOrigFilename InputTip.ahk
  ;@Ahk2Exe-UpdateManifest 1
  ;@AHK2Exe-SetDescription InputTip - 一个输入法状态管理工具(提示/切换)
  ```

### Distribution Channels
- **GitHub Releases**: Primary distribution
- **Gitee**: Mirror for Chinese users
- **Scoop**: `abgox/abyss` bucket
  - `abgox.InputTip-zip` (zip version)
  - `abgox.InputTip` (exe version)
- **WinGet**: `abgox.InputTip` (exe only)

## Update Mechanism

### File Synchronization (zip version)
- **URL mapping**: `src/files.ini` contains GitHub URLs for each file
- **Sync function**: Compares local vs remote versions
- **User-triggered**: Via tray menu "与源代码仓库同步"
- **Preserves user data**:
  - `InputTip.ini` not overwritten
  - `plugins/` directory not touched
  - Custom cursors/symbols preserved

### Version Check (exe version)
- **Periodic check**: Default 1440 minutes (24 hours)
- **Manual check**: Via tray menu
- **Silent update**: Optional automatic update

## Plugin System

### Plugin Architecture
- Entry point: `src/plugins/InputTip.plugin.ahk`
- User can add custom AHK code:
  - Custom hotkeys
  - Custom hotstrings
  - Additional functionality
- Multiple plugin files supported via `#Include`

### Plugin Guidelines
- **No dead loops**: Avoid infinite loops
- **Use global scope carefully**: Access to all InputTip globals
- **Testing**: Restart InputTip after plugin changes

### Plugin Persistence
- `plugins/` directory never overwritten during updates
- Scoop persist mechanism applies to plugins
- Safe for version control in user forks

## Common AI Assistant Tasks

### 1. Adding New Configuration Options
1. Define variable in `src/utils/var.ahk`
2. Add INI read/write in appropriate module
3. Create GUI controls in relevant menu file
4. Update CHANGELOG.md
5. Test configuration persistence

### 2. Fixing Input Method Compatibility
1. Check `src/utils/IME.ahk` for status detection logic
2. Test status codes with different IMEs
3. Update custom mode rules if needed
4. Document in README compatibility section

### 3. Improving Symbol Positioning
1. Check `src/utils/show.ahk` for display logic
2. Adjust offset calculations
3. Test with problematic applications
4. Update special offset handling if needed

### 4. Adding New Menu Items
1. Create or modify file in `src/menu/`
2. Register in `src/menu/tray-menu.ahk`
3. Follow existing GUI patterns from `create-gui.ahk`
4. Update files.ini if new file added

### 5. Translating Documentation
- Primary docs are in Chinese
- README.md is comprehensive but Chinese-only
- CHANGELOG.md tracks all changes (Chinese)
- Consider i18n if adding English support

## Important Considerations

### Security & False Positives
- AHK applications often flagged as malware/game cheats
- See: https://inputtip.abgox.com/faq/about-virus
- Recommend zip version to users to avoid AV issues

### Windows Compatibility
- **Minimum**: Windows 10 (below 10 unknown/untested)
- **Best**: Windows 10/11
- Relies on Windows IME APIs

### Input Method Limitations
- **Microsoft IME**: Status switching only works in input boxes
- **American Keyboard (ENG)**: Only English/Caps Lock states
- **Custom IMEs**: May require custom mode configuration
- **Rime, XunFei, XiaoHe**: Require specific rule sets

### Application Limitations
- **Cursor position**: Not all apps support cursor position retrieval
- **JetBrains IDEs**: Require JAB (Java Access Bridge) + special setup
- **VSCode**: Position issues reported in v1.100, fixed in v1.101
- **Fallback**: Use "show near mouse" for incompatible apps

## Git Workflow

### Branching
- **Main branch**: Production-ready code
- **Feature branches**: `claude/claude-md-*` pattern for AI work
- **Release tags**: Version tags like `v2025.10.09`

### Commit Messages
- Clear, descriptive commits
- Often in Chinese
- Reference issues when applicable: `([#234])`

### Pull Requests
- Automated WinGet PR creation on release
- Manual PRs for feature development

## Testing Strategy

### Manual Testing Required
- **No automated tests** in repository
- **Test scenarios**:
  1. Different input methods
  2. Different applications
  3. Multi-monitor setups
  4. Cursor/symbol positioning
  5. Hotkey functionality
  6. Configuration persistence
  7. Update mechanism

### Test Checklist
- [ ] Install and launch (both zip and exe versions)
- [ ] Configure mouse cursor scheme
- [ ] Configure symbol scheme
- [ ] Set up window-specific rules
- [ ] Test hotkey switching
- [ ] Verify settings persistence
- [ ] Test update check/sync
- [ ] Test plugin loading
- [ ] Multi-monitor offset testing (if applicable)

## Resources

### Official Documentation
- Main site: https://inputtip.abgox.com
- FAQ: https://inputtip.abgox.com/faq/
- Download: https://inputtip.abgox.com/download
- Extra cursors: https://inputtip.abgox.com/download/extra

### AutoHotkey Resources
- AHK v2 Docs: https://www.autohotkey.com/docs/v2/
- AHK v2 GitHub: https://github.com/AutoHotkey/AutoHotkey

### Related Projects
- ImTip (aardio): https://github.com/aardio/ImTip
- KBLAutoSwitch: https://github.com/flyinclouds/KBLAutoSwitch
- RedDot: https://github.com/Autumn-one/RedDot
- language-indicator: https://github.com/yakunins/language-indicator

## Contribution Guidelines

### For AI Assistants
1. **Preserve Chinese content**: This is a Chinese-focused project
2. **Follow AHK v2 conventions**: Use modern AHK v2 syntax
3. **Test thoroughly**: Manual testing required due to IME/app variations
4. **Update CHANGELOG**: Document all changes in Chinese
5. **Respect plugin isolation**: Don't modify core code when plugins suffice
6. **Configuration via INI**: Never hardcode settings
7. **GUI consistency**: Follow existing createGui patterns
8. **Avoid breaking changes**: Many users rely on existing behavior

### Code Quality
- **No dead code**: Remove commented-out code
- **Meaningful names**: Variable/function names should be descriptive
- **Error handling**: Use try-catch for operations that may fail
- **Resource cleanup**: Properly destroy GUIs when done

### Documentation
- Update README.md for user-facing changes
- Update CHANGELOG.md with version history
- Add code comments for complex logic
- Document compatibility issues in README

## Troubleshooting Common Issues

### Issue: Status detection not working
- Check input method compatibility
- Try custom mode with appropriate rules
- Verify timeout settings in configuration

### Issue: Symbol not displaying
- Check if app supports cursor position retrieval
- Try "show near mouse" mode
- Verify symbol files exist in InputTipSymbol/

### Issue: JetBrains IDE not working
- Ensure OpenJDK 21 installed
- Enable JAB: `jabswitch -enable`
- Set cursor mode to JAB for the IDE
- Restart IDE and InputTip

### Issue: Cursor not changing
- Verify cursor files exist in InputTipCursor/
- Check if cursor scheme is enabled
- Ensure cursor file formats are correct (.cur or .ani)

### Issue: Settings not persisting
- Check InputTip.ini exists and is writable
- Verify INI file not corrupted
- Ensure changes made via tray menu, not manual edit

## Version History Notes

### Recent Major Changes (2025)
- **2025.10.09**: Fixed special offset issues, improved preview
- **2025.10.01**: Reorganized icon structure, renamed default assets
- **2025.09.21**: Updated app icons, added user guide
- **2025.09.06**: Added pause functionality, improved IME mode UI
- **2025.09.03**: Exit restores cursor, added tray icon click-to-pause
- **2025.08.29**: Added symbol display modes
- **2025.08.22**: Reorganized tray menu structure

See `src/CHANGELOG.md` for complete history.

## Performance Considerations

- **Timers**: Use appropriate intervals to balance responsiveness and CPU
- **GUI lifecycle**: Destroy unused GUIs to free resources
- **File I/O**: Minimize INI read/writes, cache when possible
- **DLL calls**: Cursor position retrieval can be expensive in some apps

## Security Best Practices

- **No network calls** except for update checks to GitHub
- **No telemetry** or data collection
- **Local configuration only**: All data in INI file
- **Plugin sandboxing**: None - plugins have full access (document clearly)

---

**Last Updated**: 2025-11-13

**Maintainer**: abgox (abgohxf@outlook.com)

**License**: MIT License
