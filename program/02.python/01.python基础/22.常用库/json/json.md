JSON(JavaScript Object Notation, JS 对象标记) 是一种轻量级的数据交换格式。JSON的数据格式其实就是python里面的字典格式，里面可以包含方括号括起来的数组，也就是python里面的列表。

在python中，有专门处理json格式的模块—— json 和 picle模块

  Json   模块提供了四个方法： dumps、dump、loads、load

pickle 模块也提供了四个功能：dumps、dump、loads、load
 
一. dumps 和 dump:
 dumps和dump   序列化方法
       dumps只完成了序列化为str，
       dump必须传文件描述符，将序列化的str保存到文件中
 
查看源码：
def dumps(obj, skipkeys=False, ensure_ascii=True, check_circular=True,
        allow_nan=True, cls=None, indent=None, separators=None,
        default=None, sort_keys=False, **kw):
    # Serialize ``obj`` to a JSON formatted ``str``.
    # 序列号 “obj” 数据类型 转换为 JSON格式的字符串 
def dump(obj, fp, skipkeys=False, ensure_ascii=True, check_circular=True,
        allow_nan=True, cls=None, indent=None, separators=None,
        default=None, sort_keys=False, **kw):
    """Serialize ``obj`` as a JSON formatted stream to ``fp`` (a
    ``.write()``-supporting file-like object).
     我理解为两个动作，一个动作是将”obj“转换为JSON格式的字符串，还有一个动作是将字符串写入到文件中，也就是说文件描述符fp是必须要的参数 """
 

示例代码：

复制代码
>>> import json
>>> json.dumps([])    # dumps可以格式化所有的基本数据类型为字符串
'[]'
>>> json.dumps(1)    # 数字
'1'
>>> json.dumps('1')   # 字符串
'"1"'
>>> dict = {"name":"Tom", "age":23}  
>>> json.dumps(dict)     # 字典
'{"name": "Tom", "age": 23}'
复制代码
a = {"name":"Tom", "age":23}
with open("test.json", "w", encoding='utf-8') as f:
    # indent 超级好用，格式化保存字典，默认为None，小于0为零个空格
    f.write(json.dumps(a, indent=4))
    # json.dump(a,f,indent=4)   # 和上面的效果一样
保存的文件效果：



 

二. loads 和 load 

loads和load  反序列化方法

       loads 只完成了反序列化，
       load 只接收文件描述符，完成了读取文件和反序列化
 

 查看源码：

def loads(s, encoding=None, cls=None, object_hook=None, parse_float=None, parse_int=None, parse_constant=None, object_pairs_hook=None, **kw):
    """Deserialize ``s`` (a ``str`` instance containing a JSON document) to a Python object.
       将包含str类型的JSON文档反序列化为一个python对象"""
def load(fp, cls=None, object_hook=None, parse_float=None, parse_int=None, parse_constant=None, object_pairs_hook=None, **kw):
    """Deserialize ``fp`` (a ``.read()``-supporting file-like object containing a JSON document) to a Python object.
        将一个包含JSON格式数据的可读文件饭序列化为一个python对象"""
 

实例：

>>> json.loads('{"name":"Tom", "age":23}')
{'age': 23, 'name': 'Tom'}
复制代码
import json
with open("test.json", "r", encoding='utf-8') as f:
    aa = json.loads(f.read())
    f.seek(0)
    bb = json.load(f)    # 与 json.loads(f.read())
print(aa)
print(bb)

# 输出：
{'name': 'Tom', 'age': 23}
{'name': 'Tom', 'age': 23}
复制代码
三. json 和 picle 模块

 json模块和picle模块都有  dumps、dump、loads、load四种方法，而且用法一样。

不用的是json模块序列化出来的是通用格式，其它编程语言都认识，就是普通的字符串，

而picle模块序列化出来的只有python可以认识，其他编程语言不认识的，表现为乱码

不过picle可以序列化函数，但是其他文件想用该函数，在该文件中需要有该文件的定义（定义和参数必须相同，内容可以不同）

四. python对象（obj） 与json对象的对应关系

复制代码
    +-------------------+---------------+
    | Python            | JSON          |
    +===================+===============+
    | dict              | object        |
    +-------------------+---------------+
    | list, tuple       | array         |
    +-------------------+---------------+
    | str               | string        |
    +-------------------+---------------+
    | int, float        | number        |
    +-------------------+---------------+
    | True              | true          |
    +-------------------+---------------+
    | False             | false         |
    +-------------------+---------------+
    | None              | null          |
    +-------------------+---------------+
复制代码
 

 五. 总结

 1. json序列化方法：

          dumps：无文件操作            dump：序列化+写入文件

  2. json反序列化方法：

          loads：无文件操作              load： 读文件+反序列化

  3. json模块序列化的数据 更通用

      picle模块序列化的数据 仅python可用，但功能强大，可以序列号函数

  4. json模块可以序列化和反序列化的  数据类型 见  python对象（obj） 与json对象的对应关系表

  5. 格式化写入文件利用  indent = 4 


## 参考

1. https://www.cnblogs.com/tjuyuan/p/6795860.html