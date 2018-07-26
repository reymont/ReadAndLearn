JSON 数组 | 菜鸟教程 http://www.runoob.com/json/js-json-arrays.html

JSON 数组
数组作为 JSON 对象
实例
[ "Google", "Runoob", "Taobao" ]
JSON 数组在中括号中书写。
JSON 中数组值必须是合法的 JSON 数据类型（字符串, 数字, 对象, 数组, 布尔值或 null）。
JavaScript 中，数组值可以是以上的 JSON 数据类型，也可以是 JavaScript 的表达式，包括函数，日期，及 undefined。
JSON 对象中的数组
对象属性的值可以是一个数组：
实例
{
"name":"网站",
"num":3,
"sites":[ "Google", "Runoob", "Taobao" ]
}
我们可以使用索引值来访问数组：
实例
x = myObj.sites[0];

尝试一下 »
循环数组
你可以使用 for-in 来访问数组：
实例
for (i in myObj.sites) {
    x += myObj.sites[i] + "<br>";
}

尝试一下 »
你也可以使用 for 循环：
实例
for (i = 0; i < myObj.sites.length; i++) {
    x += myObj.sites[i] + "<br>";
}

尝试一下 »
嵌套 JSON 对象中的数组
JSON 对象中数组可以包含另外一个数组，或者另外一个 JSON 对象：
实例
myObj = {
    "name":"网站",
    "num":3,
    "sites": [
        { "name":"Google", "info":[ "Android", "Google 搜索", "Google 翻译" ] },
        { "name":"Runoob", "info":[ "菜鸟教程", "菜鸟工具", "菜鸟微信" ] },
        { "name":"Taobao", "info":[ "淘宝", "网购" ] }
    ]
}
我们可以使用 for-in 来循环访问每个数组：
实例
for (i in myObj.sites) {
    x += "<h1>" + myObj.sites[i].name + "</h1>";
    for (j in myObj.sites[i].info) {
        x += myObj.sites[i].info[j] + "<br>";
    }
}

尝试一下 »
修改数组值
你可以使用索引值来修改数组值：
实例
myObj.sites[1] = "Github";

尝试一下 »
删除数组元素
我们可以使用 delete 关键字来删除数组元素：
实例
delete myObj.sites[1];

尝试一下 »