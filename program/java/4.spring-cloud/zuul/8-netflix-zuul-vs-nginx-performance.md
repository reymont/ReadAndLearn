# http://instea.sk/2015/04/netflix-zuul-vs-nginx-performance/
NETFLIX ZUUL VS NGINX PERFORMANCE
POSTED BY STANISLAV MIKLIK | APRIL 16, 2015 | SPRING
Nowadays you can hear lot about microservices. Spring Boot is an excellent choice for building single microservice but you need to interconnect them somehow. That’s what Spring Cloud tries to solve (among other things) – especially Spring Cloud Netflix. It provides various components e.g. Eureka discovery service together with client side load balancer Ribbon for inter-microservice communication. But if you want to communicate to outside world (you provide external API or you just use AJAX from your page heavily) it is good to hide your various services behind a proxy.

Natural choice would be Nginx. But Netflix comes with its own solution – intelligent router Zuul. It comes with lot of interesting features and can be used e.g. for authentication, service migration, load shedding and various dynamic routing options. And it is written in Java. If Netflix uses it, is it fast enough compared to native reverse proxy? Or is it just suitable as an companion to Nginx when flexibility (or other features) are important?

Disclaimer: Do not consider this as a serious benchmark. I just wanted to get feeling how Nginx and Zuul compares and I can’t find any benchmarks on internet (ok, maybe I was not searching long enough but I wanted get my hands dirty). It does not follow any recommended benchmarking methodology (warmup period, number of measurements,…) and I was just using 3 micro EC2 instances (that is not optimal neither) in different availability zones.

TEST
So what have I done? Test was to compare raw performance of both solutions without any special features. I just concurrently make single HTTP request to get one HTML page (of size cca. 26KB). I used ApacheBench to make the test with 200 concurrent threads (I have tried also httperf but it looks that it was more CPU demanding so I got lower numbers then with ab).

DIRECT CONNECTION
First I was interested what is the performance of target HTTP server (once again Nginx) without any reverse proxy. Ab was running on one machine and was accessing target server directly.

1
$ ab -n 10000 -c 200 http://target/sample.html
2
 
3
....
4
 
5
Document Path: /sample.html
6
Document Length: 26650 bytes
7
 
