<p align="center">
    <h1 align="center">✨InputTip v1 ✨</h1>
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
-   在光标处实时显示当前输入法中英文状态
-   [点击这里查看 v2](../../README.md)

### 演示

![demo](https://abgop.netlify.app/InputTip/demo.gif)

### 使用

-   [下载](https://github.com/abgox/InputTip/releases/download/v1.0.3/InputTip.exe) 并运行 `InputTip.exe` 即可

-   设置开机自启动
    1. 运行此软件后，在屏幕右下角图标处找到此软件
    2. `鼠标右击` 软件图标
    3. 点击 `开机自启动`

### 配置文件

-   所在位置：`InputTip.exe` 的同级目录下

    -   启动软件后会检查配置文件，如果不存在会自动创建

-   配置文件名：`InputTip.ini`

    -   与软件保持同名，如将软件名改为 `xxx.exe` ，则会自动创建 `xxx.ini`
    -   此时旧的配置文件 `InputTip.ini` **请自行删除**

-   配置说明(可按需更改)
    -   `font_family=SimHei` 字体显示
    -   `font_size=12` 字体大小(显示大小)
    -   `font_weight=900` 字体粗细
    -   `font_color=ffffff` 字体颜色(16 进制)
    -   `font_bgcolor=474E68` 背景颜色(16 进制)
    -   `windowTransparent=222` 透明度(0-255)
    -   `CN_Text=中` 中文状态显示
    -   `EN_Text=英` 英文状态显示
    -   `offset_x=30` X 轴显示位置偏移量
    -   `offset_y=-50` Y 轴显示位置偏移量
    -   `window_no_display=Notepad.exe` 希望隐藏的应用列表
        -   默认写入 `Notepad.exe` ，因为记事本中输入法中英文状态获取有问题
        -   具体写法：
            1. 找到希望隐藏的应用窗口的 `.exe` 文件
            2. 填写到这一个配置中，以 `,` 间隔
                - `window_no_display=Notepad.exe,App1.exe,App2.exe`

### 兼容情况(截至 2024/1/20)

-   已知可用
    -   **搜狗**输入法、**百度**输入法、**微信**输入法、**QQ**输入法、**微软**、**冰凌**(五笔)输入法
    -   **讯飞**输入法(可用，需要设置)
        -   运行此软件后，在屏幕右下角图标处找到此软件，`鼠标右击` => 点击 `设置输入法` => 点击 `讯飞输入法`
        -   如果改用搜狗等上述输入法，需要再次改回 `默认`
-   已知不可用
    -   小鹤音形输入法、小狼毫(rime)输入法、手心输入法、谷歌输入法、2345 王牌输入法
