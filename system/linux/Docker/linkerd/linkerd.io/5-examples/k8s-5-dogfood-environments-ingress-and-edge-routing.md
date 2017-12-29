

# https://buoyant.io/2016/11/18/a-service-mesh-for-kubernetes-part-v-dogfood-environments-ingress-and-edge-routing/

```sh
kubectl apply -f linkerd-ingress.yml
kubectl apply -f node-name-test.yml
kubectl logs node-name-test
kubectl apply -f hello-world-legacy.yml
kubectl apply -f world-v2.yml
kubectl apply -f api-legacy.yml

kubectl get svc
export INGRESS_LB=10.104.122.216
# l5d          NodePort    10.104.122.216   <none>        80:32156/TCP,4141:32292/TCP,9990:30555/TCP   4m
curl -s -H "Host: www.hello.world" 10.104.122.216:80
curl -s -H "Host: api.hello.world" $INGRESS_LB

curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world => /srv/world-v2;" $INGRESS_LB

kubectl apply -f nginx.yml
kubectl get svc
# nginx        NodePort    10.103.63.231    <none>        80:31082/TCP
curl -s 10.103.63.231
export INGRESS_LB=10.103.63.231
curl -s -H "Host: www.hello.world" $INGRESS_LB
curl -s -H "Host: api.hello.world" $INGRESS_LB
curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world => /srv/world-v2;" $INGRESS_LB

curl -H "Host: www.hello.world" --cookie "special_employee_cookie=dogfood" $INGRESS_LB
curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world => /srv/world-v2;" $INGRESS_LB
```


In previous installments of this series, we’ve shown you how you can use linkerd to capture top-line service metrics, transparently add TLS across service calls, and perform blue-green deploys. These posts showed how using linkerd as a service mesh in environments like Kubernetes adds a layer of resilience and performance to internal, service-to-service calls. In this post, we’ll extend this model to ingress routing.

Although the examples in this post are Kubernetes-specific, we won’t use the built-in Ingress Resource that Kubernetes provides (for this, see Sarah’s post). While Ingress Resources are a convenient way of doing basic path and host-based routing, at the time of writing, they are fairly limited. In the examples below, we’ll be reaching far beyond what they provide.

STEP 1: DEPLOY THE LINKERD SERVICE MESH

Starting with our basic linkerd service mesh Kubernetes config from the previous articles, we’ll make two changes to support ingress: we’ll modify the linkerd config to add an additional logical router, and we’ll tweak the VIP in the Kubernetes Service object around linkerd. (The full config is here: linkerd-ingress.yml.)

Here’s the new ingress logical router on linkerd instances that will handle ingress traffic and route it to the corresponding services:


routers:
- protocol: http
  label: ingress
  dtab: |
    /srv                    =&gt; /#/io.l5d.k8s/default/http ;
    /domain/world/hello/www =&gt; /srv/hello ;
    /domain/world/hello/api =&gt; /srv/api ;
    /host                   =&gt; /$/io.buoyant.http.domainToPathPfx/domain ;
    /svc                    =&gt; /host ;
  interpreter:
    kind: default
    transformers:
    - kind: io.l5d.k8s.daemonset
      namespace: default
      port: incoming
      service: l5d
  servers:
  - port: 4142
    ip: 0.0.0.0

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
routers:
- protocol: http
  label: ingress
  dtab: |
    /srv                    =&gt; /#/io.l5d.k8s/default/http ;
    /domain/world/hello/www =&gt; /srv/hello ;
    /domain/world/hello/api =&gt; /srv/api ;
    /host                   =&gt; /$/io.buoyant.http.domainToPathPfx/domain ;
    /svc                    =&gt; /host ;
  interpreter:
    kind: default
    transformers:
    - kind: io.l5d.k8s.daemonset
      namespace: default
      port: incoming
      service: l5d
  servers:
  - port: 4142
    ip: 0.0.0.0
 
