<p align="center">
  <h1 align="center">✨<a href="https://inputtip.pages.dev/">InputTip v2</a>✨</h1>
</p>

<p align="center">
    <a href="https://github.com/abgox/InputTip">Github</a> |
    <a href="https://gitee.com/abgox/InputTip">Gitee</a>
</p>

<p align="center">
    <a href="https://github.com/abgox/InputTip/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/abgox/InputTip" alt="license" />
    </a>
    <a href="https://img.shields.io/github/languages/code-size/abgox/InputTip.svg">
        <img src="https://img.shields.io/github/languages/code-size/abgox/InputTip.svg" alt="code size" />
    </a>
    <a href="https://img.shields.io/github/repo-size/abgox/InputTip.svg">
        <img src="https://img.shields.io/github/repo-size/abgox/InputTip.svg" alt="repo size" />
    </a>
</p>

---

### 前往 [inputtip.pages.dev](https://inputtip.pages.dev) 查看更多

### 介绍

- 基于 `AutoHotKey` 编写
- 一个输入法状态(中文/英文/大写锁定)提示工具

  - 根据输入法状态改变鼠标样式
    - [样式可以自定义](#自定义光标样式)
    - 默认使用 [多彩水滴 Oreo 光标](https://zhutix.com/ico/oreo-cu)，默认中文状态为红色，英文状态为蓝色，大写锁定为绿色
  - 在输入光标处根据输入法状态显示方块符号
    - 默认中文状态为红色，英文状态为蓝色，大写锁定为绿色
    - [通过配置文件自定义配置](#关于配置文件)

- [点击这里查看 v1 版本](./src/v1/README.md)

- [版本更新日志](https://inputtip.pages.dev/v2/changelog)
  - 如果你的网络环境无法访问它，请查看 [版本更新日志](./src/v2/CHANGELOG.md)

### 演示

![demo](https://inputtip.pages.dev/releases/v2/demo.gif)

### 使用

- [下载](https://inputtip.pages.dev/releases/v2/InputTip.exe) 并运行 `InputTip.exe` 即可

- 设置开机自启动

  1. 运行此软件后，在底部任务栏右侧找到此软件图标
  2. `鼠标右击` 软件图标
  3. 点击 `开机自启动`

- 设置鼠标样式

  1. 运行此软件后，在底部任务栏右侧找到此软件图标
  2. `鼠标右击` 软件图标
  3. 点击 `设置鼠标样式`
  4. 选择包含 `.cur` 或 `.ani` 文件的文件夹
     - 比如默认的中文鼠标样式选择的文件夹: `InputTipCursor\CN_Default`
     - 直接选择 `InputTipCursor\CN_Default` 和 `InputTipCursor\EN_Default` 即可快速重置为默认的中英文鼠标样式
  5. `鼠标右击` 软件图标，点击 `重启`

  - [点击下载一些可以直接使用的鼠标样式](https://inputtip.pages.dev/releases/v2/cursorStyle.zip)
    - 这是一个压缩包，需要将其解压，放入 `InputTipCursor` 目录下，然后进行上述步骤即可

### 关于配置文件

- 请查看 [配置文件说明](https://inputtip.pages.dev/v2/config)
  - 如果你的网络环境无法访问它，请查看 [配置文件说明](./src/v2/config.md)

### 卸载

- 退出此软件，删除程序文件 `InputTip.exe` 和光标样式文件夹 `InputTipCursor`
- 重启电脑，鼠标样式会恢复到使用此软件前的状态。
  - 退出软件时，会尝试恢复，但可能失败，如果想立即回到以前的鼠标样式，应该立即重启电脑

### 自定义光标样式

- 软件启动后，会在同级目录下生成 `InputTipCursor` 目录，其中包括 `CN`、`CN_Default`、`EN`、`EN_Default`、`Caps`、`Caps_Default` 六个文件夹
  - `CN`、`EN`、`Caps` 三个文件夹仅用于软件加载鼠标样式，不要修改它
    - `CN`: 存放当输入法状态为中文时的光标样式
    - `EN`: 存放当输入法状态为英文时的光标样式
    - `Caps`: 存放当大写锁定时的光标样式
  - `CN_Default`: 存放当输入法状态为中文时的**默认**光标样式
  - `EN_Default`: 存放当输入法状态为英文时的**默认**光标样式
  - `Caps_Default`: 存放当大写锁定时的**默认**光标样式

1. 请在 `InputTipCursor` 目录下创建一个文件夹

   - 文件夹中包含鼠标样式文件(后缀名为 `.cur` 或 `.ani`)
   - 文件名大小写都可以
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

   - 详情参考 [关于光标(游标)](https://learn.microsoft.com/windows/win32/menurc/about-cursors)

2. 在底部任务栏右侧找到此软件图标，`鼠标右击` 软件图标，点击 `设置鼠标样式`
3. 选择创建好的文件夹

### 兼容情况

- 截至 **2024/9/12**

- 已知可用的输入法(通过模式切换兼容)

  > - 这里的兼容情况也仅供参考，实际情况可能与此不同，你应该自行尝试
  > - 建议尝试的顺序是 `模式2`>`模式1`>`模式3`>`模式4`

  - `模式1`:
    - **微信**输入法
    - **搜狗**输入法
    - **QQ**输入法
    - **微软**拼音
    - **冰凌**(五笔)输入法
    - **小鹤音形**输入法(使用多多输入平台生成)
  - `模式2`(默认):

    - **微信**输入法
    - **搜狗**输入法
    - **QQ**输入法
    - **微软**(拼音/五笔)
    - **冰凌**(五笔)输入法
    - **小狼毫(rime)** 输入法
    - **小鹤音形**输入法(使用多多输入平台生成)
    - **百度**输入法
    - **谷歌**输入法

  - `模式3`
    - **讯飞**输入法
  - `模式4`
    - **手心**输入法

- 如何进行模式切换
  1.  运行此软件后，在底部任务栏右侧找到此软件图标
  2.  `鼠标右击` 软件图标
  3.  点击 `设置输入法`
  4.  从这几个模式中选择一个模式
      - 也可以一个个尝试，看哪一个模式对你使用的输入法有效
