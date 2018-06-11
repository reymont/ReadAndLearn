

# pannic

删除gocode，重新安装

cd /c/Go/src/github.com/nsf/gocode
go get -u -v github.com/nsf/gocode

# 使用Visual Studio Code辅助Go源码编写

* [使用Visual Studio Code辅助Go源码编写 - 推酷 ](http://www.tuicool.com/articles/iyQr2ur)

作为VIMer，日常编码中， Vim 编辑器依然是我的首选。以前以C语言为主要语言的时候是这样，现在以Go为主要语言时亦是这样。不过近期发现Mac上使用Vim在编写Go代码时，Vim时不时的“抽风”：出现一些“屏幕字符被篡改”的问题，比如下面这幅图中”func”变成了”fknc”:


虽然一段时间后，显示会自动更正过来，但这种“篡改”是会让你产生“幻觉”的。你会想：是不是我真的将”func”写成”fknc”了呢？久而久之，这个瑕疵将会影响你的编码效率。至于为何会出现这个问题，初步怀疑可能是因为vim加载较多插件导致的一些性能问题，我在安装了Ubuntu 16.04的台式机上至今还没发现这个问题（相同的.vimrc配置）。

于是，我打算找一款辅助编辑器，用于在被上面这个问题折磨得开始“厌恶”Vim的某些时候，切换一下，平复一下心情^0^。我看中了Microsoft开源的 Visual Studio Code ，简称：VSCode。

一、与Microsoft的Visual Studio的渊源

Microsoft做IDE还是很专业的，也是很认真的。大学那时候学C，嫌弃 Turbo C 太简陋，基本上都是在D版Visual Studio 6.0上完成各种作业和小程序的制作的。后来在2001年微软发布了.net战略，发布了 C#语言 ，同时也发布了Visual Studio .NET IDE。估计我也算是国内第一批使用到Visual Studio.NET IDE的人吧，那时候微软俱乐部在校园里免费发送Vs.net beta版光盘，我拿到了一份，并第一时间体验了vs.net。Visual Studio .NET与之前的VS 6.0有着天壤之别，功能强大，界面也做了重新设计，支持微软的各种语言，包括C#、C/C++(包括managed c++)、VB、ASP.net等，并在一年后的正式版发布后，逐渐在桌面应用程序开发中成为霸主，把那个时候在IDE领域的竞争对手 Borland公司 彻底打垮。但 Visual Studio 从此也变得更加庞大和臃肿，安装一个VS，没有几个G空间是不行的。想想那个时候机器的配置，跑个VS.net还真是心有而力不足。

工作之后，进入服务端编程领域，结识了Unix、Linux以及Vim、GCC，就再也没怎么碰过Visual Studio。随着工作OS也 从Windows切换到Ubuntu ，基本就和VS绝缘了。之后随着Java语言成为企业级应用的主角、Web时代的到来以及开源IDE（比如：Eclipse）的兴起，微软的Visual Studio不再那么耀眼，或者说是人们对于IDE的关注并不像开发GUI程序那个年代那么强烈了。但鉴于微软自身产品体系的庞大，VS始终在市场中占有一席之地。

而近些年，一些跨平台、轻量级、插件结构、支持智能感知、可随意定制的文本编辑器的出现，比如： Sublime Text 、 Atom 等让开发人员喜不自禁。这些编辑器并非定位于IDE，但功能又不输给IDE很多，尤其在支持编码、调试这些环节，它们完全可以与专业IDE媲美，但资源消耗却是像Visual Studio、 Eclipse 这样大而全的IDE所无法匹敌的。而Visual Studio Code恰是微软在这方面的一个尝试，也是微软最新公司战略的体现之一：拥抱所有开发者（不仅仅是Windows上的哦）。

二、VSCode安装

VSCode 发布于2015年4月的Build大会上。发布后，迅速得到开发者响应，大家普遍反映：VSCode性能不错、关注细节、体验良好，虽然当时VSCode的插件还不算丰富。一年多过去后，VSCode已经演化到了1.8.1版本（截至2016年12月末），支持所有主流编程语言的开发，配套的插件也十分丰富了。VSCode的安装简单的很，这一向都是微软的强项，你可以在其官方站上下载到各个平台的安装包（Linux平台也有.deb/.rpm两种包格式供选择，并提供32bit和64bit两种版本）。下载后安装即可。

1、VSCode配置和数据存储路径

VSCode安装后，一般不必关心其配置和数据存储路径的位置。但作为有一些Geek精神的developer来说，弄清楚其安装和配置的来龙去脉还是很有意义的。

在Mac上：

VSCode存储运行数据和配置文件的目录在：~/Library/Application Support/Code下：

~/Library/Application Support/Code]$ls
Backups/        CachedData/        Cookies-journal        Local Storage/        User/
Cache/            Cookies            GPUCache/        Preferences        storage.json

