

# ansible插件callbacks实现redis、mongodb输出 | 峰云就她了 http://xiaorui.cc/2014/07/20/ansible%e6%8f%92%e4%bb%b6callbacks%e5%ae%9e%e7%8e%b0redis%e3%80%81mongodb%e8%be%93%e5%87%ba/

前言：

    ansible的结果默认是输出到cli终端和日志里面的，用惯了saltsatck的returners数据回调后，也很是喜欢ansible也有，一开始不知道有这个功能，自己也简单实现了这样的功能。

我的实现方式是，在模块里面做一些输出的逻辑。当使用ansible runner api的时候，是在后面runner代码，最后加了一段往redis输出的逻辑。 这里实现数据的输出有些独特，但是只能是在模块和 api方面搞 。 如果是用playbook的话，按照我以前的思路的话，再继续改ansbile的源码。  这两天听沈灿说，ansible有个callback_plugins的功能，可以对于执行的状态做一些判断，比如，执行成功，执行失败，异步执行，异步执行失败，playbook开始，结束等等。 

我也不说复杂了，就简单说一个例子，把执行的结果，都推到redis里面，也可以暂存到sqlite数据库里面，只是这段代码我给屏蔽了，有兴趣的朋友再搞搞。对于redis里面的数据可以写一个页面展现下，专门记录错误的问题，成功的就pass掉。





#xiaorui.cc

import os
import time
import sqlite3
import redis
import json

dbname = '/tmp/setup.db'
TIME_FORMAT='%Y-%m-%d %H:%M:%S'

try:
    con = sqlite3.connect(dbname)
    cur = con.cursor()
except:
    pass

def log(host, data):

#    if type(data) == dict:
#        invocation = data.pop('invocation', None)
#        if invocation.get('module_name', None) != 'setup':
#            return
#
#    facts = data.get('ansible_facts', None)
#
#    now = time.strftime(TIME_FORMAT, time.localtime())
#
#    try:
#        # `host` is a unique index
#        cur.execute("REPLACE INTO inventory (now, host, arch, dist, distvers, sys,kernel) VALUES(?,?,?,?,?,?,?);",
#        (
#            now,
#            facts.get('ansible_hostname', None),
#            facts.get('ansible_architecture', None),
#            facts.get('ansible_distribution', None),
#            facts.get('ansible_distribution_version', None),
#            facts.get('ansible_system', None),
#            facts.get('ansible_kernel', None)
#        ))
#        con.commit()
#    except:
#        pass
#
class CallbackModule(object):
    def runner_on_ok(self, host, res):
        r = redis.Redis(host='127.0.0.1', port=6379, db=0) 
        r.set(host,str(res))

        f = open('/tmp/11','a')
        f.write(str(host))
        f.write(str(res))
        f.close()
        log(host, res)
    def runner_on_failed(self, host, res, ignore_errors=False):
        f = open('/tmp/11','a')
        f.write('\nbad\n')
        f.close()
        log(host, res)
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
#xiaorui.cc
 
import os
import time
import sqlite3
import redis
import json
 
dbname = '/tmp/setup.db'
TIME_FORMAT='%Y-%m-%d %H:%M:%S'
 
try:
    con = sqlite3.connect(dbname)
    cur = con.cursor()
except:
    pass
 
def log(host, data):
 
#    if type(data) == dict:
#        invocation = data.pop('invocation', None)
#        if invocation.get('module_name', None) != 'setup':
#            return
#
#    facts = data.get('ansible_facts', None)
#
#    now = time.strftime(TIME_FORMAT, time.localtime())
#
#    try:
#        # `host` is a unique index
#        cur.execute("REPLACE INTO inventory (now, host, arch, dist, distvers, sys,kernel) VALUES(?,?,?,?,?,?,?);",
#        (
#            now,
#            facts.get('ansible_hostname', None),
#            facts.get('ansible_architecture', None),
#            facts.get('ansible_distribution', None),
#            facts.get('ansible_distribution_version', None),
#            facts.get('ansible_system', None),
#            facts.get('ansible_kernel', None)
#        ))
#        con.commit()
#    except:
#        pass
#
class CallbackModule(object):
    def runner_on_ok(self, host, res):
        r = redis.Redis(host='127.0.0.1', port=6379, db=0) 
        r.set(host,str(res))
 
        f = open('/tmp/11','a')
        f.write(str(host))
        f.write(str(res))
        f.close()
        log(host, res)
    def runner_on_failed(self, host, res, ignore_errors=False):
        f = open('/tmp/11','a')
        f.write('\nbad\n')
        f.close()
        log(host, res)
