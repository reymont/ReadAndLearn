

* [css overflow(visible auto hidden scroll)教程 - DIVCSS5 ](http://www.divcss5.com/rumen/r414.shtml)

Overflow可以实现隐藏超出对象内容，同时也有显示与隐藏滚动条的作用，

# 参数

overflow : visible | auto | hidden | scroll
当然overflow可以单独设置X（overflow-x ）和Y（overflow-y）方向的滚动条样式其值与应用与overflow语法用法结构相同。

visible : 　不剪切内容也不添加滚动条。假如显式声明此默认值，对象将被剪切为包含对象的window或frame的大小。并且clip属性设置将失效
auto : 　此为body对象和textarea的默认值。在需要时剪切内容并添加滚动条，DIV默认情况也是这个值，但需要设置时候设置即可
hidden : 　不显示超过对象尺寸的内容
scroll : 　总是显示滚动条