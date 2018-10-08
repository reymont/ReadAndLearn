十分钟写个RPC框架-博客-云栖社区-阿里云 https://yq.aliyun.com/articles/66167

https://github.com/shocklee6315/simpleRpcServer



互联网时代，各种RPC框架盛行，细看各种框架，应用层面有各种变化，但是万变不离其宗，RPC最核心的部分基本都是一致的。
那就是跟远程的服务器进行通信，像调用本地服务一样调用远程服务。
然后在这些基础上可能会附加一些诸如，服务自动注册和发现，负载均衡，就近路由，调用链路记录，远程mock等等功能。
今天想给大家分享的是，如果不考虑性能，API易用性，服务发现，负载均衡，环境隔离等其他因素，其实做一个基本功能的RPC框架，几分钟就能搞定。
个人认为RPC功能的基石有下面几个 

* RPC功能
  * 一、序列化协议 
  * 二、远程通信报文协议 
  * 三、协议报文处理实现。

序列化协议JDK为我们提供了一套自带的序列化协议，虽然不能跨语言，压缩率不高，不过我们只为展示RPC技术，没有考虑其他，如果觉得不好可以使用Hessian ,protobuf,甚至是诸如fastjson这些json序列化的开源框架。

* 远程通信JDK有一套socket和输入输出流，虽然是同步的，性能不怎么样，但是只为展示RPC技术原理，不考虑其他，为了性能和吞吐量我们可以选择netty进行改造。

* 通信协议，我只做了一个简单的 MAGIC_NUM+两个字节报文长+序列化对象字节流 的协议，协议上可以增加很多东西，比如版本号，心跳包，状态码，可扩展的报文头等等，不过同样的，这里只为展示RPC原理，不考虑其他的。

* 协议报文处理部分只是通过报文体里面携带的 类名 方法名，方法参数，做了个简单的反射处理，这部分其实可以扩展的部分很多，比如预先做方法缓存，方法签名使用短命名注册等等，或者想更快还能通过字节码注入的方式自动生成一些模板代码的方式，将反射变成直接的方法调用。

下面直接展示代码吧
首先是传输的对象都是java可序列化对象：
public class RpcCommand implements Serializable{
    String className ;
    String methodName ;
    String[] argumetsType ;

    Object[] params ;
    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public String getMethodName() {
        return methodName;
    }

    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public String[] getArgumetsType() {
        return argumetsType;
    }

    public void setArgumetsType(String[] argumetsType) {
        this.argumetsType = argumetsType;
    }

    public Object[] getParams() {
        return params;
    }

    public void setParams(Object[] params) {
        this.params = params;
    }


}
public class RpcResponse implements Serializable{
    boolean isException;
    Object result ;
    Exception exception;
    public boolean isException() {
        return isException;
    }

    public void setException(boolean exception) {
        isException = exception;
    }

    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }

    public Exception getException() {
        return exception;
    }

    public void setException(Exception exception) {
        this.exception = exception;
    }

}
 

其次是请求对象的处理部分
package com.shock.rpc;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

/**
 * ${DESCRIPTION}
 * com.shock.rpc.${CLASS_NAME}
 * Created by zhengdong.lzd on 2016/11/29 0029.
 */
public class RpcHandler {

    ConcurrentHashMap<String, Object> registered = new ConcurrentHashMap<String, Object>(128);

    public RpcResponse handler(RpcCommand commond) {
        String className = commond.getClassName();
        RpcResponse response = new RpcResponse();
        try {
            Object obj = registered.get(className);
            String[] argTypes = commond.getArgumetsType();
            Class aClass = Class.forName(className);
            List<Class> argsTypeList = new ArrayList<Class>(argTypes.length);
            for (String s : argTypes) {
                argsTypeList.add(Class.forName(s));
            }
            Method method = aClass.getMethod(commond.getMethodName(),
                argsTypeList.toArray(new Class[argsTypeList.size()]));
            Object object = method.invoke(obj, commond.getParams());
            response.setResult(object);
        } catch (Exception e) {
            e.printStackTrace();
            response.setException(true);
            response.setException(e);
        }
        return response;
    }

