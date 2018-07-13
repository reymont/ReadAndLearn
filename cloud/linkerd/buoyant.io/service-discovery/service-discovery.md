

# https://buoyant.io/2016/10/10/linkerd-on-dcos-for-service-discovery-and-visibility/

Why not DNS?

An analogous system to service discovery is DNS. DNS was designed to answer a similar question: given the hostname of a machine, e.g. buoyant.io, what is the IP address of that host? In fact, DNS can be used as a basic form of service discovery, and DC/OS ships with Mesos-DNS out of the box.

Although DNS is widely supported and easy to get started with, in practice, it is difficult to use DNS for service discovery at scale. First, DNS is primarily used to locate services with “well-known” ports, e.g. port 80 for web servers, and extending it to handle arbitrary ports is difficult (while SRV records exist for this purpose, library support for them is spotty). Second, DNS information is often aggressively cached at various layers in the system (the operating system, the JVM, etc.), and this caching can result in stale data when used in highly dynamic systems like DC/OS.

As a result, most systems that operate in scheduled environments rely on a dedicated service discovery system such as ZooKeeper, Consul, or etcd. Fortunately, on DC/OS, Marathon itself can act as source of service discovery information, eliminating much of the need to run one of these separate systems- at least, if you have a good way of connecting your application to Marathon. Enter Linkerd!