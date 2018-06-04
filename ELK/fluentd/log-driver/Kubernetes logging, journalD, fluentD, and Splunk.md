

https://github.com/kubernetes/kubernetes/issues/24677


In order to run k8s in our environment, I need to get logging information into Splunk. I need to pick up node logs AND application logs. I know at this point there is no drop-in solution, so I know i'll need to hack something together.

What I'm seeking in this issue is not a 'here's the solution', though that would be great of course.

I'm seeking advice on which of several solutions I've come up with are most likely to work, given how Kubernetes is evolving.

Research and references

Issue #1071 seems to have resulted in the current ability to choose 'elasticsearch' as a provider in kube-up.sh

Issue #17183 seems to indicate that the future is not yet clear.

Issue #23782 contemplates some limitations of the current approach also

Issue #21285 provides a proxy to send data to AWS instead of ES

Based on many sources, it seems clear that systemd/journalctl is the future of logging in *nix. latest versions of RHEL/Centos/Fedora and Ubuntu have moved this way.

While i'm of course willing to hack, i'd really rather avoid needing to re-build the k8s images if possible.

# Option 1 -- k8s->fluentd-->splunk

I could use fluentd, and then use a fluentd splunk plugin. If I use kube-up.sh with KUBERNETES_LOGGING_DESTINATION='elasticsearch', I get a fluentd/ES setup. There are plugins for fluentd that can forward content on to splunk.

But i do not know how i would configure k8s to NOT install elasticsearch as a part of startup. I also think this represents an extra layer of forwarding i'd rather avoid. With this solution, I think i would need to send all application output to STDOUT/STDERR, since this is how k8s currently gathers stuff. This solution does not use journald, which causes me to think this option is a doomed-to-change-in-the-near-future. Which leads me to option 2

# Option 2-- k8s->journald, docker->journald

I could forward all logs ( from the nodes and pods too ) to journalD using the docker journald log driver, and then capture data out of the journald logs and send to splunk from there. Honestly this seems like the 'right' solution. Why re-invent logging capture? If not already true, any strong security setup is going to require use of centralized logging capture, and that will need to be based on journald.

There are two problems with this, though:

doing it this way will not allow kubernetes metadata to be included in the log stream, and
I believe this will break kubectl logs, because it relies on the docker json logs.

# Option 3 -- docker -> k8s -> journald

Logging directly from docker to journald means there isnt a chance to add k8s meta. What might be the coolest option is if k8s provided a docker logging driver that then proxies the data and sends it to journald. That way, as a system administrator, i just need to go to one place to get all my logs-- the journald service on each node. But i still get the k8s metadata too.

I have no reasonable ability to execute this option though, it would be a big change. But i'd be willing to help if this is a good way to do it.

# Option 4-- splunk docker log driver

Splunk has an experimental log driver I could use. But it doesnt allow k8s to see the data, or to enrich it ( IE, it will certainly break k8s logs ). This might work as a workaround, but it is not appealing.

http://blogs.splunk.com/2015/12/16/splunk-logging-driver-for-docker/

Closing Thoughts

If option 1 is the best, I could use some ideas about how i could get K8s to start up fluentD, but NOT start elasticsearch.

If option 2 is best, I could use some help pointing me in the right direction about how to avoid breaking kubernetes when i configure the docker daemons on the nodes to send logs to journald instead of the json logs.

if option 3 is best, I need some pointers on how I could contribute.

Thanks for insights you can offer.