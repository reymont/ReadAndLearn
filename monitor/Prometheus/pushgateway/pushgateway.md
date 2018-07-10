
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Pushing metrics | Prometheus](#pushing-metrics-prometheus)
* [Prometheus Pushgateway](#prometheus-pushgateway)
	* [Non-goals](#non-goals)
	* [Run it](#run-it)
		* [Using Docker](#using-docker)
	* [Use it](#use-it)
		* [Configure the Pushgateway as a target to scrape](#configure-the-pushgateway-as-a-target-to-scrape)
		* [Libraries](#libraries)
		* [Command line](#command-line)
		* [About the job and instance labels](#about-the-job-and-instance-labels)
		* [About timestamps](#about-timestamps)
	* [API](#api)
		* [URL](#url)
		* [Deprecated URL](#deprecated-url)
		* [`PUT` method](#put-method)
		* [`POST` method](#post-method)
		* [`DELETE` method](#delete-method)
	* [Development](#development)
	* [Contributing](#contributing)
* [prometheus/client_java:](#prometheusclient_java)
* [Metric types | Prometheus](#metric-types-prometheus)
* [docker](#docker)

<!-- /code_chunk_output -->


# Pushing metrics | Prometheus 
https://prometheus.io/docs/instrumenting/pushing/

PUSHING METRICS
Occasionally you will need to monitor components which cannot be scraped. They might live behind a firewall, or they might be too short-lived to expose data reliably via the pull model. The Prometheus Pushgateway allows you to push time series from these components to an intermediary job which Prometheus can scrape. Combined with Prometheus's simple text-based exposition format, this makes it easy to instrument even shell scripts without a client library.

* For more information on using the Pushgateway and use from a Unix shell, see the project's [README.md](https://github.com/prometheus/pushgateway/blob/master/README.md).
* For use from Java see the [PushGateway](https://prometheus.io/client_java/io/prometheus/client/exporter/PushGateway.html) class.
* For use from Go see the [Push](http://godoc.org/github.com/prometheus/client_golang/prometheus#Push) and [PushAdd](http://godoc.org/github.com/prometheus/client_golang/prometheus#PushAdd) functions.
* For use from Python see [Exporting to a Pushgateway](https://github.com/prometheus/client_python#exporting-to-a-pushgateway).
* For use from Ruby see the [Pushgateway documentation](https://github.com/prometheus/client_ruby#pushgateway).

Java batch job example
This example illustrates how to instrument a batch job and alert on it not having succeeded recently.

If using Maven, add the following to pom.xml:

```xml
        <dependency>
            <groupId>io.prometheus</groupId>
            <artifactId>simpleclient</artifactId>
            <version>0.0.10</version>
        </dependency>
        <dependency>
            <groupId>io.prometheus</groupId>
            <artifactId>simpleclient_pushgateway</artifactId>
            <version>0.0.10</version>
        </dependency>
```
Instrument your batch job's code:
```java
import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.Gauge;
import io.prometheus.client.exporter.PushGateway;

void executeBatchJob() throws Exception {
 CollectorRegistry registry = new CollectorRegistry();
 Gauge duration = Gauge.build()
     .name("my_batch_job_duration_seconds")
     .help("Duration of my batch job in seconds.")
     .register(registry);
 Gauge.Timer durationTimer = duration.startTimer();
 try {
   // Your code here.

   // This is only added to the registry after success,
   // so that a previous success in the Pushgateway is not overwritten on failure.
   Gauge lastSuccess = Gauge.build()
       .name("my_batch_job_last_success_unixtime")
       .help("Last time my batch job succeeded, in unixtime.")
       .register(registry);
   lastSuccess.setToCurrentTime();
 } finally {
   durationTimer.setDuration();
   PushGateway pg = new PushGateway("127.0.0.1:9091");
   pg.pushAdd(registry, "my_batch_job");
 }
}
```
Set up a Pushgateway and update the host and port in the above code if needed.

Set up an alert to fire if the job has not run recently. Add the following to the rules of a Prometheus server that is scraping the Pushgateway:
```yml
ALERT MyBatchJobNotCompleted
  IF min(time() - my_batch_job_last_success_unixtime{job="my_batch_job"}) > 60 * 60
  FOR 5m
  WITH { severity="page" }
  SUMMARY "MyBatchJob has not completed successfully in over an hour"
```


# Prometheus Pushgateway
prometheus/pushgateway: push acceptor for ephemeral and batch jobs https://github.com/prometheus/pushgateway

The Prometheus Pushgateway exists to allow ephemeral and batch jobs to
expose their metrics to Prometheus. Since these kinds of jobs may not
exist long enough to be scraped, they can instead push their metrics
to a Pushgateway. The Pushgateway then exposes these metrics to
Prometheus.

## Non-goals

The Pushgateway is explicitly not an _aggregator or distributed counter_ but
rather a metrics cache. It does not have
[statsd](https://github.com/etsy/statsd)-like semantics. The metrics pushed are
exactly the same as you would present for scraping in a permanently running
program.

For machine-level metrics, the
[textfile](https://github.com/prometheus/node_exporter/blob/master/README.md#textfile-collector)
collector of the Node exporter is usually more appropriate. The Pushgateway is
intended for service-level metrics.

The Pushgateway is not an _event store_. While you can use Prometheus as a data
source for
[Grafana annotations](http://docs.grafana.org/reference/annotations/), tracking
something like release events has to happen with some event-logging framework.


## Run it

Download binary releases for your platform from the
[release page](https://github.com/prometheus/pushgateway/releases) and unpack
the tarball.

If you want to compile yourself from the sources, you need a working Go
setup. Then use the provided Makefile (type `make`).

For the most basic setup, just start the binary. To change the address
to listen on, use the `-web.listen-address` flag. By default, Pushgateway 
does not persist metrics. However, the `-persistence.file` flag
allows you to specify a file in which the pushed metrics will be
persisted (so that they survive restarts of the Pushgateway).

### Using Docker

You can deploy the Pushgateway using the [prom/pushgateway](https://registry.hub.docker.com/u/prom/pushgateway/) Docker image.

For example:

```bash
docker pull prom/pushgateway

docker run -d -p 9091:9091 prom/pushgateway
```

## Use it

### Configure the Pushgateway as a target to scrape

The Pushgateway has to be configured as a target to scrape by Prometheus, using
one of the usual methods. _However, you should always set `honor_labels: true`
in the scrape config_ (see [below](#about-the-job-and-instance-labels) for a
detailed explanation).

### Libraries

Prometheus client libraries should have a feature to push the
registered metrics to a Pushgateway. Usually, a Prometheus client
passively presents metric for scraping by a Prometheus server. A
client library that supports pushing has a push function, which needs
to be called by the client code. It will then actively push the
metrics to a Pushgateway, using the API described below.

### Command line

Using the Prometheus text protocol, pushing metrics is so easy that no
separate CLI is provided. Simply use a command-line HTTP tool like
`curl`. Your favorite scripting language has most likely some built-in
HTTP capabilities you can leverage here as well.

*Caveat: Note that in the text protocol, each line has to end with a
line-feed character (aka 'LF' or '\n'). Ending a line in other ways,
e.g. with 'CR' aka '\r', 'CRLF' aka '\r\n', or just the end of the
packet, will result in a protocol error.*

Examples:

* Push a single sample into the group identified by `{job="some_job"}`:

        echo "some_metric 3.14" | curl --data-binary @- http://pushgateway.example.org:9091/metrics/job/some_job

  Since no type information has been provided, `some_metric` will be of type `untyped`.

* Push something more complex into the group identified by `{job="some_job",instance="some_instance"}`:

        cat <<EOF | curl --data-binary @- http://pushgateway.example.org:9091/metrics/job/some_job/instance/some_instance
        # TYPE some_metric counter
        some_metric{label="val1"} 42
        # TYPE another_metric gauge
        # HELP another_metric Just an example.
        another_metric 2398.283
        EOF

  Note how type information and help strings are provided. Those lines
  are optional, but strongly encouraged for anything more complex.

* Delete all metrics grouped by job and instance:

        curl -X DELETE http://pushgateway.example.org:9091/metrics/job/some_job/instance/some_instance

* Delete all metrics grouped by job only:

        curl -X DELETE http://pushgateway.example.org:9091/metrics/job/some_job

### About the job and instance labels

The Prometheus server will attach a `job` label and an `instance` label to each
scraped metric. The value of the `job` label comes from the scrape
configuration. When you configure the Pushgateway as a scrape target for your
Prometheus server, you will probably pick a job name like `pushgateway`. The
value of the `instance` label is automatically set to the host and port of the
target scraped. Hence, all the metrics scraped from the Pushgateway will have
the host and port of the Pushgateway as the `instance` label and a `job` label
like `pushgateway`. The conflict with the `job` and `instance` labels you might
have attached to the metrics pushed to the Pushgateway is solved by renaming
those labels to `exported_job` and `exported_instance`.

However, this behavior is usually undesired when scraping a
Pushgateway. Generally, you would like to retain the `job` and `instance`
labels of the metrics pushed to the Pushgateway. That's why you have set
`honor_labels: true` in the scrape config for the Pushgateway. It enables the
desired behavior. See the
[documentation](https://prometheus.io/docs/operating/configuration/#scrape_config)
for details.

This leaves us with the case where the metrics pushed to the Pushgateway do not
feature an `instance` label. This case is quite common as the pushed metrics
are often on a service level and therefore not related to a particular
instance. Even with `honor_labels: true`, the Prometheus server will attach an
`instance` label if no `instance` label has been set in the first
place. Therefore, if a metric is pushed to the Pushgateway without an instance
label (and without instance label in the grouping key, see below), the
Pushgateway will export it with an emtpy instance label (`{instance=""}`),
which is equivalent to having no `instance` label at all but prevents the
server from attaching one.

### About timestamps

If you push metrics at time *t*<sub>1</sub>, you might be tempted to believe
that Prometheus will scrape them with that same timestamp
*t*<sub>1</sub>. Instead, what Prometheus attaches as a timestamp is the time
when it scrapes the Pushgateway. Why so?

In the world view of Prometheus, a metric can be scraped at any
time. A metric that cannot be scraped has basically ceased to
exist. Prometheus is somewhat tolerant, but if it cannot get any
samples for a metric in 5min, it will behave as if that metric does
not exist anymore. Preventing that is actually one of the reasons to
use a Pushgateway. The Pushgateway will make the metrics of your
ephemeral job scrapable at any time. Attaching the time of pushing as
a timestamp would defeat that purpose because 5min after the last
push, your metric will look as stale to Prometheus as if it could not
be scraped at all anymore. (Prometheus knows only one timestamp per
sample, there is no way to distinguish a 'time of pushing' and a 'time
of scraping'.)

As there are essentially no use cases where it would make sense to to attach a
different timestamp, and many users attempting to incorrectly do so (despite no
client library supporting this) any pushes with timestamps will be rejected.

If you think you need to push a timestamp, please see [When To Use The
Pushgateway](https://prometheus.io/docs/practices/pushing/).

In order to make it easier to alert on pushers that have not run recently, the
Pushgateway will add in a metric `push_time_seconds` with the Unix timestamp
of the last `POST`/`PUT` to each group. This will override any pushed metric by
that name.

## API

All pushes are done via HTTP. The interface is vaguely REST-like.

### URL

The default port the push gateway is listening to is 9091. The path looks like

    /metrics/job/<JOBNAME>{/<LABEL_NAME>/<LABEL_VALUE>}

`<JOBNAME>` is used as the value of the `job` label, followed by any
number of other label pairs (which might or might not include an
`instance` label). The label set defined by the URL path is used as a
grouping key. Any of those labels already set in the body of the
request (as regular labels, e.g. `name{job="foo"} 42`)
_will be overwritten to match the labels defined by the URL path!_

Note that `/` cannot be used as part of a label value or the job name,
even if escaped as `%2F`. (The decoding happens before the path
routing kicks in, cf. the Go documentation of
[`URL.Path`](http://golang.org/pkg/net/url/#URL).)

### Deprecated URL

There is a _deprecated_ version of the URL path, using `jobs` instead
of `job`:

    /metrics/jobs/<JOBNAME>[/instances/<INSTANCENAME>]

If this version of the URL path is used _with_ the `instances` part,
it is equivalent to the URL path above with an `instance` label, i.e.

    /metrics/jobs/foo/instances/bar

is equivalent to

    /metrics/job/foo/instance/bar

(Note the missing pluralizations.)

However, if the `instances` part is missing, the Pushgateway will
automatically use the IP number of the pushing host as the 'instance'
label, and grouping happens by 'job' and 'instance' labels.

Example: Pushing metrics from host 1.2.3.4 using the deprecated URL path

    /metrics/jobs/foo

is equivalent to pushing using the URL path

    /metrics/job/foo/instance/1.2.3.4

### `PUT` method

`PUT` is used to push a group of metrics. All metrics with the
grouping key specified in the URL are replaced by the metrics pushed
with `PUT`.

The body of the request contains the metrics to push either as delimited binary
protocol buffers or in the simple flat text format (both in version 0.0.4, see
the
[data exposition format specification](https://docs.google.com/document/d/1ZjyKiKxZV83VI9ZKAXRGKaUKK2BIWCT7oiGBKDBpjEY/edit?usp=sharing)).
Discrimination between the two variants is done via the `Content-Type`
header. (Use the value `application/vnd.google.protobuf;
proto=io.prometheus.client.MetricFamily; encoding=delimited` for protocol
buffers, otherwise the text format is tried as a fall-back.)

The response code upon success is always 202 (even if the same
grouping key has never been used before, i.e. there is no feedback to
the client if the push has replaced an existing group of metrics or
created a new one).

_If using the protobuf format, do not send duplicate MetricFamily
proto messages (i.e. more than one with the same name) in one push, as
they will overwrite each other._

A successfully finished request means that the pushed metrics are
queued for an update of the storage. Scraping the push gateway may
still yield the old results until the queued update is
processed. Neither is there a guarantee that the pushed metrics are
persisted to disk. (A server crash may cause data loss. Or the push
gateway is configured to not persist to disk at all.)

A `PUT` request with an empty body effectively deletes all metrics with the
specified grouping key. However, in contrast to the
[`DELETE` request](#delete-method) described below, it does update the
`push_time_seconds` metrics.

### `POST` method

`POST` works exactly like the `PUT` method but only metrics with the
same name as the newly pushed metrics are replaced (among those with
the same grouping key).

A `POST` request with an empty body merely updates the `push_time_seconds`
metrics but does not change any of the previously pushed metrics.

### `DELETE` method

`DELETE` is used to delete metrics from the push gateway. The request
must not contain any content. All metrics with the grouping key
specified in the URL are deleted.

The response code upon success is always 202. The delete
request is merely queued at that moment. There is no guarantee that the
request will actually be executed or that the result will make it to
the persistence layer (e.g. in case of a server crash). However, the
order of `PUT`/`POST` and `DELETE` request is guaranteed, i.e. if you
have successfully sent a `DELETE` request and then send a `PUT`, it is
guaranteed that the `DELETE` will be processed first (and vice versa).

Deleting a grouping key without metrics is a no-op and will not result
in an error.

**Caution:** Up to version 0.1.1 of the Pushgateway, a `DELETE` request
using the following path in the URL would delete _all_ metrics with
the job label 'foo':

    /metrics/jobs/foo

Newer versions will interpret the above URL path as deprecated (see
above). Consequently, they will add the IP number of the client as an
instance label and then delete all metrics with the corresponding job
and instance label as their grouping key.

## Development

The normal binary embeds the files in `resources`. For development
purposes, it is handy to have a running binary use those files
directly (so that you can see the effect of changes immediately). To
switch to direct usage, type `make bindata-debug` just before
compiling the binary. Switch back to "normal" mode by typing `make
bindata-embed`. (Just `make` after a resource has changed will result
in the same.)

##  Contributing

Relevant style guidelines are the [Go Code Review
Comments](https://code.google.com/p/go-wiki/wiki/CodeReviewComments)
and the _Formatting and style_ section of Peter Bourgon's [Go:
Best Practices for Production
Environments](http://peter.bourgon.org/go-in-production/#formatting-and-style).

[travis]: https://travis-ci.org/prometheus/pushgateway
[hub]: https://hub.docker.com/r/prom/pushgateway/
[circleci]: https://circleci.com/gh/prometheus/pushgateway
[quay]: https://quay.io/repository/prometheus/pushgateway


# prometheus/client_java: 
Prometheus instrumentation library for JVM applications 
https://github.com/prometheus/client_java


# Metric types | Prometheus 
https://prometheus.io/docs/concepts/metric_types/


# docker 

https://hub.docker.com/r/prom/pushgateway/

```sh
docker pull prom/pushgateway
docker run -d -p 9091:9091 --restart=always\
  --name pushgateway prom/pushgateway;docker logs -f pushgateway
# http://192.168.31.212:9091/metrics
# http://192.168.31.212:9091
```

```dockerfile
FROM       ubuntu
MAINTAINER Prometheus Team <prometheus-developers@googlegroups.com>
EXPOSE     9091
WORKDIR    /pushgateway
ENTRYPOINT [ "/pushgateway/bin/pushgateway" ]

RUN        apt-get -qy update && apt-get install -yq make git curl sudo mercurial vim-common
ADD        . /pushgateway
RUN        make bin/pushgateway
```