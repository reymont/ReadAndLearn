
# https://github.com/coreos/etcd/releases/


ETCD_VER=v3.2.10

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/coreos/etcd/releases/download
DOWNLOAD_URL=${GITHUB_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

curl -L https://github.com/coreos/etcd/releases/download/v3.2.10/etcd-v3.2.10-linux-amd64.tar.gz \
  -o /tmp/etcd-v3.2.10-linux-amd64.tar.gz

wget -O /tmp/etcd-v3.2.10-linux-amd64.tar.gz \
  https://github.com/coreos/etcd/releases/download/v3.2.10/etcd-v3.2.10-linux-amd64.tar.gz

wget https://github.com/coreos/etcd/releases/download/v3.2.10/etcd-v3.2.10-linux-amd64.tar.gz
wget -O /usr/local/bin/calicoctl https://www.projectcalico.org/builds/calicoctl
chmod +x /usr/local/bin/calicoctl

/tmp/etcd-download-test/etcd --version
<<COMMENT
etcd Version: 3.2.10
Git SHA: 694728c
Go Version: go1.8.5
Go OS/Arch: linux/amd64
COMMENT

ETCDCTL_API=3 /tmp/etcd-download-test/etcdctl version
<<COMMENT
etcdctl version: 3.2.10
API version: 3.2
COMMENT


# start a local etcd server
/tmp/etcd-download-test/etcd

# write,read to etcd
ETCDCTL_API=3 /tmp/etcd-download-test/etcdctl --endpoints=localhost:2379 put foo bar
ETCDCTL_API=3 /tmp/etcd-download-test/etcdctl --endpoints=localhost:2379 get foo