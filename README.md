<p align="center">
 <h1 align="center">✨<a href="https://inputtip.pages.dev/">InputTip v1</a>✨</h1>
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
        <img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Finputtip.pages.dev%2Freleases%2Fv1%2Fversion.json&query=%24.version&prefix=v&label=version" alt="version" />
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

> [!Warning]
> InputTip v1 版本不再更新，且 v2 版本通过配置可以实现 v1 同样的效果
>
> 请使用 v2 版本

### 介绍

- 基于 `AutoHotKey` 编写的一个小工具
- 在光标处实时显示当前输入法中英文以及大写锁定状态
- 根据不同窗口自动切换不同的输入状态

- [版本更新日志](https://inputtip.pages.dev/v1/changelog)
  - 如果你的网络环境无法访问它，请查看 [版本更新日志](./CHANGELOG.md)

### 演示

![demo](https://inputtip.pages.dev/releases/v1/demo.gif)

### 使用

- [下载](https://inputtip.pages.dev/releases/v1/InputTip.exe) 并运行 `InputTip.exe` 即可

  - 推荐做法: 新建一个目录，将 `InputTip.exe` 放入其中，然后再运行它
    - 因为运行 `InputTip.exe` 后，会产生以下文件
      - `InputTip.ini` 配置文件
    - 这样做的话，所有相关的文件都在同一个目录中，方便管理

- 设置开机自启动
  1. 运行 `InputTip.exe` 后，在屏幕右下角图标处找到软件托盘图标
  2. `鼠标右击` 软件图标
  3. 点击 `开机自启动`

### 关于配置文件

- 请查看 [配置文件说明](https://inputtip.pages.dev/v1/config)
  - 如果你的网络环境无法访问它，请查看 [配置文件说明](./config.md)

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
  1.  运行 `InputTip.exe` 后，在底部任务栏右侧找到软件托盘图标
  2.  `鼠标右击` 软件托盘图标
  3.  点击 `设置输入法`
  4.  从这几个模式中选择一个可用的模式

### 赞赏支持

<a href='https://ko-fi.com/W7W817R6Z3' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://abgox.pages.dev/buy-me-a-coffee.png' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

![赞赏支持](https://abgox.pages.dev/support.png)