wKiom1PLxF7RgYIpAANcxv3ltOA830.jpg




还是可以接收所有的facts数据的。

原文：http://rfyiamcool.blog.51cto.com/1030776/1440624 



wKiom1PLz6jT6hSxAAvukgGOdaA867.jpg

原文：http://rfyiamcool.blog.51cto.com/1030776/1440624 



虽然我上面的例子用了redis，sqlite数据库，其实我个人推荐用mongodb这样的文档数据库的。因为ansible主runner函数，给callbacks传递了一个叫res的变量，他本身就是一个dict对象，如果放到redis的hash，sqlite的各种字段，够你烦的了，如果直接mongo，那就简单了，直接insert ！ 欧了

wKiom1PL2CqjPJdLAAi3W-Hd6Xs379.jpg



这里在show一个邮件的callbacks代码，场景是，非常消耗时间的任务，当执行完成后，查看结果咋办？　　但是你也可以在终端继续看，既然咱们讲了callbacks_plugins,就可以把结果push到你的邮箱里面，当然只给你发错误的，有问题的。 下面的callback代码需要自己替换成自己用的邮箱、密码、smtp服务器。



#xiaorui.cc
原文：http://rfyiamcool.blog.51cto.com/1030776/1440624 
  
import smtplib
 
def mail(subject='Ansible error mail', sender='<root>', to='root', cc=None, bcc=None, body=None):
    if not body:
        body = subject
 
    smtp = smtplib.SMTP('localhost')
 
    content = 'From: %s\n' % sender
    content += 'To: %s\n' % to
    if cc:
        content += 'Cc: %s\n' % cc
    content += 'Subject: %s\n\n' % subject
    content += body
 
    addresses = to.split(',')
    if cc:
        addresses += cc.split(',')
    if bcc:
        addresses += bcc.split(',')
 
    for address in addresses:
        smtp.sendmail(sender, address, content)
 
    smtp.quit()
 
 
class CallbackModule(object):
 
    """
    This Ansible callback plugin mails errors to interested parties.
    """
 
    def runner_on_failed(self, host, res, ignore_errors=False):
        if ignore_errors:
            return
        sender = '"Ansible: %s" <root>' % host
        subject = 'Failed: %(module_name)s %(module_args)s' % res['invocation']
        body = 'The following task failed for host ' + host + ':\n\n%(module_name)s %(module_args)s\n\n' % res['invocation']
        if 'stdout' in res.keys() and res['stdout']:
            subject = res['stdout'].strip('\r\n').split('\n')[-1]
            body += 'with the following output in standard output:\n\n' + res['stdout'] + '\n\n'
        if 'stderr' in res.keys() and res['stderr']:
            subject = res['stderr'].strip('\r\n').split('\n')[-1]
            body += 'with the following output in standard error:\n\n' + res['stderr'] + '\n\n'
        if 'msg' in res.keys() and res['msg']:
            subject = res['msg'].strip('\r\n').split('\n')[0]
            body += 'with the following message:\n\n' + res['msg'] + '\n\n'
        body += 'A complete dump of the error:\n\n' + str(res)
        mail(sender=sender, subject=subject, body=body)
                   
    def runner_on_unreachable(self, host, res):
        sender = '"Ansible: %s" <root>' % host
        if isinstance(res, basestring):
            subject = 'Unreachable: %s' % res.strip('\r\n').split('\n')[-1]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + res
        else:
            subject = 'Unreachable: %s' % res['msg'].strip('\r\n').split('\n')[0]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + \
                   res['msg'] + '\n\nA complete dump of the error:\n\n' + str(res)
        mail(sender=sender, subject=subject, body=body)
 
    def runner_on_async_failed(self, host, res, jid):
        sender = '"Ansible: %s" <root>' % host
        if isinstance(res, basestring):
            subject = 'Async failure: %s' % res.strip('\r\n').split('\n')[-1]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + res
        else:
            subject = 'Async failure: %s' % res['msg'].strip('\r\n').split('\n')[0]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + \
                   res['msg'] + '\n\nA complete dump of the error:\n\n' + str(res)
        mail(sender=sender, subject=subject, body=body)
