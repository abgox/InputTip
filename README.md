<p align="center">
  <h1 align="center">✨<a href="https://inputtip.pages.dev/">InputTip</a>✨</h1>
</p>

<p align="center">
    <a href="https://github.com/abgox/InputTip">Github</a> |
    <a href="https://gitee.com/abgox/InputTip">Gitee</a>
</p>

<p align="center">
    <a href="https://github.com/abgox/InputTip/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/abgox/InputTip" alt="license" />
    </a>
    <a href="https://inputtip.pages.dev/releases/v2/version.json">
        <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Finputtip.pages.dev%2Freleases%2Fv2%2Fversion.json&query=%24.version&prefix=v&label=version" alt="version" />
    </a>
    <a href="https://img.shields.io/github/languages/code-size/abgox/InputTip.svg">
        <img src="https://img.shields.io/github/languages/code-size/abgox/InputTip.svg" alt="code size" />
    </a>
    <a href="https://img.shields.io/github/repo-size/abgox/InputTip.svg">
        <img src="https://img.shields.io/github/repo-size/abgox/InputTip.svg" alt="repo size" />
    </a>
    <a href="https://github.com/abgox/InputTip">
        <img src="https://img.shields.io/badge/created-2023--5--12-blue" alt="created" />
    </a>
</p>

---

> [!NOTE]
>
> `托盘菜单` 指的是在电脑底部的任务栏右侧的 `InputTip` 软件托盘菜单

### 介绍

