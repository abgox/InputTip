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
    -   [样式可以自定义](#使用)
    -   默认使用 [多彩水滴 Oreo 光标](https://zhutix.com/ico/oreo-cu)，中文状态为红色，英文状态为蓝色
-   [点击这里查看 v1](./src/v1/README.md)

### 演示

![demo](https://abgop.netlify.app/InputTip/demo_v2.gif)

### 使用

-   [下载](https://github.com/abgox/InputTip/releases/download/v2.0.0/InputTip.exe) 并运行 `InputTip.exe` 即可

-   启动后，会在同级目录下生成 `InputTipCursor` 目录，其中包括 `CN`、`EN` 两个目录，分别存放当输入法状态为中文和英文时的光标样式
    -   如需自定义光标样式，请自行替换样式文件
    -   文件名和对应样式，参考 [关于光标(游标)](https://learn.microsoft.com/zh-cn/windows/win32/menurc/about-cursors)
-   如果不再使用此软件，请自行通过鼠标设置还原鼠标光标

### 兼容情况(截至 2024/1/20)

-   已知可用
    -   **搜狗**输入法、**百度**输入法、**微信**输入法、**QQ**输入法、**微软**、**冰凌**(五笔)输入法
    -   **讯飞**输入法(可用，需要设置)
        -   运行此软件后，在屏幕右下角图标处找到此软件，`鼠标右击` => 点击 `设置输入法` => 点击 `讯飞输入法`
        -   如果改用搜狗等上述输入法，需要再次改回 `默认`
-   已知不可用
    -   小鹤音形输入法、小狼毫(rime)输入法、手心输入法、谷歌输入法、2345 王牌输入法
