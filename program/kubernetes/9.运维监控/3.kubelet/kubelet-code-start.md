
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [简介](#简介)
* [关键结构](#关键结构)
* [Kubelet启动流程](#kubelet启动流程)
	* [main 入口](#main-入口)
	* [app.Run()](#apprun)
	* [RunKubelet](#runkubelet)
	* [kubelet.NewMainKubelet](#kubeletnewmainkubelet)
	* [startKubelet](#startkubelet)
	* [k.Run](#krun)

<!-- /code_chunk_output -->
---

* [Kubelet源码分析(一):启动流程分析 - kubernetes - SegmentFault ](https://segmentfault.com/a/1190000008267351)


## 简介
在Kubernetes急群众，在每个Node节点上都会启动一个kubelet服务进程。该进程用于处理Master节点下发到本节点的任务，管理Pod及Pod中的容器。每个Kubelet进程会在APIServer上注册节点自身信息，定期向Master节点汇报节点资源的使用情况，并通过cAdvise监控容器和节点资源。

## 关键结构
```go
KubeletConfiguration
type KubeletConfiguration struct {
    // kubelet的参数配置文件
    Config string `json:"config"`
    // kubelet支持三种源数据：
    // 1. ApiServer： kubelet通过ApiServer监听etcd目录，同步Pod清单
    // 2. file： 通过kubelet启动参数"--config"指定配置文件目录下的文件
    // 3. http URL： 通过"--manifest-url"参数设置
    // 所以下面会有三种同步的频率配置
    // 同步容器和配置的频率。
    SyncFrequency unversioned.Duration `json:"syncFrequency"`
    // 文件检查频率
    FileCheckFrequency unversioned.Duration `json:"fileCheckFrequency"`
    // Http模式检查频率
    HTTPCheckFrequency unversioned.Duration `json:"httpCheckFrequency"`
    // 该参数设置HTTP模式下的endpoint
    ManifestURL string `json:"manifestURL"`

    ManifestURLHeader string `json:"manifestURLHeader"`
    // 是否需要开启kubelet Server，就是指下列的10250端口
    EnableServer bool `json:"enableServer"`
    // kubelet服务地址
    Address string `json:"address"`
    // kubelet服务端口，默认10250
    // 别的服务端口如下：
    // -->Scheduler服务端口：10251
    // -->ControllerManagerPort: 10252
    Port uint `json:"port"`

    // kubelet服务的只读端口，没有任何认证(0：disable)。默认为10255
    // 该功能只要配置端口，就必定开启服务
    ReadOnlyPort uint `json:"readOnlyPort"`

    // 证书相关：
    TLSCertFile string `json:"tLSCertFile"`

    TLSPrivateKeyFile string `json:"tLSPrivateKeyFile"`

    CertDirectory string `json:"certDirectory"`
    // 用于识别kubelet的hostname，代替实际的hostname
    HostnameOverride string `json:"hostnameOverride"`
    // 指定创建Pod时的基础镜像
    PodInfraContainerImage string `json:"podInfraContainerImage"`
    // 配置kubelet需要交互的docker的endpoint
    // 比如：unix:///var/run/docker.sock, 这个是默认的Linux配置
    DockerEndpoint string `json:"dockerEndpoint"`
    // kubelet的volume、mounts、配置目录路径
    // 默认是/var/lib/kubelet
    RootDirectory string `json:"rootDirectory"`
    
    SeccompProfileRoot string `json:"seccompProfileRoot"`
    // 是否允许root权限
    AllowPrivileged bool `json:"allowPrivileged"`
    // kubelet允许pods使用的资源：主机的Network、PID、IPC
    // 默认都是kubetypes.AllSource，即所有资源"*"
    HostNetworkSources string `json:"hostNetworkSources"`

    HostPIDSources string `json:"hostPIDSources"`

    HostIPCSources string `json:"hostIPCSources"`
    // 限制从镜像仓库拉取镜像的速度， 0：unlimited; 5.0: default
    RegistryPullQPS float64 `json:"registryPullQPS"`
    // 从镜像仓库拉取镜像允许产生的爆发值
    RegistryBurst int32 `json:"registryBurst"`
    // 限制每秒产生的events最大数量
    EventRecordQPS float32 `json:"eventRecordQPS"`
    // 允许产生events的爆发值
    EventBurst int32 `json:"eventBurst"`
    // 使能debug模式，进行log收集和本地允许容器和命令
    EnableDebuggingHandlers bool `json:"enableDebuggingHandlers"`
    // 容器被回收之前存在的最小时间，在这时间之前是不允许被回收的
    MinimumGCAge unversioned.Duration `json:"minimumGCAge"`
    // Pod中允许存在Container的最大数量，默认是2
    MaxPerPodContainerCount int32 `json:"maxPerPodContainerCount"`
    // 该节点上允许存在的最大container数量，默认是240
    MaxContainerCount int32 `json:"maxContainerCount"`
    // cAdvisor服务端口，默认是4194
    CAdvisorPort uint `json:"cAdvisorPort"`
    // 健康检测端口，默认是10248
    HealthzPort int32 `json:"healthzPort"`
    // 健康检测绑定地址，默认是“127.0.0.1”
    HealthzBindAddress string `json:"healthzBindAddress"`
    // kubelet进程的oom-score-adj值，范围：[-1000, 1000]
    OOMScoreAdj int32 `json:"oomScoreAdj"`
    // 是否自动向Apiserver注册
    RegisterNode bool `json:"registerNode"`
    
    ClusterDomain string `json:"clusterDomain"`

    MasterServiceNamespace string `json:"masterServiceNamespace"`
    // 集群DNS的IP，kubelet将配置所有的containers去使用该DNS
    ClusterDNS string `json:"clusterDNS"`
    // 流连接的超时时间
    StreamingConnectionIdleTimeout unversioned.Duration `json:"streamingConnectionIdleTimeout"`
    // Node状态更新频率，该值需要和nodeController中的nodeMonitorGracePeriod一起作用
    // 设置kubelet每隔多少时间向APIServer汇报节点状态，默认为10s
    NodeStatusUpdateFrequency unversioned.Duration `json:"nodeStatusUpdateFrequency"`
    // 设置镜像被回收之前存在的最短时间，在这时间之前是不会被回收
    ImageMinimumGCAge unversioned.Duration `json:"imageMinimumGCAge"`
    // 磁盘占用率超过该值后，镜像垃圾回收进程将一直运行
    ImageGCHighThresholdPercent int32 `json:"imageGCHighThresholdPercent"`
    // 磁盘占用率低于该值，镜像垃圾回收进程将不运行
    ImageGCLowThresholdPercent int32 `json:"imageGCLowThresholdPercent"`
    // 磁盘空间的保留大小，当低于该值时，Pods将不能再创建
    LowDiskSpaceThresholdMB int32 `json:"lowDiskSpaceThresholdMB"`
    // 计算所有Pods和缓存容量的磁盘使用情况的频率
    VolumeStatsAggPeriod unversioned.Duration `json:"volumeStatsAggPeriod"`
    // Network和volume的插件相关
    NetworkPluginName string `json:"networkPluginName"`

    NetworkPluginDir string `json:"networkPluginDir"`

    VolumePluginDir string `json:"volumePluginDir"`

    CloudProvider string `json:"cloudProvider,omitempty"`

    CloudConfigFile string `json:"cloudConfigFile,omitempty"`
    // 一个cgroups的名字，用于隔离kubelet   ？？？？为啥要隔离？单节点支持多个kubelet？？
    KubeletCgroups string `json:"kubeletCgroups,omitempty"`
    // 用于隔离容器运行时(Docker、Rkt)的cgroups
    RuntimeCgroups string `json:"runtimeCgroups,omitempty"`

    SystemCgroups string `json:"systemContainer,omitempty"`
    
    CgroupRoot string `json:"cgroupRoot,omitempty"`
    // ???
    ContainerRuntime string `json:"containerRuntime"`
    // 设置所有的runtime请求的超时时间(如：pull、logs、exec、attach)，除了那些长时间运行的任务
    RuntimeRequestTimeout unversioned.Duration `json:"runtimeRequestTimeout,omitempty"`
    // rkt执行文件的路径
    RktPath string `json:"rktPath,omitempty"`
    // rkt通讯端点
    RktAPIEndpoint string `json:"rktAPIEndpoint,omitempty"`
    
    RktStage1Image string `json:"rktStage1Image,omitempty"`
    // kubelet文件锁，用于与别的kubelet进行同步
    LockFilePath string `json:"lockFilePath"`
    
    ExitOnLockContention bool `json:"exitOnLockContention"`
    // 基于Node.Spec.PodCIDR来配置网卡cbr0
    ConfigureCBR0 bool `json:"configureCbr0"`
    // 配置网络模式， promiscuous-bridge、hairpin-veth、none
    HairpinMode string `json:"hairpinMode"`
    // 表示该节点已经有监控docker和kubelet的程序
    BabysitDaemons bool `json:"babysitDaemons"`
    // 该kubelet下能运行的最大Pods数量
    MaxPods int32 `json:"maxPods"`
    
    NvidiaGPUs int32 `json:"nvidiaGPUs"`
    // 容器命令执行的Handler，通过字符串来配置不同的Handler
    // 可配置："native" or "nsender",default: "native"
    DockerExecHandlerName string `json:"dockerExecHandlerName"`
    // 这个CIDR用于分配Pod IP地址，只作用在standalone模式
    PodCIDR string `json:"podCIDR"`
    // 配置容器的DNS解析文件，默认是"/etc/resolv.conf"
    ResolverConfig string `json:"resolvConf"`
    // 使能容器的CPU配额功能
    CPUCFSQuota bool `json:"cpuCFSQuota"`
    // 如果kubelet运行在容器中的话，需要把该值设置为true
    // kubelet运行在主机上和容器里会有差异：
    // 在主机上的话，写文件数据没有什么限制，直接调用ioutil.WriteFile()接口就OK
    // 在容器里的话，如果kubelet要写数据到它所创建的容器的话，就得使用nsender进入到
    // 容器对应的namespace中，然后写数据
    Containerized bool `json:"containerized"`
    // kubelet进程可以打开的最大文件数
    MaxOpenFiles uint64 `json:"maxOpenFiles"`
    // 由apiServer指定CIDR
    ReconcileCIDR bool `json:"reconcileCIDR"`
    // 指定kubelet将它所在的Node注册到Apiserver，为Schedulable
    RegisterSchedulable bool `json:"registerSchedulable"`
    // kubelet发送给apiServer的请求的正文类型，default:"application/vnd.kubernetes.protobuf"
    ContentType string `json:"contentType"`
    // kubelet和apiServer交互所设定的QPS
    KubeAPIQPS float32 `json:"kubeAPIQPS"`
    // kubelet与apiServer交互允许产生的爆发值
    KubeAPIBurst int32 `json:"kubeAPIBurst"`
    // 设置为true的话，告诉kubelet串行的去pull image
    SerializeImagePulls bool `json:"serializeImagePulls"`
    // 使能Flannel网络来启动kubelet，该前提是默认Flannel已经启动了
    ExperimentalFlannelOverlay bool `json:"experimentalFlannelOverlay"`
    // Node可能会出于out-of-disk的状态(磁盘空间不足)，kubelet需要定时查询node状态
    // 所以该值就是定时查询的频率
    OutOfDiskTransitionFrequency unversioned.Duration `json:"outOfDiskTransitionFrequency,omitempty"`
    // kubelet所在节点的IP.如果该值有设置，那么kubelet会把该值设置到node上
    NodeIP string `json:"nodeIP,omitempty"`
    // 该Node的Labels
    NodeLabels map[string]string `json:"nodeLabels"`

    NonMasqueradeCIDR string `json:"nonMasqueradeCIDR"`
    
    EnableCustomMetrics bool `json:"enableCustomMetrics"`
    // 以下几个都跟回收策略有关，详细的需要查看代码实现。
    // 用逗号分隔的回收资源的条件表达式
    // 参考: https://kubernetes.io/docs/admin/out-of-resource/
    EvictionHard string `json:"evictionHard,omitempty"`
    
    EvictionSoft string `json:"evictionSoft,omitempty"`
    
    EvictionSoftGracePeriod string `json:"evictionSoftGracePeriod,omitempty"`

    EvictionPressureTransitionPeriod unversioned.Duration `json:"evictionPressureTransitionPeriod,omitempty"`
    
    EvictionMaxPodGracePeriod int32 `json:"evictionMaxPodGracePeriod,omitempty"`
    // 设置每个核最大的Pods数量
    PodsPerCore int32 `json:"podsPerCore"`
    // 是否使能kubelet attach/detach的功能
    EnableControllerAttachDetach bool `json:"enableControllerAttachDetach"`
}
```
## Kubelet启动流程
### main 入口
main入口： cmd/kubelet/kubelet.go
Main源码如下：
```go
func main() {
    runtime.GOMAXPROCS(runtime.NumCPU())
    s := options.NewKubeletServer()
    s.AddFlags(pflag.CommandLine)

    flag.InitFlags()
    util.InitLogs()
    defer util.FlushLogs()

    verflag.PrintAndExitIfRequested()

    if err := app.Run(s, nil); err != nil {
        fmt.Fprintf(os.Stderr, "%v\n", err)
        os.Exit(1)
    }
}
```
有看过源码的同学，应该会发现kubernetes所有执行程序的入口函数风格都差不多一致。
options.NewKubeletServer(): 创建了一个KubeletServer结构，并进行了默认值的初始化。
接口如下：

```go
func NewKubeletServer() *KubeletServer {
    return &KubeletServer{
...
        KubeletConfiguration: componentconfig.KubeletConfiguration{
            Address:                      "0.0.0.0",
            CAdvisorPort:                 4194,
            VolumeStatsAggPeriod:         unversioned.Duration{Duration: time.Minute},
            CertDirectory:                "/var/run/kubernetes",
            CgroupRoot:                   "",
            CloudProvider:                AutoDetectCloudProvider,
            ConfigureCBR0:                false,
            ContainerRuntime:             "docker",
            RuntimeRequestTimeout:        unversioned.Duration{Duration: 2 * time.Minute},
            CPUCFSQuota:                  true,
...
}
```
s.AddFlags(pflag.CommandLine): 该接口用于从kubelet命令行获取参数。
接口如下：
```go
func (s *KubeletServer) AddFlags(fs *pflag.FlagSet) {
    fs.StringVar(&s.Config, "config", s.Config, "Path to the config file or directory of files")
    fs.DurationVar(&s.SyncFrequency.Duration, "sync-frequency", s.SyncFrequency.Duration, "Max period between synchronizing running containers and config")
    fs.DurationVar(&s.FileCheckFrequency.Duration, "file-check-frequency", s.FileCheckFrequency.Duration, "Duration between checking config files for new data")
...
}
```
命令行参数获取完之后，就是进行日志等的初始化。
verflag.PrintAndExitIfRequested(): 判断了参数是否是help，是的话直接打印help信息，然后退出。
最后就进入到关键函数app.Run(s, nil)。

### app.Run()
Run入口： cmd/kubelet/app/server.go
该接口的代码很长，其实主要也是做了一些准备工作，先来看下参数配置的过程。
代码如下：

```go
func run(s *options.KubeletServer, kcfg *KubeletConfig) (err error) {
...
    // 可以看到app.Run()进来的时候，kcfg=nil
    if kcfg == nil {
        // UnsecuredKubeletConfig()返回一个有效的KubeConfig
        cfg, err := UnsecuredKubeletConfig(s)
        if err != nil {
            return err
        }
        kcfg = cfg
        // 初始化一个Config,用来与APIServer交互
        clientConfig, err := CreateAPIServerClientConfig(s)
        if err == nil {
            // 用于创建各类client： 核心client、认证client、授权client...
            kcfg.KubeClient, err = clientset.NewForConfig(clientConfig)
            // 创建一个events的client
            // make a separate client for events
            eventClientConfig := *clientConfig
            eventClientConfig.QPS = s.EventRecordQPS
            eventClientConfig.Burst = int(s.EventBurst)
            kcfg.EventClient, err = clientset.NewForConfig(&eventClientConfig)
        }
...
    }

    // 创建了一个cAdvisor对象，用于获取各类资源信息
    // 其中有部分接口还未支持
    if kcfg.CAdvisorInterface == nil {
        kcfg.CAdvisorInterface, err = cadvisor.New(s.CAdvisorPort, kcfg.ContainerRuntime)
        if err != nil {
            return err
        }
    }
    // kubelet的容器管理模块
    if kcfg.ContainerManager == nil {
        if kcfg.SystemCgroups != "" && kcfg.CgroupRoot == "" {
            return fmt.Errorf("invalid configuration: system container was specified and cgroup root was not specified")
        }

        kcfg.ContainerManager, err = cm.NewContainerManager(kcfg.Mounter, kcfg.CAdvisorInterface, cm.NodeConfig{
            RuntimeCgroupsName: kcfg.RuntimeCgroups,
            SystemCgroupsName:  kcfg.SystemCgroups,
            KubeletCgroupsName: kcfg.KubeletCgroups,
            ContainerRuntime:   kcfg.ContainerRuntime,
        })
        if err != nil {
            return err
        }
    }
...
    // 配置系统OOM参数
    // TODO(vmarmol): Do this through container config.
    oomAdjuster := kcfg.OOMAdjuster
    if err := oomAdjuster.ApplyOOMScoreAdj(0, int(s.OOMScoreAdj)); err != nil {
        glog.Warning(err)
    }

    // 继续接下去的kubelet运行步骤
    if err := RunKubelet(kcfg); err != nil {
        return err
    }

    // kubelet的监控检测
    if s.HealthzPort > 0 {
        healthz.DefaultHealthz()
        go wait.Until(func() {
            err := http.ListenAndServe(net.JoinHostPort(s.HealthzBindAddress, strconv.Itoa(int(s.HealthzPort))), nil)
            if err != nil {
                glog.Errorf("Starting health server failed: %v", err)
            }
        }, 5*time.Second, wait.NeverStop)
    }

    if s.RunOnce {
        return nil
    }

    <-done
    return nil
}
```
该接口主要准备了一个KubeletConfig结构，调用UnsecuredKubeletConfig()接口进行创建。
然后还创建了一些该结构中的kubeClient、EventClient、CAdvisorInterface、ContainerManager、oomAdjuster等对象。
然后调用了RunKubelet()接口，走接下去的服务运行流程。
最后运行健康检测服务。

下面挑关键的接口进行介绍：

UnsecuredKubeletConfig()接口

func UnsecuredKubeletConfig(s *options.KubeletServer) (*KubeletConfig, error) {
。。。
    // kubelet可能会以容器的方式部署，需要配置标准输出
    mounter := mount.New()
    var writer io.Writer = &io.StdWriter{}
    if s.Containerized {
        glog.V(2).Info("Running kubelet in containerized mode (experimental)")
        mounter = mount.NewNsenterMounter()
        writer = &io.NsenterWriter{}
    }

    // 配置kubelet的TLS
    tlsOptions, err := InitializeTLS(s)
    if err != nil {
        return nil, err
    }
    
    // kubelet有两种部署方式： 直接运行在物理机上，还有一种是通过容器部署。
    // 若部署到容器中，就会有namespace隔离的问题，导致kubelet无法访问docker容器的
    // namespace并且docker exec运行命令。
    // 所以这里会进行判断，如果运行在容器中的话，就需要用到nsenter，它可以协助kubelet
    // 到指定的namespace运行命令。
    // nsenter参考资料： https://github.com/jpetazzo/nsenter
    var dockerExecHandler dockertools.ExecHandler
    switch s.DockerExecHandlerName {
    case "native":
        dockerExecHandler = &dockertools.NativeExecHandler{}
    case "nsenter":
        dockerExecHandler = &dockertools.NsenterExecHandler{}
    default:
        glog.Warningf("Unknown Docker exec handler %q; defaulting to native", s.DockerExecHandlerName)
        dockerExecHandler = &dockertools.NativeExecHandler{}
    }
    
    // k8s对image的回收管理策略
    // MinAge: 表示镜像存活的最小时间，只有在这之后才能回收该镜像
    // HighThresholdPercent： 磁盘占用超过该值后，GC一直开启
    // LowThresholdPercent： 磁盘占用低于该值的话，GC不开启
    imageGCPolicy := kubelet.ImageGCPolicy{
        MinAge:               s.ImageMinimumGCAge.Duration,
        HighThresholdPercent: int(s.ImageGCHighThresholdPercent),
        LowThresholdPercent:  int(s.ImageGCLowThresholdPercent),
    }
    // k8s根据磁盘空间配置策略
    // DockerFreeDiskMB： 磁盘可用空间低于该值时，pod将无法再在该节点创建,也是指该磁盘需要保留的空间大小
    diskSpacePolicy := kubelet.DiskSpacePolicy{
        DockerFreeDiskMB: int(s.LowDiskSpaceThresholdMB),
        RootFreeDiskMB:   int(s.LowDiskSpaceThresholdMB),
    }

。。。
    // k8s v1.3引入的功能。Eviction用于k8s集群提前感知节点memory/disk负载情况，来调度资源。
    thresholds, err := eviction.ParseThresholdConfig(s.EvictionHard, s.EvictionSoft, s.EvictionSoftGracePeriod)
    if err != nil {
        return nil, err
    }
    evictionConfig := eviction.Config{
        PressureTransitionPeriod: s.EvictionPressureTransitionPeriod.Duration,
        MaxPodGracePeriodSeconds: int64(s.EvictionMaxPodGracePeriod),
        Thresholds:               thresholds,
    }
    // 初始化KubeletConfig结构
    return &KubeletConfig{
        Address:                      net.ParseIP(s.Address),
        AllowPrivileged:              s.AllowPrivileged,
        Auth:                         nil, // default does not enforce auth[nz]
。。。
    }, nil
}
这段代码中，个人觉得有几个点比较值得了解下：

该接口中会涉及到kubelet跑在物理机上还是容器中。
如果运行在容器中，会存在namespace权限的问题，需要通过nsenter来操作docker容器。
kubelet提供了参数"--docker-exec-handler"(即DockerExecHandlerName)，来配置是否使用nsenter.
Nsenter功能可以了解下。

还有一个kubelet Eviction功能。该功能是k8s v1.3.0新引入的功能，eviction功能就是在节点超负荷之前，提前不让Pod进行创建，主要就是针对memory和disk。
之前的版本是不会提前感知集群的节点负荷，当内存吃紧时，k8s只依靠内核的OOM Killer、磁盘定期对image和container进行垃圾回收功能，这样对于Pod有不确定性。eviction很好的解决了该问题，可以在kubelet启动时指定memory/disk等参数，来保证节点稳定工作，让集群提前感知节点负荷。
根据kubeconfig创建client

创建client会有两步：

调用CreateAPIServerClientConfig()进行Config初始化
调用clientset.NewForConfig()根据之前初始化的Config，创建各类Client。
CreateAPIServerClientConfig()接口如下：

func CreateAPIServerClientConfig(s *options.KubeletServer) (*restclient.Config, error) {    
    // 检查APIServer是否有配置
    if len(s.APIServerList) < 1 {
        return nil, fmt.Errorf("no api servers specified")
    }
    // 检查是否配置了多个APIServer，新版本已经支持多APIServer的HA
    // 现在默认是用第一个Server
    // TODO: adapt Kube client to support LB over several servers
    if len(s.APIServerList) > 1 {
        glog.Infof("Multiple api servers specified.  Picking first one")
    }

    clientConfig, err := createClientConfig(s)
    if err != nil {
        return nil, err
    }

    clientConfig.ContentType = s.ContentType
    // Override kubeconfig qps/burst settings from flags
    clientConfig.QPS = s.KubeAPIQPS
    clientConfig.Burst = int(s.KubeAPIBurst)

    addChaosToClientConfig(s, clientConfig)
    return clientConfig, nil
}

func createClientConfig(s *options.KubeletServer) (*restclient.Config, error) {
    if s.KubeConfig.Provided() && s.AuthPath.Provided() {
        return nil, fmt.Errorf("cannot specify both --kubeconfig and --auth-path")
    }
    if s.KubeConfig.Provided() {
        return kubeconfigClientConfig(s)
    }
    if s.AuthPath.Provided() {
        return authPathClientConfig(s, false)
    }
    // Try the kubeconfig default first, falling back to the auth path default.
    clientConfig, err := kubeconfigClientConfig(s)
    if err != nil {
        glog.Warningf("Could not load kubeconfig file %s: %v. Trying auth path instead.", s.KubeConfig, err)
        return authPathClientConfig(s, true)
    }
    return clientConfig, nil
}

// 就是这边默认指定了第一个APIServer
func kubeconfigClientConfig(s *options.KubeletServer) (*restclient.Config, error) {
    return clientcmd.NewNonInteractiveDeferredLoadingClientConfig(
        &clientcmd.ClientConfigLoadingRules{ExplicitPath: s.KubeConfig.Value()},
        &clientcmd.ConfigOverrides{ClusterInfo: clientcmdapi.Cluster{Server: s.APIServerList[0]}}).ClientConfig()
}
创建Config成功之后，便调用clientset.NewForConfig()创建各类Clients:

func NewForConfig(c *restclient.Config) (*Clientset, error) {
    // 配置Client连接限制
    configShallowCopy := *c
    if configShallowCopy.RateLimiter == nil && configShallowCopy.QPS > 0 {
        configShallowCopy.RateLimiter = flowcontrol.NewTokenBucketRateLimiter(configShallowCopy.QPS, configShallowCopy.Burst)
    }
    var clientset Clientset
    var err error
    // 创建核心Client
    clientset.CoreClient, err = unversionedcore.NewForConfig(&configShallowCopy)
    if err != nil {
        return nil, err
    }
    // 创建第三方Client
    clientset.ExtensionsClient, err = unversionedextensions.NewForConfig(&configShallowCopy)
    if err != nil {
        return nil, err
    }
    // 创建自动伸缩Client
    clientset.AutoscalingClient, err = unversionedautoscaling.NewForConfig(&configShallowCopy)
    if err != nil {
        return nil, err
    }
    // 创建批量操作的Client
    clientset.BatchClient, err = unversionedbatch.NewForConfig(&configShallowCopy)
    if err != nil {
        return nil, err
    }
    // 创建Rbac Client (RBAC：基于角色的访问控制)
    // 跟k8s的认证授权有关，可以参考： https://kubernetes.io/docs/admin/authorization/
    clientset.RbacClient, err = unversionedrbac.NewForConfig(&configShallowCopy)
    if err != nil {
        return nil, err
    }
    // 创建服务发现Client
    clientset.DiscoveryClient, err = discovery.NewDiscoveryClientForConfig(&configShallowCopy)
    if err != nil {
        glog.Errorf("failed to create the DiscoveryClient: %v", err)
        return nil, err
    }
    return &clientset, nil
}
上面的各种客户端实际就是api rest请求的客户端。

### RunKubelet

上面的各类创建及初始化完之后，便进入下一步骤RunKubelet:

```go
func RunKubelet(kcfg *KubeletConfig) error {
...
    // k8s event对象创建，用于kubelet向APIServer发送管理容器相关的各类events
    // 后面会单独介绍k8s events功能,这里不再展开细讲
    eventBroadcaster := record.NewBroadcaster()
    kcfg.Recorder = eventBroadcaster.NewRecorder(api.EventSource{Component: "kubelet", Host: kcfg.NodeName})
    eventBroadcaster.StartLogging(glog.V(3).Infof)
    if kcfg.EventClient != nil {
        glog.V(4).Infof("Sending events to api server.")
        eventBroadcaster.StartRecordingToSink(&unversionedcore.EventSinkImpl{Interface: kcfg.EventClient.Events("")})
    } else {
        glog.Warning("No api server defined - no events will be sent to API server.")
    }
    // 配置capabilities
    privilegedSources := capabilities.PrivilegedSources{
        HostNetworkSources: kcfg.HostNetworkSources,
        HostPIDSources:     kcfg.HostPIDSources,
        HostIPCSources:     kcfg.HostIPCSources,
    }
    capabilities.Setup(kcfg.AllowPrivileged, privilegedSources, 0)

    credentialprovider.SetPreferredDockercfgPath(kcfg.RootDirectory)
    // 调用CreateAndInitKubelet()接口，进行各类初始化
    builder := kcfg.Builder
    if builder == nil {
        builder = CreateAndInitKubelet
    }
    if kcfg.OSInterface == nil {
        kcfg.OSInterface = kubecontainer.RealOS{}
    }
    k, podCfg, err := builder(kcfg)
    if err != nil {
        return fmt.Errorf("failed to create kubelet: %v", err)
    }
    // 设置kubelet进程自身最大能打开的文件句柄数
    util.ApplyRLimitForSelf(kcfg.MaxOpenFiles)

    // TODO(dawnchen): remove this once we deprecated old debian containervm images.
    // This is a workaround for issue: https://github.com/opencontainers/runc/issues/726
    // The current chosen number is consistent with most of other os dist.
    const maxkeysPath = "/proc/sys/kernel/keys/root_maxkeys"
    const minKeys uint64 = 1000000
    key, err := ioutil.ReadFile(maxkeysPath)
    if err != nil {
        glog.Errorf("Cannot read keys quota in %s", maxkeysPath)
    } else {
        fields := strings.Fields(string(key))
        nkey, _ := strconv.ParseUint(fields[0], 10, 64)
        if nkey < minKeys {
            glog.Infof("Setting keys quota in %s to %d", maxkeysPath, minKeys)
            err = ioutil.WriteFile(maxkeysPath, []byte(fmt.Sprintf("%d", uint64(minKeys))), 0644)
            if err != nil {
                glog.Warningf("Failed to update %s: %v", maxkeysPath, err)
            }
        }
    }
    const maxbytesPath = "/proc/sys/kernel/keys/root_maxbytes"
    const minBytes uint64 = 25000000
    bytes, err := ioutil.ReadFile(maxbytesPath)
    if err != nil {
        glog.Errorf("Cannot read keys bytes in %s", maxbytesPath)
    } else {
        fields := strings.Fields(string(bytes))
        nbyte, _ := strconv.ParseUint(fields[0], 10, 64)
        if nbyte < minBytes {
            glog.Infof("Setting keys bytes in %s to %d", maxbytesPath, minBytes)
            err = ioutil.WriteFile(maxbytesPath, []byte(fmt.Sprintf("%d", uint64(minBytes))), 0644)
            if err != nil {
                glog.Warningf("Failed to update %s: %v", maxbytesPath, err)
            }
        }
    }

    // kubelet可以只运行一次，也可以作为一个后台daemon一直运行
    // 一次运行的话，就是Runonce，处理下pods事件然后退出
    // 一直运行的话，就是startKubelet()
    // process pods and exit.
    if kcfg.Runonce {
        if _, err := k.RunOnce(podCfg.Updates()); err != nil {
            return fmt.Errorf("runonce failed: %v", err)
        }
        glog.Infof("Started kubelet %s as runonce", version.Get().String())
    } else {
        // 进入关键函数startKubelet()
        startKubelet(k, podCfg, kcfg)
        glog.Infof("Started kubelet %s", version.Get().String())
    }
    return nil
}
```

该接口中会调用CreateAndInitKubelet()接口再进行初始化，其中又调用了kubelet.NewMainKubelet()接口。
kubelet可以只运行一次，也可以后台一直运行。要一直运行的话就是调用startKubelet()。
我们先看下初始化接口干了些什么?

```go
func CreateAndInitKubelet(kc *KubeletConfig) (k KubeletBootstrap, pc *config.PodConfig, err error) {
    // TODO: block until all sources have delivered at least one update to the channel, or break the sync loop
    // up into "per source" synchronizations
    // TODO: KubeletConfig.KubeClient should be a client interface, but client interface misses certain methods
    // used by kubelet. Since NewMainKubelet expects a client interface, we need to make sure we are not passing
    // a nil pointer to it when what we really want is a nil interface.
    var kubeClient clientset.Interface
    if kc.KubeClient != nil {
        kubeClient = kc.KubeClient
        // TODO: remove this when we've refactored kubelet to only use clientset.
    }

    // 初始化container GC参数
    gcPolicy := kubecontainer.ContainerGCPolicy{
        MinAge:             kc.MinimumGCAge,
        MaxPerPodContainer: kc.MaxPerPodContainerCount,
        MaxContainers:      kc.MaxContainerCount,
    }

    // 配置kubelet server的端口, default: 10250
    daemonEndpoints := &api.NodeDaemonEndpoints{
        KubeletEndpoint: api.DaemonEndpoint{Port: int32(kc.Port)},
    }

    // 创建PodConfig
    pc = kc.PodConfig
    if pc == nil {
        // kubelet支持三种数据源： file、HTTP URL、k8s APIServer
        // 默认是k8s APIServer，这里还会涉及到cache，可以深入学习下具体实现
        pc = makePodSourceConfig(kc)
    }
    // 
    k, err = kubelet.NewMainKubelet(
        kc.Hostname,
        kc.NodeName,
        kc.DockerClient,
        kubeClient,
。。。
    )

    if err != nil {
        return nil, nil, err
    }

    k.BirthCry()

    k.StartGarbageCollection()

    return k, pc, nil
}
```

### kubelet.NewMainKubelet

初始化接口中还有一层调用：kubelet.NewMainKubelet()，该接口在1.3中是N多参数，并且函数实现也是很长很长，写的非常不友好，不过看了下新版本已经重写过了。我们还是拿这个又长又胖的接口，继续了解下：

```go
func NewMainKubelet(
    hostname string,
    nodeName string,
。。。
) (*Kubelet, error) {
。。。
    // 创建service的cache.NewStore, 设置service的监听函数listWatch，并设置对应的反射NewReflector,然后设置serviceLister
    serviceStore := cache.NewStore(cache.MetaNamespaceKeyFunc)
    if kubeClient != nil {
        // TODO: cache.NewListWatchFromClient is limited as it takes a client implementation rather
        // than an interface. There is no way to construct a list+watcher using resource name.
        listWatch := &cache.ListWatch{
            ListFunc: func(options api.ListOptions) (runtime.Object, error) {
                return kubeClient.Core().Services(api.NamespaceAll).List(options)
            },
            WatchFunc: func(options api.ListOptions) (watch.Interface, error) {
                return kubeClient.Core().Services(api.NamespaceAll).Watch(options)
            },
        }
        cache.NewReflector(listWatch, &api.Service{}, serviceStore, 0).Run()
    }
    serviceLister := &cache.StoreToServiceLister{Store: serviceStore}
    
    // 创建node的cache.NewStore, 设置fieldSelector，设置监听函数listWatch,设置对应的反射NewReflector,并设置nodeLister,nodeInfo和nodeRef
    nodeStore := cache.NewStore(cache.MetaNamespaceKeyFunc)
    if kubeClient != nil {
        // TODO: cache.NewListWatchFromClient is limited as it takes a client implementation rather
        // than an interface. There is no way to construct a list+watcher using resource name.
        fieldSelector := fields.Set{api.ObjectNameField: nodeName}.AsSelector()
        listWatch := &cache.ListWatch{
            ListFunc: func(options api.ListOptions) (runtime.Object, error) {
                options.FieldSelector = fieldSelector
                return kubeClient.Core().Nodes().List(options)
            },
            WatchFunc: func(options api.ListOptions) (watch.Interface, error) {
                options.FieldSelector = fieldSelector
                return kubeClient.Core().Nodes().Watch(options)
            },
        }
        cache.NewReflector(listWatch, &api.Node{}, nodeStore, 0).Run()
    }
    nodeLister := &cache.StoreToNodeLister{Store: nodeStore}
    nodeInfo := &predicates.CachedNodeInfo{StoreToNodeLister: nodeLister}

    // TODO: get the real node object of ourself,
    // and use the real node name and UID.
    // TODO: what is namespace for node?
    nodeRef := &api.ObjectReference{
        Kind:      "Node",
        Name:      nodeName,
        UID:       types.UID(nodeName),
        Namespace: "",
    }
    // 创建磁盘空间管理对象，该对象需要使用cAdvisor的接口来获取磁盘相关信息
    // 最后一个参数便是配置磁盘管理的Policy
    diskSpaceManager, err := newDiskSpaceManager(cadvisorInterface, diskSpacePolicy)
    if err != nil {
        return nil, fmt.Errorf("failed to initialize disk manager: %v", err)
    }
    // 创建一个空的container reference manager对象
    containerRefManager := kubecontainer.NewRefManager()
    // 创建OOM 监控对象，使用cAdvisor接口监控内存，并使用event recorder上报oom事件
    oomWatcher := NewOOMWatcher(cadvisorInterface, recorder)

    // TODO: remove when internal cbr0 implementation gets removed in favor
    // of the kubenet network plugin
    if networkPluginName == "kubenet" {
        configureCBR0 = false
        flannelExperimentalOverlay = false
    }
    // 初始化Kubelet
    klet := &Kubelet{
        hostname:                       hostname,
        nodeName:                       nodeName,
    。。。
    }

...

    procFs := procfs.NewProcFS()
    imageBackOff := flowcontrol.NewBackOff(backOffPeriod, MaxContainerBackOff)

    klet.livenessManager = proberesults.NewManager()
    // 初始化pod的cache和manager对象
    klet.podCache = kubecontainer.NewCache()
    klet.podManager = kubepod.NewBasicPodManager(kubepod.NewBasicMirrorClient(klet.kubeClient))

    // 初始化Docker container Runtime
    switch containerRuntime {
    case "docker":
        // dockerClient就是之后会介绍，就是kubelet用于操作docker的client
        // recorder: 即之前创建的event recorder
        // 还会有各类物理机信息，pull images的QPS等等参数
        // 具体可以了解下DockerManager结构
        // Only supported one for now, continue.
        klet.containerRuntime = dockertools.NewDockerManager(
            dockerClient,
            kubecontainer.FilterEventRecorder(recorder),
            klet.livenessManager,
            containerRefManager,
            klet.podManager,
            machineInfo,
            podInfraContainerImage,
            pullQPS,
            pullBurst,
            containerLogsDir,
            osInterface,
            klet.networkPlugin,
            klet,
            klet.httpClient,
            dockerExecHandler,
            oomAdjuster,
            procFs,
            klet.cpuCFSQuota,
            imageBackOff,
            serializeImagePulls,
            enableCustomMetrics,
            klet.hairpinMode == componentconfig.HairpinVeth,
            seccompProfileRoot,
            containerRuntimeOptions...,
        )
    case "rkt":
        ...
    default:
        return nil, fmt.Errorf("unsupported container runtime %q specified", containerRuntime)
    }

    ...

    // 设置containerGC
    containerGC, err := kubecontainer.NewContainerGC(klet.containerRuntime, containerGCPolicy)
    if err != nil {
        return nil, err
    }
    klet.containerGC = containerGC

    // 设置imageManager
    imageManager, err := newImageManager(klet.containerRuntime, cadvisorInterface, recorder, nodeRef, imageGCPolicy)
    if err != nil {
        return nil, fmt.Errorf("failed to initialize image manager: %v", err)
    }
    klet.imageManager = imageManager

    klet.runner = klet.containerRuntime
    // 设置statusManager
    klet.statusManager = status.NewManager(kubeClient, klet.podManager)
    // 设置probeManager
    klet.probeManager = prober.NewManager(
        klet.statusManager,
        klet.livenessManager,
        klet.runner,
        containerRefManager,
        recorder)

    klet.volumePluginMgr, err =
        NewInitializedVolumePluginMgr(klet, volumePlugins)
    if err != nil {
        return nil, err
    }
    // 设置volumeManager
    klet.volumeManager, err = kubeletvolume.NewVolumeManager(
        enableControllerAttachDetach,
        hostname,
        klet.podManager,
        klet.kubeClient,
        klet.volumePluginMgr,
        klet.containerRuntime)

    // 创建runtime Cache对象
    runtimeCache, err := kubecontainer.NewRuntimeCache(klet.containerRuntime)
    if err != nil {
        return nil, err
    }
    klet.runtimeCache = runtimeCache
    klet.reasonCache = NewReasonCache()
    klet.workQueue = queue.NewBasicWorkQueue(klet.clock)
    // 创建podWorkers对象，这个比较关键，后面会单独介绍
    klet.podWorkers = newPodWorkers(klet.syncPod, recorder, klet.workQueue, klet.resyncInterval, backOffPeriod, klet.podCache)

    klet.backOff = flowcontrol.NewBackOff(backOffPeriod, MaxContainerBackOff)
    klet.podKillingCh = make(chan *kubecontainer.PodPair, podKillingChannelCapacity)
    klet.setNodeStatusFuncs = klet.defaultNodeStatusFuncs()

    // 设置eviction manager
    evictionManager, evictionAdmitHandler, err := eviction.NewManager(klet.resourceAnalyzer, evictionConfig, killPodNow(klet.podWorkers), recorder, nodeRef, klet.clock)
    if err != nil {
        return nil, fmt.Errorf("failed to initialize eviction manager: %v", err)
    }
    klet.evictionManager = evictionManager
    klet.AddPodAdmitHandler(evictionAdmitHandler)

    // apply functional Option's
    for _, opt := range kubeOptions {
        opt(klet)
    }
    return klet, nil
}
```

该接口中，会创建podWorkers，该对象比较重要，跟pod的实际操作有关，后面会单独进行介绍。这里先只点到为止。
我们回想下整个流程就会发现，cmd/kubelet/app主要就是做一些简单的参数处理，具体的初始化都是在pkg/kubelet中做的。

### startKubelet

看完初始化，我们要进入真正运行的接口startKubelet():

```go
func startKubelet(k KubeletBootstrap, podCfg *config.PodConfig, kc *KubeletConfig) {
    // 这里是真正的启动kubelet
    go wait.Until(func() { k.Run(podCfg.Updates()) }, 0, wait.NeverStop)

    // 这里是开启kubelet Server，便于调用kubelet的API进行操作
    if kc.EnableServer {
        go wait.Until(func() {
            k.ListenAndServe(kc.Address, kc.Port, kc.TLSOptions, kc.Auth, kc.EnableDebuggingHandlers)
        }, 0, wait.NeverStop)
    }
    // 该处是开启kubelet的只读服务，端口是10255
    if kc.ReadOnlyPort > 0 {
        go wait.Until(func() {
            k.ListenAndServeReadOnly(kc.Address, kc.ReadOnlyPort)
        }, 0, wait.NeverStop)
    }
}
```

### k.Run

继续深入，进入到真正启动kubelet的接口k.Run(),这个里的k是个KubeletBootstrap类型的interface,实际对象是由CreateAndInitKubelet()接口返回的Kubelet对象，所以Run()实现可以查看该对象的实现。
具体实现路径：pkg/kubelet/kubelet.go，接口如下：
```go
func (kl *Kubelet) Run(updates <-chan kubetypes.PodUpdate) {
    // 开启日志服务
    if kl.logServer == nil {
        kl.logServer = http.StripPrefix("/logs/", http.FileServer(http.Dir("/var/log/")))
    }
    if kl.kubeClient == nil {
        glog.Warning("No api server defined - no node status update will be sent.")
    }
    // init modulers，如imageManager、containerManager、oomWathcer、resourceAnalyzer
    if err := kl.initializeModules(); err != nil {
        kl.recorder.Eventf(kl.nodeRef, api.EventTypeWarning, kubecontainer.KubeletSetupFailed, err.Error())
        glog.Error(err)
        kl.runtimeState.setInitError(err)
    }

    // Start volume manager
    go kl.volumeManager.Run(wait.NeverStop)

    // 起协程，定时向APIServer更新node status
    if kl.kubeClient != nil {
        // Start syncing node status immediately, this may set up things the runtime needs to run.
        go wait.Until(kl.syncNodeStatus, kl.nodeStatusUpdateFrequency, wait.NeverStop)
    }
    // 起协程，定时同步网络状态
    go wait.Until(kl.syncNetworkStatus, 30*time.Second, wait.NeverStop)
    go wait.Until(kl.updateRuntimeUp, 5*time.Second, wait.NeverStop)

    // Start a goroutine responsible for killing pods (that are not properly
    // handled by pod workers).
    // 起协程，定时处理那些被killing pods
    go wait.Until(kl.podKiller, 1*time.Second, wait.NeverStop)

    // Start component sync loops.
    kl.statusManager.Start()
    kl.probeManager.Start()
    // 启动evictionManager
    kl.evictionManager.Start(kl.getActivePods, evictionMonitoringPeriod)

    // Start the pod lifecycle event generator.
    kl.pleg.Start()
    // 开启pods事件，用于处理APIServer下发的任务，updates是一个管道
    kl.syncLoop(updates, kl)
}

func (kl *Kubelet) initializeModules() error {
    // Step 1: Promethues metrics.
    metrics.Register(kl.runtimeCache)

    // Step 2: Setup filesystem directories.
    if err := kl.setupDataDirs(); err != nil {
        return err
    }

    // Step 3: If the container logs directory does not exist, create it.
    if _, err := os.Stat(containerLogsDir); err != nil {
        if err := kl.os.MkdirAll(containerLogsDir, 0755); err != nil {
            glog.Errorf("Failed to create directory %q: %v", containerLogsDir, err)
        }
    }

    // Step 4: Start the image manager.
    if err := kl.imageManager.Start(); err != nil {
        return fmt.Errorf("Failed to start ImageManager, images may not be garbage collected: %v", err)
    }

    // Step 5: Start container manager.
    if err := kl.containerManager.Start(); err != nil {
        return fmt.Errorf("Failed to start ContainerManager %v", err)
    }

    // Step 6: Start out of memory watcher.
    if err := kl.oomWatcher.Start(kl.nodeRef); err != nil {
        return fmt.Errorf("Failed to start OOM watcher %v", err)
    }

    // Step 7: Start resource analyzer
    kl.resourceAnalyzer.Start()

    return nil
}
```
到这里基本就结束了，学习源码的过程中会发现很多点值得深入研究，比如:

dockerclient
podWorkers
podManager
cAdvisor
containerGC
imageManager
diskSpaceManager
statusManager
volumeManager
containerRuntime
kubelet cache
events recorder
Eviction Manager
kubelet如何收到APIServer任务，创建pod的流程
等等。。
后面会继续挑一些关键点进行分析。