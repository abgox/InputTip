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
    <a href="https://github.com/abgox/InputTip">
        <img src="https://img.shields.io/github/v/release/abgox/InputTip?label=version" alt="version" />
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

> [!Tip]
>
> `托盘菜单` 指的是在底部任务栏右边的 `InputTip` 软件托盘菜单

### 介绍

> [!Tip]
>
> QQ 反馈交流群: [451860327](http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=ZfHFP_gIMyY6kZvqRmJhrsMlvnLDjLf6&authKey=lXo50SvLgudu%2BettInNZdb2OXGjs%2BxsoqsKIB88Vcq%2FjMb9uEW5thwU5Nm85KNX4&noverify=0&group_code=451860327)

- 使用 `AutoHotKey` 编写，仅 Windows 系统可用
- 一个实时的输入法状态(中文/英文/大写锁定)提示工具

  - 根据输入法状态改变鼠标样式
    - [样式可以自定义](#自定义鼠标样式)
    - 默认使用 [多彩水滴 Oreo 光标](https://zhutix.com/ico/oreo-cu)
      - 默认中文状态为 **红色**，英文状态为 **蓝色**，大写锁定为 **绿色**
      - 在 [更多已适配的鼠标样式](https://inputtip.pages.dev/download/extra) 中有提供它们的左手镜像版本
  - 根据输入法状态在输入光标附近显示不同的 [符号](#关于符号)
    - 默认使用 [白名单机制](https://inputtip.pages.dev/FAQ/white-list/)
  - 切换不同应用窗口时，自动切换指定的输入法状态(中文/英文/大写锁定)
  - 快捷键强制切换输入法状态
  - 详尽的自定义配置菜单
    - 所有配置的修改，都在 `托盘菜单` 中进行
    - 你可以设置字体大小来解决屏幕过小导致菜单显示不完全或屏幕过大导致菜单显示过小的问题
      - `更改配置` => `其他杂项` => `所有配置菜单的字体大小`

> - [查看 v1 老版本](./src/v1/README.md) (此版本已经没啥用了，不再更新)

[**如果 `InputTip` 对你有所帮助，请考虑给它一个 Star ⭐**](#stars)

### 新的变化

- 请查阅 [更新日志](./src/v2/CHANGELOG.md)

### 常见问题

- 如果有使用上的任何问题，请先确认当前使用的 `InputTip` 是最新版本 <img style="display:inline;vertical-align: text-bottom;" src="https://img.shields.io/github/v/release/abgox/InputTip?label=%20" alt="version">
  - 在 `托盘菜单` => `关于` 中查看当前版本号
- 然后查看相关的说明文档、[常见问题(FAQ)](https://inputtip.pages.dev/FAQ/)、[issues](https://github.com/abgox/InputTip/issues) 等等

### 演示

![demo](https://inputtip.pages.dev/releases/v2/demo.gif)

---

<details>
<summary>一个使用方块符号的有趣配置</summary>
<img style="width: 70%;" src="https://inputtip.pages.dev/releases/v2/config-demo.png" />
<img style="width: 70%;" src="https://inputtip.pages.dev/releases/v2/config-demo.gif" />
</details>

### 使用

> [!Tip]
>
> - 因为以下原因，可能无法正常运行 `InputTip.exe`
>   - 没有管理员权限
>   - 杀毒软件或防火墙阻止了 `InputTip.exe` 运行
>   - 特殊的系统环境
>   - ...
> - 你可以尝试以下方案:
>   1. 克隆项目仓库到本地
>      ```shell
>       git clone --depth 1 https://github.com/abgox/InputTip.git
>      ```
>   2. 安装 [AutoHotkey v2](https://www.autohotkey.com/)
>   3. 直接运行项目中的 `InputTip.ahk` 文件
>      - `src\v2\InputTip.ahk`

> [!Warning]
>
> - 软件中使用到了 `powershell`，请确保你的电脑环境中有 `powershell`
> - 现在的 Windows，都内置了 `powershell`，但总有一些特殊环境没有，可能导致运行报错
> - 如何确认是否有 `powershell`？
>   - 打开 `cmd` 输入 `powershell` 回车，如果出现报错，说明没有 `powershell`
>   - 你需要让 `cmd` 能够使用 `powershell`

- **[下载](https://inputtip.pages.dev/download) 并运行 `InputTip.exe` 即可**

  - 你也可以在项目的 Releases 页面下载
  - 推荐做法: **新建一个目录，将 `InputTip.exe` 放入其中，然后再运行它**
    - 因为运行 `InputTip.exe` 后，会产生以下文件或文件夹
      - `InputTipCursor` 鼠标样式文件夹
      - `InputTipSymbol` 图片符号文件夹
      - `InputTip.ini` 配置文件
      - `InputTip.lnk` 快捷方式
        - 通过任务计划程序生成的特殊快捷方式
        - 运行此快捷方式不会弹出 `UAC` 权限提示窗口
        - 此快捷方式被删除后，会随着 `InputTip.exe` 启动重新生成
    - **这样做，所有相关的文件或文件夹都在同一个目录中，方便管理**
      - 或者直接下载 `InputTip.zip`

- 关于 `UAC` 权限提示窗口

  - 由于 `InputTip.exe` 需要管理员权限才能正常运行，所以会弹出 `UAC` 权限提示窗口
  - 如果你希望不弹出此窗口，请运行由 `InputTip.exe` 生成的 `InputTip.lnk` 快捷方式

- 设置开机自启动: 点击 `托盘菜单` => `开机自启动`

- 设置鼠标样式

  > [更多已适配的鼠标样式](https://inputtip.pages.dev/download/extra)

  1. 点击 `托盘菜单` => `更改配置` => `鼠标样式`
  2. 在下拉列表中，选择包含 `.cur` 或 `.ani` 文件的文件夹目录路径
     - 比如默认的中文鼠标样式文件夹目录路径: `InputTipCursor\default\CN`
  3. 点击 `确认`

> [!Warning]
>
> - 你应该尽量让三种状态下的鼠标样式文件夹中包含的鼠标样式文件的数量和类型是一致的
> - 比如：
>   - 如果中文状态的目录路径下有 `IBeam.cur` 或 `IBeam.ani` 文件，英文状态或大写锁定的目录路径下没有。
>   - 则切换到中文状态时，会加载中文状态的 `IBeam.cur`
>   - 但是再切换到英文或大写锁定时，`IBeam` 类型的鼠标样式不会变化，因为英文和大写锁定缺少对应的样式文件

### 编译

> [!Tip]
> 你可以自行查看源代码并编译 `InputTip`

> [!Warning]
>
> 如果修改了项目代码，需要先编译 `InputTip.JAB.JetBrains.ahk`，再编译 `InputTip.ahk`

1. 克隆项目仓库到本地

   ```shell
    git clone --depth 1 https://github.com/abgox/InputTip.git
   ```

2. 安装 [AutoHotkey v2](https://www.autohotkey.com/)
   - 这一步完成后，你也可以直接运行 `src\v2\InputTip.ahk` 来使用 `InputTip`
3. 打开 `AutoHotKey Dash`
4. 点击左边的 `Compile`，等待编译器下载完成
5. 重新点击左边的 `Compile`
6. 将 `src\v2\InputTip.ahk` 拖入弹出的编译窗口中
7. 点击左下角的 `Convert` 完成编译
8. 运行编译后的 `InputTip.exe`

### 卸载

- 所有相关的文件或目录

  - 软件本体 `InputTip.exe`
  - 鼠标样式文件夹 `InputTipCursor` (软件本体的同级目录下)
  - 图片符号文件夹 `InputTipSymbol` (软件本体的同级目录下)
  - 配置文件 `InputTip.ini` (软件本体的同级目录下)
  - 快捷方式 `InputTip.lnk` (软件本体的同级目录下)

---

1. 取消 `开机自启动`: 点击 `托盘菜单` => `设置` => `开机自启动`
   - 如果使用了 `开机自启动` 中的 `任务计划程序`，你需要打开 `任务计划程序`，找到 `abgox.InputTip.noUAC` 和 `abgox.InputTip.JAB.JetBrains` 任务，删除它们
   - 也可以忽略，它们不会造成任何影响，但尽量删除，让电脑更清洁
2. 退出 `InputTip.exe`
   - 如果修改了鼠标样式，可以通过 `更改配置` => `显示形式` => `1. 要不要修改鼠标样式` 设置为否，会尝试进行恢复
   - 如果未完全恢复，请根据弹窗提示信息进行操作
3. 删除以上所有文件或目录

### 如何在 JetBrains 系列 IDE 中使用 InputTip

> [通过 AutoHotkey 官方论坛中 Descolada 大佬给出的解决方案实现](https://www.autohotkey.com/boards/viewtopic.php?t=130941#p576439)

> [!Tip]
>
> 如果有其他 JAB 程序，也可以按照此步骤进行设置

1. 打开 Java Access Bridge (java 访问桥)

   - 如果命令不存在，请 [下载并安装 OpenJDK JRE](https://adoptium.net/temurin/releases/?os=windows&arch=x64&package=jre&version=8)

   ```cmd
     jabswitch -enable
   ```

2. 点击 `托盘菜单` => `启用 JAB/JetBrains IDE 支持`

   - 会在 `InputTip.exe` 同级目录下生成 `InputTip.JAB.JetBrains.exe`
   - 它由 `InputTip.exe` 控制，不需要手动启动/终止

3. 点击 `托盘菜单` => `设置光标获取模式`，将 JetBrains IDE 应用添加到其中的 `JAB` 列表中

4. 如果未生效，请重启正在使用的 JetBrains IDE

5. 如果仍未生效，请重启 InputTip 或重启系统

> [!Tip]
> 如果有多块屏幕，副屏幕上可能有坐标偏差，需要通过 `托盘菜单` => `设置特殊偏移量` 手动调整

### 关于符号

#### 图片符号

- `InputTip.exe` 启动后，会在同级目录下生成 `InputTipSymbol` 目录，其中包括 `default` 文件夹

  - `default` 文件夹中包含了默认的图片符号
  - 当 `托盘菜单` 中 `更改配置` => `显示形式` => `2. 在输入光标附近显示什么类型的符号`，选择 `显示图片符号` 时，会在输入光标附近显示对应的图片符号
  - 你也可以将自己喜欢的图片符号，或者自己制作图片符号，放入 `InputTipSymbol` 目录下
    - 限制: 图片必须是 `.png` 格式
    - [更多的符号图片](https://inputtip.pages.dev/download/extra)
  - 然后，点击 `托盘菜单` => `更改配置` => `图片符号`，在对应的下拉列表中选择正确的图片路径
  - 如果留空，则不会显示对应状态的图片符号

#### 方块符号

- 当 `托盘菜单` 中 `更改配置` => `显示形式` => `2. 在输入光标附近显示什么类型的符号`，选择 `显示方块符号` 时，会在输入光标附近显示不同颜色的方块符号
- 默认中文状态为**红色**，英文状态为**蓝色**，大写锁定为**绿色**
- 方块符号相关的配置: `托盘菜单` => `更改配置` => `方块符号`
- 当其中的方块符号的颜色设置修改为空时，则不会显示该状态的方块符号
  - 比如: 你只希望在中文状态下显示方块符号，那么就将 `英文状态时方块符号的颜色` 和 `大写锁定时方块符号的颜色` 的值都设置为空
  - 如果选择 `显示文本符号`，方块符号的颜色为空会导致文本符号无法显示

#### 文本符号

- 当 `托盘菜单` 中 `更改配置` => `显示形式` => `2. 在输入光标附近显示什么类型的符号`，选择 `显示文本符号` 时，会在输入光标附近显示对应的文本符号
- 默认中文状态为 `中`，英文状态为 `英`，大写锁定为 `大`
- 文本符号相关的配置: `托盘菜单` => `更改配置` => `文本符号`
- 当其中的文本字符设置修改为空时，则不会显示该状态的文本符号
  - 比如: 你只希望在中文状态下显示文本字符，那么就将 `英文状态时显示的文本字符` 和 `大写锁定时显示的文本字符` 的值都设置为空

### 自定义鼠标样式

> [!Tip]
>
> - 也可以直接下载 [已经适配的鼠标样式](https://inputtip.pages.dev/download/extra) 来使用
> - `InputTip.exe` 启动后，会在同级目录下生成 `InputTipCursor` 目录，其中包括 `default` 文件夹
>   - `default` 用于存放中文/英文/大写锁定状态的 **默认** 鼠标样式

1. 你需要在 `InputTipCursor` 目录下创建一个文件夹

   - 文件夹中只能包含鼠标样式文件(后缀名为 `.cur` 或 `.ani`)

   - 必须使用以下表格中的文件名(大小写都可以)

   - 每个文件都不是必须的，但建议至少添加 `Arrow`，`IBeam`，`Hand`

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

   - 详情参考 [微软文档: 关于光标(游标)](https://learn.microsoft.com/windows/win32/menurc/about-cursors)

2. 点击 `托盘菜单` => `更改配置` => `鼠标样式` => 在下拉列表中选择对应文件夹目录路径

> [!Warning]
>
> - 你应该尽量让三种状态下的鼠标样式文件夹中包含的鼠标样式文件的数量和类型是一致的
> - 比如：
>   - 如果中文状态的目录路径下有 `IBeam.cur` 或 `IBeam.ani` 文件，英文状态或大写锁定的目录路径下没有。
>   - 则切换到中文状态时，会加载中文状态的 `IBeam.cur`
>   - 但是再切换到英文或大写锁定时，`IBeam` 类型的鼠标样式不会变化，因为英文和大写锁定缺少对应的样式文件

### 兼容情况

#### 输入法兼容情况

> [!Tip]
>
> 现在，InputTip 使用 **【通用】** 和 **【自定义】** 模式兼容输入法，默认使用 **【通用】** 模式

- **【通用】**

  - [微信输入法](https://z.weixin.qq.com/)
  - [搜狗输入法](https://shurufa.sogou.com/)，[搜狗五笔输入法](https://wubi.sogou.com/)
  - [QQ 输入法](https://qq.pinyin.cn/)
  - [百度输入法](https://shurufa.baidu.com/)
  - 微软拼音，微软五笔，微软仓颉
  - [冰凌输入法](https://icesofts.com/)
  - 小鹤音形输入法
    - 需要使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成
    - 使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成的输入法都可用
  - [小小输入法](http://yongim.ysepan.com/)
  - [影子输入法](https://gitee.com/orz707/Yzime)
    - 需要关闭影子输入法中的 `tsf`
    - 在键盘布局中，选择一个能正常识别状态的输入法(建议选择微信输入法、搜狗输入法等)
    - 然后正常使用影子输入法即可
  - [可可五笔](https://suke.kim/)
  - 谷歌输入法

- **【自定义】**

  - 一个万能的模式，需要根据实际情况设置状态码(规则)和切换码(规则)
  - 详情参考: [关于【自定义】模式](https://inputtip.pages.dev/FAQ/custom-input-mode)
  - 可以通过 `设置输入法模式` => `自定义` 使用以下已知可用的配置:

    - 选择 `英文状态` 作为判断依据( `中文状态` 相反)

      - [小鹤音形](https://flypy.com/download/)
        - 经过测试，`v10.11.4` 版本中，在 `切换码数字`的输入框中填入 `257` 即可
      - [小狼毫(rime)输入法](https://rime.im/download/)
        - 经过测试，`v0.16.1` 版本中，勾选 `切换码规则` 中的 `使用偶数` 即可
      - [讯飞输入法](https://srf.xunfei.cn/)
        - 经过测试，`v3.0` 版本中，勾选 `状态码规则` 中的 `使用奇数` 即可
      - [手心输入法](https://www.xinshuru.com/)
        - 经过测试，`v3.1` 版本中，在 `切换码数字`的输入框中填入 `1` 即可
        - 兼容性一般，因为获取到的输入法状态可能有误，导致基于此的相关功能都可能有问题

#### [应用窗口兼容情况](https://inputtip.pages.dev/FAQ/support-app-list)

### 参考项目

- [ImTip - aardio](https://github.com/aardio/ImTip)
- [KBLAutoSwitch - flyinclouds](https://github.com/flyinclouds/KBLAutoSwitch)
- [AutoHotkeyScripts - Tebayaki](https://github.com/Tebayaki/AutoHotkeyScripts)
- [language-indicator - yakunins](https://github.com/yakunins/language-indicator)
- [RedDot - Autumn-one](https://github.com/Autumn-one/RedDot)
  - [InputTip v1](./src/v1/README.md) 在鼠标附近显示带文字的方块符号，后来 [InputTip v2](./) 版本默认通过不同颜色的鼠标样式来区分
  - 之后看到了 [RedDot - Autumn-one](https://github.com/Autumn-one/RedDot) 和 [language-indicator - yakunins](https://github.com/yakunins/language-indicator) 的设计，通过不同颜色加上小符号来判断不同输入法状态
  - InputTip 也参照了这样的设计，因为这样的实现很简单，其实就是 [InputTip v1](./src/v1/README.md) 中带文字的方块符号，去掉文字，加上不同的背景颜色

### Stars

**如果 `InputTip` 对你有所帮助，请考虑给它一个 Star ⭐**

<a href="https://github.com/abgox/InputTip">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://reporoster.com/stars/abgox/InputTip"> <!-- light theme -->
    <img alt="stargazer-widget" src="https://reporoster.com/stars/dark/abgox/InputTip"> <!-- dark theme -->
  </picture>
</a>

### 赞赏支持

<a href='https://ko-fi.com/W7W817R6Z3' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://abgox.pages.dev/buy-me-a-coffee.png' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

![赞赏支持](https://abgox.pages.dev/support.png)
