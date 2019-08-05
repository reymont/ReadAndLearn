
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
### 4. 迁移模型Entry
python manage.py makemigrations learning_logs
python manage.py migrate
### 5. 向网站注册Entry
from __future__ import unicode_literals

from django.contrib import admin

from learning_logs.models import Topic, Entry
admin.site.register(Topic)
admin.site.register(Entry)
### 6. Django shell
python manage.py shell
>>> from learning_logs.models import Topic
>>> Topic.objects.all()
[<Topic: Chess>, <Topic: Rock Climbing>]
# 遍历
>>> topics = Topic.objects.all()
>>> for topic in topics:
... print(topic.id, topic)
# 根据id
>>> t = Topic.objects.get(id=1)
>>> t.text
# 查询关联的entry。为通过外键关系获取数据， 可使用相关模型的小写名称、 下划线和单词set
t.entry_set.all()

### 9. https://github.com/reymont/Python-Crash-Course.git (fork)