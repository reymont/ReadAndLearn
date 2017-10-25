
* [Yelp/paasta: An open, distributed platform as a service ](https://github.com/Yelp/paasta)

* Components

Note: PaaSTA is an opinionated platform that uses a few un-opinionated tools. It requires a non-trivial amount of infrastructure to be in place before it works completely:

  * Docker for code delivery and containment
  * Mesos for code execution and scheduling (runs Docker containers)
  * Marathon for managing long-running services
  * Chronos for running things on a timer (nightly batches)
  * SmartStack for service registration and discovery
  * Sensu for monitoring/alerting
  * Jenkins (optionally) for continuous deployment