$ls User
keybindings.json    locale.json        settings.json        snippets/        workspaceStorage/
在Ubuntu中：

VSCode存储运行数据和配置文件的目录在~/.config/Code下面：

~/.config/Code$ ls
Backups  Cache  CachedData  Cookies  Cookies-journal  GPUCache  Local Storage  storage.json  User
至于Windows平台，请自行探索^_^。

2、启动方式

VSCode有两种启动方式：桌面启动和命令行启动。桌面启动自不必说了。命令行启动的示例如下：

$ code main.go
code命令会打开一个VSCode窗口并加载命令参数中的文件内容，这里是main.go。

三、VSCode的配置

一般来说，VSCode启动即可用了。但要想发挥出VSCode的能量，我们必须对其进行一番配置。VSCode的配置有几十上百项，这里无法全覆盖，仅说明一下我个人比较关注的。

1、安装插件

像VSCode这种小清新文本编辑器要想对编程语言有很好的支持，必须安装相应语言的插件。以Go为例，我们至少要安装 vscode-go 插件。vscode-go之于VSCode，就好比vim-go之于VIM。并且和 vim-go 类似，vscode-go实现的各种Features也是依赖诸多已存在的Go周边工具，包括：

gocode: go get -u -v github.com/nsf/gocode
godef: go get -u -v github.com/rogpeppe/godef
gogetdoc: go get -u -v github.com/zmb3/gogetdoc
golint: go get -u -v github.com/golang/lint/golint
go-outline: go get -u -v github.com/lukehoban/go-outline
goreturns: go get -u -v sourcegraph.com/sqs/goreturns
gorename: go get -u -v golang.org/x/tools/cmd/gorename
gopkgs: go get -u -v github.com/tpng/gopkgs
go-symbols: go get -u -v github.com/newhook/go-symbols
guru: go get -u -v golang.org/x/tools/cmd/guru
gotests: go get -u -v github.com/cweill/gotests/...
因此，要想实现vscode-go官网页面中demo中哪些神奇的Feature，你必须将上面的这些依赖工具逐一安装成功。如果缺少一个依赖工具，VSCode会在窗口右下角的状态栏里显示：“Analysis Tools Missing”字样，以提示你安装这些工具。

VSCode当然也支持Vim-mode的编辑模式，如果你也和我一样，喜欢用vim-mode在VSCode中进行编辑，可以安装 VSCodeVim插件 。

VSCode的插件安装方式分为两种：在线安装和VSIX方式安装。

在线安装，顾名思义，即在VSCode的窗口左侧边栏中点击“Extensions”按钮，在打开的Extensions搜索框中搜索你想要的插件名称，或者选择预制的条件获得插件信息。选中你要安装的插件，点击“Install”按钮即可完成安装。

VSIX安装：即到插件官网将插件文件下载到本地（插件安装文件一般以.vsix或.zip结尾），在窗口中选择：”Install from VSIX…”，选择你下载的插件文件即可。

安装后的插件都被放在~/.vscode/extensions目录下(mac和linux)。

2、更改语言设置

VSCode在初次启动时会判断当前系统语言，并以相应的语言作为默认窗口显示语言。比如：我的是中文OS X系统，那么默认VSCode的窗口文字都是中文。如果我要将其改为英文，应该如何操作呢？

F1登场！这里的F1可不是赛车比赛，而是快捷键F1，估计也是整个VSCode最常用的快捷键之一了。敲击F1后，VSCode会显示其“Command Palette”输入框，这里面包含了当前VSCode可以执行的所有操作命令，支持Search。我们输入”language”，在搜索结果中选择“Configure Language”，VSCode打开一个新的编辑窗口，加载~/Library/Application Support/Code/User/locale.json文件：

{
    // 定义 VSCode 的显示语言。
    // 请参阅 https://go.microsoft.com/fwlink/?LinkId=761051，了解支持的语言列表。
    // 要更改值需要重启 VSCode。
    "locale": "zh-cn"
}
当前语言为中文，如果我们要将其改为英文，则修改该文件中的”locale”项：

