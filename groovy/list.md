Groovy集合(list) - CSDN博客 https://blog.csdn.net/dora_310/article/details/52863422

声明list

list = [1,2,3]
list = (1..3).toList()  //range转换为list

assert list == [1,2,3]
assert list[1] == 2
assert list instanceof java.util.List
list[1] = 12
assert list == [1,12,3]
longList = (0..100)
assert longList[22] == 22
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
list操作符

下标操作符


/** 
    GDK使用range 和 collection作为参数重载了getAt()方法，这样就可以使用范围和索引的集合访问list
*/

list = [1,2,3,4]

assert list[0..2] == [1,2,3]    //使用range访问list
assert list[0,2] ==[1,3]    //使用集合访问list

list[0..2] = ['x','y','z']
assert list == ['x','y','z',4]

//当范围作为下标时，数量不一定要相等，当指定的列表值小于或者为空时，列表收缩
//当指定的列表值更大时，列表增长

list = [1,2,3,4]
list[1..2] = []
assert list == [3,4] 

list = [1,2,3,4]
list[1..1] = [1,2]
assert list == [1,1,2,3,4]

//list可以通过负数进行索引
//-1表示最后一个。-2表示倒数第二个，以此类推

list = (0..3).toList()
assert list[-1] == 3

 //当范围反向时，结果列表也是反向的
assert list[3..0] == [3,2,1,0]    

//正负数可以一起使用 下式可以去掉开头和最后的元素
assert list[1..-2] == [1,2]
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
增删list中的元素

//+ plus方法
list = []
list += 1        //plus(Object)
list += [2,3]        //plus(Collection)
assert list == [1,2,3]
list += (4..5) 
assert list == [1,2,3,4,5]

//<< leftShift()方法
list << 6 <<7        //leftShift(Object)
assert list == [1,2,3,4,5,6,7]
list << [8,9]
assert list == [1,2,3,4,5,6,7,[8,9]]
list = [1,2,3]
list << (4..5)  //4..5 字符串
assert list == [1,2,3,4..5]

//- minus()方法
list = [1,2,3,4,5,6]
assert list -= [5,6] == [1,2,3,4]  
assert list -= （3..4）   == [1,2]

assert list*2 == [1,2,1,2]         //multiply(Object)
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
list方法


//add()类似于<<，但返回布尔值
list = [1,2,3]
list.add(4)
assert list == [1,2,3,4]
list = [1,2,3]
list.add(1,4)
assert list == [1,4,2,3]    //在给定索引处插入新值
list = [1,2,3]
list.add([4,5])
assert list == [1,2,3,[4,5]]
list = [1,2,3]
list.add((1..2))
assert list == [1,2,3,1..2]

//addAll()类似于+，返回布尔值。
list = [1,2,3]
list.addAll([4,5])
assert list == [1,2,3,4,5]
list = [1,2,3]
list.addAll((4..5))
assert list == [1,2,3,4,5]

//get()  getAt()
assert [1,2,3].get(1) == 2
assert [1,2,3].getAt([1,2]) == [2,3]    //返回指定索引段的新列表
assert [1,2,3].getAt((0..1)) == [1,2]

assert  [].isEmpty()    //判断列表是否为空
assert [1,2,3].intersect([2,3]) == [2,3]    //取交集，参数只能为列表
assert [1,2,3,4].disjoint([1])    //判断是否有交集 有则返回false；
assert [1,2,[3,4]].flatten() == [1,2,3,4]   //打开嵌套的列表
assert [1,2,1,3].unique() == [1,2,3]    //去重
assert new HashSet([1,2,3,1,1,1]).toList() == [1,2,3]    //去重
assert [1,2,3,4].reverse() == [4,3,2,1]    //反转
assert [1,5,3,7].sort() == [1,3,5,7]    //升序
//对map组成的list进行排序
def list = [[a:11],[a:3],[a:5]]
assert list.sort{a,b-> return (a.a).compareTo(b.a)} == [[a:3], [a:5], [a:11]]
assert [1,5,3,7].sort{a,b -> b<=>a} == [7,5,3,1]   //降序
assert [1,2,3,1,1].count(1) == 3    //计算包含元素的个数
assert list.join('-') == '1-2-3'    //把所有的元素用给定字符串连接
assert list.join('') == '123'

[1,2,3,1,1,1].sum()    //求和
[1,2,3,1,1,1].max()    //求最大值
[1,2,3,1,1,1].min()    //求最小值

//包含 contains()

assert [1,2].contains(1)

//every() 所有的element都满足条件才返回true，否则返回false
assert list.every{it -> it<5}
//any() 只要存在一个满足条件的element就返回true，否则返回false
assert list.any{it -> it>2}

//像堆栈(stack)一样使用 push操作由<<代替 返回被删除的值
assert [1,2,3].pop()
assert [1,2,3].push(4)  //返回布尔值

