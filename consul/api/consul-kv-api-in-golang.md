
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Introduction](#introduction)
* [Client Object](#client-object)
* [Key/Value Store](#keyvalue-store)
	* [QueryOptions](#queryoptions)
	* [Put](#put)
	* [Get](#get)
	* [Delete](#delete)
	* [Keys](#keys)
	* [List](#list)
	* [DeleteTree](#deletetree)
	* [Primitives for advanced operations](#primitives-for-advanced-operations)
* [Conclusion](#conclusion)

<!-- /code_chunk_output -->

---

* [An introduction to Consul key/value store API in Golang ](http://techblog.zeomega.com/devops/golang/2015/06/09/consul-kv-api-in-golang.html)

An introduction to Consul key/value store API in Golang
Jun 9, 2015 • Baiju Muthukadan

## Introduction
Consul is a tool for service discovery and key value store for configurations. Consul exposes most of its functionalities through a RESTful HTTP API. There are many programming language specific wrappers available for the API. This is a brief overview of Golang package for Consul focusing on basic key/value storage API.

To try the examples given here, you should have Go compiler and Consul installed in your system. Later, you can also install the Go package for Consul using go get:

go get github.com/hashicorp/consul/api
Now we can import the api package and give the name consulapi as alias for better readability.

import (
    consulapi "github.com/hashicorp/consul/api"
)
## Client Object
You can create a new consul client by calling NewClient function with a Config object as argument. An easy way to create Config object is by calling DefaultConfig function and change attribues like Address, Scheme, Datacenter etc.

config := consulapi.DefaultConfig()
config.Address = "192.168.1.2:8500"
consul, err := consulapi.NewClient(config)
In the example given above, Address attribute is changed to a local IP and port. We can also change some of the attributes by setting environment variables. However, the value that you are setting though code will take priority over the value set through environment variable.

These are the available Config object attributes.

Address
Address attribute should be a string value pointing to the address of the Consul server with the format as HOST:PORT. e.g., "192.168.1.2:8500". The value can be provided by setting CONSUL_HTTP_ADDR environment variable. The default value for address is set to 127.0.0.1:8500 and this value should work for most of the cases unless you change the Consul server address.

Scheme
Scheme attribute should be a string value pointing to the URI scheme of the Consul server. The value could be either http or https. The defaul value is set to http. There are two related environment variables to use the https scheme, CONSUL_HTTP_SSL and CONSUL_HTTP_SSL_VERIFY - both are booean values. If CONSUL_HTTP_SSL is set to true, the scheme will be changed to https. The CONSUL_HTTP_SSL_VERIFY can be set to false to skip the SSL verification.

Datacenter
Datacenter to use. If not provided, the default agent datacenter is used.

HttpClient
HttpClient is the client to use. Default will be used if not provided.

HttpAuth
HttpAuth attribute should be a pointer to HttpBasicAuth struct which conatins Username and Password values in string format for HTTP Basic Authentication. Here is an example usage:

config := consulapi.DefaultConfig()
config.HttpAuth = &consulapi.HttpBasicAuth{Username: "guest", Password: "secret"}
consul, err := consulapi.NewClient(config)
The HttpAuth value can be provided through CONSUL_HTTP_AUTH environment variable. The expected format for the environment variable is a coolon separated values of username and password. If colon is not given the entire string is considered as username and password will be empty. Here is two examples:

export CONSUL_HTTP_AUTH=guest:secret
export CONSUL_HTTP_AUTH=guest
WaitTime
WaitTime limits how long a Watch will block. If not provided, the agent default values will be used.

Token
Token is used to provide a per-request ACL token which overrides the agent’s default token.

Using the methods provided by the consul client object, you can access various API end points. We will go through key/value store API end point usage here.

## Key/Value Store
To get the Key/Value object store, call the KV method available for the consul client.

kv := consul.KV()
There are few structs required for CRUD operations with key/value store. The KVPair struct is used to represent a single key/value entry.

type KVPair struct {
    Key         string
    CreateIndex uint64
    ModifyIndex uint64
    LockIndex   uint64
    Flags       uint64
    Value       []byte
    Session     string
}
Key is key, normally this will be a slash serated name. e.g., sites/1/domain
CreateIndex is the index number assigned when the key was first created.
ModifyIndex is the index number assigned when the key was last updated.
LockIndex is an index number created when a new lock acquired on the key/value entry
Flags is can be used by app to set custom value
Value is a byte array of maximum 512kb
Session can be set after creating a session object.
The KVPairs is a list of KVPair reference objects:

type KVPairs []*KVPair
QueryMeta is used to return meta data about a query:

type QueryMeta struct {
    // LastIndex. This can be used as a WaitIndex to perform
    // a blocking query
    LastIndex uint64

    // Time of last contact from the leader for the
    // server servicing the request
    LastContact time.Duration

    // Is there a known leader
    KnownLeader bool

    // How long did the request take
    RequestTime time.Duration
}

### QueryOptions

QueryOptions are used to parameterize a query:

```go
type QueryOptions struct {
    // Providing a datacenter overwrites the DC provided
    // by the Config
    Datacenter string

    // AllowStale allows any Consul server (non-leader) to service
    // a read. This allows for lower latency and higher throughput
    AllowStale bool

    // RequireConsistent forces the read to be fully consistent.
    // This is more expensive but prevents ever performing a stale
    // read.
    RequireConsistent bool

    // WaitIndex is used to enable a blocking query. Waits
    // until the timeout or the next index is reached
    WaitIndex uint64

    // WaitTime is used to bound the duration of a wait.
    // Defaults to that of the Config, but can be overriden.
    WaitTime time.Duration

    // Token is used to provided
    a per-request ACL token
    // which overrides the agent's default token.
    Token string
}
```
### Put

This is the signature of the method:

func (k *KV) Put(p *KVPair, q *WriteOptions) (*WriteMeta, error)
Here is a simple example:

d := &consulapi.KVPair{Key: "sites/1/domain", Value: []byte("example.com")}
kv.Acquire(d, nil)
### Get

This is the signature of the method:

func (k *KV) Get(key string, q *QueryOptions) (*KVPair, *QueryMeta, error)
Here is a simple example:

kvp, qm, error := kv.Get("sites/1/domain", nil)
if err != nil {
    fmt.Println(err)
} else {
    fmt.Println(string(kvp.Value))
}
### Delete

This is the signature of the method:

func (k *KV) Delete(key string, w *WriteOptions) (*WriteMeta, error)
Here is a simple example:

wm, err := kv.Delete("sites/1/domain", nil)
if err != nil {
    fmt.Println(err)
}
### Keys

This is the signature of the method:

func (k *KV) Keys(prefix, separator string, q *QueryOptions) ([]string, *QueryMeta, error)
### List

This is the signature of the method:

func (k *KV) List(prefix string, q *QueryOptions) (KVPairs, *QueryMeta, error)
### DeleteTree

This is the signature of the method:

func (k *KV) DeleteTree(prefix string, w *WriteOptions) (*WriteMeta, error)
Here is a simple example:

wm, err := kv.DeleteTree("sites", nil)
if err != nil {
    fmt.Println(err)
}
### Primitives for advanced operations

There are few other primitives used for advanced operation like complex synchronization and leader election. Those methods are listed here:

Acquire is used for a lock acquisiiton operation. The Key, Flags, Value and Session are respected. Returns true on success or false on failures.

CAS is used for a Check-And-Set operation. The Key, ModifyIndex, Flags and Value are respected. Returns true on success or false on failures.

DeleteCAS is used for a Delete Check-And-Set operation. The Key and ModifyIndex are respected. Returns true on success or false on failures.

Release is used for a lock release operation. The Key, Flags, Value and Session are respected. Returns true on success or false on failures.

## Conclusion
This document coverred the Consul key/value store API using the Golang package. Consul has many other parts apart from key/value store. The Golang wrapper is maintained by the creators of Consul.