java中的SPI机制 - OrcHome http://orchome.com/762

https://github.com/orchome/spi
* fork
  https://github.com/reymont/spi

作者：半兽人
链接：http://orchome.com/762
来源：OrcHome
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

SPI机制简介

SPI的全名为Service Provider Interface.大多数开发人员可能不熟悉，因为这个是针对厂商或者插件的。在java.util.ServiceLoader的文档里有比较详细的介绍。简单的总结下java spi机制的思想。我们系统里抽象的各个模块，往往有很多不同的实现方案，比如日志模块的方案，xml解析模块、jdbc模块的方案等。面向的对象的设计里，我们一般推荐模块之间基于接口编程，模块之间不对实现类进行硬编码。一旦代码里涉及具体的实现类，就违反了可拔插的原则，如果需要替换一种实现，就需要修改代码。为了实现在模块装配的时候能不在程序里动态指明，这就需要一种服务发现机制。 java spi就是提供这样的一个机制：`为某个接口寻找服务实现的机制`。有点类似IOC的思想，就是将装配的控制权移到程序之外，在模块化设计中这个机制尤其重要。

SPI具体约定

java spi的具体约定为:当服务的提供者，提供了服务接口的一种实现之后，在jar包的META-INF/services/目录里同时创建一个以服务接口命名的文件。该文件里就是实现该服务接口的具体实现类。而当外部程序装配这个模块的时候，就能通过该jar包META-INF/services/里的配置文件找到具体的实现类名，并装载实例化，完成模块的注入。 基于这样一个约定就能很好的找到服务接口的实现类，而不需要再代码里制定。jdk提供服务实现查找的一个工具类：java.util.ServiceLoader

应用场景

common-logging
apache最早提供的日志的门面接口。只有接口，没有实现。具体方案由各提供商实现， 发现日志提供商是通过扫描 META-INF/services/org.apache.commons.logging.LogFactory配置文件，通过读取该文件的内容找到日志提工商实现类。只要我们的日志实现里包含了这个文件，并在文件里制定 LogFactory工厂接口的实现类即可。

jdbc
jdbc4.0以前， 开发人员还需要基于Class.forName("xxx")的方式来装载驱动，jdbc4也基于spi的机制来发现驱动提供商了，可以通过META-INF/services/java.sql.Driver文件里指定实现类的方式来暴露驱动提供者.

举个例子

1、 创建 DogService

package com.system.spi;

public interface DogService {
    void sleep();
}
2、 实现 BlackDogServiceImpl

package com.system.spi.impl;

import com.system.spi.DogService;

public class WhiteDogServiceImpl implements DogService {

    public void sleep() {
        System.out.println("white Dog,sleep...");
    }
}
3、 实现 WhiteDogServiceImpl

package com.system.spi.impl;

import com.system.spi.DogService;

public class WhiteDogServiceImpl implements DogService {

    public void sleep() {
        System.out.println("white Dog,sleep...");
    }
}
4、 src/META-INF/services/com.system.spi.DogService 文件中的代码:

com.system.spi.impl.BlackDogServiceImpl
com.system.spi.impl.WhiteDogServiceImpl
5、最后运行用例

package com.system.spi.test;

import com.sun.tools.javac.util.ServiceLoader;
import com.system.spi.DogService;


public class Test {

    public static void main(String[] args) throws Exception {
        ServiceLoader<DogService> loaders = ServiceLoader.load(DogService.class);

        for (DogService d : loaders) {
            d.sleep();
        }
    }
}
运行结果

black Dog,sleep...
white Dog,sleep...
项目结构如下

├── README.md
├── pom.xml
├── spi.iml
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── system
    │   │           └── spi
    │   │               ├── DogService.java
    │   │               └── impl
    │   │                   ├── BlackDogServiceImpl.java
    │   │                   └── WhiteDogServiceImpl.java
    │   └── resources
    │       └── META-INF
    │           └── services
    │               └── com.system.spi.DogService
    └── test
        └── java
            └── com
                └── system
                    └── spi
                        └── test
                            └── Test.java
源码地址，拉下来可直接运行：https://github.com/orchome/spi