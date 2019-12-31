https://blog.csdn.net/hewei0241/article/details/26402807

js中删除table里所有行
方法一
attAchments为table
```js
var tb = document.getElementById('attAchments');
     var rowNum=tb.rows.length;
     for (i=0;i<rowNum;i++)
     {
         tb.deleteRow(i);
         rowNum=rowNum-1;
         i=i-1;
     }
```
方法二:
removeNode(true)使用。
```html
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<title>newpage</title>
</head>
<body>
<table border="1" width="100%" id="table1">
    <tr>
        <td></td>
        <td></td>
    </tr>
    <tr>
        <td></td>
        <td></td>
    </tr>
</table>
</body>
<script>
var t=document.getElementById("table1");
alert(t.outerHTML);
//删除所有行
t.firstChild.removeNode(true)
alert(t.outerHTML);
//增加一行
t.insertRow();
alert(t.outerHTML);
</script>
</html>
```