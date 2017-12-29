
# https://buoyant.io/2017/03/14/a-service-mesh-for-kubernetes-part-vii-distributed-tracing-made-easy/


```sh
kubectl apply -f zipkin.yml

kubectl get svc
# zipkin             NodePort    10.97.236.143    <none>        80:30430/TCP
export ZIPKIN_LB=10.97.236.143
curl $ZIPKIN_LB
open http://192.168.99.100:30430/

kubectl apply -f linkerd-zipkin.yml
# l5d                NodePort    10.104.122.216   <none>        4140:31495/TCP,4141:32292/TCP,9990:30555/TCP
curl 10.104.122.216:4140
export L5D_INGRESS_LB=10.104.122.216
http_proxy=http://$L5D_INGRESS_LB:4140 curl -s http://hello

http://192.168.99.100:30430/?serviceName=0.0.0.0:4140

# https://github.com/kubernetes/minikube/issues/1451
# https://github.com/kubernetes/minikube/issues/1674
# DNS lookup not working when starting minikube with --dns-domain
# kubedns
VBoxManage modifyvm "minikube" --natdnshostresolver1 on
minikube start
kubectl cluster-info
kubectl get pods --namespace=kube-system -l k8s-app=kube-dns

nslookup kubernetes.default.svc.cluster.local 10.0.0.1

kubectl get svc --all-namespaces
kubectl get svc kube-dns -n kube-system
# kube-system   kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP
nslookup kubernetes.default.svc.cluster.local 10.96.0.10
# Server:    10.96.0.10
# Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

# Name:      kubernetes.default.svc.cluster.local
# Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local

# 启用dns
minikube stop
minikube addons enable kube-dns
minikube start
minikube addons list
https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/kube-dns
```

In previous installments of this series, we’ve shown you how you can use Linkerd to capture top-line service metrics. Service metrics are vital for determining the health of individual services, but they don’t capture the way that multiple services work (or don’t work!) together to serve requests. To see a bigger picture of system-level performance, we need to turn to distributed tracing.

In a previous post, we covered some of the benefits of distributed tracing, and how to configure Linkerd to export tracing data to Zipkin. In this post, we’ll show you how to run this setup entirely in Kubernetes, including Zipkin itself, and how to derive meaningful data from traces that are exported by Linkerd.

A Kubernetes Service Mesh

Before we start looking at traces, we’ll need to deploy Linkerd and Zipkin to Kubernetes, along with some sample apps. The linkerd-examples repo provides all of the configuration files that we’ll need to get tracing working end-to-end in Kubernetes. We’ll walk you through the steps below.

STEP 1: INSTALL ZIPKIN

We’ll start by installing Zipkin, which will be used to collect and display tracing data. In this example, for convenience, we’ll use Zipkin’s in-memory store. (If you plan to run Zipkin in production, you’ll want to switch to using one of its persistent backends.)

To install Zipkin in the default Kubernetes namespace, run:


kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/zipkin.yml

1
2
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/zipkin.yml
 
You can confirm that installation was successful by viewing Zipkin’s web UI:


ZIPKIN_LB=$(kubectl get svc zipkin -o jsonpath="{.status.loadBalancer.ingress[0].*}")
open http://$ZIPKIN_LB # on OS X

1
2
3
ZIPKIN_LB=$(kubectl get svc zipkin -o jsonpath="{.status.loadBalancer.ingress[0].*}")
open http://$ZIPKIN_LB # on OS X
 
Note that it may take a few minutes for the ingress IP to become available. Or if external load balancer support is unavailable for the cluster, use hostIP:


ZIPKIN_LB=</code>$(kubectl get po -l app=zipkin -o jsonpath="{.items[0].status.hostIP}"):$(kubectl get svc zipkin -o 'jsonpath={.spec.ports[0].nodePort}') open http://$ZIPKIN_LB # on OS X
1
ZIPKIN_LB=</code>$(kubectl get po -l app=zipkin -o jsonpath="{.items[0].status.hostIP}"):$(kubectl get svc zipkin -o 'jsonpath={.spec.ports[0].nodePort}') open http://$ZIPKIN_LB # on OS X
However, the web UI won’t show any traces until we install Linkerd.

STEP 2: INSTALL THE SERVICE MESH

