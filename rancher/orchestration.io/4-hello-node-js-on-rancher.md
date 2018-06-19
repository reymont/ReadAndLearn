Hello Node.js on Rancher | orchestration.io https://orchestration.io/2016/07/21/hello-node-js-on-rancher/

```sh
# https://www.centos.bz/2017/07/kubernetes-deploy-test-nginx-service/
# nginx
kubectl delete deploy nginx
kubectl run nginx --image=nginx --replicas=5 --port=80
kubectl get deploy
kubectl get pod –all-namespaces -o wide|grep nginx
kubectl expose deployment nginx --type=NodePort --name=nginx-svc
kubectl describe svc nginx-svc

# tomcat
kubectl delete deploy tomcat
kubectl run tomcat --image=tomcat --replicas=3 --port=8088
kubectl expose deployment tomcat –type=NodePort –name=tomcat-svc
kubectl describe svc tomcat-svc


# 测试nginx服务
curl 10.105.170.116:80
# 浏览器访问都能显示nginx welcome界面
http://172.172.20.14:30457
http://172.172.20.15:30457
http://nodes:30457
```


Hello Node.js on Rancher
Posted: July 21, 2016 | Author: Chris Greene | Filed under: containers, Uncategorized | Tags: docker, rancher |Leave a comment
In this post I’m going to show how to go through the Kubernetes Hello World Walkthrough but using Rancher instead of Google’s Cloud Platform. One of the reasons I wanted to install Kubernetes on my own resources instead of in the cloud is so that I don’t have to pay additional costs while I’m experimenting/learning.

You’ll need to have done the following before proceeding:

Installed Rancher.
Building the Micro Datacenter – Running Rancher on a Laptop or
Getting started with Rancher
Installed Kubernetes on Rancher.
(Optional) Created a Docker Hub account.
Create the Docker image
I’m going to build the Docker image on my Rancher machine (a VM), but you can build it anywhere. If you decide to build the Docker image somewhere other than the Rancher machine, you’ll need to push your image up to Docker Hub. You may be able to add a container registry to Rancher, but I haven’t explored that. You can also use my image.

Run the following on the Rancher machine.

mkdir hello-node
cd hello-node

Create a file named Dockerfile with the following contents:

FROM node:4.4
EXPOSE 8080
COPY server.js .
CMD node server.js
Create a file named server.js with the following contents:

var http = require(‘http’);
var handleRequest = function(request, response) {
response.writeHead(200);
response.end(“Hello World!”);
}
var www = http.createServer(handleRequest);
www.listen(8080);

Build the Docker image (that’s a period after v1):

docker build -t chrisgreene/hello-node:v1 .

If you need to upload the image to Docker Hub (make sure to change the image name or it will conflict with mine and fail):

docker login
docker push

Create the deployment
Now that we have our Docker image ready to go we can create the deployment. To do so:

Make sure you’re in the Kubernetes (k8s) environment.
Select Kubernetes
Select Kubectl
You’ll now have a shell to enter commands
2016-07-20_15-00-04.jpg

Enter the following command (replace the image name if you’re using your own):

kubectl run hello-node –image=chrisgreene/hello-node:v1 –port=8080

2016-07-20_14-57-01.jpg
If the deployment was successfully created, you’ll see the following:

2016-07-20_14-57-59.jpg

Verify our deployment:

2016-07-20_15-01-05.jpg

If we get all of the pods, we will see the hello-node pod:

2016-07-20_15-01-42.jpg

You can also view the replica sets by running kubectl get rs.

Select Infrastructure > Containers and you’ll see the hello-node containers:

2016-07-20_14-58-40.jpg

Expose the Node.js service to the outside
In order to reach the Node.js service, we need to expose it. We can do this with the following command:

kubectl expose deployment hello-node –port=80 –target-port=8080 –external-ip=192.168.3.168

192.168.3.168 is the IP of my Rancher machine. You’ll most likely need to change this. If you’re copy and pasting from this example, make sure there are two dashes in front of port, target-port and external-ip. Sometimes those get lost during copy/paste and the command won’t work.

2016-07-20_15-06-13.jpg
Let’s verify our service:

2016-07-20_15-06-56.jpg

Now I can access my Node.js app:

2016-07-20_15-12-34.jpg

Scale the app
Let’s scale the app to 4 replicas instead of one:

2016-07-20_15-14-50.jpg

Verify that we now have 4 pods:

2016-07-20_15-15-33.jpg

Upgrade the app
I’m not going to show the steps to upgrade the app, but they are exactly as described in Roll out an upgrade to your website.

I performed the steps and was able to see the new site:

2016-07-20_15-24-38.jpg