https://segmentfault.com/a/1190000006795206

前言
以前写过一些命令行程序，在需要带参数的时候都是自己来判断args，导致程序光解析args都占了好大一堆，而且解析代码也不美观。
偶然间发现了apache公共库中的cli库，在这里分享给大家。

入门
commons-cli中把解释参数分为三种状态，分别是定义、解释和询问交互。

接下来，我以一个例子做一下说明：

maven库：

<dependency>
        <groupId>commons-cli</groupId>
        <artifactId>commons-cli</artifactId>
        <version>1.3.1</version>
</dependency>
import org.apache.commons.cli.*;

public class CLI {
    public static void main(String[] args) throws ParseException {
        //定义
        Options options = new Options();
        options.addOption("h",false,"list help");//false代表不强制有
        options.addOption("t",true,"set time on system");

        //解析
        //1.3.1中已经弃用针对不同格式入参对应的解析器
        //CommandLineParser parser = new PosixParser();
        CommandLineParser parser = new DefaultParser();
        CommandLine cmd = parser.parse(options,args);

        //查询交互
        //你的程序应当写在这里，从这里启动
        if (cmd.hasOption("h")){
            String formatstr = "CLI  cli  test";
            HelpFormatter hf = new HelpFormatter();
            hf.printHelp(formatstr, "", options, "");
            return;
        }

        if (cmd.hasOption("t")){
            System.out.printf("system time has setted  %s \n",cmd.getOptionValue("t"));
            return;
        }

        System.out.println("error");
    }
}
在另一个类中做一下测试

String argss[]={"-t  1000"};
CLI.main(argss);
结果是：

system time has setted 1000

String argss[]={"-h"};
CLI.main(argss);
结果是：

usage: CLI cli test
-h list help
-t <arg> set time on system

好啦，入门就到这里了。

代码结构分析
包组织结构：

commons-cli-1.3.1.jar
org.apache.commons.cli

在cli包中，包含了所有的类，包括定义，解析，查询交互和Exception

类的关系结构图如下



定义
在定义这一部分，最重要的类是Option，Option类中定义了一个基本的选项，例如-t xxx ，是否为必选项，该命令的解释等等。

Option重写了很多构造函数，但是最终都调用下面这个构造函数：

public Option(String opt, String longOpt, boolean hasArg, String description)
           throws IllegalArgumentException
    {
        //写这个代码的人以前应该是写C++的。。。
        // 判断短选项是否包含非法字符，如果包含抛出异常
        OptionValidator.validateOption(opt);
        //短选项
        this.opt = opt;
        //长选项
        this.longOpt = longOpt;

        // 是否是必要选项
        if (hasArg)
        {
            this.numberOfArgs = 1;
        }
        //选项描述
        this.description = description;
    }
OptionsGroup类中包含了许多个Option，并可以对多个Option进行一些处理。其实现是采用一个HashMap来存储Option的，key是Option中的长选项或者短选项的第一个字符，如果短选项存在，则优先选择短选项。

OptionGroup类还包含了一个组描述和组是否必须存在，相当于对一群Option的群组操作。

Options类是被解析的对象，使用者可以在Options实例中直接添加命令，也可以添加Option实例，也可以添加OptionGroup实例。

其addOption方法最终调用了其重写的一个方法：

public Options addOption(Option opt)
    {
        String key = opt.getKey();

        // add it to the long option list
        if (opt.hasLongOpt())
        {
            longOpts.put(opt.getLongOpt(), opt);
        }

        // if the option is required add it to the required list
        if (opt.isRequired())
        {
            if (requiredOpts.contains(key))
            {
                requiredOpts.remove(requiredOpts.indexOf(key));
            }
            requiredOpts.add(key);
        }

        shortOpts.put(key, opt);

        return this;
    }
添加GroupOption方法如下：

public Options addOptionGroup(OptionGroup group)
    {
        if (group.isRequired())
        {
            requiredOpts.add(group);
        }

        for (Option option : group.getOptions())
        {
            // an Option cannot be required if it is in an
            // OptionGroup, either the group is required or
            // nothing is required
            option.setRequired(false);
            addOption(option);

            optionGroups.put(option.getKey(), group);
        }

        return this;
    }
解析
接下来就是CommandLineParser接口，在1.3.1版本中取消了Parser抽象类，GnuParser、BasicParser、PosixParser类，取而代之的是DefaultParser类。DefaultParser类提供了对Options实例的解析，即对入参命令和Options实例之间对应关系的解析，返回的类是CommandLine。如果入参命令与Options实例对应不上就会抛出解析异常。

DefaultParser类解析方法最基本的方法是handleToken(String token)，token是每一个入参字符串。这个方法会在解析错误的时候抛出解析异常。

查询交互
CommandLine可以对入参命令进行判断解析，例如可以查询是否存在某个选项，以及获取这个选项的值。

总结
cli包还是相当简单的，大家也可以自己看一看commons库的源码。

更多文章：http://blog.gavinzh.com