Next we’ll install the Linkerd service mesh, configured to write tracing data to Zipkin. To install Linkerd as a DaemonSet (i.e., one instance per host) in the default Kubernetes namespace, run:


kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-zipkin.yml

1
2
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-zipkin.yml
 
This installed Linkerd as a service mesh, exporting tracing data with Linkerd’s Zipkin telemeter. The relevant config snippet is:


telemetry:
- kind: io.l5d.zipkin
  host: zipkin-collector.default.svc.cluster.local
  port: 9410
  sampleRate: 1.0

1
2
3
4
5
6
telemetry:
- kind: io.l5d.zipkin
  host: zipkin-collector.default.svc.cluster.local
  port: 9410
  sampleRate: 1.0
 
Here we’re telling Linkerd to send tracing data to the Zipkin service that we deployed in the previous step, on port 9410. The configuration also specifies a sample rate, which determines the number of requests that are traced. In this example we’re tracing all requests, but in a production setting you may want to set the rate to be much lower (the default is 0.001, or 0.1% of all requests).

You can confirm the installation was successful by viewing Linkerd’s admin UI (note, again, that it may take a few minutes for the ingress IP to become available, depending on the vagaries of your cloud provider):


L5D_INGRESS_LB=$(kubectl get svc l5d -o jsonpath="{.status.loadBalancer.ingress[0].*}")
open http://$L5D_INGRESS_LB:9990 # on OS X

1
2
3
L5D_INGRESS_LB=$(kubectl get svc l5d -o jsonpath="{.status.loadBalancer.ingress[0].*}")
open http://$L5D_INGRESS_LB:9990 # on OS X
 
Or if external load balancer support is unavailable for the cluster, use hostIP:


L5D_INGRESS_LB=$(kubectl get po -l app=l5d -o jsonpath="{.items[0].status.hostIP}")
open http://$L5D_INGRESS_LB:$(kubectl get svc l5d -o 'jsonpath={.spec.ports[2].nodePort}') # on OS X
1
2
L5D_INGRESS_LB=$(kubectl get po -l app=l5d -o jsonpath="{.items[0].status.hostIP}")
open http://$L5D_INGRESS_LB:$(kubectl get svc l5d -o 'jsonpath={.spec.ports[2].nodePort}') # on OS X
STEP 3: INSTALL THE SAMPLE APPS

Now we’ll install the “hello” and “world” apps in the default namespace. These apps rely on the nodeName supplied by the Kubernetes downward API to find Linkerd. To check if your cluster supports nodeName, you can run this test job:


kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/node-name-test.yml
1
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/node-name-test.yml
And then looks at its logs:


kubectl logs node-name-test
1
kubectl logs node-name-test
If you see an ip, great! Go ahead and deploy the hello world app using:


kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world.yml

1
2
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world.yml
 
If instead you see a “server can’t find …” error, deploy the hello-world legacy version that relies on hostIP instead of nodeName:


kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world-legacy.yml
1
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world-legacy.yml
Congrats! At this point, we have a functioning service mesh with distributed tracing enabled, and an application that makes use of it.

Let’s see the entire setup in action by sending traffic through Linkerd’s outgoing router running on port 4140:


http_proxy=http://$L5D_INGRESS_LB:4140 curl -s http://hello
Hello () world ()!

1
2
3
http_proxy=http://$L5D_INGRESS_LB:4140 curl -s http://hello
Hello () world ()!
 
Or if using hostIP:


http_proxy=http://$L5D_INGRESS_LB:</code>$(kubectl get svc l5d -o 'jsonpath={.spec.ports[0].nodePort}') curl -s http://hello Hello () world ()!
1
http_proxy=http://$L5D_INGRESS_LB:</code>$(kubectl get svc l5d -o 'jsonpath={.spec.ports[0].nodePort}') curl -s http://hello Hello () world ()!
If everything is working, you’ll see a “Hello world” message similar to that above, with the IPs of the pods that served the request.

STEP 4: ENJOY THE VIEW

Now it’s time to see some traces. Let’s start by looking at the trace that was emitted by the test request that we sent in the previous section. Zipkin’s UI allows you to search by “span” name, and in our case, we’re interested in spans that originated with the Linkerd router running on 0.0.0.0:4140, which is where we sent our initial request. We can search for that span as follows:


