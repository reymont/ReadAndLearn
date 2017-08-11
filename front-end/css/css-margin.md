



# margin

* [CSS中margin和padding的区别 - 开心学习 ](http://www.studyofnet.com/news/35.html)


1、语法结构
（1）margin-left:10px; 左外边距
（2）margin-right:10px; 右外边距
（3）margin-top:10px; 上外边距
（4）margin-bottom:10px; 下外边距
（5）margin:10px; 四边统一外边距
（6）margin:10px 20px; 上下、左右外边距
（7）margin:10px 20px 30px; 上、左右、下外边距
（8）margin:10px 20px 30px 40px; 上、右、下、左外边距

2、可能取的值
（1）length  规定具体单位记的外边距长度
（2）%       基于父元素的宽度的外边距的长度
（3）auto    浏览器计算外边距
（4）inherit 规定应该从父元素继承外边距

3、浏览器兼容问题
（1）所有浏览器都支持margin属性
（2）任何版本IE都不支持属性值“inherit”

# DIV间距设置
 
* [DIV间距设置 - DIVCSS5 ](http://www.divcss5.com/jiqiao/j231.shtml)

## 一、消除上下结构距离

DIV之间距离
让两个上下结构DIV块距离为零，通常新手在制作DIV CSS页面的时候，不会考虑到初始化CSS属性，这样各标签属性默认的CSS属性将会造成错位、兼容等问题。
如上下结构的2个box DIV块，中间有一定间距无法消除

## 二、清除DIV间距解决方法

在CSS里设置DIV标签各属性参数为0
```css
div{margin:0;border:0;padding:0;}
```
这里就设置了DIV标签CSS属性相当于初始化了DIV标签CSS属性，这里设置margin外边距为0；边框border属性为0和内补白也为0；这样相当于就初始化了DIV盒子之间距各属性距离为0，这样就不会造成DIV直接有一定的距离。
当然推荐在制作开发DIV CSS的时候最好将网页CSS属性、常用网页标签初始化一下。
CSS初始化技巧地址：http://www.divcss5.com/template/m17.shtml

## 三、设置DIV盒子之间间距

* [HTML <!--...--> 注释 、CSS/JS //注释 和 /*.....*/ 注释 - 水墨墨心 - 博客园 ](http://www.cnblogs.com/iceflorence/p/5815409.html)

以上是使用CSS清除盒子之间距离。接下来为大家介绍设置盒子之间间距。
使用CSS样式单词为margin（可进入CSS margin教程了解详细使用方法）。
```css
/*1、设置对象的上下间距*/
.divcss5-a{margin:10px 0} 
/*设置“divcss5-a”对象上下间距为10px,左右为0*/
/*2、设置对象左右距离*/
.divcss5-b{margin:0 8px} 
/*设置“divcss5-b”对象上下间距为0,左右为8px*/
/*3、设置DIV盒子与上方相邻间距*/
.divcss5-c{margin-top:10px} 
/*设置“divcss5-c”对象与上方相邻间距为10px*/
/*4、设置DIV盒子与下方相邻距离*/
.divcss5-d{margin-bottom:10px} 
/*设置“divcss5-d”对象与下方相邻间距为10px*/
/*5、设置DIV盒子与左方相邻间距*/
.divcss5-e{margin-left:9px} 
/*设置“divcss5-e”对象与左侧方相邻间距为9px*/
/*6、设置盒子与右方相邻距离*/
.divcss5-f{margin-right:12px} 
/*设置“divcss5-f”对象与右方相邻间距为12px*/
```
以上我们为了方便介绍margin设置对象外间距，将对象分别CSS命名为".divcss5-a"至“.divcss5-f”,实际使用时候更加需求命名。

## 四、让左右结构内容之间有一定间距距离

CSS案例图-DIV之间距离
如上图，左右结构内容之间一定距离设置技巧
解决方法与技巧：
一般我们使用float 浮动属性（float:left（局左）、float:right（居右））来解决此问题。这样的布局一般总的宽度一定，只需左、右内容DIV宽度设置小于总宽度即可实现，注意的是宽度计算一定是包括自己设置宽度+边框宽度+padding宽度+margin宽度组成。
提示：在DIV CSS制作中很多时候需要计算的如这样的布局。
 
实例图：
DIV+CSS设置内容之间间距设置
实现以上效果，提示总宽度为200px,而左右布局都有边框并中间间隔一定距离，这里为了样式所以距离设置比较大。
CSS代码：
```css
.div-c{width:200px;} 
.div-a{ float:left; width:50px; border:1px solid #999; height:60px;} 
.div-b{ float:right; width:120px; border:1px solid #999; height:60px;} 
```
Html代码：
```html
<div class="div-c"> 
<div class="div-a"></div> 
<div class="div-b"></div> 
</div> 
```
完整DIV+CSS代码：
```html
<!DOCTYPE html> 
<html> 
<head> 
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" /> 
<title>DIVCSS5案例</title> 
<!-- www.divcss5.com --> 
<style type="text/css"> 
.div-c{width:200px;} 
.div-a{ float:left; width:50px; border:1px solid #999; height:60px;} 
.div-b{ float:right; width:120px; border:1px solid #999; height:60px;} 
</style> 
</head> 
<body> 
<div class="div-c"> 
<div class="div-a"></div> 
<div class="div-b"></div> 
</div> 
</body> 
</html> 
```
说明：
1、实现设置总宽度为200px的(div-c)，左右DIV使用了float:left左浮动（局左）和float:right右浮动（局右），分别设置边框和宽度
2、这里设置左右DIV块(即div-a和div-b)总宽度+边框小于总宽度(即div-c对象宽度)
## 五、总结

设置DIV之间距离无论对象之间有一定距离还是没有距离，我们都需要CSS初始化，并且有距离地方还需要计算宽度，遵循这条死定律 设置宽度之和+边框(border)+margin+padding小于等于总宽度，不然会造成左右结构布局错位、其他比较的错误或有差异。
如有疑问请到DIVCSS5的CSS论坛讨论区发表您的问题我们将第一时间为你解答。
