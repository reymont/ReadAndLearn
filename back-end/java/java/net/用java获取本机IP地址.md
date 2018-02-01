用java获取本机IP地址 - CSDN博客 http://blog.csdn.net/thunder09/article/details/5360251

方法一（只能在Windows上使用，Linux平台就gei屁了）：
```java
try
{ 
System.out.println("本机的IP = " + InetAddress.getLocalHost());
} catch (UnknownHostException e)
{ 
e.printStackTrace();
}
```

在Linux下的执行结果是：本机的IP = xxx/127.0.1.1 (其中xxx是你的计算机名，偶这里马赛克了)

方法二(宣称可以在Linux下执行)

Enumeration netInterfaces=NetworkInterface.getNetworkInterfaces();
InetAddress ip = null;
while(netInterfaces.hasMoreElements())
{
NetworkInterface ni=(NetworkInterface)netInterfaces.nextElement();
System.out.println(ni.getName());
ip=(InetAddress) ni.getInetAddresses().nextElement();
if( !ip.isSiteLocalAddress() 
&& !ip.isLoopbackAddress() 
&& ip.getHostAddress().indexOf(":")==-1)
{
System.out.println ("本机的ip=" + ip.getHostAddress());
break;
}
else
{
ip=null;
}
}
从红色部分的代码可以看到，该代码对于获取到的第一个NetworkInterface的IP地址的获取，没有循环的获取，只是对第一个IP地址进行了处理，这样就导致了如果第一个IP地址不是一个
Inet4Address的地址而是一个< span
id="ArticleContent1_ArticleContent1_lblContent">Inet6Address，这个判断 ip.getHostAddress().indexOf(":")==-1将永远是false,这个if条件进不去呀，多害人，强烈鄙视！

不过方法二思路是对了，就是有些小毛病，让偶修改了一下，最终版的可以在 Linux下正确执行的代码如下：

```java
		List<String> results = new ArrayList<>();
		Enumeration<NetworkInterface> allNetInterfaces = NetworkInterface.getNetworkInterfaces();
		InetAddress ip = null;
		while (allNetInterfaces.hasMoreElements()) {
			NetworkInterface netInterface = (NetworkInterface) allNetInterfaces.nextElement();
			// System.out.println(netInterface.getName());
			Enumeration<InetAddress> addresses = netInterface.getInetAddresses();
			while (addresses.hasMoreElements()) {
				ip = (InetAddress) addresses.nextElement();
				if (ip != null && ip instanceof Inet4Address) {
					System.out.println("本机的IP = " + ip.getHostAddress());
					results.add(ip.getHostAddress());
				}
			}
		}
		System.out.println("本机的IP = " + results);
```