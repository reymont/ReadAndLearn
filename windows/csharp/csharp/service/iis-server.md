

* [C#创建Windows服务与安装-图解_百度经验 ](http://jingyan.baidu.com/article/fa4125acb71a8628ac709226.html)


```bash
#以管理员身份打开cmd。执行安装
cd C:\Windows\Microsoft.NET\Framework64\v4.0.30319
InstallUtil.exe E:\workspace\window\OpenBridge-CloudOS-IISAdmin\IISService\bin\Debug\IISService.exe
#删除服务
sc delete CloudOSIISService
```

* [C# 编写Windows服务实现开机启动一个程序 - Jerry_Wu - 博客园 ](http://www.cnblogs.com/perzy/p/3385121.html)

```cs
protected override void OnStart(string[] args)
{
    try
    {
        Process proc = new Process();
        proc.StartInfo.FileName = StartAppPath; //注意路径  
        proc.Start();
    }
    catch (System.Exception ex)
    {
        //错误处理  
    }
}
```

# System.Diagnostics.Process

* [System.Diagnostics.Process 执行.EXE - huangqing - 博客园 ](http://www.cnblogs.com/huangqing/articles/2232985.html)
* [Process Class (System.Diagnostics) ](https://msdn.microsoft.com/en-us/library/system.diagnostics.process(v=vs.110).aspx#Examples)


* [C#创建windows服务并定时执行 - 专注程序设计开发 - CSDN博客 ](http://blog.csdn.net/armyfai/article/details/8056976)
```cs
namespace IISService
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : System.Configuration.Install.Installer
    {
        public ProjectInstaller()
        {
            InitializeComponent();
            this.Committed += new InstallEventHandler(ProjectInstaller_Committed);
        }

        private void ProjectInstaller_Committed(object sender, InstallEventArgs e)
        {
            //参数为服务的名字
            System.ServiceProcess.ServiceController controller = new System.ServiceProcess.ServiceController("CloudOSIISService");
            controller.Start();
        }
    }
}
```



* [c# - Inno Setup for Windows service? - Stack Overflow ](https://stackoverflow.com/questions/1449994/inno-setup-for-windows-service)

```cs
using System;
using System.Collections.Generic;
using System.Configuration.Install; 
using System.IO;
using System.Linq;
using System.Reflection; 
using System.ServiceProcess;
using System.Text;

static void Main(string[] args)
{
    if (System.Environment.UserInteractive)
    {
        string parameter = string.Concat(args);
        switch (parameter)
        {
            case "--install":
                ManagedInstallerClass.InstallHelper(new string[] { Assembly.GetExecutingAssembly().Location });
                break;
            case "--uninstall":
                ManagedInstallerClass.InstallHelper(new string[] { "/u", Assembly.GetExecutingAssembly().Location });
                break;
        }
    }
    else
    {
        ServiceBase.Run(new WindowsService());
    }
}
```

# ManagedInstallerClass.InstallHelper

* [创建windows service 并打包成安装文件 - PeterZhang - 博客园 ](http://www.cnblogs.com/Peter-Zhang/archive/2011/09/17/2121484.html)
* [Windows Service的安装卸载 和 Service控制 - PeterZhang - 博客园 ](http://www.cnblogs.com/Peter-Zhang/archive/2011/10/15/2212663.html)
* [【C#】分享基于Win32 API的服务操作类（解决ManagedInstallerClass.InstallHelper不能带参数安装的问题） - ahdung - 博客园 ](http://www.cnblogs.com/ahdung/p/4587003.html)
* [ServiceController 类 (System.ServiceProcess) ](https://msdn.microsoft.com/zh-cn/library/system.serviceprocess.servicecontroller(VS.80).aspx)
* [Self install windows service in .NET c# - Stack Overflow ](https://stackoverflow.com/questions/4144019/self-install-windows-service-in-net-c-sharp)
* [c# - Using ManagedInstallerClass.InstallHelper to install multiple services - Stack Overflow ](https://stackoverflow.com/questions/3398701/using-managedinstallerclass-installhelper-to-install-multiple-services)


```cs
using System.Configuration.Install;

/// <summary>
        /// 使用Windows Service对应的exe文件 安装Service
        /// 和 installutil xxx.exe 效果相同
        /// </summary>
        /// <param name="installFile">exe文件（包含路径）</param>
        /// <returns>是否安装成功</returns>
        public static bool InstallServie(string installFile)
        {
            string[] args = { installFile };
            try
            {
                ManagedInstallerClass.InstallHelper(args);
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 使用Windows Service对应的exe文件 卸载Service
        /// 和 installutil /u xxx.exe 效果相同
        /// </summary>
        /// <param name="installFile">exe文件（包含路径）</param>
        /// <returns>是否卸载成功</returns>
        public static bool UninstallService(string installFile)
        {
            string[] args = { "/u", installFile };
            try
            {
                // 根据文件获得服务名，假设exe文件名和服务名相同
                string tmp = installFile;
                if (tmp.IndexOf('\\') != -1)
                {
                    tmp = tmp.Substring(tmp.LastIndexOf('\\') + 1);
                }
                string svcName = tmp.Substring(0, tmp.LastIndexOf('.'));
                // 在卸载服务之前 要先停止windows服务
                StopService(svcName);

                ManagedInstallerClass.InstallHelper(args);
                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 获得service对应的ServiceController对象
        /// </summary>
        /// <param name="serviceName">服务名</param>
        /// <returns>ServiceController对象，若没有该服务，则返回null</returns>
        public static ServiceController GetService(string serviceName)
        {
            ServiceController[] services = ServiceController.GetServices();
            foreach (ServiceController s in services)
            {
                if (s.ServiceName == serviceName)
                {
                    return s;
                }
            }
            return null;
        }

        /// <summary>  
        /// 检查指定的服务是否存在。  
        /// </summary>  
        /// <param name="serviceName">要查找的服务名字</param>  
        /// <returns>是否存在</returns>  
        public static bool ServiceExisted(string serviceName)
        {
            if (GetService(serviceName) == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 获得Service的详细信息
        /// </summary>
        /// <param name="serviceName">服务名</param>
        /// <returns>Service信息，保存在string中</returns>
        public static string GetServiceInfo(string serviceName)
        {
            StringBuilder details = new StringBuilder();

            ServiceController sc = GetService(serviceName);

            if (sc == null)
            {
                return string.Format("{0} 不存在！", serviceName);
            }

            details.AppendLine(string.Format("服务标识的名称: {0}", sc.ServiceName));
            details.AppendLine(string.Format("服务友好名称：{0}", sc.DisplayName));
            details.AppendLine(string.Format("服务在启动后是否可以停止: {0}", sc.CanStop));
            details.AppendLine(string.Format("服务所驻留的计算机的名称: {0}", sc.MachineName)); // "." 表示本地计算机
            details.AppendLine(string.Format("服务类型： {0}", sc.ServiceType.ToString()));
            details.AppendLine(string.Format("服务状态： {0}", sc.Status.ToString()));

            // DependentServices 获取依赖于与此 ServiceController 实例关联的服务的服务集。
            StringBuilder dependentServices = new StringBuilder();
            foreach (ServiceController s in sc.DependentServices)
            {
                dependentServices.Append(s.ServiceName + ", ");
            }
            details.AppendLine(string.Format("依赖于与此 ServiceController 实例关联的服务的服务: {0}", dependentServices.ToString()));
            
            // ServicesDependedOn 此服务所依赖的服务集。
            StringBuilder serviceDependedOn = new StringBuilder();
            foreach (ServiceController s in sc.ServicesDependedOn)
            {
                serviceDependedOn.Append(s.ServiceName + ", ");
            }
            details.AppendLine(string.Format("此服务所依赖的服务: {0}", serviceDependedOn.ToString()));

            return details.ToString();
        }

        /// <summary>
        /// 启动服务
        /// </summary>
        /// <param name="serviceName">服务名</param>
        /// <returns>是否启动成功</returns>
        public static bool StartService(string serviceName)
        {
            ServiceController sc = GetService(serviceName);

            if (sc.Status != ServiceControllerStatus.Running)
            {
                try
                {
                    sc.Start();
                    sc.WaitForStatus(ServiceControllerStatus.Running);  // 等待服务达到指定状态
                }
                catch
                {
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// 停止服务
        /// </summary>
        /// <param name="serviceName">服务名</param>
        /// <returns>是否停止服务成功，如果服务启动后不可以停止，则抛异常</returns>
        public static bool StopService(string serviceName)
        {
            ServiceController sc = GetService(serviceName);

            if (!sc.CanStop)
            {
                throw new Exception(string.Format("服务{0}启动后不可以停止.", serviceName));
            }

            if (sc.Status != ServiceControllerStatus.Stopped)
            {
                try
                {
                    sc.Stop();
                    sc.WaitForStatus(ServiceControllerStatus.Stopped);  // 等待服务达到指定状态
                }
                catch
                {
                    return false;
                }
            }

            return true;
        }
```


* [确保该 HttpConfiguration.EnsureInitialized() - 广瓜网 ](http://www.guanggua.com/question/19969228-ensure-that-httpconfiguration-ensureinitialized.html)

```cs
//Route前面不能有“/”
[RoutePrefix("api/v1/services")]
[Route("listInfo")]
```