//通过下标删除元素 返回被删除的值
assert [1,2,3,4].remove(2) == [1,2,4] 
//通过值删除符合条件的一个元素   返回布尔值
assert [1,'2',3,4].remove('2')   
assert [1,'2',3,1,1,1].removeAll(['2',3])    //删除所有符合条件的元素

//grep() 符合条件的element会被提取出来，形成一个list
def list = ['a', 'ab', 'abc']
assert list.grep { elem -> elem.length()<3} == ['a','ab']   //条件以闭包形式传入
assert ["ab"] == list.grep(~/../)  //条件以regex形式传入
assert ["a","ab"] == list.grep(['a', 'cde', 'ab'])  //条件以列表形式传入

//each() 遍历list
store = '' 
[1,2,3].each{it -> store += it}
assert store == '123'

//eachWithIndex() 带index的each
def list = []
['a', 'b', 'c'].eachWithIndex { elem, i ->list << "${elem}${i}"}
assert list == ["a0","b1","c2"]

//find()  findAll()返回符合条件的所有元素,
def list = [1, 2, 3, 4]
assert list.find{it -> it%2 ==0} ==2 //返回符合条件的一个元素
assert list.findAll{it -> it%2 ==0} == [2,4]
assert [1,2,3,4].findAll{it>2?it*2:null} == [3,4]   //但不能改变元素

//collect() 对集合每个元素进行运算后,得到一个新集合
def list = [1, 2, 3, 4]
assert [2,4,6,8] == list.collect{it*2}
assert [1,2,3].collect{if(it > 1){"a"}} ==   [null, 'a','a']    //返回每个元素,即使没有指定值.
assert [1,2,2,3].collect(new HashSet()){it*2}  == [2,4,6] as Set    //指定集合的类型

//findResults() 使用提供的闭包迭代Iterable变换项，并收集任何非空结果
 assert  [1,2,3].findResults { it > 1 ? "Found $it" : null } == ["Found 2", "Found 3"]

//collectEntries() 对list的每一个元素进行一定格式的转换,返回map.可以指定初始值.
assert [1,10,100,1000].collectEntries{[it,it.toString().size()]}  ==  [1:1, 10:2, 100:3, 1000:4] 
assert [1,10,100,1000].collectEntries{if(it>11){[it,it.toString().size()]}else{[it.toString().size(),it] }} == [1:1, 2:10, 100:3, 1000:4]   //必须返回每一个元素
 assert  [1,10,100,1000].collectEntries([11:1]){[it,it.toString().size()]}   ==   [11:1, 1:1, 10:2, 100:3, 1000:4] //可以指定初始值.

//groupBy() 对collection中的element按给定条件进行分组
def list = ['a', 'b', 'abc', 'ab', 'c', 'bc']
assert [1:["a","b","c"],3:["abc"],2:["ab","bc"]] == list.groupBy { elem ->
    elem.length()
}

//inject()方法遍历集合，第一次将传递的值和集合元素传给闭包，将处理结果作为传递的值，和下一个集合元素传给闭包，依此类推
result = list.inject(5){a,b -> a+=b}
assert result == 5 + 1+2+3

//transpose()方法实际上就是数学中矩阵的转置，简单的来说就是行和列的交换。如果List的长度不一，则取最短的长度
def list41 = [1, 1, 1]  
def list51 = [2, 2]  
assert [[1, 2], [1, 2]] == [list41, list51].transpose()
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
tokenize() vs split()


//1.split()返回string[]， tokenize()返回list
//2.tokenize()忽略空字符串

String testString = 'hello brother'
assert testString.split() instanceof String[]
assert ['hello','brother']==testString.split() 
assert['he','','o brother']==testString.split('l')

assert testString.tokenize() instanceof List
assert ['hello','brother']==testString.tokenize() 
assert ['he','o brother']==testString.tokenize('l')

//3.tokenize()使用字符串内的所有字符

String  testString1='hello world'
assert ['hel',' world']==testString1.split('lo')
assert ['he',' w','r','d']==testString1.tokenize('lo')

//4.split()可以使用正则表达式
String testString2='hello world 123 herload'
assert['hello world ',' herload']==testString2.split(/\d{3}/)
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
集合应用

//    根据list内的map数组元素的元素有条件的去重,对name进行去重，age尽量不为空

def list =  [['name':"zhangsan",'age':null],['name':"zhangsan",'age':23],
['name':"lisi",'age':null],['name':"lisi",'age':20],
['name':"lisi",'age':null],['name':"wangwu",'age':null]]
def ref = [];

list.each{
    if(it.name in ref['name']){
       name =it.name;
       age  = it.age;
       ref.each{
            if(it.name == name && it.age == null){
                ref -= ["name":it.name,"age":it.age]
                ref += ["name":name,"age":age]           
            }
        }
    }else{
        ref += ["name":it.name,"age":it.age]
    }
}
assert ref == [[name:zhangsan, age:23], [name:lisi, age:20], [name:wangwu, age:null]]
