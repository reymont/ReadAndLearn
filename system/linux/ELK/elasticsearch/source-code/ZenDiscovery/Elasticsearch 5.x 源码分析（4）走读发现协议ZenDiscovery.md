

Elasticsearch 5.x 源码分析（4）走读发现协议ZenDiscovery - 简书 http://www.jianshu.com/p/b21b42d02bd8

Elasticsearch 的发现模块应该算是保证Elasticsearch启动并正常工作最基本的模块了，可以这么理解，如果启动一个实例后，它连最基本的加入一个“组织”都失败的话那么它将无法提供服务。
Elasticsearch的Discovery Module有下面几种实现，

Azure Classic Discovery
EC2 Discovery
Google Compute Engine Discovery
Zen Discovery
而ZenDiscovery是默认实现，这次主要想走读一下ZenDiscovery的源码来学习一下发现协议是如何运作的。
ZenDiscovery 逻辑起比较重要作用的类有下面几个，也涵盖了这个模块的几大基本功能：

ZenDiscovery.java 模块的主类，也是启动这个模块的入口，由Node.java调用并初始化，几乎涵盖了全部的发现协议的逻辑，是一个高度内聚了类
UnicastZenPing.java 是一个ZenPing 实现类，主要是负责底层和其他Nodes建立并维护连接的任务
PublishClusterStateAction.java 在ZenDiscovery中的变量名是publishClusterState，之前讲过，这些**Action 都是对**Service的封装，因此它主要是用来处理发送事件和处理事件的接口，比如发送一个clusterStateChangeEvent 和处理这个event，都是通过这个类调用
MasterFaultDetection.java 构建完cluster后所有的node用来检测master存活状态的类
NodeFaultDetection.java 构建完cluster后master用来检测其他node存活状态的类
连接

在Node.java的start（）里，discovery代码有4行

  Discovery discovery = injector.getInstance(Discovery.class);
  clusterService.getMasterService().setClusterStatePublisher(discovery::publish);
  // start after transport service so the local disco is known
  discovery.start(); // start before cluster service so that it can set initial state on ClusterApplierService
  discovery.startInitialJoin();   
这里Discovery的实例是由DisdcoveryModule的suppiler 提供

        discoveryTypes.put("zen",
            () -> new ZenDiscovery(settings, threadPool, transportService, namedWriteableRegistry, masterService, clusterApplier,
                clusterSettings, hostsProvider, allocationService));
        discoveryTypes.put("tribe", () -> new TribeDiscovery(settings, transportService, masterService, clusterApplier));
        discoveryTypes.put("single-node", () -> new SingleNodeDiscovery(settings, transportService, masterService, clusterApplier));
