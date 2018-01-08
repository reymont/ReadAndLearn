
//C:\workspace\java\dubbo\dubbo-admin-api\src\main\java\com\alibaba\dubbo\governance\service\impl\ProviderServiceImpl.java

    public List<Provider> findByService(String serviceName) {
        return SyncUtils.url2ProviderList(findProviderUrlByService(serviceName));
    }

    private Map<Long, URL> findProviderUrlByService(String service) {
        Map<String, String> filter = new HashMap<String, String>();
        filter.put(Constants.CATEGORY_KEY, Constants.PROVIDERS_CATEGORY);
        filter.put(SyncUtils.SERVICE_FILTER_KEY, service);
        
        return SyncUtils.filterFromCategory(getRegistryCache(), filter);
    }