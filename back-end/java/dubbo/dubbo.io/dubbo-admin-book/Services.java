
//C:\workspace\cmi\jtp\dubbox\dubbo-admin\src\main\java\com\alibaba\dubbo\governance\web\governance\module\screen\Services.java

public boolean tolerant(Map<String, Object> context) throws Exception {
	return mock(context, "fail:return null");
}

"&mock=force%3Areturn+null"

// Notify urls for subscribe url 
// consumer://172.20.54.25/org.spring.springboot.dubbo.CityDubboService?application=consumer&category=providers,
// configurators,routers&dubbo=2.5.3&interface=org.spring.springboot.dubbo.CityDubboService
// &methods=findCityByName&pid=18736&revision=1.0.0&side=consumer&timestamp=1514199469655&version=1.0.0, 
// urls: [override://0.0.0.0/org.spring.springboot.dubbo.CityDubboService?application=consumer
// &category=configurators&dynamic=false&enabled=true&mock=force%3Areturn+null&version=1.0.0], 
// dubbo version: 2.5.3, current host: 172.20.54.25