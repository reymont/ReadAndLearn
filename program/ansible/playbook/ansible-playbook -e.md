

* [《Ansible权威指南》笔记（4）——Playbook - 沄持的学习记录 - 博客园 ](http://www.cnblogs.com/maxgongzuo/p/6237594.html)

4、ansible-playbook
    -i    指定inventory文件
    -v    详细输出，-vvv更详细，-vvvv更更详细
    -f    并发数
    -e    定义Playbook中使用的变量，格式"key=value,key=value"
    --remote-user    #远程用户
    --ask-pass    #远程用户密码
    --sudo    #使用sudo
    --sudo-user    #sudo的用户，默认root
    --ask-sudo-pass    #sudo密码

扩展：
(1)handlers：见test1
(2)environment：为某个play设置单独的环境变量，例子见P94-95
(3)delegate_to：任务委派
例：- name: 123
        shell: "echo $PATH>/test/1"
        delegate_to: 192.168.2.30
把shell命令委派给192.168.2.30节点执行，其他hosts中指定的节点不执行。
(4)register：注册变量
将操作结果，包括stdout和stderr，保存到变量中，再根据变量的内容决定下一步，这个保存操作结果的变量就是注册变量。
例：- shell: ***
        register: result
使用result.stdout和result.stderr读取执行结果的标准输出和标准错误。
(5)vars_prompt: 交互式提示
例：
```yaml
---
- hosts: all
  vars_prompt:
  - name: share_user
    prompt: "username?"
  - name: share_pass
    prompt: "password"
    private: yes
```
常用选项：
private: yes    #用户输入不可见
default    #设置默认值
confirm: yes    #要求输入两次