8
Total transferred: 268940000 bytes
9
HTML transferred: 266500000 bytes
10
Requests per second: 2928.45 [#/sec] (mean)
11
Time per request: 68.295 [ms] (mean)
12
Time per request: 0.341 [ms] (mean, across all concurrent requests)
13
Transfer rate: 76911.96 [Kbytes/sec] received
14
 
15
Connection Times (ms)
16
 min mean[+/-sd] median max
17
Connect: 4 33 6.0 32 66
18
Processing: 20 35 7.5 35 392
19
Waiting: 20 35 6.4 34 266
20
Total: 24 68 7.8 66 423
21
 
22
Percentage of the requests served within a certain time (ms)
23
 50% 66
24
 66% 67
25
 75% 69
26
 80% 70
27
 90% 74
28
 95% 81
29
 98% 91
30
 99% 92
31
 100% 423 (longest request)
Quiet nice, few more tests shows similar values: 2928 ; 2725 ; 2834 ; 2648 req/s. There are some deviations but this number is not that important now.

VIA NGINX
So now I could setup proxy server (Ubuntu 14.04 LTS) with default nginx installation. I just updated configuration to proxy to target server like:

1
server {
2
   listen 80 default_server;
3
   listen [::]:80 default_server ipv6only=on;
4
 
5
   # Make site accessible from http://localhost/
6
   server_name localhost;
7
 
8
   # allow file upload
9
   client_max_body_size 10M;
10
 
11
   location / {
12
      proxy_set_header X-Real-IP $remote_addr;
13
      proxy_set_header X-Forwarded-For $remote_addr;
14
      proxy_set_header Host $host;
15
      proxy_pass http://target:80;
16
   }
17
}
And run similar test as before

1
$ ab -n 50000 -c 200 http://proxy/sample.html
2
...
3
Server Software: nginx/1.4.6
4
Server Hostname: proxy
5
Server Port: 80
6
 
7
Document Path: /sample.html
8
Document Length: 26650 bytes
9
 
10
Concurrency Level: 200
11
Time taken for tests: 52.366 seconds
12
Complete requests: 50000
13
Failed requests: 0
14
Total transferred: 1344700000 bytes
15
HTML transferred: 1332500000 bytes
16
Requests per second: 954.81 [#/sec] (mean)
17
Time per request: 209.465 [ms] (mean)
18
Time per request: 1.047 [ms] (mean, across all concurrent requests)
19
Transfer rate: 25076.93 [Kbytes/sec] received
20
 
21
Connection Times (ms)
22
 min mean[+/-sd] median max
23
Connect: 3 50 11.7 48 114
24
Processing: 37 159 11.9 160 208
25
Waiting: 36 159 11.9 160 207
26
Total: 40 209 10.4 209 256
27
 
28
Percentage of the requests served within a certain time (ms)
29
 50% 209
30
 66% 212
31
 75% 214
32
 80% 216
33
 90% 220
34
 95% 224
35
 98% 232
36
 99% 238
37
 100% 256 (longest request)
Further results were 954 ; 953 ; 941 req/s. Performance and latency is (as expected) worse.

VIA ZUUL
Now we can use same machine to setup the zuul. Application itself is very simple:

1
@SpringBootApplication
2
@Controller
3
@EnableZuulProxy
4
public class DemoApplication {
5
  public static void main(String[] args) {
6
    new SpringApplicationBuilder(DemoApplication.class).web(true).run(args);
7
  }
8
}
And we just have to define fixed route in application.yml

1
zuul:
2
  routes:
3
    sodik:
4
      path: /sodik/**
5
      url: http://target
And now let’s try to run test.

1
$ ab -n 50000 -c 200 http://proxy:8080/sodik/sample.html
2
 
3
Server Software: Apache-Coyote/1.1
4
Server Hostname: proxy
5
Server Port: 8080
6
 
7
Document Path: /sodik/sample.html
8
Document Length: 26650 bytes
9
 
10
Concurrency Level: 200
11
Time taken for tests: 136.164 seconds
12
Complete requests: 50000
13
Failed requests: 2
14
(Connect: 0, Receive: 0, Length: 2, Exceptions: 0)
15
Non-2xx responses: 2
16
Total transferred: 1343497042 bytes
17
HTML transferred: 1332447082 bytes
18
Requests per second: 367.20 [#/sec] (mean)
19
Time per request: 544.657 [ms] (mean)
20
Time per request: 2.723 [ms] (mean, across all concurrent requests)
21
Transfer rate: 9635.48 [Kbytes/sec] received
22
 
23
Connection Times (ms)
24
min mean[+/-sd] median max
25
Connect: 2 12 92.3 2 1010
26
Processing: 15 532 321.6 461 10250
27
Waiting: 10 505 297.2 441 9851
28
Total: 17 544 333.1 467 10270
29
 
30
Percentage of the requests served within a certain time (ms)
31
50% 467
32
66% 553
33
75% 626
34
80% 684
35
90% 896
36
95% 1163
37
98% 1531
38
99% 1864
39
100% 10270 (longest request)
Result is worse then my (optimistic?) guess. Additionally we can see two failures (and we can see two corresponding exceptions in Zuul log that complains about HTTP pool timeout). Apparently the timeout is set to 10 seconds by default.

So let’s get some more results.

1
Document Path: /sodik/sample.html
2
Document Length: 26650 bytes
3
 
4
Concurrency Level: 200
5
Time taken for tests: 50.080 seconds
6
Complete requests: 50000
7
Failed requests: 0
8
Total transferred: 1343550000 bytes
9
HTML transferred: 1332500000 bytes
10
Requests per second: 998.39 [#/sec] (mean)
11
Time per request: 200.322 [ms] (mean)
12
Time per request: 1.002 [ms] (mean, across all concurrent requests)
13
Transfer rate: 26199.09 [Kbytes/sec] received
14
 
15
Connection Times (ms)
16
min mean[+/-sd] median max
17
Connect: 2 16 7.9 16 126
18
Processing: 15 184 108.1 203 1943
19
Waiting: 13 183 105.9 202 1934
20
Total: 18 200 107.8 218 1983
21
 
22
Percentage of the requests served within a certain time (ms)
23
50% 218
24
66% 228
25
75% 235
26
80% 239
27
90% 254
28
95% 287
29
98% 405
30
99% 450
31
100% 1983 (longest request)
Wow, what an improvement. Only what comes to my mind that Java JIT compilation could help the performance. But to verify if it was just an coincidence, one more attempt: 1010 req/sec. At the end the result is a positive surprise for me.

CONCLUSION
Zuul’s raw performance is very comparative to Nginx – in fact after startup warmup period it is even slightly better in my results (again – see disclaimer – this is not a serious performance test). Nginx shows more predicable performance (lower variation) and (sadly) we have experienced minor glitches (2 out of 150000 requests) during Zuul “warmup” (but your microservices are fault resilient, right? 🙂 )

So if you consider using some of the extra Zuul features or want to gain more from integration with other Netflix services like Eureka for service discovery, Zuul looks very promising as a replacement for ordinary reverse proxy. Maybe it is really used by Netflix 🙂 so you can try it too.