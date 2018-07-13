

# Deploying https://amdatu.org/infra/deploying/

DEPLOYING
Amdatu offers 2 complementary components which offer blue-green deployments for Kubernetes. The Amdatu Kubernetes Deployer is a tool written in Go and is doing the actual work. It offers a REST API for managing application descriptors and running the deployments.

Amdatu Kubernetes DeploymentCtl offers a UI for the Kubernetes Deployer. It’s splitted in a Java backend which serves the frontend and proxies most request to the deployer, and a Angular frontend.


# https://amdatu.org/infra/deploying/deployer/

Amdatu Kubernetes Deployer

Introduction

Amdatu Kubernetes Deployer is a component to orchestrate Kubernetes deployments with the following features:

Blue-green deployment

Ingress configuration

Management of application descriptors

Management of deployments

Health checks during deployment

Injecting environment variables into pods

The component is built on top of the Kubernetes API. It provides a REST API for management of descriptors and deployments, and a Websocket API for streaming logs during a deployment.

The Amdatu Kubernetes Deployer is typically used together with Amdatu Kubernetes Deploymentctl, which provides a UI for the Deployer’s functionality and some more features. But the Deployer can also be invoked directly as part of a build pipeline via its REST API.

The Deployer is used in several production environments, and is actively maintained.

Architectural Overview

overview

Related components

As already mentioned, Amdatu Kubernetes DeploymentCtl provides a UI for the Deployer, but is loosely coupled only, and the Deployer can be used standalone.

Load balancing

To make applications available to the internet, you need a load balancer. Amdatu Kubernetes Deployer is using Kubernetes Ingresses for exposing the deployed applications. In order to use them you need deploy a Ingress Controller (preferable the Nginx controller, because the Deployer uses some Nginx specific features at the moment; other controllers might work as well but are not supported). How the Ingress Controller is exposed to the internet depends on environment: on cloud providers you probably want to expose it with the cloud specific loadbalancer, on other environments it might be enough to expose it with a NodePort service.

Note: earlier versions of the Deployer used a custom setup of a HAProxy Loadbalancer and more Amdatu Kubernetes components for dynamic reconfiguration of HAProxy. That setup was deprecated in favour of using K8s native Ingresses and the Nginx Ingress Controller, and the corresponsing code will be removed soonish!

Usage

Running

Docker
For first quick tests of the Deployer just run it in a Docker container:

docker run -p 8000:8000 amdatu/amdatu-kubernetes-deployer:production -kubernetes http://[kubernetes-api-server]:8080 -etcd http://[etcd-server]:2379
Kubernetes
For longer usage it makes a lot of sense to deploy the Deployer into your K8s cluster, in order to benefit from it’s capabilities of running containers in a fail save way. This is an example deployment and service:

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: deployer
  name: deployer
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: deployer
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: deployer
    spec:
      containers:
      - args:
        - -etcd
        - http://[etcd-server]:2379
        - -kubernetes
        - http://[kubernetes-api-server]:8080
        image: amdatu/amdatu-kubernetes-deployer:production
        imagePullPolicy: Always
        name: deployer
        ports:
        - containerPort: 8000
          name: deployer
          protocol: TCP
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
      dnsPolicy: ClusterFirst
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: deployer
  namespace: kube-system
spec:
  ports:
  - name: deployer
    port: 8000
    protocol: TCP
    targetPort: 8000
  selector:
    app: deployer
  sessionAffinity: None
  type: NodePort
This will make the Deployer available on the cluster internal network on deployer.kube-system.svc.cluster.local:8000, and externally on any cluster node on the dynamically assigned NodePort (find it with kubectl -n kube-system get svc deployer).

Application descriptors

Schema
The following JSON represents an application descriptor, which describes how to deploy your application:

