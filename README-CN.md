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
-   [点击这里查看 v1](./src/v1/README-CN.md)

### 演示

![demo](https://abgop.netlify.app/InputTip/demo_v2.gif)

### 使用

-   [下载](https://gitee.com/abgox/InputTip/releases/download/v2.0.0/InputTip.exe) 并运行 `InputTip.exe` 即可

-   设置开机自启动
    1. 运行此软件后，在屏幕右下角图标处找到此软件
    2. `鼠标右击` 软件图标
    3. 点击 `开机自启动`

### 卸载

-   退出此软件，删除程序文件 `InputTip.exe` 和光标样式文件夹 `InputTipCursor`
-   重启电脑，鼠标光标样式恢复如初。

### 自定义光标样式

-   软件启动后，会在同级目录下生成 `InputTipCursor` 目录，其中包括 `CN`、`EN` 两个目录，分别存放当输入法状态为中文和英文时的光标样式
-   如需自定义光标样式，请自行替换样式文件

    -   两个目录中所需的文件(一般为 `.cur` 或 `.ani`)
    -   文件名大小写都可以
    -   每个文件都不是必须的，但建议至少添加 `Arrow`，`Ibeam`，`Hand`
    -   必须确保在 `CN`、`EN` 两个目录都存在对应的同类型样式文件

        -   如，`CN` 目录下存在 `Arrow.ani` 或 `Arrow.cur`，`EN` 目录下就必须存在 `Arrow.ani` 或 `Arrow.cur`

        | 文件名(类型) |              说明               |
        | :----------: | :-----------------------------: |
        |    Arrow     |            普通选择             |
        |    Ibeam     |            文本选择             |
        |     Wait     |               忙                |
        |   UpArrow    |            备用选择             |
        |   SizeNWSE   | 对角线调整大小 1 (左上 => 右下) |
        |   SizeNESW   | 对角线调整大小 2 (左下 => 右上) |
        |    SizeWE    |          水平调整大小           |
        |    SizeNS    |          垂直调整大小           |
        |   SizeAll    |              移动               |
        |      No      |           无法(禁用)            |
        |     Hand     |            链接选择             |
        |     Help     |            帮助选择             |
        |     Pin      |            位置选择             |
        |    Person    |            人员选择             |

-   详情参考 [关于光标(游标)](https://learn.microsoft.com/zh-cn/windows/win32/menurc/about-cursors)

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
