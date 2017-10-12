

# 生成kubelet.conf

gen.sh/gen_kube_config

```sh
function gen_kube_config() {
  KUBE_APISERVER="https://$MASTER_ADDR:6443"
  # BOOTSTRAP_TOKEN="$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')"
  BOOTSTRAP_TOKEN="$(echo $MASTER_ADDR|md5sum|cut -f 1 -d ' ')"
  echo "BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN"

  echo "$BOOTSTRAP_TOKEN,kubelet-bootstrap,10001,\"system:kubelet-bootstrap\"" > token.csv
  echo "123456,admin,admin" > user.csv

  sudo mkdir -p /etc/kubernetes/ssl
  sudo cp -f ca.pem /etc/kubernetes/ssl/
  kubectl config set-cluster kubernetes \
      --certificate-authority=/etc/kubernetes/ssl/ca.pem \
      --embed-certs=true \
      --server=${KUBE_APISERVER} \
      --kubeconfig=kubelet.conf

  kubectl config set-credentials kubelet-bootstrap \
      --token=${BOOTSTRAP_TOKEN} \
      --kubeconfig=kubelet.conf

  kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=kubelet.conf

  kubectl config use-context default --kubeconfig=kubelet.conf
}
```

# 阅读



## 配置远程工具访问kubernetes集群

* [配置远程工具访问kubernetes集群 - 沈首二 - CSDN博客 ](http://blog.csdn.net/shenshouer/article/details/52960364)

执行如下命令，将在生成$HOME/.kube/config文件。每次使用kubectl时，未指定--kubeconfig将默认使用此配置文件。

```sh
# 配置一个名为default的集群，并指定服务地址与根证书
kubectl config set-cluster default --server=https://172.17.4.101:443 --certificate-authority=${PWD}/ssl/ca.pem
# 设置一个管理用户为admin，并配置访问证书
kubectl config set-credentials admin --certificate-authority=${PWD}/ssl/ca.pem --client-key=${PWD}/ssl/admin-key.pem --client-certificate=${PWD}/ssl/admin.pem
# 设置一个名为default使用default集群与admin用户的上下文，
kubectl config set-context default --cluster=default --user=admin
# 启用default为默认上下文
kubectl config use-context default
# 配置预览
kubectl config view
# 配置验证
kubectl cluster-info
```