{
    "id": "<unique id>",                       // will be set by deployer when creating a new descriptor
    "namespace": "default",                    // k8s namespace, required
    "appName": "my-app",                       // the name of your app, required, must comply to https://github.com/kubernetes/community/blob/master/contributors/design-proposals/identifiers.md
    "newVersion": "#",                         // version, use "#" for an autoincrement (on each deployment) number
    "created": "2017-01-15T02:02:14Z",         // creation timestamp, set by deployer
    "lastModified": "2017-02-08T08:54:01Z"`    // modification timestamp, set by deployer
    "webhooks": [                              // webhook identifier(s) for automated redeployments, not used by deployer, but deploymentctl
        {
            "key": "<unique id>",              // required
            "description": "..."               // optional, for your own usage
        }
    ],
    "deploymentType": "blue-green",            // rollout strategy, optional, defaults to blue-green, the only supported type atm
    "replicas": 2,                             // number of pods which should be started, optional, defaults to 1
    "frontend": "example.com",                 // domain for the proxy config, optional (if not set, no Ingress will be created)
    "redirectWww": "<boolean>"                 // if true the "www" subdomain will be redirected automatically to given frontend domain, defaults to false
    "useCompression": "<boolean>"              // if true gzip compression will be enabled, defaults to false
    "additionHttpHeaders": [                   // http headers, which should be set by proxy on every response, optional
        {
            "Header": "X-TEST",
            "Value": "some http header test"
        }
    ],
    "useHealthCheck": true,                    // whether the app supports health checks
    "healthCheckPort": 9999,                   // the healthcheck port, required if "useHealthCheck" is true
    "healthCheckPath": "health",               // the healthcheck path, required if "useHealthCheck" is true
    "healthCheckType": "probe|simple",         // the healthcheck type, see below, required if "useHealthCheck" is true
    "ignoreHealthCheck": true,                 // whether to ignore the healthcheck during deployments (healthcheck still might be used by other monitoring tools)
    "imagePullSecrets" : [                     // secrets for private docker repository credentials, optional
        {
            "name": "secretName"               // name of the secret holding the credentials
        }
    ]
    "podspec": {
        ...                                    // the K8s PodSpec as in http://kubernetes.io/docs/api-reference/v1/definitions/#_v1_podspec
    }
}
Health checks

Health checks should be implemented as part of the application. They help the deployer (and potentially other tools) to determine when and if your application is started and healthy. When health checks are enabled, the Amdatu Kubernetes Deployer expects them on <healthCheckPath> in the first container in the pod. When multiple ports are configured in the container, the health check port should be named healthcheck. If no ports are configured in on container, port 9999 is assumed. (Note: since this "algorithm" is confusing, there will probably a change on this in the near future…​)

There are two healthcheck types, probe and simple:

probe: The healthcheck endpoint should return JSON in the following format: { "healthy" : true|false } Additional properties are allowed, but ignored by the Amdatu Kubernetes Deployer.

simple: The healthcheck endpoint should return a 2xx status code for healthy apps, anything else if unhealthy.

Manage descriptors
The deployer offers a REST API for creating, updating and deleting desciptors:

Resource	Method	Description	Returns
/descriptors/?namespace={namespace}

POST

Create new deployment descriptor, JSON formatted descriptor in the POST bodyno deployment is triggered

201 with Location header pointing to new descriptor401 not authenticated403 no access to namespace400 bad request (malformed deployment descriptor)

/descriptors/?namespace={namespace}[&appname={appname}]

GET

Get all descriptorsoptionally provide additional appname filter

200 with list of descriptors, can be empty401 not authenticated403 no access to namespace

/descriptors/{id}/?namespace={namespace}

GET

Get descriptor with given id

200 with descriptor401 not authenticated403 no access to namespace404 descriptor not found

/descriptors/{id}/?namespace={namespace}

PUT

Update descriptor, JSON formatted descriptor in the POST bodyno (re-)deployment is triggered

204 success no content401 not authenticated403 no access to namespace404 descriptor not found

/descriptors/{id}/?namespace={namespace}

DELETE

Delete descriptorno undeployment is triggered

200 success no content401 not authenticated403 no access to namespace404 descriptor not found

Deployments

Schema
Based on an existing descriptor you can start a deployment. That will create a deployment resource in this format:

{
    "id": "<unique id>",                                              // will be set by deployer during deployment
    "created": "2017-01-15T02:02:14Z",                                // creation timestamp, set by deployer
    "lastModified": "2017-02-08T08:54:01Z"                            // modification timestamp, set by deployer
    "version": "<version>",                                           // deployment version, set by deployer based on descriptor's version field
    "status": "DEPLOYING|DEPLOYED|UNDEPLOYING|UNDEPLOYED|FAILURE",    // deployment status, set by deployer
    "descriptor": {                                                   // a copy(!) of the descriptor used for the deployment
        ...
    }
}
Deploying
The deployer offers a REST API for deploying apps based on the deployment descriptor, and for getting logs and healthcheck data:

Resource	Method	Description	Returns
/deployments/?namespace={namespace}&descriptorId={descriptorId}

POST

Trigger a deploymentwill create a deployment resourceyou can poll the created deployment resource for the current status, logs and healthcheck data

202 deployment started, with Location header pointing to deployment401 not authenticated403 no access to namespace404 descriptor not found

/deployments/?namespace={namespace}[&appname={appname}]

GET

Get all deploymentsoptionally provide appname filter

200 with list of descriptors, can be empty401 not authenticated403 no access to namespace (with filter only)

/deployments/{id}/?namespace={namespace}

GET

Get deployment

200 deployment resource found (check deployment status if (un-)deployment is running / was successfull)401 not authenticated403 no access to namespace404 deployment not found

/deployments/{id}/logs?namespace={namespace}

GET

Get deployment logslogs are updated constantly during (un)deployments

200 deployment logs found401 not authenticated403 no access to namespace404 deployment not found

/deployments/{id}/healthcheckdata?namespace={namespace}

GET

Get deployment healthcheckdatahealthcheckdata is updated at the end of a deployment

200 deployment healthcheckdata found401 not authenticated403 no access to namespace404 deployment not found

/deployments/{id}/?namespace={namespace}

PUT

Redeploy this deploymentempty body

202 redeployment started, with Location header pointing to new deployment401 not authenticated403 no access to namespace404 deployment not found

/deployments/{id}/?namespace={namespace}[&deleteDeployment=\{true

false}]

DELETE

Trigger a undeployment and / or deletion of the deployment resourceif the deployment is deployed, it will be undeployed.Poll deployment for status until it returns a UNDEPLOYEDif deleteDeployment is true, also the deployment resource itself will be deleted, and polling it will result in a 404 when undeployment and deletion is done

Used K8s resources

For each deployment the following resources are created in Kubernetes.

Resource	Name	Description
Service

appName

Service that is not versioned. This service can be used from other components, because it stays around between deployments.

Service

appName-version

Service that is versioned. This service is used by the load balancer. Each deployment will create a new versioned service

ReplicationController

appName-version

Replication controller for the specific version of the deployment. Each deployment will create a new replication controller

Ingress

appName

Ingress which points to the versioned service.

Environment variables

It’s possible to inject extra environment variables into pods, which are not defined in the deployment descriptor. This is useful if pods need to discover certain infrastructure services outside Kubernetes, without the need to put them in the deployment descriptor. To inject an environment variable, a key has to be created in etcd:

/deployer/environment/[mykey]
The key will be the environment variable name, the value of the etcd key will be the value of the environment variable.

Authentication and authorization

For authentication against the Kubernetes API, basic authentication is supported. Credentials need to be provided as program arguments.

Authentication and authorization for the REST API is not implemented yet, but will be based on JWT, like it is already done in DeploymentCtl.

Getting involved

Issue Tracker

Bug reports and feature requests and of course pull requests are greatly appreciated!

CI

The deployer is built using Bitbucket Pipelines (see bitbucket-pipelines.yml and build.sh), which results in executables which can be downloaded on the Bitbucket Download Section, and in Docker images, see Docker Hub.

Versioning

The binaries are named and the docker images are tagged using a alpha/beta/production scheme:

Every push to master result in a alpha version and a version with the current git hash.

Every git tag results in a version with the same name, reusing the already build git hash based artifacts from the alpha step. We use beta and production tags, which will be moved for every new beta/production version.

For the production tag there will also be an additional tag, which represents a version number, following semantic versioning scheme, which will not be moved.

On docker hub the production image tag will also result in the latest image tag

Dependency management

This repository uses Godep for go dependency management. In short this means:

Install Godep:

Run go get github.com/tools/godep

Add a new dependency:

Run go get foo/bar

Use new dependency

Run godep save ./…​

Update an existing dependency:

Run go get -u foo/bar

Run godep update foo/bar

Testing

On order to run the integrationtests, you first need to run the deployer as described above, and then start the tests with:

go test testing/deployment_test.go -deployer http://[deployerhost]:8000/ -kubernetes http://[kubernetes-api-server]:8080 -etcd http://[etcd-server]:2379 -concurrent 5