tribe 是搭建需要clusters间通信的模型时的一种类型。
discoverystart（）其实只是简单的初始化些变量，真正做事的是最后一句startInitialJoin（）方法，它会一直调startNewThredIfNotRunning（）接着启动一个线程去执行innerJoinCluster（），这里顺带提下，每次的join只允许至多一个线程执行，因此在这里会看到不但加锁，还会判断是否只由一个线程执行。
在innerJoinCluster()里，最开始要做的当然就是findMaster（）也就是说一个Node一启动，得先找“组织”：

   private DiscoveryNode findMaster() {
        logger.trace("starting to ping");
        List<ZenPing.PingResponse> fullPingResponses = pingAndWait(pingTimeout).toList();
...
...
   private ZenPing.PingCollection pingAndWait(TimeValue timeout) {
        final CompletableFuture<ZenPing.PingCollection> response = new CompletableFuture<>();
        try {
            zenPing.ping(response::complete, timeout);
        } catch (Exception ex) {
            // logged later
            response.completeExceptionally(ex);
        }

        try {
            return response.get();
        } catch (InterruptedException e) {
            logger.trace("pingAndWait interrupted");
            return new ZenPing.PingCollection();
        } catch (ExecutionException e) {
            logger.warn("Ping execution failed", e);
            return new ZenPing.PingCollection();
        }
    }
第一个重要大将zenPing开始上场了，从 response::complete和response.get两句大致就能猜出里面会异步并发一堆请求，主线程则阻塞在等response。
接下来我们看看ping的具体逻辑

        final List<DiscoveryNode> seedNodes;
        try {
            seedNodes = resolveHostsLists(
                unicastZenPingExecutorService,
                logger,
                configuredHosts,
                limitPortCounts,
                transportService,
                UNICAST_NODE_PREFIX,
                resolveTimeout);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        seedNodes.addAll(hostsProvider.buildDynamicNodes());
        final DiscoveryNodes nodes = contextProvider.clusterState().nodes();
        // add all possible master nodes that were active in the last known cluster configuration
        for (ObjectCursor<DiscoveryNode> masterNode : nodes.getMasterNodes().values()) {
            seedNodes.add(masterNode.value);
        }
在sendPing之前需要先把seedNodes确定，就是从3个地方获取，我们配置的discovery.zen.ping.unicast.hosts列表；hostsProvider.buildDynamicNodes()（这个我还不知道它是干啥的，知道的知会一下）；还有就是本实例最近一次的clusterState的masterNode是谁。

        // create tasks to submit to the executor service; we will wait up to resolveTimeout for these tasks to complete
        final List<Callable<TransportAddress[]>> callables =
            hosts
                .stream()
                .map(hn -> (Callable<TransportAddress[]>) () -> transportService.addressesFromString(hn, limitPortCounts))
                .collect(Collectors.toList());
        final List<Future<TransportAddress[]>> futures =
            executorService.invokeAll(callables, resolveTimeout.nanos(), TimeUnit.NANOSECONDS);
        final List<DiscoveryNode> discoveryNodes = new ArrayList<>();
        final Set<TransportAddress> localAddresses = new HashSet<>();
        localAddresses.add(transportService.boundAddress().publishAddress());
        localAddresses.addAll(Arrays.asList(transportService.boundAddress().boundAddresses()));
        // ExecutorService#invokeAll guarantees that the futures are returned in the iteration order of the tasks so we can associate the
        // hostname with the corresponding task by iterating together
        final Iterator<String> it = hosts.iterator();
        for (final Future<TransportAddress[]> future : futures) {
            final String hostname = it.next();
            if (!future.isCancelled()) {
                assert future.isDone();
                try {
                    final TransportAddress[] addresses = future.get();
                    logger.trace("resolved host [{}] to {}", hostname, addresses);
                    for (int addressId = 0; addressId < addresses.length; addressId++) {
                        final TransportAddress address = addresses[addressId];
                        // no point in pinging ourselves
                        if (localAddresses.contains(address) == false) {
                            discoveryNodes.add(
                                new DiscoveryNode(
                                    nodeId_prefix + hostname + "_" + addressId + "#",
                                    address,
                                    emptyMap(),
                                    emptySet(),
                                    Version.CURRENT.minimumCompatibilityVersion()));
                        }
                    }
                } catch (final ExecutionException e) {
                    assert e.getCause() != null;
                    final String message = "failed to resolve host [" + hostname + "]";
                    logger.warn(message, e.getCause());
                }
            } else {
                logger.warn("timed out after [{}] resolving host [{}]", resolveTimeout, hostname);
            }
        }
而resolveHostsLists就是把配好的unicast的地址列表都用TransportService构造一个DiscoveryNode返回，留意一下这里用了一个异步future来并发去读，估计是怕有些人配一些域名地址
解析需要很长时间？如果解析都那么长时间那这样配岂不是很蛋疼？？？
拿到seedNodes后就需要发起连接，这里会构造一个叫PingRound的类来统计，并且分别会在 scheduleDuration的0, 1/3, 2/3时刻发起一轮sendPing操作。

        final ConnectionProfile connectionProfile =
            ConnectionProfile.buildSingleChannelProfile(TransportRequestOptions.Type.REG, requestDuration, requestDuration);
        final PingingRound pingingRound = new PingingRound(pingingRoundIdGenerator.incrementAndGet(), seedNodes, resultsConsumer,
            nodes.getLocalNode(), connectionProfile);
        activePingingRounds.put(pingingRound.id(), pingingRound);
        final AbstractRunnable pingSender = new AbstractRunnable() {
            @Override
            public void onFailure(Exception e) {
                if (e instanceof AlreadyClosedException == false) {
                    logger.warn("unexpected error while pinging", e);
                }
            }

            @Override
            protected void doRun() throws Exception {
                sendPings(requestDuration, pingingRound);
            }
        };
        threadPool.generic().execute(pingSender);
        threadPool.schedule(TimeValue.timeValueMillis(scheduleDuration.millis() / 3), ThreadPool.Names.GENERIC, pingSender);
        threadPool.schedule(TimeValue.timeValueMillis(scheduleDuration.millis() / 3 * 2), ThreadPool.Names.GENERIC, pingSender);
        threadPool.schedule(scheduleDuration, ThreadPool.Names.GENERIC, new AbstractRunnable() {
            @Override
            protected void doRun() throws Exception {
                finishPingingRound(pingingRound);
            }

            @Override
            public void onFailure(Exception e) {
                logger.warn("unexpected error while finishing pinging round", e);
            }
        });
这里注意一点就是ping的连接不像其他那样由transportService 来保持长连接，而是即建即销，的一条连接。最后finishPingRound时则把这些临时连接干掉。

选举Master

跳回去findMaster（），上面的ping完之后我们就拿到了一个个pingResponses 这里有个filter操作，如果我们启用了discovery.zen.master_election.ignore_non_master_pings则就会把那些node.master = false 那些节点都忽略掉：

       // filter responses
        final List<ZenPing.PingResponse> pingResponses = filterPingResponses(fullPingResponses, masterElectionIgnoreNonMasters, logger);
接着就要从这些pingResponse里面收集其他节点当前的master节点是谁，最后拿到一个activeMasters的候选的名单，并把自己给去掉，Discovery的策略是非直到最后一刻都不会选自己为master，可能预防脑裂在一开始就发生吧。

       if (activeMasters.isEmpty()) {
            if (electMaster.hasEnoughCandidates(masterCandidates)) {
                final ElectMasterService.MasterCandidate winner = electMaster.electMaster(masterCandidates);
                logger.trace("candidate {} won election", winner);
                return winner.getNode();
            } else {
                // if we don't have enough master nodes, we bail, because there are not enough master to elect from
                logger.warn("not enough master nodes discovered during pinging (found [{}], but needed [{}]), pinging again",
                            masterCandidates, electMaster.minimumMasterNodes());
                return null;
            }
        } else {
            assert !activeMasters.contains(localNode) : "local node should never be elected as master when other nodes indicate an active master";
            // lets tie break between discovered nodes
            return electMaster.tieBreakActiveMasters(activeMasters);
        }
接着就对这个候选列表判断，最理想就是列表为1，就证明你当前加入一个健康的集群中去，如果是有多个（正常情况下肯定不会有多个，除非你没有配置那个discovery.zen.minimum_master_nodes导致很多分治子群了）则在列表里面简单的选一个id号最小的（意思是不参乱了）。如果列表为空，就是大家都是刚启动，则进入选举环节，选举环节还是选出那个id最小的。
现在这个masterNode是定下来了，如果这个master是别人，则就简单的发送个join请求过去就好了，如果选出的master是你自己，那就还有一件很重要的事要做，还记得那个discovery.zen.minimum_master_nodes参数吗，一般要求这个值需要配成你的集群的cluster节点数的一半+1，以预防有脑裂，当前如果你选举出自己是master，那么你还需要等待 minimumMasterNodes() - 1 这么多个人join过来并认同你是master，那你才是真正的master，选举才结束。

       if (transportService.getLocalNode().equals(masterNode)) {
            final int requiredJoins = Math.max(0, electMaster.minimumMasterNodes() - 1); // we count as one
            logger.debug("elected as master, waiting for incoming joins ([{}] needed)", requiredJoins);
            nodeJoinController.waitToBeElectedAsMaster(requiredJoins, masterElectionWaitForJoinsTimeout,
                    new NodeJoinController.ElectionCallback() {
                        @Override
                        public void onElectedAsMaster(ClusterState state) {
                            synchronized (stateMutex) {
                                joinThreadControl.markThreadAsDone(currentThread);
                            }
                        }

                        @Override
                        public void onFailure(Throwable t) {
                            logger.trace("failed while waiting for nodes to join, rejoining", t);
                            synchronized (stateMutex) {
                                joinThreadControl.markThreadAsDoneAndStartNew(currentThread);
                            }
                        }
                    }

            );
        } else {
这里也有一个等待join超时配置，超时后还没有满足数量的join请求，则选举失败，需要新一轮选举，发送接收join的细节就不再过了。
选举流程结束后就会开始同步clusterState了

MasterFaultDetection 和 NodeFaultDetection

选举流程结束后两个重要的小task就开始工作了，分别是masterFaultDetection和NodeFaultDetection，这两个task很简单，就拿一个master的来看，唯一不同就是node的里面保存的是cluster里面所有的nodes。

             if (masterToPing.equals(MasterFaultDetection.this.masterNode())) {
                                // we don't stop on disconnection from master, we keep pinging it
                                threadPool.schedule(pingInterval, ThreadPool.Names.SAME, MasterPinger.this);
                            }
和findMaster（）里面的不一样就是这里不再用temp连接而是在threadPool里面的长连接，这里对错误进行分类，如果是一些业务错误则不受尝试次数的限制，如请求的节点根本不是master节点，请求的master不是自己的cluster等等，会直接调用notifyMasterFailure回调，如果是常规错误，则记录尝试次数，当错误次数超过了阈值，则调用notifyMasterFailure回调。

private void handleMasterGone(final DiscoveryNode masterNode, final Throwable cause, final String reason) {
        if (lifecycleState() != Lifecycle.State.STARTED) {
            // not started, ignore a master failure
            return;
        }
        if (localNodeMaster()) {
            // we might get this on both a master telling us shutting down, and then the disconnect failure
            return;
        }

        logger.info((Supplier<?>) () -> new ParameterizedMessage("master_left [{}], reason [{}]", masterNode, reason), cause);

        synchronized (stateMutex) {
            if (localNodeMaster() == false && masterNode.equals(committedState.get().nodes().getMasterNode())) {
                // flush any pending cluster states from old master, so it will not be set as master again
                pendingStatesQueue.failAllStatesAndClear(new ElasticsearchException("master left [{}]", reason));
                rejoin("master left (reason = " + reason + ")");
            }
        }
    }
ZenDiscovery的回调方法最终将会重新进入rejoin（）流程。

Cluster状态的更新

好了，集群也建立了，master也选出来了，定时ping也保证了，剩下最后就是master如何把clusterState推送到所有节点了。
还记得在Node.java里初始化ZenDiscovery时，注册了clusterState的发布的方法

clusterService.getMasterService().setClusterStatePublisher(discovery::publish);
publish的核心代码是

        pendingStatesQueue.addPending(newState);

        try {
            publishClusterState.publish(clusterChangedEvent, electMaster.minimumMasterNodes(), ackListener);
        } catch (FailedToCommitClusterStateException t) {
            // cluster service logs a WARN message
            logger.debug("failed to publish cluster state version [{}] (not enough nodes acknowledged, min master nodes [{}])",
                newState.version(), electMaster.minimumMasterNodes());

            synchronized (stateMutex) {
                pendingStatesQueue.failAllStatesAndClear(
                    new ElasticsearchException("failed to publish cluster state"));

                rejoin("zen-disco-failed-to-publish");
            }
            throw t;
        }

        final DiscoveryNode localNode = newState.getNodes().getLocalNode();
        final CountDownLatch latch = new CountDownLatch(1);
        final AtomicBoolean processedOrFailed = new AtomicBoolean();
        pendingStatesQueue.markAsCommitted(newState.stateUUID(),
            new PendingClusterStatesQueue.StateProcessedListener() {
                @Override
                public void onNewClusterStateProcessed() {
                    processedOrFailed.set(true);
                    latch.countDown();
                    ackListener.onNodeAck(localNode, null);
                }

                @Override
                public void onNewClusterStateFailed(Exception e) {
                    processedOrFailed.set(true);
                    latch.countDown();
                    ackListener.onNodeAck(localNode, e);
                    logger.warn(
                        (org.apache.logging.log4j.util.Supplier<?>) () -> new ParameterizedMessage(
                            "failed while applying cluster state locally [{}]",
                            clusterChangedEvent.source()),
                        e);
                }
            });
pendingStatesQueue会保存每个待提交的state，并且也会提供最新的commit 的state给其他请求。而发布clusterChangedEvent则交给了PublishClusterStateAction主要逻辑在innerPublish方法

private void innerPublish(final ClusterChangedEvent clusterChangedEvent, final Set<DiscoveryNode> nodesToPublishTo,
                              final SendingController sendingController, final boolean sendFullVersion,
                              final Map<Version, BytesReference> serializedStates, final Map<Version, BytesReference> serializedDiffs) {

        final ClusterState clusterState = clusterChangedEvent.state();
        final ClusterState previousState = clusterChangedEvent.previousState();
        final TimeValue publishTimeout = discoverySettings.getPublishTimeout();

        final long publishingStartInNanos = System.nanoTime();

        for (final DiscoveryNode node : nodesToPublishTo) {
            // try and serialize the cluster state once (or per version), so we don't serialize it
            // per node when we send it over the wire, compress it while we are at it...
            // we don't send full version if node didn't exist in the previous version of cluster state
            if (sendFullVersion || !previousState.nodes().nodeExists(node)) {
                sendFullClusterState(clusterState, serializedStates, node, publishTimeout, sendingController);
            } else {
                sendClusterStateDiff(clusterState, serializedDiffs, serializedStates, node, publishTimeout, sendingController);
            }
        }

        sendingController.waitForCommit(discoverySettings.getCommitTimeout());

        try {
            long timeLeftInNanos = Math.max(0, publishTimeout.nanos() - (System.nanoTime() - publishingStartInNanos));
            final BlockingClusterStatePublishResponseHandler publishResponseHandler = sendingController.getPublishResponseHandler();
            sendingController.setPublishingTimedOut(!publishResponseHandler.awaitAllNodes(TimeValue.timeValueNanos(timeLeftInNanos)));
            if (sendingController.getPublishingTimedOut()) {
                DiscoveryNode[] pendingNodes = publishResponseHandler.pendingNodes();
                // everyone may have just responded
                if (pendingNodes.length > 0) {
                    logger.warn("timed out waiting for all nodes to process published state [{}] (timeout [{}], pending nodes: {})",
                        clusterState.version(), publishTimeout, pendingNodes);
                }
            }
        } catch (InterruptedException e) {
            // ignore & restore interrupt
            Thread.currentThread().interrupt();
        }
    }
在ES2.x 之后支持了发送临近版本的diff来同步状态，目的为了省网络带宽，点进去ClusterState类可以发现里面的状态信息量还是不少，不过diff 需要你的版本和目前的最新的版本只相差一个版本，如果你要从1跳到3需要发送full的状态。sendFullClusterState 和sendClusterStateDiff都会调用底层transportService来真正发送状态，而状态记录通过一个sendingController来维护，没接收到ack或者timeout都会让controller来check是否达到了minMasterNodes-1，达到则标记这次的状态推送commited，其余情况都会抛错。

这里一定需要注意，Publish状态分成两个阶段，首先是sendNotification

 private void sendClusterStateToNode(final ClusterState clusterState, BytesReference bytes,
                                        final DiscoveryNode node,
                                        final TimeValue publishTimeout,
                                        final SendingController sendingController,
                                        final boolean sendDiffs, final Map<Version, BytesReference> serializedStates) {
        try {

            // -> no need to put a timeout on the options here, because we want the response to eventually be received
            //  and not log an error if it arrives after the timeout
            // -> no need to compress, we already compressed the bytes
            TransportRequestOptions options = TransportRequestOptions.builder()
                .withType(TransportRequestOptions.Type.STATE).withCompress(false).build();
            transportService.sendRequest(node, SEND_ACTION_NAME,
                    new BytesTransportRequest(bytes, node.getVersion()),
                    options,
                    new EmptyTransportResponseHandler(ThreadPool.Names.SAME) {

                        @Override
                        public void handleResponse(TransportResponse.Empty response) {
                            if (sendingController.getPublishingTimedOut()) {
                                logger.debug("node {} responded for cluster state [{}] (took longer than [{}])", node,
                                    clusterState.version(), publishTimeout);
                            }
                            sendingController.onNodeSendAck(node);
                        }
就是master先向所有节点发送这个状态，需要等minMasterNodes确认了这个通知，master节点才会把这个状态mark成commited，再sendCommitToNode() 告知所有节点把commited这个状态。

public synchronized void onNodeSendAck(DiscoveryNode node) {
            if (committed) {
                assert sendAckedBeforeCommit.isEmpty();
                sendCommitToNode(node, clusterState, this);
            } else if (committedOrFailed()) {
                logger.trace("ignoring ack from [{}] for cluster state version [{}]. already failed", node, clusterState.version());
            } else {
                // we're still waiting
                sendAckedBeforeCommit.add(node);
                if (node.isMasterNode()) {
                    checkForCommitOrFailIfNoPending(node);
                }
            }
        }
其他Node的处理这两个消息的handler也在这个类里面，有兴趣的可以阅读一下，这里就不过了

 transportService.registerRequestHandler(SEND_ACTION_NAME, BytesTransportRequest::new, ThreadPool.Names.SAME, false, false,
            new SendClusterStateRequestHandler());
        transportService.registerRequestHandler(COMMIT_ACTION_NAME, CommitClusterStateRequest::new, ThreadPool.Names.SAME, false, false,
            new CommitClusterStateRequestHandler());
至此Elasticsearch的整个发现协议和状态更新流程就走完了。
有问题欢迎交流。

作者：华安火车迷
链接：http://www.jianshu.com/p/b21b42d02bd8
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。