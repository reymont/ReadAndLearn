
// C:\workspace\cmi\jtp\dubbox\dubbo-admin\src\main\java\com\alibaba\dubbo\governance\service\impl\OverrideServiceImpl.java

public void saveOverride(Override override) {
    URL url = getUrlFromOverride(override);
    registryService.register(url);
}