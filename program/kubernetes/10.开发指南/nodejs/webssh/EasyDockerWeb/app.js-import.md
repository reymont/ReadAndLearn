

public\js\app.js属于客户端，发请求
socket.emit('exec', id, $('#terminal').width(), $('#terminal').height());

routes\containers.js属于服务端，监听请求
socket.on('exec', function (id, w, h) {

views\include\footer.html
```html
<script src="/static/js/app.js"></script>
```

