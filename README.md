<p align="center">
    <h1 align="center">✨InputTip v2 ✨</h1>
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

### 介绍

-   基于 `AutoHotKey` 编写的一个小工具
-   根据当前输入法中英文状态切换光标样式
    -   [样式可以自定义](#自定义光标样式)
    -   默认使用 [多彩水滴 Oreo 光标](https://zhutix.com/ico/oreo-cu)，中文状态为红色，英文状态为蓝色
-   [点击这里查看 v1](./src/v1/README.md)

### 演示

![demo](https://abgop.netlify.app/InputTip/demo_v2.gif)

### 使用

-   [下载](https://github.com/abgox/InputTip/releases/download/v2.1.0/InputTip.exe) 并运行 `InputTip.exe` 即可

-   设置开机自启动

    1. 运行此软件后，在屏幕右下角图标处找到此软件
    2. `鼠标右击` 软件图标
    3. 点击 `开机自启动`

-   设置鼠标样式

    1. 运行此软件后，在屏幕右下角图标处找到此软件
    2. `鼠标右击` 软件图标
    3. 点击 `设置鼠标样式`
    4. 选择包含 `.cur` 或 `.ani` 文件的文件夹
        - 比如默认的中文鼠标样式选择的文件夹: `InputTipCursor\oreo_default\Red`
    5. `鼠标右击` 软件图标，点击 `重启`

    -   [点击下载一些可以直接使用的鼠标样式](https://github.com/abgox/InputTip/releases/download/v2.1.0/cursorStyle.zip)
        -   这是一个压缩包，需要将其解压，放入 `InputTipCursor` 目录下，然后进行上述步骤即可

### 卸载

-   退出此软件，删除程序文件 `InputTip.exe` 和光标样式文件夹 `InputTipCursor`
-   重启电脑，鼠标样式会恢复到使用此软件前的状态。

### 自定义光标样式

> -   软件启动后，会在同级目录下生成 `InputTipCursor` 目录，其中包括 `CN`、`EN` 两个目录，分别存放当输入法状态为中文和英文时的光标样式

1. 请在 `InputTipCursor` 目录下创建一个文件夹

    - 文件夹中所需的文件(后缀名为 `.cur` 或 `.ani`)
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

    - 详情参考 [关于光标(游标)](https://learn.microsoft.com/zh-cn/windows/win32/menurc/about-cursors)

2. 在屏幕右下角图标处找到此软件，`鼠标右击` 软件图标，点击 `设置鼠标样式`
3. 选择创建好的文件夹
    - 注意，选择的文件夹不能是 `InputTipCursor` 目录下的 `EN` 和 `CN` 文件夹

### 兼容情况(截至 2024/1/20)

-   已知可用
    -   **搜狗**输入法、**百度**输入法、**微信**输入法、**QQ**输入法、**微软**、**冰凌**(五笔)输入法
    -   **讯飞**输入法(可用，需要设置)
        1.  运行此软件后，在屏幕右下角图标处找到此软件
        2.  `鼠标右击` 软件图标
        3.  点击 `设置输入法`
        4.  点击 `讯飞输入法`
        -   如果改用搜狗等上述输入法，需要再次改回 `默认`
-   已知不可用
    -   小鹤音形输入法、小狼毫(rime)输入法、手心输入法、谷歌输入法、2345 王牌输入法