    public void regist(Class interfa, Object object) {
        registered.put(interfa.getName(), object);
    }
}
 代码里面只有很粗暴的反射实现

第三个是服务端启动和服务端协议处理代码

package com.shock.rpc;

import com.shock.rpc.demo.IDemoImpl;
import com.shock.rpc.demo.IDemoInterface;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * ${DESCRIPTION}
 * com.shock.rpc.${CLASS_NAME}
 * Created by zhengdong.lzd on 2016/11/29 0029.
 */
public class RpcServer {
    int port;

    public RpcServer(int port, RpcHandler handler) {
        this.port = port;
        this.handler = handler;
    }

    RpcHandler      handler;

    ExecutorService executorService = Executors.newFixedThreadPool(20);

    public void start() {
        try {
            ServerSocket serverSocket = new ServerSocket(port);
            while (true) {
                Socket socket = serverSocket.accept();
                executorService.submit(new WorkThread(socket));
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public class WorkThread implements Runnable {
        Socket socket;

        WorkThread(Socket socket) {
            this.socket = socket;
        }

        @Override
        public void run() {
            try {
                InputStream inputStream = socket.getInputStream();
                OutputStream outputStream = socket.getOutputStream();
                while (true) {
                    int magic = inputStream.read();
                    //魔数
                    if (magic == 0x5A) {
                        //两个字节用来计算长度数据长度，服务传送的数据过大可能会出现截断问题
                        int length1 = inputStream.read();
                        int length2 = inputStream.read();
                        int length = (length1 << 8) + length2;
                        ByteArrayOutputStream bout = new ByteArrayOutputStream(length);
                        int sum = 0;
                        byte[] bs = new byte[length];
                        while (true) {
                            int readLength = inputStream.read(bs, 0, length - sum);
                            if (readLength > 0) {
                                bout.write(bs, 0, readLength);
                                sum += readLength;
                            }
                            if (sum >= length) {
                                break;
                            }
                        }
                        ObjectInputStream objectInputStream = new ObjectInputStream(
                            new ByteArrayInputStream(bout.toByteArray()));
                        try {
                            RpcCommand commond = (RpcCommand) objectInputStream.readObject();
                            RpcResponse response = handler.handler(commond);
                            ByteArrayOutputStream objectout = new ByteArrayOutputStream(length);
                            ObjectOutputStream objectOutputStream = new ObjectOutputStream(objectout);
                            objectOutputStream.writeObject(response);
                            objectOutputStream.flush();
                            byte[] commondBytes = objectout.toByteArray();
                            int len = commondBytes.length;
                            outputStream.write(0x5A);
                            outputStream.write(len >> 8);
                            outputStream.write(len & 0x00FF);
                            outputStream.write(commondBytes);
                            outputStream.flush();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("和客户端连接断开了");
            } finally {
                if (socket != null) {
                    try {
                        socket.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    public static void main(String[] args) {
        RpcHandler rpcHandler = new RpcHandler();
        rpcHandler.regist(IDemoInterface.class, new IDemoImpl());
        RpcServer servcer = new RpcServer(8081, rpcHandler);
        servcer.start();
    }
}
 代码实现也很简单，就是根据前面说的传输报文协议读取传输的报文，反序列化出请求对象RpcCommand，给处理类进行处理，如果做好兼容加上版本和不同协议的话，可以增加不同的处理实现。


最后是客户端传输和协议处理代码
package com.shock.rpc;

import com.shock.rpc.demo.IDemoInterface;

import java.io.*;
import java.net.InetSocketAddress;
import java.net.Socket;

/**
 * ${DESCRIPTION}
 * com.shock.rpc.${CLASS_NAME}
 * Created by zhengdong.lzd on 2016/11/29 0029.
 */
public class RpcClient {

    String       host;
    int          port;
    Socket       socket;
    InputStream  inputStream;
    OutputStream outputStream;

    public RpcClient(String host, int port) {
        try {
            socket = new Socket();
            socket.connect(new InetSocketAddress(host, port));
            inputStream = socket.getInputStream();
            outputStream = socket.getOutputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //这个不能并发请求，否则会出现数据流乱的情况
    public synchronized RpcResponse invoke(RpcCommand commond) {
        RpcResponse response = new RpcResponse();
        try {
            ByteArrayOutputStream objectout = new ByteArrayOutputStream();
            ObjectOutputStream objectOutputStream = new ObjectOutputStream(objectout);
            objectOutputStream.writeObject(commond);
            objectOutputStream.flush();
            byte[] commondBytes = objectout.toByteArray();
            outputStream.write(0x5A);
            int len = commondBytes.length;

            outputStream.write(len >> 8);
            outputStream.write(0x00FF & len);
            outputStream.write(commondBytes);
            outputStream.flush();
            while (true) {
                int magic = inputStream.read();
                if (magic == 0x5A) {
                    int length1 = inputStream.read();
                    int length2 = inputStream.read();
                    int length = (length1 << 8) + length2;
                    ByteArrayOutputStream bout = new ByteArrayOutputStream(length);
                    int sum = 0;
                    byte[] bs = new byte[length];
                    while (true) {
                        int readLength = inputStream.read(bs, 0, length - sum);
                        if (readLength > 0) {
                            bout.write(bs, 0, readLength);
                            sum += readLength;
                        }
                        if (sum >= length) {
                            break;
                        }
                    }
                    ObjectInputStream objectInputStream = new ObjectInputStream(
                        new ByteArrayInputStream(bout.toByteArray()));
                    RpcResponse response1 = (RpcResponse) objectInputStream.readObject();
                    return response1;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return response;
    }

    public static void main(String[] args) {
        RpcClient client = new RpcClient("localhost", 8081);
        RpcCommand command = new RpcCommand();
        command.setClassName(IDemoInterface.class.getName());
        command.setMethodName("noArgument");
        command.setArgumetsType(new String[0]);
        RpcResponse response = client.invoke(command);

        RpcCommand command2 = new RpcCommand();
        command2.setClassName(IDemoInterface.class.getName());
        command2.setMethodName("withReturn");
        command2.setArgumetsType(new String[] { "java.lang.String" });
        command2.setParams(new String[] { "shocklee" });
        RpcResponse response2 = client.invoke(command2);
        System.out.println(response.getResult());
        System.out.println(response2.getResult());
    }
}
 

至此整个框架部分已经完成，暂时还没有做常见的rpc客户端api包装，比如包装成从某个容器里面根据接口取出一个远程对象，直接调用远程对象的方法。
最后贴个测试类和接口
package com.shock.rpc.demo;

/**
 * ${DESCRIPTION}
 * com.shock.rpc.demo.${CLASS_NAME}
 * Created by zhengdong.lzd on 2016/11/29 0029.
 */
public interface IDemoInterface {

    public String withReturn(String name);
    public void noReturn(String name);
    public String noArgument();
}
package com.shock.rpc.demo;

/**
 * ${DESCRIPTION}
 * com.shock.rpc.demo.${CLASS_NAME}
 * Created by zhengdong.lzd on 2016/11/29 0029.
 */
public class IDemoImpl implements IDemoInterface {
    @Override
    public String withReturn(String name) {
        System.out.println("withReturn "+name);
        return "hello " + name;
    }

    @Override
    public void noReturn(String name) {
        System.out.println("noReturn "+name);
    }

    @Override
    public String noArgument() {
        System.out.println("noArgument");
        return "noArgument";
    }
}
 

整个RPC功能已经都贴出来了，代码没有做过整理，没有把序列化/反序列代码抽象,协议部分也没做抽象，只是想写的快点，能够在短时间内写出来和标题十分钟对应上，所以可能代码难看点，不过整体已经展示出来了，关键代码是不需要使用任何第三方框架和工具包的。

欢迎大家进行拍砖。

另外打个广告吧，本人写了一个稍微复杂点的RPC放在github上，有木有同学想一起进行写着玩的的，赶紧约起啊，代码地址是
https://github.com/shocklee6315/simpleRpcServer
如果您发现本社区中有涉嫌抄袭的内容，欢迎发送邮件至：yqgroup@service.aliyun.com 进行举报，并提供相关证据，一经查实，本社区将立刻删除涉嫌侵权内容。