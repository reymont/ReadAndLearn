
// C:\workspace\cmi\jtp\dubbox\dubbo-admin\src\main\java\com\alibaba\dubbo\governance\sync\RegistryServerSync.java


// registryCache的初始化

    // 收到的通知对于 ，同一种类型数据（override、subcribe、route、其它是Provider），同一个服务的数据是全量的
    public void notify(List<URL> urls) {
        if(urls == null || urls.isEmpty()) {
        	return;
        }
        // Map<category, Map<servicename, Map<Long, URL>>>
        final Map<String, Map<String, Map<Long, URL>>> categories = new HashMap<String, Map<String, Map<Long, URL>>>();
        for(URL url : urls) {
        	String category = url.getParameter(Constants.CATEGORY_KEY, Constants.PROVIDERS_CATEGORY);
            if(Constants.EMPTY_PROTOCOL.equalsIgnoreCase(url.getProtocol())) { // 注意：empty协议的group和version为*
            	ConcurrentMap<String, Map<Long, URL>> services = registryCache.get(category);
            	if(services != null) {
            		String group = url.getParameter(Constants.GROUP_KEY);
            		String version = url.getParameter(Constants.VERSION_KEY);
            		// 注意：empty协议的group和version为*
            		if (! Constants.ANY_VALUE.equals(group) && ! Constants.ANY_VALUE.equals(version)) {
            			services.remove(url.getServiceKey());
            		} else {
	                	for (Map.Entry<String, Map<Long, URL>> serviceEntry : services.entrySet()) {
	                		String service = serviceEntry.getKey();
	                		if (Tool.getInterface(service).equals(url.getServiceInterface())
	                				&& (Constants.ANY_VALUE.equals(group) || StringUtils.isEquals(group, Tool.getGroup(service)))
	                				&& (Constants.ANY_VALUE.equals(version) || StringUtils.isEquals(version, Tool.getVersion(service)))) {
	                			services.remove(service);
	                		}
	                	}
            		}
                }
            } else {
            	Map<String, Map<Long, URL>> services = categories.get(category);
                if(services == null) {
                    services = new HashMap<String, Map<Long,URL>>();
                    categories.put(category, services);
                }
                String service = url.getServiceKey();
                Map<Long, URL> ids = services.get(service);
                if(ids == null) {
                    ids = new HashMap<Long, URL>();
                    services.put(service, ids);
                }
                ids.put(ID.incrementAndGet(), url);
            }
        }
        for(Map.Entry<String, Map<String, Map<Long, URL>>> categoryEntry : categories.entrySet()) {
            String category = categoryEntry.getKey();
            ConcurrentMap<String, Map<Long, URL>> services = registryCache.get(category);
            if(services == null) {
                services = new ConcurrentHashMap<String, Map<Long,URL>>();
                registryCache.put(category, services);
            }
            services.putAll(categoryEntry.getValue());
        }
    }