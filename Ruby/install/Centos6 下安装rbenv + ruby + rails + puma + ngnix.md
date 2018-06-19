

Centos6 下安装rbenv + ruby + rails + puma + ngnix · Racksam http://www.racksam.com/2016/03/01/install-rbenv-ruby-rails-nginx-puma-on-centos6/


Centos6 下安装rbenv + ruby + rails + puma + ngnix
 2016-03-01 · 1142 WORDS · 3 MINUTE READ  RUBY  RAILS · LINUX · PUMA · NGINX
Rails项目在生产环境上线时，可以选择的ruby服务器比较多，例如：Rainbows、Unicorn、Passenger、Puma。其中Puma是近年来口碑比较不错的一个。

这里总结整理CentOS6环境下安装配置rbenv、Ruby 2.3、rails 4、puma以及ngnix的集成环境。

一、系统安装所需的yum包

root超级管理员终端下：

# yum update -y
# yum -y install git gcc gcc-c++ make zlib zlib-devel openssl openssl-devel  epel-release
# yum -y install redhat-lsb-core readline-devel
# yum -y install sqlite sqlite-devel
# yum -y install nodejs npm --enablerepo=epel
# yum -y install nginx
安装node.js (rails项目中会用到V8 js引擎)

二、创建普通账号deploy

出于安全原因，一般web应用都不会建议使用root启动程序。这里以创建一个名字为deploy的普通账号为例。

root超级管理员终端下：

创建账号并设置密码

# adduser deploy
# passwd deploy
编辑deploy账号的sudo权限

输入命令：

# visudo
在root ALL=(ALL) ALL一行的下面，添加下面一行并保存

deploy    ALL=(ALL)       ALL
三、在系统普通账号的终端环境下进行ruby的安装

以普通账号deploy身份登录ssh, 例如ssh deploy@yourhost，在该用户的目录下进行下面的安装。

安装rbenv

$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
增加该用户的环境配置

$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
重新加载环境配置参数并确认

$ exec $SHELL -l
$ rbenv --version
安装ruby-build

$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
检查ruby的可以安装的最新版本(目前主流版本是2.2以上版本，建议安装最新的稳定版)

$ rbenv install --list
安装ruby最新版本(编译时间比较长，取决于服务器的性能)

$ rbenv install -v 2.3.1
确认安装的ruby版本

$ rbenv versions
设置当前环境默认Ruby版本

$ rbenv global 2.3.1
四、安装配置bundle、rails

设置gem为默认不安装文档

在当前用户目录下创建文件$ vi .gemrc，存入以下内容：

gem: --no-ri --no-rdoc
安装bundle

$ gem install bundle
安装rails

$ gem install rails
五、配置rails项目

这里创建一个demo_rails作为样例来做说明。

$ rails new demo_rails
初始化rails项目

dotenv-rails用来方便管理rails所需要的各种环境变量参数

$ cd demo_rails
$ vi Gemfiles
在Gemfiles文件中，增加puma, dotenv-rails

gem 'puma'
gem 'dotenv-rails'
执行bundle install

$ bundle install
生成secret

$ bundle exec rake secret
将生成的SECRET_KEY_BASE按照以下格式存入项目demo_rails的根目录下.env文件中

SECRET_KEY_BASE="生成的key"
六、配置puma启动脚本

参照我整理的https://github.com/racksam/puma-jungle-centos脚本，设置puma的Linux服务启动脚本以及nginx配置。

七、补充说明

puma作者提供的jungle脚本是一个辅助小工具，并非是运行puma项目所必须使用的。用户完全可以针对单个puma项目自行编写一个Linux服务启动脚本。