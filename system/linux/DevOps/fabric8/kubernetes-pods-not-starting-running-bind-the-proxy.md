

# https://stackoverflow.com/questions/43728355/kubernetes-pods-not-starting-running-bind-the-proxy/43757872#43757872


I was able to fix it myself. I had Docker on my host and there is Docker in Minikube. Docker in Minukube had issues I had to ssh into minikube VM and follow this post

Cannot download Docker images behind a proxy and it all works nows,

There should be a better way of doing this, on starting minikube i have passed docker env like below, which did not work

minikube start --docker-env HTTP_PROXY=http://xxxx:8080 --docker-env HTTPS_PROXY=http://xxxx:8080 
--docker-env NO_PROXY=localhost,127.0.0.0/8,192.0.0.0/8 --extra-config=kubelet.PodInfraContainerImage=myhub/pause:3.0
I had set the same env variable inside Minikube VM, to make it work