如果不想发邮件，又不想搞到数据库里面，怎么办？　那来点低端的。　　直接写入到文件里面。
官方给出一个例子，大家照着模板写就行了。


import os
import time
import json
 
TIME_FORMAT="%b %d %Y %H:%M:%S"
MSG_FORMAT="%(now)s - %(category)s - %(data)s\n\n"
 
if not os.path.exists("/var/log/ansible/hosts"):
    os.makedirs("/var/log/ansible/hosts")
 
def log(host, category, data):
    if type(data) == dict:
        if 'verbose_override' in data:
            # avoid logging extraneous data from facts
            data = 'omitted'
        else:
            data = data.copy()
            invocation = data.pop('invocation', None)
            data = json.dumps(data)
            if invocation is not None:
                data = json.dumps(invocation) + " => %s " % data
 
    path = os.path.join("/var/log/ansible/hosts", host)
    now = time.strftime(TIME_FORMAT, time.localtime())
    fd = open(path, "a")
    fd.write(MSG_FORMAT % dict(now=now, category=category, data=data))
    fd.close()
 
class CallbackModule(object):
    """
    logs playbook results, per host, in /var/log/ansible/hosts
    """
 
    def on_any(self, *args, **kwargs):
        pass
 
    def runner_on_failed(self, host, res, ignore_errors=False):
        log(host, 'FAILED', res)
 
    def runner_on_ok(self, host, res):
        log(host, 'OK', res)
 
    def runner_on_skipped(self, host, item=None):
        log(host, 'SKIPPED', '...')
 
    def runner_on_unreachable(self, host, res):
        log(host, 'UNREACHABLE', res)
 
    def runner_on_no_hosts(self):
        pass
 
    def runner_on_async_poll(self, host, res, jid, clock):
        pass
 
    def runner_on_async_ok(self, host, res, jid):
        pass
 
    def runner_on_async_failed(self, host, res, jid):
        log(host, 'ASYNC_FAILED', res)
 
    def playbook_on_start(self):
        pass
 
    def playbook_on_notify(self, host, handler):
        pass
 
    def playbook_on_no_hosts_matched(self):
        pass
 
    def playbook_on_no_hosts_remaining(self):
        pass
 
    def playbook_on_task_start(self, name, is_conditional):
        pass
 
    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        pass
 
    def playbook_on_setup(self):
        pass
 
    def playbook_on_import_for_host(self, host, imported_file):
        log(host, 'IMPORTED', imported_file)
 
    def playbook_on_not_import_for_host(self, host, missing_file):
        log(host, 'NOTIMPORTED', missing_file)
 
    def playbook_on_play_start(self, name):
        pass
 
    def playbook_on_stats(self, stats):
        pass
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162
163
164
165
166
167
168
169
170
171
#xiaorui.cc
原文：http://rfyiamcool.blog.51cto.com/1030776/1440624 
  
import smtplib
 
def mail(subject='Ansible error mail', sender='<root>', to='root', cc=None, bcc=None, body=None):
    if not body:
        body = subject
 
    smtp = smtplib.SMTP('localhost')
 
    content = 'From: %s\n' % sender
    content += 'To: %s\n' % to
    if cc:
        content += 'Cc: %s\n' % cc
    content += 'Subject: %s\n\n' % subject
    content += body
 
    addresses = to.split(',')
    if cc:
        addresses += cc.split(',')
    if bcc:
        addresses += bcc.split(',')
 
    for address in addresses:
        smtp.sendmail(sender, address, content)
 
    smtp.quit()
 
 