In this config, we’re using linkerd’s routing syntax, dtabs, to route requests from domain to service—in this case from “api.hello.world” to the api service, and from “www.hello.world” to the world service. For simplicity’s sake, we’ve added one rule per domain, but this mapping can easily be generified for more complex setups. (If you’re a linkerd config aficionado, we’re accomplishing this behavior by combining linkerd’s default header token identifier to route on the Host header, the domainToPathPfx namer to turn dotted hostnames into hierarchical paths, and the io.l5d.k8s.daemonset transformer to send requests to the corresponding host-local linkerd.)

We’ve added this ingress router to every linkerd instance—in true service mesh fashion, we’ll fully distribute ingress traffic across these instances so that no instance is a single point of failure.

We also need modify our k8s Service object to replace the outgoing VIP with aningress VIP on port 80. This will allow us to send ingress traffic directly to the linkerd service mesh—mainly for debugging purposes, since the this traffic will not be sanitized before hitting linkerd. (In the next step, we’ll fix this.)

The Kubernetes change looks like this:


---
apiVersion: v1
kind: Service
metadata:
  name: l5d
spec:
  selector:
    app: l5d
  type: LoadBalancer
  ports:
  - name: ingress
    port: 80
    targetPort: 4142
  - name: incoming
    port: 4141
  - name: admin
    port: 9990

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
---
apiVersion: v1
kind: Service
metadata:
  name: l5d
spec:
  selector:
    app: l5d
  type: LoadBalancer
  ports:
  - name: ingress
    port: 80
    targetPort: 4142
  - name: incoming
    port: 4141
  - name: admin
    port: 9990
 
All of the above can be accomplished in one fell swoop by running this command to apply the full linkerd service mesh plus ingress Kubernetes config:


$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-ingress.yml

1
2
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-ingress.yml
 
STEP 2: DEPLOY THE SERVICES

For services in this example, we’ll use the same hello and world configs from the previous blog posts, and we’ll add two new services: an api service, which calls both hello and world, and a new version of the world service, world-v2, which will return the word “earth” rather than “world”—our growth hacker team has assured us their A/B tests show this change will increase engagement tenfold.

The following commands will deploy the three hello world services to the default namespace. These apps rely on the nodeName supplied by the Kubernetes downward API to find Linkerd. To check if your cluster supports nodeName, you can run this test job:


kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/node-name-test.yml
1
kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/node-name-test.yml
And then looks at its logs:


kubectl logs node-name-test
1
kubectl logs node-name-test
If you see an ip, great! Go ahead and deploy the hello world app using:


$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/api.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/world-v2.yml
1
2
3
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/api.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/world-v2.yml

If instead you see a “server can’t find …” error, deploy the hello-world legacy version that relies on hostIP instead of nodeName:


$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world-legacy.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/api-legacy.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/world-v2.yml
1
2
3
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/hello-world-legacy.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/api-legacy.yml
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/world-v2.yml

At this point we should be able to test the setup by sending traffic through the ingress Kubernetes VIP. In the absence of futzing with DNS, we’ll set a Host header manually on the request:


$ INGRESS_LB=$(kubectl get svc l5d -o jsonpath="{.status.loadBalancer.ingress[0].*}")
$ curl -s -H "Host: www.hello.world" $INGRESS_LB
Hello (10.0.5.7) world (10.0.4.7)!!
$ curl -s -H "Host: api.hello.world" $INGRESS_LB
{"api_result":"api (10.0.3.6) Hello (10.0.5.4) world (10.0.1.5)!!"}

1
2
3
4
5
6
$ INGRESS_LB=$(kubectl get svc l5d -o jsonpath="{.status.loadBalancer.ingress[0].*}")
$ curl -s -H "Host: www.hello.world" $INGRESS_LB
Hello (10.0.5.7) world (10.0.4.7)!!
$ curl -s -H "Host: api.hello.world" $INGRESS_LB
{"api_result":"api (10.0.3.6) Hello (10.0.5.4) world (10.0.1.5)!!"}
 
