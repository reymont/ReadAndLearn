
# https://www.cnblogs.com/smallstudent/p/5821436.html
# https://kubernetes.io/docs/getting-started-guides/centos/centos_manual_config/
systemctl daemon-reload
yum install -y kubernetes etcd flannel
# yum remove -y kubernetes etcd flannel

for SERVICES in kube-proxy kubelet flanneld docker; do
    systemctl restart $SERVICES
    systemctl enable $SERVICES
    systemctl status $SERVICES
done

# 清理 kube

cd /etc/
rm -rf /etc/kubernetes
cd /etc/systemd/system/
rm *kube*