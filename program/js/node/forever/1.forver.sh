

### 1. 安装
npm install -g forever
### 2. 启动
forever -o logs/out.log -e logs/err.log start node.js
### 3. 查看是否启动
forever list
### 4. 更新文件操作
# 停止forever
forever stopall
# 替换文件后再启动
forever -o logs/out.log -e logs/err.log start node.js

### https://www.oschina.net/question/433035_171960?sort=time