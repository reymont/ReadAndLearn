
//C:\workspace\java\dubbo\brave-dubbo\src\main\java\com\github\kristofa\brave\dubbo\DubboClientRequestAdapter.java

//设置url
    @Override
    public Collection<KeyValueAnnotation> requestAnnotations() {
        return Collections.singletonList(KeyValueAnnotation.create("url", RpcContext.getContext().getUrl().toString()));
    }

//C:\workspace\java\dubbo\brave-dubbo\src\main\java\com\github\kristofa\brave\dubbo\DubboServerResponseAdapter.java

    @Override
    public Collection<KeyValueAnnotation> responseAnnotations() {
        List<KeyValueAnnotation> annotations = new ArrayList<KeyValueAnnotation>();
        Object result = rpcResult.getValue();
        if(!rpcResult.hasException()){
            KeyValueAnnotation keyValueAnnotation=  KeyValueAnnotation.create("server_result",result!=null?result.toString():"");
            annotations.add(keyValueAnnotation);
        }else {
            KeyValueAnnotation keyValueAnnotation=  KeyValueAnnotation.create("exception",rpcResult.getException().getMessage());
            annotations.add(keyValueAnnotation);
        }
        return annotations;
    }

//C:\workspace\java\dubbo\brave-dubbo\src\main\java\com\github\kristofa\brave\dubbo\DubboClientRequestAdapter.java

// 设置client 的服务器地址

    @Override
    public Endpoint serverAddress() {
        InetSocketAddress inetSocketAddress = RpcContext.getContext().getRemoteAddress();
        String ipAddr = RpcContext.getContext().getUrl().getIp();
        String serverName = serverNameProvider.resolveServerName(RpcContext.getContext());
        return Endpoint.create(serverName, IPConversion.convertToInt(ipAddr),inetSocketAddress.getPort());
    }