Or if external load balancer support is unavailable for the cluster, use hostIP:


$ INGRESS_LB=$(kubectl get po -l app=l5d -o jsonpath="{.items[0].status.hostIP}"):$(kubectl get svc l5d -o 'jsonpath={.spec.ports[0].nodePort}')
1
$ INGRESS_LB=$(kubectl get po -l app=l5d -o jsonpath="{.items[0].status.hostIP}"):$(kubectl get svc l5d -o 'jsonpath={.spec.ports[0].nodePort}')
Success! We’ve set up linkerd as our ingress controller, and we’ve used it to route requests received on different domains to different services. And as you can see, production traffic is hitting the world-v1 service—we aren’t ready to bring world-v2out just yet.

STEP 3: A LAYER OF NGINX

At this point we have functioning ingress. However, we’re not ready for production just yet. For one thing, our ingress router doesn’t strip headers from requests, which means that external requests may include headers that we do not want to accept. For instance, linkerd allows setting the l5d-dtab header to apply routing rules per-request. This is a useful feature for ad-hoc staging of new services, but it’s probably not appropriate calls from the outside world!

For example, we can use the l5d-dtab header to override the routing logic to use world-v2 rather than the production world-v1 service the outside world:


$ curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world =&gt; /srv/world-v2;" $INGRESS_LB
Hello (10.100.4.3) earth (10.100.5.5)!!

1
2
3
$ curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world =&gt; /srv/world-v2;" $INGRESS_LB
Hello (10.100.4.3) earth (10.100.5.5)!!
 
Note the earth in the response, denoting the result of the world-v2 service. That’s cool, but definitely not the kind of power we want to give just anyone!

We can address this (and other issues, such as serving static files) by adding nginx to the mix. If we configure nginx to strip incoming headers before proxying requests to the linkerd ingress route, we’ll get the best of both worlds: an ingress layer that is capable of safely handling external traffic, and linkerd doing dynamic, service-based routing.

Let’s add nginx to the cluster. We’ll configure it using this nginx.conf. We’ll use the proxy_pass directive under our virtual servers www.hello.world and api.hello.world to send requests to the linkerd instances, and, for maximum fanciness, we’ll strip linkerd’s context headers using the more_clear_input_headers directive (with wildcard matching) provided by the Headers More module.

(Alternatively, we could avoid third-party nginx modules by using nginx’sproxy_set_header directive to clear headers. We’d need separate entries for each l5d-ctx- header as well as the l5d-dtab and l5d-sample headers.)

Note that as of linkerd 0.9.0, we can clear incoming l5d-* headers by setting clearContext: true on the ingress router server. However, nginx has many features we can make use of (as you’ll see presently), so it is still valuable to use nginx in conjunction with linkerd.

For those of you following along at home, we’ve published an nginx Docker image with the Headers More module installed (Dockerfile here) as buoyantio/nginx:1.11.5. We can deploy this image with our config above using this Kubernetes config:


$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/nginx.yml

1
2
$ kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/nginx.yml
 
After waiting a bit for the external IP to appear, we can test that nginx is up by hitting the simple test endpoint in the nginx.conf:


$ INGRESS_LB=$(kubectl get svc nginx -o jsonpath="{.status.loadBalancer.ingress[0].*}")
$ curl $INGRESS_LB
200 OK

1
2
3
4
$ INGRESS_LB=$(kubectl get svc nginx -o jsonpath="{.status.loadBalancer.ingress[0].*}")
$ curl $INGRESS_LB
200 OK
 
Or if external load balancer support is unavailable for the cluster, use hostIP:


