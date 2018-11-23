

利用dockerize模板为容器内应用生成配置文件和环境变量 - CSDN博客
http://blog.csdn.net/liucaihong123/article/details/51945413

首先试验一下dockerize的可用性：

最近一个docker容器里面的应用启动依赖于一个配置文件cfg.json

设置模板文件cfg.template.json格式如下：

{
    "debug": true,
    "hostname": {{ default .Env.HOSTNAME "\"\"" }},
    "ip": {{ default .Env.IP "\"\"" }},
    "plugin": {
        "enabled": {{ default .Env.PLUGIN_ENABLED "false" }},
        "dir": {{ default .Env.PLUGIN_DIR "\"./plugin\"" }},
        "git": {{ default .Env.PLUGIN_GIT "\"https://github.com/open-falcon/plugin.git\"" }},
        "logs": {{ default .Env.PLUGIN_LOGS "\"./logs\"" }}
    },
}

在~/.bashrc中添加HOSTNAME，IP ，PLUGIN_ENABLED ，PLUGIN_DIR ，PLUGIN_GIT ，PLUGIN_LOGS 这几个环境变量，假如cfg.template.json在当前目录下，执行如下命令：

dockerize -template ./cfg.template.json:./cfg.json 
就会按照模板文件生成cfg.json配置文件，注意：假如~/.bashrc中没有配置PLUGIN_GIT 环境变量，则会按照模板中的默认值"https://github.com/open-falcon/plugin.git"生成配置文件。

以下是生成的配置文件cfg.json:

{

    "debug": true,
    "hostname": "node2",
    "ip": "",
    "plugin": {
        "enabled": false,
        "dir": "./plugin",
        "git": "https://github.com/open-falcon/plugin.git",
        "logs": "./logs"
    },
  }
测试成功。

以后在打包镜像的过程中，利用dockerize将模板中参数传到镜像中，具体用法参考文章：https://segmentfault.com/a/1190000000728440

转载请注明出处：http://blog.csdn.net/liucaihong123/article/details/51945413