

* [ansible 直接执行系统命令 碰到了awk中的$ - CSDN博客 ](http://blog.csdn.net/vbaspdelphi/article/details/69947316)

```sh
# 不可以。会返回整行ps后的结果，而不只是打印pid
ansible all -m raw -a "ps aux | grep xx | awk '{print $2}' "

# 可以
ansible all -m raw -a "ps aux | grep xx | awk '{print \$2}' "

# 不可以
ansible all -m raw -a 'ps aux | grep xx | awk "{print \$2}" '

# 不可以
ansible all -m raw -a 'ps aux | grep xx | awk \'{print \$2}\' '
```