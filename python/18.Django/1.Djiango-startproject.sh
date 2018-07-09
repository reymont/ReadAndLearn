
### 1. 加入环境变量
C:\Python27;C:\Python27\Scripts
### 2. virtualenv
# 安装在用户目录
pip install virtualenv
# 安装装pyhon
# pip install --user virtualenv
### 3. 切换目录
# 在终端中切换到目录learning_log， 并像下面这样创建一个虚拟环境：
cd learning_log
virtualenv ll_env
# 命令virtualenv ll_env --python=python3 创建一个使用Python 3的虚拟环境
### 4. 激活虚拟环境
# Django仅在虚拟环境处于活动状态时才可用
ll_env/Scripts/activate
# 要停止使用虚拟环境
deactivate
### 5. 安装Django
pip install Django
### 6. 在Django中创建项目
django-admin.py startproject learning_log .
### 7. 创建SQLite数据库
python manage.py migrate
### 8. 查看项目
python manage.py runserver
http://127.0.0.1:8000/
# 如果出现错误消息“That port is already in use”（指定端口已被占用） ， 请执行命令python manage.py runserver 8001