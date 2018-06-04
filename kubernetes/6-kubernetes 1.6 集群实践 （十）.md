kubernetes 1.6 集群实践 （十） - 不忘初心-铃 - 博客园 https://www.cnblogs.com/panjunbai/p/8410688.html

kubernetes 1.6 集群实践 （十）

default-backend 配置
命名空间定义：

[root@panjb-k8s-1 n1]# cat namespace.yaml 
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
default-backend deploy和svc定义：

[root@panjb-k8s-1 n1]# cat default-backend.yaml 
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app: default-http-backend
  namespace: ingress-nginx
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: default-http-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        # Any image is permissable as long as:
        # 1. It serves a 404 page at /
        # 2. It serves 200 on a /healthz endpoint
        image: 192.168.7.248:5002/baseimages/defaultbackend:1.0
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
---

apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: ingress-nginx
  labels:
    app: default-http-backend
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: default-http-backend
ingress 配置
定义cm：

[root@panjb-k8s-1 n1]# cat configmap.yaml 
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app: ingress-nginx
[root@panjb-k8s-1 n1]# cat tcp-services-configmap.yaml 
kind: ConfigMap
apiVersion: v1
metadata:
  name: tcp-services
  namespace: ingress-nginx
[root@panjb-k8s-1 n1]# cat udp-services-configmap.yaml 
kind: ConfigMap
apiVersion: v1
metadata:
  name: udp-services
  namespace: ingress-nginx
定义sa：

[root@panjb-k8s-1 n1]# cat sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: system:ingress
rules:
- apiGroups:
  - ""
  resources: ["configmaps","secrets","endpoints","events","services"]
  verbs: ["list","watch","create","update","delete","get"]
- apiGroups:
  - ""
  - "extensions"
  resources: ["services","nodes","ingresses","pods","ingresses/status"]
  verbs: ["list","watch","create","update","delete","get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:ingress
subjects:
  - kind: ServiceAccount
    name: ingress
    namespace: kube-system
定义ingress的deploy和svc

[root@panjb-k8s-1 n1]# cat with-rbac.yaml 
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingress-nginx
  template:
    metadata:
      labels:
        app: ingress-nginx
    spec:
      hostNetwork: true
      serviceAccountName: ingress
      containers:
        - name: nginx-ingress-controller
          image: gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.3
          args:
            - /nginx-ingress-controller
            - --default-backend-service=ingress-nginx/default-http-backend
            - --configmap=ingress-nginx/nginx-configuration
            - --tcp-services-configmap=ingress-nginx/tcp-services
            - --udp-services-configmap=ingress-nginx/udp-services
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
          - name: http
            containerPort: 80
          - name: https
            containerPort: 443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
在K8S系统中启动配置文件

kubectl apply -f namespace.yaml  &&  kubectl apply -f default-backend.yaml  &&  kubectl apply -f  configmap.yaml  &&  kubectl apply -f  tcp-services-configmap.yaml && 
 kubectl apply -f udp-services-configmap.yaml  &&  kubectl apply -f with-rbac.yaml 
rabc相关资料：https://kubernetes.io/docs/admin/authorization/rbac/