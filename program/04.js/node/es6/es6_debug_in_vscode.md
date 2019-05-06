原文：[How to debug ES6 NodeJS with VSCode – katopz – Medium](https://medium.com/@katopz/how-to-debug-es6-nodejs-with-vscode-8d00bd6c4f94)

# 快速实践

先上项目：[katopz/vscode-debug-nodejs-es6](https://github.com/katopz/vscode-debug-nodejs-es6): How to debug ES6 NodeJS with VSCode

使用vscode调试es6时，会有如下错误。

    $ node --debug-brk=14397 --nolazy server.js 
    Debugger listening on [::]:14397
    /Users/katopz/git/vscode-debug-nodejs-es6/server.js:1
    (function (exports, require, module, __filename, __dirname) { import fetch from 'isomorphic-fetch';
                                                                  ^^^^^^
    SyntaxError: Unexpected token import
    ...

# 解决办法：

使用babel-register  
专业建议（Pro tips） : 你也可以使用babel-node或者其他的方式，但需要做更多的工作，因此这里仅介绍babel-register的方式.

    $ npm i -D babel-register
    $ npm i -D babel-preset-es2015

package.json

    {
      // ...
      // something else
      // ...
      "devDependencies": {
        "babel-preset-es2015": "^6.18.0",
        "babel-register": "^6.18.0"
      },
      "babel": {
        "presets": [
          "es2015"
        ],
        "sourceMaps": true,
        "retainLines": true
      }
    }

或者配置.babelrc

    {
      "presets": [
        "es2015"
      ],
      "sourceMaps": true,
      "retainLines": true
    }

注意 : 在这里统一将配置到package.json。

# 额外的配置

需要额外的配置babel，例子中已经配置

    "sourceMaps": true,
    "retainLines": true

同时在.vscode/launch.json添加

    "sourceMaps": true,

如果不添加sourceMaps，会这样：

![](https://static.oschina.net/uploads/space/2017/0711/154740_sNtw_2419022.png)

这样你就可以使用vscode开始调试了.

![](https://static.oschina.net/uploads/space/2017/0711/154635_IWxt_2419022.png)

漂亮吧?

# 最佳实践

对于生产，应该使用[这面](http://babel-handbook/user-handbook.md at master · thejameskyle/babel-handbook https://github.com/thejameskyle/babel-handbook/blob/master/translations/en/user-handbook.md#babel-register)所提到的代替方法  
请注意，这不适用于生产环境。部署这种方式编译的代码并不是好的做法。在部署之前最好提前编译。然而，这对于在本地运行调试或编写脚本是非常有效的。  
现在让我们来召唤调试吧！

# 翻译笔记

## babel-register

babel-register模块改写require命令，为它加上一个钩子。此后，每当使用require加载.js、.jsx、.es和.es6后缀名的文件，就会先用Babel进行转码。

$ npm install --save-dev babel-register  
使用时，必须首先加载babel-register。

require("babel-register");  
require("./index.js");  
然后，就不需要手动对index.js转码了。  
需要注意的是，babel-register只会对require命令加载的文件转码，而不会对当前文件转码。另外，由于它是实时转码，所以只适合在开发环境使用。

## sourceMaps & retainLines

sourceMaps: If truthy, adds a map property to returned output. If set to "inline", a comment with a sourceMappingURL directive is added to the bottom of the returned code. If set to "both" then a map property is returned as well as a source map comment appended. This does not emit sourcemap files by itself! To have sourcemaps emitted using the CLI, you must pass it the --source-maps option.

retainLines: Retain line numbers. This will lead to wacky code but is handy for scenarios where you can’t use source maps. (NOTE: This will not retain the columns)

## 参考：

*   [Babel 入门教程 - 阮一峰的网络日志](http://www.ruanyifeng.com/blog/2016/01/babel.html)
*   [API · Babel](https://babeljs.io/docs/usage/api/)
*   [在node中使用babel6的一些简单分享 - CNode技术社区](https://cnodejs.org/topic/56460e0d89b4b49902e7fbd3)