# 配置文件说明 v2

- 配置信息存储在同级目录的 `InputTip.ini` 文件中，启动软件时自动创建
  - 如果 v1 v2 版本都使用过，不用担心，它们的配置信息是独立的，不会冲突
- 修改方式:
  - (**推荐方式**)鼠标右键点击任务栏右侧的 `InputTip.exe` 托盘图标，点击 `更改配置`(或其他设置)。
  - (**非常不推荐**)直接打开 `InputTip.ini` 文件，修改对应项的值，保存后重启 `InputTip.exe`。

---

## 是否更改鼠标样式

- 在 `InputTip.ini` 的键名: `changeCursor`
- 默认值: `1`
- 可选值: `0` 或 `1`
- 当输入法状态改变时(中英文/大写锁定)，是否改变鼠标指针样式。
- 注意:
  - 当设置为`0`后，`InputTip.exe` 会尝试恢复到原来的鼠标指针样式，但不一定全部成功。
  - 如果有部分鼠标样式没有恢复，那就需要重启电脑。

## 是否显示文本符号

- 在 `InputTip.ini` 的键名: `showChar`
- 默认值: `0`
- 可选值: `0` 或 `1`
- 在方块符号中显示不同状态下的对应文本符号
- 这个配置项需要确保 `是否显示方块符号` 也为 `1`，如果 `是否显示方块符号` 为 `0`，则此配置项无效。

## 是否显示方块符号

- 在 `InputTip.ini` 的键名: `showSymbol`
- 默认值: `1`
- 可选值: `0` 或 `1`
- 当输入法状态改变时(中英文/大写锁定)，是否在输入光标附近显示一个方块符号。

### 中文状态时方块符号的颜色

- 在 `InputTip.ini` 的键名: `CN_color`
- 默认值: `red`
- 可以是常见的颜色英文单词，也可以是十六进制颜色值(带不带 `#` 都可以)。

### 英文状态时方块符号的颜色

- 在 `InputTip.ini` 的键名: `EN_color`
- 默认值: `blue`
- 可以是常见的颜色英文单词，也可以是十六进制颜色值(带不带 `#` 都可以)。

### 大写锁定时方块符号的颜色

- 在 `InputTip.ini` 的键名: `Caps_color`
- 默认值: `green`
- 可以是常见的颜色英文单词，也可以是十六进制颜色值(带不带 `#` 都可以)。

### 方块符号的透明度

- 在 `InputTip.ini` 的键名: `transparent`
- 默认值: `222`
- 取值范围: `0`~`255`

### 方块符号的水平偏移量

- 在 `InputTip.ini` 的键名: `offset_x`
- 默认值: `5`

### 方块符号的垂直偏移量

- 在 `InputTip.ini` 的键名: `offset_y`
- 默认值: `0`

### 方块符号的高度

- 在 `InputTip.ini` 的键名: `symbol_height`
- 默认值: `7`

### 方块符号的宽度

- 在 `InputTip.ini` 的键名: `symbol_width`
- 默认值: `7`

### 方块符号在多少毫秒后隐藏

- 在 `InputTip.ini` 的键名: `HideSymbolDelay`
- 默认值: `0`，表示不隐藏，实时显示
- 当值不为 `0`，则此值被认为是指定的毫秒时间，在这个时间后，方块符号将会隐藏
- 方块符号隐藏后，在当前软件窗口的任何鼠标操作都不会再显示方块符号，直到下一次键盘按键操作或者切换到其他软件窗口才会重新显示

### 其他配置

- 以下配置不应该手动更改，而是从托盘图标菜单中进行设置，由 `InputTip.exe` 内部更改

  - `mode`
    - 鼠标右键点击托盘图标 -> `设置模式` -> `模式1`,`模式2`,...
  - `app_hide_CN_EN`、`app_hide_state`
    - 鼠标右键点击托盘图标 -> `设置特殊软件` -> `隐藏中英文状态方块符号提示`,`隐藏输入法状态方块符号提示`
  - `app_CN`、`app_EN`、`app_Caps`
    - 鼠标右键点击托盘图标 -> `设置自动切换` -> `自动切换到中文状态`,`自动切换到英文状态`,`自动切换到大写锁定状态`
  - `hotkey_CN`、`hotkey_EN`、`hotkey_Caps`
    - 鼠标右键点击托盘图标 -> `设置强制切换快捷键`
  - `border_type`: 边框类型，默认值为 `1`
  - 自定义边框相关的配置

    - `border_margin_left`
    - `border_margin_right`
    - `border_margin_top`
    - `border_margin_bottom`
    - `border_color_CN`
    - `border_color_EN`
    - `border_color_Caps`
    - `border_transparent`

  - 特殊偏移量相关的配置
    - `offset_x_1`
    - `offset_y_1`
    - `offset_x_2`
    - `offset_y_2`
    - ...
  - 显示文本符号相关的配置
    - `font_family`
    - `font_size`
    - `font_weight`
    - `font_color`
    - `CN_Text`
    - `EN_Text`
    - `Caps_Text`
