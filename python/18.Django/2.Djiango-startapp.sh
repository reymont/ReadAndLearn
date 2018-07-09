
### 1. 创建应用
python manage.py startapp learning_logs
### 2. 激活模型
# learning_log
# settings
python manage.py makemigrations learning_logs
python manage.py migrate
### 3. django管理网站
# learning_log
python manage.py createsuperuser
# ll_admin/ll_admin
# Superuser creation skipped due to not running in a TTY. You can run manage.py createsuperuser in your project to create one manually.
# 在cmd中使用命令行 可解决
python manage.py runserver
http://127.0.0.1:8000/admin

