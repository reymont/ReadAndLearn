在Kubernetes中使用Helm Chart部署有状态应用 | iSt0ne's Notes http://yoyolive.com/2017/03/13/Use-Helm-Chart-Running-a-Replicated-Stateful-Application/

Helm工作原理
Helm包括两个部分，helm客户端和tiller服务端。

the client is responsible for managing charts, and the server is responsible for managing releases.
helm客户端

helm客户端是一个命令行工具，负责管理charts、reprepository和release。它通过gPRC API（使用kubectl port-forward将tiller的端口映射到本地，然后再通过映射后的端口跟tiller通信）向tiller发送请求，并由tiller来管理对应的Kubernetes资源。

tiller服务端

tiller接收来自helm客户端的请求，并把相关资源的操作发送到Kubernetes，负责管理（安装、查询、升级或删除等）和跟踪Kubernetes资源。为了方便管理，tiller把release的相关信息保存在kubernetes的ConfigMap中。

tiller对外暴露gRPC API，供helm客户端调用。

Helm Charts
Helm使用Chart来管理Kubernetes manifest文件。每个chart都至少包括

1. 应用的基本信息Chart.yaml;
2. 一个或多个Kubernetes manifest文件模版（放置于templates/目录中），可以包括Pod、Deployment、Service等各种Kubernetes资源;
依赖管理

Helm支持两种方式管理依赖的方式：

1. 直接把依赖的package放在charts/目录中;
1. 使用requirements.yaml并用helm dep up foochart来自动下载依赖的packages;
Chart模版

Chart模板基于Go template和Sprig，模版参数的默认值必须放到values.yaml文件中。

安装MySQL服务
mysql-repl chart目录结构

[root@rancher-server mysql-repl]# tree -L 2
.
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── configmap.yaml
│   ├── services.yaml
│   └── statefulset.yaml
└── values.yaml
Chart.yaml用于描述MySQL chart

1
2
3
4
apiVersion: v1
description: A Helm chart for Kubernetes
name: mysql-repl
version: 1.1.0
templates/configmap.yaml用于生成MySQL配置文件

[root@rancher-server mysql-repl]# cat templates/configmap.yaml

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql
  labels:
    app: mysql
data:
  master.cnf: |
    # Apply this config only on the master.
    [mysqld]
    log-bin
{{- if .Values.masterConfig }}
{{ .Values.masterConfig | indent 4 }}
{{- end }}
  slave.cnf: |
    # Apply this config only on slaves.
    [mysqld]
    super-read-only
{{- if .Values.slaveConfig }}
{{ .Values.slaveConfig | indent 4 }}
{{- end -}}
templates/services.yaml用来配置MySQL服务

[root@rancher-server mysql-repl]# cat templates/services.yaml

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
# Headless service for stable DNS entries of StatefulSet members.
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
    app: {{ template "fullname" . }}
spec:
  ports:
  - name: {{ .Values.service.name }}
    port: 3306
  clusterIP: None
  selector:
    app: {{ template "fullname" . }}
---
# Client service for connecting to any MySQL instance for reads.
# For writes, you must instead connect to the master: <fullname>-mysql-0.mysql.
apiVersion: v1
kind: Service
metadata:
  name: mysql-read
  labels:
    app: {{ template "fullname" . }}
spec:
  ports:
  - name: {{ template "fullname" . }}
    port: 3306
  selector:
    app: {{ template "fullname" . }}
templates/statefulset.yaml用来定义MySQL StatefulSet