open http://$ZIPKIN_LB/?serviceName=0.0.0.0%2F4140 # on OS X
1
open http://$ZIPKIN_LB/?serviceName=0.0.0.0%2F4140 # on OS X
That should surface 1 trace with 8 spans, and the search results should look like this:



Clicking on the trace from this view will bring up the trace detail view:



From this view, you can see the timing information for all 8 spans that Linkerd emitted for this trace. The fact that there are 8 spans for a request between 2 services stems from the service mesh configuration, in which each request passes through two Linkerd instances (so that the protocol can be upgraded or downgraded, or TLS can be added and removed across node boundaries). Each Linkerd router emits both a server span and a client span, for a total of 8 spans.

Clicking on a span will bring up additional details for that span. For instance, the last span in the trace above represents how long it took the world service to respond to a request—8 milliseconds. If you click on that span, you’ll see the span detail view:



This view has a lot more information about the span. At the top of the page, you’ll see timing information that indicates when Linkerd sent the request to the service, and when it received a response. You’ll also see a number of key-value pairs with additional information about the request, such as the request URI, the response status code, and the address of the server that served the request. All of this information is populated by Linkerd automatically, and can be very useful in tracking down performance bottlenecks and failures.

A NOTE ABOUT REQUEST CONTEXT

In order for distributed traces to be properly disentangled, we need a little help from the application. Specifically, we need services to forward Linkerd’s “context headers” (anything that starts with l5d-ctx-) from incoming requests to outgoing requests. Without these headers, it’s impossible to align outgoing requests with incoming requests through a service. (The hello and world services provided above do this by default.)

There are some additional benefits to forwarding context headers, beyond tracing. From our previous blog post on the topic:

Forwarding request context for Linkerd comes with far more benefits than just tracing, too. For instance, adding the l5d-dtab header to an inbound request will add a dtab override to the request context. Provided you propagate request context, dtab overrides can be used to apply per-request routing overrides at any point in your stack, which is especially useful for staging ad-hoc services within the context of a production application. In the future, request context will be used to propagate overall latency budgets, which will make handling requests within distributed systems much more performant.

Finally, the L5d-sample header can be used to adjust the tracing sample rate on a per-request basis. To guarantee that a request will be traced, set L5d-sample: 1.0. If you’re sending a barrage of requests in a loadtest that you don’t want flooding your tracing system, consider setting it to something much lower than the steady-state sample rate defined in your Linkerd config.
Conclusion

We’ve demonstrated how to run Zipkin in Kubernetes, and how to configure your Linkerd service mesh to automatically export tracing data to Zipkin. Distributed tracing is a powerful tool that is readily available to you if you’re already using Linkerd. Check out Linkerd’s Zipkin telemeter configuration reference, and find us in the Linkerd Slack if you run into any issues setting it up.

APPENDIX: UNDERSTANDING TRACES

In distributed tracing, a trace is a collection of spans that form a tree structure. Each span has a start timestamp and an end timestamp, as well as additional metadata about what occurred in that interval. The first span in a trace is called the root span. All other spans have a parent ID reference that refers to the root span or one of its descendants. There are two types of spans: server and client. In Linkerd’s context, server spans are created when a Linkerd router receives a request from an upstream client. Client spans are created when Linkerd sends that request to a downstream server. Thus the parent of a client span is always a server span. In the process of routing a multi-service request, Linkerd will emit multiple client and server spans, which are displayed as a single trace in the Zipkin UI.

For instance, consider the following trace:



In this example, an external request is routed by Linkerd to the “Web” service, which then calls “Service B” and “Service C” sequentially (via Linkerd) before returning a response. The trace has 6 spans, and a total duration of 20 milliseconds. The 3 yellow spans are server spans, and the 3 blue spans are client spans. The root span is Span A, which represents the time from when Linkerd initially received the external request until it returned the response. Span A has one child, Span B, which represents the amount of time that it took for the Web service to respond to Linkerd’s forwarded request. Likewise Span D represents the amount of time that it took for Service B to respond to the request from the Web service. For more information about tracing, read our previous blog post, Distributed Tracing for Polyglot Microservices.
Note: there are a myriad of ways to deploy Kubernetes and different environments support different features. Learn more about deployment differences here.