$ INGRESS_LB=$(kubectl get po -l app=nginx -o jsonpath="{.items[0].status.hostIP}"):$(kubectl get svc nginx -o 'jsonpath={.spec.ports[0].nodePort}')
1
$ INGRESS_LB=$(kubectl get po -l app=nginx -o jsonpath="{.items[0].status.hostIP}"):$(kubectl get svc nginx -o 'jsonpath={.spec.ports[0].nodePort}')
We should be able to now send traffic to our services through nginx:


$ curl -s -H "Host: www.hello.world" $INGRESS_LB
Hello (10.0.5.7) world (10.0.4.7)!!
$ curl -s -H "Host: api.hello.world" $INGRESS_LB
{"api_result":"api (10.0.3.6) Hello (10.0.5.4) world (10.0.1.5)!!"}

1
2
3
4
5
$ curl -s -H "Host: www.hello.world" $INGRESS_LB
Hello (10.0.5.7) world (10.0.4.7)!!
$ curl -s -H "Host: api.hello.world" $INGRESS_LB
{"api_result":"api (10.0.3.6) Hello (10.0.5.4) world (10.0.1.5)!!"}
 
Finally, let’s try our header trick and attempt to communicate directly with the world-v2 service:


$ curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world =&gt; /srv/world-v2;" $INGRESS_LB
Hello (10.196.1.8) world (10.196.2.13)!!

1
2
3
$ curl -H "Host: www.hello.world" -H "l5d-dtab: /host/world =&gt; /srv/world-v2;" $INGRESS_LB
Hello (10.196.1.8) world (10.196.2.13)!!
 
Great! No more earth. Nginx is sanitizing external traffic.

STEP 4: TIME FOR SOME DELICIOUS DOGFOOD!

Ok, we’re ready for the good part: let’s set up a dogfood environment that uses theworld-v2 service, but only for some traffic!

For simplicity, we’ll target traffic that sets a particular cookie,special_employee_cookie. In practice, you probably want something more sophisticated than this—authenticate it, require that it come from the corp network IP range, etc.

With nginx and linkerd installed, accomplishing this is quite simple. We’ll use nginx to check for the presence of that cookie, and set a dtab override header for linkerd to adjust its routing. The relevant nginx config looks like this:


if ($cookie_special_employee_cookie ~* "dogfood") {
  set $xheader "/host/world =&gt; /srv/world-v2;";
}

proxy_set_header 'l5d-dtab' $xheader;

1
2
3
4
5
6
if ($cookie_special_employee_cookie ~* "dogfood") {
  set $xheader "/host/world =&gt; /srv/world-v2;";
}
 
proxy_set_header 'l5d-dtab' $xheader;
 
If you’ve been following the steps above, the deployed nginx already contains this configuration. We can test it like so:


$ curl -H "Host: www.hello.world" --cookie "special_employee_cookie=dogfood" $INGRESS_LB
Hello (10.196.1.8) earth (10.196.2.13)!!

1
2
3
$ curl -H "Host: www.hello.world" --cookie "special_employee_cookie=dogfood" $INGRESS_LB
Hello (10.196.1.8) earth (10.196.2.13)!!
 
The system works! When this cookie is set, you’ll be in dogfood mode. Without it, you’ll be in regular, production traffic mode. Most importantly, dogfood mode can involve new versions of services that appear anywhere in the service stack, even many layers deep—as long as service code forwards linkerd context headers, the linkerd service mesh will take care of the rest.

Conclusion

In this post, we saw how to use linkerd to provide powerful and flexible ingress to a Kubernetes cluster. We’ve demonstrated how to deploy a nominally production-ready setup that uses linkerd for service routing. And we’ve demonstrated how to use some of the advanced routing features of linkerd to decouple the traffic-serving topology from the deployment topology, allowing for the creation of dogfood environments without separate clusters or deploy-time complications.
Note: there are a myriad of ways to deploy Kubernetes and different environments support different features. Learn more about deployment differences here.

For more about running linkerd in Kubernetes, or if you have any issues configuring ingress in your setup, feel free to stop by our linkerd community Slack, ask a question on Discourse, or contact us directly!