{
    // 定义 VSCode 的显示语言。
    // 请参阅 https://go.microsoft.com/fwlink/?LinkId=761051，了解支持的语言列表。
    // 要更改值需要重启 VSCode。
    "locale": "en-US"
}
保存，重启VSCode。再次启动的VSCode将会以英文界面示人了。

3、User Settings和Workspace Settings

UserSettings是一种“全局”设置，而Workspace Settings则顾名思义，是一种针对一个特定目录或project的设置。

UserSettings设置后的数据保存在~/Library/Application Support/Code下(以mac为例)，而Workspace Setting设置后的数据则保存在某个项目特定目录下的.vscode目录下。

在菜单栏，选择【Preferences -> User Settings】可以打开~/Library/Application Support/Code/User/settings.json文件。默认情况下，该文件为空。VSCode采用默认设置。如果你要个性化设置，那么可将对应的配置项copy一份到settings.json中，并赋予其新值，保存即可。新值将覆盖默认值。以字体大小为例，我们将默认的editor.fontSize 12改为10：

// Place your settings in this file to overwrite the default settings
{
    "editor.fontSize": 10,
}
保存后，可以看到窗口中所有文字的Size都变小了。

在菜单栏，选择【Preferences -> Workspace Settings】可打开当前工作目录下的.vscode的settings.json文件，其工作原理和配置方法与User Settings一样，只是生效范围仅限于该工作区范畴。

4、Color Theme

VSCode内置了主流的配色方案，比如：monokai、solarized dark/light等。F1，输入”color”搜索，选择：“Perefences: Color Theme”（在MAC上也可以用cmd+k, cmd+t打开），在下拉列表中选择你喜欢的配色Theme即可，即可生效。

四、vscode-go的使用

前面说过，和vim-go一样，vscode-go插件实现了Go编码中需要的各种功能：自动format、自动增删import、build on save、lint on save、定义跳转、原型信息快速提示、自动补全、code snippets等。另外它通过带颜色的波浪线提示代码问题（虽然有时候反应有点慢），包括语法问题、不符合idiomatic go规则的问题（比如appId这个命名，它会建议你改为appID）等。

code snippets非常好用，内置的code snippets在~/.vscode/extensions/lukehoban.Go-0.6.51/snippets/go.json中可以找到，类似这样的定义：

//~/.vscode/extensions/lukehoban.Go-0.6.51/snippets/go.json
{
        ".source.go": {
                "single import": {
                        "prefix": "im",
                        "body": "import \"${1:package}\""
                },
                "multiple imports": {
                        "prefix": "ims",
                        "body": "import (\n\t\"${1:package}\"\n)"
                },
                "single constant": {
                        "prefix": "co",
                        "body": "const ${1:name} = ${2:value}"
                },
                "multiple constants": {
                        "prefix": "cos",
                        "body": "const (\n\t${1:name} = ${2:value}\n)"
                },
                "type interface declaration": {
                        "prefix": "tyi",
                        "body": "type ${1:name} interface {\n\t$0\n}"
                },
                "type struct declaration": {
                        "prefix": "tys",
                        "body": "type ${1:name} struct {\n\t$0\n}"
                },
                "package main and main function": {
                        "prefix": "pkgm",
                        "body": "package main\n\nfunc main() {\n\t$0\n}"
                },
... ...
敲入”prefix”的值，比如”ims”，输入tab，vscode-go将为你展开为：

import (
    "package"
)
在使用vscode时遇到过一次代码自动补全“失灵”的问题。vscode-go只会提示：”PANIC,PANIC,PANIC”。经查，这个是 gocode daemon的问题，我的解决方法是：

gocode close //关闭gocode daemon
gocode -s &  //重启之。
五、小结

在诸多轻量级编辑器中，我还是比较看好vscode的，毕竟其背后有着Microsoft积淀多年的IDE产品开发经验。并且和Microsoft以往产品最大的不同就是其是开源项目。

关于Vscode的使用和奇技淫巧可以参见其官方的这篇文档“ VS Code Tips and Tricks ”。

关于Vscode的各种周边工具和资料列表，请参考 Awesome-vscode项目 。

快捷键往往是开发人员的最爱，VSCode官方制作了三个平台的VSCode的快捷键worksheet：

https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf

https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf

https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf

VSCode还在快速发展，离完善还有不小提升空间。比如：在使用过程中也发现了VSCode 窗口无响应或代码编辑错乱之情况。不过作为Go编码的一个辅助编辑器，VSCode还是完全胜任和超出预期的。

© 2016,bigwhite. 版权所有.