

git 设置存储用户名与密码 - 浅水224 - 博客园 
http://www.cnblogs.com/qianshui/p/5514662.html

git 设置存储用户名与密码

git config --global user.name "myusername"
git config --global user.email "myusername@myemaildomain.com"
git config --global credential.helper cache

git: 'credential-cache' is not a git command. See 'get --help'.

windows
git config --global credential.helper winstore
git config --global credential.helper wincred
