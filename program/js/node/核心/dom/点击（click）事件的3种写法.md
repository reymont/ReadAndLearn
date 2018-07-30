https://blog.csdn.net/h5css3_linhuai/article/details/56011582

方法一：
```html
<!DOCTYPE html>
<html>
<head>
	<title>Javascript中点击事件方法一</title>
</head>
<body>
	<button id="btn">click</button>
	<script type="text/javascript">
		var btn = document.getElementById("btn");
		btn.onclick=function(){
			alert("hello world");
		}
	</script>
</body>
</html>
```
消除事件：btn.onclick=null;

方法二：
```html
<!DOCTYPE html>
<html>
<head>
	<title>Javascript中点击事件方法二</title>
</head>
<body>
	<button id="btn">click</button>
	<script type="text/javascript">
		var btn = document.getElementById("btn");
		btn.addEventListener('click',function(){
			alert("hello wrold");
		},false)
	</script>
</body>
</html>
```
## 方法三：
```html
<!DOCTYPE html>
<html>
<head>
	<title>Javascript中点击事件方法三</title>
	<script type="text/javascript">
		function test(){
			alert("hello world");
		}
	</script>
</head>
<body>
	<button id="btn" onclick="test()">click</button>
</body>
</html>
```