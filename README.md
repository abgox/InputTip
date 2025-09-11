<h1 align="center">✨<a href="https://inputtip.abgox.com">InputTip</a>✨</h1>

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
        <img src="https://img.shields.io/github/created-at/abgox/InputTip" alt="created" />
    </a>
</p>

---

![InputTip](https://socialify.git.ci/abgox/InputTip/image?description=1&font=Inter&forks=1&issues=1&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI%2BDQogIDxtYXNrIGlkPSJjdXJzb3JNYXNrIj4NCiAgICA8cmVjdCB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgZmlsbD0id2hpdGUiLz4NCiAgICA8IS0tIOWFieagh%2BaVtOS9k%2BaUvuWkpyAxLjEg5YCN5bm25L%2Bd5oyB5Lit5b%2BD5a%2B56b2QIC0tPg0KICAgIDxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDI1NiwyNTYpIHNjYWxlKDEuMSkgdHJhbnNsYXRlKC0yNTYsLTI1NikiPg0KICAgICAgPHJlY3QgeD0iMjMwIiB5PSIxMDAiIHdpZHRoPSI1MiIgaGVpZ2h0PSIzMTIiIHJ4PSIxMCIgcnk9IjEwIiBmaWxsPSJibGFjayIvPg0KICAgICAgPHJlY3QgeD0iMTgwIiB5PSI4MCIgd2lkdGg9IjE1MiIgaGVpZ2h0PSIzNiIgcng9IjgiIHJ5PSI4IiBmaWxsPSJibGFjayIvPg0KICAgICAgPHJlY3QgeD0iMTgwIiB5PSIzOTYiIHdpZHRoPSIxNTIiIGhlaWdodD0iMzYiIHJ4PSI4IiByeT0iOCIgZmlsbD0iYmxhY2siLz4NCiAgICA8L2c%2BDQogIDwvbWFzaz4NCiAgPHJlY3QgeD0iOCIgeT0iOCIgd2lkdGg9IjQ5NiIgaGVpZ2h0PSI0OTYiIHJ4PSI2NCIgcnk9IjY0IiBmaWxsPSIjMUU4OEZGIiBtYXNrPSJ1cmwoI2N1cnNvck1hc2spIi8%2BDQo8L3N2Zz4NCg%3D%3D&name=1&owner=1&stargazers=1&theme=Auto)

<p align="center">
  <strong>喜欢这个项目？请给它一个 ⭐️ 或 <a href="https://abgox.com/donate">赞赏 💰</a></strong>
</p>

> [!Tip]
>
> - InputTip 使用 [AutoHotkey(AHK)](https://github.com/AutoHotkey/AutoHotkey) 语言编写
>   - [InputTip 可能被误判为游戏外挂，exe 版本可能被误判为病毒程序](https://inputtip.abgox.com/faq/about-virus)
>   - [因此，只推荐使用 zip 版本](https://inputtip.abgox.com/faq/zip-vs-exe)
> - InputTip 只适用于 **Windows** 系统: **Win10** 以上可用，以下未知
> - `托盘菜单` 指的是鼠标右键点击任务栏托盘区域的 InputTip 后显示的菜单

### 介绍

- 一个输入法状态管理工具：实时提示(鼠标样式、符号显示) + 窗口自动切换状态 + 快捷键切换状态

  - [多种状态提示方案](#关于状态提示方案)
    - [鼠标方案](#鼠标方案): 使用多套鼠标光标样式，根据输入法状态加载不同的鼠标光标样式
    - [符号方案](#符号方案): 根据输入法状态在输入光标附近显示不同的 **符号**
  - 切换不同窗口时，自动切换到指定的输入法状态
    - 支持 `标题级` 的匹配
  - 设置按键强制切换到指定的输入法状态
  - 详细便捷的配置菜单
    - 所有的配置变动，都只应该在 `托盘菜单` 中进行
    - 不要手动修改 `InputTip.ini` 文件

### 演示

> [!Tip]
>
> - 如果这里无法正常显示，[可前往官网查看](https://inputtip.abgox.com/)
> - [点击查看 Bilibili 中的介绍及教学视频](https://www.bilibili.com/video/BV15oYKz5EQ8)

<video src="https://inputtip.abgox.com/releases/v2/demo.mp4" controls></video>

### 新的变化

- 请查阅 [更新日志](./src/CHANGELOG.md)

### 常见问题

- 如果有使用问题，请先确保当前使用的 InputTip 是最新版本

  - 如果是 [zip 版本](#zip-版本):

    - `托盘菜单` => `其他设置` => `更新检查` => `与源代码仓库同步`
    - 同步完成后，检查问题是否仍然存在

  - 如果是 [exe 版本](#exe-版本):
    - 在 `托盘菜单` => `关于` 中查看当前版本号
    - `托盘菜单` => `其他设置` => `更新检查` => `立即检查版本更新`
    - 如果存在新版本，你应该先更新，然后检查问题是否仍然存在

- 然后查看相关的文档
  - 本页面中包含的内容
  - [常见问题(FAQ)](https://inputtip.abgox.com/faq/)
  - [输入法和应用窗口兼容情况](#兼容情况)
  - [issues](https://github.com/abgox/InputTip/issues)
  - ...
- 如果还有问题，可以创建 [issues](https://github.com/abgox/InputTip/issues) 或前往 [腾讯频道](https://pd.qq.com/s/gyers18g6?businessType=5) 或 [QQ 反馈交流群(451860327)](https://qm.qq.com/q/Ch6T7YILza) 交流反馈

### 安装

#### zip 版本

> [!Tip]
>
> - 推荐使用，它拥有 [exe 版本](#exe-版本) 不具备的额外特性，且没有 [exe 版本](#exe-版本) 所存在的缺陷
> - 详情参考: [关于 zip 与 exe 版本的区别以及相关说明](https://inputtip.abgox.com/faq/zip-vs-exe)

- 下载仓库的最新代码压缩包 `InputTip-main.zip`
- 在仓库的 Releases (发行版) 中下载 `InputTip.zip`
- [前往官网下载 InputTip.zip](https://inputtip.abgox.com/download)
- 使用 [Scoop](https://scoop.sh/)

  - 添加 [abyss](https://abyss.abgox.com) bucket ([Github](https://github.com/abgox/abyss) 或 [Gitee](https://gitee.com/abgox/abyss))

  - 安装 `InputTip-zip`

    ```shell
    scoop install abyss/abgox.InputTip-zip
    ```

#### exe 版本

> [!Warning]
>
> - 不推荐使用，和 [zip 版本](#zip-版本) 相比，它缺少了一些特性，且有一些缺陷
> - 详情参考: [关于 zip 与 exe 版本的区别以及相关说明](https://inputtip.abgox.com/faq/zip-vs-exe)

- 在仓库的 Releases (发行版) 中下载 `InputTip.exe`

- 使用 [Scoop](https://scoop.sh/)

  - 添加 [abyss](https://abyss.abgox.com) bucket ([Github](https://github.com/abgox/abyss) 或 [Gitee](https://gitee.com/abgox/abyss))

  - 安装 `InputTip`

    ```shell
    scoop install abyss/abgox.InputTip
    ```

- 使用 [WinGet](https://learn.microsoft.com/windows/package-manager/winget/)

  ```shell
  winget install abgox.InputTip
  ```

### 使用

1. 完成 [安装](#安装) 后，运行对应文件即可

   - [Scoop](https://scoop.sh/): 运行安装后创建的 `InputTip` 快捷方式或命令即可
   - [WinGet](https://learn.microsoft.com/windows/package-manager/winget/): 运行 `InputTip` 命令即可
   - 如果是手动下载的

     - zip 版本: 运行 `InputTip.bat`
     - exe 版本: 运行 `InputTip.exe`

2. 设置开机自启动: `托盘菜单` => `开机自启动`

3. 设置 `配置菜单的字体大小`

   - 你可以设置字体大小来优化配置菜单在不同屏幕上的显示效果
   - `托盘菜单` => `其他设置` => `配置菜单字体大小`

4. 使用 [鼠标方案](#鼠标方案): `托盘菜单` => `状态提示 - 鼠标方案` => `加载鼠标样式`

5. 使用 [符号方案](#符号方案): `托盘菜单` => `状态提示 - 符号方案` => `指定符号的类型`

6. 更多相关配置在 `托盘菜单` 中查看

### 卸载

1. 取消 `开机自启动`: `托盘菜单` => `开机自启动`
2. 退出: `托盘菜单` => `退出`
3. 删除下方的 [目录结构及数据](#目录结构及数据) 中展示的相关目录即可

### 目录结构及数据

- zip 版本

  ```txt
  InputTip-zip/
  ├── InputTip.bat            # 启动脚本
  ├── src/
      ├── InputTip.ini        # 配置文件
      ├── InputTipCursor/     # 鼠标样式
      ├── InputTipSymbol/     # 图片符号
      └── ...                 # 其他源代码文件
  └── ...                     # 其他文件

  ```

- exe 版本

  - 没有根目录，建议新建一个目录，将 `InputTip.exe` 放入其中再运行

  ```txt
  InputTip-exe/
  ├── InputTip.exe            # 主程序
  ├── InputTip.ini            # 配置文件
  ├── InputTipCursor/         # 鼠标样式
  ├── InputTipSymbol/         # 图片符号
  └── ...
  ```

---

- 如果你需要备份 InputTip 的数据以便于后续使用，请备份它们

  - `InputTip.ini`
  - `InputTipCursor` (如果没有修改，可以忽略)
  - `InputTipSymbol` (如果没有修改，可以忽略)

- 如果使用 [Scoop](https://scoop.sh/) 安装 [abyss](https://abyss.abgox.com) 下的 `InputTip-zip` 或 `InputTip`
  - 它会将这些数据文件或文件夹保存在 [Scoop](https://scoop.sh/) 的 persist 目录中
  - 可以正常通过 [Scoop](https://scoop.sh/) 更新、卸载，不会删除它们，除非卸载时携带 `-p` 或 `--purge` 参数
- 如果使用 [WinGet](https://learn.microsoft.com/windows/package-manager/winget/) 安装 [abgox.InputTip](https://github.com/microsoft/winget-pkgs/tree/master/manifests/a/abgox/InputTip)
  - 这些数据文件或文件夹会保存在 `$env:LocalAppData\Microsoft\WinGet\Packages\abgox.InputTip_Microsoft.Winget.Source_8wekyb3d8bbwe` 中
  - 可以正常通过 [WinGet](https://learn.microsoft.com/windows/package-manager/winget/) 更新、卸载，不会删除这些数据文件和文件夹

### 自定义功能

> [!Caution]
>
> - 它是 [zip 版本](#zip-版本) 独有的功能，因为 [exe 版本](#exe-版本) 无法实现它
> - 如果你不熟悉 [AutoHotkey(AHK)](https://github.com/AutoHotkey/AutoHotkey) 语言开发 ([v2 版本](https://www.autohotkey.com/docs/v2/))，不要随意进行更改
>   - 不要修改 `plugins` 目录以外的其他源代码文件

- 在 `src` 目录下有一个 `plugins` 目录
- 目录中添加了一个空的 `InputTip.plugin.ahk` 文件
- InputTip 会引入这个文件，你可以在其中添加自定义功能，比如 **自定义热键**、**自定义热字串** 等
- 或者，在 `plugins` 目录中新建 `.ahk` 文件，然后在 `InputTip.plugin.ahk` 中 `#Include` 它
- `plugins` 目录的特点:
  - 在 `plugins` 目录中的文件不会因为版本更新而被覆盖
  - 如果你使用 [Scoop](https://scoop.sh/) 安装 [abyss](https://abyss.abgox.com) 下的 `abgox.InputTip-zip`，`plugins` 目录会被 `persist`
    - 因此，也可以通过 [Scoop](https://scoop.sh/) 更新，而不会覆盖 `plugins` 目录中的文件

### 关于状态提示方案

#### 鼠标方案

- 使用多套鼠标样式，根据输入法状态加载不同的鼠标样式
- 默认使用 [多彩水滴 Oreo 光标](https://zhutix.com/ico/oreo-cu)
  - 默认中文状态为 **红色**，英文状态为 **蓝色**，大写锁定为 **绿色**
  - 在 [更多已适配的鼠标样式](https://inputtip.abgox.com/download/extra) 中有提供它们的左手镜像版本
- [自定义鼠标样式](#自定义鼠标样式)

#### 符号方案

- 根据输入法状态显示不同的 [符号](#关于符号)

- 它有两种显示位置

  - 在鼠标附近显示:
    - `托盘菜单` => `在鼠标附近显示符号`
  - 在输入光标附近显示:
    - 需要搭配 [符号的名单机制](https://inputtip.abgox.com/faq/symbol-list-mechanism/) 使用
    - `托盘菜单` => `符号的黑/白名单`

- 注意: 在输入光标附近显示会涉及到调用 DLL 获取应用窗口中的输入光标位置信息
  - InputTip 将通过 [光标获取模式](https://inputtip.abgox.com/faq/cursor-mode) 尝试获取到输入光标位置信息
    - 部分应用可能会因为 DLL 调用出现兼容性问题
      - 它们应该从 `符号的白名单` 中移除
      - 或者，使用 `在鼠标附近显示符号`
    - 部分应用可能必须使用某个特殊模式才能获取
    - 可以通过 `托盘菜单` => `光标获取模式` 进行指定并测试
  - 如果获取不到:
    - 符号无法显示
    - 这就只能使用 [鼠标方案](#鼠标方案) 或者 `在鼠标附近显示符号`
  - 获取到了，符号位置有偏差，但在此应用中，所有窗口的偏差相同:
    - 符号会显示，但符号显示的位置有偏差
    - 由于偏差相同，可以通过 `偏移量`、`特殊偏移量` 解决
  - 获取到了，符号位置有偏差，且在此应用中，不同窗口的偏差不同:
    - 符号会显示，但符号显示的位置有偏差
    - 由于偏差不同，无论如何设置，都会有窗口出现位置错误，目前无解
    - 参考示例:
      - [在 vscode v1.100 版本中，编辑界面和终端界面符号位置有不同偏差](https://github.com/abgox/InputTip/issues/172)
      - 在 vscode v1.101 版本中已修复

### [如何在 JetBrains 系列 IDE 中使用 InputTip](https://inputtip.abgox.com/faq/use-inputtip-in-jetbrains)

> [!Tip]
>
> - [使用 AutoHotkey 官方论坛中的解决方案实现，方案由 Descolada 提出](https://www.autohotkey.com/boards/viewtopic.php?t=130941#p576439)
> - 建议使用 [Microsoft OpenJDK 21](https://learn.microsoft.com/java/openjdk/download#openjdk-21)
> - 如果使用其他版本的 JDK 或 JRE，需要自行测试可用性
> - 例如 [Adoptium Temurin](https://adoptium.net/zh-CN/temurin/releases/?os=windows&arch=any)，测试后发现: JDK 版本无效，JRE 版本有效

> [!Warning]
>
> - 如果不使用 [符号方案](#符号方案)，或者使用 `在鼠标附近显示符号`，无需步骤 1 和 2

1. 安装 [Microsoft OpenJDK 21](https://learn.microsoft.com/java/openjdk/download#openjdk-21)

   - 使用 [Scoop](https://scoop.sh/)

     - 添加 [abyss](https://abyss.abgox.com) bucket ([Github](https://github.com/abgox/abyss) 或 [Gitee](https://gitee.com/abgox/abyss))

     - 安装 `Microsoft.OpenJDK.21`

       ```shell
       scoop install abyss/Microsoft.OpenJDK.21
       ```

   - 使用 [WinGet](https://learn.microsoft.com/windows/package-manager/winget/)

     ```shell
     winget install Microsoft.OpenJDK.21
     ```

2. 启用 `Java Access Bridge`

   - 如果以下命令不存在，请检查 **步骤 1**
   - 如果以下命令不能正常运行，请检查环境变量是否配置正确

     ```shell
     java -version
     ```

     ```shell
     jabswitch -enable
     ```

3. `托盘菜单` => `更多设置` => `JAB/JetBrains IDE 支持`

4. `托盘菜单` => `光标获取模式`，设置 JetBrains IDE 的光标获取模式为 `JAB`

5. 如果未生效，请依次尝试以下操作并查看是否生效
   - 重启 InputTip: `托盘菜单` => `重启`
   - 重启正在运行的 JetBrains IDE
   - 重启系统

> [!Tip]
> 如果有多块屏幕，副屏幕上可能有坐标偏差，需要通过 `托盘菜单` => `特殊偏移量` 手动调整

### 自定义鼠标样式

> [!Tip]
>
> - 可以直接使用 [已经适配的一些鼠标样式](https://inputtip.abgox.com/download/extra)

- 你需要在 `InputTipCursor` 目录下创建一个文件夹

- 文件夹不应该放在 `default` 文件夹下

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

> [!Warning]
>
> - 你应该尽量让三种状态下的鼠标样式文件夹中包含的鼠标样式文件的数量和类型是一致的
> - 比如：
>   - 如果中文状态的目录路径下有 `IBeam.cur` 或 `IBeam.ani` 文件，英文状态或大写锁定的目录路径下没有。
>   - 则切换到中文状态时，会加载中文状态的 `IBeam.cur`
>   - 但是再切换到英文或大写锁定时，`IBeam` 类型的鼠标样式不会变化，因为英文和大写锁定缺少对应的样式文件

### 兼容情况

#### 应用窗口兼容情况

> [!Tip]
>
> 如果你不使用 [符号方案](#符号方案)，可以直接忽略

- InputTip 在部分应用窗口中无法正确获取到输入光标位置，导致使用 [符号方案](#符号方案) 可能存在问题
- [应用窗口兼容情况](https://inputtip.abgox.com/faq/app-compatibility) 会记录这些特别的应用窗口
- 你也可以使用 `在鼠标附近显示符号` 作为折中的方案

#### 输入法兼容情况

> [!Tip]
>
> - InputTip 使用 `通用` 和 `自定义` 模式兼容不同输入法的状态识别，默认使用 `通用` 模式
> - 如果你熟悉了 `自定义` 模式，建议直接使用 `自定义` 模式去配置规则，状态识别更稳定
> - 设置: `托盘菜单` => `输入法相关`

- `通用`

  - [微信输入法](https://z.weixin.qq.com/)
  - [搜狗输入法](https://shurufa.sogou.com/)，[搜狗五笔输入法](https://wubi.sogou.com/)
  - [QQ 输入法](https://qq.pinyin.cn/)
  - [百度输入法](https://shurufa.baidu.com/)
  - 微软拼音，微软五笔，微软仓颉...
    - `指定窗口自动切换状态` 和 `状态切换快捷键` 存在缺陷
      - 只有当聚焦到输入框时，微软输入法才能正常切换输入法状态
      - 这可能会导致 InputTip 去模拟按键切换输入法状态时切换失效
      - 大写锁定除外，因为它是通过模拟输入`CapsLock` 按键实现，不受其他影响
  - 美式键盘 ENG
    - `指定窗口自动切换状态` 和 `状态切换快捷键` 存在缺陷
      - 它只有英文状态和大写锁定这两种输入法状态
      - 因此，只有英文状态和大写锁定的输入法状态切换有效
  - [冰凌输入法](https://icesofts.com/)
  - [手心输入法](https://www.xinshuru.com/): 使用 `Shift` 切换中英文状态无法正常识别，需要参照下方的使用方式

    - 首先，确保输入法状态正确
      - 通过 `Shift` 将输入法状态切换为中文，然后不再使用 `Shift` 切换状态(此时可以在手心输入法设置中关闭 `Shift` 切换功能)
      - 后续只能使用 `Ctrl + Space` 进行中英文状态切换，否则状态识别有误
    - 其次，修改 InputTip 的配置
      - `托盘菜单` => `输入法相关` => `输入法状态的切换方式`，选择 `模拟输入 Ctrl + Space`

  - 小鹤音形输入法
    - 需要使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成
    - 使用 [多多输入法生成器](https://duo.ink/ddimegen/ddimegen-desc.html) 生成的输入法都可用
  - [小小输入法](http://yongim.ysepan.com/)
  - [华宇拼音输入法](https://pinyin.thunisoft.com/)
  - [影子输入法](https://gitee.com/orz707/Yzime)
    - 需要关闭影子输入法中的 `tsf`
    - 在键盘布局中，选择一个能正常识别状态的输入法(建议选择[微信输入法](https://z.weixin.qq.com/)、[搜狗输入法](https://shurufa.sogou.com/)等)
    - 然后正常使用影子输入法即可
  - [可可五笔](https://suke.kim/)
  - 谷歌输入法
  - ...

- `自定义`

  - 一个万能的模式，根据规则列表依次匹配，需要根据实际情况添加一条或多条规则
  - 详情参考: [关于【自定义】模式](https://inputtip.abgox.com/faq/custom-input-mode)
  - 可以通过 `输入法相关` => `自定义` 使用以下已知可用的规则配置:

    - 配置项 `默认状态` 选择 `英文状态`

    - [小狼毫(rime)输入法](https://rime.im/download/)

      - 经过测试，`v0.17.0` 版本中，添加以下规则即可

        | 顺序 | 状态码规则 | 切换码规则 | 输入法状态 |
        | :--: | :--------: | :--------: | :--------: |
        |  1   |            |    奇数    |  中文状态  |

    - [讯飞输入法](https://srf.xunfei.cn/)

      - 经过测试，`v3.0` 版本中，添加以下规则即可

        | 顺序 | 状态码规则 | 切换码规则 | 输入法状态 |
        | :--: | :--------: | :--------: | :--------: |
        |  1   |    偶数    |            |  中文状态  |

    - [小鹤音形](https://flypy.cc)

      - 经过测试，`v10.13.0` 版本中，添加以下规则即可

        | 顺序 | 状态码规则 | 切换码规则 | 输入法状态 |
        | :--: | :--------: | :--------: | :--------: |
        |  1   |            |    1025    |  中文状态  |

### 参考项目

- [ImTip - aardio](https://github.com/aardio/ImTip)
- [KBLAutoSwitch - flyinclouds](https://github.com/flyinclouds/KBLAutoSwitch)
- [AutoHotkeyScripts - Tebayaki](https://github.com/Tebayaki/AutoHotkeyScripts)
- [language-indicator - yakunins](https://github.com/yakunins/language-indicator)
- [RedDot - Autumn-one](https://github.com/Autumn-one/RedDot)
- [InputTip v1](../v1) 在鼠标附近显示带文字的方块符号，后来 [InputTip v2](./) 版本默认通过不同颜色的鼠标样式来区分
- 之后看到了 [RedDot - Autumn-one](https://github.com/Autumn-one/RedDot) 和 [language-indicator - yakunins](https://github.com/yakunins/language-indicator) 的设计，通过不同颜色加上小符号来判断不同输入法状态
- InputTip 也参照了这样的设计，简单直接，其实就是 [InputTip v1](../v1) 中带文字的方块符号，去掉文字，加上不同的背景颜色

---

[![Powered by DartNode](https://dartnode.com/branding/DN-Open-Source-sm.png)](https://dartnode.com "Powered by DartNode - Free VPS for Open Source")
