

https://stackoverflow.com/questions/40720979/access-kubernetes-cluster-setup-using-minikube-with-the-kubernetes-api

Running minikube start will automatically configure kubectl.

You can run minikube ip to get the IP that your minikube is on. The API server runs on 8443 by default.

Update: To access the API server directly, you'll need to use the custom SSL certs that have been generated. by minikube. The client certificate and key are typically stored at: ~/.minikube/apiserver.crt and ~/.minikube/apiserver.key. You'll have to load them into your HTTPS client when you make requests.

If you're using curl use the --cert and the --key options to use the cert and key file. Check the docs for more details.

The easiest way to access the Kubernetes API with when running minikube is to use

`kubectl proxy --port=8080`
You can then access the API with

curl http://localhost:8080/api/
This also allows you to browse the API in your browser. Start minikube using

`minikube start --extra-config=apiserver.Features.EnableSwaggerUI=true`
then start kubectl proxy, and navigate to `http://localhost:8080/swagger-ui/` in your browser.

You can access the Kubernetes API with curl directly using

curl --cacert ~/.minikube/ca.crt --cert ~/.minikube/client.crt --key ~/.minikube/client.key 

https://`minikube ip`:8443/api/
but usually there is no advantage in doing so. Common browsers are not happy with the certificates minikube generates, so if you want to access the API with your browser you need to use kubectl proxy.