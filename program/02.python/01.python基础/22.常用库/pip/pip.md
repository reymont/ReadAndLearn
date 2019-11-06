

如何在win7下安装python包工具pip_百度经验 https://jingyan.baidu.com/article/e73e26c0d94e0524adb6a7ff.html

工具/原料
python
easy_install
在安装pip前，请确认你win系统中已经安装好了python，和easy_install工具，如果系统安装成功，easy_install在目录C:\Python27\Scripts 下面，
进入命令行，然后把目录切换到python的安装目录下的Script文件夹下，运行 easy_inatall pip
如何在win7下安装python包工具pip
pip安装成功后，在cmd下执行pip，将会有如下提示.
如何在win7下安装python包工具pip
安装pip前，系统要已经安装完成python和easy_install，并且设置了环境变量。

### centos
yum -y install python-pip


# 1. 查看版本
pip show django

pip install --upgrade pip

# 2. 指定版本

pip install applicationName==version
pip install markdown==3.1