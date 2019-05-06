http://www.w3school.com.cn/jsref/met_table_insertrow.asp

定义和用法
insertRow() 方法用于在表格中的指定位置插入一个新行。

语法
tableObject.insertRow(index)
返回值
返回一个 TableRow，表示新插入的行。

说明
该方法创建一个新的 TableRow 对象，表示一个新的 <tr> 标记，并把它插入表中的指定位置。

新行将被插入 index 所在行之前。若 index 等于表中的行数，则新行将被附加到表的末尾。

如果表是空的，则新行将被插入到一个新的 <tbody> 段，该段自身会被插入表中。

抛出
若参数 index 小于 0 或大于等于表中的行数，该方法将抛出代码为 INDEX_SIZE_ERR 的 DOMException 异常。

提示和注释
提示：可以用 TableRow.insertCell() 方法给新创建的行添加内容。

```js
// 最后一行插入
TableRow.insertCell(-1)
```

实例
下面的例子在表格的开头插入一个新行：
```html
<html>
<head>
<script type="text/javascript">
function insRow()
  {
  document.getElementById('myTable').insertRow(0)
  }
</script>
</head>

<body>
<table id="myTable" border="1">
<tr>
<td>Row1 cell1</td>
<td>Row1 cell2</td>
</tr>
<tr>
<td>Row2 cell1</td>
<td>Row2 cell2</td>
</tr>
</table>
<br />
<input type="button" onclick="insRow()"
value="Insert new row">

</body>
</html>
```
TIY
向表格添加新行 - 然后向其添加内容