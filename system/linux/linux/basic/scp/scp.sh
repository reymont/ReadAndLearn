

# 文件夹
scp -r /home/administrator/test/ root@192.168.1.100:/root/
# 端口
# 在需要指定端口时要使用-P(大写的P)，而且要紧跟在scp之后
scp -P 12349 upload_file username@server
# -v 和大多数 linux 命令中的 -v 意思一样 , 用来显示进度 . 可以用来查看连接 , 认证 , 或是配置错误 . 
