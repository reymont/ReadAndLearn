
# https://o-my-chenjian.com/2017/04/26/Create-The-File-Of-Kubeconfig-For-K8s/
# 生成Token文件
Kubelet在首次启动时，会向kube-apiserver发送TLS Bootstrapping请求。如果kube-apiserver验证其与自己的token.csv一致，则为kubelete生成CA与key。

# 生成Token文件
cat > token.csv <<EOF 
2dc1235a021972ca7d9d486795e57369,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF
cp token.csv /etc/kubernetes/
# 生成kubectl的kubeconfig文件
# 设置集群参数
ln -s /usr/bin/kubectl /usr/local/bin/kubectl
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=172.20.62.42

# 设置客户端认证参数
kubectl config set-credentials admin \
--client-certificate=/etc/kubernetes/ssl/admin.pem \
--embed-certs=true \
--client-key=/etc/kubernetes/ssl/admin-key.pem
# 设置上下文参数
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=admin
# 设置默认上下文
kubectl config use-context kubernetes
# admin.pem证书的OU字段值为system:masters，kube-apiserver预定义的RoleBinding cluster-admin 将 Group system:masters 与 Role cluster-admin 绑定，该Role授予了调用kube-apiserver相关API的权限
# 生成的kubeconfig被保存到~/.kube/config文件
ls ~/.kube/
# 生成kubelet的bootstrapping kubeconfig文件
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=172.20.62.42 \
--kubeconfig=bootstrap.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
--token=2dc1235a021972ca7d9d486795e57369 \
--kubeconfig=bootstrap.kubeconfig
# 设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=bootstrap.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
## --embed-certs为true时表示将certificate-authority证书写入到生成的bootstrap.kubeconfig文件中
## 设置kubelet客户端认证参数时没有指定秘钥和证书，后续由kube-apiserver自动生成；
## 生成的bootstrap.kubeconfig文件会在当前文件路径下
## 生成kube-proxy的kubeconfig文件
# 设置集群参数
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=172.20.62.42 \
--kubeconfig=kube-proxy.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
--client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
--client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig
# 设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
# --embed-cert 都为 true，这会将certificate-authority、client-certificate和client-key指向的证书文件内容写入到生成的kube-proxy.kubeconfig文件中
# kube-proxy.pem证书中CN为system:kube-proxy，kube-apiserver预定义的 RoleBinding cluster-admin将User system:kube-proxy与Role system:node-proxier绑定，该Role授予了调用kube-apiserver Proxy相关API的权限
# 将kubeconfig文件拷贝至Node上
# 操作服务器IP：
# 将生成的两个kubeconfig文件拷贝到所有的Node的/etc/kubernetes/
cp bootstrap.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/