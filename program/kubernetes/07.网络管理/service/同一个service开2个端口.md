Kubernetes多端口容器 - OrcHome http://orchome.com/1306


作者：半兽人
链接：http://orchome.com/1306
来源：OrcHome
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

同一个service开2个端口
一般我们只有一个端口的时候，在service的yaml文件：

ports:
  - nodePort: 8482
    port: 8080
    protocol: TCP
    targetPort: 8080
而如果你想开两个端口，直接复制粘贴可不行，k8s会提示你必须要加上name。所以,如果要开多端口，要为每个port都指定一个name，如：

ports:
  - name: http
    nodePort: 8482
    port: 8080
    protocol: TCP
    targetPort: 8080