[root@rancher-server mysql-repl]# cat templates/statefulset.yaml

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: {{ template "fullname" . }}
spec:
  serviceName: mysql
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ template "fullname" . }}
      annotations:
        pod.beta.kubernetes.io/init-containers: '[
          {
            "name": "init-mysql",
            "image": "{{ .Values.image.repository }}:{{ .Values.image.tag }}",
            "command": ["bash", "-c", "
              set -ex\n
              # Generate mysql server-id from pod ordinal index.\n
              [[ `hostname` =~ -([0-9]+)$ ]] || exit 1\n
              ordinal=${BASH_REMATCH[1]}\n
              echo [mysqld] > /mnt/conf.d/server-id.cnf\n
              # Add an offset to avoid reserved server-id=0 value.\n
              echo server-id=$((100 + $ordinal)) >> /mnt/conf.d/server-id.cnf\n
              # Copy appropriate conf.d files from config-map to emptyDir.\n
              if [[ $ordinal -eq 0 ]]; then\n
                cp /mnt/config-map/master.cnf /mnt/conf.d/\n
              else\n
                cp /mnt/config-map/slave.cnf /mnt/conf.d/\n
              fi\n
            "],
            "volumeMounts": [
              {"name": "conf", "mountPath": "/mnt/conf.d"},
              {"name": "config-map", "mountPath": "/mnt/config-map"}
            ]
          },
          {
            "name": "clone-mysql",
            "image": "ist0ne/xtrabackup:1.0",
            "command": ["bash", "-c", "
              set -ex\n
              # Skip the clone if data already exists.\n
              [[ -d /var/lib/mysql/mysql ]] && exit 0\n
              # Skip the clone on master (ordinal index 0).\n
              [[ `hostname` =~ -([0-9]+)$ ]] || exit 1\n
              ordinal=${BASH_REMATCH[1]}\n
              [[ $ordinal -eq 0 ]] && exit 0\n
              # Clone data from previous peer.\n
              ncat --recv-only {{ template "fullname" . }}-$(($ordinal-1)).mysql 3307 | xbstream -x -C /var/lib/mysql\n
              # Prepare the backup.\n
              xtrabackup --prepare --target-dir=/var/lib/mysql\n
            "],
            "volumeMounts": [
              {"name": "data", "mountPath": "/var/lib/mysql", "subPath": "mysql"},
              {"name": "conf", "mountPath": "/etc/mysql/conf.d"}
            ]
          }
        ]'
    spec:
      containers:
      - name: mysql
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        env:
        - name: MYSQL_ALLOW_EMPTY_PASSWORD
          value: "1"
        ports:
        - name: mysql
          containerPort: 3306
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
{{ toYaml .Values.resources | indent 12 }}
        livenessProbe:
          exec:
            command: ["mysqladmin", "ping"]
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          exec:
            # Check we can execute queries over TCP (skip-networking is off).
            command: ["mysql", "-h", "127.0.0.1", "-e", "SELECT 1"]
          initialDelaySeconds: 5
          timeoutSeconds: 1
      - name: xtrabackup
        image: ist0ne/xtrabackup:1.0
        ports:
        - name: xtrabackup
          containerPort: 3307
        command:
        - bash
        - "-c"
        - |
          set -ex
          cd /var/lib/mysql
          # Determine binlog position of cloned data, if any.
          if [[ -f xtrabackup_slave_info ]]; then
            # XtraBackup already generated a partial "CHANGE MASTER TO" query
            # because we're cloning from an existing slave.
            mv xtrabackup_slave_info change_master_to.sql.in
            # Ignore xtrabackup_binlog_info in this case (it's useless).
            rm -f xtrabackup_binlog_info
          elif [[ -f xtrabackup_binlog_info ]]; then
            # We're cloning directly from master. Parse binlog position.
            [[ `cat xtrabackup_binlog_info` =~ ^(.*?)[[:space:]]+(.*?)$ ]] || exit 1
            rm xtrabackup_binlog_info
            echo "CHANGE MASTER TO MASTER_LOG_FILE='${BASH_REMATCH[1]}',\
                  MASTER_LOG_POS=${BASH_REMATCH[2]}" > change_master_to.sql.in
          fi
          # Check if we need to complete a clone by starting replication.
          if [[ -f change_master_to.sql.in ]]; then
            echo "Waiting for mysqld to be ready (accepting connections)"
            until mysql -h 127.0.0.1 -e "SELECT 1"; do sleep 1; done
            echo "Initializing replication from clone position"
            # In case of container restart, attempt this at-most-once.
            mv change_master_to.sql.in change_master_to.sql.orig
            mysql -h 127.0.0.1 <<EOF
          $(<change_master_to.sql.orig),
            MASTER_HOST='{{ template "fullname" . }}-0.mysql',
            MASTER_USER='root',
            MASTER_PASSWORD='',
            MASTER_CONNECT_RETRY=10;
          START SLAVE;
          EOF
          fi
          # Start a server to send backups when requested by peers.
          exec ncat --listen --keep-open --send-only --max-conns=1 3307 -c \
            "xtrabackup --backup --slave-info --stream=xbstream --host=127.0.0.1 --user=root"
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: mysql
        - name: conf
          mountPath: /etc/mysql/conf.d
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
      volumes:
      - name: conf
        emptyDir: {}
      - name: config-map
        configMap:
          name: mysql
  volumeClaimTemplates:
  - metadata:
      name: data
      annotations:
        volume.beta.kubernetes.io/storage-class: {{ .Values.persistence.storageClass }}
    spec:
      accessModes: [{{ .Values.persistence.accessMode }}]
      resources:
        requests:
          storage: {{ .Values.persistence.size }}
values.yaml用来填充模板变量

[root@rancher-server mysql-repl]# cat values.yaml

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
# Default values for mysql.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
replicaCount: 3
image:
  repository: mysql
  tag: 5.7
  pullPolicy: IfNotPresent
service:
  name: mysql
  type: ClusterIP
resources:
  limits:
    cpu: 1
    memory: 1024Mi
  requests:
    cpu: 1
    memory: 1024Mi
## Persist data to a persitent volume
persistence:
  ## If defined, volume.beta.kubernetes.io/storage-class: <storageClass>
  ## Default: volume.alpha.kubernetes.io/storage-class: default
  ##
  storageClass: gluster-heketi
  accessMode: ReadWriteOnce
  size: 10Gi
masterConfig: |-
  character-set-server=utf8
  collation-server=utf8_general_ci
slaveConfig: |-
  character-set-server=utf8
  collation-server=utf8_general_ci
Helm帮助信息

[root@rancher-server charts] helm --help
The Kubernetes package manager

To begin working with Helm, run the 'helm init' command:

    $ helm init

This will install Tiller to your running Kubernetes cluster.
It will also set up any necessary local configuration.

Common actions from this point include:

- helm search:    search for charts
- helm fetch:     download a chart to your local directory to view
- helm install:   upload the chart to Kubernetes
- helm list:      list releases of charts

Environment:
  $HELM_HOME          set an alternative location for Helm files. By default, these are stored in ~/.helm
  $HELM_HOST          set an alternative Tiller host. The format is host:port
  $TILLER_NAMESPACE   set an alternative Tiller namespace (default "kube-namespace")
  $KUBECONFIG         set an alternative Kubernetes configuration file (default "~/.kube/config")

Usage:
  helm [command]

Available Commands:
  completion  Generate bash autocompletions script
  create      create a new chart with the given name
  delete      given a release name, delete the release from Kubernetes
  dependency  manage a chart's dependencies
  fetch       download a chart from a repository and (optionally) unpack it in local directory
  get         download a named release
  history     fetch release history
  home        displays the location of HELM_HOME
  init        initialize Helm on both client and server
  inspect     inspect a chart
  install     install a chart archive
  lint        examines a chart for possible issues
  list        list releases
  package     package a chart directory into a chart archive
  repo        add, list, remove, update, and index chart repositories
  reset       uninstalls Tiller from a cluster
  rollback    roll back a release to a previous revision
  search      search for a keyword in charts
  serve       start a local http web server
  status      displays the status of the named release
  test        test a release
  upgrade     upgrade a release
  verify      verify that a chart at the given path has been signed and is valid
  version     print the client/server version information

Flags:
      --debug                     enable verbose output
      --home string               location of your Helm config. Overrides $HELM_HOME (default "/Users/shidongliang/.helm")
      --host string               address of tiller. Overrides $HELM_HOST
      --kube-context string       name of the kubeconfig context to use
      --tiller-namespace string   namespace of tiller (default "kube-system")

Use "helm [command] --help" for more information about a command.
shidongliangdeMacBook-Pro:licaishi shidongliang$ helm help create
This command creates a chart directory along with the common files and
directories used in a chart.

For example, 'helm create foo' will create a directory structure that looks
something like this:

    foo/
      |
      |- .helmignore   # Contains patterns to ignore when packaging Helm charts.
      |
      |- Chart.yaml    # Information about your chart
      |
      |- values.yaml   # The default values for your templates
      |
      |- charts/       # Charts that this chart depends on
      |
      |- templates/    # The template files

'helm create' takes a path for an argument. If directories in the given path
do not exist, Helm will attempt to create them as it goes. If the given
destination exists and there are files in that directory, conflicting files
will be overwritten, but other files will be left alone.

Usage:
  helm create NAME [flags]

Flags:
  -p, --starter string   the named Helm starter scaffold

Global Flags:
      --debug                     enable verbose output
      --home string               location of your Helm config. Overrides $HELM_HOME (default "/Users/shidongliang/.helm")
      --host string               address of tiller. Overrides $HELM_HOST
      --kube-context string       name of the kubeconfig context to use
      --tiller-namespace string   namespace of tiller (default "kube-system")
Helm初始化

第一次使用需要初始化helm，helm和kubectl使用同一配置文件

[root@rancher-server charts] helm init
部署MySQL服务

[root@rancher-server charts] helm install mysql-repl -n mysql-statefulset
NAME:   mysql-statefulset
LAST DEPLOYED: Tue Mar 14 15:36:10 2017
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME   DATA  AGE
mysql  2     0s

==> v1/Service
NAME        CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
mysql       None           <none>       3306/TCP  0s
mysql-read  10.43.227.109  <none>       3306/TCP  0s

==> apps/v1beta1/StatefulSet
NAME                          DESIRED  CURRENT  AGE
mysql-statefulset-mysql-repl  3        1        0s


NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=mysql-statefulset-mysql-repl" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:
查看服务部署情况

[root@rancher-server ~]# kubectl get pods -l app=mysql-statefulset-mysql-repl --watch
NAME                             READY     STATUS    RESTARTS   AGE
mysql-statefulset-mysql-repl-0   1/2       Running   0          9m
NAME                             READY     STATUS    RESTARTS   AGE
mysql-statefulset-mysql-repl-0   2/2       Running   0          9m
mysql-statefulset-mysql-repl-1   0/2       Pending   0         0s
mysql-statefulset-mysql-repl-1   0/2       Pending   0         0s
mysql-statefulset-mysql-repl-1   0/2       Init:0/2   0         0s
mysql-statefulset-mysql-repl-1   0/2       Init:0/2   0         4s
mysql-statefulset-mysql-repl-1   0/2       Init:1/2   0         5s
mysql-statefulset-mysql-repl-1   0/2       Init:1/2   0         6s
mysql-statefulset-mysql-repl-1   0/2       PodInitializing   0         33s
mysql-statefulset-mysql-repl-1   1/2       Running   0         35s
mysql-statefulset-mysql-repl-1   1/2       Error     0         37s
mysql-statefulset-mysql-repl-1   1/2       Running   1         38s

[root@rancher-server ~]# kubectl get pods -l app=mysql-statefulset-mysql-repl --watch
NAME                             READY     STATUS    RESTARTS   AGE
mysql-statefulset-mysql-repl-0   2/2       Running   0          11m
mysql-statefulset-mysql-repl-1   2/2       Running   1          1m
mysql-statefulset-mysql-repl-2   2/2       Running   1          1m
服务部署完成

Stateful Sets

Stateful Sets

Service

Service

Pods

Pods

Persistent Volume Claims

Persistent Volume Claims

更新MySQL服务
[root@rancher-server charts] helm upgrade mysql-repl mysql-statefulset
删除MySQL服务
[root@rancher-server charts] helm delete mysql-statefulset