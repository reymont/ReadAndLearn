Java Properties 类读配置文件保持顺序 - 霞光里 - 博客园 https://www.cnblogs.com/loong-hon/p/9957575.html

前几天，公司项目中有一个需求是读取配置文件的，而且最好能够保证加载到内存中的顺序能够和配置文件中的顺序一致，但是，如果使用 jdk 中提供的 Properties 类的话，读取配置文件后，加载到内存中的顺序是随机的，不能保证和原文件的顺序一致，因此，jdk 提供的 Properties 是不行的。

由于有这样的需求，而 Java 的 Properties 类又不能实现，因此只能想别的办法。我曾经想过，在把配置文件加载到内存后，对其进行排序，但这个方案会有很多限制，而且也有问题。配置文件中的信息会有很多，如果对其进行再排序的话，首先会影响系统的性能，其次，对程序的执行效率来讲，也会有一定的影响。最后，经过一番查证之后，同事找到了一篇类似的文章。

解决方案

从文章中了解到，Java 的 Properties 加载属性文件后是无法保证输出的顺序与文件中一致的，因为 Properties 是继承自 Hashtable 的， key/value 都是直接存在 Hashtable 中的，而 Hashtable 是不保证进出顺序的。

文章中已经给提供了代码，思路是继承自 Properties，覆盖原来的 put/keys，keySet，stringPropertyNames 即可，其中用一个 LinkedHashSet 来保存它的所有 key。完整代码如下：

复制代码
import java.util.Collections;
import java.util.Enumeration;
import java.util.LinkedHashSet;
import java.util.Properties;
import java.util.Set;

/**
 * OrderedProperties
 * @author hanwl
 * @date 2018-11-13
 * @userd 使得Properties有序
 */
public class OrderedProperties extends Properties {

    private static final long serialVersionUID = 4710927773256743817L;

    private final LinkedHashSet<Object> keys = new LinkedHashSet<Object>();

    @Override
    public Enumeration<Object> keys() {
        return Collections.<Object> enumeration(keys);
    }

    @Override
    public Object put(Object key, Object value) {
        keys.add(key);
        return super.put(key, value);
    }

    @Override
    public Set<Object> keySet() {
        return keys;
    }

    @Override
    public Set<String> stringPropertyNames() {
        Set<String> set = new LinkedHashSet<String>();

        for (Object key : this.keys) {
            set.add((String) key);
        }

        return set;
    }
}
复制代码
 

调用方法：

复制代码
public class demo {
    Properties prop = new OrderedProperties();
    File appDir = GlobalVars.getLocalAppDataDir();
    File dir = new File(appDir, "userHistory/");
    if (!dir.exists()) {
        dir.mkdirs();
    }
    try {
        OutputStreamWriter oStreamWriter = new OutputStreamWriter(new FileOutputStream(dir+"\\user.properties",true), "utf-8");
        //FileOutputStream fileOutputstream = new FileOutputStream(dir+"\\user.properties", false);
        prop.setProperty("serverUrl", serverUrlTextField.getText());
        prop.setProperty("userName", userNameTextField.getText());
        prop.setProperty("password", passwordField.getText());
        prop.store(oStreamWriter, null);
        oStreamWriter.close();

    } catch (Exception e) {
        e.printStackTrace();
    }

    Properties prop = new OrderedProperties();
    File appDir = GlobalVars.getLocalAppDataDir();
    File dir = new File(appDir, "userHistory/");
    if(new File(dir+"\\user.properties").exists()){
        try {
            InputStreamReader iStreamReader = new InputStreamReader(new FileInputStream(dir+"\\user.properties"),"utf-8");
            prop.load(iStreamReader);
            Iterator<String> it = prop.stringPropertyNames().iterator();
            while (it.hasNext()) {
                 String key = it.next();
                 String value  = prop.getProperty(key);
                 System.out.println(key+":"+value);
            }
            iStreamReader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

复制代码
复制代码
    /**
     * 返回程序本地数据存储目录
     * C:\Users\Administrator\AppData\Local\Founder\PublisherClient
     * C:\Users\Administrator\AppData\Local\Founder\PrinterClient
     * C:\Users\Administrator\AppData\Local\Founder\TypeSettingClient
     * @return
     */
    public static File getLocalAppDataDir() {
        String appDataPath;
        if (Util.isMac()) {
            appDataPath = System.getProperty("user.home") + "/Library/";
        }
        else if (NativeUtil.libraryLoaded()) {
            appDataPath = NativeUtil.getLocalAppDataFolder();
        }
        else {
            appDataPath = System.getProperty("user.home");
        }

        File founderDir = new File(appDataPath, Util.isWindows() || Util.isMac() ? "Founder" : ".Founder");
        File appDir = new File(founderDir, CLIENT_TYPE.getClientName());
        appDir.mkdirs();

        return appDir;
    }
复制代码
结束
 
　　这种特定的需求，以前倒是没怎么接触过，不给通过这次的经历，发现了一点，自己的积累还是很少，不多说了，继续努力吧。
 
参考：
StackOverflow
Playframework1中的另一个实现