class CallbackModule(object):
 
    """
    This Ansible callback plugin mails errors to interested parties.
    """
 
    def runner_on_failed(self, host, res, ignore_errors=False):
        if ignore_errors:
            return
        sender = '"Ansible: %s" <root>' % host
        subject = 'Failed: %(module_name)s %(module_args)s' % res['invocation']
        body = 'The following task failed for host ' + host + ':\n\n%(module_name)s %(module_args)s\n\n' % res['invocation']
        if 'stdout' in res.keys() and res['stdout']:
            subject = res['stdout'].strip('\r\n').split('\n')[-1]
            body += 'with the following output in standard output:\n\n' + res['stdout'] + '\n\n'
        if 'stderr' in res.keys() and res['stderr']:
            subject = res['stderr'].strip('\r\n').split('\n')[-1]
            body += 'with the following output in standard error:\n\n' + res['stderr'] + '\n\n'
        if 'msg' in res.keys() and res['msg']:
            subject = res['msg'].strip('\r\n').split('\n')[0]
            body += 'with the following message:\n\n' + res['msg'] + '\n\n'
        body += 'A complete dump of the error:\n\n' + str(res)
        mail(sender=sender, subject=subject, body=body)
                   
    def runner_on_unreachable(self, host, res):
        sender = '"Ansible: %s" <root>' % host
        if isinstance(res, basestring):
            subject = 'Unreachable: %s' % res.strip('\r\n').split('\n')[-1]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + res
        else:
            subject = 'Unreachable: %s' % res['msg'].strip('\r\n').split('\n')[0]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + \
                   res['msg'] + '\n\nA complete dump of the error:\n\n' + str(res)
        mail(sender=sender, subject=subject, body=body)
 
    def runner_on_async_failed(self, host, res, jid):
        sender = '"Ansible: %s" <root>' % host
        if isinstance(res, basestring):
            subject = 'Async failure: %s' % res.strip('\r\n').split('\n')[-1]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + res
        else:
            subject = 'Async failure: %s' % res['msg'].strip('\r\n').split('\n')[0]
            body = 'An error occured for host ' + host + ' with the following message:\n\n' + \
                   res['msg'] + '\n\nA complete dump of the error:\n\n' + str(res)
        mail(sender=sender, subject=subject, body=body)
如果不想发邮件，又不想搞到数据库里面，怎么办？　那来点低端的。　　直接写入到文件里面。
官方给出一个例子，大家照着模板写就行了。
 
 
import os
import time
import json
 
TIME_FORMAT="%b %d %Y %H:%M:%S"
MSG_FORMAT="%(now)s - %(category)s - %(data)s\n\n"
 
if not os.path.exists("/var/log/ansible/hosts"):
    os.makedirs("/var/log/ansible/hosts")
 
def log(host, category, data):
    if type(data) == dict:
        if 'verbose_override' in data:
            # avoid logging extraneous data from facts
            data = 'omitted'
        else:
            data = data.copy()
            invocation = data.pop('invocation', None)
            data = json.dumps(data)
            if invocation is not None:
                data = json.dumps(invocation) + " => %s " % data
 
    path = os.path.join("/var/log/ansible/hosts", host)
    now = time.strftime(TIME_FORMAT, time.localtime())
    fd = open(path, "a")
    fd.write(MSG_FORMAT % dict(now=now, category=category, data=data))
    fd.close()
 
class CallbackModule(object):
    """
    logs playbook results, per host, in /var/log/ansible/hosts
    """
 
    def on_any(self, *args, **kwargs):
        pass
 
    def runner_on_failed(self, host, res, ignore_errors=False):
        log(host, 'FAILED', res)
 
    def runner_on_ok(self, host, res):
        log(host, 'OK', res)
 
    def runner_on_skipped(self, host, item=None):
        log(host, 'SKIPPED', '...')
 
    def runner_on_unreachable(self, host, res):
        log(host, 'UNREACHABLE', res)
 
    def runner_on_no_hosts(self):
        pass
 
    def runner_on_async_poll(self, host, res, jid, clock):
        pass
 
    def runner_on_async_ok(self, host, res, jid):
        pass
 
    def runner_on_async_failed(self, host, res, jid):
        log(host, 'ASYNC_FAILED', res)
 
    def playbook_on_start(self):
        pass
 
    def playbook_on_notify(self, host, handler):
        pass
 
    def playbook_on_no_hosts_matched(self):
        pass
 
    def playbook_on_no_hosts_remaining(self):
        pass
 
    def playbook_on_task_start(self, name, is_conditional):
        pass
 
    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        pass
 
    def playbook_on_setup(self):
        pass
 
    def playbook_on_import_for_host(self, host, imported_file):
        log(host, 'IMPORTED', imported_file)
 
    def playbook_on_not_import_for_host(self, host, missing_file):
        log(host, 'NOTIMPORTED', missing_file)
 
    def playbook_on_play_start(self, name):
        pass
 
    def playbook_on_stats(self, stats):
        pass
wKioL1PLzZbDY29sAAWL-68tvIQ014.jpg



也可以把结果以webhooks钩子的方式，做些你想做的东西。