- 基于 `AutoHotKey` 编写
- 一个实时的输入法状态(中文/英文/大写锁定)提示工具

  - 根据输入法状态改变鼠标样式
    - [样式可以自定义](#自定义鼠标样式)
    - 默认使用 [多彩水滴 Oreo 光标](https://zhutix.com/ico/oreo-cu)，默认中文状态为红色，英文状态为蓝色，大写锁定为绿色
  - 根据输入法状态在输入光标附近显示不同的 [符号](#关于符号)
  - 根据不同应用自动切换不同的输入法状态(英文/中文/大写锁定)
  - 快捷键强制切换输入法状态

- [版本更新日志](https://inputtip.pages.dev/v2/changelog)
  - 如果你的网络环境无法访问它，请查看 [项目仓库中的版本更新日志](./src/v2/CHANGELOG.md)
- [一些常见的使用问题(FAQ)，如果有使用问题，你应该先查看它](https://inputtip.pages.dev/FAQ/)

> - [点击这里查看 v1 老版本](./src/v1/README.md) (此版本已经没啥用了，不再更新)

### 演示

![demo](https://inputtip.pages.dev/releases/v2/demo.gif)

---

<details>
<summary>点击查看一个使用方块符号的有趣配置</summary>
<img style="width: 70%;" src="https://inputtip.pages.dev/releases/v2/config-demo.png" />
<img style="width: 70%;" src="https://inputtip.pages.dev/releases/v2/config-demo.gif" />
</details>

### 使用

- [下载](https://inputtip.pages.dev/releases/v2/InputTip.exe) 并运行 `InputTip.exe` 即可

  - 如果此下载链接无法打开，你也可以在项目的 Releases 页面下载
  - 推荐做法: 新建一个目录，将 `InputTip.exe` 放入其中，然后再运行它
    - 因为运行 `InputTip.exe` 后，会产生以下文件或文件夹
      - `InputTipCursor` 鼠标样式文件夹
      - `InputTipSymbol` 图片符号文件夹
      - `InputTip.ini` 配置文件
      - `InputTip.lnk` 快捷方式
        - 运行此快捷方式不会弹出 `UAC` 权限提示窗口
    - 这样做的话，所有相关的文件或文件夹都在同一个目录中，方便管理

- 关于 `UAC` 权限提示窗口

  - 由于 `InputTip.exe` 需要管理员权限才能正常运行，所以会弹出 `UAC` 权限提示窗口
  - 如果你希望不弹出此窗口，请运行由 `InputTip.exe` 生成的 `InputTip.lnk` 快捷方式

- 设置开机自启动: 点击 `托盘菜单` => `开机自启动`

- 设置鼠标样式

  1. 点击 `托盘菜单` => `设置鼠标样式`
  2. 选择包含 `.cur` 或 `.ani` 文件的文件夹
     - 比如默认的中文鼠标样式文件夹: `InputTipCursor\default\CN`
     - 直接选择 `InputTipCursor\default` 目录下的 `CN`/`EN`/`Caps` 文件夹即可快速重置为默认的中文/英文/大写锁定状态时的鼠标样式
  3. 点击 `托盘菜单` => `重启`

  - [点击下载一些可以直接使用的鼠标样式](https://inputtip.pages.dev/releases/v2/cursorStyle.zip)
    - 这是一个压缩包，需要将其解压，放入 `InputTipCursor` 目录下，然后进行上述步骤即可

### 卸载

- 所有相关的文件或目录

  - 软件本体 `InputTip.exe`
  - 鼠标样式文件夹 `InputTipCursor` (软件本体的同级目录下)
  - 图片符号文件夹 `InputTipSymbol` (软件本体的同级目录下)
  - 配置文件 `InputTip.ini` (软件本体的同级目录下)
  - 快捷方式 `InputTip.lnk` (软件本体的同级目录下)

---

1. 取消 `开机自启动`: 点击 `托盘菜单` => `设置` => `开机自启动`
2. 退出 `InputTip.exe`
   - 如果修改了鼠标样式，退出软件时，会尝试进行恢复，但可能无法完全恢复，如果想完全恢复到以前的鼠标样式，需要重启电脑
3. 删除以上所有文件或目录
4. 打开 `任务计划程序`，找到 `abgox.InputTip.noUAC` 和 `abgox.InputTip.JAB.JetBrains` 任务，删除它
   - 其实不删除也没事，它不会造成任何影响，不过既然不再使用 `InputTip`，还是删除为好

### 如何在 JetBrains 系列 IDE 中使用 InputTip

> [通过 AutoHotkey 官方论坛中 Descolada 大佬给出的解决方案实现](https://www.autohotkey.com/boards/viewtopic.php?t=130941#p576439)

1. 打开 Java Access Bridge (java 访问桥)

   - 如果命令不存在，请 [下载并安装 OpenJDK JRE](https://adoptium.net/temurin/releases/?os=windows&arch=x64&package=jre&version=8)

   ```cmd
     jabswitch -enable
   ```

2. 点击 `托盘菜单` => `启用 JetBrains IDE 支持`
   - 会在 `InputTip.exe` 同级目录下生成 `InputTip.JAB.JetBrains.exe`
   - 它由 `InputTip.exe` 控制，不需要手动启动/终止
3. 点击 `托盘菜单` => `添加 JetBrains IDE 应用`，确保你使用的 JetBrains IDE 应用已经添加
4. 重启 `InputTip.exe`

> [!TIP]
> 如果你有多块屏幕，在副屏上，会有非常大的坐标偏差
>
> 你需要通过 `托盘菜单` => `设置特殊偏移量` => `设置 JetBrains 系列 IDE 的副屏偏移量` 手动调整

### 关于符号

#### 图片符号

- `InputTip.exe` 启动后，会在同级目录下生成 `InputTipSymbol` 目录，其中包括 `CN.png`、`EN.png`、`Caps.png` 三个图片文件以及 `default` 文件夹

  - `CN.png`、`EN.png`、`Caps.png`
    - 这三个图片文件分别对应中文/英文/大写锁定状态的图片符号
    - 你可以随意替换它们
      - 你可以替换为自己喜欢的图片符号，或者自己制作一个图片符号
      - 限制: 必须是 `.png` 格式
  - `default` 文件夹中包含了默认的图片符号

- 当 `托盘菜单` 中 `更改配置` => `显示形式` => `是否显示图片符号` 设置为 `1` 时，会在输入光标附近显示对应的图片符号
- 图片符号相关的配置: `托盘菜单` => `更改配置` => `图片符号`
- 当图片文件被删除时，则不会显示对应状态的图片符号
  - 比如: 你只希望在中文状态下显示图片符号，那么就删除 `EN.png`、`Caps.png` 这两个文件
- 如果你自己删除或替换后，想换回默认的图片符号，就将 `default` 文件夹中对应的图片文件复制到 `InputTipSymbol` 目录下
- 或者你可以直接删除 `InputTipSymbol` 目录然后重启 `InputTip.exe`，它会重新创建

#### 方块符号

- 当 `托盘菜单` 中 `更改配置` => `显示形式` => `是否显示图片符号` 设置为 `1` 时，同时 `是否显示图片符号` 和 `是否显示文本符号` 都为 `0` 时，会在输入光标附近显示不同颜色的方块符号
- 默认中文状态为红色，英文状态为蓝色，大写锁定为绿色
- 方块符号相关的配置: `托盘菜单` => `更改配置` => `方块符号`
- 当其中的方块符号的颜色设置修改为空时，则不会显示该状态的方块符号
  - 比如: 你只希望在中文状态下显示方块符号，那么就将 `英文状态时方块符号的颜色` 和 `大写锁定时方块符号的颜色` 的值都设置为空

#### 文本符号

- 当 `托盘菜单` 中 `更改配置` => `显示形式` => `是否显示文本符号` 设置为 `1` 时，同时 `是否显示方块符号` 为 `1`、`是否显示图片符号` 为 `0` 时，会在输入光标附近显示对应的文本符号
- 默认中文状态为 `中`，英文状态为 `英`，大写锁定为 `大`
- 文本符号相关的配置: `托盘菜单` => `更改配置` => `文本符号`
- 当其中的文本字符设置修改为空时，则不会显示该状态的文本符号
  - 比如: 你只希望在中文状态下显示文本字符，那么就将 `英文状态时显示的文本字符` 和 `大写锁定时显示的文本字符` 的值都设置为空

### 自定义鼠标样式

- `InputTip.exe` 启动后，会在同级目录下生成 `InputTipCursor` 目录，其中包括 `CN`、`EN`、`Caps`、`default` 四个文件夹
  - **这六个文件夹都不能手动修改**
  - `CN`、`EN`、`Caps` 用于实时加载中文/英文/大写锁定状态的鼠标样式
    - 当设置鼠标样式时，会相对应的复制到 `CN`、`EN`、`Caps` 文件夹中
      - 如何设置鼠标样式: `托盘菜单` => `更改配置` => `鼠标样式` => `设置中文状态鼠标样式`/`设置英文状态鼠标样式`/`设置大写锁定鼠标样式`
  - `default` 用于存放中文/英文/大写锁定状态的 **默认** 鼠标样式

1. 你需要在 `InputTipCursor` 目录下创建一个文件夹

   - 文件夹中只能包含鼠标样式文件(后缀名为 `.cur` 或 `.ani`)
   - 必须使用以下表格中的文件名(大小写都可以)
   - 每个文件都不是必须的，但建议至少添加 `Arrow`，`IBeam`，`Hand`

     - 你需要保证 `InputTipCursor` 目录中的 `CN`/`EN`/`Caps`文件夹中包含的鼠标样式文件的数量和类型是一致的
     - 比如：如果 `CN` 文件夹有 `IBeam.cur` 或 `IBeam.ani` 文件，`EN`/`Caps` 没有。则 `IBeam` 类型的鼠标样式将在中文状态下生效，之后由于 `EN`/`Caps` 缺少对应的样式文件，将不会再随输入法状态的切换而变化

     | 文件名(类型) |              说明               |
     | :----------: | :-----------------------------: |
     |    Arrow     |            普通选择             |
     |    IBeam     |        文本选择/文本输入        |
     |     Hand     |            链接选择             |
     | AppStarting  |            后台工作             |
     |     Wait     |              忙碌               |
     |   SizeAll    |              移动               |
     |   SizeNWSE   | 对角线调整大小 1 (左上 => 右下) |
     |   SizeNESW   | 对角线调整大小 2 (左下 => 右上) |
     |    SizeWE    |          水平调整大小           |
     |    SizeNS    |          垂直调整大小           |
     |      No      |           无法(禁用)            |
     |     Help     |            帮助选择             |
     |    Cross     |            精度选择             |
     |   UpArrow    |            备用选择             |
     |     Pin      |            位置选择             |
     |    Person    |            人员选择             |
     |     Pen      |              手写               |

   - 详情参考 [关于光标(游标)](https://learn.microsoft.com/windows/win32/menurc/about-cursors)

2. 在底部任务栏右侧找到此软件托盘图标，点击 `更改配置` => `鼠标样式` => `设置中文状态鼠标样式`/`设置英文状态鼠标样式`/`设置大写锁定鼠标样式`
3. 选择创建好的文件夹
   - 选择的文件夹中的鼠标样式文件会被复制到对应的 `CN`/`EN`/`Caps` 文件夹中，用于加载

### 兼容情况

> [!NOTE]
>
> 这里的兼容情况也仅供参考，实际情况可能与此不同，你应该自行尝试
>
> 建议尝试的顺序是 `模式2` > `模式1` > `模式3` > `模式4`

- 已知可用的输入法(通过模式切换兼容)

  - `模式1`:
    - **微信**输入法
    - **搜狗**(五笔)输入法
    - **QQ**输入法
    - **微软**拼音
    - **冰凌**(五笔)输入法
    - **小鹤音形**输入法(使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成)
      - 使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成的输入法都可用
  - `模式2`(默认):

    - **微信**输入法
    - **搜狗**(五笔)输入法
    - **QQ**输入法
    - **微软**(拼音/五笔)
    - **冰凌**(五笔)输入法
    - **小狼毫(rime)** 输入法
    - **小鹤音形**输入法(使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成)
      - 使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成的输入法都可用
    - **百度**输入法
    - **谷歌**输入法
    - **微软仓颉**输入法
    - **小小**输入法

  - `模式3`
    - **讯飞**输入法
  - `模式4`
    - **手心**输入法

- 如何进行模式切换
  1.  运行 `InputTip.exe` 后，在底部任务栏右侧找到软件托盘图标
  2.  `鼠标右击` 软件托盘图标
  3.  点击 `设置输入法模式`
  4.  从这几个模式中选择一个可用的模式

### 参考项目

- [ImTip - aardio](https://github.com/aardio/ImTip)
- [KBLAutoSwitch - flyinclouds](https://github.com/flyinclouds/KBLAutoSwitch)
- [AutoHotkeyScripts - Tebayaki](https://github.com/Tebayaki/AutoHotkeyScripts)
- [language-indicator - yakunins](https://github.com/yakunins/language-indicator)
- [RedDot - Autumn-one(木瓜太香)](https://github.com/Autumn-one/RedDot)
  - `InputTip` 最初([InputTip v1](./src/v1/README.md))在鼠标附近显示符号，后来 [InputTip v2](./) 版本通过不同的鼠标样式来区分
  - 而之后在输入光标处显示色块，通过颜色区分的思路设计来自于 [RedDot - Autumn-one(木瓜太香)](https://github.com/Autumn-one/RedDot)

### 赞赏支持

![赞赏支持](https://abgox.pages.dev/support.png)
