https://www.cnblogs.com/feiyuhuo/p/5097385.html

document.ready和onload的区别——JavaScript文档加载完成事件
页面加载完成有两种事件：

一是ready，表示文档结构已经加载完成（不包含图片等非文字媒体文件）；

二是onload，指示页面包含图片等文件在内的所有元素都加载完成。

 

## 1、Dom Ready

使用jq时一般都是这么开始写脚本的：

$(function(){ 
      // do something 
});
例如：

$(function() {
     $("a").click(function() {
           alert("Hello world!");
      });
})
这个例子就是给所有的a标签绑定了一个click事件。即当所有链接被鼠标单击的时候，都执行 alert("Hello World!");
也就是说页面加载时绑定，真正该触发时触发。
其实这个就是jq ready()的简写，它等价于：

复制代码
$(document).ready(function(){
     //do something
})
//或者下面这个方法，jQuer的默认参数是：“document”；
$().ready(function(){
    //do something
})
复制代码
这个就是jq ready()的方法就是Dom Ready，他的作用或者意义就是:在DOM加载完成后就可以可以对DOM进行操作。
一般情况一个页面响应加载的顺序是，域名解析-加载html-加载js和css-加载图片等其他信息。
那么Dom Ready应该在“加载js和css”和“加载图片等其他信息”之间，就可以操作Dom了。

 

## 2、Dom Load

用原生的js的时候我们通常用onload时间来做一些事情，比如： 

```js
window.onload=function(){
      //do something
}
//或者经常用到的图片
document.getElementById("imgID").onload=function(){
     //do something
}
```
复制代码
这种就是Dom Load，他的作用或者意义就是：在document文档加载完成后就可以对DOM进行操作，document文档包括了加载图片等其他信息。
那么Dom Load就是在页面响应加载的顺序中的“加载图片等其他信息”之后，就可以操作Dom了。

 

最后附上一段在所有DOM元素加载之前执行的jQuery代码。

<script type="text/javascript">
(function() {
            alert("DOM还没加载哦!");
        })(jQuery)
</script>