callbacks的各种状态还是很多的，每个函数的字眼还是很好理解的。

比如：

on_any  哪都有他 ！任何的状态他触发。

runner_on_failed 失败

runner_on_ok  成功

runner_on_unreachable 网络不可达

runner_on_no_hosts 没有主机

runner_on_async_poll 任务的异步执行

playbook_on_start  playbook执行的时候

等等。。。。  自己尝试吧 ！


class CallbackModule(object):
 
 
    def on_any(self, *args, **kwargs):
        pass
 
    def runner_on_failed(self, host, res, ignore_errors=False):
        log(host, 'FAILED', res)
 
    def runner_on_ok(self, host, res):
        log(host, 'OK', res)
 
    def runner_on_skipped(self, host, item=None):
        log(host, 'SKIPPED', '...')
 
    def runner_on_unreachable(self, host, res):
        log(host, 'UNREACHABLE', res)
 
    def runner_on_no_hosts(self):
        pass
 
    def runner_on_async_poll(self, host, res, jid, clock):
        pass
 
    def runner_on_async_ok(self, host, res, jid):
        pass
 
    def runner_on_async_failed(self, host, res, jid):
        log(host, 'ASYNC_FAILED', res)
 
    def playbook_on_start(self):
        pass
 
    def playbook_on_notify(self, host, handler):
        pass
 
    def playbook_on_no_hosts_matched(self):
        pass
 
    def playbook_on_no_hosts_remaining(self):
        pass
 
    def playbook_on_task_start(self, name, is_conditional):
        pass
 
    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        pass
 
    def playbook_on_setup(self):
        pass
 
    def playbook_on_import_for_host(self, host, imported_file):
        log(host, 'IMPORTED', imported_file)
 
    def playbook_on_not_import_for_host(self, host, missing_file):
        log(host, 'NOTIMPORTED', missing_file)
 
    def playbook_on_play_start(self, name):
        pass
 
    def playbook_on_stats(self, stats):
        pass
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
class CallbackModule(object):
 
 
    def on_any(self, *args, **kwargs):
        pass
 
    def runner_on_failed(self, host, res, ignore_errors=False):
        log(host, 'FAILED', res)
 
    def runner_on_ok(self, host, res):
        log(host, 'OK', res)
 
    def runner_on_skipped(self, host, item=None):
        log(host, 'SKIPPED', '...')
 
    def runner_on_unreachable(self, host, res):
        log(host, 'UNREACHABLE', res)
 
    def runner_on_no_hosts(self):
        pass
 
    def runner_on_async_poll(self, host, res, jid, clock):
        pass
 
    def runner_on_async_ok(self, host, res, jid):
        pass
 
    def runner_on_async_failed(self, host, res, jid):
        log(host, 'ASYNC_FAILED', res)
 
    def playbook_on_start(self):
        pass
 
    def playbook_on_notify(self, host, handler):
        pass
 
    def playbook_on_no_hosts_matched(self):
        pass
 
    def playbook_on_no_hosts_remaining(self):
        pass
 
    def playbook_on_task_start(self, name, is_conditional):
        pass
 
    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        pass
 
    def playbook_on_setup(self):
        pass
 
    def playbook_on_import_for_host(self, host, imported_file):
        log(host, 'IMPORTED', imported_file)
 
    def playbook_on_not_import_for_host(self, host, missing_file):
        log(host, 'NOTIMPORTED', missing_file)
 
    def playbook_on_play_start(self, name):
        pass
 
    def playbook_on_stats(self, stats):
        pass

咱们可以简单看看ansible的callbacks源码。

规定了两个类，一个是供应ansible-playbook用的，还有一个是供应ansible，也就是cli。 根据各种的情况，调用不同的函数，首先会打到终端，再log日志，最后是自定义的callbacks的插件。 

好了，就这样了 ！！！！ 





对Python及运维开发感兴趣的朋友可以加QQ群 ： 478476595 !!! 
{ 2000人qq大群内有各厂大牛，常组织线上分享及沙龙，对高性能及分布式场景感兴趣同学欢迎加入该QQ群 } 

另外如果大家觉得文章对你有些作用！   帮忙点击广告. 一来能刺激我写博客的欲望，二来好维护云主机的费用. 
如果想赏钱，可以用微信扫描下面的二维码. 另外再次标注博客原地址  xiaorui.cc  ……   感谢！