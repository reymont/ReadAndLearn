

```js
// C:\workspace\nodejs\EasyDockerWeb\routes\containers.js
  /* GET containers. */
  router.get('/', function (req, res, next) {
    docker.listContainers({ all: true }, function (err, containers) {
      res.locals.formatName = function (str) {
        return str[0].split('/')[1];
      }
      docker.listImages(function (err, listImages) {
        res.render('containers',
          {
            containers: containers,
            images: listImages
          });
      });
    });
  });
```

C:\workspace\nodejs\EasyDockerWeb\views\containers.html
```html
<td>
    <%= formatName(container.Names) %>
</td>
```

## 参考

1. https://www.nodeapp.cn/stream.html
2. https://github.com/apocas/dockerode